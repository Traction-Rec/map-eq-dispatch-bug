/**
 * Reproduces Salesforce platform bug: Map.containsKey(key) does NOT call
 * the key's equals() when the map is declared as Map<InterfaceType, V>.
 *
 * Hypotheses under test:
 * Hierarchy: interface → abstract → concrete (vs interface → concrete) may trigger the bug.
 */
@IsTest
private class MapEqualsDispatchBugTest {
    @IsTest
    static void containsKeyWithAbstractMiddle() {
        Map<IKey, String> m = new Map<IKey, String>();
        IKey k1 = new StringKey('hello');
        m.put(k1, 'value');
        IKey k2 = new StringKey('hello');
        System.assertEquals(k1.hashCode(), k2.hashCode());
        for (IKey existing : m.keySet()) {
            System.assert(k2.equals(existing), 'k2.equals(existing)');
            System.assert(existing.equals(k2), 'existing.equals(k2)');
        }
        // If bug reproduces: containsKey(k2) is false; AbstractKey.equals() never appears in Debug Log.
        System.assert(m.containsKey(k2), 'Hypothesis: containsKey with interface→abstract→concrete (StringKey)');
    }
}
