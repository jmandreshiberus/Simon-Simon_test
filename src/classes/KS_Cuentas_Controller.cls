public without sharing class KS_Cuentas_Controller {
    
    //public List<Cuenta> cuentas {get;set;}
    public Cuenta filtro {get;set;}
    
    public KS_Cuentas_Controller(ApexPages.StandardController controller) {
        
        /*cuentas = new List<Cuenta>();
        List<Account> accLst = [SELECT ID, Name, KS_ID_SAP__c, KS_Id_Salesforce__c, 
                                ShippingCountry, ShippingCity, ShippingState, ShippingPostalCode, ShippingStreet,
                                BillingCountry, BillingCity, BillingState, BillingPostalCode, BillingStreet
                                FROM Account WHERE KS_recordType_name__c = 'KS_Distribuidores' OR KS_recordType_name__c = 'KS_Distribuidores_SAP'
                                limit 4000];
        for (Account acc : accLst) {
            Cuenta c = new Cuenta(acc);
            cuentas.add(c);
        }*/
        filtro = new Cuenta();
    }
    
    public ApexPages.StandardSetController setCon {
        get {
            if (setCon == null) {

                String fltrName = filtro.name != null ? '%'+filtro.name+'%' : '%%';
                String fltriSAP = filtro.idSap != null ? filtro.idSap+'%' : '%%';
                String fltrCoPs = filtro.codpost != null ? filtro.codpost+'%' : '%%';
                
                String accQRY = 'SELECT ID, Name, KS_ID_SAP__c, KS_Id_Salesforce__c, Phone, '
                    + ' ShippingCountry, ShippingCity, ShippingState, ShippingPostalCode, ShippingStreet, '
                    + ' BillingCountry, BillingCity, BillingState, BillingPostalCode, BillingStreet '
                    + ' FROM Account WHERE (KS_recordType_name__c = \'KS_Distribuidores\' OR KS_recordType_name__c = \'KS_Distribuidores_SAP\') '
                    + ' AND Name LIKE \'' + fltrName + '\' '
                    + ' AND KS_ID_SAP__c LIKE \'' + fltriSAP + '\' '
                    + ' AND ( ShippingPostalCode LIKE \'' + fltrCoPs + '\' '
                    + ' OR BillingPostalCode LIKE \'' + fltrCoPs + '\') '
                    + ' limit 4000';
                
                System.debug(' -- JCAR -- accQRY -- ' + accQRY);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(accQRY));
                setCon.setpageSize(25);
            }
            return SetCon;
        }
        set;
    } 
        
    public List<Cuenta> getCuentas() {

        List<Cuenta> cLst = new List<Cuenta>();
        List<Account> accLst = (List<Account>) setCon.getRecords();
        for (Account acc : accLst) {
            Cuenta c = new Cuenta(acc);
            cLst.add(c);
        }
        return cLst;
    }
    
    public void getCuentasFilter(){
        setcon = null; getCuentas();
    }    
    
    public void gotoNext() { setCon.next(); }
    
    public void gotoPrevious() { setCon.previous(); }
    
    public class Cuenta {
		
        public String url {get;set;}
        public String idsap {get;set;}
        public String idSF {get;set;}
        public String name {get;set;}
        public String direccion {get;set;}
        public String provincia {get;set;}
        public String codpost {get;set;}
        public String telefon {get;set;}
        
        public Cuenta() {}
        public Cuenta(Account acc) {
            url = acc.ID;
            idsap = acc.KS_ID_SAP__C;
            idSF = acc.KS_ID_SAP__C;
            name = acc.Name;
            if (acc.ShippingStreet != null && acc.ShippingState != null && acc.ShippingPostalCode != null) {
                direccion = acc.ShippingStreet;
                provincia = acc.ShippingState;
                codpost = acc.ShippingPostalCode;                
            } else {
                direccion = acc.BillingStreet;
                provincia = acc.BillingState;
                codpost = acc.BillingPostalCode;                
            }
            telefon = acc.Phone;
        }
    }
}