/**
 * Hypothesis 1: Abstract class between IKey and concrete.
 * Production has ICacheKey → StringCacheKey (abstract) → SelectByIdCacheKey.
 * equals/hashCode live here to mirror that structure; platform may only
 * dispatch to equals when key type is a class, not an interface.
 */
public abstract class AbstractKey implements IKey {
    protected abstract String getKeyValue();

    public Boolean equals(Object obj) {
        System.debug('AbstractKey.equals() called - dispatch worked!');
        if (obj instanceof AbstractKey) {
            return ((AbstractKey) obj).getKeyValue() == this.getKeyValue();
        }
        return false;
    }

    public Integer hashCode() {
        System.debug('AbstractKey.hashCode() called - dispatch worked!');
        String v = getKeyValue();
        return v != null ? System.hashCode(v) : 0;
    }

    public override String toString() {
        return getKeyValue();
    }
}
