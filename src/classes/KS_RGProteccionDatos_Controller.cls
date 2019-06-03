public class KS_RGProteccionDatos_Controller {

    public Lead led {get;set;} public Boolean getIsLead() { return led != null; }
    public Account acc {get;set;} public Boolean getIsAccount() { return acc != null; }
    public Contact con {get;set;} public Boolean getIsContact() { return con != null; }
    public Boolean guardado {get;set;}
    public String errorMSG {get;set;}
    
    public KS_RGProteccionDatos_Controller(ApexPages.StandardController controller) {
        
        errorMSG = '';
        sObject sobj = (sObject)controller.getRecord();
        led = sobj.getSobjectType() == Schema.Lead.getSObjectType() ? (Lead)sobj : null;
        acc = sobj.getSobjectType() == Schema.Account.getSObjectType() ? (Account)sobj : null;
        con = sobj.getSobjectType() == Schema.Contact.getSObjectType() ? (Contact)sobj : null;
        
        if (led != null) {
            led = [SELECT ID,Name,FirstName,Lastname,SI_Telefono_Movil__c,Email,Company,
                   KS_Tipo_de_via__c,KS_Calle__c,KS_N_m_portal_piso_puerta_y_resto_domici__c,
                   KS_C_digo_Postal__c,KS_Ciudad__c,KS_Estado_o_Provincia__c,KS_Pais__c,
                   KS_Consentimiento__c,KS_RechazoComunicaciones__c
                   FROM Lead WHERE ID = :led.ID];
        }
        if (acc != null) {
            acc = [SELECT ID,Name,FirstName,Lastname,Phone,PersonEmail FROM Account WHERE ID = :acc.ID];
        }
        if (con != null) {
            con = [SELECT ID,Name,FirstName,Lastname,
                   AccountId, SI_Telofono_Movil__c, Email, KS_Codigo_postal__c,
                   SI_Consiente_tratamiento_de_datos__c, SI_Rechaza_comunicaciones__c
                   FROM Contact WHERE ID = :con.ID];
        }
        
        guardado = false;
    }
    
    public String getReturnURL() {
        if (led != null) { return '/' + led.ID; }
        if (acc != null) { return '/' + acc.ID; }
        if (con != null) { return '/' + con.ID; }
        return '';
    }
    
    public PageReference save() {
        errorMSG = '';
        try {
            PageReference pg = null;
            if (led != null && led.ID != null) { update led; pg = new PageReference('/'+led.ID); }
            if (acc != null && acc.ID != null) { update acc; pg = new PageReference('/'+acc.ID); }
            if (con != null && con.ID != null) { update con; pg = new PageReference('/'+con.ID); }
            if (pg!=null) { guardado = true; pg.setRedirect(true); }
        } catch (Exception ex) {
            if (ex.getMessage().contains('VALIDATION_EXCEPTION')) {
                errorMSG = ex.getMessage().split('VALIDATION_EXCEPTION\\,')[1].split('\\: \\[\\]')[0];
            } else {
                errorMSG = ex.getMessage();
            }
        }
        return null;
    }
    public PageReference cancel() {
        PageReference pg = null;
        if (led != null && led.ID != null) { pg = new PageReference('/'+led.ID); }
        if (acc != null && acc.ID != null) { pg = new PageReference('/'+acc.ID); }
        if (con != null && con.ID != null) { pg = new PageReference('/'+con.ID); }
        if (pg!=null) { pg.setRedirect(true); }
        return null;
    }
    
    public static Boolean getIsAdmin() {
        if (UserInfo.getUserEmail()=='customers@kaizenstep.com') {return true;}
        return false;
    }
}