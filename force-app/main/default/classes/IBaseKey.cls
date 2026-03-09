// Interface for transitive hierarchy: IBaseKey <- ConcreteBase <- MidKey <- DeepAbstractKey
public interface IBaseKey {
    Boolean equals(Object obj);
    Integer hashCode();
    String toString();
}
