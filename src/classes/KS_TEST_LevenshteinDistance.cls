@isTest
public class KS_TEST_LevenshteinDistance {

    public static testMethod void TEST_levenshteinDistanceSelectValue() {
        
        // Si hay menos cambios que la distancia, devuelve el valor antiguo
        String selected = KS_LevenshteinDistance_Utils.levenshteinDistanceSelectValue('ABCD', 'ABEF', 3);
        System.debug('TEST_levenshteinDistanceSelectValue selected ' + (selected == 'ABCD') + ' ' + selected);
        System.assertEquals(selected,'ABCD');
        
        // Si hay mismos cambios que la distancia, devuelve el valor nuevo
        selected = KS_LevenshteinDistance_Utils.levenshteinDistanceSelectValue('ABCD', 'ABEF', 2);
        System.debug('TEST_levenshteinDistanceSelectValue selected ' + (selected == 'ABCD') + ' ' + selected);
        System.assertEquals(selected,'ABEF');
        
        // Si hay más cambios que la distancia, devuelve el valor nuevo
        selected = KS_LevenshteinDistance_Utils.levenshteinDistanceSelectValue('ABCD', 'ABEF', 1);
        System.debug('TEST_levenshteinDistanceSelectValue selected ' + (selected == 'ABEF') + ' ' + selected);
        System.assertEquals(selected,'ABEF');
    }
    
    public static testMethod void TEST_levenshteinDistancePercentageToCount() {
        Decimal diff = KS_LevenshteinDistance_Utils.levenshteinDistancePercentageToCount('1234567890',Decimal.valueOf(50));
        System.debug('TEST_levenshteinDistancePercentageToCount diff ' + (diff == Decimal.valueOf(5)) + ' ' + diff);
        System.assertEquals(diff, Decimal.valueOf(5));
    }
    
    public static testMethod void TEST_levenshteinDistanceFrom() {
        Map<String,Decimal> levenshteinDistance = KS_LevenshteinDistance_Utils.levenshteinDistanceFrom(Account.class.getName());
        System.debug('TEST_levenshteinDistanceFrom levenshteinDistance ' + Account.class.getName() + ' ' + levenshteinDistance);
        System.assertEquals(levenshteinDistance.isEmpty(), false);
    }
   
    public static testMethod void TEST_levenshteinDistanceByPercentage() {
        String oldVal = 'AVENIDA MERIDIANA, 5';
        String newVal = 'Avda. Meridiana 354';
        Decimal dist = KS_LevenshteinDistance_Utils.getLevenshteinDistanceUpperCase(oldVal, newVal);
        Decimal pctg = KS_LevenshteinDistance_Utils.levenshteinGetPercentageDistance(oldVal,newVal);
        
        System.debug('TEST_levenshteinDistanceByPercentage PercentageToCount ' + pctg + '%');
        System.assertEquals(dist, KS_LevenshteinDistance_Utils.levenshteinDistancePercentageToCount(oldVal,pctg));
        
        String endVal = KS_LevenshteinDistance_Utils.levenshteinDistanceByPercentage(oldVal,newVal,pctg);
        System.debug('TEST_levenshteinDistanceByPercentage levenshteinDistance ' + (endVal == newVal) + ' ' + endVal);
        System.assertEquals(endVal, newVal);
    }
     
    public static testMethod void TEST_levenshteinDistanceByPercentageWhenZero() {
        String oldVal = '1234567890';
        String newVal = '123456789';
        
        String endVal = KS_LevenshteinDistance_Utils.levenshteinDistanceByPercentage(oldVal,newVal,0);
        System.debug('TEST_levenshteinDistanceByPercentageWhenZero levenshteinDistance ' + (endVal == newVal) + ' ' + endVal);
        System.assertEquals(endVal, newVal);
    }

}