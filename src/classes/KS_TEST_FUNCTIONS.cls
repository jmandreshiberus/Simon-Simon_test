public with sharing class KS_TEST_FUNCTIONS {
    
    public static Map<String, ID> getRecordTypeStatic() {
        
        Map<String, ID> rtM = new Map<String, ID>();
        for (RecordType rt : [SELECT ID, DeveloperName FROM RecordType]) {
            rtM.put(rt.DeveloperName, rt.ID);
        }
        return rtM;
    }
    public Map<String, ID> getRecordType() {
        return KS_TEST_FUNCTIONS.getRecordTypeStatic();
    }
    
    public Profile getProfile() {        
        return [SELECT ID, Name FROM Profile WHERE Name = 'Administrador del sistema' OR Name like 'System Administrator' LIMIT 1];
    }
    
    public User createUser(Profile prf) {
        
        User usr = new User();
        
        usr.FirstName = 'Test';
        usr.LastName = 'User';
        usr.Email = integer.ValueOf(Math.rint(Math.random() * 100000)) + 'test@user.sf';
        usr.Username = usr.Email;
        usr.Alias = 'USRTST';
        usr.LanguageLocaleKey = 'es';
        usr.LocaleSidKey = 'es_ES';
        usr.TimeZoneSidKey = 'Europe/Paris';
        usr.EmailEncodingKey = 'ISO-8859-1';
        usr.ProfileId = prf.ID;
        usr.KS_IDSAP__c = 'TESTUSER';
        
        insert usr; return usr;
    }
    
    public KS_Obra__c createObra(Map<String, ID> rtM){

        KS_Obra__c obra = new KS_Obra__c();
        ID rt = rtM.get('KS_Oportunidades');
        obra.RecordTypeId = rt;
        
        obra.Name = 'TEST OBRA ' + integer.ValueOf(Math.rint(Math.random() * 100000));
        obra.KS_Fase__c = 'En curso';
        obra.KS_Marca__c = 'SI10';
        obra.KS_Codigo_Postal__c = '08099';
             
        upsert obra; return obra;
    }
    
    public Account createAccDistribuidor(Map<String, ID> rtM) {
        
        Account acc = new Account();
        ID rt = rtM.get('KS_Distribuidores_SAP');
        acc.RecordTypeId = rt;
        
        acc.Name = 'Test Cuenta ' + integer.ValueOf(Math.rint(Math.random() * 100000));
        acc.KS_Id_SAP__c = 'IDSAPTEST' + integer.ValueOf(Math.rint(Math.random() * 100000));
        acc.Phone = '666666666';
        acc.BillingCountryCode = 'ES';
        acc.BillingCity = 'Barcelona';
        acc.BillingPostalCode = '08907';
        acc.BillingStreet = 'Calle de gracia';
        acc.KS_Grupo_de_ctas_deudor__c = '0001';
        acc.KS_Idioma__c = 'ES';
        acc.KS_Nombre_2__c = 'Cliente Distribuidor TEST';
        acc.KS_N_identificacion_fiscal_suplementario__c = '1';
        acc.KS_Numero_de_identificacion_fiscal_1__c = '1';
        acc.KS_N_de_telefono_2__c = '1';
        acc.KS_Actividad__c = 'Distribuidor';
        acc.KS_Canal__c = 'Distribuidores SAP';
        
        upsert acc; return acc;
    }
    
    public Contact createContact(Account acc) {
        
        Contact con = new Contact();
		con.AccountId = acc.ID;
        con.Salutation = 'Sr.';
        con.FirstName = 'Pruebo';
        con.LastName = 'Testez';
        
        upsert con; return con;        
    }
    
    public KS_Estructura_Geografica__c createEstructuraGeografica(Account acc) {
        
        KS_Estructura_Geografica__c ege = new KS_Estructura_Geografica__c();
        
        ege.KS_CPDesde__c = acc.BillingPostalCode;
        ege.KS_CPHasta__c = acc.BillingPostalCode;
        ege.KS_Organizacion_de_ventas__c = 'SI10';
        ege.KS_Area__c = '1030';
        ege.KS_Delegacion__c = '006';
        ege.KS_Zona__c = '8';
        
        upsert ege; return ege;
    }
    
    public KS_Organizacion_Cliente__c createAccDistribuidorOrganizacion(Account acc, KS_Estructura_Geografica__c ege) {
        
        KS_Organizacion_Cliente__c orgClie = new KS_Organizacion_Cliente__c();
        
        orgClie.CurrencyIsoCode = 'EUR';
        orgClie.KS_Bloqueo_contabilizacion_para_sociedad__c = true; //Boolean
        orgClie.KS_Bloqueo_de_entrega_para_cliente__c = '01';
        orgClie.KS_Bloqueo_de_factura_para_cliente__c = '01';
        orgClie.KS_Bloqueo_de_pedido_para_cliente__c = '01';
        orgClie.KS_Canal_de_distribucion__c = '10';
        orgClie.KS_Clasificacion_de_Clientes__c = '1';
        orgClie.KS_Clave_de_condiciones_de_pago__c = '0001';
        
        orgClie.KS_Cliente_Distribucion__c = acc.ID;
        orgClie.KS_Cliente_Dest_Mercancias__c = acc.ID;
        orgClie.KS_Cliente_solicitante__c = acc.ID;        
        
        orgClie.KS_Grupo_de_vendedores__c = '000';
        orgClie.KS_Incoterms_parte_1__c = '1';
        orgClie.KS_Incoterms_parte_2__c = '1';
        orgClie.KS_Lista_de_precios__c = '00';
        orgClie.KS_Oficinas_de_ventas__c = '1010';
        orgClie.KS_Organizacion_de_ventas__c = 'SI10';
        orgClie.KS_Peticion_de_borrado_para_cliente__c = true;
        orgClie.KS_Peticion_borrado_para_reg_maestro__c = true;
        orgClie.KS_Sector_Distribuidor__c = '10';
        orgClie.KS_Sociedad__c = 'SI10';

        orgClie.KS_ID_Organizacion_Cliente__c += acc.KS_Id_SAP__c + '-';
        orgClie.KS_ID_Organizacion_Cliente__c += '-' + orgClie.KS_Organizacion_de_ventas__c != null ? orgClie.KS_Organizacion_de_ventas__c : '';
        orgClie.KS_ID_Organizacion_Cliente__c += '-' + orgClie.KS_Canal_de_distribucion__c != null ? orgClie.KS_Canal_de_distribucion__c : '';
        orgClie.KS_ID_Organizacion_Cliente__c += '-' + orgClie.KS_Sector_Distribuidor__c != null ? orgClie.KS_Sector_Distribuidor__c : '';        
        orgClie.KS_ID_Organizacion_Cliente__c += '-' + orgClie.KS_Oficinas_de_ventas__c != null ? orgClie.KS_Oficinas_de_ventas__c : '';
        
        orgClie.KS_Area__c = ege.KS_Area__c;
        orgClie.KS_Delegacion__c = ege.KS_Delegacion__c;
        orgClie.KS_Zona__c = ege.KS_Zona__c;
        
        upsert orgClie;
        System.debug('-- JCAR ---------------------------------- - TEST createAccDistribuidorOrganizacion() KS_Organizacion_Cliente__c - ' + orgClie);
        return orgClie;
    }  
    
    public Pricebook2 createPricebook() {
        
        Pricebook2 pbS = new Pricebook2();
        pbS.ID = Test.getStandardPricebookId();

        /*insert pbS; */return pbS;
    }

    public KS_Usuario_MarcaArea__c createUserArea(KS_Organizacion_Cliente__c org) {
        
        ID userID = userInfo.getUserId();
        System.debug('-- JCAR ---------------------------------- - TEST createUserArea() userID - ' + userID);
        KS_Usuario_MarcaArea__c uma = new KS_Usuario_MarcaArea__c();
        uma.KS_Usuario__c = userID;
        uma.KS_Marca__c = org.KS_Organizacion_de_ventas__c;
        uma.KS_Area__c = org.KS_Area__c;
        
        upsert uma;
        System.debug('-- JCAR ---------------------------------- - TEST createUserArea() KS_Usuario_MarcaArea__c - ' + uma);
        return uma;
    }
    
    public Opportunity createOferta(Account acc, KS_Organizacion_Cliente__c orgAcc, KS_Obra__c obra, Pricebook2 pbS) {
        
        Opportunity oferta = new Opportunity();
        
        oferta.Name = 'OFERTATEST' + integer.ValueOf(Math.rint(Math.random() * 100000));
        oferta.KS_Distribuidor__c = acc.ID;
        oferta.KS_Organizacion_Cliente__c = orgAcc.ID;
        oferta.KS_Organizacion__c = orgAcc.KS_Organizacion_de_ventas__c;
        oferta.KS_Obra__c = obra.ID;
        oferta.StageName = 'Licitación';
        oferta.Probability = 10;
        oferta.Pricebook2Id = pbS.ID;
        oferta.CloseDate = Date.today();
        
        upsert oferta; return oferta;
    }
    
    public KS_Condicion_de_Obra__c createCondicionObra(Opportunity opp){

        KS_Condicion_de_Obra__c cobra = new KS_Condicion_de_Obra__c();
        cobra.KS_Oportunidad__c = opp.ID;
        cobra.KS_Aprobado__c = true;
            
        upsert cobra; return cobra;
    }      
    
    public Product2 creaProduct(String name) {
        
        Product2 prod = new Product2();
        
        prod.KS_Id_SAP__c = name;     
        prod.Name = prod.KS_Id_SAP__c;   
        prod.KS_Peso_bruto__c = 10;
        prod.KS_Peso_neto__c = 10;            
        prod.KS_Tipo_de_material__c = 'FERT';
        
        prod.KS_Nombre_Producto_ES__c = name+'_ES';
        prod.KS_Nombre_Producto_EN__c = name+'_EN';
        prod.KS_Nombre_Producto_FR__c = name+'_FR';
        prod.KS_Nombre_Producto_IT__c = name+'_IT';
        prod.KS_Nombre_Producto_DE__c = name+'_DE';
        prod.KS_Nombre_Producto_ZH__c = name+'_ZH';
        prod.KS_Nombre_Producto_PT__c = name+'_PT';
        prod.KS_Nombre_Producto_RU__c = name+'_RU';
        
        prod.KS_Descripcion_corta_ES__c = name+'_ES_DESC';
        prod.KS_Descripcion_corta_EN__c = name+'_EN_DESC';
        prod.KS_Descripcion_corta_FR__c = name+'_FR_DESC';
        prod.KS_Descripcion_corta_IT__c = name+'_IT_DESC';
        prod.KS_Descripcion_corta_DE__c = name+'_DE_DESC';
        prod.KS_Descripcion_corta_ZH__c = name+'_ZH_DESC';
        prod.KS_Descripcion_corta_PT__c = name+'_PT_DESC';
        prod.KS_Descripcion_corta_RU__c = name+'_RU_DESC';
        
        upsert prod; return prod;
    }
    
    public PricebookEntry getPricebookEntry(Product2 prd, Pricebook2 pbS) {
  
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.Pricebook2Id = pbS.ID;
        pbe.Product2Id = prd.ID;
        pbe.UseStandardPrice = false;
        pbe.IsActive = true;
        pbe.UnitPrice = 0;
        
        upsert pbe; return pbe;
    }
    
    public OpportunityLineItem createLineaOferta(Opportunity oferta, Product2 producto, PricebookEntry pbE) {
        
        OpportunityLineItem oppL = new OpportunityLineItem();
        
        oppL.OpportunityId = oferta.ID;
        oppL.PricebookEntryId = pbE.ID;
        oppL.TotalPrice = 1;
        oppL.Quantity = 1;
        oppL.KS_Cantidad__c = 1;
        oppL.KS_Ficha__c = 1;
        oppL.KS_Cantidad_Ficha__c = 1;
        
        upsert oppL; return oppL;
    }
    
    public KS_Oferta_Pendiente__c createOfertaPendiente(Opportunity oferta) {
        
        KS_Oferta_Pendiente__c ofP = new KS_Oferta_Pendiente__c();
        ofP.KS_Oferta__c = oferta.ID;
        
        upsert ofP; return ofP;
    }
    
    public KS_Obra_Ubicacion__c createObraUbicacion(KS_Obra__c obra, KS_Estructura_Geografica__c eg) {
        
        KS_Obra_Ubicacion__c ou = new KS_Obra_Ubicacion__c();
        ou.KS_Obra__c = obra.ID; ou.KS_Ubicacion__c = eg.ID;
        ou.KS_ID__c = obra.ID+'-'+ou.KS_Ubicacion__c;
        
        Schema.sObjectField idSAP = KS_Obra_Ubicacion__c.KS_ID__c.getDescribe().getSObjectField();
        Database.UpsertResult upsertResult = Database.upsert(ou, idSAP, false);          
        /*upsert ou;*/ return ou;
    }
    public Task createTaskforContact(Contact con)
    {
        Task t = new Task();
        t.WhoId = con.Id;
        t.Description = 'Descripción';
        insert t;
        return t;
    }

    public Event createEventforContact(Contact con)
    {
        Event e = new Event();
        e.WhoId = con.id;
        e.Description = 'Event';
        e.DurationInMinutes = 2;
        e.ActivityDateTime = System.now();
        insert e;
        return e;
    }
    public KS_Reporte__c createReporteforContact (Contact con)
    {
        KS_Reporte__c rep = new KS_Reporte__c();
        rep.KS_Asunto__c = 'Asunto';
        rep.KS_Contacto__c = con.id;
        insert rep;
        return rep;

    }
    public KS_Intervinientes__c createIntervinientesforContact (Contact con,KS_Obra__c obra, Account interv)
    {
        KS_Intervinientes__c inter = new KS_Intervinientes__c();
        inter.KS_Contacto__c = con.Id;
        inter.KS_Obra__c = obra.Id;
        inter.KS_Interviniente__c = interv.Id;
        insert inter;
        return inter;   
    }
    public KS_Organizacion_Producto__c createOrgProductoForProducto(Product2 prd, KS_Organizacion_Cliente__c org) {
        KS_Organizacion_Producto__c orgp = new KS_Organizacion_Producto__c();
        
        orgp.KS_Producto__c = prd.ID;
        orgp.KS_Superfamilia__c = 'S001';
        orgp.KS_Familia__c = 'S01';
        orgp.KS_Serie_Gama__c = 'S01';
        orgp.KS_Subserie__c = 'S01';
        orgp.KS_Canal_de_distribucion__c = org.KS_Canal_de_distribucion__c;
        orgp.KS_Organizacion_de_Ventas__c = org.KS_Organizacion_de_ventas__c;
        orgp.KS_Sector__c = org.KS_Sector_Distribuidor__c;
        
        orgp.KS_ID_Organizacion_Producto__c = prd.KS_Id_SAP__c;
        orgp.KS_ID_Organizacion_Producto__c += '-';
        orgp.KS_ID_Organizacion_Producto__c += orgp.KS_Organizacion_de_Ventas__c != null ? orgp.KS_Organizacion_de_Ventas__c : '';
        orgp.KS_ID_Organizacion_Producto__c += orgp.KS_Canal_de_distribucion__c != null ? orgp.KS_Canal_de_distribucion__c : '';
        orgp.KS_ID_Organizacion_Producto__c += orgp.KS_Sector__c != null ? orgp.KS_Sector__c : '';
        
        insert orgp;
        return orgp;
    }
    public KS_Condicion_Comercial__c createCondicionComercialForProducto(Product2 prd, KS_Organizacion_Cliente__c org) {
        KS_Condicion_Comercial__c ccp = new KS_Condicion_Comercial__c();
        
        ccp.KS_Material__c = prd.ID;
        ccp.KS_Importe__c = 1;
        ccp.KS_Canal__c = org.KS_Canal_de_distribucion__c;
        ccp.KS_Tarifa__c = org.KS_Lista_de_precios__c;
        ccp.KS_Condicion__c = 'PR00';
        
        insert ccp;
        return ccp;
    }
}