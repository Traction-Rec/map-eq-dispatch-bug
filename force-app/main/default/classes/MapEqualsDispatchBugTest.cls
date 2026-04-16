/**
 * Reproduces Salesforce platform bug: Map.containsKey(key) does NOT call
 * the key's equals() when the map is declared as Map<InterfaceType, V>.
 *
 * Hypotheses under test:
 * 1. Hierarchy: interface → abstract → concrete (vs interface → concrete) may trigger the bug.
 * 2. Transitive hierarchy: IBaseKey <- ConcreteBase <- MidKey <- DeepAbstractKey (equals on deep abstract).
 * 3. Virtual concrete that directly implements interface: IKey <- BaseKeyVirtual <- MidKeyVirtual (project8 style).
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

    /**
     * Transitive hierarchy: IBaseKey <- ConcreteBase <- MidKey <- DeepAbstractKey (abstract with equals) <- ConcreteDeepKey.
     * Confirms the same dispatch bug when equals lives on a deep abstract in a longer chain.
     */
    @IsTest
    static void containsKeyWithTransitiveHierarchy() {
        Map<IBaseKey, String> m = new Map<IBaseKey, String>();
        IBaseKey k1 = new ConcreteDeepKey('transitive');
        m.put(k1, 'value');
        IBaseKey k2 = new ConcreteDeepKey('transitive');
        System.assertEquals(k1.hashCode(), k2.hashCode());
        for (IBaseKey existing : m.keySet()) {
            System.assert(k2.equals(existing), 'k2.equals(existing)');
            System.assert(existing.equals(k2), 'existing.equals(k2)');
        }
        // If bug reproduces: containsKey(k2) is false; DeepAbstractKey.equals() never appears in Debug Log.
        System.assert(m.containsKey(k2), 'Hypothesis: containsKey with transitive IBaseKey<-ConcreteBase<-MidKey<-DeepAbstractKey<-ConcreteDeepKey');
    }

    /**
     * Virtual concrete class that directly implements interface: IKey <- BaseKeyVirtual <- MidKeyVirtual.
     * Equals/hashCode defined in MidKeyVirtual; map declared as Map<IKey, V>.
     */
    @IsTest
    static void containsKeyWithVirtualConcreteImplementor() {
        Map<IKey, String> m = new Map<IKey, String>();
        IKey k1 = new MidKeyVirtual('virtual');
        m.put(k1, 'value');
        IKey k2 = new MidKeyVirtual('virtual');
        System.assertEquals(k1.hashCode(), k2.hashCode());
        for (IKey existing : m.keySet()) {
            System.assert(k2.equals(existing), 'k2.equals(existing)');
            System.assert(existing.equals(k2), 'existing.equals(k2)');
        }
        // If bug reproduces: containsKey(k2) is false; MidKeyVirtual.equals() never appears in Debug Log.
        System.assert(m.containsKey(k2), 'Hypothesis: containsKey with virtual concrete implementor (IKey<-BaseKeyVirtual<-MidKeyVirtual)');
    }

    // --- put / get / remove vs same preamble (expected: equals-based keying even when containsKey is wrong) ---

    @IsTest
    static void putWithEqualKeyKeepsSizeOneAbstractMiddle() {
        Map<IKey, String> m = new Map<IKey, String>();
        IKey k1 = new StringKey('hello');
        m.put(k1, 'value');
        IKey k2 = new StringKey('hello');
        System.assertEquals(k1.hashCode(), k2.hashCode());
        for (IKey existing : m.keySet()) {
            System.assert(k2.equals(existing), 'k2.equals(existing)');
            System.assert(existing.equals(k2), 'existing.equals(k2)');
        }
        m.put(k2, 'value2');
        System.assertEquals(1, m.size(), 'put(k2) should replace same logical key, not add a second bucket');
    }

    @IsTest
    static void getWithEqualKeysReturnsSameValueAbstractMiddle() {
        Map<IKey, String> m = new Map<IKey, String>();
        IKey k1 = new StringKey('hello');
        m.put(k1, 'value');
        IKey k2 = new StringKey('hello');
        System.assertEquals(k1.hashCode(), k2.hashCode());
        for (IKey existing : m.keySet()) {
            System.assert(k2.equals(existing), 'k2.equals(existing)');
            System.assert(existing.equals(k2), 'existing.equals(k2)');
        }
        System.assertEquals(m.get(k1), m.get(k2), 'get should resolve k2 to the same entry as k1');
    }

    @IsTest
    static void removeWithEqualKeyEmptiesMapAbstractMiddle() {
        Map<IKey, String> m = new Map<IKey, String>();
        IKey k1 = new StringKey('hello');
        m.put(k1, 'value');
        IKey k2 = new StringKey('hello');
        System.assertEquals(k1.hashCode(), k2.hashCode());
        for (IKey existing : m.keySet()) {
            System.assert(k2.equals(existing), 'k2.equals(existing)');
            System.assert(existing.equals(k2), 'existing.equals(k2)');
        }
        m.remove(k2);
        System.assertEquals(0, m.size(), 'remove(k2) should remove the lone entry keyed equivalently to k1');
    }

    @IsTest
    static void putWithEqualKeyKeepsSizeOneTransitiveHierarchy() {
        Map<IBaseKey, String> m = new Map<IBaseKey, String>();
        IBaseKey k1 = new ConcreteDeepKey('transitive');
        m.put(k1, 'value');
        IBaseKey k2 = new ConcreteDeepKey('transitive');
        System.assertEquals(k1.hashCode(), k2.hashCode());
        for (IBaseKey existing : m.keySet()) {
            System.assert(k2.equals(existing), 'k2.equals(existing)');
            System.assert(existing.equals(k2), 'existing.equals(k2)');
        }
        m.put(k2, 'value2');
        System.assertEquals(1, m.size(), 'put(k2) should replace same logical key, not add a second bucket');
    }

    @IsTest
    static void getWithEqualKeysReturnsSameValueTransitiveHierarchy() {
        Map<IBaseKey, String> m = new Map<IBaseKey, String>();
        IBaseKey k1 = new ConcreteDeepKey('transitive');
        m.put(k1, 'value');
        IBaseKey k2 = new ConcreteDeepKey('transitive');
        System.assertEquals(k1.hashCode(), k2.hashCode());
        for (IBaseKey existing : m.keySet()) {
            System.assert(k2.equals(existing), 'k2.equals(existing)');
            System.assert(existing.equals(k2), 'existing.equals(k2)');
        }
        System.assertEquals(m.get(k1), m.get(k2), 'get should resolve k2 to the same entry as k1');
    }

    @IsTest
    static void removeWithEqualKeyEmptiesMapTransitiveHierarchy() {
        Map<IBaseKey, String> m = new Map<IBaseKey, String>();
        IBaseKey k1 = new ConcreteDeepKey('transitive');
        m.put(k1, 'value');
        IBaseKey k2 = new ConcreteDeepKey('transitive');
        System.assertEquals(k1.hashCode(), k2.hashCode());
        for (IBaseKey existing : m.keySet()) {
            System.assert(k2.equals(existing), 'k2.equals(existing)');
            System.assert(existing.equals(k2), 'existing.equals(k2)');
        }
        m.remove(k2);
        System.assertEquals(0, m.size(), 'remove(k2) should remove the lone entry keyed equivalently to k1');
    }

    @IsTest
    static void putWithEqualKeyKeepsSizeOneVirtualConcreteImplementor() {
        Map<IKey, String> m = new Map<IKey, String>();
        IKey k1 = new MidKeyVirtual('virtual');
        m.put(k1, 'value');
        IKey k2 = new MidKeyVirtual('virtual');
        System.assertEquals(k1.hashCode(), k2.hashCode());
        for (IKey existing : m.keySet()) {
            System.assert(k2.equals(existing), 'k2.equals(existing)');
            System.assert(existing.equals(k2), 'existing.equals(k2)');
        }
        m.put(k2, 'value2');
        System.assertEquals(1, m.size(), 'put(k2) should replace same logical key, not add a second bucket');
    }

    @IsTest
    static void getWithEqualKeysReturnsSameValueVirtualConcreteImplementor() {
        Map<IKey, String> m = new Map<IKey, String>();
        IKey k1 = new MidKeyVirtual('virtual');
        m.put(k1, 'value');
        IKey k2 = new MidKeyVirtual('virtual');
        System.assertEquals(k1.hashCode(), k2.hashCode());
        for (IKey existing : m.keySet()) {
            System.assert(k2.equals(existing), 'k2.equals(existing)');
            System.assert(existing.equals(k2), 'existing.equals(k2)');
        }
        System.assertEquals(m.get(k1), m.get(k2), 'get should resolve k2 to the same entry as k1');
    }

    @IsTest
    static void removeWithEqualKeyEmptiesMapVirtualConcreteImplementor() {
        Map<IKey, String> m = new Map<IKey, String>();
        IKey k1 = new MidKeyVirtual('virtual');
        m.put(k1, 'value');
        IKey k2 = new MidKeyVirtual('virtual');
        System.assertEquals(k1.hashCode(), k2.hashCode());
        for (IKey existing : m.keySet()) {
            System.assert(k2.equals(existing), 'k2.equals(existing)');
            System.assert(existing.equals(k2), 'existing.equals(k2)');
        }
        m.remove(k2);
        System.assertEquals(0, m.size(), 'remove(k2) should remove the lone entry keyed equivalently to k1');
    }
}
