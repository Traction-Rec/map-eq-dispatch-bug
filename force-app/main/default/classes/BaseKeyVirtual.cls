/**
 * Virtual concrete class that directly implements interface (virtual so it can be extended).
 * Mirrors project8: IKey <- BaseKey <- MidKey.
 * Does not override equals/hashCode; subclass MidKeyVirtual defines them.
 */
public virtual class BaseKeyVirtual implements IKey {
    private String key;

    public BaseKeyVirtual(String key) {
        this.key = key;
    }

    public virtual String getKeyValue() {
        return key;
    }

    public virtual Boolean equals(Object obj) {
        return this === obj;
    }

    public virtual Integer hashCode() {
        return System.hashCode(key);
    }

    public override String toString() {
        return key;
    }
}
