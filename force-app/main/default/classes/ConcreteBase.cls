/**
 * Concrete base in transitive chain: IBaseKey <- ConcreteBase <- MidKey <- DeepAbstractKey.
 * Virtual so MidKey can extend; equals/hashCode virtual so DeepAbstractKey can override.
 */
public virtual class ConcreteBase implements IBaseKey {
    protected String keyValue;

    public ConcreteBase(String keyValue) {
        this.keyValue = keyValue;
    }

    public virtual Boolean equals(Object obj) {
        return this === obj;
    }

    public virtual Integer hashCode() {
        return System.hashCode(keyValue);
    }

    public override String toString() {
        return keyValue;
    }
}
