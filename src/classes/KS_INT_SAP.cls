global class KS_INT_SAP {

    webservice static string HelloWorld(string message){
        return 'Hello World from Salesforce: ' + message;
    }

    
    //////////////////////////////////////
    // CLIENTE - CUENTA (DISTRIBUCION) //
    ////////////////////////////////////    
    webservice static List<KS_INT_GEN.KS_Resultado> SetCliente(List<KS_INT_GEN.KS_Cliente> lstCliente) {
        
        Map<String, KS_INT_GEN.KS_Resultado> mapResult = new Map<String, KS_INT_GEN.KS_Resultado>();
        Map<String, KS_INT_GEN.KS_Resultado> mapResultOrga = new Map<String, KS_INT_GEN.KS_Resultado>();
        List<KS_INT_GEN.KS_Resultado> lstResult = new List<KS_INT_GEN.KS_Resultado>();
        
        String tipo = 'Cliente Distribuidor';
        String subtipo = 'Organizacion Cliente';

        //Creamos Mapa ID Sap Cliente + lista Organizaciones Cliente Distribucion
        Map<String, List<KS_INT_GEN.KS_OrganizacionCliente>> mapIdSapListOrgCDis = new Map<String, List<KS_INT_GEN.KS_OrganizacionCliente>>();
                      
        Set<String> usrSet = new Set<String>();
        
        System.debug('------------------------- JCAR KS_INT_SAP SetCliente - ' + lstCliente.size() + ' KS_INT_GEN.KS_Cliente ' + lstCliente);
        
        //Creamos Mapa de ID Sap Cliente + Id SF Cliente Mercancia/Solicitante
        List<String> lstAccSAP = new List<String>();
        List<String> lstAccSF = new List<String>();
        Map<String,Account> mapAcc = new Map<String,Account>();
        Map<String,KS_INT_GEN.KS_Cliente> mapSAP = new Map<String,KS_INT_GEN.KS_Cliente>();
        
        for(KS_INT_GEN.KS_Cliente clie : lstCliente) {
            for(KS_INT_GEN.KS_OrganizacionCliente oClie : clie.lstOrgClientes) {
                
                if (oClie.KS_Cliente_Dest_Mercancias != null) { lstAccSAP.add(oClie.KS_Cliente_Dest_Mercancias); }
                if (oClie.KS_Cliente_solicitante != null) { lstAccSAP.add(oClie.KS_Cliente_solicitante); }
                //if (oClie.KS_Cliente_Distribucion != null) { lstAccSAP.add(oClie.KS_Cliente_Distribucion); }
			
                // Coordinador OrgClie
                if (!usrSet.contains(oClie.KS_Numero_Personal)) { usrSet.add(oClie.KS_Numero_Personal); }
            }
            
            lstAccSAP.add(clie.KS_Numero_de_deudor);
            if (clie.KS_Clave_de_grupo != null) {lstAccSF.add(clie.KS_Clave_de_grupo);}
            mapSAP.put(clie.KS_Numero_de_deudor, clie);
        }
        
        List<RecordType> rtLst = [ select id, developername from RecordType where developername = 'KS_Distribuidores_SAP' OR developername = 'KS_OrgClie_SAP' OR developername = 'KS_Nodo_Jerarquico'];
        RecordType rtClie = null; RecordType rtOrgClie = null;RecordType rtNode = null;
        for (RecordType rt : rtLst) {
            if (rt.DeveloperName == 'KS_Distribuidores_SAP') {
                rtClie = rt;
            } else if (rt.DeveloperName == 'KS_OrgClie_SAP') {
                rtOrgClie = rt;
            } else if (rt.DeveloperName == 'KS_Nodo_Jerarquico') {
                rtNode = rt;
            }
        }
        List<Account> lstClieDistribucionSAP = new List<Account>();
        Map<String,Account> mapClieDistribucionSF = new Map<String,Account>();        
        
        // Mapeo usuarios Coordinador OrgCLie
        Map<String,Id> usrMAP = new Map<String,Id>();
        User adminUser = new User();
        List<String> usrSAP = new List<String>(); usrSAP.addAll(usrSet);
        for (User usr : [SELECT ID,KS_IDSAP__c,Alias FROM User WHERE (KS_IDSAP__c IN :usrSAP OR Alias = 'asimo') AND isActive = true] ) {
            if (usr.Alias == 'asimo') {
            	adminUser = usr;
            } else {
                usrMAP.put(usr.KS_IDSAP__c, usr.ID);
            }
        }
        
        for(KS_INT_GEN.KS_Cliente clie : lstCliente) {

            Boolean wrong = false;
            KS_INT_GEN.KS_Resultado resultC = new KS_INT_GEN.KS_Resultado();
            resultC.descripcion = '';
            Account clieDist = new Account();
            
            //Datos por defecto - Cliente Distribuidor
            clieDist.RecordTypeId = clie.KS_Grupo_de_ctas_deudor != null && clie.KS_Grupo_de_ctas_deudor == '0012' ? rtNode.Id : rtClie.Id;
            clieDist.KS_Estado__c = 'Activo';
            
            //Datos suministrados
            clieDist.KS_Id_SAP__c = clie.KS_Numero_de_deudor;
            
            clieDist.Name = 
                clie.KS_Nombre_3 != null ? clie.KS_Nombre_3 : ''
                + (clie.KS_Nombre_3 != null && clie.KS_Nombre_4 != null ? ' ' : '') 
                + clie.KS_Nombre_4 != null ? clie.KS_Nombre_4 : '';
            clieDist.KS_Nombre_2__c = 
                clie.KS_Nombre_1 != null ? clie.KS_Nombre_1 : ''
                + (clie.KS_Nombre_1 != null && clie.KS_Nombre_2 != null ? ' ' : '') 
                + clie.KS_Nombre_2 != null ? clie.KS_Nombre_2 : '';            
            
            clieDist.Phone = clie.KS_N_de_telefono_1;
            clieDist.ShippingCountryCode = clie.KS_Pais_Cliente;
            clieDist.ShippingCity = clie.KS_Poblacion;
            clieDist.ShippingPostalCode = clie.KS_Codigo_Postal;
            clieDist.ShippingStreet = clie.KS_Calle_y_N;
                               
            clieDist.KS_Grupo_de_ctas_deudor__c = clie.KS_Grupo_de_ctas_deudor;
            clieDist.KS_Idioma__c = clie.KS_Idioma;
            clieDist.KS_N_identificacion_fiscal_suplementario__c = clie.KS_N_identificacion_fiscal_suplementario;
            clieDist.KS_Numero_de_identificacion_fiscal_1__c = clie.KS_Numero_de_identificacion_fiscal_1;
            clieDist.KS_N_de_telefono_2__c = clie.KS_N_de_telefono_2;
                         
            clieDist.KS_Peticion_borrado__c = clie.KS_Peticion_de_borrado_para_cliente != null ? clie.KS_Peticion_de_borrado_para_cliente : false;
            
            //clieDist.KS_Actividad__c = 'Distribuidor';
            //clieDist.KS_Canal__c = 'Distribuidores SAP';
            
            mapIdSapListOrgCDis.put(clie.KS_Numero_de_deudor, new List<KS_INT_GEN.KS_OrganizacionCliente>());
            resultC.codigo = clie.KS_Numero_de_deudor;
            if (!wrong) { 
                if (clie.KS_Clave_de_grupo!=null) { mapClieDistribucionSF.put(clie.KS_Clave_de_grupo, clieDist); }
                else { lstClieDistribucionSAP.add(clieDist); }
            }
            else { resultC.tipo = 'E - ' + tipo; }
            mapResult.put(resultC.codigo, resultC);
        }

        List<Account> lstClieDistribucion = new List<Account>();
        System.debug('------------------------- JCAR KS_INT_SAP SetCliente lstClieDistribucionSAP - ' + lstClieDistribucionSAP.size() + ' List<Account> ' + lstClieDistribucionSAP);
        System.debug('------------------------- JCAR KS_INT_SAP SetCliente mapClieDistribucionSF - ' + mapClieDistribucionSF.size() + ' Map<String, Account> ' + mapClieDistribucionSF);
        
        Schema.sObjectField idSAP = Account.KS_Id_SAP__c.getDescribe().getSObjectField();
        Database.UpsertResult[] upsertResult = Database.upsert(lstClieDistribucionSAP, idSAP, false);
        
        System.debug('------------------------- JCAR KS_INT_SAP SetCliente lstAccSF - ' + lstAccSF.size() + ' List<String> ' + lstAccSF);
        Map<String,Account> mapClieDistribucion = new Map<String,Account>();
        for(Account clie : [SELECT ID, KS_Id_Salesforce__c FROM Account WHERE KS_Id_Salesforce__c in :lstAccSF ]) 
        { 
            Account acc = new Account(); if (mapClieDistribucionSF.containsKey(clie.KS_Id_Salesforce__c)) 
            { 
                acc = mapClieDistribucionSF.get(clie.KS_Id_Salesforce__c); acc.ID = clie.ID;
                mapClieDistribucion.put(clie.KS_Id_Salesforce__c, acc); 
            } 
        }
        System.debug('------------------------- JCAR KS_INT_SAP SetCliente mapClieDistribucion - ' + mapClieDistribucion.size() + ' Map<String,Account> ' + mapClieDistribucion);
        
        Schema.sObjectField IDSF = Account.ID.getDescribe().getSObjectField();
        upsertResult.addAll(Database.upsert(mapClieDistribucion.values(), IDSF, false));
        
        lstClieDistribucion.addAll(lstClieDistribucionSAP); lstClieDistribucion.addAll(mapClieDistribucion.values());
        lstResult = controlErrorUpsert(upsertResult, tipo, (List<Object>)lstClieDistribucion, mapResult);
        
        for(Account clie : [SELECT id, KS_Id_SAP__c, KS_Id_Salesforce__c FROM Account WHERE KS_Id_SAP__c in :lstAccSAP or KS_Id_Salesforce__c in :lstAccSF ]) 
        { mapAcc.put(clie.KS_Id_SAP__c, clie); }
        System.debug('------------------------- JCAR KS_INT_SAP SetCliente - ' + mapAcc.size() + ' Map<ID, Account> ' + mapAcc);
        
        List<KS_Organizacion_Cliente__c> lstOClieUpsert = new List<KS_Organizacion_Cliente__c>();
        
        System.debug('------------------------- JCAR KS_INT_SAP SetCliente - mapAcc LOOP INIT');
        for(String numDeudor : mapAcc.keySet()) {
            System.debug('------------------------- JCAR KS_INT_SAP SetCliente - numDeudor ' + numDeudor);
            
            //// JCAR 2019-01-10, CONTROL ERROR INDETERMINADO AL NO ENCONTRAR YA UN RESULTADO PRECREADO
            Boolean wrong = false;
            KS_INT_GEN.KS_Resultado resultC = new KS_INT_GEN.KS_Resultado();
            if (mapResult.containsKey(numDeudor) && mapResult.get(numDeudor) != null) {
                resultC = mapResult.get(numDeudor);
                System.debug('------------------------- JCAR KS_INT_SAP SetCliente - resultC ' + resultC);
                wrong = resultC.tipo != null && resultC.tipo.contains('E - ');
                if (wrong) {continue;}
            } else {
                resultC.codigo = numDeudor;
                resultC.tipo = 'Cliente Distribuidor';
                resultC.descripcion = '- ¿ERROR? - Número Deudor no procesado correctamente aunque se haya guardado el cliente';
                mapResult.put(resultC.codigo, resultC);
                System.debug('------------------------- JCAR KS_INT_SAP SetCliente - ¿ERROR? resultC ' + resultC);
                lstResult.add(resultC);
            }
            //// JCAR 2019-01-10, CONTROL ERROR INDETERMINADO AL NO ENCONTRAR YA UN RESULTADO PRECREADO

            if(!mapSAP.containsKey(numDeudor)) {continue;}
            if(mapSAP.get(numDeudor)==null) {continue;}
            
            //Recorremos Organizacion Cliente 
            for(KS_INT_GEN.KS_OrganizacionCliente oClie : mapSAP.get(numDeudor).lstOrgClientes) {
               
                KS_INT_GEN.KS_Resultado result = new KS_INT_GEN.KS_Resultado();
                result.descripcion = '';
                KS_Organizacion_Cliente__c orgClie = new KS_Organizacion_Cliente__c();

                if (oClie.KS_Cliente_Dest_Mercancias != null && oClie.KS_Cliente_Dest_Mercancias != numDeudor) {
                    if (mapAcc.containsKey(oClie.KS_Cliente_Dest_Mercancias)) {
                        orgClie.KS_Cliente_Dest_Mercancias__c = mapAcc.get(oClie.KS_Cliente_Dest_Mercancias).ID;
                    } else {
                        result.descripcion += ' ### KS_Cliente_Dest_Mercancias ' + oClie.KS_Cliente_Dest_Mercancias + ' no encontrado';
                        wrong = true;
                    }
                }

                if (oClie.KS_Cliente_solicitante != null && oClie.KS_Cliente_solicitante != numDeudor) {
                    if (mapAcc.containsKey(oClie.KS_Cliente_solicitante)) {
                        orgClie.KS_Cliente_solicitante__c = mapAcc.get(oClie.KS_Cliente_solicitante).ID;
                    } else {
                        result.descripcion += ' ### KS_Cliente_solicitante ' + oClie.KS_Cliente_solicitante + ' no encontrado';
                        wrong = true;
                    }
                }

                Boolean numeroPersonal = oClie.KS_Numero_Personal != null && usrMap.containsKey(oClie.KS_Numero_Personal);
                orgClie.KS_Coordinador__c = numeroPersonal ? usrMap.get(oClie.KS_Numero_Personal) : adminUser.ID;

                orgClie.CurrencyIsoCode = oClie.KS_Moneda;
                orgClie.KS_Sector_Distribuidor__c = oClie.KS_Sector;
                orgClie.KS_Organizacion_de_ventas__c = oClie.KS_Organizacion_de_ventas;
                orgClie.KS_Canal_de_distribucion__c = oClie.KS_Canal_de_distribucion;
                orgClie.KS_Bloqueo_de_entrega_para_cliente__c = oClie.KS_Bloqueo_de_entrega_para_cliente;
                orgClie.KS_Bloqueo_de_factura_para_cliente__c = oClie.KS_Bloqueo_de_factura_para_cliente;
                orgClie.KS_Bloqueo_de_pedido_para_cliente__c = oClie.KS_Bloqueo_de_pedido_para_cliente;
                orgClie.KS_Clasificacion_de_Clientes__c = oClie.KS_Clasificacion_de_Clientes;
                orgClie.KS_Grupo_de_vendedores__c = oClie.KS_Grupo_de_vendedores;
                orgClie.KS_Incoterms_parte_1__c = oClie.KS_Incoterms_parte_1;
                orgClie.KS_Incoterms_parte_2__c = oClie.KS_Incoterms_parte_2;
                orgClie.KS_Oficinas_de_ventas__c = oClie.KS_Oficinas_de_ventas;
                orgClie.KS_Peticion_de_borrado_para_cliente__c = oClie.KS_Peticion_de_borrado_para_cliente != null ? oClie.KS_Peticion_de_borrado_para_cliente : false;
                orgClie.KS_Lista_de_precios__c = oClie.KS_Lista_de_precios;
                orgClie.KS_Bloqueo_contabilizacion_para_sociedad__c = oClie.KS_Bloqueo_contabilizacion_para_sociedad != null ? oClie.KS_Bloqueo_contabilizacion_para_sociedad : false;
                orgClie.KS_Clave_de_condiciones_de_pago__c = oClie.KS_Clave_de_condiciones_de_pago;
                orgClie.KS_Peticion_borrado_para_reg_maestro__c = oClie.KS_Peticion_borrado_para_reg_maestro != null ? oClie.KS_Peticion_borrado_para_reg_maestro : false;
                orgClie.KS_Sociedad__c = oClie.KS_Sociedad;
                
                orgClie.KS_Cliente_Distribucion__c = mapAcc.get(numDeudor).ID;
                
                String idClFnal = null;
                if (oClie.KS_Cliente_Dest_Mercancias == numDeudor)
                { 
                    orgClie.KS_Cliente_Dest_Mercancias__c = mapAcc.get(numDeudor).ID; 
                    idClFnal = mapAcc.get(numDeudor).KS_Id_Salesforce__c;
                }
                else if (oClie.KS_Cliente_Dest_Mercancias != numDeudor && mapAcc.containsKey(oClie.KS_Cliente_Dest_Mercancias)) 
                { 
                    orgClie.KS_Cliente_Dest_Mercancias__c = mapAcc.get(oClie.KS_Cliente_Dest_Mercancias).ID; 
                    idClFnal =  mapAcc.get(oClie.KS_Cliente_Dest_Mercancias).KS_Id_Salesforce__c;
                }
                
                String idSolic = null;
                if (oClie.KS_Cliente_solicitante == numDeudor)
                { 
                    orgClie.KS_Cliente_solicitante__c = mapAcc.get(numDeudor).ID;
                    idSolic = mapAcc.get(numDeudor).KS_Id_Salesforce__c;
                }
                else if (oClie.KS_Cliente_solicitante != numDeudor && mapAcc.containsKey(oClie.KS_Cliente_solicitante)) 
                { 
                    orgClie.KS_Cliente_solicitante__c = mapAcc.get(oClie.KS_Cliente_solicitante).ID;
                    idSolic =  mapAcc.get(oClie.KS_Cliente_solicitante).KS_Id_Salesforce__c;
                }
                
                orgClie.KS_ID_Organizacion_Cliente__c = KS_OrgCliente_Util.buildID(
                    mapAcc.get(numDeudor).KS_Id_Salesforce__c,
                    idClFnal,
                    idSolic,
                    orgClie.KS_Organizacion_de_ventas__c,
                    orgClie.KS_Canal_de_distribucion__c,
                    orgClie.KS_Sector_Distribuidor__c,
                    orgClie.KS_Oficinas_de_ventas__c);
                
                result.codigo = orgClie.KS_ID_Organizacion_Cliente__c;
                if (!wrong) { lstOClieUpsert.add(orgClie); }
                else { 
                    resultC.descripcion = ' ### ERROR en ' + subtipo; 
                    result.tipo = 'E - ' + subtipo; 
                }
                mapResultOrga.put(result.codigo, result);
            }
        }
        System.debug('------------------------- JCAR KS_INT_SAP SetCliente - mapAcc LOOP FINI');

        System.debug('------------------------- JCAR KS_INT_SAP SetCliente - ' + lstOClieUpsert.size() + ' List<KS_Organizacion_Cliente__c> ' + lstOClieUpsert);
        idSAP = KS_Organizacion_Cliente__c.KS_ID_Organizacion_Cliente__c.getDescribe().getSObjectField();
        upsertResult = Database.upsert(lstOClieUpsert, idSAP, false);
        List<KS_INT_GEN.KS_Resultado> lstErrOrgProducto = controlErrorUpsert(upsertResult, subtipo, (List<Object>)lstOClieUpsert, mapResultOrga);
        
        lstResult.addAll(lstErrOrgProducto);
        setResultados(lstResult, 'SetCliente', tipo);
        return lstResult;
    }
    
    ////////////////////////////
    // JERARQUIA DE CLIENTES //
    //////////////////////////
    webservice static List<KS_INT_GEN.KS_Resultado> SetJerarquiaCliente(List<KS_INT_GEN.KS_JerarquiaCliente> lstJerarquiaCliente) {

        Map<String, KS_INT_GEN.KS_Resultado> mapResult = new Map<String, KS_INT_GEN.KS_Resultado>();
        List<KS_INT_GEN.KS_Resultado> lstResult = new List<KS_INT_GEN.KS_Resultado>();
        String tipo = 'Jerarquia de Cliente';        
        
        /*
        //Creamos Mapa de ID Organizacion Clientes donde apuntaran posteriormente las Jerarquias
        Map<String, String> mapIdOrgClieDist = new Map<String, String>();
        for(KS_INT_GEN.KS_JerarquiaCliente jClie : lstJerarquiaCliente) {
            if(!mapIdOrgClieDist.containsKey(jClie.KS_Cliente_distribuidor))
                mapIdOrgClieDist.put(jClie.KS_Cliente_distribuidor + '-' + jClie.KS_Organizacion_de_ventas + jClie.KS_Canal_de_distribucion + jClie.KS_Sector, null);
                
            if(!mapIdOrgClieDist.containsKey(jClie.KS_Cliente_distribuidor_superior))
                mapIdOrgClieDist.put(jClie.KS_Cliente_distribuidor_superior + '-' + jClie.KS_Organizacion_de_ventas + jClie.KS_Canal_de_distribucion + jClie.KS_Sector, null);
        }
        
        //Rellenamos Mapa con los ID SF Cliente que corresponden a los Clientes de las Jerarquias
        for(KS_Organizacion_Cliente__c orgClie : [ select id, KS_ID_Organizacion_Cliente__c from KS_Organizacion_Cliente__c where KS_ID_Organizacion_Cliente__c in :mapIdOrgClieDist.keySet() ]) {
            mapIdOrgClieDist.put(orgClie.KS_ID_Organizacion_Cliente__c, orgClie.Id);
        }*/
        
        Map<String, String> mapClienteSAP = new Map<String, String>();
        
        Set<String> idsapClientes = new Set<String>(); List<String> clientesSAP = new List<String>();
        for (KS_INT_GEN.KS_JerarquiaCliente jc : lstJerarquiaCliente) {
            if ( jc.KS_Cliente_distribuidor != null ) { idsapClientes.add(jc.KS_Cliente_distribuidor); }
            if ( jc.KS_Cliente_distribuidor_superior != null ) { idsapClientes.add(jc.KS_Cliente_distribuidor_superior); }
        }
        clientesSAP.addAll(idsapClientes);
        for(Account acc : [ SELECT ID, KS_ID_SAP__c FROM Account WHERE KS_ID_SAP__c in :clientesSAP]) {
            mapClienteSAP.put(acc.KS_ID_SAP__c, acc.ID);
        }
        
        List<KS_Jerarquia_Cliente__c> lstJClieDist = new List<KS_Jerarquia_Cliente__c>();        
        
        for(KS_INT_GEN.KS_JerarquiaCliente jClie : lstJerarquiaCliente) {
            
            KS_Jerarquia_Cliente__c jClieDist = new KS_Jerarquia_Cliente__c();
            Boolean wrong = false;
            KS_INT_GEN.KS_Resultado result = new KS_INT_GEN.KS_Resultado();
            result.descripcion = '';            
            
            // OJO: Campos obligatorios: KS_Inicio_de_validez_de_la_asignacion__c, KS_Organizacion_Cliente__c, KS_ID_Jerarquia__c
            
            //ID Jerarquia (corresponde a) --> ID SAP Cliente + Org Venta + Canal Dist + Sector + KS_Inicio_de_validez_de_la_asignacion                           
            //jClieDist.KS_ID_Jerarquia__c = jClie.KS_Cliente_distribuidor + '-' + jClie.KS_Organizacion_de_ventas + jClie.KS_Canal_de_distribucion + jClie.KS_Sector + jClie.KS_Inicio_de_validez_de_la_asignacion.format();
            jClieDist.KS_ID_Jerarquia__c = '';
            //String KS_Organizacion_Cliente_KEY = '';
            if (jClie.KS_Cliente_distribuidor != null) {
                
                jClieDist.KS_ID_Jerarquia__c += jClie.KS_Cliente_distribuidor;
                //KS_Organizacion_Cliente_KEY += jClie.KS_Cliente_distribuidor;

            } else {
                result.descripcion += ' ### KS_Cliente_distribuidor no informado';
                wrong = true;
            }
            
            if (jClie.KS_Organizacion_de_ventas != null || jClie.KS_Canal_de_distribucion != null || jClie.KS_Sector != null || jClie.KS_Inicio_de_validez_de_la_asignacion != null) {
                
                /*KS_Organizacion_Cliente_KEY += '-';
                KS_Organizacion_Cliente_KEY += jClie.KS_Organizacion_de_ventas != null ? jClie.KS_Organizacion_de_ventas : '';
                KS_Organizacion_Cliente_KEY += jClie.KS_Canal_de_distribucion != null ? jClie.KS_Canal_de_distribucion : '';
                KS_Organizacion_Cliente_KEY += jClie.KS_Sector != null ? jClie.KS_Sector : '';*/
                
                jClieDist.KS_ID_Jerarquia__c += '-';
                jClieDist.KS_ID_Jerarquia__c += jClie.KS_Organizacion_de_ventas != null ? jClie.KS_Organizacion_de_ventas : '';
                jClieDist.KS_ID_Jerarquia__c += jClie.KS_Canal_de_distribucion != null ? jClie.KS_Canal_de_distribucion : '';
                jClieDist.KS_ID_Jerarquia__c += jClie.KS_Sector != null ? jClie.KS_Sector : '';
                jClieDist.KS_ID_Jerarquia__c += jClie.KS_Inicio_de_validez_de_la_asignacion != null ? jClie.KS_Inicio_de_validez_de_la_asignacion.format() : '';
            }
            
            //jClieDist.KS_Organizacion_Cliente__c = mapIdOrgClieDist.get(jClie.KS_Cliente_distribuidor + '-' + jClie.KS_Organizacion_de_ventas + jClie.KS_Canal_de_distribucion + jClie.KS_Sector); 
            if (jClie.KS_Cliente_distribuidor != null) {
                if (mapClienteSAP.containsKey(jClie.KS_Cliente_distribuidor)) {
                    jClieDist.KS_Cliente__c = mapClienteSAP.get(jClie.KS_Cliente_distribuidor);
                } else {
                    result.descripcion += ' ### KS_Cliente__c ' + jClie.KS_Cliente_distribuidor + ' no encontrado';                
                    wrong = true;
                }
            }
            
            //jClieDist.KS_Organizacion_Cliente_Superior__c = mapIdOrgClieDist.get(jClie.KS_Cliente_distribuidor_superior + '-' + jClie.KS_Organizacion_de_ventas_superior + jClie.KS_Canal_de_distribucion_superior + jClie.KS_Sector_superior);
			/*if (jClie.KS_Cliente_distribuidor_superior != null && jClie.KS_Cliente_distribuidor_superior != '') {
                String KS_Organizacion_Cliente_Superior_KEY = jClie.KS_Cliente_distribuidor_superior + '-';
                
                if (jClie.KS_Organizacion_de_ventas_superior != null || jClie.KS_Canal_de_distribucion_superior != null || jClie.KS_Sector_superior != null) {
                    
                    KS_Organizacion_Cliente_Superior_KEY += '-';
                    KS_Organizacion_Cliente_Superior_KEY += jClie.KS_Organizacion_de_ventas_superior != null ? jClie.KS_Organizacion_de_ventas_superior : '';
                    KS_Organizacion_Cliente_Superior_KEY += jClie.KS_Canal_de_distribucion_superior != null ? jClie.KS_Canal_de_distribucion_superior : '';
                    KS_Organizacion_Cliente_Superior_KEY += jClie.KS_Sector_superior != null ? jClie.KS_Sector_superior : '';
                }                

                if (mapIdOrgClieDist.containsKey(KS_Organizacion_Cliente_Superior_KEY)) {
                    jClieDist.KS_Organizacion_Cliente_Superior__c = mapIdOrgClieDist.get(KS_Organizacion_Cliente_Superior_KEY);
                } else {
                    result.descripcion += ' ### KS_Organizacion_Cliente_Superior ' + KS_Organizacion_Cliente_Superior_KEY + ' no encontrado';                
                    wrong = true;
                }
            }*/        
            if (jClie.KS_Cliente_distribuidor_superior != null) {
                if (mapClienteSAP.containsKey(jClie.KS_Cliente_distribuidor_superior)) {
                    jClieDist.KS_Cliente_Superior__c = mapClienteSAP.get(jClie.KS_Cliente_distribuidor_superior);
                } else {
                    result.descripcion += ' ### KS_Cliente_Superior__c ' + jClie.KS_Cliente_distribuidor_superior + ' no encontrado';                
                    wrong = true;
                }
            }            
            
            jClieDist.KS_Asignacion_de_jerarquia__c = jClie.KS_Asignacion_de_jerarquia;
            jClieDist.KS_Canal_de_distribucion__c = jClie.KS_Canal_de_distribucion;//!=null && jClie.KS_Canal_de_distribucion!='' ? jClie.KS_Canal_de_distribucion : 'null';
            jClieDist.KS_Canal_de_distribucion_superior__c = jClie.KS_Canal_de_distribucion_superior;
            //jClieDist.KS_Cliente_distribuidor__c = mapIdSapClieDist.get(jClie.KS_Cliente_distribuidor);
            jClieDist.KS_Fin_de_validez_de_la_asignacion__c = jClie.KS_Fin_de_validez_de_la_asignacion;
            jClieDist.KS_Inicio_de_validez_de_la_asignacion__c = jClie.KS_Inicio_de_validez_de_la_asignacion;
            //jClieDist.KS_Cliente_distribuidor_superior__c = mapIdSapClieDist.get(jClie.KS_Cliente_distribuidor_superior);
            jClieDist.KS_Organizacion_de_ventas__c = jClie.KS_Organizacion_de_ventas;//!=null && jClie.KS_Organizacion_de_ventas!='' ? jClie.KS_Organizacion_de_ventas : 'null';
            jClieDist.KS_Organizacion_de_ventas_superior__c = jClie.KS_Organizacion_de_ventas_superior;
            jClieDist.KS_Sector__c = jClie.KS_Sector;//!=null && jClie.KS_Sector!='' ? jClie.KS_Sector : 'null';
            jClieDist.KS_Sector_superior__c = jClie.KS_Sector_superior;

            result.codigo = jClieDist.KS_ID_Jerarquia__c;
            if (!wrong) { lstJClieDist.add(jClieDist); }
            else { result.tipo = 'E - ' + tipo; }
            mapResult.put(result.codigo, result);
        }        
       
        Schema.DescribeFieldResult field = KS_Jerarquia_Cliente__c.KS_ID_Jerarquia__c.getDescribe();
        Schema.sObjectField idSAP = field.getSObjectField();
        Database.UpsertResult[] upsertResult = Database.upsert(lstJClieDist, idSAP, false);          
        
        lstResult = controlErrorUpsert(upsertResult, tipo, (List<Object>)lstJClieDist, mapResult);
        setResultados(lstResult, 'SetJerarquiaCliente', tipo);
        return lstResult;        
    }
    
    
    //////////////////////////
    // MATERIAL - PRODUCTO //
    ////////////////////////   
    webservice static List<KS_INT_GEN.KS_Resultado> SetProducto(List<KS_INT_GEN.KS_Producto> lstProducto) {
        
        Map<String, KS_INT_GEN.KS_Resultado> mapResult = new Map<String, KS_INT_GEN.KS_Resultado>();
        Map<String, KS_INT_GEN.KS_Resultado> mapResultOrga = new Map<String, KS_INT_GEN.KS_Resultado>();
        List<KS_INT_GEN.KS_Resultado> lstResult = new List<KS_INT_GEN.KS_Resultado>();
        
        String tipo = 'Producto';
        String subtipo = 'Organizacion Producto';
        
        //Creamos Mapa ID Sap Prodcuto + lista Organizaciones Producto
        Map<String, List<KS_Organizacion_Producto__c>> mapIdSapListOrgProd = new Map<String, List<KS_Organizacion_Producto__c>>();
        
        //Creamos Mapa ID Sap Jerarquia Producto + Id SF Jerarquia Producto 
        Map<String, String> mapIdJProd = new Map<String, String>();
        for(KS_INT_GEN.KS_Producto pr : lstProducto) {
            for(KS_INT_GEN.KS_OrganizacionProducto orgProd : pr.lstOrgProductos) {
                if(orgProd.KS_Jerarquia_Producto != null && !mapIdJProd.containsKey(orgProd.KS_Jerarquia_Producto))
                    mapIdJProd.put(orgProd.KS_Jerarquia_Producto, null);                        
            }
        }
        
        //Rellenamos Mapa con los ID SF Jerarquia Producto que corresponden
        List<String> idSAPjp = new List<String>(); idSAPjp.addAll(mapIdJProd.keySet());
        for(KS_Jerarquia_Producto__c jP : [ select id, KS_Id_SAP__c from KS_Jerarquia_Producto__c where KS_Id_SAP__c in :idSAPjp ]) {
            mapIdJProd.put(jP.KS_Id_SAP__c, jP.Id);
        }                                              
                
        List<Product2> lstProdSF = new List<Product2>();        
        
        for(KS_INT_GEN.KS_Producto pr : lstProducto) {
            
            Boolean wrong = false;
            KS_INT_GEN.KS_Resultado resultP = new KS_INT_GEN.KS_Resultado();
            resultP.descripcion = '';

            Product2 prod = new Product2();
            prod.KS_Id_SAP__c = pr.KS_Numero_de_material;
            prod.KS_Codigo_EAN_Material__c = pr.KS_Codigo_EAN_Material;
            
            prod.Name = pr.KS_Numero_de_material;  
            prod.IsActive = true; 
            prod.KS_Peso_bruto__c = pr.KS_Peso_bruto;
            prod.KS_Peso_neto__c = pr.KS_Peso_neto;            
            prod.KS_Tipo_de_material__c = pr.KS_Tipo_de_material;  

            prod.KS_Nombre_Producto_ES__c = pr.KS_Nombre_Producto_ES;
            prod.KS_Nombre_Producto_EN__c = pr.KS_Nombre_Producto_EN;
            prod.KS_Nombre_Producto_FR__c = pr.KS_Nombre_Producto_FR;
            prod.KS_Nombre_Producto_IT__c = pr.KS_Nombre_Producto_IT;
            prod.KS_Nombre_Producto_DE__c = pr.KS_Nombre_Producto_DE;
            prod.KS_Nombre_Producto_ZH__c = pr.KS_Nombre_Producto_ZH;
            prod.KS_Nombre_Producto_PT__c = pr.KS_Nombre_Producto_PT;
            prod.KS_Nombre_Producto_RU__c = pr.KS_Nombre_Producto_RU;             
            
            prod.KS_Descripcion_corta_ES__c = pr.KS_Descripcion_corta_ES;
            prod.KS_Descripcion_corta_EN__c = pr.KS_Descripcion_corta_EN;
            prod.KS_Descripcion_corta_FR__c = pr.KS_Descripcion_corta_FR;
            prod.KS_Descripcion_corta_IT__c = pr.KS_Descripcion_corta_IT;
            prod.KS_Descripcion_corta_DE__c = pr.KS_Descripcion_corta_DE;
            prod.KS_Descripcion_corta_ZH__c = pr.KS_Descripcion_corta_ZH;
            prod.KS_Descripcion_corta_PT__c = pr.KS_Descripcion_corta_PT;
            prod.KS_Descripcion_corta_RU__c = pr.KS_Descripcion_corta_RU;

            //Recorremos Organizacion Producto 
            mapIdSapListOrgProd.put(pr.KS_Numero_de_material, new List<KS_Organizacion_Producto__c>());
            for(KS_INT_GEN.KS_OrganizacionProducto oProd : pr.lstOrgProductos) {
                
                KS_Organizacion_Producto__c orgProd = new KS_Organizacion_Producto__c();
                KS_INT_GEN.KS_Resultado result = new KS_INT_GEN.KS_Resultado();
                result.descripcion = '';
                
                //ID Organizacion Producto (corresponde a) --> ID SAP Producto + Org Venta + Canal Dist + Sector
                orgProd.KS_ID_Organizacion_Producto__c = pr.KS_Numero_de_material;// + oProd.KS_Organizacion_de_ventas + oProd.KS_Canal_de_distribucion + oProd.KS_Sector;
                if (oProd.KS_Organizacion_de_ventas != null || oProd.KS_Canal_de_distribucion != null || oProd.KS_Sector != null) {
                    
                    orgProd.KS_ID_Organizacion_Producto__c += '-';
                    orgProd.KS_ID_Organizacion_Producto__c += oProd.KS_Organizacion_de_ventas != null ? oProd.KS_Organizacion_de_ventas : '';
                    orgProd.KS_ID_Organizacion_Producto__c += oProd.KS_Canal_de_distribucion != null ? oProd.KS_Canal_de_distribucion : '';
                    orgProd.KS_ID_Organizacion_Producto__c += oProd.KS_Sector != null ? oProd.KS_Sector : '';
                }
                
                //orgProd.KS_Jerarquia_Producto__c = mapIdJProd.get(oProd.KS_Jerarquia_Producto);
                if (oProd.KS_Jerarquia_Producto != null) {
                    if (mapIdJProd.containsKey(oProd.KS_Jerarquia_Producto)) {
                        orgProd.KS_Jerarquia_Producto__c = mapIdJProd.get(oProd.KS_Jerarquia_Producto);
                    } else {
                        result.descripcion += ' ### KS_Jerarquia_Producto ' + oProd.KS_Jerarquia_Producto + ' no encontrado';
                        wrong = true;
                    }
                }
                
                orgProd.KS_Organizacion_de_Ventas__c = oProd.KS_Organizacion_de_Ventas;//!=null && oProd.KS_Organizacion_de_Ventas!='' ? oProd.KS_Organizacion_de_Ventas : 'null'; 
                orgProd.KS_Canal_de_distribucion__c = oProd.KS_Canal_de_distribucion;//!=null && oProd.KS_Canal_de_distribucion!='' ? oProd.KS_Canal_de_distribucion : 'null'; 
                orgProd.KS_Sector__c = oProd.KS_Sector;//!=null && oProd.KS_Sector!='' ? oProd.KS_Sector : 'null';
                
                orgProd.KS_eCatalogo__c = oProd.KS_eCatalogo != null ? oProd.KS_eCatalogo : false;
                orgProd.KS_Estatus_Comercial__c = oProd.KS_Estatus_Comercial;
                orgProd.KS_Fecha_de_validez_Estatus_Comercial__c = oProd.KS_Fecha_de_validez_Estatus_Comercial;
                orgProd.KS_Serie_Gama__c = oProd.KS_Serie_Gama;
                orgProd.KS_Subserie__c = oProd.KS_Subserie;
                orgProd.KS_Familia__c = oProd.KS_Familia;
                orgProd.KS_Superfamilia__c = oProd.KS_Superfamilia;
                orgProd.KS_Unidad_de_entrega__c = oProd.KS_Unidad_de_entrega;
                orgProd.KS_Unidad_medida_de_entrega__c = oProd.KS_Unidad_medida_de_entrega;
                                
                result.codigo = orgProd.KS_ID_Organizacion_Producto__c;
                if (!wrong) { mapIdSapListOrgProd.get(pr.KS_Numero_de_material).add(orgProd); }
                else { 
                    resultP.descripcion = ' ### ERROR en ' + subtipo; 
                    result.tipo = 'E - ' + subtipo; 
                }
                mapResultOrga.put(result.codigo, result);
            }

            resultP.codigo = pr.KS_Numero_de_material;
            if (!wrong) { lstProdSF.add(prod); }
            else { resultP.tipo = 'E - ' + tipo; }
            mapResult.put(resultP.codigo, resultP);
        }
        
        Schema.DescribeFieldResult field = Product2.KS_Id_SAP__c.getDescribe();
        Schema.sObjectField idSAP = field.getSObjectField();
        Database.UpsertResult[] upsertResult = Database.upsert(lstProdSF, idSAP, false);                 
        lstResult = controlErrorUpsert(upsertResult, tipo, (List<Object>)lstProdSF, mapResult);

        //Asignacion de Producto a las Organizaciones Producto
        List<KS_Organizacion_Producto__c> lstOProdFinal = new List<KS_Organizacion_Producto__c>();
        for(Product2 prod : [ select id, KS_Id_SAP__c from product2 where KS_Id_SAP__c in :mapIdSapListOrgProd.keySet() ]) { 
            for(KS_Organizacion_Producto__c oClie : mapIdSapListOrgProd.get(prod.KS_Id_SAP__c)) {
                oClie.KS_Producto__c = prod.id;
                lstOProdFinal.add(oClie);
            }
        }
        
        field = KS_Organizacion_Producto__c.KS_ID_Organizacion_Producto__c.getDescribe();
        idSAP = field.getSObjectField();
        upsertResult = Database.upsert(lstOProdFinal, idSAP, false);          
        List<KS_INT_GEN.KS_Resultado> lstErrOrgProducto = controlErrorUpsert(upsertResult, subtipo, (List<Object>)lstOProdFinal, mapResultOrga);
        
        lstResult.addAll(lstErrOrgProducto);
        setResultados(lstResult, 'SetProducto', tipo);
        return lstResult;
    }
    
    /////////////////////////////
    // JERARQUIA DE PRODUCTOS //
    ///////////////////////////       
    webservice static List<KS_INT_GEN.KS_Resultado> SetJerarquiaProducto(List<KS_INT_GEN.KS_JerarquiaProducto> lstJerarquiaProducto) {
        
        Map<String, KS_INT_GEN.KS_Resultado> mapResult = new Map<String, KS_INT_GEN.KS_Resultado>();
        List<KS_INT_GEN.KS_Resultado> lstResult = new List<KS_INT_GEN.KS_Resultado>();
        String tipo = 'Jerarquia de Producto';
            
        List<KS_Jerarquia_Producto__c> lstJProd = new List<KS_Jerarquia_Producto__c>();        
        
        for(KS_INT_GEN.KS_JerarquiaProducto jp : lstJerarquiaProducto) {
            
            KS_INT_GEN.KS_Resultado result = new KS_INT_GEN.KS_Resultado();
            result.descripcion = '';
            
            KS_Jerarquia_Producto__c jProd = new KS_Jerarquia_Producto__c();
            jProd.KS_Id_SAP__c = jp.KS_Jerarquia_Producto;
            jProd.KS_Numero_Nivel_Jerarquia__c = jp.KS_Numero_Nivel_Jerarquia;
            
            jProd.KS_Denominacion_ES__c = jp.KS_Denominacion_ES;
            jProd.KS_Denominacion_EN__c = jp.KS_Denominacion_EN;
            jProd.KS_Denominacion_FR__c = jp.KS_Denominacion_FR;
            jProd.KS_Denominacion_IT__c = jp.KS_Denominacion_IT;
            jProd.KS_Denominacion_DE__c = jp.KS_Denominacion_DE;
            jProd.KS_Denominacion_ZH__c = jp.KS_Denominacion_ZH;
            jProd.KS_Denominacion_PT__c = jp.KS_Denominacion_PT;
            jProd.KS_Denominacion_RU__c = jp.KS_Denominacion_RU;            
            
            result.codigo = jp.KS_Jerarquia_Producto;
            lstJProd.add(jProd);
            mapResult.put(result.codigo, result);            
        }
       
        Schema.DescribeFieldResult field = KS_Jerarquia_Producto__c.KS_Id_SAP__c.getDescribe();
        Schema.sObjectField idSAP = field.getSObjectField();
        Database.UpsertResult[] upsertResult = Database.upsert(lstJProd, idSAP, false);          
        
        lstResult = controlErrorUpsert(upsertResult, tipo, (List<Object>)lstJProd, mapResult);
        setResultados(lstResult, 'setJerarquiaProducto', tipo);
        return lstResult;
    }
    
      /////////////////////////////
     // CONDICIONES COMERCIALES //
    /////////////////////////////    
    webservice static List<KS_INT_GEN.KS_Resultado> SetCondicionComercial(List<KS_INT_GEN.KS_CondicionComercial> lstCondicionComercial) {
        
        System.debug('-------------------------JCAR - SetCondicionComercial - ENTER');
        Map<String, KS_INT_GEN.KS_Resultado> mapResult = new Map<String, KS_INT_GEN.KS_Resultado>();
        List<KS_INT_GEN.KS_Resultado> lstResult = new List<KS_INT_GEN.KS_Resultado>();
        String tipo = 'Condición Comercial';
        
        // DELETE DÍA ANTERIOR
        System.debug('-------------------------JCAR - Llamamos al método @future "deleteCondicionesComerciales"');
        //deleteCondicionesComerciales(); // A partir de ahora será UPSERT
        
        // INSERT
        List<KS_Condicion_Comercial__c> lstConCom = new List<KS_Condicion_Comercial__c>();     
        // Pueden llegar 5k><10k entradas que guardar. SF tiene un max de 50k, creo.
        // Procedimiento: Recogemos las CondicionesComerciales y listamos sus "lookup".
        Set<String> idsapJerCli = new Set<String>();// KS_Cliente_Jerarquia__c = KS_Jerarquia_Cliente__c.KS_ID_Jerarquia__c > Account?
        Set<String> idsapNumMat = new Set<String>();// KS_Material__c = Product2.KS_Id_SAP__c
        Set<String> idsapJerPro = new Set<String>();// KS_PRODH1__c, KS_Jerarquia_Producto__c.KS_Id_SAP__c
        for (KS_INT_GEN.KS_CondicionComercial conComSAP : lstCondicionComercial) {
            if (conComSAP.KS_Cliente != null && !idsapJerCli.contains(conComSAP.KS_Cliente)) { idsapJerCli.add(conComSAP.KS_Cliente); }
            if (conComSAP.KS_NumeroMaterial != null && !idsapNumMat.contains(conComSAP.KS_NumeroMaterial)) { idsapNumMat.add(conComSAP.KS_NumeroMaterial); }
            if (conComSAP.KS_JerarquiaProducto1 != null && !idsapJerPro.contains(conComSAP.KS_JerarquiaProducto1)) { idsapJerPro.add(conComSAP.KS_JerarquiaProducto1); }
            if (conComSAP.KS_JerarquiaProducto2 != null && !idsapJerPro.contains(conComSAP.KS_JerarquiaProducto2)) { idsapJerPro.add(conComSAP.KS_JerarquiaProducto2); } 
            if (conComSAP.KS_JerarquiaProducto3 != null && !idsapJerPro.contains(conComSAP.KS_JerarquiaProducto3)) { idsapJerPro.add(conComSAP.KS_JerarquiaProducto3); }
            if (conComSAP.KS_JerarquiaProducto4 != null && !idsapJerPro.contains(conComSAP.KS_JerarquiaProducto4)) { idsapJerPro.add(conComSAP.KS_JerarquiaProducto4); }             
        }
        
        //jClieDist.KS_ID_Jerarquia__c = jClie.KS_Cliente_distribuidor + '-' + jClie.KS_Organizacion_de_ventas + jClie.KS_Canal_de_distribucion + jClie.KS_Sector + jClie.KS_Inicio_de_validez_de_la_asignacion.format();
        
        System.debug('-------------------------JCAR - SetCondicionComercial - idsapJerCli '+idsapJerCli);
        System.debug('-------------------------JCAR - SetCondicionComercial - idsapNumMat '+idsapNumMat);
        System.debug('-------------------------JCAR - SetCondicionComercial - idsapJerPro '+idsapJerPro);
        // Buscamos en cada tabla correspondiendo las IDs
        /*List<KS_Jerarquia_Cliente__c> sfJerCli = [SELECT ID, KS_ID_Jerarquia__c, KS_Organizacion_Cliente__c, KS_Organizacion_Cliente__r.KS_Cliente_Distribucion__c
                                                 FROM KS_Jerarquia_Cliente__c WHERE KS_ID_Jerarquia__c IN :idsapJerCli];*/
        List<Account> sfJerCli = [SELECT ID, KS_Id_SAP__c FROM Account WHERE KS_Id_SAP__c IN :idsapJerCli];
        List<Product2> sfNumMat = [SELECT ID, KS_Id_SAP__c FROM Product2 WHERE KS_Id_SAP__c IN :idsapNumMat];
        List<KS_Jerarquia_Producto__c> sfJerPro = [SELECT ID, KS_Id_SAP__c FROM KS_Jerarquia_Producto__c WHERE KS_Id_SAP__c IN :idsapJerPro];
        
        System.debug('-------------------------JCAR - SetCondicionComercial - sfJerCli '+sfJerCli);
        System.debug('-------------------------JCAR - SetCondicionComercial - sfNumMat '+sfNumMat);
        System.debug('-------------------------JCAR - SetCondicionComercial - sfJerPro '+sfJerPro);
        
        // y meapeamos con las IDs SF.
        Map<String, ID> mapJerCli = new Map<String, ID>();
        Map<String, ID> mapNumMat = new Map<String, ID>();
        Map<String, ID> mapJerPro = new Map<String, ID>();
        
        //for (KS_Jerarquia_Cliente__c jerCli : sfJerCli) { mapJerCli.put(jerCli.KS_ID_Jerarquia__c, jerCli.KS_Organizacion_Cliente__r.KS_Cliente_Distribucion__c); }
        for (Account jerCli : sfJerCli) { mapJerCli.put(jerCli.KS_Id_SAP__c, jerCli.ID); }
        for (Product2 numMat : sfNumMat) { mapNumMat.put(numMat.KS_Id_SAP__c, numMat.ID); }
        for (KS_Jerarquia_Producto__c jerPro : sfJerPro) { mapJerPro.put(jerPro.KS_Id_SAP__c, jerPro.ID); }
        
        System.debug('-------------------------JCAR - SetCondicionComercial - mapJerCli '+mapJerCli);
        System.debug('-------------------------JCAR - SetCondicionComercial - mapNumMat '+mapNumMat);
        System.debug('-------------------------JCAR - SetCondicionComercial - mapJerPro '+mapJerPro);
        
        // Instanciamos objetos KS_Condicion_Comercial__c.
        Integer x = 0; // Para hacer debug, solamente se hará en el primer objeto
        for (KS_INT_GEN.KS_CondicionComercial conComSAP : lstCondicionComercial) {
            
            KS_Condicion_Comercial__c conCom = new KS_Condicion_Comercial__c();
            Boolean wrong = false;
            KS_INT_GEN.KS_Resultado result = new KS_INT_GEN.KS_Resultado();
            result.descripcion = '';
            
            String idCondicionComercial = '';
            // KS_Condicion - KS_Organizacion_Ventas KS_Canal KS_Sector KS_Tarifa 
            // - KS_Cliente - KS_NumeroMaterial - KS_JerarquiaProducto1 - KS_JerarquiaProducto2- KS_JerarquiaProducto3 - KS_JerarquiaProducto4 
            // - KS_Serie KS_Subserie KS_Familia - KS_Pais

            if (conComSAP.KS_Condicion != null && conComSAP.KS_Condicion != '') {

                idCondicionComercial = conComSAP.KS_Condicion;
                conCom.KS_Condicion__c = conComSAP.KS_Condicion;  // picklist
            }
            
            if (conComSAP.KS_Organizacion_Ventas != null && conComSAP.KS_Organizacion_Ventas != '') {
                
                if (conComSAP.KS_Condicion != null && conComSAP.KS_Condicion != '') {
                    idCondicionComercial += '-';
                }
                
                idCondicionComercial += conComSAP.KS_Organizacion_Ventas;
                conCom.KS_Organizacion_Ventas__c = conComSAP.KS_Organizacion_Ventas;  // picklist
                
            } else {
                result.tipo = 'E - ' + tipo;
                result.descripcion += ' ### KS_Organizacion_Ventas no informado';
                wrong = true;
            }
            
            if (conComSAP.KS_Canal != null && conComSAP.KS_Canal != '') {

                idCondicionComercial += conComSAP.KS_Canal;
                conCom.KS_Canal__c = conComSAP.KS_Canal;  // picklist
            }
            
            if (conComSAP.KS_Sector != null && conComSAP.KS_Sector != '') {

                idCondicionComercial += conComSAP.KS_Sector;
                conCom.KS_Sector__c = conComSAP.KS_Sector;  // picklist
            }            
            
            if (conComSAP.KS_Tarifa != null && conComSAP.KS_Tarifa != '') {

                idCondicionComercial += conComSAP.KS_Tarifa;
                conCom.KS_Tarifa__c = conComSAP.KS_Tarifa;  // picklist
            }
            
            if (conComSAP.KS_Cliente != null) {

                if (mapJerCli.containsKey(conComSAP.KS_Cliente)) {
                    conCom.KS_Cliente_Jerarquia__c = mapJerCli.get(conComSAP.KS_Cliente);} //> Account
                else {
                    result.tipo = 'E - ' + tipo;
                    result.descripcion += ' ### KS_Cliente ' + conComSAP.KS_Cliente + ' no encontrado';                
                    wrong = true;
                }
                idCondicionComercial += '-' + conComSAP.KS_Cliente;
            } else {
                idCondicionComercial += '-000';
            }

            if (conComSAP.KS_NumeroMaterial != null) {
                if (conComSAP.KS_NumeroMaterial != null && mapNumMat.containsKey(conComSAP.KS_NumeroMaterial)) {
                    conCom.KS_Material__c = mapNumMat.get(conComSAP.KS_NumeroMaterial);} // KS_Material__c = Product2.KS_Id_SAP__c
                else {
                    result.tipo = 'E - ' + tipo;
                    result.descripcion += ' ### KS_NumeroMaterial ' + conComSAP.KS_NumeroMaterial + ' no encontrado';                
                    wrong = true;
                }
                idCondicionComercial += '-' + conComSAP.KS_NumeroMaterial;
            } else {
                idCondicionComercial += '-000';
            }
            
            if (conComSAP.KS_JerarquiaProducto1 != null) {
                if (conComSAP.KS_JerarquiaProducto1 != null && mapJerPro.containsKey(conComSAP.KS_JerarquiaProducto1)) {
                    conCom.KS_PRODH1__c = mapJerPro.get(conComSAP.KS_JerarquiaProducto1);} // KS_PRODH1__c, KS_Jerarquia_Producto__c.KS_Id_SAP__c
                else {
                    result.tipo = 'E - ' + tipo;
                    result.descripcion += ' ### KS_JerarquiaProducto1 ' + conComSAP.KS_JerarquiaProducto1 + ' no encontrado';                
                    wrong = true;
                }
                idCondicionComercial += '-' + conComSAP.KS_JerarquiaProducto1;
            } else {
                idCondicionComercial += '-000';
            }
            
            if (conComSAP.KS_JerarquiaProducto2 != null) {
                if (conComSAP.KS_JerarquiaProducto2 != null && mapJerPro.containsKey(conComSAP.KS_JerarquiaProducto2)) {
                    conCom.KS_PRODH2__c = mapJerPro.get(conComSAP.KS_JerarquiaProducto2);} // KS_PRODH2__c, KS_Jerarquia_Producto__c.KS_Id_SAP__c
                else {
                    result.tipo = 'E - ' + tipo;
                    result.descripcion += ' ### KS_JerarquiaProducto2 ' + conComSAP.KS_JerarquiaProducto2 + ' no encontrado';                
                    wrong = true;
                }
                idCondicionComercial += '-' + conComSAP.KS_JerarquiaProducto2;
            } else {
                idCondicionComercial += '-000';
            }
            
            if (conComSAP.KS_JerarquiaProducto3 != null) {
                if (conComSAP.KS_JerarquiaProducto3 != null && mapJerPro.containsKey(conComSAP.KS_JerarquiaProducto3)) {
                    conCom.KS_PRODH3__c = mapJerPro.get(conComSAP.KS_JerarquiaProducto3);} // KS_PRODH3__c, KS_Jerarquia_Producto__c.KS_Id_SAP__c
                else {
                    result.tipo = 'E - ' + tipo;
                    result.descripcion += ' ### KS_JerarquiaProducto3 ' + conComSAP.KS_JerarquiaProducto3 + ' no encontrado';                
                    wrong = true;
                }
                idCondicionComercial += '-' + conComSAP.KS_JerarquiaProducto3;
            } else {
                idCondicionComercial += '-000';
            }
            
            if (conComSAP.KS_JerarquiaProducto4 != null) {
                if (conComSAP.KS_JerarquiaProducto4 != null && mapJerPro.containsKey(conComSAP.KS_JerarquiaProducto4)) {
                    conCom.KS_PRODH4__c = mapJerPro.get(conComSAP.KS_JerarquiaProducto4);} // KS_PRODH4__c, KS_Jerarquia_Producto__c.KS_Id_SAP__c
                else {
                    result.tipo = 'E - ' + tipo;
                    result.descripcion += ' ### KS_JerarquiaProducto4 ' + conComSAP.KS_JerarquiaProducto4 + ' no encontrado';                
                    wrong = true;
                }
                idCondicionComercial += '-' + conComSAP.KS_JerarquiaProducto4;
            } else {
                idCondicionComercial += '-000';
            }
            
            if (conComSAP.KS_Serie != null || conComSAP.KS_Subserie != null || conComSAP.KS_Familia != null) {
                
                String serieFamilia = conComSAP.KS_Serie != null ? conComSAP.KS_Serie : '000';
                serieFamilia += conComSAP.KS_Subserie != null ? conComSAP.KS_Subserie : '000';
                serieFamilia += conComSAP.KS_Familia != null ? conComSAP.KS_Familia : '000';
                idCondicionComercial += (serieFamilia != '' ? '-'+serieFamilia : '');
                
                conCom.KS_Serie_single__c = conComSAP.KS_Serie;  // picklist
                conCom.KS_Subserie__c = conComSAP.KS_Subserie;  // picklist
                conCom.KS_Familia__c = conComSAP.KS_Familia;  // picklist
            
            } else {
                
                idCondicionComercial += '-000000000';
            }
            
            if (conComSAP.KS_Pais != null && conComSAP.KS_Pais != '') {

                idCondicionComercial += '-'+conComSAP.KS_Pais;
                conCom.KS_CountryCode__c = conComSAP.KS_Pais;  // picklist
            
            } else {
                
                idCondicionComercial += '-00';
            }
            
            conCom.KS_Cantidad_Base__c = conComSAP.KS_Cantidad_Base; // número
            conCom.KS_Escala_Importe__c = conComSAP.KS_Escala_Importe; // divisa
            conCom.KS_Escala_Unidades__c = conComSAP.KS_Escala_Unidades; // número
            conCom.KS_Fecha_Fin__c = conComSAP.KS_Fecha_Fin; // fecha
            conCom.KS_Fecha_Inicio__c = conComSAP.KS_Fecha_Inicio; // fecha
            conCom.KS_Importe__c = conComSAP.KS_Importe;  // divisa
            conCom.KS_Porcentaje__c = conComSAP.KS_Porcentaje != null ? conComSAP.KS_Porcentaje*-1 : 0; // porcentaje
            
            // condicion - orgventas canal sector tarifa - cliente - material - jp1 - jp2 - jp3 - jp4 - serie subserie familia
            conCOm.KS_ID_condicion_comercial__c = idCondicionComercial;
            result.codigo = conCOm.KS_ID_condicion_comercial__c;
            if (!wrong) { lstConCom.add(conCom); }
            mapResult.put(result.codigo, result);
            x++;
        }
        System.debug('-------------------------JCAR - SetCondicionComercial - lstConCom ' + lstConCom);
        
        // INSERT
        //Database.SaveResult[] insertResult = Database.insert(lstConCom, false);
        Schema.DescribeFieldResult field = KS_Condicion_Comercial__c.KS_ID_condicion_comercial__c.getDescribe();
        Schema.sObjectField idSAP = field.getSObjectField();
        Database.UpsertResult[] upsertResult = Database.upsert(lstConCom, idSAP, false);
		System.debug('-------------------------JCAR - SetCondicionComercial - upsertResult ' + upsertResult);

        //lstResult = controlErrorInsert(insertResult, tipo, (List<Object>)lstConCom, mapResult);
        lstResult = controlErrorUpsert(upsertResult, tipo, (List<Object>)lstConCom, mapResult);
        setResultados(lstResult, 'setCondicionComercial', tipo);
        return lstResult;
    }
    
    public static void deleteCondicionesComerciales() {
                
        Datetime dt = Datetime.now().addDays(-1);
        System.debug('-------------------------JCAR - DELETE Condiciones Comerciales de ' + dt.format() + ' o anterior.');
        
        String q = 'SELECT ID FROM KS_Condicion_Comercial__c WHERE CreatedDate <= ' + dt.format('YYYY-MM-dd\'T\'kk:mm:ss')+'.000+0000';
        String e = 'KS_Condicion_Comercial__c';
        Id batchInstanceId = Database.executeBatch(new KS_Batch_CondicionesComerciales_Delete(q,e,'',''), 5000);

        System.debug('-------------------------JCAR - DELETE BATCH CON ID' + batchInstanceId);
    }
    
    webservice static List<KS_INT_GEN.KS_Resultado> SetPedidos(List<KS_INT_GEN.KS_Pedido> lstPedidoSAP) {
        
        Map<String, KS_INT_GEN.KS_Resultado> mapResult = new Map<String, KS_INT_GEN.KS_Resultado>();
        List<KS_INT_GEN.KS_Resultado> lstResult = new List<KS_INT_GEN.KS_Resultado>();
        String tipo = 'Pedido';
        
        Set<String> accSet = new Set<String>(); 
        Set<String> oppSet = new Set<String>();
        Set<String> usrSet = new Set<String>();
        // Mapeo de cuentas && mapeo de oportunidades && mapeo usuarios
        for (KS_INT_GEN.KS_Pedido pedido : lstPedidoSAP) {
            
            if (!accSet.contains(pedido.KS_Solicitante)) { accSet.add(pedido.KS_Solicitante); }
            if (!oppSet.contains(pedido.KS_Oferta)) { oppSet.add(pedido.KS_Oferta); }
            if (!usrSet.contains(pedido.KS_Numero_Personal)) { usrSet.add(pedido.KS_Numero_Personal); }
            //if (!oppSet.contains(pedido.KS_Oferta_CRM)) { oppSet.add(pedido.KS_Oferta); }
        }
        
        Map<String,String> accMAP = new Map<String,String>();
        Map<String,Opportunity> oppMAP = new Map<String,Opportunity>();
        Map<String,Id> usrMAP = new Map<String,Id>();
        User adminUser = new User();
        
        List<String> accSAP = new List<String>(); accSAP.addAll(accSet);
        for (Account acc : [SELECT ID,KS_Id_SAP__c FROM Account WHERE KS_Id_SAP__c IN :accSAP] ) {
            accMAP.put(acc.KS_Id_SAP__c, acc.ID);
        }
        List<String> oppSAP = new List<String>(); oppSAP.addAll(oppSet);
        for (Opportunity opp : [SELECT ID,KS_Oferta_ID__c,KS_Obra__c FROM Opportunity WHERE KS_Oferta_ID__c IN :oppSAP] ) {
            oppMAP.put(opp.KS_Oferta_ID__c, opp);
        }
        
        List<String> usrSAP = new List<String>(); usrSAP.addAll(usrSet);
        for (User usr : [SELECT ID,KS_IDSAP__c,Alias FROM User WHERE (KS_IDSAP__c IN :usrSAP OR Alias = 'asimo') AND isActive = true] ) {
            if (usr.Alias == 'asimo') {
            	adminUser = usr;
            } else {
                usrMAP.put(usr.KS_IDSAP__c, usr.ID);
            }
        }
        
        // Set SAP2SF
        List<KS_Pedido__c> lstPedidos = new List<KS_Pedido__c>();
        for (KS_INT_GEN.KS_Pedido pedidoSAP : lstPedidoSAP) {
            
            Boolean wrong = false;
            KS_Pedido__c pedido = new KS_Pedido__c();
            KS_INT_GEN.KS_Resultado result = new KS_INT_GEN.KS_Resultado();
            result.descripcion = '';
            
            result.codigo = pedidoSAP.KS_Documento_de_ventas;
            pedido.KS_Numero_Pedido__c = pedidoSAP.KS_Documento_de_ventas;
            pedido.KS_Documento_de_ventas__c = pedidoSAP.KS_Documento_de_ventas;
			//pedido.Name = pedido.KS_Numero_Pedido__c;
            
            // LOOKUP ACCOUNT   
            if (pedidoSAP.KS_Solicitante != null) {
                if (accMAP.containsKey(pedidoSAP.KS_Solicitante)) {
                    pedido.KS_Solicitante__c = accMAP.get(pedidoSAP.KS_Solicitante);
                } else {
                    result.tipo = 'E - ' + tipo;
                    result.descripcion += ' ### KS_Solicitante ' + pedidoSAP.KS_Solicitante + ' no encontrado';
                    wrong = true;
                }   

            } else {
                result.tipo = 'E - ' + tipo;
                result.descripcion += ' ### KS_Solicitante no informado';
                wrong = true;
            }

            // LOOKUP OPPORTUNITY
            if (pedidoSAP.KS_Oferta != null) {
                if (oppMAP.containsKey(pedidoSAP.KS_Oferta)) {
                    pedido.KS_Oferta__c = oppMAP.get(pedidoSAP.KS_Oferta).ID;
                    pedido.KS_Obra__c = oppMAP.get(pedidoSAP.KS_Oferta).KS_Obra__c;
                } else {
                    /*
                    result.tipo = 'E - ' + tipo;
                    result.descripcion += ' ### KS_Oferta ' + pedidoSAP.KS_Oferta + ' no encontrado';
                    wrong = true;
					*/
                    pedido.KS_Oferta_CRM__c = pedidoSAP.KS_Oferta;
                }
            }

            pedido.KS_Numero_Personal__c = pedidoSAP.KS_Numero_Personal;
            Boolean numeroPersonal = pedidoSAP.KS_Numero_Personal != null && usrMap.containsKey(pedidoSAP.KS_Numero_Personal);
            pedido.OwnerId = numeroPersonal ? usrMap.get(pedidoSAP.KS_Numero_Personal) : adminUser.ID;

            pedido.KS_Numero_de_pedido_del_cliente__c = pedidoSAP.KS_Numero_de_pedido_del_cliente;
            pedido.KS_Fecha_creacion_registro_en_SAP__c = pedidoSAP.KS_Fecha_creacion_registro_en_SAP;
            pedido.KS_Hora_registrada__c = pedidoSAP.KS_Hora_registrada;
            pedido.KS_Nombre_del_responsable__c = pedidoSAP.KS_Nombre_del_responsable;
            pedido.KS_Clase_de_documento_de_ventas__c = pedidoSAP.KS_Clase_de_documento_de_ventas;
            pedido.KS_Motivo_de_pedido__c = pedidoSAP.KS_Motivo_de_pedido;
            pedido.KS_Bloqueo_de_nota_de_entrega__c = pedidoSAP.KS_Bloqueo_de_nota_de_entrega;
            pedido.KS_Bloqueo_de_clases_de_facturas__c = pedidoSAP.KS_Bloqueo_de_clases_de_facturas;
            pedido.KS_Valor_neto_del_pedido__c = pedidoSAP.KS_Valor_neto_del_pedido;
            pedido.CurrencyIsoCode = pedidoSAP.CurrencyIsoCode;
            pedido.KS_Organizacion_de_ventas__c = pedidoSAP.KS_Organizacion_de_ventas;
            pedido.KS_Canal_de_distribucion__c = pedidoSAP.KS_Canal_de_distribucion;
            pedido.KS_Sector__C = pedidoSAP.KS_Sector;
            pedido.KS_Grupo_de_vendedores__c = pedidoSAP.KS_Grupo_de_vendedores;
            pedido.KS_Oficina_de_ventas__c = pedidoSAP.KS_Oficina_de_ventas;
            pedido.KS_Fecha_preferente_de_entrega__c = pedidoSAP.KS_Fecha_preferente_de_entrega;
            pedido.KS_Condicion_de_expedicion__c = pedidoSAP.KS_Condicion_de_expedicion;
            pedido.KS_Clase_de_pedido_de_cliente__c = pedidoSAP.KS_Clase_de_pedido_de_cliente;
            pedido.KS_Fecha_del_pedido_de_compras_cliente__c = pedidoSAP.KS_Fecha_del_pedido_de_compras_cliente;
            pedido.KS_Destinatario__c = pedidoSAP.KS_Destinatario;
            pedido.KS_Resp_Pago__c = pedidoSAP.KS_Resp_Pago;
            pedido.KS_Dest_Factura__c = pedidoSAP.KS_Dest_Factura;
            pedido.KS_Vendedor__c = pedidoSAP.KS_Vendedor;
            pedido.KS_Comisionista__c = pedidoSAP.KS_Comisionista;
            pedido.KS_Nombre_de_usuario__c = pedidoSAP.KS_Nombre_de_usuario;
            pedido.KS_Hora_del_dia__c = pedidoSAP.KS_Hora_del_dia;
            pedido.KS_Numero_de_ticket_Attend__c = pedidoSAP.KS_Numero_de_ticket_Attend;
            
            pedido.KS_Estado__c = pedidoSAP.KS_Estado;
            
            pedido.KS_Fecha__c = pedidoSAP.KS_Fecha != null ? pedidoSAP.KS_Fecha : Date.today();
            //pedido.EffectiveDate = pedidoSAP.KS_Fecha != null ? pedidoSAP.KS_Fecha : Date.today();

            if (!wrong) { lstPedidos.add(pedido); }
            mapResult.put(result.codigo, result);
        }

        Schema.DescribeFieldResult field = KS_Pedido__c.KS_Numero_Pedido__c.getDescribe();
        Schema.sObjectField idSAP = field.getSObjectField();
        Database.UpsertResult[] upsertResult = Database.upsert(lstPedidos, idSAP, false);          
        
        lstResult = controlErrorUpsert(upsertResult, tipo, (List<Object>)lstPedidos, mapResult);
        setResultados(lstResult, 'setPedidos', tipo);
        return lstResult;
    }
    webservice static List<KS_INT_GEN.KS_Resultado> SetEntregas(List<KS_INT_GEN.KS_Entrega> lstEntregaSAP) {
        
        Map<String, KS_INT_GEN.KS_Resultado> mapResult = new Map<String, KS_INT_GEN.KS_Resultado>();
        List<KS_INT_GEN.KS_Resultado> lstResult = new List<KS_INT_GEN.KS_Resultado>();
        String tipo = 'Entrega';
        
        Set<String> accSet = new Set<String>();
        Set<String> usrSet = new Set<String>();
        
        // Mapeo de cuentas && users
        for (KS_INT_GEN.KS_Entrega entregaSAP : lstEntregaSAP) {
            if (!accSet.contains(entregaSAP.KS_Solicitante)) { accSet.add(entregaSAP.KS_Solicitante); }
            if (!usrSet.contains(entregaSAP.KS_Numero_Personal)) { usrSet.add(entregaSAP.KS_Numero_Personal); }
        }
        
        Map<String,String> accMAP = new Map<String,String>(); 
        Map<String,Id> usrMAP = new Map<String,Id>();
        User adminUser = new User();        
        
        List<String> accSAP = new List<String>(); accSAP.addAll(accSet);
        for (Account acc : [SELECT ID,KS_Id_SAP__c FROM Account WHERE KS_Id_SAP__c IN :accSAP] ) {
            accMAP.put(acc.KS_Id_SAP__c, acc.ID);
        }
        
        List<String> usrSAP = new List<String>(); usrSAP.addAll(usrSet);
        for (User usr : [SELECT ID,KS_IDSAP__c,Alias FROM User WHERE (KS_IDSAP__c IN :usrSAP OR Alias = 'asimo') AND isActive = true] ) {
            if (usr.Alias == 'asimo') {
            	adminUser = usr;
            } else {
                usrMAP.put(usr.KS_IDSAP__c, usr.ID);
            }
        }        
        
        // Set SAP2SF
        List<KS_Entrega__c> lstEntregas = new List<KS_Entrega__c>();
        for (KS_INT_GEN.KS_Entrega entregaSAP : lstEntregaSAP) {
            
            Boolean wrong = false;
            KS_Entrega__c entrega = new KS_Entrega__c();
            KS_INT_GEN.KS_Resultado result = new KS_INT_GEN.KS_Resultado();
            result.descripcion = '';
            
            result.codigo = entregaSAP.KS_Numero_Entrega;
            entrega.Name = entregaSAP.KS_Numero_Entrega;
            entrega.KS_Numero_Entrega__c = entregaSAP.KS_Numero_Entrega;
            
            // LOOKUP ACCOUNT   
            if (entregaSAP.KS_Solicitante != null) {
                if (accMAP.containsKey(entregaSAP.KS_Solicitante)) {
                    entrega.KS_Solicitante__c = accMAP.get(entregaSAP.KS_Solicitante);
                } else {
                    result.tipo = 'E - ' + tipo;
                    result.descripcion += ' ### KS_Solicitante ' + entregaSAP.KS_Solicitante + ' no encontrado';
                    wrong = true;
                }

            } else {
                result.tipo = 'E - ' + tipo;
                result.descripcion += ' ### KS_Solicitante no informado';
                wrong = true;
            }            
            
            entrega.KS_Numero_Personal__c = entregaSAP.KS_Numero_Personal;
            Boolean numeroPersonal = entregaSAP.KS_Numero_Personal != null && usrMap.containsKey(entregaSAP.KS_Numero_Personal);
            entrega.OwnerId = numeroPersonal ? usrMap.get(entregaSAP.KS_Numero_Personal) : adminUser.ID;
            
            entrega.KS_Fecha_de_creacion_del_registro__c = entregaSAP.KS_Fecha_de_creacion_del_registro;
            entrega.KS_Hora_registrada__c = entregaSAP.KS_Hora_registrada;
            entrega.KS_Organizacion_de_ventas__c = entregaSAP.KS_Organizacion_de_ventas;
            entrega.KS_Clase_de_entrega__c = entregaSAP.KS_Clase_de_entrega;
            entrega.KS_Entrega_completa_por_pedido__c = entregaSAP.KS_Entrega_completa_por_pedido;
            entrega.KS_Fecha_de_entrega__c = entregaSAP.KS_Fecha_de_entrega;
            entrega.KS_Fecha_prevista_para_movimiento__c = entregaSAP.KS_Fecha_prevista_para_movimiento;
            entrega.KS_Fecha_movimiento_de_mercancias_real__c = entregaSAP.KS_Fecha_movimiento_de_mercancias_real;
            entrega.KS_Incoterms_parte_1__C = entregaSAP.KS_Incoterms_parte_1;
            entrega.KS_Incoterms_parte_2__c = entregaSAP.KS_Incoterms_parte_2;
            entrega.KS_Prioridad_de_entrega__c = entregaSAP.KS_Prioridad_de_entrega;
            entrega.KS_Condicion_de_expedicion__c = entregaSAP.KS_Condicion_de_expedicion;
            entrega.KS_Destinatario__c = entregaSAP.KS_Destinatario;
            entrega.KS_Transportista__c = entregaSAP.KS_Transportista;
            entrega.KS_Peso_total__c = entregaSAP.KS_Peso_total;
            entrega.KS_Peso_neto__c = entregaSAP.KS_Peso_neto;
            entrega.KS_Unidad_de_peso__c = entregaSAP.KS_Unidad_de_peso;
            entrega.KS_Volumen__c = entregaSAP.KS_Volumen;
            entrega.KS_Unidad_de_volumen__c = entregaSAP.KS_Unidad_de_volumen;
            entrega.KS_Cantidad_total_de_bultos_de_entrega__c = entregaSAP.KS_Cantidad_total_de_bultos_de_entrega;
            entrega.KS_Estado__c = entregaSAP.KS_Estado;
            
            if (!wrong) { lstEntregas.add(entrega); }
            mapResult.put(result.codigo, result);
        }

        Schema.DescribeFieldResult field = KS_Entrega__c.KS_Numero_entrega__c.getDescribe();
        Schema.sObjectField idSAP = field.getSObjectField();
        Database.UpsertResult[] upsertResult = Database.upsert(lstEntregas, idSAP, false);          
        
        lstResult = controlErrorUpsert(upsertResult, tipo, (List<Object>)lstEntregas, mapResult);
        setResultados(lstResult, 'setEntregas', tipo);
        return lstResult;
    }
    webservice static List<KS_INT_GEN.KS_Resultado> SetFacturas(List<KS_INT_GEN.KS_Factura> lstFacturaSAP) {
        
        Map<String, KS_INT_GEN.KS_Resultado> mapResult = new Map<String, KS_INT_GEN.KS_Resultado>();
        List<KS_INT_GEN.KS_Resultado> lstResult = new List<KS_INT_GEN.KS_Resultado>();
        String tipo = 'Factura';
        
        Set<String> accSet = new Set<String>();
        Set<String> usrSet = new Set<String>();
        
        // Mapeo de cuentas && users
        for (KS_INT_GEN.KS_Factura facturaSAP : lstFacturaSAP) {
            if (!accSet.contains(facturaSAP.KS_Solicitante)) { accSet.add(facturaSAP.KS_Solicitante); }
            if (!usrSet.contains(facturaSAP.KS_Numero_Personal)) { usrSet.add(facturaSAP.KS_Numero_Personal); }
        }
        
        Map<String,String> accMAP = new Map<String,String>(); 
        Map<String,Id> usrMAP = new Map<String,Id>();
        User adminUser = new User();        
        
        List<String> accSAP = new List<String>(); accSAP.addAll(accSet);
        for (Account acc : [SELECT ID,KS_Id_SAP__c FROM Account WHERE KS_Id_SAP__c IN :accSAP] ) {
            accMAP.put(acc.KS_Id_SAP__c, acc.ID);
        }
        
        List<String> usrSAP = new List<String>(); usrSAP.addAll(usrSet);
        for (User usr : [SELECT ID,KS_IDSAP__c,Alias FROM User WHERE (KS_IDSAP__c IN :usrSAP OR Alias = 'asimo') AND isActive = true] ) {
            if (usr.Alias == 'asimo') {
            	adminUser = usr;
            } else {
                usrMAP.put(usr.KS_IDSAP__c, usr.ID);
            }
        } 
        
        // Set SAP2SF
        List<KS_Factura__c> lstfacturas = new List<KS_Factura__c>();
        for (KS_INT_GEN.KS_Factura facturaSAP : lstFacturaSAP) {
            
            Boolean wrong = false;
            KS_Factura__c factura = new KS_Factura__c();
            KS_INT_GEN.KS_Resultado result = new KS_INT_GEN.KS_Resultado();
            result.descripcion = '';
            
            result.codigo = facturaSAP.KS_Numero_Factura;
            factura.Name = facturaSAP.KS_Numero_Factura;
            factura.KS_Numero_Factura__c = facturaSAP.KS_Numero_Factura;
            
            // LOOKUP ACCOUNT   
            if (facturaSAP.KS_Solicitante != null) {
                if (accMAP.containsKey(facturaSAP.KS_Solicitante)) {
                    factura.KS_Solicitante__c = accMAP.get(facturaSAP.KS_Solicitante);
                } else {
                    result.tipo = 'E - ' + tipo;
                    result.descripcion += ' ### KS_Solicitante ' + facturaSAP.KS_Solicitante + ' no encontrado';
                    wrong = true;
                }

            } else {
                result.tipo = 'E - ' + tipo;
                result.descripcion += ' ### KS_Solicitante no informado';
                wrong = true;
            }
            
            factura.KS_Numero_Personal__c = facturaSAP.KS_Numero_Personal;
            Boolean numeroPersonal = facturaSAP.KS_Numero_Personal != null && usrMap.containsKey(facturaSAP.KS_Numero_Personal);
            factura.OwnerId = numeroPersonal ? usrMap.get(facturaSAP.KS_Numero_Personal) : adminUser.ID;            

            factura.KS_Clase_de_factura__c = facturaSAP.KS_Clase_de_factura;
            factura.KS_Tipo_de_documento_comercial__c = facturaSAP.KS_Tipo_de_documento_comercial;
            factura.CurrencyIsoCode = facturaSAP.CurrencyIsoCode;
            factura.KS_Organizacion_de_ventas__c = facturaSAP.KS_Organizacion_de_ventas;
            factura.KS_Canal_de_distribucion__c = facturaSAP.KS_Canal_de_distribucion;
            factura.KS_Fecha_de_factura_para_el_indice__c = facturaSAP.KS_Fecha_de_factura_para_el_indice;
            factura.KS_Ejercicio__c = facturaSAP.KS_Ejercicio;
            factura.KS_Periodo_contable__c = facturaSAP.KS_Periodo_contable;
            factura.KS_Incoterms_parte_1__c = facturaSAP.KS_Incoterms_parte_1;
            factura.KS_Incoterms_parte_2__c = facturaSAP.KS_Incoterms_parte_2;
            factura.KS_Indicador_de_exportacion__c = facturaSAP.KS_Indicador_de_exportacion;
            factura.KS_Status_para_la_transferencia_a_contab__c = facturaSAP.KS_Status_para_la_transferencia_a_contab;
            factura.KS_Tipo_de_cambio_de_moneda_para_conta__c = facturaSAP.KS_Tipo_de_cambio_de_moneda_para_conta;
            factura.KS_Ind_fijacion_tipo_cambio_sin_determ__c = facturaSAP.KS_Ind_fijacion_tipo_cambio_sin_determ;
            factura.KS_Dias_valor_adicionales__c = facturaSAP.KS_Dias_valor_adicionales;
            factura.KS_Fecha_de_valor__c = facturaSAP.KS_Fecha_de_valor;
            factura.KS_Clave_de_condiciones_de_pago__c = facturaSAP.KS_Clave_de_condiciones_de_pago;
            factura.KS_via_de_pago__c = facturaSAP.KS_via_de_pago;
            factura.KS_Valor_neto_en_moneda_de_documento__c = facturaSAP.KS_Valor_neto_en_moneda_de_documento;
            factura.KS_Nombre_del_responsable__c = facturaSAP.KS_Nombre_del_responsable;
            factura.KS_Hora_registrada__c = facturaSAP.KS_Hora_registrada;
            factura.KS_Fecha_de_creacion_del_registro__c = facturaSAP.KS_Fecha_de_creacion_del_registro;
            factura.KS_Destinatario__c = facturaSAP.KS_Destinatario;
            factura.KS_Resp_pago__c = facturaSAP.KS_Resp_pago;
            factura.KS_Dest_Factura__c = facturaSAP.KS_Dest_Factura;
            factura.KS_Vendedor__c = facturaSAP.KS_Vendedor;
            factura.KS_Comisionista__c = facturaSAP.KS_Comisionista;
            factura.KS_Factura_esta_anulada__c = facturaSAP.KS_Factura_esta_anulada;
            factura.KS_Estado__c = facturaSAP.KS_Estado;
            
            if (!wrong) { lstfacturas.add(factura); }
            mapResult.put(result.codigo, result);
        }

        Schema.DescribeFieldResult field = KS_Factura__c.KS_Numero_factura__c.getDescribe();
        Schema.sObjectField idSAP = field.getSObjectField();
        Database.UpsertResult[] upsertResult = Database.upsert(lstfacturas, idSAP, false);          
        
        lstResult = controlErrorUpsert(upsertResult, tipo, (List<Object>)lstfacturas, mapResult);
        setResultados(lstResult, 'setFacturas', tipo);
        return lstResult;
    }    
    
    /////////////////////
    // TRATAR ERRORES //
    ///////////////////
    public static List<KS_INT_GEN.KS_Resultado> controlErrorUpsert(List<Database.UpsertResult> result, String tipo, List<Object> lstObj, Map<String, KS_INT_GEN.KS_Resultado> mapError) {
        
        System.debug('--------------------------------- JCAR controlErrorUpsert - tipo: ' + tipo);
        System.debug('--------------------------------- JCAR controlErrorUpsert - result: ' + result);
        System.debug('--------------------------------- JCAR controlErrorUpsert - lstObj: ' + lstObj);
        System.debug('--------------------------------- JCAR controlErrorUpsert - mapError: ' + mapError);
        
        List<KS_INT_GEN.KS_Resultado> lstError = mapError.values();
        Integer i = 0;
        for (Object obj : (list<Object>)lstObj) {
            
            KS_INT_GEN.KS_Resultado error = new KS_INT_GEN.KS_Resultado();
            if (tipo == 'Pedido') { error = mapError.get( ((KS_Pedido__c)obj).KS_Numero_Pedido__c ); }
            if (tipo == 'Entrega') { error = mapError.get( ((KS_Entrega__c)obj).KS_Numero_Entrega__c ); }
            if (tipo == 'Factura') { error = mapError.get( ((KS_Factura__c)obj).KS_Numero_Factura__c ); }
            if (tipo == 'Cliente Distribuidor') { error = mapError.get( ((Account)obj).KS_Id_SAP__c ); }
            if (tipo == 'Organizacion Cliente') { error = mapError.get( ((KS_Organizacion_Cliente__c)obj).KS_ID_Organizacion_Cliente__c ); }
            if (tipo == 'Jerarquia de Cliente') { error = mapError.get( ((KS_Jerarquia_Cliente__c)obj).KS_ID_Jerarquia__c ); }
            if (tipo == 'Producto') { error = mapError.get( ((Product2)obj).KS_Id_SAP__c ); }
            if (tipo == 'Organizacion Producto') { error = mapError.get( ((KS_Organizacion_Producto__c)obj).KS_ID_Organizacion_Producto__c ); }
            if (tipo == 'Jerarquia de Producto') { error = mapError.get( ((KS_Jerarquia_Producto__c)obj).KS_Id_SAP__c ); }
            if (tipo == 'Condición Comercial') { error = mapError.get( ((KS_Condicion_Comercial__c)obj).KS_ID_condicion_comercial__c ); }
            error.tipo = result[i].success? 'I - ' + tipo : 'E - ' + tipo;
            error.descripcion = result[i].success? 'OK' : (result[i].errors[0].fields.size()>0 ? result[i].errors[0].fields[0] + ' - ' : '') + result[i].errors[0].message;
            i++;
        }
        System.debug('--------------------------------- JCAR controlErrorUpsert - lstError: ' + lstError);
        return lstError;
    }
    public static List<KS_INT_GEN.KS_Resultado> controlErrorInsert(List<Database.SaveResult> result, String tipo, List<Object> lstObj, Map<String, KS_INT_GEN.KS_Resultado> mapError) {
        
        List<KS_INT_GEN.KS_Resultado> lstError = mapError.values();
        Integer i = 0;
        for (Object obj : (list<Object>)lstObj) {
            
            KS_INT_GEN.KS_Resultado error = new KS_INT_GEN.KS_Resultado();
            if (tipo == 'Condición Comercial') { error = mapError.get( ((KS_Condicion_Comercial__c)obj).KS_ID_condicion_comercial__c ); }
            error.tipo = result[i].success? 'I - ' + tipo : 'E - ' + tipo;
            error.descripcion = result[i].success? 'OK' : (result[i].errors[0].fields.size()>0 ? result[i].errors[0].fields[0] + ' - ' : '') + result[i].errors[0].message;
            i++;
        }
        System.debug('--------------------------------- JCAR - lstError: ' + lstError);
        return lstError;
    }
    
    public static List<KS_INT_GEN.KS_Resultado> controlErrorInsertOLD(List<Database.SaveResult> insRes, String tipo, List<Object> lstObj, List<KS_INT_GEN.KS_Resultado> lstError) {
        
        lstError = lstError != null ? lstError : new List<KS_INT_GEN.KS_Resultado>();
        //Recogemos los Objectos que dan error y los devolvemos con su correspondiente mensaje       
        Integer i = 0;

        if (tipo == 'Condición Comercial') {
            for(KS_Condicion_Comercial__c cc : (list<KS_Condicion_Comercial__c>)lstObj) { 
                KS_INT_GEN.KS_Resultado errJProd = new KS_INT_GEN.KS_Resultado();
                errJProd.tipo = insRes[i].success? 'I - ' + tipo : 'E - ' + tipo;
                errJProd.codigo = cc.KS_ID_condicion_comercial__c;
                errJProd.descripcion = insRes[i].success? 'OK' : (insRes[i].errors[0].fields.size()>0 ? insRes[i].errors[0].fields[0] + ' - ' : '') + insRes[i].errors[0].message;
                // Añadir mensajes de "lookup not found" si se da el caso
                if ( cc.KS_Cliente_Jerarquia__c == null ) { errJProd.descripcion += ' #### '+'KS_JerarquiaCliente o Cuenta asociada no encontrado, no se ha podido establecer una relación'; }
                if ( cc.KS_Material__c == null ) { errJProd.descripcion += ' #### '+'KS_NumeroMaterial o Producto asociado no encontrado, no se ha podido establecer una relación'; }
                if ( cc.KS_PRODH1__c == null ) { errJProd.descripcion += ' #### '+'KS_JerarquiaProducto1 no encontrado, no se ha podido establecer una relación'; }
                if ( cc.KS_PRODH2__c == null ) { errJProd.descripcion += ' #### '+'KS_JerarquiaProducto2 no encontrado, no se ha podido establecer una relación'; }
                if ( cc.KS_PRODH3__c == null ) { errJProd.descripcion += ' #### '+'KS_JerarquiaProducto3 no encontrado, no se ha podido establecer una relación'; }
                if ( cc.KS_PRODH4__c == null ) { errJProd.descripcion += ' #### '+'KS_JerarquiaProducto4 no encontrado, no se ha podido establecer una relación'; }
                lstError.add(errJProd);
                i++;
            }
        }
        
        setResultados(lstError, 'SET', tipo);
        System.debug('--------------------------------- JCAR - lstError: ' + lstError);
        return lstError;        
    }
    public static List<KS_INT_GEN.KS_Resultado> controlErrorUpsertOLD(List<Database.UpsertResult> upsRes, String tipo, List<Object> lstObj, List<KS_INT_GEN.KS_Resultado> lstError) {
        
        lstError = lstError != null ? lstError : new List<KS_INT_GEN.KS_Resultado>();
        //Recogemos los Objectos que dan error y los devolvemos con su correspondiente mensaje       
        Integer i = 0;
        
        if(tipo == 'Cliente Distribuidor') {
            for(Account clieDist : (list<Account>)lstObj) { 
                KS_INT_GEN.KS_Resultado errClieDist = new KS_INT_GEN.KS_Resultado();
                errClieDist.tipo = upsRes[i].success? 'I - ' + tipo : 'E - ' + tipo;
                errClieDist.codigo = clieDist.KS_Id_SAP__c;  
                //System.debug('-------------------------SERG - Error - Cliente Distribuidor: ' + upsRes[i]);                
                errClieDist.descripcion = upsRes[i].success? 'OK' : (upsRes[i].errors[0].fields.size()>0 ? upsRes[i].errors[0].fields[0] + ' - ' : '') + upsRes[i].errors[0].message;                                
                lstError.add(errClieDist); 
                i++;
            }   
            
        } else if(tipo == 'Organizacion Cliente') {
            for(KS_Organizacion_Cliente__c oClie : (list<KS_Organizacion_Cliente__c>)lstObj) { 
                KS_INT_GEN.KS_Resultado errOClie = new KS_INT_GEN.KS_Resultado();
                errOClie.tipo = upsRes[i].success? 'I - ' + tipo : 'E - ' + tipo;
                errOClie.codigo = oClie.KS_ID_Organizacion_Cliente__c; 
                errOClie.descripcion = upsRes[i].success? 'OK' : (upsRes[i].errors[0].fields.size()>0 ? upsRes[i].errors[0].fields[0] + ' - ' : '') + upsRes[i].errors[0].message;                
                // Añadir mensajes de "lookup not found" si se da el caso
                if ( oClie.KS_Cliente_Dest_Mercancias__c == null ) { errOClie.descripcion += ' #### '+'KS_Cliente_Dest_Mercancias o Cuenta asociada no encontrado, no se ha podido establecer una relación'; }
                if ( oClie.KS_Cliente_solicitante__c == null ) { errOClie.descripcion += ' #### '+'KS_Cliente_solicitante o Cuenta asociada no encontrado, no se ha podido establecer una relación'; }                
                if ( oClie.KS_Cliente_Distribucion__c == null ) { errOClie.descripcion += ' #### '+'KS_Numero_de_deudor o Cuenta asociada no encontrado, no se ha podido establecer una relación'; }                
                //clie.KS_Numero_de_deudor + '-' + oClie.KS_Organizacion_de_ventas + oClie.KS_Canal_de_distribucion + oClie.KS_Sector;
                lstError.add(errOClie);
                i++;
            } 

        } else if(tipo == 'Producto') {
            for(Product2 pr : (list<Product2>)lstObj) { 
                KS_INT_GEN.KS_Resultado errProd = new KS_INT_GEN.KS_Resultado();
                errProd.tipo = upsRes[i].success? 'I - ' + tipo : 'E - ' + tipo;
                errProd.codigo = pr.KS_Id_SAP__c;                   
                errProd.descripcion = upsRes[i].success? 'OK' : (upsRes[i].errors[0].fields.size()>0 ? upsRes[i].errors[0].fields[0] + ' - ' : '') + upsRes[i].errors[0].message;                   
                lstError.add(errProd);               
                i++;
            }  
            
        } else if(tipo == 'Organizacion Producto') {
            for(KS_Organizacion_Producto__c pr : (list<KS_Organizacion_Producto__c>)lstObj) { 
                KS_INT_GEN.KS_Resultado errOrgProd = new KS_INT_GEN.KS_Resultado();
                errOrgProd.tipo = upsRes[i].success? 'I - ' + tipo : 'E - ' + tipo;
                errOrgProd.codigo = pr.KS_ID_Organizacion_Producto__c;                   
                errOrgProd.descripcion = upsRes[i].success? 'OK' : (upsRes[i].errors[0].fields.size()>0 ? upsRes[i].errors[0].fields[0] + ' - ' : '') + upsRes[i].errors[0].message;                   
                lstError.add(errOrgProd);               
                i++;
            }
        }
        
        System.debug('---------------------------------SERG - lstError: ' + lstError);
        
        setResultados(lstError, 'SET', tipo);
        return lstError;
    }
    
    private static void setResultados(List<KS_INT_GEN.KS_Resultado> lstResultados, String metodo, String clase) {
        
        List<KS_Debug__c> lstErrors = new List<KS_Debug__c>();
        for (KS_INT_GEN.KS_Resultado resultado : lstResultados) {
            
            Boolean isError = resultado.tipo != null && resultado.tipo.startsWith('E');
            if (isError) {
                
                KS_Debug__c error = new KS_Debug__c();
                error.Name = resultado.codigo.length() <= 80 ? resultado.codigo : resultado.codigo.substring(0,79);
                error.KS_Codigo__c = resultado.codigo;
                error.KS_Clase__c = clase;
                //error.KS_Campo__c = resultado.codigo;
                error.KS_Descripcion__c = resultado.descripcion;
                error.KS_Origen__c = 'KS_INT_SAP';
                error.KS_Origen_Metodo__c = metodo;
                lstErrors.add(error);
            }
        }
        insert lstErrors;
    }
    
    webservice static List<KS_INT_GEN.KS_Resultado> DelPedidos(List<KS_INT_GEN.KS_Pedido> lstPedidoSAP) {
        
        Map<ID, KS_Pedido__c> pedidos = new Map<ID, KS_Pedido__c>(); List<String> pedidosIDSAP = new List<String>();
        for (KS_INT_GEN.KS_Pedido pedidoSAP : lstPedidoSAP) {
            if (pedidoSAP.KS_Documento_de_ventas != null) 
            {pedidosIDSAP.add(pedidoSAP.KS_Documento_de_ventas);}
        }
        for (KS_Pedido__c pedido : [SELECT ID,KS_Numero_pedido__c FROM KS_Pedido__c WHERE KS_Numero_pedido__c IN :pedidosIDSAP]) {
            pedidos.put(pedido.ID, pedido);
        }

        return getDeleteResult(pedidos.values(), 'KS_Pedido');
    }
    webservice static List<KS_INT_GEN.KS_Resultado> DelEntregas(List<KS_INT_GEN.KS_Entrega> lstEntregaSAP) {

        Map<ID, KS_Entrega__c> entregas = new Map<ID, KS_Entrega__c>(); List<String> entregasIDSAP = new List<String>();
        for (KS_INT_GEN.KS_Entrega entregaSAP : lstEntregaSAP) {
            if (entregaSAP.KS_Numero_Entrega != null) 
            {entregasIDSAP.add(entregaSAP.KS_Numero_Entrega);}
        }
        for (KS_Entrega__c entrega : [SELECT ID,KS_Numero_entrega__c FROM KS_Entrega__c WHERE KS_Numero_entrega__c IN :entregasIDSAP]) {
            entregas.put(entrega.ID, entrega);
        }

        return getDeleteResult(entregas.values(), 'KS_Entrega');
    }
    public static List<KS_INT_GEN.KS_Resultado> getDeleteResult(List<SObject> sobjLst, String classType) {
        List<KS_INT_GEN.KS_Resultado> result = new List<KS_INT_GEN.KS_Resultado>();
        
        Database.DeleteResult[] deleteResult = Database.delete(sobjLst, true);
        Integer i = 0;
        for (SObject sobj : sobjLst) {
            
            Database.DeleteResult delRes = deleteResult[i];
            KS_INT_GEN.KS_Resultado errDelete = new KS_INT_GEN.KS_Resultado();
            String cod = '';
            if (classType == 'KS_Entrega') { cod = ((KS_Entrega__c)sobjLst.get(i)).KS_Numero_entrega__c; }
            if (classType == 'KS_Pedido') { cod = ((KS_Pedido__c)sobjLst.get(i)).KS_Numero_pedido__c; }
            errDelete.codigo =  cod;
            errDelete.tipo = delRes.success? 'I - ' + classType : 'E - ' + classType;
            errDelete.descripcion = delRes.success? 'OK' : (delRes.errors[0].fields.size()>0 ? delRes.errors[0].fields[0] + ' - ' : '') + delRes.errors[0].message;                   
            result.add(errDelete);
            i++;
        }
        
        return result;
    }

}