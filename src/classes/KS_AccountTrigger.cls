public without sharing class KS_AccountTrigger extends KS_TriggerController {
 
    public KS_AccountTrigger (Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
            List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);                 
    }

    public static Map<ID,Boolean> accInUse = new Map<ID,Boolean>();
    
    protected override void runAfterInsert() { executeAfterInsert(); }
    protected override void runAfterUpdate() { executeAfterUpdate(); }
    
    //public void executeAfterInsert() { KS_AccountTrigger.futureUpdate(mapNewItems.keySet()); }
    public void executeAfterInsert() { executeAfterUpsert(); executeNormalizacion(); }
    public void executeAfterUpdate() { executeAfterUpsert(); executeNormalizacion(); }
    
    public void executeAfterUpsert() {

        System.debug('----------------------------------------JCAR - isBatch? : ' + System.isBatch());
        if (System.isBatch()) {return;}
        
        System.debug('----------------------------------------JCAR - isFuture? : ' + System.isFuture());
        if (System.isFuture()) {return;}
        
        Map<String,ID> recordTypes = new Map<String,ID>();
        List<RecordType> rtLst = [SELECT ID,DeveloperName FROM RecordType];
        for (RecordType rt : rtLst) {
            recordTypes.put(rt.DeveloperName, rt.ID);
        }
        
        //Mapeos de configuraciones para ORG:Clientes
        List<KS_Conf_Organizacion_Cliente__mdt> orgConfLst = [SELECT Id, DeveloperName, KS_Organizacion_de_ventas__c, KS_Canal_SAP__c, KS_Sector__c, KS_Lista_de_precios__c FROM KS_Conf_Organizacion_Cliente__mdt];
        Map<ID,KS_Conf_Organizacion_Cliente__mdt> orgConfObjt = new  Map<ID,KS_Conf_Organizacion_Cliente__mdt>(orgConfLst);
        Map<string,string> orgConfMap = new Map<string,string>();
        Map<string,string> orgConfGeoMap = new Map<string,string>();
        for(KS_Conf_Organizacion_Cliente__mdt cnorgcli : orgConfLst)
        {
            orgConfMap.put(cnorgcli.DeveloperName,cnorgcli.Id);
            orgConfGeoMap.put(cnorgcli.DeveloperName+'__c',cnorgcli.KS_Organizacion_de_ventas__c);
        }
        
        // MAPEO CUENTAS LEAD
       
        List<Account> accounts = (List<Account>)lstNewItems;
        Map<ID,Account> leads = new Map<ID,Account>();
        Set<String> mapSAP2Vent = new Set<String>();
        
        for (Account acc : accounts) {
            if (KS_OrgCliente_Trigger.accInUse.containsKey(acc.ID)) {
                if (!Test.isRunningTest()) { System.debug('-- JCAR -- --------------- ALERTA DE RECURSIVIDAD EN CUENTA ' + acc.KS_Id_Salesforce__c + ' - ' + acc.ID + ' - ' + acc.Name); }
                //continue;
            }
            
            if (Test.isRunningTest() && KS_TEST_Debug.isRunning) { acc.Name.addError('TEST_Debug ERROR'); }
            
            if (acc.RecordTypeID == recordTypes.get('KS_Lead')) {
                
                if (!accInUse.containsKey(acc.ID)) { leads.put(acc.ID, acc); }
                accInUse.put(acc.ID, true);
                
                if(acc.KS_OC_Fluvia_Export__c == true)
                {
                    Schema.DescribeFieldResult F = Account.KS_OC_Fluvia_Export__c.getDescribe();
                    string fieldName = F.getLocalName();
                    mapSAP2Vent.add(orgConfGeoMap.get(fieldname));
                }
                if(acc.KS_OC_Fluvia_Nacional__c == true)
                {
                    Schema.DescribeFieldResult F = Account.KS_OC_Fluvia_Nacional__c.getDescribe();
                    string fieldName = F.getLocalName();
                    mapSAP2Vent.add(orgConfGeoMap.get(fieldname));
                }
                if(acc.KS_OC_Simon_Export__c == true)
                {
                    Schema.DescribeFieldResult F = Account.KS_OC_Simon_Export__c.getDescribe();
                    string fieldName = F.getLocalName();
                    mapSAP2Vent.add(orgConfGeoMap.get(fieldname));
                }
                if(acc.KS_OC_Simon_Nacional__c == true)
                {
                    Schema.DescribeFieldResult F = Account.KS_OC_Simon_Nacional__c.getDescribe();
                    string fieldName = F.getLocalName();
                    mapSAP2Vent.add(orgConfGeoMap.get(fieldname));
                }
            }
        }
        
        
        // MAPEOS Y PROCESOS PARA LEAD
        if (!leads.isEmpty()) {
                        
            Set<ID> isSI10 = new Set<ID>(); // SIMON
            Set<ID> isFL31 = new Set<ID>(); // FLUVIA
            Set<ID> isIE20 = new Set<ID>(); // LIGHTING

            List<KS_Organizacion_Cliente__c> newOrgClie = new List<KS_Organizacion_Cliente__c>();
            
            // MAPEO ORG.CLIENTE NUEVAS Y EXISTENTES
            List<ID> accID = new List<ID>(); 
            accID.addAll(leads.keySet());
            
            List<KS_Organizacion_Cliente__c> oCLst = [SELECT ID, KS_Cliente_Distribucion__c, 
                                                      KS_Organizacion_de_ventas__c, KS_Canal_de_distribucion__c, 
                                                      KS_Sector_Distribuidor__c FROM KS_Organizacion_Cliente__c
                                                      WHERE KS_Cliente_Distribucion__c IN :accID];
            //Mapeo Estructuras Geográficas
            List<KS_Estructura_Geografica__c> esGeogLst = [SELECT Id, KS_CPDesde__c, KS_CPHasta__c, KS_Delegacion__c, KS_Area__c, KS_Zona__c, KS_Organizacion_de_ventas__c, KS_CountryCode__c FROM KS_Estructura_Geografica__c WHERE KS_Organizacion_de_ventas__c in :mapSAP2Vent];
            
            for (Account acc : leads.values()) {
                
                Account accOLD = new Account();
                if (isUpdate) {
                    accOLD = (Account) mapOldItems.get(acc.ID);
                    //if (acc.KS_Organizaciones_de_cuentas__c != null && acc.KS_Organizacion_Ventas__c == accOLD.KS_Organizacion_Ventas__c) {
                    if (acc.KS_Organizaciones_de_cuentas__c != null && acc.KS_OC_Simon_Nacional__c == accOLD.KS_OC_Simon_Nacional__c && acc.KS_OC_Fluvia_Nacional__c == accOLD.KS_OC_Fluvia_Nacional__c && acc.KS_OC_Simon_Export__c == accOLD.KS_OC_Simon_Export__c && acc.KS_OC_Fluvia_Export__c == accOLD.KS_OC_Fluvia_Export__c) 
                    {
                        system.debug('Entro en el if');
                        continue;
                    }
                }
                
                
                
                /*
                String marcas = acc.KS_Organizacion_Ventas__c;
                String[] marcasA = acc.KS_Organizacion_Ventas__c.split(';');
                
                for (KS_Organizacion_Cliente__c oc : oCLst) {
                    String marca = oc.KS_Organizacion_de_ventas__c;
                    
                    // Detectamos que existe ya una org cliente para esa cuenta lead
                    if (oc.KS_Cliente_Distribucion__c == acc.ID) {
                        if (marca == 'SI10') { isSI10.add(acc.ID); }
                        if (marca == 'FL31') { isFL31.add(acc.ID); }
                        if (marca == 'IE20') { isIE20.add(acc.ID); }
                    }
                }*/
                
                //Miro las organizaciones de cliente a crear en base a los checkboxes. 
                List<string> organizaciones = new List<string>();
                system.debug('-- JCAR ------------------------------------------ organizaciones?' + 
                             ' - KS_OC_Simon_Nacional__c ' + acc.KS_OC_Simon_Nacional__c + 'isChanged? ' + (acc.KS_OC_Simon_Nacional__c != accOLD.KS_OC_Simon_Nacional__c) +
                             ' - KS_OC_Simon_Export__c ' + acc.KS_OC_Simon_Export__c + 'isChanged? ' + (acc.KS_OC_Simon_Export__c != accOLD.KS_OC_Simon_Export__c) +
                             ' - KS_OC_Fluvia_Nacional__c ' + acc.KS_OC_Fluvia_Nacional__c + 'isChanged? ' + (acc.KS_OC_Fluvia_Nacional__c != accOLD.KS_OC_Fluvia_Nacional__c) +
                             ' - KS_OC_Fluvia_Export__c ' + acc.KS_OC_Fluvia_Export__c + 'isChanged? ' + (acc.KS_OC_Fluvia_Export__c != accOLD.KS_OC_Fluvia_Export__c)
                            );
                if(acc.KS_OC_Fluvia_Export__c == true && acc.KS_OC_Fluvia_Export__c != accOLD.KS_OC_Fluvia_Export__c)
                {
                    Schema.DescribeFieldResult F = Account.KS_OC_Fluvia_Export__c.getDescribe();
                    string fieldName = F.getLocalName();
                    organizaciones.add(fieldname.removeEnd('__c'));
                }
                if(acc.KS_OC_Fluvia_Nacional__c == true && acc.KS_OC_Fluvia_Nacional__c != accOLD.KS_OC_Fluvia_Nacional__c)
                {
                    Schema.DescribeFieldResult F = Account.KS_OC_Fluvia_Nacional__c.getDescribe();
                    string fieldName = F.getLocalName();
                    organizaciones.add(fieldname.removeEnd('__c'));
                }
                if(acc.KS_OC_Simon_Export__c == true && acc.KS_OC_Simon_Export__c != accOLD.KS_OC_Simon_Export__c)
                {
                    Schema.DescribeFieldResult F = Account.KS_OC_Simon_Export__c.getDescribe();
                    string fieldName = F.getLocalName();
                    organizaciones.add(fieldname.removeEnd('__c'));
                }
                if(acc.KS_OC_Simon_Nacional__c == true && acc.KS_OC_Simon_Nacional__c != accOLD.KS_OC_Simon_Nacional__c)
                {
                    Schema.DescribeFieldResult F = Account.KS_OC_Simon_Nacional__c.getDescribe();
                    string fieldName = F.getLocalName();
                    organizaciones.add(fieldname.removeEnd('__c'));
                }
                system.debug('-- JCAR ------------------------------------------ ' + organizaciones.size() + ' organizaciones:' + organizaciones);
                
                // Miramos cuales crear nuevas
                for (String marca : organizaciones) {
                    
                    String countryS = acc.ShippingCountryCode != null ? acc.ShippingCountryCode : acc.BillingCountryCode;
            		Boolean validCountry = (countryS == 'ES' || countryS == 'PT' || countryS == 'AD');
            		String postalCodeS = acc.ShippingPostalCode != null ? acc.ShippingPostalCode : acc.BillingPostalCode;
                    
                    string OficinaVentas = EstructGeo(postalCodeS,countryS,validCountry,esGeogLst);
                    //system.debug('Otro Mapa: ' + orgConfObjt);
                    //system.debug('Mapa: ' + orgConfMap);
                    //system.debug('Marca: ' + marca);
                    KS_Organizacion_Cliente__c oc = new KS_Organizacion_Cliente__c();
                    KS_Conf_Organizacion_Cliente__mdt conf = orgConfObjt.get(orgConfMap.get(marca));
                    
                    String idacc = 
                        KS_OrgCliente_Util.buildID(
                            acc.KS_Id_Salesforce__c,
                            acc.KS_Id_Salesforce__c, 
                            acc.KS_Id_Salesforce__c, 
                            conf.KS_Organizacion_de_ventas__c, 
                            conf.KS_Canal_SAP__c, 
                            conf.KS_Sector__c, 
                            OficinaVentas);
                                        
                    oc.KS_Cliente_Distribucion__c = acc.ID;
                    oc.KS_Cliente_solicitante__c = acc.ID;
                    oc.KS_Cliente_Dest_Mercancias__c = acc.ID;
                    oc.KS_ID_Organizacion_Cliente__c = idacc;
                    oc.KS_Oficinas_de_ventas__c = OficinaVentas;

                    oc.KS_Organizacion_de_ventas__c = conf.KS_Organizacion_de_ventas__c;
                    oc.KS_Sociedad__c = conf.KS_Organizacion_de_ventas__c;
                    oc.KS_Canal_de_distribucion__c = conf.KS_Canal_SAP__c;
                    oc.KS_Sector_Distribuidor__c = conf.KS_Sector__c;
                    oc.KS_Lista_de_precios__c = conf.KS_Lista_de_precios__c;
                    oc.RecordTypeId = recordTypes.get('KS_OrgClie_NOSAP');

                    if (!accInUse.containsKey(acc.ID)) {
                        accInUse.put(acc.ID, true);
                    }
                    newOrgClie.add(oc);
                    
                    /*
                    if (marca == 'SI10' && !isSI10.contains(acc.ID)) 
                    { isSI10.add(acc.ID); newOrgClie.add(oc); }
                    if (marca == 'FL31' && !isFL31.contains(acc.ID)) 
                    { isFL31.add(acc.ID); newOrgClie.add(oc); }
                    if (marca == 'IE20' && !isIE20.contains(acc.ID)) 
                    { isIE20.add(acc.ID); newOrgClie.add(oc); }
					*/
                }
            }
            
            if (!Test.isRunningTest()) { System.debug('-- JCAR ---------------------------------- - UPSERT newOrgClie? ' + newOrgClie.size() + ' - ' + newOrgClie); }
            if (!newOrgClie.isEmpty()) { 
                
                Schema.DescribeFieldResult field = KS_Organizacion_Cliente__c.KS_ID_Organizacion_Cliente__c.getDescribe();
                Schema.sObjectField idSAP = field.getSObjectField();
                Database.UpsertResult[] upsertResult = Database.upsert(newOrgClie, idSAP, true);                  
                //upsert newOrgClie; 
            }
            
            if (!Test.isRunningTest()) {future_setResponsablesLead(leads.keySet());}
            
            
            
/*            oCLst = [SELECT ID, KS_Cliente_Distribucion__c, KS_Responsable__c,
                     KS_Organizacion_de_ventas__c, KS_Canal_de_distribucion__c, 
                     KS_Sector_Distribuidor__c FROM KS_Organizacion_Cliente__c
                     WHERE KS_Cliente_Distribucion__c IN :accID];*/
            
            if (!Test.isRunningTest()) { System.debug('-------------------------JCAR - userProfile - ' + getProfile()); }
            
        }
    }
    
    public void executeNormalizacion() {
        
        System.debug('-------------------------JCAR - accInUse - ' + accInUse);
        if (accInUse.isEmpty()) {
            
            if (!KS_Normalizacion_Utils.getConfigurationFlag('NormalizacionCuentaStatus')) {return;}
            
            accInUse = accInUse != null ? accInUse : new Map<ID,Boolean>();
            for (ID key : mapNewItems.keySet()) { accInUse.put(key,true); }
            KS_Normalizacion_Utils.executeNormalizacion(Account.class.getName(), lstNewItems);
        }
    }
    
    @future(callout=true)
    public static void future_setResponsablesLead(Set<ID> accounts) {
		
        if (Test.isRunningTest()) {return;}
        System.debug('-------------------------JCAR - future_setResponsablesLead');
        
        Map<ID, Account> accUPDATE = new Map<ID, Account>();
        List<ID> accID = new List<ID>(); accID.addAll(accounts);
        List<KS_Organizacion_Cliente__c> oCLst = [SELECT ID, KS_Cliente_Distribucion__c, KS_Cliente_solicitante__c, 
                                                  KS_Responsable__c, KS_Organizacion_de_ventas__c, KS_Canal_de_distribucion__c, 
                                                  KS_Sector_Distribuidor__c FROM KS_Organizacion_Cliente__c
                                                  WHERE KS_Responsable__c != NULL AND 
                                                  (KS_Cliente_Distribucion__c IN :accID OR
                                                   (KS_Cliente_solicitante__c IN :accID AND KS_Cliente_Distribucion__c = null)
                                                  )
                                                  ];
        
        System.debug('-- JCAR ---------------------------------- - SELECT oCLst? ' + oCLst.size() + ' - ' + oCLst);
        for (KS_Organizacion_Cliente__c oC : oCLst) {
            
            Account acc = new Account();
            acc.ID = oC.KS_Cliente_Distribucion__c;
            acc.ID = acc.ID != null ? acc.ID : oC.KS_Cliente_solicitante__c;            
            if (accUPDATE.containsKey(acc.ID)) { acc = accUPDATE.get(acc.ID); }
            
            String marca = oC.KS_Organizacion_de_ventas__c;
            if (marca == 'SI10' && acc.KS_Responsable_SI10__c != oC.KS_Responsable__c)
            { acc.KS_Responsable_SI10__c = oC.KS_Responsable__c; accUPDATE.put(acc.ID, acc); }
            if (marca == 'FL31' && acc.KS_Responsable_FL31__c != oC.KS_Responsable__c)
            { acc.KS_Responsable_FL31__c = oC.KS_Responsable__c; accUPDATE.put(acc.ID, acc); }
            if (marca == 'IE20' && acc.KS_Responsable_IE20__c != oC.KS_Responsable__c)
            { acc.KS_Responsable_IE20__c = oC.KS_Responsable__c; accUPDATE.put(acc.ID, acc); }            
        }
        
        System.debug('-- JCAR ---------------------------------- - UPDATE accUPDATE? ' + accUPDATE.size() + ' - ' + accUPDATE);
        if (!accUPDATE.isEmpty()) { update accUPDATE.values(); }
    }
    
    /*
    @future(callout=true)
    public static void futureUpdate(Set<ID> accounts) {
        System.debug('-- JCAR ---------------------------------- - isRunningTest? : ' + Test.isRunningTest());
        if (Test.isRunningTest()) {return;}
        System.debug('-- JCAR ---------------------------------- - futureUpdate.accounts? ' + accounts.size() + ' accounts - ' + accounts);
        List<ID> ids = new List<ID>(); ids.addAll(accounts);
    	TerritoryMangRule.fireTerritoryManagementViaSoap(ids);
    }
    
    public void executeBeforeUpdate() {
        
        Map<String,ID> recordTypes = new Map<String,ID>();
        List<RecordType> rtLst = [SELECT ID,DeveloperName FROM RecordType];
        for (RecordType rt : rtLst) {
            recordTypes.put(rt.DeveloperName, rt.ID);
        }        
        List<Account> accounts = (List<Account>)lstNewItems;
        List<Account> cuentas = new List<Account>();
        
        Set<ID> cuentasID = new Set<ID>();
        Map<ID,List<String>> marcasCuenta = new Map<ID,List<String>>();
        Set<String> marcas = new Set<String>();
        Map<ID, String> areaCuenta = new Map<ID, String>();
        
        System.debug('-- JCAR ---------------------------------- - executeAfterInsert.accounts? ' + accounts.size() + ' accounts - ' + accounts);
        //KS_Lead
        for (Account acc : accounts) {
            if ( acc.RecordTypeID == recordTypes.get('KS_Lead') && acc.KS_Organizaciones_de_cuentas__c != null && acc.KS_Organizaciones_de_cuentas__c != '') {
                cuentas.add(acc);
                List<String> mrcs = new List<String>();
                for (String s : acc.KS_Organizaciones_de_cuentas__c.split(';')) {
                    if (s.trim() != '') {
                        marcas.add( s.split('-')[0] );
                        areaCuenta.put(acc.ID, s.split('-')[3]);
                    }
                }
                marcasCuenta.put(acc.ID, mrcs);
            }
        }
        if (!cuentas.isEmpty() && !marcas.isEmpty() && !marcasCuenta.isEmpty()) {
        	KS_Aprobaciones_Controller.setAprobacionesCuenta(cuentas, marcas, marcasCuenta, areaCuenta);
            //update cuentas; // En un before la actualización ocurre por si sola
        }
    }*/  
    
    private String getProfile() {
        List<Profile> profLst = [SELECT ID,Name FROM Profile];
        for (Profile prof : profLst) {
            if (prof.ID == userInfo.getProfileId()) { return prof.Name; }
        }
        return '';
    }
    public string EstructGeo(string postalCodeS,string countryS,Boolean validCountry,List<KS_Estructura_Geografica__c> esGeogLst)
    {
        string retorno = '';
        Boolean next = false; Integer i = 0;
        while (!next && i<esGeogLst.size() && validCountry && postalCodeS != null) {
            
            KS_Estructura_Geografica__c eg = esGeogLst.get(i);
            String dsd = eg.KS_CPDesde__c;
            String hst = eg.KS_CPHasta__c;
            
            if (eg.KS_CountryCode__c == countryS && (countryS == 'AD' || countryS == 'ES') ) { // ANDORRA || ESPAÑA

                next = postalCodeS.startsWithIgnoreCase(dsd.substring(0,2));
                
            } else if (countryS == 'PT' && eg.KS_CountryCode__c == countryS) { // PORTUGAL
                
                if (dsd.split('-')[0].isNumeric() && hst.split('-')[0].isNumeric() && postalCodeS.split('-')[0].split(' ')[0].isNumeric()) {
                    Integer z = Integer.valueOf(postalCodeS.split('-')[0].split(' ')[0]);
                    Integer x = Integer.valueOf(dsd.split('-')[0]);
                    Integer y = Integer.valueOf(hst.split('-')[0]);
                    next = (z >= x && z <= y);
                }
                
            } else { // Internacional, se sigue otra lógica
                
                next = eg.KS_CountryCode__c == countryS && countryS == eg.KS_Delegacion__c && eg.KS_Area__c == 'INTE';
            }
            
            if (next) { // se ha encontrado un CP
                //mapPC2EG.put(postalCodeS, eg);
                retorno = eg.KS_Area__c;
                
            }
            i++;
        }
        return retorno;
    }
}