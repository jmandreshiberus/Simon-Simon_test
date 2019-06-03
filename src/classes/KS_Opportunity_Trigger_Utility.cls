public without sharing class KS_Opportunity_Trigger_Utility {

    
    public static void calculaIntervinientes(List<ID> idObra) {
        
        if (idObra.isEmpty()) {return;}
        else if (idObra.get(0)==null) {return;}
        
        // TRIGGER INTERVINIENTE
        // INTERVINIENTE == KS_Obra__c+KS_Distribuidor__c
        // Los lookup KS_Cliente_final__c, KS_Instalador__c y KS_Distribuidor__c se convertirán en Interviniente
        // Hay que verificar si ya hay creados con los criterios KS_Obra__c+KS_Distribuidor__c y sumarles 1 al campo KS_Repeticiones__c        
        
        // Primer mapeo, extracción de cuentas
        List<Opportunity> ofertas = [SELECT ID,KS_Distribuidor__c,AccountId,KS_Instalador__c,KS_Cliente_final__c,KS_Obra__c
                                     FROM Opportunity WHERE KS_Obra__c IN :idObra];
        List<KS_Oferta_Pendiente__c> ofertasP = [SELECT ID,KS_Cuenta__c,KS_Obra__c
                                                 FROM KS_Oferta_Pendiente__c WHERE KS_Obra__c IN :idObra];
        Map<String, Decimal> intervinientesObra = setIntervinientesObra(ofertas, ofertasP);
		System.debug('----------------------------------------JCAR - ' + intervinientesObra.size() + ' intervinientesObra : ' + intervinientesObra);
        
        // Segundo mapeo, intervinientes actuales!
        // SI está en OLD y NO en NEW, DELETE
        // SI está en NEW y NO en OLD, INSERT
        // SI está en NEW y SI en OLD, UPDATE
        Map<String, KS_Intervinientes__c> intervinientesObraOLD = new Map<String, KS_Intervinientes__c>();
        List<KS_Intervinientes__c> interDELETE = new List<KS_Intervinientes__c>();
        for (KS_Intervinientes__c inter : [SELECT ID,KS_Obra__c,KS_Interviniente__c,KS_Repeticiones__c FROM KS_Intervinientes__c WHERE KS_Obra__c IN :idObra]) {

            String skey = inter.KS_Obra__c + '_' + inter.KS_Interviniente__c;
            //System.debug('----------------------------------------JCAR - ' + skey);
            if (!intervinientesObra.containsKey(skey)) { // DELETE
                interDELETE.add(inter);
            } else { // UPDATE
            	intervinientesObraOLD.put(skey, inter);    
            }
        }
        System.debug('----------------------------------------JCAR - ' + intervinientesObraOLD.size() + ' intervinientesObraOLD : ' + intervinientesObraOLD);
        
        // Tercer mapeo, cruzado de datos
        List<KS_Intervinientes__c> interUPSERT = new List<KS_Intervinientes__c>();
        for (String skey : intervinientesObra.keySet()) {
            
            //System.debug('----------------------------------------JCAR - ' + skey);
            
            Decimal count = intervinientesObra.get(skey);
            KS_Intervinientes__c inter = new KS_Intervinientes__c();
            if ( intervinientesObraOLD.containsKey(skey) ) //  UPDATE!
            { 
                inter = intervinientesObraOLD.get(skey);
                //System.debug('----------------------------------------JCAR - ' + inter);
            }
            else // INSERT!
            {
                inter.KS_Obra__c = skey.split('_')[0];
                inter.KS_Interviniente__c = skey.split('_')[1];
            }
            inter.KS_Origen__c = '1'; // Origen = Oferta
            inter.KS_Repeticiones__c = count;
            interUPSERT.add(inter);
            
        }
        System.debug('----------------------------------------JCAR - ' + interUPSERT.size() + ' interUPSERT : ' + interUPSERT);
        upsert interUPSERT;
        System.debug('----------------------------------------JCAR - ' + interDELETE.size() + ' interDELETE : ' + interDELETE);
        delete interDELETE;        
        
    }
    private static Map<String, Decimal>  setIntervinientesObra (List<Opportunity> ofertas, List<KS_Oferta_Pendiente__c> ofertasP) {
        
        System.debug('----------------------------------------JCAR - ' + ofertas.size() + ' ofertas : ' + ofertas);
        System.debug('----------------------------------------JCAR - ' + ofertasP.size() + ' ofertasP : ' + ofertasP);        
        
        Map<String, Decimal> intervinientesObra = new Map<String, Decimal>();
        for (Opportunity opp : ofertas) {
            
            List<String> oppAcc = new List<String>();
            if (opp.KS_Distribuidor__c != null) { oppAcc.add(opp.KS_Distribuidor__c); }
            if (opp.KS_Instalador__c != null) { oppAcc.add(opp.KS_Instalador__c); }
            if (opp.KS_Cliente_final__c != null) { oppAcc.add(opp.KS_Cliente_final__c); }
            
            for (String accID : oppAcc) {
                
                String skey = opp.KS_Obra__c + '_' + accID;
                Decimal count = 0;
                if (intervinientesObra.containsKey(skey)) {
                    count = intervinientesObra.get(skey);
                }
				intervinientesObra.put(skey, count + 1);                
            }
        }
		for (KS_Oferta_Pendiente__c opp : ofertasP) {
            
            if (opp.KS_Cuenta__c != null) {
                
                String skey = opp.KS_Obra__c + '_' + opp.KS_Cuenta__c;
                Decimal count = 0;
                if (intervinientesObra.containsKey(skey)) {
                    count = intervinientesObra.get(skey);
                }
				intervinientesObra.put(skey, count + 1);                
            }
        } 
        return intervinientesObra;
    }
}