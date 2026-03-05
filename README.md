# Map containsKey / equals dispatch bug (Apex)

Platform bug: for `Map<ICacheKey, ICacheItem>`, `containsKey(lookupKey)` can return false even when `lookupKey.hashCode()` matches a key in the map and `lookupKey.equals(existingKey)` / `existingKey.equals(lookupKey)` are true. Root cause: when the map’s key type is an interface, the platform may not call the key’s `equals()` during `containsKey()` (effectively reference equality).

## Repro structure

| Class | Purpose |
|-------|--------|
| `IKey` | Interface (mirrors `ICacheKey`) |
| `AbstractKey` | **Hypothesis 1**: abstract class between interface and concrete; `equals`/`hashCode` live here |
| `StringKey` | Concrete key extending `AbstractKey` (interface → abstract → concrete) |
| `StringKeyDirect` | Concrete key implementing `IKey` directly (baseline: interface → concrete) |
| `KeyHolder` | **Hypothesis 2**: owns the map and creates/puts the key; caller creates lookup key elsewhere |
| `MapEqualsDispatchBugRunner` | **Hypothesis 3**: run scenario outside `@IsTest` (Execute Anonymous) |
| `MapEqualsDispatchBugTest` | Tests for all scenarios |

## How to run

1. **Tests**  
   Run `MapEqualsDispatchBugTest` (all methods). Check the Debug Log: if the bug appears, `AbstractKey.equals()` (or `StringKeyDirect.equals()`) is never logged for `containsKey`, and the corresponding assertion may fail.

2. **Hypothesis 3 – non-test context**  
   In Developer Console: **Debug → Open Execute Anonymous Window**, paste:
   ```apex
   MapEqualsDispatchBugRunner.runContainsKeyTest();
   ```
   Run with **Open Log**. In the log, check whether `containsKey(k2)` is true and whether `AbstractKey.equals() called` appears. If `containsKey` is false and `equals` is never logged, the bug reproduces outside `@IsTest`.

## Hypotheses

- **1. Hierarchy**  
  Production uses interface → abstract (`StringCacheKey`) → concrete (`SelectByIdCacheKey`). This repro adds `AbstractKey` in the middle with `equals`/`hashCode`. If the bug only appears when the key type is interface → abstract → concrete, the failure should show up in `containsKeyWithAbstractMiddle` or when using `StringKey` in the Runner.

- **2. Where keys are created**  
  In production, the key in the map is created in one path (e.g. selector/cache) and the lookup key in another (e.g. invalidation/test). `KeyHolder` mimics that: it creates and puts the key; the test (or Runner) creates the lookup key and calls `containsKey`. See `containsKeyCrossClassCreation`.

- **3. Test vs non-test**  
  The bug might only appear outside `@IsTest`. Use `MapEqualsDispatchBugRunner.runContainsKeyTest()` in Execute Anonymous to compare behavior.

## Workaround (production)

- Key the map by `String` (e.g. `key.toString()`) so the platform uses string equality, or  
- Find the key by iterating (match `hashCode()` then call your `equals()`), then use the found key for `get()` instead of relying on `containsKey(lookupKey)`.
