/**
 * Concrete key. Extends AbstractKey (hypothesis 1: interface → abstract → concrete).
 * For minimal repro without hierarchy, a second concrete that implements IKey directly
 * can be used (see StringKeyDirect in tests if needed).
 */
public class StringKey extends AbstractKey {
    private String value;

    public StringKey(String value) {
        this.value = value;
    }

    protected override String getKeyValue() {
        return value;
    }
}
