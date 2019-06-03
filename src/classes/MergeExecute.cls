@RestResource(urlMapping='/MergeExecute/*')
global with sharing class MergeExecute {            

    @HttpGet
    global static String doGet() {
        String ret = 'fail';
        RestRequest req = RestContext.request;
        String type = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);     
        
        if (type == 'Contact'){
            KS_Batch_MergeTool_MergeContacts mrgCn = new KS_Batch_MergeTool_MergeContacts();

            try{
                ID batchprocessid = Database.executeBatch(mrgCn);
                system.debug('*****lcr.isSuccess()'+batchprocessid);            
                ret = 'ok';
            }
            catch(exception ex){
                system.debug('***NOT MERGED***');           
            }
        } else if (type == 'Account'){
            KS_Batch_MergeTool_MergeAccounts mrgAc = new KS_Batch_MergeTool_MergeAccounts();

            try{
                ID batchprocessid = Database.executeBatch(mrgAc);
                system.debug('*****lcr.isSuccess()'+batchprocessid);            
                ret = 'ok';
            }
            catch(exception ex){
                system.debug('***NOT MERGED***');           
            }
        } else if (type=='All'){
            KS_Batch_MergeTool_MergeContacts mrgCn2 = new KS_Batch_MergeTool_MergeContacts();

            try{
                ID batchprocessid = Database.executeBatch(mrgCn2);
                system.debug('*****lcr.isSuccess()'+batchprocessid);            
                ret = 'ok';
            }
            catch(exception ex){
                system.debug('***NOT MERGED***');           
            }
            KS_Batch_MergeTool_MergeAccounts mrgAc2 = new KS_Batch_MergeTool_MergeAccounts();

            try{
                ID batchprocessid = Database.executeBatch(mrgAc2);
                system.debug('*****lcr.isSuccess()'+batchprocessid);            
                ret = ret + '_ok';
            }
            catch(exception ex){
                system.debug('***NOT MERGED***');           
            }        
        }
        return ret;
    }   
}