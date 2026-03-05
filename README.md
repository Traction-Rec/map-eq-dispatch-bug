# Map containsKey / equals dispatch bug (Apex)

Platform bug: for `Map<IKey, V>`, `containsKey(lookupKey)` can return false even when `lookupKey.hashCode()` matches a key in the map and both `lookupKey.equals(existingKey)` and `existingKey.equals(lookupKey)` are true.

**Root cause:** when the map’s key type is an interface, the platform may not call the key’s `equals()` during `containsKey()` (effectively using reference equality instead).

## tl;dr with aer vs sfapex

```
% aer test force-app                                             
PASS MapEqualsDispatchBugTest.containsKeyWithAbstractMiddle

Ran 1 tests: 1 passed, 0 failed
```

```
% sf apex run test -o test-31gzyr326ogv@example.com --synchronous
 ›   Warning: @salesforce/cli update available from 2.121.7 to 2.124.7.
=== Test Results
TEST NAME                                               OUTCOME  MESSAGE                                                                                                         RUNTIME (MS)
──────────────────────────────────────────────────────  ───────  ──────────────────────────────────────────────────────────────────────────────────────────────────────────────  ────────────
MapEqualsDispatchBugTest.containsKeyWithAbstractMiddle  Fail     System.AssertException: Assertion Failed: Hypothesis: containsKey with interface→abstract→concrete (StringKey)  
                                                                 Class.MapEqualsDispatchBugTest.containsKeyWithAbstractMiddle: line 22, column 1                                             




=== Test Summary
NAME                 VALUE                        
───────────────────  ─────────────────────────────
Outcome              Failed                       
Tests Ran            1                            
Pass Rate            0%                           
Fail Rate            100%                         
Skip Rate            0%                           
Test Run Id          707Au00002YjYS5              
Test Setup Time      0 ms                         
Test Execution Time  61 ms                        
Test Total Time      61 ms                        
Org Id               00DAu00000FNHxBMAX           
Username             test-31gzyr326ogv@example.com
```

## Minimal repro

| Class        | Purpose |
|-------------|--------|
| `IKey`      | Interface declaring `equals`, `hashCode`, `toString`. |
| `AbstractKey` | Abstract class implementing `IKey`; defines `equals`/`hashCode` (with `System.debug` so you can see if they’re called). |
| `StringKey` | Concrete key extending `AbstractKey` (interface → abstract → concrete). |
| `MapEqualsDispatchBugTest` | Single test that puts one key and checks `containsKey` with a second, equal key. |

The test builds a `Map<IKey, String>`, puts `k1 = new StringKey('hello')`, then creates `k2 = new StringKey('hello')`. It asserts that `k1` and `k2` have the same `hashCode` and that `k2.equals(existing)` and `existing.equals(k2)` for the map’s key. Then it asserts `m.containsKey(k2)`. When the bug occurs, that assertion fails and `AbstractKey.equals()` never appears in the Debug Log for the `containsKey` path.

## How to run

Run the test class `MapEqualsDispatchBugTest`. If the bug reproduces:

- The assertion `m.containsKey(k2)` fails.
- In the Debug Log, `AbstractKey.equals() called` does **not** appear for the `containsKey` call (you may see it for the manual `k2.equals(existing)` / `existing.equals(k2)` checks).

## Workaround (production)

- Key the map by `String` (e.g. `key.toString()`) so the platform uses string equality, or  
- Find the key by iterating (match `hashCode()` then call your `equals()`), then use the found key for `get()` instead of relying on `containsKey(lookupKey)`.
