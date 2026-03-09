/**
 * Abstract class with equals/hashCode in transitive chain:
 * IBaseKey <- ConcreteBase <- MidKey <- DeepAbstractKey (abstract with equals).
 * Platform may not dispatch to this equals when map key type is IBaseKey.
 */
public abstract class DeepAbstractKey extends MidKey {
    public DeepAbstractKey(String keyValue) {
        super(keyValue);
    }

    public override Boolean equals(Object obj) {
        System.debug('DeepAbstractKey.equals() called - dispatch worked!');
        if (obj instanceof DeepAbstractKey) {
            return ((DeepAbstractKey) obj).keyValue == this.keyValue;
        }
        return false;
    }

    public override Integer hashCode() {
        System.debug('DeepAbstractKey.hashCode() called - dispatch worked!');
        return keyValue != null ? System.hashCode(keyValue) : 0;
    }
}
