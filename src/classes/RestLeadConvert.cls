@RestResource(urlMapping='/LeadConvert')
global with sharing class RestLeadConvert {            

    @HttpPost
    global static String doGet() {
        String ret = 'fail';
        RestRequest req = RestContext.request;
        String request_str = req.requestBody.toString();
        ConvertLeadsJson2ids json_data = (ConvertLeadsJson2ids)JSON.deserialize(request_str,ConvertLeadsJson2ids.class);  
     
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(json_data.leadId);
        if (json_data.accountId != 'none') {
            lc.setAccountId(json_data.accountId);
        }

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);           
        Database.LeadConvertResult lcr ;
        try{
            lcr = Database.convertLead(lc);
            system.debug('*****lcr.isSuccess()'+lcr.isSuccess());            
            ret = lcr.accountId+'_'+lcr.contactId;
        }
        catch(exception ex){
            system.debug('***NOT CONVERTED**');           
        }
        return ret;
    }   
}