public with sharing class ConvertLeadsJson2ids {
    public String leadId;
    public String accountId;
    
    public ConvertLeadsJson2ids() {}
    
    public ConvertLeadsJson2ids(String leadId, String accountId){
        this.leadId = leadId;
        this.accountId = accountId;
    }

    public static ConvertLeadsJson2ids parse(String json) {
        return (ConvertLeadsJson2ids) System.JSON.deserialize(json, ConvertLeadsJson2ids.class);    
    }
}