global class KS_OrgCliente_Util {

    global static String buildID(String idDistr, String idClFnal, String idSolic, 
                                 String orgVentas, String canal, String sector, String ofiVentas) {
                                     
                                     String idOrgCliente = '';
                                     
                                     idOrgCliente = idDistr;
                                     if (idClFnal != null) { idOrgCliente += '-' + idClFnal; }
                                     if (idSolic != null) { idOrgCliente += '-' + idSolic; }
                                     if (orgVentas != null) { idOrgCliente += '-' + orgVentas; }
                                     if (canal != null) { idOrgCliente += '-' + canal; }
                                     if (sector != null) { idOrgCliente += '-' + sector; }
                                     if (ofiVentas != null) { idOrgCliente += '-' + ofiVentas; }
                                     
                                     return idOrgCliente;
                                 }
    
    global static String buildMarcaAreaCuenta
        (String marcArea, String orgVentas, String canal, 
         String sector, String area, String delega, String zona,
         Set<String> validMarcas) {
             
             String marca = '';//orgVentas + '-' + canal + '-' + sector;
             if (orgVentas != null) { marca += orgVentas; }
             if (canal != null) { marca += '-' + canal; }
             if (sector != null) { marca += '-' + sector; }
              System.debug(Logginglevel.ERROR,'-- KS_OrgCliente_Util -- ----------------- JCAR - validMarca? - '
                           + marca + ' = ' + validMarcas.contains(marca));
             
             if (validMarcas.contains(marca)) {
                 String newMA = marca;// + '-' + area + '-' + delega + '-' + zona;
                 if (area != null) { newMA += '-' + area; }
                 if (delega != null) { newMA += '-' + delega; }
                 if (zona != null) { newMA += '-' + zona; }
                 
                 if (marcArea == null) { marcArea = newMA; }
                 else if (marcArea!=null && !marcArea.contains(newMA)) { marcArea += ';' + newMA; }
             }
             return marcArea;
         }
    
    global static Set<String> validMarcas() {
        List<KS_Conf_Organizacion_Cliente__mdt> orgConfLst = 
            [SELECT Id, DeveloperName, KS_Organizacion_de_ventas__c, KS_Canal_SAP__c, KS_Sector__c, KS_Lista_de_precios__c 
             FROM KS_Conf_Organizacion_Cliente__mdt];
        Set<String> validMarca = new Set<String>();
        for (KS_Conf_Organizacion_Cliente__mdt conf : orgConfLst) {
            validMarca.add(conf.KS_Organizacion_de_ventas__c 
                           + '-' + conf.KS_Canal_SAP__c
                           + '-' + conf.KS_Sector__c);
        }
        return validMarca;
    }
}