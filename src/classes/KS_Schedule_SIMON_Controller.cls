global without sharing class KS_Schedule_SIMON_Controller {

    private static String CRON_EXPStatus = '0 30 00 * * ?';
    private static String CRON_EXPScorin = '0 30 01 * * ?';
    private static String CRON_EXPAttach = '0 30 04 * * ?';
    private static String CRON_EXPcNotes = '0 30 05 * * ?';
    
    public String statusH {get;set;}
    public String statusM {get;set;}
    public String scorinH {get;set;}
    public String scorinM {get;set;}
    public String attachH {get;set;}
    public String attachM {get;set;}
    public String cnotesH {get;set;}
    public String cnotesM {get;set;}    
    
    public String scorinIDs {get;set;}
    public Integer scorinChunk {get;set;}

    public String orgClieIDs {get;set;}
    public Integer orgClieChunk {get;set;}
    
    public String productIDs {get;set;}
    public Integer productChunk {get;set;}
    
    Integer attachSize = 200;
    Integer cNotesSize = 200;
    
    public String cConComDia {get;set;}// = '15';
    public String cConComHor {get;set;}// = '23';
    
    public String normalizacionIDs {get;set;}
    
    public KS_Schedule_SIMON_Controller(ApexPages.StandardController controller) {
        System.debug('-------------------------JCAR - KS_Schedule_SIMON_Controller');
        statusH = '00'; statusM = '00';
        scorinH = '01'; scorinM = '00';
        attachH = '04'; attachM = '00';
        cnotesH = '05'; cnotesM = '00';
        scorinChunk = 50;
        orgClieChunk = 10;
        productChunk = 10;
        cConComDia = '15'; cConComHor = '23';
    }
    
    public void callScheduleLeadAccounts() {
        
        CRON_EXPStatus = '0 ' + statusM + ' ' + statusH + ' * * ?';
        
        System.debug('-------------------------JCAR - callScheduleLeadAccounts');
        KS_Schedule_Cuentas sc = new KS_Schedule_Cuentas();
        String schld = System.schedule('Daily - Lead - Status Update', CRON_EXPStatus, sc);

        System.debug('-------------------------JCAR - callScheduleLeadAccounts ' + schld);
    }
    
    public void callScheduleLeadAccounts_Manual() {
        System.debug('-------------------------JCAR - callScheduleLeadAccounts_Manual');
		
        System.debug('-------------------------JCAR - callScheduleLeadAccounts_Manual userProfile - ' + getProfile());
        
        String rt = 'KS_Lead';
        String q = 'SELECT ID FROM Account WHERE KS_recordType_Name__c = \''+rt+'\'';
        String e = 'Account';
        
        Id batchInstanceId = Database.executeBatch(new KS_Batch_Cuentas(q,e,'',''), 200);
        System.debug('-------------------------JCAR - callScheduleLeadAccounts_Manual ' + batchInstanceId); 
    }
    
    public void callScheduleAccScoring() {//return;
                                          
        CRON_EXPScorin = '0 ' + scorinM + ' ' + scorinH + ' * * ?';
                                          
        System.debug('-------------------------JCAR - callScheduleAccScoring');
        KS_Schedule_AccScoring sas = new KS_Schedule_AccScoring(scorinChunk);
        String schld = System.schedule('Daily - Marca - Scoring Update', CRON_EXPScorin, sas);

        System.debug('-------------------------JCAR - callScheduleAccScoring ' + schld);
    }
    
    public void callScheduleAccScoring_Manual() {//return;
        System.debug('-------------------------JCAR - callScheduleAccScoring_Manual');
		
        System.debug('-------------------------JCAR - callScheduleAccScoring_Manual userProfile - ' + getProfile());
        
        String scorinIDLst = '';
        if (scorinIDs != null && scorinIDs.trim() != '') {
            
            scorinIDLst = '(';
            Integer x = 1; Integer l = scorinIDs.split(';').size();
            for (String s : scorinIDs.split(';')) { 
                scorinIDLst += ('\'' + s + '\''); 
                if (x < l) { scorinIDLst += ','; } x++;
            }
            scorinIDLst += ')';
        }
        
        String rt = '(\'Distribuidores CRM\', \'Distribuidores SAP\', \'Clientes finales\', \'Prescriptores\', \'Instalador\')';
        String q = 'SELECT ID, KS_recordType_Name__c, KS_Canal__c FROM Account WHERE KS_Canal__c in ' + rt 
            + (scorinIDLst != null && scorinIDLst.trim() != '' ? ' and ID in ' + scorinIDLst : '');
        String e = 'Account';
        
        Id batchInstanceId = Database.executeBatch(new KS_Batch_AccScoring(q,e,'',''), scorinChunk);
        System.debug('-------------------------JCAR - callScheduleAccScoring_Manual ' + batchInstanceId); 
    }

    private String getProfile() {
        List<Profile> profLst = [SELECT ID,Name FROM Profile];
        for (Profile prof : profLst) {
            if (prof.ID == userInfo.getProfileId()) { return prof.Name; }
        }
        return '';
    }
    
    public void callScheduleAttach() {//return;
        
        CRON_EXPAttach = '0 ' + attachM + ' ' + attachH + ' * * ?';
        Integer bSize = 200;
        
        System.debug('-------------------------JCAR - callScheduleAttach');
        ConvertAttachmentsToFilesSchedulable ca2f = new ConvertAttachmentsToFilesSchedulable(bSize);
        String schld = System.schedule('Daily - AttachmentsToFiles', CRON_EXPAttach, ca2f);
        System.debug('-------------------------JCAR - callScheduleAttach ' + schld);
    }
    
    public void callScheduleAttach_Manual() {//return;
        System.debug('-------------------------JCAR - callScheduleAttach_Manual');
        
        ConvertAttachmentsToFilesOptions bOptions = new ConvertAttachmentsToFilesOptions();
        Integer bSize = 200;

        System.debug( '-------------------------JCAR - callScheduleAttach_Manual Options: ' + bOptions );
        System.debug( '-------------------------JCAR - callScheduleAttach_Manual Batch Size: ' + bSize );

        ConvertAttachmentsToFilesBatchable batchable = new ConvertAttachmentsToFilesBatchable(bOptions);
        Id batchInstanceId = Database.executeBatch( batchable, bSize );

        System.debug('-------------------------JCAR - callScheduleAttach_Manual ' + batchInstanceId);
    }
    
    public void callScheduleCNotes() {//return;
        
        CRON_EXPcNotes = '0 ' + cNotesM + ' ' + cNotesH + ' * * ?';
        Integer bSize = 200;
        
        System.debug('-------------------------JCAR - callScheduleCNotes');
        ConvertNotesToContentNotesSchedulable n2cn = new ConvertNotesToContentNotesSchedulable(bSize);
        String schld = System.schedule('Daily - NotesToContentNotes', CRON_EXPcNotes, n2cn);
        System.debug('-------------------------JCAR - callScheduleCNotes ' + schld);
    }
    
    public void callScheduleCNotes_Manual() {//return;
        System.debug('-------------------------JCAR - callScheduleCNotes_Manual');
        
        ConvertNotesToContentNotesOptions bOptions = new ConvertNotesToContentNotesOptions();
        Integer bSize = 200;

        System.debug( '-------------------------JCAR - callScheduleCNotes_Manual Options: ' + bOptions );
        System.debug( '-------------------------JCAR - callScheduleCNotes_Manual Batch Size: ' + bSize );

        ConvertNotesToContentNotesBatchable batchable = new ConvertNotesToContentNotesBatchable( bOptions );
        Id batchInstanceId = Database.executeBatch( batchable, bSize );
        
        System.debug('-------------------------JCAR - callScheduleCNotes_Manual ' + batchInstanceId);
    }
    
    public void callRepairProduct() {
        System.debug('-------------------------JCAR - callRepairProduct');
        
        String productIDLst = '';
        if (productIDs != null && productIDs.trim() != '') {
            
            productIDLst = '(';
            Integer x = 1; Integer l = productIDs.split(';').size();
            for (String s : productIDs.split(';')) { 
                productIDLst += ('\'' + s + '\''); 
                if (x < l) { productIDLst += ','; } x++;
            }
            productIDLst += ')';
        }
        
        String rt = '(\'KS_Productos_estndard\')';
        String q = 'SELECT ID FROM Product2 WHERE RecordType.DeveloperName IN ' + rt
            + (productIDLst != null && productIDLst.trim() != '' ? ' AND ID in ' + productIDLst : '');
        String e = 'Product2';
        
        Id batchInstanceId = Database.executeBatch(new KS_Batch_RepairProduct(q,e,'',''), productChunk);
        System.debug('-------------------------JCAR - callRepairProduct ' + batchInstanceId); 
    }
    
    public void callScheduleRepairOrgCliente_Manual() {//return;
        System.debug('-------------------------JCAR - callScheduleRepairOrgCliente_Manual');

        String orgClieIDLst = '';
        if (orgClieIDs != null && orgClieIDs.trim() != '') {
            
            orgClieIDLst = '(';
            Integer x = 1; Integer l = orgClieIDs.split(';').size();
            for (String s : orgClieIDs.split(';')) { 
                orgClieIDLst += ('\'' + s + '\''); 
                if (x < l) { orgClieIDLst += ','; } x++;
            }
            orgClieIDLst += ')';
        }
        
        //String rt = '(\'Distribuidores CRM\', \'Distribuidores SAP\', \'Clientes finales\', \'Prescriptores\', \'Instalador\')';
        //String rt = '(\'Distribuidores SAP\')';
        //String q = 'SELECT ID, KS_recordType_Name__c, KS_Canal__c FROM Account WHERE KS_Canal__c in ' + rt 
        String q = 'SELECT ID, KS_recordType_Name__c, KS_Canal__c FROM Account WHERE KS_CountOC__c > 0 '
            + (orgClieIDLst != null && orgClieIDLst.trim() != '' ? ' AND ID in ' + orgClieIDLst : '');
        String e = 'Account';
        
        Id batchInstanceId = Database.executeBatch(new KS_Batch_RepairOrgCliente(q,e,'',''), orgClieChunk);
        System.debug('-------------------------JCAR - callScheduleRepairOrgCliente_Manual ' + batchInstanceId); 
    }
    
    public void callScheduleDeleteConComerciales() {
        String CRON = '0 00 ' + /*23*/cConComHor + ' ' + /*15*/cConComDia + ' * ?';
        if (cConComHor=='99') {
            DateTime now = DateTime.now().addMinutes(5);
            CRON = '0 ' + now.minute() + ' ' + now.hour() + ' ' + now.day() + ' * ?';
        }
        System.debug('-------------------------JCAR - callScheduleDeleteConComerciales');
        KS_Schedule_DeleteConCom sc = new KS_Schedule_DeleteConCom();
        String schld = System.schedule('Monthly - Day 15 - Condiciones Comerciales - DELETE', CRON, sc);
        System.debug('-------------------------JCAR - callScheduleDeleteConComerciales ' + schld);
    }
    public static void callScheduleDeleteConComerciales_Manual() {
        String q = 'SELECT ID FROM KS_Condicion_Comercial__c WHERE (NOT KS_ID_condicion_comercial__c LIKE \'MANUAL%\') AND CreatedDate <= ' + Datetime.now().addDays(-1).format('YYYY-MM-dd\'T\'kk:mm:ss')+'.000+0000';
        String e = 'KS_Condicion_Comercial__c';
        Id batchInstanceId = Database.executeBatch(new KS_Batch_CondicionesComerciales_Delete(q,e,'',''), 5000);
        System.debug('-------------------------JCAR - callScheduleDeleteConComerciales_Manual ' + batchInstanceId); 
    }
    
    public void callBatchNormalizacion_Accounts() {
        callBatchNormalizacion(Account.class.getName(), KS_Batch_Normalizacion.getQueryAccount(), normalizacionIDs);
    }
    public void callBatchNormalizacion_Contacts() {
        callBatchNormalizacion(Contact.class.getName(), KS_Batch_Normalizacion.getQueryContact(), normalizacionIDs);
    }
    public static void callBatchNormalizacion(String sObjectType, String query, String idString) {
        
        String normalizacionIDLst = '';
        if (idString != null && idString.trim() != '') {
            
            normalizacionIDLst = ' WHERE ID in (';
            Integer x = 1; Integer l = idString.split(';').size();
            for (String s : idString.split(';')) { 
                normalizacionIDLst += ('\'' + s + '\''); 
                if (x < l) { normalizacionIDLst += ','; } x++;
            }
            normalizacionIDLst += ')';
        }
        
        System.debug('-------------------------JCAR - callBatchNormalizacion ' + sObjectType); 
        System.debug('-------------------------JCAR - callBatchNormalizacion QRY ' + query); 
        KS_Batch_Normalizacion batchNormal = 
            new KS_Batch_Normalizacion( query + normalizacionIDLst, sObjectType );
        Id batchInstanceId = DataBase.executeBatch(batchNormal, 1);
        System.debug('-------------------------JCAR - callBatchNormalizacion ' + batchInstanceId); 
    }
    
}