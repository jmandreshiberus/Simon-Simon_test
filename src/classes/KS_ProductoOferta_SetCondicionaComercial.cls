public without sharing class KS_ProductoOferta_SetCondicionaComercial {

    public static Map<String, Condicion> oldMethod(Map<ID,Product2> productos, Opportunity oferta) {

		Map<String, Condicion> precios = new Map<String, Condicion>();        
        List<ID> producLst = new List<ID>(); producLst.addAll(productos.keySet());
        List<KS_Condicion_Comercial__c> condiciones = [SELECT Id, KS_Tarifa__c, KS_Material__c, KS_Condicion__c, KS_Importe__c, KS_Cliente_Jerarquia__c
                                                       FROM KS_Condicion_Comercial__c WHERE KS_tarifa__c = :oferta.KS_Lista_de_precios__c 
                                                       AND KS_Material__c in :producLst 
                                                       AND (KS_Condicion__c = 'PR00' 
                                                            OR (KS_Condicion__c = null AND KS_CountryCode__c = :oferta.KS_Pais__c)
                                                           )
                                                      ];   
        
        for (KS_Condicion_Comercial__c condiC : condiciones) { 
            
            Condicion condi = new Condicion(condiC);
            precios.put(condiC.KS_Material__c, condi); 
        }        
        return precios;
    }
    public static Map<String, Condicion> condicionesPorMaterial(Map<ID,Product2> productos, Opportunity oferta) {
        
        // Hasta que esté, devolverá la primera versión del sistema
        //return oldMethod(productos, oferta);
        
        // origen precio del producto:
        // CONDICIÓN COMERCIAL: 
        // lista de precios (from organizacióncli) == tarifa // Esto ya no es necesario, hay CC sin tarifa
        // && numero material (producto.KS_Id_SAP__c)
        // && condición PR00 // Esto ya no es necesario
        // && cliente==null || cliente==oferta.distribuidor     

		System.debug('-- JCAR ---------------------------------- - condicionesPorMaterial oferta' + oferta);
        
        Map<String, Condicion> precios = new Map<String, Condicion>();
        List<ID> producLst = new List<ID>(); producLst.addAll(productos.keySet());
        
        System.debug('-- JCAR ---------------------------------- - SELECT ' + producLst.size() + ' producLst - ' + producLst);
        
        Map<String, List<KS_Condicion_Comercial__c>> preciosPorMaterial = new Map<String, List<KS_Condicion_Comercial__c>>();
        Map<String, List<KS_Condicion_Comercial__c>> descuentosPorMaterial = new Map<String, List<KS_Condicion_Comercial__c>>();
        
        Map<String, List<KS_Condicion_Comercial__c>> descuentosPorJerCliente = new Map<String, List<KS_Condicion_Comercial__c>>();
        
        Map<String, List<KS_Condicion_Comercial__c>> descuentosPorFamilia = new Map<String, List<KS_Condicion_Comercial__c>>();
        Map<String, List<KS_Condicion_Comercial__c>> descuentosPorSerie = new Map<String, List<KS_Condicion_Comercial__c>>();
        Map<String, List<KS_Condicion_Comercial__c>> descuentosPorSubSerie = new Map<String, List<KS_Condicion_Comercial__c>>();
        
        Map<String, List<KS_Condicion_Comercial__c>> descuentosPorJerProducto1 = new Map<String, List<KS_Condicion_Comercial__c>>();
        Map<String, List<KS_Condicion_Comercial__c>> descuentosPorJerProducto2 = new Map<String, List<KS_Condicion_Comercial__c>>();
        Map<String, List<KS_Condicion_Comercial__c>> descuentosPorJerProducto3 = new Map<String, List<KS_Condicion_Comercial__c>>();
        Map<String, List<KS_Condicion_Comercial__c>> descuentosPorJerProducto4 = new Map<String, List<KS_Condicion_Comercial__c>>();
        
        Map<String, Integer> jerarquiaIndex = new Map<String, Integer>();
        Map<String, String> jerarquia = new Map<String, String>(); Set<String> jerarquiaOferta = new Set<String>();
        // Jerarquía de la cuenta de la oferta
        Id cuentActual = oferta.KS_Distribuidor__c; Id cuentSuperior = null;
        Boolean stop = false;
        Integer index = 0;
        while (!stop) {
            
            jerarquiaOferta.add(cuentActual);
            jerarquiaIndex.put(cuentActual, index);
            
            List<KS_Jerarquia_Cliente__c> jCLst = 
                [SELECT KS_Cliente__c, KS_Cliente_Superior__c
                 FROM KS_Jerarquia_Cliente__c
                 WHERE KS_Cliente__c = :cuentActual
                 AND KS_Organizacion_de_ventas__c = :oferta.KS_Organizacion_de_ventas__c 
                 AND KS_Canal_de_distribucion__c = :oferta.KS_Canal__c 
                 AND KS_Sector__c = :oferta.KS_Sector__c
                 LIMIT 1];            
            
            if (jCLst.size()>0) {
                cuentSuperior = jCLst[0].KS_Cliente_Superior__c;
            }
            if (cuentSuperior == null || cuentActual == cuentSuperior)
            { stop = true; }
            else 
            { jerarquia.put(cuentActual, cuentSuperior); cuentActual = cuentSuperior; }
            index++;
        }
        jerarquia.put(cuentActual, 'NULL');
        jerarquiaIndex.put(cuentActual, index);
        
        System.debug('-- JCAR ---------------------------------- - SELECT ' + jerarquia.size() + ' jerarquia cuenta oferta - ' + jerarquia);
        
        List<String> cuentasOferta = new List<String>(); cuentasOferta.addAll(jerarquiaOferta);
        List<KS_Condicion_Comercial__c> condiciones = [SELECT Id, KS_Tarifa__c, KS_Material__c, KS_Condicion__c, KS_Importe__c, KS_Porcentaje__c, KS_Canal__c, KS_CountryCode__c,
                                                       KS_JP1__c, KS_JP2__c, KS_JP3__c, KS_JP4__c, KS_Subserie__c, KS_Serie_single__c, KS_Familia__c, KS_Cliente_Jerarquia__c, KS_Sector__c
                                                       FROM KS_Condicion_Comercial__c WHERE 
                                                       (KS_Canal__c = :oferta.KS_Canal__c OR KS_Canal__c = NULL) AND
                                                       ((KS_Condicion__c = 'PR00' AND KS_Tarifa__c = :oferta.KS_Lista_de_precios__c) OR
                                                        (KS_Condicion__c = 'ZPN0' AND KS_Tarifa__c = :oferta.KS_Lista_de_precios__c) OR
                                                        (KS_Condicion__c != NULL AND KS_Tarifa__c = NULL) OR
                                                        (KS_Condicion__c = NULL AND KS_Tarifa__c = NULL AND KS_CountryCode__c = :oferta.KS_Pais__c AND KS_Canal__c = '20')
                                                       ) AND
                                                       (KS_Material__c in :producLst OR KS_Material__c = NULL) AND
                                                       (KS_Cliente_Jerarquia__c = NULL OR KS_Cliente_Jerarquia__c IN :cuentasOferta)];
        
        System.debug('-- JCAR ---------------------------------- - SELECT ' + condiciones.size() + ' condiciones - ' + condiciones);
        
        // MAPEO PRODUCTOS
        for (KS_Condicion_Comercial__c condi : condiciones) {
            
            List<KS_Condicion_Comercial__c> ccLst = new List<KS_Condicion_Comercial__c>();
            if (condi.KS_Material__c != null) {
                
                // Precios (PR00,ZPN0)
                if (condi.KS_Condicion__c == 'PR00' || condi.KS_Condicion__c == 'ZPN0' || (condi.KS_Condicion__c == null && condi.KS_Canal__c == '20') ) {
                    
                    if (preciosPorMaterial.containsKey(condi.KS_Material__c)) {
                        ccLst = preciosPorMaterial.get(condi.KS_Material__c);
                    }
                    
                    ccLst.add(condi);
                    System.debug('-- JCAR ---------------------------------- - SELECT PRECIO ' + condi);
                    preciosPorMaterial.put(condi.KS_Material__c, ccLst);
                    
                } else {
                    
                    if (descuentosPorMaterial.containsKey(condi.KS_Material__c)) {
                        ccLst = descuentosPorMaterial.get(condi.KS_Material__c);
                    }
                    ccLst.add(condi);
                    descuentosPorMaterial.put(condi.KS_Material__c, ccLst);                
                    
                }                
            
            } else {
/*
                if (condi.KS_Cliente_Jerarquia__c != null) {
                    if (descuentosPorJerCliente.containsKey(condi.KS_Cliente_Jerarquia__c)) {
                        ccLst = descuentosPorJerCliente.get(condi.KS_Cliente_Jerarquia__c);
                    }
                    ccLst.add(condi);
                    descuentosPorJerCliente.put(condi.KS_Cliente_Jerarquia__c, ccLst);                      
                
                } else {
                    */
                if (condi.KS_Familia__c != null) {
                    if (descuentosPorFamilia.containsKey(condi.KS_Familia__c)) {
                        ccLst = descuentosPorFamilia.get(condi.KS_Familia__c);
                    }
                    ccLst.add(condi);
                    descuentosPorFamilia.put(condi.KS_Familia__c, ccLst);                       
                }
                if (condi.KS_Serie_single__c != null) {
                    if (descuentosPorSerie.containsKey(condi.KS_Serie_single__c)) {
                        ccLst = descuentosPorSerie.get(condi.KS_Serie_single__c);
                    }
                    ccLst.add(condi);
                    descuentosPorSerie.put(condi.KS_Serie_single__c, ccLst);                       
                }
                if (condi.KS_Subserie__c != null) {
                    if (descuentosPorSubSerie.containsKey(condi.KS_Subserie__c)) {
                        ccLst = descuentosPorSubSerie.get(condi.KS_Subserie__c);
                    }
                    ccLst.add(condi);
                    descuentosPorSubSerie.put(condi.KS_Subserie__c, ccLst);                       
                }
                
                if (condi.KS_JP4__c != null) {
                    if (descuentosPorJerProducto4.containsKey(condi.KS_JP4__c)) {
                        ccLst = descuentosPorJerProducto4.get(condi.KS_JP4__c);
                    }
                    ccLst.add(condi);
                    descuentosPorJerProducto4.put(condi.KS_JP4__c, ccLst);                       
                }      
                if (condi.KS_JP3__c != null) {
                    if (descuentosPorJerProducto3.containsKey(condi.KS_JP3__c)) {
                        ccLst = descuentosPorJerProducto3.get(condi.KS_JP3__c);
                    }
                    ccLst.add(condi);
                    descuentosPorJerProducto3.put(condi.KS_JP3__c, ccLst);                       
                }
                if (condi.KS_JP2__c != null) {
                    if (descuentosPorJerProducto2.containsKey(condi.KS_JP2__c)) {
                        ccLst = descuentosPorJerProducto2.get(condi.KS_JP2__c);
                    }
                    ccLst.add(condi);
                    descuentosPorJerProducto2.put(condi.KS_JP2__c, ccLst);                       
                }
                if (condi.KS_JP1__c != null) {
                    if (descuentosPorJerProducto1.containsKey(condi.KS_JP1__c)) {
                        ccLst = descuentosPorJerProducto1.get(condi.KS_JP1__c);
                    }
                    ccLst.add(condi);
                    descuentosPorJerProducto1.put(condi.KS_JP1__c, ccLst);                       
                }                    
                //}
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - SELECT ' + preciosPorMaterial.size() + ' preciosPorMaterial - ' + preciosPorMaterial.keySet());
        System.debug('-- JCAR ---------------------------------- - SELECT ' + descuentosPorMaterial.size() + ' descuentosPorMaterial - ' + descuentosPorMaterial.keySet());
        System.debug('-- JCAR ---------------------------------- - SELECT ' + descuentosPorFamilia.size() + ' descuentosPorFamilia - ' + descuentosPorFamilia.keySet());
        System.debug('-- JCAR ---------------------------------- - SELECT ' + descuentosPorSerie.size() + ' descuentosPorSerie - ' + descuentosPorSerie.keySet());
        System.debug('-- JCAR ---------------------------------- - SELECT ' + descuentosPorSubSerie.size() + ' descuentosPorSubSerie - ' + descuentosPorSubSerie.keySet());
        System.debug('-- JCAR ---------------------------------- - SELECT ' + descuentosPorJerProducto1.size() + ' descuentosPorJerProducto1 - ' + descuentosPorJerProducto1.keySet());
        System.debug('-- JCAR ---------------------------------- - SELECT ' + descuentosPorJerProducto2.size() + ' descuentosPorJerProducto2 - ' + descuentosPorJerProducto2.keySet());
        System.debug('-- JCAR ---------------------------------- - SELECT ' + descuentosPorJerProducto3.size() + ' descuentosPorJerProducto3 - ' + descuentosPorJerProducto3.keySet());
        System.debug('-- JCAR ---------------------------------- - SELECT ' + descuentosPorJerProducto4.size() + ' descuentosPorJerProducto4 - ' + descuentosPorJerProducto4.keySet());        
        
        // Para los productos no encontramos, recuperamos sus organizaciones producto
        // servirán apra cruzar con la familia, serie, subserie y jerarquías encontradas
        List<ID> product404 = new List<ID>();
        for (ID key : productos.keySet()) {
            String material = productos.get(key).KS_Id_SAP__c;
            if (!descuentosPorMaterial.containsKey(material)) {
                product404.add(key);
            }
        }
        System.debug('-- JCAR ---------------------------------- - SELECT ' + product404.size() + ' product404 - ' + product404);
        
        Map <ID,KS_Organizacion_Producto__c> orgProdByProd_Nacional = new Map<ID,KS_Organizacion_Producto__c>();
        Map <ID,KS_Organizacion_Producto__c> orgProdByProd_Exportac = new Map<ID,KS_Organizacion_Producto__c>();
        List<KS_Organizacion_Producto__c> orgPLst = [SELECT ID, KS_Producto__c, KS_Jerarquia_Producto__c, KS_Familia__c, 
                                                     KS_Serie_Gama__c, KS_Subserie__c, KS_Canal_de_distribucion__c, KS_Sector__c 
                                                     FROM KS_Organizacion_Producto__c WHERE KS_Producto__c IN :product404];
        for (KS_Organizacion_Producto__c org : orgPLst ) {
            if (org.KS_Canal_de_distribucion__c == '20') {
                orgProdByProd_Exportac.put(org.KS_Producto__c, org);
            } else {
                orgProdByProd_Nacional.put(org.KS_Producto__c, org);
            }
        }
        System.debug('-- JCAR ---------------------------------- - SELECT ' + orgProdByProd_Nacional.size() + ' orgProdByProd_Nacional - ' + orgProdByProd_Nacional);
        System.debug('-- JCAR ---------------------------------- - SELECT ' + orgProdByProd_Exportac.size() + ' orgProdByProd_Exportac - ' + orgProdByProd_Exportac);
       
        Map<ID, KS_Condicion_Comercial__c> accCondi = new Map<ID, KS_Condicion_Comercial__c>();
        Set<String> cuentas = new Set<String>();
        
        Set<String> materiales = new Set<String>();
        materiales.addAll(preciosPorMaterial.keySet());
        materiales.addAll(descuentosPorMaterial.keySet());
        
        System.debug('-- JCAR ---------------------------------- - SELECT ' + materiales.size() + ' materiales - ' + materiales);
        
        // MAPEO CUENTAS
        for (String material : preciosPorMaterial.keySet()) {
            
            List<KS_Condicion_Comercial__c> ccLst = preciosPorMaterial.get(material);
            if (ccLst.size() > 1) {
                
                for (KS_Condicion_Comercial__c condi : ccLst) {
                    if (condi.KS_Cliente_Jerarquia__c != null) {
                        accCondi.put(condi.KS_Cliente_Jerarquia__c, condi);
                        cuentas.add(condi.KS_Cliente_Jerarquia__c);
                    }
                }
                if (accCondi.size() == 1) {
                    KS_Condicion_Comercial__c condiC = accCondi.values().get(0);
                    Condicion condi = new Condicion(condiC);
                    precios.put(condiC.KS_Material__c, condi);
                    cuentas.remove(condiC.KS_Cliente_Jerarquia__c);
                }
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - SELECT ' + accCondi.size() + ' accCondi - ' + accCondi);
        System.debug('-- JCAR ---------------------------------- - SELECT ' + precios.size() + ' precios - ' + precios);
        
        // MAPEO JERARQUÍAS CLIENTE
        // Creamos un "arbol" que relaciona una jerarquía con su superior
        // Si no tiene superior, el valor será el String 'NULL'
        if (!cuentas.isEmpty()) {
            List<String> cuentasL = new List<String>(); cuentasL.addAll(cuentas);
            /*
            List<KS_Jerarquia_Cliente__c> jerCList = [SELECT
                                                      KS_Organizacion_Cliente__r.KS_Cliente_Distribucion__c, 
                                                      KS_Organizacion_Cliente_Superior__r.KS_Cliente_Distribucion__c
                                                      FROM KS_Jerarquia_Cliente__c
                                                      WHERE KS_Organizacion_Cliente__r.KS_Cliente_Distribucion__c IN :cuentasL];*/
            List<KS_Jerarquia_Cliente__c> jerCList = [SELECT KS_Cliente__c, KS_Cliente_Superior__c
                                                      FROM KS_Jerarquia_Cliente__c
                                                      WHERE KS_Cliente__c IN :cuentasL
                                                      AND KS_Organizacion_de_ventas__c = :oferta.KS_Organizacion_de_ventas__c 
                                                      AND KS_Canal_de_distribucion__c = :oferta.KS_Canal__c 
                                                      AND KS_Sector__c = :oferta.KS_Sector__c];
            for (KS_Jerarquia_Cliente__c jc : jerCList) {
                
                String inferior = jc.KS_Cliente__c;
                String superior = jc.KS_Cliente_Superior__c;
                superior = superior != null ? superior : 'NULL';
                jerarquia.put(inferior, superior);
            }        
        }
        
        System.debug('-- JCAR ---------------------------------- - SELECT ' + jerarquia.size() + ' jerarquia - ' + jerarquia);

		// ASIGNACIÓN FINAL
        for (String prodK : productos.keySet()) {
            //for (String material : preciosPorMaterial.keySet()) {

            String material = productos.get(prodK).KS_Id_SAP__c;
            
            System.debug('-- JCAR ---------------------------------- - SELECT material - ' + prodK + '//' + material);

            // PRECIOS
            if (preciosPorMaterial.containsKey(prodK)) {
                
                List<KS_Condicion_Comercial__c> ccLst = preciosPorMaterial.get(prodK);
                System.debug('-- JCAR ---------------------------------- - SELECT ' + ccLst.size() + ' ccLst - ' + ccLst);
                
                if (ccLst.size() == 1) {
                    
                    KS_Condicion_Comercial__c condiC = ccLst.get(0);
                    Condicion condi = new Condicion(condiC);
                    if (precios.containsKey(condiC.KS_Material__c)) { condi = precios.get(condiC.KS_Material__c); }
                    condi.setPrecios(condiC);
                    precios.put(condiC.KS_Material__c, condi);
                    
                } else {
                    
                    Boolean precioAsignado = false;
                    for (KS_Condicion_Comercial__c condiC : ccLst) {
                        
                        if (precioAsignado) { continue; }

                        if (condiC.KS_Cliente_Jerarquia__c != null) {
                            
                            String jc = jerarquia.get(condiC.KS_Cliente_Jerarquia__c);                        
                            if (jc == 'NULL' || jc == condiC.KS_Cliente_Jerarquia__c) {
                                Condicion condi = new Condicion(condiC);
                                if (precios.containsKey(condiC.KS_Material__c)) { condi = precios.get(condiC.KS_Material__c); }
                                condi.setPrecios(condiC);
                                precios.put(condiC.KS_Material__c, condi);
                                precioAsignado = true;
                            }
                        } else {
                            
                            if (condiC.KS_Canal__c == oferta.KS_Canal__c && condiC.KS_Tarifa__c == oferta.KS_Lista_de_precios__c/* && condiC.KS_Sector__c == oferta.KS_Sector__c*/) {
                                // JCAR 170124 - Se ha quitado el control de Sector, decisión de SIMON //
                                Condicion condi = new Condicion(condiC);
                                if (precios.containsKey(condiC.KS_Material__c)) { condi = precios.get(condiC.KS_Material__c); }
                                condi.setPrecios(condiC);
                                precios.put(condiC.KS_Material__c, condi);
                                precioAsignado = true;
                            
                            } else if (condiC.KS_Canal__c == null && condiC.KS_Tarifa__c == oferta.KS_Lista_de_precios__c && condiC.KS_Sector__c == oferta.KS_Sector__c) {
                                
                                Condicion condi = new Condicion(condiC);
                                if (precios.containsKey(condiC.KS_Material__c)) { condi = precios.get(condiC.KS_Material__c); }
                                if (condi.Tarifa == null && condi.Canal == null) { 
                                    condi.setPrecios(condiC);
                                    precios.put(condiC.KS_Material__c, condi);
                                }
                                
                            } else if (condiC.KS_Tarifa__c == null && condiC.KS_Canal__c == '20' && condiC.KS_CountryCode__c != null) {
                                
                                Condicion condi = new Condicion(condiC);
                                if (precios.containsKey(condiC.KS_Material__c)) { condi = precios.get(condiC.KS_Material__c); }
                                if (condi.Tarifa == null && condi.Canal == null) { 
                                    condi.setPrecios(condiC);
                                    precios.put(condiC.KS_Material__c, condi);
                                }
                            }
                        }
                    }
                }
            }
            
            // DESCUENTOS
            List<KS_Condicion_Comercial__c> ccLst = new List<KS_Condicion_Comercial__c>();
            String canal = '10';
            if (precios.containsKey(prodK)) { canal = precios.get(prodK).Canal; }
            if (descuentosPorMaterial.containsKey(prodK)) {
                ccLst = descuentosPorMaterial.get(prodK);
            } else {
                KS_Organizacion_Producto__c org = canal == '20' ? orgProdByProd_Exportac.get(prodK) : orgProdByProd_Nacional.get(prodK);
                System.debug('-- JCAR ---------------------------------- - SELECT KS_Organizacion_Producto__c - ' + org);

                if (org.KS_Jerarquia_Producto__c != null && descuentosPorJerProducto1.containsKey(org.KS_Jerarquia_Producto__c)) {
                    ccLst.addAll(descuentosPorJerProducto1.get(org.KS_Jerarquia_Producto__c));
                }
                if (org.KS_Jerarquia_Producto__c != null && descuentosPorJerProducto2.containsKey(org.KS_Jerarquia_Producto__c)) {
                    ccLst.addAll(descuentosPorJerProducto2.get(org.KS_Jerarquia_Producto__c));
                }
                if (org.KS_Jerarquia_Producto__c != null && descuentosPorJerProducto3.containsKey(org.KS_Jerarquia_Producto__c)) {
                    ccLst.addAll(descuentosPorJerProducto3.get(org.KS_Jerarquia_Producto__c));
                }
                if (org.KS_Jerarquia_Producto__c != null && descuentosPorJerProducto4.containsKey(org.KS_Jerarquia_Producto__c)) {
                    ccLst.addAll(descuentosPorJerProducto4.get(org.KS_Jerarquia_Producto__c));
                }
                if (org.KS_Familia__c != null && descuentosPorFamilia.containsKey(org.KS_Familia__c)) {
                    ccLst.addAll(descuentosPorFamilia.get(org.KS_Familia__c));
                }
                if (org.KS_Serie_Gama__c != null && descuentosPorSerie.containsKey(org.KS_Serie_Gama__c)) {
                    ccLst.addAll(descuentosPorSerie.get(org.KS_Serie_Gama__c));
                }
                if (org.KS_Subserie__c != null && descuentosPorSubSerie.containsKey(org.KS_Subserie__c)) {
                    ccLst.addAll(descuentosPorSubSerie.get(org.KS_Subserie__c));
                }
            }
            
            System.debug('-- JCAR ---------------------------------- - SELECT ' + ccLst.size() + ' ccLst - ' + ccLst);
            System.debug('-- JCAR ---------------------------------- - SELECT ' + precios.containsKey(prodK) + ' precios - ' + precios.get(prodK));
            
            Condicion condi = new Condicion();
            if (precios.containsKey(prodK)) { condi = precios.get(prodK); }
            
            Map<String,Integer> indexDto = new Map<String,Integer>();
            for (KS_Condicion_Comercial__c condiC : ccLst) {

                if (condiC.KS_Cliente_Jerarquia__c != null) {
                    
                    Integer idx = 1000;
                    if (indexDto.containsKey(condiC.KS_Condicion__c))
                    { idx = indexDto.get(condiC.KS_Condicion__c); }
                    
                    String jc = jerarquia.get(condiC.KS_Cliente_Jerarquia__c);
                    
                    if (jc == 'NULL' || jc == condiC.KS_Cliente_Jerarquia__c) {
                        condi.setDescuento(condiC);
                        
                    } else if ( jerarquiaIndex.get(jc) < idx ) { // está más abajo en la jerarquia
                        
                        condi.setDescuento(condiC);
                        idx = jerarquiaIndex.get(jc);
                    }
                    indexDto.put(condiC.KS_Condicion__c, idx);
                    
                } else if (condiC.KS_Condicion__c == 'ZDB1') { // No tiene cliente y es B1
                    condi.setDescuento(condiC);
                }
            }
            System.debug('-- JCAR ---------------------------------- - SELECT ' + indexDto.size() + ' indexDto - ' + indexDto);
            precios.put(prodK, condi);
        }
        
        System.debug('-- JCAR ---------------------------------- - SELECT ' + precios.size() + ' precios - ' + precios);
        
        return precios;
    }
    
    
    public class Condicion {
        
        public Decimal ZDB5 {get;set;} // dtoajuste (only canal 20)
        public Decimal ZDB1 {get;set;} // dtobase1
        public Decimal ZDB2 {get;set;} // dtobase2
        public Decimal ZPN0 {get;set;} // precioneto
        public Decimal ZDA8 {get;set;} // dtoadicional1
        public Decimal ZDB6 {get;set;} // dtocampaña
        //public Decimal ZDVR {get;set;} // dtovariedad
        //public Decimal ZDVA {get;set;} // dtovolumen
        public Decimal PR00 {get;set;} // preciobruto
        public String Canal {get;set;} // 10 (nacional) or 20 (exportación)
        public String Tarifa {get;set;} // 10 (nacional) or 20 (exportación)
        
        public Decimal precio() { if (ZPN0 != null) { return ZPN0; } else { return PR00; } }
        public Decimal dtobase1() { return ZDB1; }
        public Decimal dtobase2() { if (Canal == '20') { return ZDB5; } else { return ZDB2; } }
        public Decimal dtoadicional1() { return ZDA8; }
        public Decimal dtocampaign() { return ZDB6; }
        //public Decimal dtovariedad() { return ZDVR; }
        //public Decimal dtovolumen() { return ZDVA; }
        
        public Condicion() {}
        public Condicion(KS_Condicion_Comercial__c condi) {
            
            Canal = condi.KS_Canal__c;// != null ? condi.KS_Canal__c : '10';
            Tarifa = condi.KS_Tarifa__c;
            if (condi.KS_Condicion__c == 'PR00') { PR00 = condi.KS_Importe__c; }
            if (condi.KS_Condicion__c == 'ZPN0') { ZPN0 = condi.KS_Importe__c; }
            if (condi.KS_Condicion__c == null && Canal == '20') { PR00 = condi.KS_Importe__c; }
            
            System.debug('-- JCAR ---------------------------------- - new Condicion ' + this + ' FROM KS_Condicion_Comercial__c - ' + condi);
        }
        public void setPrecios(KS_Condicion_Comercial__c condi) {
            Canal = condi.KS_Canal__c;// != null ? condi.KS_Canal__c : '10';
            if (condi.KS_Condicion__c == 'PR00') { PR00 = condi.KS_Importe__c; }
            if (condi.KS_Condicion__c == 'ZPN0') { ZPN0 = condi.KS_Importe__c; }            
        }
        public void setDescuento(KS_Condicion_Comercial__c condi) {
            if (condi.KS_Condicion__c == 'ZDB1') { ZDB1 = condi.KS_Porcentaje__c; }
            if (condi.KS_Condicion__c == 'ZDB2') { ZDB2 = condi.KS_Porcentaje__c; }
            if (condi.KS_Condicion__c == 'ZDB5') { ZDB5 = condi.KS_Porcentaje__c; }
            if (condi.KS_Condicion__c == 'ZDA8') { ZDA8 = condi.KS_Porcentaje__c; }
            if (condi.KS_Condicion__c == 'ZDB6') { ZDB6 = condi.KS_Porcentaje__c; }
            //if (condi.KS_Condicion__c == 'ZDVR') { ZDVR = condi.KS_Porcentaje__c; }
            //if (condi.KS_Condicion__c == 'ZDVA') { ZDVA = condi.KS_Porcentaje__c; }
        }
        
        public OpportunityLineItem toProducto(OpportunityLineItem opp) {

            System.debug('-- JCAR ---------------------------------- - SET OpportunityLineItem FROM - ' + this);
            
			opp = opp != null ? opp : new OpportunityLineItem();
            Canal = Canal != null ? Canal : '10';
            
            opp.UnitPrice = precio();
            opp.KS_Dto_base_1__c = dtobase1();
            opp.KS_Dto_base_2__c = dtobase2();
            opp.KS_Dto_adicional_1__c = dtoadicional1();
            opp.KS_Dto_Campaign__c = dtocampaign();
            //opp.KS_Dto_Variedad__c = dtovariedad();
            //opp.KS_dto_volumen__c = dtovolumen();
            opp.KS_ZPN0__c = ZPN0 != null;
            
            return opp;
        }
    }
}