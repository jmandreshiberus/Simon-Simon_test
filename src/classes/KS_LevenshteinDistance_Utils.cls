public class KS_LevenshteinDistance_Utils {

    public static Map<String,Decimal> levenshteinDistanceFrom(String sObjectType) {
        Map<String,Decimal> levenshteinDistance = new Map<String,Decimal>();
        if (sObjectType == null) {return levenshteinDistance;} if (sObjectType.trim() == '') {return levenshteinDistance;}
        for (KS_LevenshteinDistance__mdt ld : [SELECT KS_Field__c,KS_Distance__c FROM KS_LevenshteinDistance__mdt WHERE KS_Object__c = :sObjectType]) 
        { levenshteinDistance.put(ld.KS_Field__c, ld.KS_Distance__c); }
        return levenshteinDistance;
    }
    
    public static String levenshteinDistanceByPercentage(String oldVal, String newVal, Decimal diffPctg) {
        if (oldVal == null) {return oldVal;}
        if (newVal == null) {return oldVal;}
        if (oldVal.length() == 0) {return newVal;}
        //if (diffPctg == 0) { return newVal; }
        
        Decimal diff = levenshteinDistancePercentageToCount(oldVal, diffPctg);
        return levenshteinDistanceSelectValue(oldVal, newVal, diff);
    }
    
    public static Decimal levenshteinDistancePercentageToCount(String text, Decimal diffPctg)
    { return text.length() * (diffPctg/100); }
    
    public static String levenshteinDistanceSelectValue(String oldVal, String newVal, Decimal diff) 
    { return getLevenshteinDistanceUpperCase(oldVal, newVal) >= diff ? newVal : oldVal; }
    
    public static Decimal levenshteinGetPercentageDistance(String oldVal, String newVal) {
        if (oldVal == null) {return 0;}
        if (newVal == null) {return 0;}
        if (newVal.length() == 0) {return 0;}
        if (oldVal.length() == 0) {return 100;}
        Decimal dist = getLevenshteinDistanceUpperCase(oldVal, newVal);
        return dist > 0 ? (dist/oldVal.length())*100 : 0;
    }
    
    public static Decimal getLevenshteinDistanceUpperCase(String oldVal, String newVal) {
        if (oldVal == null) {return 0;} if (newVal == null) {return 0;} if (oldVal.length() == 0) {return 100;}
        return oldVal.toUpperCase().getLevenshteinDistance(newVal.toUpperCase());
    }
}