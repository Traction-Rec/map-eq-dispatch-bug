/**
 * Concrete key at end of transitive chain: ... <- DeepAbstractKey <- ConcreteDeepKey.
 */
public class ConcreteDeepKey extends DeepAbstractKey {
    public ConcreteDeepKey(String keyValue) {
        super(keyValue);
    }
}
