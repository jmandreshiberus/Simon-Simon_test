public without sharing class KS_OrgCliente_Trigger extends KS_TriggerController {

    public KS_OrgCliente_Trigger (Boolean isAfter, Boolean isBefore, Boolean isDelete, Boolean isInsert, Boolean isUndelete, Boolean isUpdate,
        List<sObject> lstNewItems, Map<Id, sObject> mapNewItems, List<sObject> lstOldItems, Map<Id, sObject> mapOldItems)
    {
        super(isAfter, isBefore, isDelete, isInsert, isUndelete, isUpdate, lstNewItems, mapNewItems, lstOldItems, mapOldItems);
    }
    
    public static Boolean blocked() { System.debug('-- TRIGGER BLOCKED! --'); return Test.isRunningTest() && KS_Trigger_Test.blockTrigger; }
    
    public static Map<ID,Boolean> accInUse = new Map<ID,Boolean>();
    public static Map<ID,sObject> orgInUse = new Map<ID,sObject>();
    
    public Map<String,ID> recordTypes;
    protected override void runBeforeInsert(){ if(blocked()){return;} executeBeforeInsert(); }
    protected override void runBeforeUpdate(){ if(blocked()){return;} executeBeforeUpdate(); } 
    public void executeBeforeInsert() { executeBeforeUpsert(); }
    public void executeBeforeUpdate() { executeBeforeUpsert(); }       
    public void executeBeforeUpsert() {
        
        if (orgInUse != null && !orgInUse.isEmpty()) { return; }
        if (mapNewItems != null && !mapNewItems.isEmpty()) { orgInUse.putAll(mapNewItems); }
        
        System.debug('----------------------------------------JCAR - isBatch? : ' + System.isBatch());
        if (System.isBatch()) {return;}        
        
        recordTypes = new Map<String,ID>();
        List<RecordType> rtLst = [SELECT ID,DeveloperName FROM RecordType];
        for (RecordType rt : rtLst) {
            recordTypes.put(rt.DeveloperName, rt.ID);
        }
        Map<String,ID> terrType = new Map<String,ID>();
        List<Territory2Type> terrLst = [SELECT ID, DeveloperName FROM Territory2Type];
        for (Territory2Type tp : terrLst) {
            terrType.put(tp.DeveloperName, tp.ID);
        }        
        
        List<KS_Organizacion_Cliente__c> orgclLST = (List<KS_Organizacion_Cliente__c>)lstNewItems;
        
        Map<String, KS_Organizacion_Cliente__c> mapSAP2Orga = new Map<String, KS_Organizacion_Cliente__c>();
        Map<String, Id> mapSAP2Clie = new Map<String, Id>();
        Map<String, String> mapSAP2Vent = new Map<String, String>();
        
        Map<Id, String> mapPostalCode = new Map<Id, String>();
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        Map<String, KS_Estructura_Geografica__c> mapPC2EG = new Map<String, KS_Estructura_Geografica__c>();
        
        // Asignación ORG-ventas
        Map<ID, Set<String>> orgVentasCliente = new Map<ID, Set<String>>();
        
        for (KS_Organizacion_Cliente__c orgcl : orgclLST) {
            
            ID accID = getAccountOrgCliente(orgcl);
            
            List<String> orgaWVentas = new List<String>();
            if (orgcl.KS_Organizacion_de_ventas__c != null && accID != null) {
                               
                mapSAP2Orga.put(orgcl.KS_ID_Organizacion_Cliente__c, orgcl);
                mapSAP2Clie.put(orgcl.KS_ID_Organizacion_Cliente__c, accID);
                mapSAP2Vent.put(orgcl.KS_ID_Organizacion_Cliente__c, orgcl.KS_Organizacion_de_ventas__c);
                //mapPostalCode.put(orgcl., null);
                
                // Asignación ORG-ventas
                Set<String> orgVentas = new Set<String>();
                if (orgVentasCliente.containsKey(accID)) {
                    orgVentas = orgVentasCliente.get(accID);
                }
                orgVentas.add(orgcl.KS_Organizacion_de_ventas__c);
                orgVentasCliente.put(accID, orgVentas);
            }
            
            if (orgcl.KS_Lista_de_precios__c == null) { // tarifa is NULL
                
            }
        }
        
        if (!Test.isRunningTest()) { 
            System.debug('----------------------------------------JCAR - ' + mapSAP2Orga.size() + ' mapSAP2Orga : ' + mapSAP2Orga);
            System.debug('----------------------------------------JCAR - ' + mapSAP2Clie.size() + ' mapSAP2Clie : ' + mapSAP2Clie);
            System.debug('----------------------------------------JCAR - ' + mapSAP2Vent.size() + ' mapSAP2Vent : ' + mapSAP2Vent);
        }
    
        List<Account> accLst = [SELECT ID,KS_Id_SAP__c,BillingPostalCode,BillingCountryCode,ShippingPostalCode,ShippingCountryCode,
                                KS_Organizacion_Ventas__c,KS_Organizaciones_de_cuentas__c
                                FROM Account WHERE ID in :mapSAP2Clie.values() 
                                /*AND (RecordTypeId = :recordTypes.get('KS_Distribuidores_SAP') OR RecordTypeId = :recordTypes.get('KS_Lead'))*/];
        for (Account acc : accLst) {
            //mapPostalCode.put(acc.ID, acc.BillingPostalCode);
            mapAccounts.put(acc.ID, acc);
        }
        if (!Test.isRunningTest()) { System.debug('----------------------------------------JCAR - ' + mapAccounts.size() + ' mapAccounts : ' + mapAccounts); }
        
        List<KS_Estructura_Geografica__c> esGeogLst = 
            [SELECT Id, KS_CPDesde__c, KS_CPHasta__c, KS_Delegacion__c, KS_Area__c, KS_Zona__c, KS_Organizacion_de_ventas__c, KS_CountryCode__c 
             FROM KS_Estructura_Geografica__c WHERE KS_Organizacion_de_ventas__c in :mapSAP2Vent.values()];
        if (!Test.isRunningTest()) { System.debug('----------------------------------------JCAR - ' + esGeogLst.size() + ' KS_Estructura_Geografica__c : ' + esGeogLst); }
        
        //List<Account> accUPDATE = new List<Account>();
        Map<Id, Account> accUPDATE = new Map<Id, Account>();
        for (Account acc : mapAccounts.values()) {
            
            String countryS = acc.ShippingCountryCode != null ? acc.ShippingCountryCode : acc.BillingCountryCode;
            
            Boolean validCountry = (countryS == 'ES' || countryS == 'PT' || countryS == 'AD');
            
            String postalCodeS = acc.ShippingPostalCode != null ? acc.ShippingPostalCode : acc.BillingPostalCode;
            
            Integer i = 0;
            Map<String,Boolean> nextM = new Map<String,Boolean>();
            
            if (!Test.isRunningTest()) { 
                System.debug('----------------------------------------JCAR - postalCodeS : ' + postalCodeS);
                System.debug('----------------------------------------JCAR - validCountry : ' + countryS + ' - ' + validCountry);
            }
            
            while (i<esGeogLst.size() && validCountry && postalCodeS != null) {
                
                KS_Estructura_Geografica__c eg = esGeogLst.get(i);
                String dsd = eg.KS_CPDesde__c;
                String hst = eg.KS_CPHasta__c;
                
                Boolean goodPS = false;
                if (eg.KS_CountryCode__c == countryS && (countryS == 'AD' || countryS == 'ES') && dsd != null ) { // ANDORRA || ESPAÑA
                
                    if (postalCodeS.length() == 4) { 
                        postalCodeS = '0'+postalCodeS;
                        if(acc.ShippingPostalCode != null) {
                            acc.ShippingPostalCode = postalCodeS;
                        } else {
                            acc.BillingPostalCode = postalCodeS;
                        }
                    }
                    goodPS = postalCodeS.startsWithIgnoreCase(dsd.substring(0,2));
                
                } else if (countryS == 'PT' && eg.KS_CountryCode__c == countryS && dsd != null  && hst != null ) { // PORTUGAL
                    
                    if (dsd.split('-')[0].isNumeric() && hst.split('-')[0].isNumeric() && postalCodeS.split('-')[0].split(' ')[0].isNumeric()) {
                        Integer z = Integer.valueOf(postalCodeS.split('-')[0].split(' ')[0]);
                        Integer x = Integer.valueOf(dsd.split('-')[0]);
                        Integer y = Integer.valueOf(hst.split('-')[0]);
                        goodPS = (z >= x && z <= y);
                    }
                    
                } else { // Internacional, se sigue otra lógica
                    
                    goodPS = eg.KS_CountryCode__c == countryS && countryS == eg.KS_Delegacion__c && eg.KS_Area__c == 'INTE';
                }
                
                if (goodPS) { // se ha encontrado un CP
                    mapPC2EG.put(postalCodeS+'_'+eg.KS_Organizacion_de_ventas__c, eg);
                }
                i++;
            }
            
            if (!Test.isRunningTest()) { System.debug('----------------------------------------JCAR - mapPC2EG : ' + mapPC2EG); }
        }
        
        List<String> areaGLst = new List<String>();
        List<String> orgVnLST = new List<String>();
        List<String> canalLST = new List<String>();
        List<String> sectrLST = new List<String>();
        Map<String, KS_Organizacion_Cliente__c> marcareaOrgCliente = new Map<String, KS_Organizacion_Cliente__c>();
        Set<String> validMarca = KS_OrgCliente_Util.validMarcas();
        
        Set<ID> accounts = new Set<ID>();
        List<String> marcareas = new List<String>();
        for (String orgclK : mapSAP2Orga.keySet()) {
            
            KS_Organizacion_Cliente__c orgcl = (KS_Organizacion_Cliente__c)mapSAP2Orga.get(orgclK);
            ID accID = getAccountOrgCliente(orgcl);
            //KS_Estructura_Geografica__c eg = mapPC2EG.get(mapPostalCode.get(accID));
            if (!Test.isRunningTest()) { System.debug('----------------------------------------JCAR - mapAccounts.get(accID) : ' + mapAccounts.get(accID)); }
            if (mapAccounts.get(accID) != null) {
                
                Account acc = mapAccounts.get(accID);
                if (accUPDATE.containsKey(accID)) { acc = accUPDATE.get(accID);}
                
                String countryS = acc.ShippingCountryCode != null ? acc.ShippingCountryCode : acc.BillingCountryCode;
                Boolean validCountry = (countryS == 'ES' || countryS == 'PT' || countryS == 'AD');                 
                if (orgcl.KS_Lista_de_precios__c == null && validCountry) { // tarifa is NULL
                    
                    if (countryS == 'ES' || countryS == 'AD') {
                        orgcl.KS_Lista_de_precios__c = '00';
                    } else if (countryS == 'PT') {
                        orgcl.KS_Lista_de_precios__c = '10';
                    }
                }
                
                String billingPostalCode = acc.ShippingPostalCode != null ? acc.ShippingPostalCode : acc.BillingPostalCode;
                KS_Estructura_Geografica__c eg = mapPC2EG.get(billingPostalCode+'_'+orgcl.KS_Organizacion_de_ventas__c);
                if (eg != null) { 
                    if (!Test.isRunningTest()) { System.debug('----------------------------------------JCAR - KS_Estructura_Geografica__c : ' + eg); }
                    orgcl.KS_Area__c = eg.KS_Area__c;
                    orgcl.KS_Delegacion__c = eg.KS_Delegacion__c;
                    orgcl.KS_Zona__c = eg.KS_Zona__c;
                    if (!Test.isRunningTest()) { System.debug('----------------------------------------JCAR - orgcl+eg : ' + orgcl); }
                    
                    /*String marcarea = eg.KS_Organizacion_de_ventas__c+'-'+orgcl.KS_Canal_de_distribucion__c+'-'+orgcl.KS_Sector_Distribuidor__c+'-'
                        +eg.KS_Area__c+'-'+eg.KS_Delegacion__c+'-'+eg.KS_Zona__c;
                    acc.KS_Organizaciones_de_cuentas__c = acc.KS_Organizaciones_de_cuentas__c != null ? acc.KS_Organizaciones_de_cuentas__c : '';
                    System.debug('----------------------------------------JCAR - marcarea : ' + marcarea);
                    System.debug('----------------------------------------JCAR - acc.KS_Organizaciones_de_cuentas__c : ' + acc.KS_Organizaciones_de_cuentas__c);
                    if (!acc.KS_Organizaciones_de_cuentas__c.containsIgnoreCase(marcarea)) {
                        acc.KS_Organizaciones_de_cuentas__c += marcarea+';';
                        accUPDATE.put(acc.ID, acc);
                        accounts.add(acc.ID);
                    }*/
                    
                    acc.KS_Organizaciones_de_cuentas__c =
                        KS_OrgCliente_Util.buildMarcaAreaCuenta(
                            acc.KS_Organizaciones_de_cuentas__c,
                            orgcl.KS_Organizacion_de_ventas__c,
                            orgcl.KS_Canal_de_distribucion__c,
                            orgcl.KS_Sector_Distribuidor__c,
                            eg.KS_Area__c, eg.KS_Delegacion__c, eg.KS_Zona__c,
                            validMarca);
                    if (!Test.isRunningTest()) { System.debug('----------------------------------------JCAR - acc.KS_Organizaciones_de_cuentas__c : ' + acc.KS_Organizaciones_de_cuentas__c); }
                    
                    String maK = eg.KS_Organizacion_de_ventas__c+'-'+orgcl.KS_Canal_de_distribucion__c+'-'+orgcl.KS_Sector_Distribuidor__c+'-'+eg.KS_Area__c;
                    areaGLst.add(eg.KS_Area__c);
                    orgVnLST.add(eg.KS_Organizacion_de_ventas__c);
                    canalLST.add(orgcl.KS_Canal_de_distribucion__c);
                    sectrLST.add(orgcl.KS_Sector_Distribuidor__c);
                    marcareaOrgCliente.put(maK, orgcl);
                }
            }
        }
        
        System.debug('-- JCAR ---------------------------------- executeBeforeUpsert JAR - ' + marcareaOrgCliente.size() + ' marcareaOrgCliente - ' + marcareaOrgCliente);
        if (!Test.isRunningTest()) { 
            System.debug('-- JCAR ---------------------------------- executeBeforeUpsert JAR - ' + orgVnLST.size() + ' orgVnLST - ' + orgVnLST);
            System.debug('-- JCAR ---------------------------------- executeBeforeUpsert JAR - ' + canalLST.size() + ' canalLST - ' + canalLST);
            System.debug('-- JCAR ---------------------------------- executeBeforeUpsert JAR - ' + sectrLST.size() + ' sectrLST - ' + sectrLST);
            System.debug('-- JCAR ---------------------------------- executeBeforeUpsert JAR - ' + areaGLst.size() + ' areaGLst - ' + areaGLst);
            System.debug('-- JCAR ---------------------------------- executeBeforeUpsert JAR - ' + terrType.size() + ' terrType - ' + terrType);
        }
    
        List<UserTerritory2Association> terrOferta = 
            [SELECT Id, UserId, Territory2Id, RoleInTerritory2,
             Territory2.KS_Organizacion_Ventas__c,
             Territory2.KS_Canal__c,
             Territory2.KS_Sector_Distribuidor__c,
             Territory2.KS_Area__c
             FROM UserTerritory2Association 
             WHERE RoleInTerritory2 = 'JAR'
             AND Territory2.KS_Organizacion_Ventas__c IN :orgVnLST
             AND Territory2.KS_Canal__c IN :canalLST
             AND Territory2.KS_Sector_Distribuidor__c IN :sectrLST
             AND Territory2.KS_Area__c IN :areaGLst
             AND Territory2.Territory2TypeId = :terrType.get('KS_Area')
            ];
        if (!Test.isRunningTest()) { System.debug('-- JCAR ---------------------------------- executeBeforeUpsert JAR - ' + terrOferta.size() + ' terrOferta - ' + terrOferta); }
        for (UserTerritory2Association uta : terrOferta) {
            
            String maK = uta.Territory2.KS_Organizacion_Ventas__c+'-'
                +uta.Territory2.KS_Canal__c+'-'
                +uta.Territory2.KS_Sector_Distribuidor__c+'-'
                +uta.Territory2.KS_Area__c;
            
            if (!Test.isRunningTest()) { System.debug('-- JCAR ---------------------------------- executeBeforeUpsert JAR - ' + maK + ' - ' + uta.UserId); }
            
            if (marcareaOrgCliente.containsKey(maK) && uta.UserId != null) {
                
                KS_Organizacion_Cliente__c orgcl = marcareaOrgCliente.get(maK);
                orgcl.KS_Responsable__c = uta.UserId;
                
                if (!Test.isRunningTest()) { System.debug('-- JCAR ---------------------------------- executeBeforeUpsert JAR - ' + orgcl); }
                
                if (orgcl.KS_Cliente_Distribucion__c != null) {
                    
                    Account acc = new Account(); acc.ID = orgcl.KS_Cliente_Distribucion__c;
                    if (accUPDATE.containsKey(acc.ID)) { acc = accUPDATE.get(acc.ID); }
                    /*
                    String marca = orgcl.KS_Organizacion_de_ventas__c;
                    if (marca == 'SI10')
                    { acc.KS_Responsable_SI10__c = uta.UserId; accUPDATE.put(acc.ID, acc); }
                    if (marca == 'FL31')
                    { acc.KS_Responsable_FL31__c = uta.UserId; accUPDATE.put(acc.ID, acc); }
                    if (marca == 'IE20')
                    { acc.KS_Responsable_IE20__c = uta.UserId; accUPDATE.put(acc.ID, acc); }
					*/
                    //if (accInUse == null || (accInUse != null && accInUse.isEmpty()) || (accInUse != null && accInUse.containsKey(acc.ID)) ) {
                        if (accUPDATE == null)  {accUPDATE = new Map<ID,Account>(); } accUPDATE.put(acc.ID, acc);
                        //if (accInUse == null)  {accInUse = new Map<ID,Boolean>(); } accInUse.put(acc.ID, true);
                    //} 
                }
            }
        }
        
        System.debug('----------------------------------------JCAR - isRunningTest? : ' + Test.isRunningTest());
        System.debug('----------------------------------------JCAR - isBatch? : ' + System.isBatch());
        
        if (accUPDATE.isEmpty()) {accUPDATE.putAll(mapAccounts);}
        else { for (ID accID : mapAccounts.keySet()) { if (!accUPDATE.containsKey(accID)) { accUPDATE.put(accID, mapAccounts.get(accID)); } } }
        
        System.debug('----------------------------------------JCAR - executeBeforeUpsert accUPDATE - ' + accUPDATE.size() + ' - ' + accUPDATE);
        if (accUPDATE.size()>0 && !System.isBatch()) {
            update accUPDATE.values();
            if ( !System.isFuture() ) { futureUpdate(accUPDATE.keySet()); }
            
        }
    }
    
    @future(callout=true)
    public static void futureUpdate(Set<ID> accounts) {
        if (Test.isRunningTest()) {return;}
        //for (ID accID : accounts) { if (accInUse.containsKey(accID)) { return; } }
        futureUpdateCall(accounts);
        //if (accInUse == null) { accInUse = new Map<ID,Boolean>(); }
        //for (ID accID : accounts) { accInUse.put(accID, true); }
    }
    
    public static void futureUpdateCall(Set<ID> accounts) {
        futureUpdateCallTerritory(accounts);
        futureUpdateCallOrgCuenta(accounts);
    }
    public static void futureUpdateCallTerritory(Set<ID> accounts) {
        System.debug('-- JCAR ---------------------------------- - futureUpdateCallTerritory.accounts? ' + accounts.size() + ' accounts - ' + accounts);
        List<ID> ids = new List<ID>(); ids.addAll(accounts);
        TerritoryMangRule.fireTerritoryManagementViaSoap(ids);
    }
    public static void futureUpdateCallOrgCuenta(Set<ID> accounts) {
        
        Set<String> validMarca = KS_OrgCliente_Util.validMarcas();
        Map<ID, Account> accUpdate = new Map<ID, Account>();
        Map<ID, Integer> accSI10 = new Map<ID, Integer>();
        Map<ID, Integer> accFL31 = new Map<ID, Integer>();
        
        for (KS_Organizacion_Cliente__c oc : 
             [SELECT ID, KS_Organizacion_de_ventas__c, KS_Canal_de_distribucion__c, KS_Sector_Distribuidor__c, KS_Area__c, KS_Delegacion__c, KS_Zona__c,
              KS_Cliente_Distribucion__r.KS_Organizaciones_de_cuentas__c FROM KS_Organizacion_Cliente__c WHERE KS_Cliente_Distribucion__c in :accounts]) {
                  
                  Account acc = new Account(); acc.ID = oc.KS_Cliente_Distribucion__c;
                  if (accUpdate.containsKey(acc.ID)) { acc = accUpdate.get(acc.ID); }
                  else { acc.KS_Organizaciones_de_cuentas__c = oc.KS_Cliente_Distribucion__r.KS_Organizaciones_de_cuentas__c; }
                  
                  Integer countSI10 = 0; if (accSI10.containsKey(acc.ID)) { countSI10 = accSI10.get(acc.ID); }
                  Integer countFL31 = 0; if (accFL31.containsKey(acc.ID)) { countFL31 = accFL31.get(acc.ID); }
                  if (oc.KS_Organizacion_de_ventas__c == 'SI10') { countSI10++; }
                  if (oc.KS_Organizacion_de_ventas__c == 'FL31') { countFL31++; }
                  acc.KS_CountOC__c = countSI10 + countFL31;
                  acc.KS_CountOC_SI10__c = countSI10;
                  acc.KS_CountOC_FL31__c = countFL31;
                  accSI10.put(acc.ID, countSI10);
                  accFL31.put(acc.ID, countFL31);
                  
                  acc.KS_Organizaciones_de_cuentas__c =
                      KS_OrgCliente_Util.buildMarcaAreaCuenta(
                          acc.KS_Organizaciones_de_cuentas__c,
                          oc.KS_Organizacion_de_ventas__c,
                          oc.KS_Canal_de_distribucion__c,
                          oc.KS_Sector_Distribuidor__c,
                          oc.KS_Area__c, 
                          oc.KS_Delegacion__c, 
                          oc.KS_Zona__c,
                          validMarca);
                  accUpdate.put(acc.ID, acc);
              }
        System.debug('-- JCAR ---------------------------------- - futureUpdateCallOrgCuenta.accounts? ' + accUpdate.size() + ' accounts - ' + accUpdate.values());
        //accInUse = new Map<ID,Boolean>(); for (ID accID : accUpdate.keySet()) { accInUse.put(accID, true); }
        update accUpdate.values();
    }
    
    public ID getAccountOrgCliente(KS_Organizacion_Cliente__c orgcl) {
        
        ID accID = null;
        if (orgcl.KS_Cliente_Dest_Mercancias__c != null) {
            accID = orgcl.KS_Cliente_Dest_Mercancias__c;
        }
        if (orgcl.KS_Cliente_solicitante__c != null) {
            accID = orgcl.KS_Cliente_solicitante__c;
        }
        if (orgcl.KS_Cliente_Distribucion__c != null) {
            accID = orgcl.KS_Cliente_Distribucion__c;
        }
        return accID;
    }
    
    protected override void runAfterInsert(){ executeAfterInsert(); }
    protected override void runAfterUpdate(){ executeAfterUpdate(); } 
    public void executeAfterInsert() { executeAfterUpsert(); }
    public void executeAfterUpdate() { executeAfterUpsert(); }       
    public void executeAfterUpsert() {      
        
        Map<ID, Account> accUpdate = new Map<ID, Account>();
        List<KS_Organizacion_Cliente__c> orgclLST = (List<KS_Organizacion_Cliente__c>)lstNewItems;
        //system.debug('JCAR - executeAfterUpsert --------------------- : ' + orgclLST);
        for (KS_Organizacion_Cliente__c orgcl : orgclLST) {
            
            String accID = orgcl.KS_Cliente_Distribucion__c;
            accID = accID != null ? accID : orgcl.KS_Cliente_Dest_Mercancias__c;
            accID = accID != null ? accID : orgcl.KS_Cliente_solicitante__c;
            if (orgcl.KS_Responsable__c != null && accID != null) {
                
                Account acc = new Account(); acc.ID = accID;
                if (accUpdate.containsKey(accID)) { acc = accUpdate.get(accID); }
                
                String marca = orgcl.KS_Organizacion_de_ventas__c;
                if (marca == 'SI10')
                { acc.KS_Responsable_SI10__c = orgcl.KS_Responsable__c; accUPDATE.put(acc.ID, acc); }
                if (marca == 'FL31')
                { acc.KS_Responsable_FL31__c = orgcl.KS_Responsable__c; accUPDATE.put(acc.ID, acc); }
                if (marca == 'IE20')
                { acc.KS_Responsable_IE20__c = orgcl.KS_Responsable__c; accUPDATE.put(acc.ID, acc); }
            }
        }
        
        if (accUpdate.size()>0) {
            system.debug('accUpdate: ' + accUpdate);
            update accUpdate.values();
        }
    }
}