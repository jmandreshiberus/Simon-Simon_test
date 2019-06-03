@isTest
public class KS_Trigger_Test {

    public static Boolean blockTrigger = false;
    public static testMethod void disableTrigger(){ blockTrigger = true; }
    public static testMethod void enableTrigger(){ blockTrigger = false; }
    
    public static testMethod Test_Data testTrigger(){
        KS_Trigger_Test.disableTrigger();
        Test_Data data = new Test_Data(); 
        KS_Trigger_Test.enableTrigger();
        return data;
    }
    
    public static testMethod Profile TEST_Profile(){
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        Profile prf = tstfnc.getProfile();
        return prf;
    }
    public static testMethod User TEST_User() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        KS_Trigger_Test.disableTrigger();
        Profile prf = tstfnc.getProfile();
        KS_Trigger_Test.enableTrigger();
        User usr = tstfnc.createUser(prf);
        return usr;
    }
    public static testMethod KS_Obra__c TEST_Obra() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        KS_Obra__c obr = tstfnc.createObra(rtM);
        return obr;
    }
    public static testMethod Account TEST_Account() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        Account acc = tstfnc.createAccDistribuidor(rtM);
        return acc;
    }
    public static testMethod Contact TEST_Contact() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        KS_Trigger_Test.disableTrigger();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        Account acc = tstfnc.createAccDistribuidor(rtM);
        KS_Trigger_Test.enableTrigger();
        Contact con = tstfnc.createContact(acc);
        return con;
    }
    public static testMethod KS_Estructura_Geografica__c TEST_Estructura_Geografica() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        KS_Trigger_Test.disableTrigger();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        Account acc = tstfnc.createAccDistribuidor(rtM);
        KS_Trigger_Test.enableTrigger();
        KS_Estructura_Geografica__c ege = tstfnc.createEstructuraGeografica(acc);
        return ege;
    }
    public static testMethod KS_Organizacion_Cliente__c TEST_Organizacion_Cliente() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        KS_Trigger_Test.disableTrigger();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        Account acc = tstfnc.createAccDistribuidor(rtM);
        KS_Estructura_Geografica__c ege = tstfnc.createEstructuraGeografica(acc);
        KS_Trigger_Test.enableTrigger();
        KS_Organizacion_Cliente__c org = tstfnc.createAccDistribuidorOrganizacion(acc, ege);
        return org;
    }
    public static testMethod Pricebook2 TEST_Pricebook() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        Pricebook2 pbs = tstfnc.createPricebook();
        return pbs;
    }
    public static testMethod KS_Usuario_MarcaArea__c TEST_Usuario_MarcaArea() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        KS_Trigger_Test.disableTrigger();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        Account acc = tstfnc.createAccDistribuidor(rtM);
        KS_Estructura_Geografica__c ege = tstfnc.createEstructuraGeografica(acc);
        KS_Organizacion_Cliente__c org = tstfnc.createAccDistribuidorOrganizacion(acc, ege);
        KS_Trigger_Test.enableTrigger();
        KS_Usuario_MarcaArea__c uma = tstfnc.createUserArea(org);
        return uma;
    }
    public static testMethod Opportunity TEST_Opportunity() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        KS_Trigger_Test.disableTrigger();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        KS_Obra__c obr = tstfnc.createObra(rtM);
        Account acc = tstfnc.createAccDistribuidor(rtM);
        Pricebook2 pbS = tstfnc.createPricebook();
        KS_Estructura_Geografica__c ege = tstfnc.createEstructuraGeografica(acc);
        KS_Organizacion_Cliente__c org = tstfnc.createAccDistribuidorOrganizacion(acc, ege);
        KS_Trigger_Test.enableTrigger();
        Opportunity opp = tstfnc.createOferta(acc, org, obr, pbS);
        return opp;
    }
    public static testMethod KS_Condicion_de_Obra__c TEST_Condicion_de_Obra() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        KS_Trigger_Test.disableTrigger();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        KS_Obra__c obr = tstfnc.createObra(rtM);
        Account acc = tstfnc.createAccDistribuidor(rtM);
        Pricebook2 pbS = tstfnc.createPricebook();
        KS_Estructura_Geografica__c ege = tstfnc.createEstructuraGeografica(acc);
        KS_Organizacion_Cliente__c org = tstfnc.createAccDistribuidorOrganizacion(acc, ege);
        Opportunity opp = tstfnc.createOferta(acc, org, obr, pbS);
        KS_Trigger_Test.enableTrigger();
        KS_Condicion_de_Obra__c cobra = tstfnc.createCondicionObra(opp);
        return cobra;
    }
    public static testMethod Product2 TEST_Product() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        Product2 prd = tstfnc.creaProduct('PRODTEST1234');
        return prd;
    }
    public static testMethod PricebookEntry TEST_PricebookEntry() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        KS_Trigger_Test.disableTrigger();
        Pricebook2 pbs = tstfnc.createPricebook();
        Product2 prd = tstfnc.creaProduct('PRODTEST1234');
        KS_Trigger_Test.enableTrigger();
        PricebookEntry pbE = tstfnc.getPricebookEntry(prd, pbS);
        return pbE;
    }
    public static testMethod OpportunityLineItem TEST_OpportunityLineItem() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        KS_Trigger_Test.disableTrigger();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        KS_Obra__c obr = tstfnc.createObra(rtM);
        Account acc = tstfnc.createAccDistribuidor(rtM);
        Pricebook2 pbS = tstfnc.createPricebook();
        KS_Estructura_Geografica__c ege = tstfnc.createEstructuraGeografica(acc);
        KS_Organizacion_Cliente__c org = tstfnc.createAccDistribuidorOrganizacion(acc, ege);
        Opportunity opp = tstfnc.createOferta(acc, org, obr, pbS);
        Product2 prd = tstfnc.creaProduct('PRODTEST1234');
        PricebookEntry pbE = tstfnc.getPricebookEntry(prd, pbS);
        KS_Trigger_Test.enableTrigger();
        OpportunityLineItem ofL = tstfnc.createLineaOferta(opp, prd, pbE);
        return ofL;
    }
    public static testMethod KS_Oferta_Pendiente__c TEST_KS_Oferta_Pendiente() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        KS_Trigger_Test.disableTrigger();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        KS_Obra__c obr = tstfnc.createObra(rtM);
        Account acc = tstfnc.createAccDistribuidor(rtM);
        Pricebook2 pbS = tstfnc.createPricebook();
        KS_Estructura_Geografica__c ege = tstfnc.createEstructuraGeografica(acc);
        KS_Organizacion_Cliente__c org = tstfnc.createAccDistribuidorOrganizacion(acc, ege);
        Opportunity opp = tstfnc.createOferta(acc, org, obr, pbS);
        KS_Trigger_Test.enableTrigger();
        KS_Oferta_Pendiente__c ofP = tstfnc.createOfertaPendiente(opp);
        return ofP;
    }
    public static testMethod KS_Obra_Ubicacion__c TEST_Obra_Ubicacion() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        KS_Trigger_Test.disableTrigger();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        KS_Obra__c obr = tstfnc.createObra(rtM);
        Account acc = tstfnc.createAccDistribuidor(rtM);
        KS_Estructura_Geografica__c ege = tstfnc.createEstructuraGeografica(acc);
        KS_Trigger_Test.enableTrigger();
        KS_Obra_Ubicacion__c obu = tstfnc.createObraUbicacion(obr, ege);
        return obu;
    }
    public static testMethod KS_Organizacion_Producto__c TEST_Organizacion_Producto() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        KS_Trigger_Test.disableTrigger();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        Account acc = tstfnc.createAccDistribuidor(rtM);
        KS_Estructura_Geografica__c ege = tstfnc.createEstructuraGeografica(acc);
        KS_Organizacion_Cliente__c org = tstfnc.createAccDistribuidorOrganizacion(acc, ege);
        Product2 prd = tstfnc.creaProduct('PRODTEST1234');
        KS_Trigger_Test.enableTrigger();
        KS_Organizacion_Producto__c orgp = tstfnc.createOrgProductoForProducto(prd, org);
        return orgp;
    }
    public static testMethod KS_Condicion_Comercial__c TEST_Condicion_Comercial() {
        KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
        KS_Trigger_Test.disableTrigger();
        Map<String, ID> rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
        Account acc = tstfnc.createAccDistribuidor(rtM);
        KS_Estructura_Geografica__c ege = tstfnc.createEstructuraGeografica(acc);
        KS_Organizacion_Cliente__c org = tstfnc.createAccDistribuidorOrganizacion(acc, ege);
        Product2 prd = tstfnc.creaProduct('PRODTEST1234');
        KS_Trigger_Test.enableTrigger();
        KS_Condicion_Comercial__c ccp = tstfnc.createCondicionComercialForProducto(prd, org);
        return ccp;
    }
    
    public class Test_Data {
        
        public Map<String, ID> rtM {get;set;}
        public Profile prf {get;set;}
        public User usr {get;set;}
        public KS_Obra__c obr {get;set;}
        public Account acc {get;set;}
        public Contact con {get;set;}
        public KS_Estructura_Geografica__c ege {get;set;}
        public KS_Organizacion_Cliente__c org {get;set;}
        public Pricebook2 pbS {get;set;}
        public KS_Usuario_MarcaArea__c uma {get;set;}
        public Opportunity opp {get;set;}
        public KS_Condicion_de_Obra__c cobra {get;set;}
        public Product2 prd {get;set;}
        public PricebookEntry pbE {get;set;}
        public OpportunityLineItem ofL {get;set;}
        public KS_Oferta_Pendiente__c ofP {get;set;}
        public KS_Obra_Ubicacion__c obu {get;set;}
        public KS_Organizacion_Producto__c orgp {get;set;}
        public KS_Condicion_Comercial__c ccp {get;set;}
        
        public Test_Data() {
            
            KS_TEST_FUNCTIONS tstfnc = new KS_TEST_FUNCTIONS();
            
            rtM = KS_TEST_FUNCTIONS.getRecordTypeStatic();
            prf = tstfnc.getProfile();
            usr = tstfnc.createUser(prf);
            obr = tstfnc.createObra(rtM);
            acc = tstfnc.createAccDistribuidor(rtM);
            con = tstfnc.createContact(acc);
            ege =  tstfnc.createEstructuraGeografica(acc);
            org = tstfnc.createAccDistribuidorOrganizacion(acc, ege);
            pbS = tstfnc.createPricebook();
            uma = tstfnc.createUserArea(org);
            opp = tstfnc.createOferta(acc, org, obr, pbS);
            cobra = tstfnc.createCondicionObra(opp);
            prd = tstfnc.creaProduct('PRODTEST1234');
            pbE = tstfnc.getPricebookEntry(prd, pbS);
            ofL = tstfnc.createLineaOferta(opp, prd, pbE);
            ofP = tstfnc.createOfertaPendiente(opp);
            obu = tstfnc.createObraUbicacion(obr, ege);
            orgp = tstfnc.createOrgProductoForProducto(prd, org);
            ccp = tstfnc.createCondicionComercialForProducto(prd, org);
            
            Product2 prd2 = tstfnc.creaProduct('PRODTEST4321');
            KS_Organizacion_Producto__c orgp2 = tstfnc.createOrgProductoForProducto(prd2, org);
        }
    }
}