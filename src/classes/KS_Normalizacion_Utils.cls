public class KS_Normalizacion_Utils {
    
    private static Map<String,Boolean> configFlag = new Map<String,Boolean>();

    public static Map<String,Boolean> getConfigurationFlags() {
        if (!configFlag.isEmpty()) {return configFlag;}
        
        Map<String,Boolean> conf = new Map<String,Boolean>();
        
        for (KS_GlobalTriggerControl__mdt gtc : 
             [SELECT DeveloperName, ID, KS_TriggerName__c, KS_TriggerFunction__c, KS_TriggerActive__c FROM KS_GlobalTriggerControl__mdt
              WHERE KS_TriggerName__c LIKE 'KS_Normalizacion%']) 
        { conf.put(gtc.DeveloperName, gtc.KS_TriggerActive__c); }
        System.debug('-- -- JCAR -- getConfigurationFlag ' + conf);
        
        configFlag = conf;
        return conf;
    }
    
    public static Boolean getConfigurationFlag(String key) { return getConfigurationFlags().get(key); }
    public static void setConfigurationFlag(String key, Boolean bool) { configFlag.put(key, bool); }
    
    public static void executeNormalizacion(String sObjectType, List<sObject> scope) {
        
        System.debug('-- -- JCAR -- executeNormalizacion '+sObjectType+' -- -- '+scope);
        
        Map<String,sObject> batched = new Map<String,sObject>();
        if (sObjectType == Account.class.getName()) { batched = KS_Normalizacion.normalizarAccount( scopeToMap(scope) ); } 
        else if (sObjectType == Contact.class.getName()) { batched = KS_Normalizacion.normalizarContact( scopeToMap(scope) ); }
        if (batched != null && !batched.isEmpty()) {
            resultado( Database.update(batched.values(), false), batched, sObjectType);
        }
    }
    
    public static Map<String,sObject> scopeToMap(List<sObject> scope) {
        
        Map<String,sObject> mapScope = new Map<String,sObject>();
        for (sObject obj : scope) { mapScope.put(obj.ID, obj); }
        return mapScope;
    }
    
    public static void resultado(List<Database.SaveResult> saveResult, Map<String,sObject> batched, String sObjectType) {
        
        if (saveResult == null) {return;} if (saveResult.isEmpty()) {return;}
        if (batched == null) {return;} if (batched.isEmpty()) {return;}
        System.debug('-- -- JCAR -- executeNormalizacion resultado '+batched);
        
        String origen = 'executeNormalizacion';
        if (sObjectType == Account.class.getName()) { origen = 'normalizarAccount'; } 
        else if (sObjectType == Contact.class.getName()) { origen = 'normalizarContact'; }
        KS_Debug_Utils.processSaveResult(saveResult, batched, 'KS_Normalizacion', origen);
    }
}