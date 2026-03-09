/**
 * Extends virtual base that implements IKey; defines value-based equals/hashCode.
 * Like project8 MidKey but with value equality so two instances can be "equal".
 * If platform does not dispatch to this equals for Map<IKey,V>, containsKey will fail.
 */
public class MidKeyVirtual extends BaseKeyVirtual {
    public MidKeyVirtual(String key) {
        super(key);
    }

    public override Boolean equals(Object obj) {
        System.debug('MidKeyVirtual.equals() called - dispatch worked!');
        if (obj instanceof MidKeyVirtual) {
            return ((MidKeyVirtual) obj).getKeyValue() == this.getKeyValue();
        }
        return false;
    }

    public override Integer hashCode() {
        System.debug('MidKeyVirtual.hashCode() called - dispatch worked!');
        String v = getKeyValue();
        return v != null ? System.hashCode(v) : 0;
    }
}
