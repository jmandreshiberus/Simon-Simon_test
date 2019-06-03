public with sharing class KS_MergeToolController {

	private final sObject mysObject;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public KS_MergeToolController(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
    }

    /*public String getRecordName() {
        return 'Hello ' + (String)mysObject.get('name') + ' (' + (Id)mysObject.get('Id') + ')';
    }*/

    public void DeleteContacts()
    {
        KS_Batch_MergeTool_DeleteContacts del = new KS_Batch_MergeTool_DeleteContacts();
        ID batchprocessid = Database.executeBatch(del, 50);
    }
    public void MergeContacts()
    {
        KS_Batch_MergeTool_MergeContacts mrgCn = new KS_Batch_MergeTool_MergeContacts();
        ID batchprocessid = Database.executeBatch(mrgCn, 50);

    }
    public void MergeAccounts()
    {
        KS_Batch_MergeTool_MergeAccounts mrgAcc = new KS_Batch_MergeTool_MergeAccounts();
        ID batchprocessid = Database.executeBatch(mrgAcc, 50);
    }
}