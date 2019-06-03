public class KS_Merge_CSVtoFusion_Controller {
	
    public String fields {get;set;}
    public String csv {get;set;}
    public KS_Fusion__c fusionHeader {get;set;}
    public KS_Merge_CSVtoFusion_Controller(ApexPages.StandardController stdController) {
        this.fusionHeader = (KS_Fusion__c)stdController.getRecord();
        //fields = '18-IDDUPLI;3-ID;1-IDSF;10-MOVIL;11-EMAIL;9-TELF1;21-MAIN';
        fields = '0-IDDUPLI;2-ID;2-IDSF;6-EMAIL;8-CALLE;10-CIUDAD;11-ESTADO;12-CODPOST;13-PAIS;14-TELF1;15-TELF2;16-TELF3;17-MOVIL';
    } 
    
    // MERGE CONTACT '18-IDDUPLI;3-ID;1-IDSF;10-MOVIL;11-EMAIL;9-TELF1;21-MAIN'
    // MERGE ACCOUNT '0-IDDUPLI;2-ID;2-IDSF,6-EMAIL;8-CALLE;10-CIUDAD;11-ESTADO;12-CODPOST;13-PAIS;14-TELF1;15-TELF2;16-TELF3;17-MOVIL'
    
    private Map<String,Integer> fieldIndex {get;set;}
    private Map<String,sObject> objectMap {get;set;}
    private Map<String,String> objectIndex {get;set;}
    private Map<String,Set<String>> fusionIndex {get;set;}
    private Map<String,String> fusionMain {get;set;}
    
    private Boolean isAcc {get;set;}// = fusionHeader.KS_Tipo__c=='ACCOUNT';
    private Boolean isCon {get;set;}// = fusionHeader.KS_Tipo__c=='CONTACT';
    
    private Set<ID> verifiedID {get;set;}
    
    public void convert() {
        isAcc = fusionHeader.KS_Tipo__c=='ACCOUNT';
        isCon = fusionHeader.KS_Tipo__c=='CONTACT';
        process();
        fusion();
    }
    
    public void process() {
        
        if (fusionHeader==null) {return;}       
        if (fields==null) {return;} if (fields.trim()=='') {return;} if (!fields.contains(';') && !fields.contains('-')) {return;}
        if (csv==null) {return;} if (csv.trim()=='') {return;} if (!csv.contains(';')) {return;}
        
        fieldIndex = new Map<String,Integer>();
        objectMap = new Map<String,sObject>();
        objectIndex = new Map<String,String>();
        fusionIndex = new Map<String,Set<String>>();
        fusionMain = new Map<String,String>();
        
        Boolean isAcc = fusionHeader.KS_Tipo__c=='ACCOUNT';
        Boolean isCon = fusionHeader.KS_Tipo__c=='CONTACT';
        
        System.debug('-- JCAR -- KS_Merge_CSVtoFusion_Controller process -- ACCOUNT? ' + isAcc);
        System.debug('-- JCAR -- KS_Merge_CSVtoFusion_Controller process -- CONTACT? ' + isCon);
        
        if (fusionHeader.KS_Accion__c!='MERGE') {
            if (fusionHeader.KS_Accion__c!='DELETE') {
                processDELETE(); return;
            }
        }
        
        for (String fieldData : fields.split(';')) {
            if (!fieldData.contains('-')) {continue;}
            if (fieldData.split('-').size()!=2) {continue;}
            if (!fieldData.split('-').get(0).isNumeric()) {continue;}
            fieldIndex.put(fieldData.split('-').get(1), Integer.valueOf(fieldData.split('-').get(0)));
        }
        System.debug('-- JCAR -- KS_Merge_CSVtoFusion_Controller process -- ' + fieldIndex.size() + ' TOTAL FIELDS ' + fieldIndex);
        
        verifiedID = new Set<ID>();
        Set<ID> verifyID = new Set<ID>();
        
        for (String rowDataStr : csv.split('\r\n'))  {

            if (!rowDataStr.contains(';')) {continue;}
            
            //18-IDDUPLI;3-ID;1-IDSF;10-MOVIL;11-EMAIL;9-TELF1;21-MAIN
            //0-IDDUPLI;2-ID;3-IDSF;6-EMAIL;8-CALLE;10-CIUDAD;11-ESTADO;12-CODPOST;13-PAIS;14-TELF1;15-TELF2;16-TELF3;17-MOVIL
            //IDDUPLI identifica el grupo de duplicados, ID es el identificador interno de cada objeto, y con ello, de ROW

            Account acc = new Account(); 
            Contact con = new Contact();
            
            if (!fieldIndex.containsKey('ID')) {continue;}
            if (!fieldIndex.containsKey('IDSF')) {continue;}
            if (!fieldIndex.containsKey('IDDUPLI')) {continue;}
            if (isCon&&!fieldIndex.containsKey('MAIN')) {continue;}

            List<String> rowData = rowDataStr.split(';',-1);
            String IDROW = rowData.get(fieldIndex.get('ID'));
            if (isAcc) { try { acc.ID = IDROW; } catch (Exception ex){} } 
            else if(isCon) { try { con.ID = IDROW; } catch (Exception ex){} }
            
            String IDDUPLI = rowData.get(fieldIndex.get('IDDUPLI'));
            Set<String> fusionIDs = new Set<String>();
            if (fusionIndex.containsKey(IDDUPLI)) { fusionIDs = fusionIndex.get(IDDUPLI); }
            fusionIDs.add(IDROW); fusionIndex.put(IDDUPLI, fusionIDs);
            
            verifyID.add(IDROW);

            String IDSF = rowData.get(fieldIndex.get('IDSF'));
            System.debug('-- JCAR -- KS_Merge_CSVtoFusion_Controller process -- IDDUPLI? ' + IDDUPLI);
            System.debug('-- JCAR -- KS_Merge_CSVtoFusion_Controller process -- IDROW? ' + IDROW);
            System.debug('-- JCAR -- KS_Merge_CSVtoFusion_Controller process -- IDSF? ' + IDSF);
            System.debug('-- JCAR -- KS_Merge_CSVtoFusion_Controller process -- rowData? ' + rowData);
            
            if (!fusionMain.containsKey(IDDUPLI)) { 
                
                // MERGE ACCOUNT '0-IDDUPLI;2-ID;2-IDSF,6-EMAIL;8-CALLE;10-CIUDAD;11-ESTADO;12-CODPOST;13-PAIS;14-TELF1;15-TELF2;16-TELF3;17-MOVIL'
                if (isAcc && IDDUPLI == IDROW) {
                    fusionMain.put(IDDUPLI, IDROW); 
                    
                    if (fieldIndex.containsKey('EMAIL')) 
                    { acc.KS_Email__c = rowData.get(fieldIndex.get('EMAIL')); }
                    if (fieldIndex.containsKey('CALLE')) 
                    { acc.BillingStreet = rowData.get(fieldIndex.get('CALLE')); }
                    if (fieldIndex.containsKey('CIUDAD')) 
                    { acc.BillingCity = rowData.get(fieldIndex.get('CIUDAD')); }
                    if (fieldIndex.containsKey('ESTADO')) 
                    { acc.BillingState = rowData.get(fieldIndex.get('ESTADO')); }
                    if (fieldIndex.containsKey('CODPOST')) 
                    { acc.BillingPostalCode = rowData.get(fieldIndex.get('CODPOST')); }
                    if (fieldIndex.containsKey('PAIS')) 
                    { acc.BillingCountryCode = rowData.get(fieldIndex.get('PAIS')); }
                    if (fieldIndex.containsKey('TELF1')) 
                    { acc.Phone = rowData.get(fieldIndex.get('TELF1')); }
                    if (fieldIndex.containsKey('TELF2')) 
                    { acc.KS_N_de_telefono_2__c = rowData.get(fieldIndex.get('TELF2')); }
                    if (fieldIndex.containsKey('TELF3')) 
                    { acc.KS_N_de_telefono_3__c = rowData.get(fieldIndex.get('TELF3')); }
                    if (fieldIndex.containsKey('CANAL')) 
                    { acc.KS_Canal__c = rowData.get(fieldIndex.get('CANAL')); }
                    if (fieldIndex.containsKey('ACTIV')) 
                    { acc.KS_Actividad__c = rowData.get(fieldIndex.get('ACTIV')); }
                    if (fieldIndex.containsKey('SUBACTIV')) 
                    { acc.KS_Subactividad__c = rowData.get(fieldIndex.get('SUBACTIV')); }
                    if (fieldIndex.containsKey('SECTOR')) 
                    { acc.KS_Sector__c = rowData.get(fieldIndex.get('SECTOR')); }    
                    
                //18-IDDUPLI;3-ID;1-IDSF;10-MOVIL;11-EMAIL;9-TELF1;21-MAIN    
                } else if (isCon && rowData.get(fieldIndex.get('MAIN')) == 'SI') {
                    fusionMain.put(IDDUPLI, IDROW); 
                    
                    if (fieldIndex.containsKey('TELF1')) 
                    { con.Phone = rowData.get(fieldIndex.get('TELF1')); }
                    if (fieldIndex.containsKey('TELF2')) 
                    { con.OtherPhone = rowData.get(fieldIndex.get('TELF2')); }
                    if (fieldIndex.containsKey('MOVIL')) 
                    { con.MobilePhone = rowData.get(fieldIndex.get('MOVIL')); }
                    if (fieldIndex.containsKey('EMAIL')) 
                    { con.Email = rowData.get(fieldIndex.get('EMAIL')); }
                    if (fieldIndex.containsKey('FUNCION')) 
                    { con.KS_Funcion_en_empresa__c = rowData.get(fieldIndex.get('FUNCION')); }
                    if (fieldIndex.containsKey('IDIOMA')) 
                    { con.KS_Idioma__c = rowData.get(fieldIndex.get('IDIOMA')); }
                }
            }
            
            objectIndex.put(IDROW, IDSF);
            if (isAcc) { objectMap.put(IDROW, acc); } else if(isCon) { objectMap.put(IDROW, con); }
        }
        
        System.debug('-- JCAR -- KS_Merge_CSVtoFusion_Controller process -- ' + fusionIndex.size() + ' - TOTAL FUSION INDEX ' + fusionIndex.keySet());
        System.debug('-- JCAR -- KS_Merge_CSVtoFusion_Controller process -- ' + objectIndex.size() + ' - TOTAL OBJECTS INDEX ' + objectIndex.keySet());
        System.debug('-- JCAR -- KS_Merge_CSVtoFusion_Controller process -- ' + objectMap.size() + ' - TOTAL OBJECTS ' + objectMap.keySet());
        System.debug('-- JCAR -- KS_Merge_CSVtoFusion_Controller process -- ' + fusionMain.size() + ' - TOTAL FUSION MAIN ' + fusionMain);
        
        if (isAcc) { for (Account obj : [SELECT ID FROM Account WHERE ID in :verifyID]) { verifiedID.add(obj.ID); } }
        if (isCon) { for (Contact obj : [SELECT ID FROM Contact WHERE ID in :verifyID]) { verifiedID.add(obj.ID); } }
    }
    
    public void processDELETE() {
        System.debug('-- JCAR -- KS_Merge_CSVtoFusion_Controller processDELETE!!');
        
        fusionLst = new List<KS_Fusion__c>();
        for (String rowDataStr : csv.split('\r\n'))  {
            
            rowDataStr = rowDataStr.trim();
            if (rowDataStr.contains(';')) {rowDataStr = rowDataStr.split(';')[0];}
            KS_Fusion__c fus = new KS_Fusion__c();
            fus.KS_Id_Principal__c = rowDataStr;
            fus.KS_Accion__c = fusionHeader.KS_Accion__c;
            fus.KS_Tipo__c = fusionHeader.KS_Tipo__c;
            fusionLst.add(fus);
        }
        System.debug('-- JCAR -- KS_Merge_CSVtoFusion_Controller processDELETE fusion -- ' + fusionLst.size() + ' - TOTAL FUSION LIST ' + fusionLst);
        insert fusionLst;
    }
    
    private List<KS_Fusion__c> fusionLst {get;set;}
    
    public void fusion() {
        fusionLst = new List<KS_Fusion__c>();
        for (String IDDUPLI : fusionIndex.keySet()) {
            Set<String> fusionIDs = fusionIndex.get(IDDUPLI);
            for (String IDROW : fusionIDs) {
                String IDSF = objectIndex.get(IDROW);
                if (IDSF == IDDUPLI && IDROW == fusionMain.get(IDDUPLI)) { continue; }
                
                KS_Fusion__c fus = new KS_Fusion__c();
                fus.KS_Id_Principal__c = fusionMain.get(IDDUPLI);
                fus.KS_Id_Duplicado__c = IDROW;
                fus.KS_Accion__c = fusionHeader.KS_Accion__c;
                fus.KS_Tipo__c = fusionHeader.KS_Tipo__c;
                
                if (!verifiedID.contains(fus.KS_Id_Principal__c)) { continue; }
                if (!verifiedID.contains(fus.KS_Id_Duplicado__c)) { continue; }
                if (fus.KS_Id_Principal__c == fus.KS_Id_Duplicado__c) { continue; }
                if (isAcc) {
                    
                    Account acc = (Account)objectMap.get(fusionMain.get(IDDUPLI));
                    if (acc.KS_Email__c != null) 
                    { fus.KS_Acc_Correo__c = acc.KS_Email__c; }
                    if (acc.BillingStreet != null) 
                    { fus.KS_Acc_Calle__c = acc.BillingStreet; }
                    if (acc.BillingCity != null) 
                    { fus.KS_Acc_Ciudad__c = acc.BillingCity; }
                    if (acc.BillingState != null) 
                    { fus.KS_Acc_Estado_Provincia__c = acc.BillingState; }
                    if (acc.BillingPostalCode != null) 
                    { fus.KS_Acc_Codigo_Postal__c = acc.BillingPostalCode; }
                    if (acc.BillingCountryCode != null) 
                    { fus.KS_Acc_Pais__c = acc.BillingCountryCode; }
                    if (acc.Phone != null) 
                    { fus.KS_Acc_Telefono__c = acc.Phone; }
                    if (acc.KS_N_de_telefono_2__c != null) 
                    { fus.KS_Acc_Telefono_2__c = acc.KS_N_de_telefono_2__c; }
                    if (acc.KS_N_de_telefono_3__c != null) 
                    { fus.KS_Acc_Telefono_3__c = acc.KS_N_de_telefono_3__c; }
                    if (acc.KS_Canal__c != null) 
                    { fus.KS_Acc_Canal__c = acc.KS_Canal__c; }
                    if (acc.KS_Actividad__c != null) 
                    { fus.KS_Acc_Actividad__c = acc.KS_Actividad__c; }
                    if (acc.KS_Subactividad__c != null) 
                    { fus.KS_Acc_Subactividad__c = acc.KS_Subactividad__c; }
                    if (acc.KS_Sector__c != null) 
                    { fus.KS_Acc_Sector__c = acc.KS_Sector__c; }
                    
                } else if (isCon) {
                    Contact con = (Contact)objectMap.get(fusionMain.get(IDDUPLI));
                    if (con.Phone != null) 
                    { fus.KS_Ctc_Telefono__c = con.Phone; }
                    if (con.OtherPhone != null) 
                    { fus.KS_Ctc_Telefono_Particular__c = con.OtherPhone; }
                    if (con.MobilePhone != null) 
                    { fus.KS_Ctc_Movil__c = con.MobilePhone; }
                    if (con.Email != null) 
                    { fus.KS_Ctc_Correo__c = con.Email; }
                    if (con.KS_Funcion_en_empresa__c != null) 
                    { fus.KS_Ctc_Funcion_en_empresa__c = con.KS_Funcion_en_empresa__c; }
                    if (con.KS_Idioma__c != null) 
                    { fus.KS_Ctc_Idioma__c = con.KS_Idioma__c; }
                }
                
                fusionLst.add(fus);
            }
        }
        System.debug('-- JCAR -- KS_Merge_CSVtoFusion_Controller fusion -- ' + fusionLst.size() + ' - TOTAL FUSION LIST ' + fusionLst);
        insert fusionLst;
    }
}