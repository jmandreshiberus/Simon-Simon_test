@RestResource(urlMapping='/MergeLeads')
global with sharing class MergeLeads {               
    @HttpPost
    global static String doGet() {
        String ret = 'fail';
        RestRequest req = RestContext.request;
        String request_str = req.requestBody.toString();
        MergeLeadsJson2ids json_data = (MergeLeadsJson2ids)JSON.deserialize(request_str,MergeLeadsJson2ids.class);

        Lead master = [SELECT Id FROM Lead WHERE id = :json_data.Id_master];
        Lead[] duplicates = [SELECT Id FROM Lead WHERE id = :json_data.Id_merge1];

        try {
            Database.MergeResult[] results = Database.merge(master, duplicates, false);
                       
            for(Database.MergeResult res : results) {
                if (res.isSuccess()) {
                    // Get the master ID from the result and validate it
                    System.debug('Master record ID: ' + res.getId());
                    System.assertEquals(master.Id, res.getId());              
                    
                    // Get the IDs of the merged records and display them
                    List<Id> mergedIds = res.getMergedRecordIds();
                    System.debug('IDs of merged records: ' + mergedIds);           
                    ret = 'ok';
                      
                }
                else {
                    for(Database.Error err : res.getErrors()) {
                        // Write each error to the debug output
                        System.debug(err.getMessage());
                        ret = err.getMessage();
                    }
                }
            }
            }
        catch(exception ex){
            system.debug('***NOT MERGED**');           
            }
        return ret;
    }   
 }