global without sharing class KS_Batch_AccScoring implements Database.Batchable<sObject>{
    
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    
    global KS_Batch_AccScoring(String q, String e, String f, String v) {
        
        System.debug('-------------------------JCAR - QUERY - ' + q);
        Query=q; Entity=e; Field=f;Value=v;
    }
    
    global KS_Batch_AccScoring(String q){
        
        System.debug('-------------------------JCAR - QUERY - ' + q);
        Query=q;
    }    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('-------------------------JCAR - QUERY - ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        Map<ID, KS_Organizacion_Cliente__c> orgUPDATE = new Map<ID, KS_Organizacion_Cliente__c>();
        
        List<Account> accLst = (List<Account>)scope;
        
        List<ID> accIDs = new List<ID>();
        List<ID> accDistr = new List<ID>();
        List<ID> accInsta = new List<ID>();
        List<ID> accClFin = new List<ID>();
        List<ID> accPrein = new List<ID>();
        
        Map<ID, String> accCanal = new Map<ID, String>();
        Map<String, ID> accMarca = new Map<String, ID>();
        
        for (Account acc : accLst) {
            
            accCanal.put(acc.ID, acc.KS_Canal__c);
            if (acc.KS_Canal__c == 'Distribuidores CRM' || acc.KS_Canal__c == 'Distribuidores SAP') {
                accDistr.add(acc.ID);
            } else if (acc.KS_Canal__c == 'Instalador') {
                accInsta.add(acc.ID);
            } else if (acc.KS_Canal__c == 'Clientes finales') {
                accClFin.add(acc.ID);
            } else if (acc.KS_Canal__c == 'Prescriptores') {
                accPrein.add(acc.ID);
            }
        }
        accIDs.addAll(accCanal.keySet());
        
        System.debug('-------------------------JCAR - accIDs ' + accIDs.size() + ' total.');
        System.debug('-------------------------JCAR - accDistr ' + accDistr.size());
        System.debug('-------------------------JCAR - accInsta ' + accInsta.size());
        System.debug('-------------------------JCAR - accClFin ' + accClFin.size());
        System.debug('-------------------------JCAR - accPrein ' + accPrein.size());
        
        Map<String, List<KS_Organizacion_Cliente__c>> accOrgs = new Map<String, List<KS_Organizacion_Cliente__c>>();
        List<KS_Organizacion_Cliente__c> orgClienteLst = 
            [SELECT ID, KS_Cliente_Distribucion__c, KS_Cliente_solicitante__c, KS_Scoring_Negocio__c, KS_Scoring_Actividad__c, 
             KS_Sociedad__c, KS_Sector_Distribuidor__c, KS_Canal_Cliente__c, KS_Canal_de_distribucion__c, KS_Organizacion_de_ventas__c
             FROM KS_Organizacion_Cliente__c WHERE 
             KS_Sociedad__c != null AND KS_Sector_Distribuidor__c != null AND KS_Canal_Cliente__c != null
             AND KS_Canal_de_distribucion__c != null AND KS_Organizacion_de_ventas__c != NULL
             AND (
                 (KS_Cliente_Distribucion__c IN :accDistr AND KS_Canal_Cliente__c IN ('Distribuidores CRM', 'Distribuidores SAP'))
                 OR 
                 (KS_Cliente_solicitante__c IN :accInsta AND KS_Canal_Cliente__c IN ('Instalador'))
                 OR 
                 (KS_Cliente_solicitante__c IN :accClFin AND KS_Canal_Cliente__c IN ('Clientes finales'))
                 OR 
                 (KS_Cliente_solicitante__c IN :accPrein AND KS_Canal_Cliente__c IN ('Prescriptores'))
             )
            ];
        
        System.debug('-------------------------JCAR - orgClienteLst ' + orgClienteLst.size() + ' total.');
        for (KS_Organizacion_Cliente__c org : orgClienteLst) {
            
            ID accID = org.KS_Cliente_solicitante__c;
            String accKey = org.KS_Cliente_solicitante__c + org.KS_Organizacion_de_ventas__c + org.KS_Canal_de_distribucion__c;
            if (org.KS_Canal_Cliente__c == 'Distribuidores CRM' || org.KS_Canal_Cliente__c == 'Distribuidores SAP') {
                accKey = org.KS_Cliente_Distribucion__c + org.KS_Organizacion_de_ventas__c + org.KS_Canal_de_distribucion__c;
                accID = org.KS_Cliente_Distribucion__c;
            }
            
            accMarca.put(accKey, accID);
            
            List<KS_Organizacion_Cliente__c> orgLst = new List<KS_Organizacion_Cliente__c>();
            if ( accOrgs.containsKey(accKey) ) { orgLst = accOrgs.get(accKey); }
            orgLst.add(org); accOrgs.put(accKey, orgLst);
            
            org.KS_Scoring_Negocio__c = null;
            org.KS_Scoring_Actividad__c = null;
            orgUPDATE.put(org.ID, org);
        }
  
        Datetime dt = Datetime.now().addMonths(-12);
        System.debug('-------------------------JCAR - ' + dt.format() + ' o anterior.');
        
        String oppQRYs = 'SELECT ID, KS_Importe_total_fichas__c, KS_Importe_total_Instalador_c__c, KS_Importe_total_Cliente_Final__c,'+
            ' KS_Distribuidor__c, KS_Instalador__c, KS_Cliente_final__c, KS_Canal__c, KS_Organizacion_de_ventas__c FROM Opportunity'+
            ' WHERE (KS_Distribuidor__c in :accDistr or KS_Instalador__c in :accInsta or KS_Cliente_final__c in :accClFin or KS_Cliente_final__c in :accPrein)'+
            ' AND CreatedDate > ' + dt.format('YYYY-MM-dd\'T\'kk:mm:ss')+'.000+0000';
        List<Opportunity> oppQRY = Database.query(oppQRYs);
		System.debug('-------------------------JCAR - oppQRY ' + oppQRY.size() + ' total.');
        
        Map<String, List<Opportunity>> accOpps = new Map<String, List<Opportunity>>();
        List<ID> oppIDs = new List<ID>(); Map<ID, Opportunity> oppMap = new Map<ID, Opportunity>();
        for (Opportunity opp : oppQRY) {
            
            oppIDs.add(opp.ID); oppMap.put(opp.ID, opp);
            
            if (opp.KS_Distribuidor__c != null) {
                
                String accKey = opp.KS_Distribuidor__c + opp.KS_Organizacion_de_ventas__c + opp.KS_Canal__c;
                List<Opportunity> opps = new List<Opportunity>();
                if ( accOpps.containsKey(accKey) ) { opps = accOpps.get(accKey); }
                opps.add(opp); accOpps.put(accKey, opps);
                
            } else if (opp.KS_Instalador__c != null) {
                
                String accKey = opp.KS_Instalador__c + opp.KS_Organizacion_de_ventas__c + opp.KS_Canal__c;
                List<Opportunity> opps = new List<Opportunity>();
                if ( accOpps.containsKey(accKey) ) { opps = accOpps.get(accKey); }
                opps.add(opp); accOpps.put(accKey, opps);
                
            } else if (opp.KS_Cliente_final__c != null) {
                
                String accKey = opp.KS_Cliente_final__c + opp.KS_Organizacion_de_ventas__c + opp.KS_Canal__c;
                List<Opportunity> opps = new List<Opportunity>();
                if ( accOpps.containsKey(accKey) ) { opps = accOpps.get(accKey); }
                opps.add(opp); accOpps.put(accKey, opps);
            }
        }

        String pdfQRYs = 'SELECT ID, KS_Cuenta__c, KS_Oferta__c FROM KS_Oferta_pendiente__c'+
            ' WHERE (KS_Cuenta__c in :accDistr or KS_Cuenta__c in :accInsta or KS_Cuenta__c in :accClFin or KS_Cuenta__c in :accPrein)'+
            ' AND CreatedDate > ' + dt.format('YYYY-MM-dd\'T\'kk:mm:ss')+'.000+0000';
        List<KS_Oferta_pendiente__c> pdfQRY = Database.query(pdfQRYs);
        System.debug('-------------------------JCAR - pdfQRYs ' + pdfQRY.size() + ' total.');
        
        Map<ID, List<KS_Oferta_pendiente__c>> pdfMap = new Map<ID, List<KS_Oferta_pendiente__c>>();
        for (KS_Oferta_pendiente__c pdf : pdfQRY) {
            
            List<KS_Oferta_pendiente__c> pdfLst = new List<KS_Oferta_pendiente__c>();
            if ( pdfMap.containsKey(pdf.KS_Cuenta__c) ) { pdfLst = pdfMap.get(pdf.KS_Cuenta__c); }
            pdfLst.add(pdf); pdfMap.put(pdf.KS_Cuenta__c, pdfLst);
        }
        
        String rptQRYs = 'SELECT ID, KS_Oferta__c, KS_Cuenta__c FROM KS_Reporte__c'+
            ' WHERE (KS_Cuenta__c in :accDistr or KS_Cuenta__c in :accInsta or KS_Cuenta__c in :accClFin or KS_Cuenta__c in :accPrein)'+
            ' AND CreatedDate > ' + dt.format('YYYY-MM-dd\'T\'kk:mm:ss')+'.000+0000';
        List<KS_Reporte__c> rptQRY = Database.query(rptQRYs);
        System.debug('-------------------------JCAR - rptQRY ' + rptQRY.size() + ' total.');
        
        Map<ID, List<KS_Reporte__c>> rptMap = new Map<ID, List<KS_Reporte__c>>();
        for (KS_Reporte__c rpt : rptQRY) {
            
            List<KS_Reporte__c> rptLst = new List<KS_Reporte__c>();
            if ( rptMap.containsKey(rpt.KS_Cuenta__c) ) { rptLst = rptMap.get(rpt.KS_Cuenta__c); }
            rptLst.add(rpt); rptMap.put(rpt.KS_Cuenta__c, rptLst);
        }
        
        Map<String, Integer> accActividad = new Map<String, Integer>();
        Map<String, Decimal> accNegocio = new Map<String, Decimal>();
        
        for (String accKey : accMarca.keySet()) {

            System.debug('-------------------------JCAR - accKey ' + accKey);
            
            List<Opportunity> oppLst = accOpps.containsKey(accKey) ? accOpps.get(accKey) : new List<Opportunity>();
            List<KS_Organizacion_Cliente__c> orgLst = accOrgs.containsKey(accKey) ? accOrgs.get(accKey) : new List<KS_Organizacion_Cliente__c>();
            ID accID = accMarca.get(accKey);

            String canal = accCanal.get(accID);
            
            Decimal negocio = 0;
            for (Opportunity opp : oppLst) {
                
                if ( (canal == 'Distribuidores CRM' || canal == 'Distribuidores SAP') && opp.KS_Distribuidor__c == accID) {
                    
                    negocio = negocio + opp.KS_Importe_total_fichas__c;
                    
                } else if (canal == 'Instalador' && opp.KS_Instalador__c == accID) {
                    
                    negocio = negocio + opp.KS_Importe_total_Instalador_c__c;
                    
                } else if ( (canal == 'Clientes finales' || canal == 'Prescriptores') && opp.KS_Cliente_final__c == accID) {
                    
                    negocio = negocio + opp.KS_Importe_total_Cliente_Final__c;
                    
                }
            }
            accNegocio.put(accKey, negocio);

            List<KS_Reporte__c> rptLst = rptMap.containsKey(accID) ? rptMap.get(accID) : new List<KS_Reporte__c>();            
            List<KS_Oferta_pendiente__c> pdfLst = pdfMap.containsKey(accID) ? pdfMap.get(accID) : new List<KS_Oferta_pendiente__c>();            

            Integer actividad = oppLst.size() + rptLst.size() + pdfLst.size();
            accActividad.put(accKey, actividad);

            System.debug('-------------------------JCAR - accKey negocio ' + negocio);
            System.debug('-------------------------JCAR - accKey actividad ' + oppLst.size() + '+' + rptLst.size() + '+' + pdfLst.size() + ' = ' + actividad);
            
            if (negocio>0 || actividad>=0) {
                
                for (KS_Organizacion_Cliente__c org : orgLst) {
                    
                    //if ( orgUPDATE.containsKey(accID) ) { org = orgUPDATE.get(org.ID); }
                    org.KS_Scoring_Negocio__c = null;
                    org.KS_Scoring_Actividad__c = null;
                    org = setScoring(org, negocio, actividad, canal);
                    orgUPDATE.put(org.ID, org);
                }
            }
        }
        
        if (orgUPDATE.size()>0) {
            update orgUPDATE.values();
        }
    }
    
    global KS_Organizacion_Cliente__c setScoring(KS_Organizacion_Cliente__c org, Decimal negocio, Integer actividad, String canal) {

        System.debug('-------------------------JCAR - setScoring ' + org.ID + ' - ' + canal);
        
        if (canal == 'Distribuidores CRM' || canal == 'Distribuidores SAP') {
            
            System.debug('-------------------------JCAR - setScoring account ' + org.KS_Cliente_Distribucion__c);
            
            if (negocio < 250000 && negocio >= 100000) { org.KS_Scoring_Negocio__c = '*'; }
            else if (negocio < 500000 && negocio >= 250000) { org.KS_Scoring_Negocio__c = '**'; }
            else if (negocio < 750000 && negocio >= 500000) { org.KS_Scoring_Negocio__c = '***'; }
            else if (negocio < 1000000 && negocio >= 750000) { org.KS_Scoring_Negocio__c = '****'; }
            else if (negocio >= 1000000) { org.KS_Scoring_Negocio__c = '*****'; }
            
            if (actividad < 20 && actividad >= 10) { org.KS_Scoring_Actividad__c = '*'; }
            else if (actividad < 30 && actividad >= 20) { org.KS_Scoring_Actividad__c = '**'; }
            else if (actividad < 40 && actividad >= 30) { org.KS_Scoring_Actividad__c = '***'; }
            else if (actividad < 50 && actividad >= 40) { org.KS_Scoring_Actividad__c = '****'; }
            else if (actividad >= 50) { org.KS_Scoring_Actividad__c = '*****'; }
        
        } else if (canal == 'Instalador') {

            System.debug('-------------------------JCAR - setScoring account ' + org.KS_Cliente_solicitante__c);
            
            if (negocio < 100000 && negocio >= 50000) { org.KS_Scoring_Negocio__c = '*'; }
            else if (negocio < 150000 && negocio >= 100000) { org.KS_Scoring_Negocio__c = '**'; }
            else if (negocio < 250000 && negocio >= 150000) { org.KS_Scoring_Negocio__c = '***'; }
            else if (negocio < 500000 && negocio >= 250000) { org.KS_Scoring_Negocio__c = '****'; }
            else if (negocio >= 500000) { org.KS_Scoring_Negocio__c = '*****'; }
            
            if (actividad < 10 && actividad >= 5) { org.KS_Scoring_Actividad__c = '*'; }
            else if (actividad < 15 && actividad >= 10) { org.KS_Scoring_Actividad__c = '**'; }
            else if (actividad < 20 && actividad >= 15) { org.KS_Scoring_Actividad__c = '***'; }
            else if (actividad < 25 && actividad >= 20) { org.KS_Scoring_Actividad__c = '****'; }
            else if (actividad >= 25) { org.KS_Scoring_Actividad__c = '*****'; }
            
        } else if (canal == 'Clientes finales') {
            
            System.debug('-------------------------JCAR - setScoring account ' + org.KS_Cliente_solicitante__c);
            
            if (negocio < 75000 && negocio >= 25000) { org.KS_Scoring_Negocio__c = '*'; }
            else if (negocio < 100000 && negocio >= 75000) { org.KS_Scoring_Negocio__c = '**'; }
            else if (negocio < 150000 && negocio >= 100000) { org.KS_Scoring_Negocio__c = '***'; }
            else if (negocio < 250000 && negocio >= 150000) { org.KS_Scoring_Negocio__c = '****'; }
            else if (negocio >= 250000) { org.KS_Scoring_Negocio__c = '*****'; }
            
            if (actividad < 3 && actividad >= 0) { org.KS_Scoring_Actividad__c = '*'; }
            else if (actividad < 5 && actividad >= 3) { org.KS_Scoring_Actividad__c = '**'; }
            else if (actividad < 10 && actividad >= 5) { org.KS_Scoring_Actividad__c = '***'; }
            else if (actividad < 15 && actividad >= 10) { org.KS_Scoring_Actividad__c = '****'; }
            else if (actividad >= 15) { org.KS_Scoring_Actividad__c = '*****'; }
            
        } else if (canal == 'Prescriptores') {
            
            System.debug('-------------------------JCAR - setScoring account ' + org.KS_Cliente_solicitante__c);
            
            if (negocio < 75000 && negocio >= 25000) { org.KS_Scoring_Negocio__c = '*'; }
            else if (negocio < 100000 && negocio >= 75000) { org.KS_Scoring_Negocio__c = '**'; }
            else if (negocio < 150000 && negocio >= 100000) { org.KS_Scoring_Negocio__c = '***'; }
            else if (negocio < 250000 && negocio >= 150000) { org.KS_Scoring_Negocio__c = '****'; }
            else if (negocio >= 250000) { org.KS_Scoring_Negocio__c = '*****'; }
            
            if (actividad < 3 && actividad >= 0) { org.KS_Scoring_Actividad__c = '*'; }
            else if (actividad < 5 && actividad >= 3) { org.KS_Scoring_Actividad__c = '**'; }
            else if (actividad < 15 && actividad >= 5) { org.KS_Scoring_Actividad__c = '***'; }
            else if (actividad < 25 && actividad >= 15) { org.KS_Scoring_Actividad__c = '****'; }
            else if (actividad >= 25) { org.KS_Scoring_Actividad__c = '*****'; }
        }
        
        System.debug('-------------------------JCAR - setScoring negocio ' + negocio + ' - ' + org.KS_Scoring_Negocio__c);
        System.debug('-------------------------JCAR - setScoring activid ' + actividad + ' - ' + org.KS_Scoring_Actividad__c);        
        
        return org;
    }
    
    global void finish(Database.BatchableContext BC) { }
}