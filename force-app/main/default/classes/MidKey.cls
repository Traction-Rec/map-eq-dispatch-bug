/**
 * Mid layer: IBaseKey <- ConcreteBase <- MidKey <- DeepAbstractKey.
 * Does not override equals/hashCode.
 */
public virtual class MidKey extends ConcreteBase {
    public MidKey(String keyValue) {
        super(keyValue);
    }
}
