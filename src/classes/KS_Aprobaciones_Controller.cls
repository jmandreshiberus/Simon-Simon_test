global without sharing class KS_Aprobaciones_Controller {

    global static void setAprobacionesOferta(Map<String,Decimal> mapDescuentos, Map<String,Decimal> mapDescuentosMSC, Map<String,Set<ID>> mapElementos, 
                                             Map<ID,ID> responsables, List<SObject> elementos, List<Opportunity> ofertas, Map<ID,String> orgVentas, List<String> clavesSerieFamilia,
                                             List<String> subseries, List<String> series, List<String> familias, Map<ID, String> paises) {
        
        //Boolean setNecesitaAprobacion = oportunidadProducto != null && oportunidadProducto.size()>0;
        Schema.sObjectType oppLType = Schema.OpportunityLineItem.getSObjectType();
        Schema.sObjectType CoObType = Schema.KS_Condicion_de_Obra__c.getSObjectType();
        Boolean isOppLType = oppLType == elementos[0].getSobjectType();
        Boolean isCoObType = CoObType == elementos[0].getSobjectType();
        
        //Opportunity oferta = ofertas.get(0);
        
        /*Set<String> subsSet = new Set<String>(); subsSet.addAll(mapDescuentos.keySet()); subsSet.addAll(mapDescuentosMSC.keySet());
        List<String> subsLst = new List<String>(); subsLst.addAll(subsSet);*/
        System.debug('-- JCAR ---------------------------------- - ' + subseries.size() + ' KS_Autorizacion_Oferta subseries - ' + subseries);
        System.debug('-- JCAR ---------------------------------- - ' + series.size() + ' KS_Autorizacion_Oferta series - ' + series);
        System.debug('-- JCAR ---------------------------------- - ' + familias.size() + ' KS_Autorizacion_Oferta familias - ' + familias);
		System.debug('-- JCAR ---------------------------------- - ' + orgVentas.size() + ' KS_Autorizacion_Oferta orgVentas - ' + orgVentas);
        System.debug('-- JCAR ---------------------------------- - ' + paises.size() + ' KS_Autorizacion_Oferta paises - ' + paises);
                                                 
        List<KS_Autorizacion_Oferta__c> aoList = [SELECT KS_Niv1_LimiteExtra__c, KS_Niv2_LimiteExtra__c, KS_Niv3_LimiteExtra__c, KS_Niv4_LimiteExtra__c, 
                                                  KS_Niv1_LimiteMSC__c, KS_Niv2_LimiteMSC__c, KS_Niv3_LimiteMSC__c, KS_Niv4_LimiteMSC__c, 
                                                  KS_Niv1_User__c, KS_Niv2_User__c, KS_Niv3_User__c, KS_Niv4_User__c, KS_Niv4_User2__c,
                                                  KS_Niv3_Categoria__c, KS_Organizacion_Ventas__c, KS_Pais__c, 
                                                  KS_Subserie__c, KS_Serie__c , KS_Familia__c, ID 
                                                  FROM KS_Autorizacion_Oferta__c
                                                  WHERE ( (KS_Subserie__c IN :subseries AND KS_Serie__c IN :series AND KS_Familia__c IN :familias)
                                                  OR (KS_Subserie__c = NULL AND KS_Serie__c = NULL AND KS_Familia__c = NULL) )
                                                  AND KS_Organizacion_Ventas__c IN :orgVentas.values() AND KS_Pais__c in :paises.values()];
                                                 
        System.debug('-- JCAR ---------------------------------- - ' + aoList.size() + ' KS_Autorizacion_Oferta - ' + aoList);
        Map<String, Map<String, KS_Autorizacion_Oferta__c>> mapAO = new Map<String, Map<String, KS_Autorizacion_Oferta__c>>();
                             
        Map<String,KS_Autorizacion_Oferta__c> aoDefault = new Map<String,KS_Autorizacion_Oferta__c>();
        for (KS_Autorizacion_Oferta__c ao : aoList) {
            
            if (ao.KS_Subserie__c == null && ao.KS_Serie__c == null && ao.KS_Familia__c == null) {
                
                aoDefault.put(ao.KS_Organizacion_Ventas__c+''+ao.KS_Pais__c, ao);
                
            } else {
                Map<String, KS_Autorizacion_Oferta__c> aoM = new Map<String, KS_Autorizacion_Oferta__c>();
                if (mapAO.containsKey(ao.KS_Organizacion_Ventas__c)) {
                    aoM = mapAO.get(ao.KS_Organizacion_Ventas__c);
                }
                
                String clave = ''; // Serie+Subserie+Familia
                clave += ao.KS_Serie__c != null ? ao.KS_Serie__c : '';
                clave += ao.KS_Subserie__c != null ? ao.KS_Subserie__c : '';
                clave += ao.KS_Familia__c != null ? ao.KS_Familia__c : '';
                clave += ao.KS_Pais__c != null ? ao.KS_Pais__c : '';
                
                aoM.put(clave, ao);
                mapAO.put(ao.KS_Organizacion_Ventas__c, aoM);                
            }
        }
        
        Integer index = 0;
        for(SObject sObj : elementos) {
            
            Opportunity oferta =  ofertas.get(index);
            OpportunityLineItem ol = isOppLType ? (OpportunityLineItem)sObj : null;
            KS_Condicion_de_Obra__c co = isCoObType ? (KS_Condicion_de_Obra__c)sObj : null;
            
            Boolean msc = isOppLType && ol != null && ol.KS_Material_sin_cargo__c;
            
            System.debug('-- JCAR ---------------------------------- - sObj? ' + sObj);
            
            String clave = clavesSerieFamilia.get(index); // Serie+Subserie+Familia
            String orgVenta = orgVentas.get(oferta.ID);
            String pais = oferta.KS_Pais__c;
            
            //if (mapAO.get(orgVenta) == null) {continue;}
            //if (mapAO.get(orgVenta).get(clave) == null) {continue;}
            
            boolean generico = false;
            KS_Autorizacion_Oferta__c ao = null;
            if (mapAO.containsKey(orgVenta)) {
                
                if (mapAO.get(orgVenta).containsKey(clave+pais)) {
                    ao = mapAO.get(orgVenta).get(clave+pais);
                
                } else if (aoDefault.containsKey(orgVenta+pais)) {
                    ao = aoDefault.get(orgVenta+pais); generico = true;
                }

            } else { continue; }
            if (ao == null) { continue; }
            //if (ao.KS_Pais__c != oferta.KS_Pais__c) { continue; } 
            
            Decimal dtoObj = 0;
            if (isOppLType)
            { dtoObj = ol.KS_Material_sin_cargo__c ? ol.KS_Dto_SinCargo__c : ol.KS_Dto_adicional_2__c; }
            else if (isCoObType) 
            { dtoObj = co.KS_Dto_adicional_2__c; }
            
            if (mapDescuentos.containsKey(clave) || (msc && mapDescuentosMSC.containsKey(clave)) ) {
                               
                ID userID = null;
                Decimal dto = msc ? mapDescuentosMSC.get(clave) : mapDescuentos.get(clave);
                
                System.debug('-- JCAR ---------------------------------- - clave? ' + clave);
                System.debug('-- JCAR ---------------------------------- - descuento? ' + dto);
                
                Decimal limit1 = msc ? ao.KS_Niv1_LimiteMSC__c: ao.KS_Niv1_LimiteExtra__c;
                Decimal limit2 = msc ? ao.KS_Niv2_LimiteMSC__c: ao.KS_Niv2_LimiteExtra__c;
                Decimal limit3 = msc ? ao.KS_Niv3_LimiteMSC__c: ao.KS_Niv3_LimiteExtra__c;
                Decimal limit4 = msc ? ao.KS_Niv4_LimiteMSC__c: ao.KS_Niv4_LimiteExtra__c;
                
                Boolean niv1 = false; Boolean niv2 = false; Boolean niv3 = false; Boolean niv4 = false;
                if (dto <= limit1 ) {
                    niv1 = true; userID = ao.KS_Niv1_User__c;
                } 
                
                System.debug('-- JCAR ---------------------------------- - NIVEL 2? ' + ( (dtoObj > limit1) || (niv1 && limit1 == limit2) || limit2 == 0 ) );
                if ( (dto > limit1) || (niv1 && limit1 == limit2) || limit2 == 0 ) {
                    niv2 = (dtoObj > limit1) || (niv1 && limit1 == limit2) || limit2 == 0;
                    userID = ao.KS_Niv2_User__c;
                    ID responsable = responsables.get(oferta.ID);
                    System.debug('-- JCAR ---------------------------------- - responsable? ' + responsable);
                    if (ol != null) {
                        oferta.KS_Nivel2__c = true;
                        oferta.KS_Resp_Jefe_de_Area__c = responsable;
                    } else if (co != null) {
                        co.KS_Nivel2__c = true;
                        co.KS_Resp_Jefe_de_Area__c = responsable;
                    }
                }
                
                System.debug('-- JCAR ---------------------------------- - NIVEL 3? ' + ( (dtoObj > limit2) || (niv2 && limit2 == limit3) || limit3 == 0 ) );
                if ( (dto > limit2) || (niv2 && limit2 == limit3) || limit3 == 0 ) {
                    niv3 = (dtoObj > limit2) || (niv1 && limit2 == limit3) || limit3 == 0;
                    userID = ao.KS_Niv3_User__c;
                    
                    String sbs = ao.KS_Niv3_Categoria__c;
                    System.debug('-- JCAR ---------------------------------- - Categoria? ' + sbs);
                    if (sbs == 'ILU') {
                        if (ol != null) { oferta.KS_Nivel3__c = true; oferta.KS_Resp_Iluminacion__c = userID; } 
                        else if (co != null) { co.KS_Nivel3__c = true; co.KS_Resp_Iluminacion__c = userID; }                        
                    } else if (sbs == 'VEH') {
                        if (ol != null) { oferta.KS_Nivel3__c = true; oferta.KS_Resp_Vehiculo_Electrico__c = userID; } 
                        else if (co != null) { co.KS_Nivel3__c = true; co.KS_Resp_Vehiculo_Electrico__c = userID; }                          
                    } else if (sbs == 'RES') {
                        if (ol != null) { oferta.KS_Nivel3__c = true; oferta.KS_Resp_resto_de_gamas__c = userID; } 
                        else if (co != null) { co.KS_Nivel3__c = true; co.KS_Resp_resto_de_gamas__c = userID; }                          
                    } else if (sbs == 'SIS') {
                        if (ol != null) { oferta.KS_Nivel3__c = true; oferta.KS_Resp_Sist_Control__c = userID; } 
                        else if (co != null) { co.KS_Nivel3__c = true; co.KS_Resp_Sist_Control__c = userID; }                          
                    } else if (sbs == 'CON') { 
                        if (ol != null) { oferta.KS_Nivel3__c = true; oferta.KS_Resp_Conectividad__c = userID; } 
                        else if (co != null) { co.KS_Nivel3__c = true; co.KS_Resp_Conectividad__c = userID; }                      
                    }
                    /*
                    if (generico) {
                        if (ol != null) { oferta.KS_Nivel3__c = true; oferta.KS_Resp_resto_de_gamas__c = userID; } 
                        else if (co != null) { co.KS_Nivel3__c = true; co.KS_Resp_resto_de_gamas__c = userID; }                          
                    }*/
                } 
                
                System.debug('-- JCAR ---------------------------------- - NIVEL 4? ' + (dtoObj > limit3) );
                if ( dto > limit3 ) {
                    niv4 = dtoObj > limit3;
                    if (ol != null) {
                        oferta.KS_Nivel4__c = true;
                        oferta.KS_Resp_negocio_iberia__c = ao.KS_Niv4_User__c;
                        oferta.KS_Resp_Negocio_Iberia_2__c = ao.KS_Niv4_User2__c;
                    } else if (co != null) {
                        co.KS_Nivel4__c = true;
                        co.KS_Resp_negocio_iberia__c = ao.KS_Niv4_User__c;
                        co.KS_Resp_Negocio_Iberia_2__c = ao.KS_Niv4_User2__c;
                    }
                }
                
                if (ol != null && (niv2||niv3||niv4)) { ol.KS_Necesita_aprobacion__c = true; }
            }
            index++;
        }        
    }    
        
    global static void setAprobacionesCuenta(List<Account> cuentas, Set<String> marcas, Map<ID,List<String>> marcasCuenta, Map<ID, String> areaCuenta) {
        
        if (cuentas.isEmpty() || marcas.isEmpty() || marcasCuenta.isEmpty()) { return; }
        
		List<ID> cuentasID = new List<ID>(); cuentasID.addAll(marcasCuenta.keySet());
        List<String> marcasS = new List<String>(); marcasS.addAll(marcas);
        Set<ID> terrSet = new Set<ID>();
        
        List<ObjectTerritory2Association> taccLst = 
            [SELECT Id, ObjectId, Territory2Id, Territory2.KS_Organizacion_Ventas__c, SobjectType
             FROM ObjectTerritory2Association WHERE ObjectId IN :cuentasID
             AND Territory2.KS_Organizacion_Ventas__c IN :marcasS];
        Map<ID,Set<ID>> territorios = new Map<ID,Set<ID>>();
        Map<ID,String> territorioMarca = new Map<ID,String>();
        for (ObjectTerritory2Association tacc : taccLst) {
            
            Set<ID> terrLst = new Set<ID>();
            if (territorios.containsKey(tacc.ObjectId)) {
                terrLst = territorios.get(tacc.ObjectId);
            }
            terrLst.add(tacc.Territory2Id); terrSet.add(tacc.Territory2Id);
            territorios.put(tacc.ObjectId, terrLst);
            territorioMarca.put(tacc.Territory2Id, tacc.Territory2.KS_Organizacion_Ventas__c);
        }
        
        Map<ID,ID> responsables = new Map<ID,ID>();
        
        List<ID> terrID = new List<ID>(); terrID.addAll(terrSet);
        List<UserTerritory2Association> terrOferta = 
            [SELECT Id, UserId, Territory2Id, RoleInTerritory2 
             FROM UserTerritory2Association 
             WHERE RoleInTerritory2 = 'JAR'
             AND Territory2Id IN :terrSet];
        for (UserTerritory2Association uta : terrOferta) {
            responsables.put(uta.Territory2Id , uta.UserId);
        }
        
        
        /*
        List<UserTerritory2Association> terrOferta = 
            [SELECT Id, UserId, Territory2Id, RoleInTerritory2,
             Territory2.KS_Organizacion_Ventas__c,
             Territory2.KS_Canal__c,
             Territory2.KS_Sector_Distribuidor__c,
             Territory2.KS_Area__c
             FROM UserTerritory2Association 
             WHERE RoleInTerritory2 = 'JAR'
             AND Territory2.KS_Area__c IN :areaGLst
             AND Territory2.Territory2TypeId = :terrType.get('KS_Area')
            ];
        for (Opportunity opp : ofertas.values()) {
            for (UserTerritory2Association uta : terrOferta) {
                if (uta.Territory2.KS_Organizacion_Ventas__c == opp.KS_Organizacion_de_Ventas__c
                    && uta.Territory2.KS_Canal__c == opp.KS_Canal__c
                    && uta.Territory2.KS_Sector_Distribuidor__c == opp.KS_Sector__c
                    && uta.Territory2.KS_Area__c == opp.KS_Area__c) {
                    
                        responsables.put(opp.ID , uta.UserId);
                }
            }
        }        
        */
        // Asignación Responsables Cuenta
        for (Account acc : cuentas) {
            
            if (territorios.containsKey(acc.ID)) {
                Set<ID> terrLst = territorios.get(acc.ID);
                
                for (ID terr : terrLst) {
                    
                    if (territorioMarca.containsKey(terr) && responsables.containsKey(terr)) {
                        String marca = territorioMarca.get(terr);
                        ID user = responsables.get(terr);
                        
                        if (marca == 'SI10') {
                            acc.KS_Responsable_SI10__c = user;
                        } else if (marca == 'FL31') {
                            acc.KS_Responsable_FL31__c = user;
                        } else if (marca == 'IE20') {
                            acc.KS_Responsable_IE20__c = user;
                        }
                    }
                }               
            }
        }
    }
}