public class ArrayUtils {

  public static Object[] add(Object[] objectList, Object newObject) {
    return addAll(objectList, new Object[]{newObject});
  }

  public static Object[] addAll(Object[] objectList, Object[] newObjectList) {
    // FOR LOOP REQUIRED INSTEAD OF addAll() METHOD DUE TO BUG IN APEX
    for (Integer i = 0; i < newObjectList.size(); i++) {
      objectList.add(newObjectList.get(i));
    }
    return objectList;
  }

  
}