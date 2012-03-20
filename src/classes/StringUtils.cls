public class StringUtils {
  
    public static String joinSet(Set<String> stringSet, String separator){
      String returnString = '';
      Integer i = 0;
      for (String s: stringSet) {
        returnString += s;
        if (i < stringSet.size() - 1) {
          returnString += separator;
        }
        i++;
      }
      return returnString;
    }

}