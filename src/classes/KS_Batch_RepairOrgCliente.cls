global without sharing class KS_Batch_RepairOrgCliente implements Database.Batchable<sObject>{
    
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    
    global KS_Batch_RepairOrgCliente(String q, String e, String f, String v){
        
        System.debug(Logginglevel.ERROR,'-------------------------JCAR - QUERY - ' + q);
        Query=q; Entity=e; Field=f;Value=v;
    }
    
    global KS_Batch_RepairOrgCliente(String q){
        
        System.debug(Logginglevel.ERROR,'-------------------------JCAR - QUERY - ' + q);
        Query=q;
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug(Logginglevel.ERROR,'-------------------------JCAR - QUERY - ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        logic((List<Account>)scope);
    }
    global static List<KS_Organizacion_Cliente__c> logic(List<Account> scopeLst){
        
        /*
        A la hora de fusionar Marcas Comerciales, cual es la lógica:
        SCORING: Siempre gana el superior (mayor cantidad de estrellas o alfabéticamente)
        RECURRENCIA: Siempre gana la mayor
        OWNER: Siempre gana el que no sea Admin
        */
        
        // 2018-01-16: Depuración 
        List<KS_Debug__c> debugList = new List<KS_Debug__c>();
        ID debugRT = [SELECT ID FROM RecordType WHERE DeveloperName = 'KS_MERGE_MARCA'].ID;
        Map<Id,String> ownerUserNameMap = new Map<Id,String>();
        // 2018-01-16: Depuración 

        System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - scopeLst - ' + scopeLst.size() + ' -- ' + scopeLst);
        
        Set<String> validMarca = KS_OrgCliente_Util.validMarcas();
        System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - validMarca - ' + validMarca.size() + ' -- ' + validMarca);
        
        Boolean isTest = Test.isRunningTest();
        Map<ID, Account> accUpdate = new Map<ID, Account>();
        
        List<String> userAlias = new List<String>(); 
        userAlias.add('asimo'); userAlias.add('wuser');
        Set<ID> userID = new Set<ID>();
        if (isTest) { userID.add(UserInfo.getUserId()); }
        else { for (User u : [SELECT ID, Alias FROM User WHERE Alias IN :userAlias]) { userID.add(u.ID); } }
        
        Map<ID, Map<String, List<KS_Organizacion_Cliente__c>>> orgMap = 
            new Map<ID, Map<String, List<KS_Organizacion_Cliente__c>>>();
        Map<ID,Account> accMap = new Map<ID,Account>();
        
        Set<ID> idSet = new Set<ID>(); List<ID> idLst = new List<ID>();
        for (Account acc : scopeLst) { acc.KS_Organizaciones_de_cuentas__c = null; accMap.put(acc.ID, acc); }
        idSet = accMap.keySet(); idLst.addAll(idSet);
        
        System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - Account idLst - ' + idLst.size() + ' -- ' + idLst);
        
        Map<String, String> orgID2ID = new Map<String, String>();

        Map<Id, KS_Organizacion_Cliente__c> orgClieQRY = new Map<Id, KS_Organizacion_Cliente__c>(
            [SELECT ID, Name, KS_ID_Organizacion_Cliente__c, KS_Recurrencia__c, OwnerID, Owner.Username, CreatedDate, 
             KS_Cliente_Distribucion__c, KS_Cliente_solicitante__c, KS_Cliente_Dest_Mercancias__c,
             KS_Id_Salesforce_Distribuidor__c, KS_Id_Salesforce_Solicitante__c, KS_Id_Salesforce_Destinatario__c,
             KS_Organizacion_de_ventas__c, KS_Oficinas_de_ventas__c, KS_Canal_de_distribucion__c, KS_Sector_Distribuidor__c,
             KS_Scoring_Actividad__c, KS_Scoring_Negocio__c, KS_Scoring_IF__c,
             KS_Area__c, KS_Delegacion__c, KS_Zona__c
             FROM KS_Organizacion_Cliente__c 
             WHERE KS_Cliente_Distribucion__c IN :idLst OR KS_Cliente_solicitante__c IN :idLst]);
        System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - orgClieQRY - ' + orgClieQRY.size() + ' -- ' + orgClieQRY);
        
        for (KS_Organizacion_Cliente__c org : orgClieQRY.values()) 
        {

            String idDistribuidor = org.KS_Id_Salesforce_Distribuidor__c;
            String idDestinatario = org.KS_Id_Salesforce_Destinatario__c;
            
            if (org.KS_Cliente_Distribucion__c == null && org.KS_Cliente_solicitante__c != null) 
            { org.KS_Cliente_Distribucion__c = org.KS_Cliente_solicitante__c; }
            if (org.KS_Cliente_Distribucion__c != org.KS_Cliente_solicitante__c && org.KS_Cliente_solicitante__c != null)
            { org.KS_Cliente_Distribucion__c = org.KS_Cliente_solicitante__c; idDistribuidor = org.KS_Id_Salesforce_Solicitante__c; }
            
            if (org.KS_Cliente_Dest_Mercancias__c == null 
                && org.KS_Cliente_solicitante__c != null && org.KS_Cliente_Distribucion__c != null) 
            { org.KS_Cliente_Dest_Mercancias__c = org.KS_Cliente_solicitante__c; }
            
            if (org.KS_Oficinas_de_ventas__c == null && org.KS_Area__c != null) 
            { org.KS_Oficinas_de_ventas__c = org.KS_Area__c; }
            
            idDistribuidor = idDistribuidor != null ? idDistribuidor : org.KS_Id_Salesforce_Solicitante__c;
            idDestinatario = idDestinatario != null ? idDestinatario : org.KS_Id_Salesforce_Solicitante__c;
            
            String ID_Organizacion_Cliente = 
                KS_OrgCliente_Util.buildID(
                    idDistribuidor,
                    idDestinatario, 
                    org.KS_Id_Salesforce_Solicitante__c, 
                    org.KS_Organizacion_de_ventas__c, 
                    org.KS_Canal_de_distribucion__c, 
                    org.KS_Sector_Distribuidor__c, 
                    org.KS_Oficinas_de_ventas__c);
            
            if (org.KS_ID_Organizacion_Cliente__c != ID_Organizacion_Cliente) {
                orgID2ID.put(org.KS_ID_Organizacion_Cliente__c, ID_Organizacion_Cliente);
            }
             
            // Map<ID, Map<String, List<KS_Organizacion_Cliente__c>>> orgMap
            Map<String, List<KS_Organizacion_Cliente__c>> sameIDorgs = new Map<String, List<KS_Organizacion_Cliente__c>>();
            if (orgMap.containsKey(org.KS_Cliente_Distribucion__c)) { sameIDorgs = orgMap.get(org.KS_Cliente_Distribucion__c); }
            List<KS_Organizacion_Cliente__c> sameIDorgsLst = new List<KS_Organizacion_Cliente__c>();
            if (sameIDorgs.containsKey(ID_Organizacion_Cliente)) { sameIDorgsLst = sameIDorgs.get(ID_Organizacion_Cliente); }
            
            sameIDorgsLst.add(org); 
            sameIDorgs.put(ID_Organizacion_Cliente, sameIDorgsLst);
            orgMap.put(org.KS_Cliente_Distribucion__c, sameIDorgs);
            
            // 2018-01-16: Depuración 
            ownerUserNameMap.put(org.OwnerId, org.Owner.Username);
            // 2018-01-16: Depuración 
        }
        
        System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - orgID2ID - ' + orgID2ID.size() + ' -- ' + orgID2ID);
        System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - orgMap - ' + orgMap.size() + ' -- ' + orgMap);
        
        List<ID> searchForOfertasByOrg = new List<ID>();
		Map<String, List<KS_Organizacion_Cliente__c>> orgDuplicate = new Map<String, List<KS_Organizacion_Cliente__c>>();
        Map<ID, KS_Organizacion_Cliente__c> orgUpdate = new Map<ID, KS_Organizacion_Cliente__c>();
        
        Map<String, String> scrACMap = new Map<String, String>();
        Map<String, String> scrNGMap = new Map<String, String>();
        Map<String, String> scrIFMap = new Map<String, String>();
        Map<String, String> recurMap = new Map<String, String>();
        Map<String, String> ownerMap = new Map<String, String>();
        
        for (String idCli : orgMap.keySet()) {
            for (String idOrg : orgMap.get(idCli).keySet()) {
                
                List<KS_Organizacion_Cliente__c> sameIDorgs = orgMap.get(idCli).get(idOrg);
                Boolean duplicate = sameIDorgs.size() > 1;
                for (KS_Organizacion_Cliente__c org : sameIDorgs) { 
                    //org.KS_ID_Organizacion_Cliente__c = idOrg;
                    if (duplicate) { 
                        
                        searchForOfertasByOrg.add(org.ID); 

                        if (!recurMap.containsKey(idOrg) && org.KS_Recurrencia__c != null)
                        { recurMap.put(idOrg, org.KS_Recurrencia__c); }
                        else if (org.KS_Recurrencia__c != null) {
                            Integer recurr = Integer.valueOf(recurMap.get(idOrg));
                            if (recurr < Integer.valueOf(org.KS_Recurrencia__c)) 
                            { recurMap.put(idOrg, org.KS_Recurrencia__c); }
                        }
                        
                        if (ownerMap.containsKey(idOrg) && org.OwnerId != null && !userID.contains(org.OwnerId))
                        { ownerMap.put(idOrg, org.OwnerId); }
                        else if (!ownerMap.containsKey(idOrg) && org.OwnerId != null)
                        { ownerMap.put(idOrg, org.OwnerId); }
                        
                        if (!scrIFMap.containsKey(idOrg) && org.KS_Scoring_IF__c != null)
                        { scrIFMap.put(idOrg, org.KS_Scoring_IF__c); }
                        else if (org.KS_Scoring_IF__c != null) {
                            String actScr = scrIFMap.get(idOrg);
                            List<String> sorted = new List<String>();
                            sorted.add(org.KS_Scoring_IF__c); sorted.add(actScr);
                            sorted.sort();
                            scrIFMap.put(idOrg, sorted.get(0));
                        }
                        
                        if (!scrACMap.containsKey(idOrg) && org.KS_Scoring_Actividad__c != null)
                        { scrACMap.put(idOrg, org.KS_Scoring_Actividad__c); }
                        else if (org.KS_Scoring_Actividad__c != null) {
                            String actScr = scrACMap.get(idOrg);
                            if (org.KS_Scoring_Actividad__c.length() > actScr.length())
                             { scrACMap.put(idOrg, org.KS_Scoring_Actividad__c); }
                        }
                        
                        if (!scrNGMap.containsKey(idOrg) && org.KS_Scoring_Negocio__c != null)
                        { scrNGMap.put(idOrg, org.KS_Scoring_Negocio__c); }
                        else if (org.KS_Scoring_Negocio__c != null) {
                            String actScr = scrNGMap.get(idOrg);
                            if (org.KS_Scoring_Negocio__c.length() > actScr.length())
                             { scrNGMap.put(idOrg, org.KS_Scoring_Negocio__c); }
                        }
                    }
                }
                
                if (!duplicate && orgID2ID.containsKey(sameIDorgs.get(0).KS_ID_Organizacion_Cliente__c)) 
                { 
                    sameIDorgs.get(0).KS_ID_Organizacion_Cliente__c = idOrg; 
                    orgUpdate.put(sameIDorgs.get(0).ID, sameIDorgs.get(0)); 
                    /*Account acc = accMap.get(sameIDorgs.get(0).KS_Cliente_Distribucion__c);
                    if (accUpdate.containsKey(acc.ID)) { acc = accUpdate.get(acc.ID); }
                    acc.KS_Organizaciones_de_cuentas__c =
                        KS_OrgCliente_Util.buildMarcaAreaCuenta(
                            acc.KS_Organizaciones_de_cuentas__c,
                            sameIDorgs.get(0).KS_Organizacion_de_ventas__c,
                            sameIDorgs.get(0).KS_Canal_de_distribucion__c,
                            sameIDorgs.get(0).KS_Sector_Distribuidor__c,
                            sameIDorgs.get(0).KS_Area__c, 
                            sameIDorgs.get(0).KS_Delegacion__c, 
                            sameIDorgs.get(0).KS_Zona__c,
                            validMarca);
                    accUpdate.put(acc.ID, acc);*/
                }
                
                if (duplicate) { orgDuplicate.put(idOrg, sameIDorgs); }
            }
        }
        
        if (orgDuplicate.size()>0) {
            
            System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - orgDuplicate - ' + orgDuplicate.size() + ' -- ' + orgDuplicate);
            Map<ID, List<Opportunity>> orgOpps = new Map<ID, List<Opportunity>>();
            for (Opportunity opp : [SELECT ID,KS_Organizacion_Cliente__c FROM Opportunity WHERE KS_Organizacion_Cliente__c IN :searchForOfertasByOrg]) {
                
                List<Opportunity> opps = new List<Opportunity>();
                if (orgOpps.containsKey(opp.KS_Organizacion_Cliente__c)) { opps = orgOpps.get(opp.KS_Organizacion_Cliente__c); }
                opps.add(opp); orgOpps.put(opp.KS_Organizacion_Cliente__c, opps);
            }
            System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - orgOpps - ' + orgOpps.size() + ' -- ' + orgOpps);
            
            System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - scrACMap - ' + scrACMap.size() + ' -- ' + scrACMap);
            System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - scrNGMap - ' + scrNGMap.size() + ' -- ' + scrNGMap);
            System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - scrIFMap - ' + scrIFMap.size() + ' -- ' + scrIFMap);
            System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - recurMap - ' + recurMap.size() + ' -- ' + recurMap);
            System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - ownerMap - ' + ownerMap.size() + ' -- ' + ownerMap);
            
            Map<ID, KS_Organizacion_Cliente__c> orgDelete = new Map<ID, KS_Organizacion_Cliente__c>();

            List<Opportunity> totalOpps = new List<Opportunity>();
            for (String idOrg : orgDuplicate.keySet()) {
                List<KS_Organizacion_Cliente__c> duplicados = orgDuplicate.get(idOrg);
                List<Opportunity> orgTotalOpps = new List<Opportunity>();
                
                KS_Organizacion_Cliente__c oldest = new KS_Organizacion_Cliente__c();
                KS_Organizacion_Cliente__c oppest = new KS_Organizacion_Cliente__c();
                
                // 2018-01-16: Depuración 
                Map<Id, KS_Organizacion_Cliente__c> dupMap = new Map<Id, KS_Organizacion_Cliente__c>();
                // 2018-01-16: Depuración 

                for (KS_Organizacion_Cliente__c org : duplicados) {
                    
                    //org.KS_ID_Organizacion_Cliente__c = idOrg;
                   
                    if (org.CreatedDate < oldest.CreatedDate || oldest.ID == null) 
                    { oldest = org; }
                    
                    if (orgOpps.containsKey(org.ID))  { 
                        
                        if (oppest.ID == null || orgOpps.containsKey(oppest.ID)) {
                            if (oppest.ID == null || orgOpps.get(org.ID).size() > orgOpps.get(oppest.ID).size()) {
                                oppest = org;
                            }
                        }
                        orgTotalOpps.addAll( orgOpps.get(org.ID) ); 
                    }  
                    
                    orgDelete.put(org.ID, org);
                    // 2018-01-16: Depuración 
                    dupMap.put(org.ID, orgClieQRY.get(org.ID));
                    // 2018-01-16: Depuración 
                }

                KS_Organizacion_Cliente__c goodOrg = new KS_Organizacion_Cliente__c();
                if (oppest.ID != null) { 
                    for (Opportunity opp : orgTotalOpps) { opp.KS_Organizacion_Cliente__c = oppest.ID; }
                    totalOpps.addAll(orgTotalOpps);
                    goodOrg = oppest;
                } else if (oldest.ID != null) { goodOrg = oldest; }
                
                if (goodOrg.ID != null) {
                    
                    // 2018-01-16: Depuración 
                    if (dupMap.size()>1) {
                        dupMap.remove(goodOrg.ID);
                        KS_Organizacion_Cliente__c oldGoodOrg = orgClieQRY.get(goodOrg.ID);
                        List<KS_Organizacion_Cliente__c> marcasDup = new List<KS_Organizacion_Cliente__c>(); marcasDup.add(oldGoodOrg);
                        String owner = ownerUserNameMap.get(oldGoodOrg.OwnerId);
                        String descr = 'Histórico de: \r\n' + oldGoodOrg.Name + ';';
                        for (KS_Organizacion_Cliente__c orgDup : dupMap.values()) {
                            if (orgDup.OwnerId != null) { owner += ' ; ' + ownerUserNameMap.get(orgDup.OwnerId); }
                            descr += orgDup.Name + ';';
                            marcasDup.add(orgDup);
                        }
                        owner += ' > ' + ownerUserNameMap.get(goodOrg.OwnerId);
                        
                        KS_Debug__c debug = KS_Debug_Utils.debugObjectFieldsLst(
                            'Organización Cliente', 'KS_Batch_RepairOrgCliente', '', idOrg, 'Name', 
                            goodOrg, marcasDup, KS_Batch_RepairOrgCliente.camposMarca());
                        debug.KS_Descripcion__c = descr;
                        debug.KS_Master_Owner__c = owner; debug.KS_Merge_Responsable__c = owner;
                        debug.KS_Master_Marca__c = goodOrg.ID;
                        debug.RecordTypeId = debugRT;
                        debugList.add(debug);
                    }
                    // 2018-01-16: Depuración 

                    goodOrg.KS_ID_Organizacion_Cliente__c = idOrg;
                    if (scrACMap.containsKey(idOrg)) { goodOrg.KS_Scoring_Actividad__c = scrACMap.get(idOrg); }
                    if (scrNGMap.containsKey(idOrg)) { goodOrg.KS_Scoring_Negocio__c = scrNGMap.get(idOrg); }
                    if (scrIFMap.containsKey(idOrg)) { goodOrg.KS_Scoring_IF__c = scrIFMap.get(idOrg); }
                    if (recurMap.containsKey(idOrg)) { goodOrg.KS_Recurrencia__c = recurMap.get(idOrg); }
                    if (ownerMap.containsKey(idOrg)) { goodOrg.OwnerId = ownerMap.get(idOrg); }
                    orgDelete.remove(goodOrg.ID); orgUpdate.put(goodOrg.ID,goodOrg);
                }
            }
            
            System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - totalOpps - ' + totalOpps.size() + ' -- ' + totalOpps);
            update totalOpps;
            
            System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - orgDelete - ' + orgDelete.size() + ' -- ' + orgDelete);
            delete orgDelete.values();
        }
        
        System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - orgUpdate - ' + orgUpdate.size() + ' -- ' + orgUpdate);
        if (!isTest) { update orgUpdate.values(); }
        
        /*System.debug(Logginglevel.ERROR,'-- BATCH -- ----------------- JCAR - accUpdate - ' + accUpdate.size() + ' -- ' + accUpdate);
        update accUpdate.values(); // reactualizamos las cuentas*/

        // 2018-01-16: Depuración 
        insert debugList;
        // 2018-01-16: Depuración 
        
		KS_OrgCliente_Trigger.futureUpdateCallOrgCuenta(accMap.keySet());
        return orgUpdate.values();
    }

    global void finish(Database.BatchableContext BC){}
    
    global static Map<String,String> camposMarca() {
        Map<String,String> campos = new Map<String,String>();
        campos.put('KS_Scoring_Actividad__c', 'KS_Scoring_Actividad__c');
        campos.put('KS_Scoring_Negocio__c', 'KS_Scoring_Negocio__c');
        campos.put('KS_Scoring_IF__c', 'KS_Scoring_IF__c');
        campos.put('KS_Recurrencia__c', 'KS_Recurrencia__c');
        return campos;
    }
}