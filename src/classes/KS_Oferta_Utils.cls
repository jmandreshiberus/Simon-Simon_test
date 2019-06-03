global without sharing class KS_Oferta_Utils {
    
    public KS_Oferta_Utils(ApexPages.StandardController controller) { } // empty constructor
    
    @RemoteAction
    global static String callSetValorLinea(String idLinea, String nombreCampo, String valor, String ficha, String idOferta) {
        
        System.debug('-- JCAR ---------------------------------- - callSetValorLinea ficha - ' + idOferta);
        System.debug('-- JCAR ---------------------------------- - callSetValorLinea ficha - ' + ficha);
        System.debug('-- JCAR ---------------------------------- - callSetValorLinea idLinea - ' + idLinea);
        System.debug('-- JCAR ---------------------------------- - callSetValorLinea campo - ' + nombreCampo);
        System.debug('-- JCAR ---------------------------------- - callSetValorLinea valor - ' + valor);
        
        String result = setValorLinea(idLinea, nombreCampo, valor);
        if ( result != null ) {return result;}
        return getTotalFichaOferta(idOferta, ficha);
    }
    
    global static String setValorLinea(String idLinea, String nombreCampo, String valor) {

        if ( idLinea != null && idLinea != '') {
			
            OpportunityLineItem oli = new OpportunityLineItem();
            try { oli.ID = idLinea; }
            catch (Exception e) {return e.getMessage();}

            if (nombreCampo == 'UnitPrice') {
                valor = valor.replace(',', '.');
                try { oli.UnitPrice = Decimal.valueOf(valor); } 
                catch (Exception e) {return e.getMessage();}
            }
            if (nombreCampo == 'KS_Orden__c') {
                try { oli.KS_Orden__c = Decimal.valueOf(valor); } 
                catch (Exception e) {return e.getMessage();}
            } else
            if (nombreCampo == 'KS_Cantidad__c') {
                try { oli.KS_Cantidad__c = Decimal.valueOf(valor); } 
                catch (Exception e) {return e.getMessage();}
            } else
            if (nombreCampo == 'KS_Dto_adicional_2__c') {
                valor = valor.replace(',', '.');
                try { oli.KS_Dto_adicional_2__c = Decimal.valueOf(valor); } 
                catch (Exception e) {return e.getMessage();}
            } else
            if (nombreCampo == 'KS_Dto_Instalador__c') {
                valor = valor.replace(',', '.');
                try { oli.KS_Dto_Instalador__c = Decimal.valueOf(valor); } 
                catch (Exception e) {return e.getMessage();}
            } else
            if (nombreCampo == 'KS_Dto_cliente_final__c') {
                valor = valor.replace(',', '.');
                try { oli.KS_Dto_cliente_final__c = Decimal.valueOf(valor); } 
                catch (Exception e) {return e.getMessage();}
            } else
            if (nombreCampo == 'KS_Prescrito__c') {
                try { oli.KS_Prescrito__c = Boolean.valueOf(valor); } 
                catch (Exception e) {return e.getMessage();}
            } else
            if (nombreCampo == 'KS_Destinatario__c') {
                if (valor != null && valor.trim() != '--Ninguno--' && valor.trim() != '') {
                    try { oli.KS_Destinatario__c = valor; } 
                    catch (Exception e) {return e.getMessage();}
                    oli.KS_Material_sin_cargo__c = true;
                    if ( valor == 'Distribuidor') { 
                        oli.KS_Dto_adicional_2__c = 100;
                        oli.KS_Dto_Instalador__c = null;
                        oli.KS_Dto_cliente_final__c = null;
                    }
                    if ( valor == 'Instalador') { 
                        oli.KS_Dto_adicional_2__c = 100;
                        oli.KS_Dto_Instalador__c = 100;
                        oli.KS_Dto_cliente_final__c = null;
                    }
                    if ( valor == 'Cliente final') { 
                        oli.KS_Dto_adicional_2__c = 100;
                        oli.KS_Dto_Instalador__c = 100;
                        oli.KS_Dto_cliente_final__c = 100;
                    }
                } else {
                    oli.KS_Material_sin_cargo__c = false;
                    oli.KS_Destinatario__c = null;
                    oli.KS_Dto_adicional_2__c = null;
                    oli.KS_Dto_Instalador__c = null;
                    oli.KS_Dto_cliente_final__c = null;
                }
                
            } else
            if (nombreCampo == 'KS_Referencia__c') {
                try { oli.KS_Referencia__c = valor; } 
                catch (Exception e) {return e.getMessage();}
            }
            
            System.debug('-- JCAR ---------------------------------- - setValorLinea OpportunityLineItem - ' + oli);
            try { if (oli.ID != null) {update oli;} } catch(Exception e) { return e.getMessage(); }
        }
        
        return null;
    }
    
    public class TotalesFicha {
        
        public Decimal neto {get;set;}
        public Decimal pvp {get;set;}
        public Decimal margen {get;set;}
        
        public TotalesFicha() {}
        public TotalesFicha(List<OpportunityLineItem> oliLst) {calc(oliLst);}
        
        public void reset() {
            neto = 0; pvp = 0; margen = 0;
        }
        public void calc(List<OpportunityLineItem> oliLst) {
            
            reset();
            for (OpportunityLineItem oli : oliLst) {
                System.debug('-- JCAR ----------------------------------');
                System.debug('-- JCAR ---------------------------------- - calc KS_Neto_por_fila__c = ' + oli.KS_Neto_por_fila__c);
                System.debug('-- JCAR ---------------------------------- - calc TotalPrice = ' + oli.TotalPrice);
                System.debug('-- JCAR ----------------------------------');
                neto += oli.KS_Neto_por_fila__c != null ? oli.KS_Neto_por_fila__c : 0;
                pvp += oli.TotalPrice != null ? oli.TotalPrice : 0;
            }
            
            margen = pvp > 0 ? (1-(neto/pvp))*100 : 0;
            margen = margen != null && margen != 0 ? margen.setscale(2) : 0; // Redondeamos a dos decimales
            System.debug('-- JCAR ---------------------------------- - calc TotalesFicha = ' + this);
        }
    }
    
    global static String getTotalFichaOferta(String idOferta, String ficha) {
        
        System.debug('-- JCAR ---------------------------------- getTotalFichaOferta - idOferta ' + idOferta);
        System.debug('-- JCAR ---------------------------------- getTotalFichaOferta - ficha ' + ficha);
        if (idOferta == null) {return null;} if (idOferta.trim() == '') {return null;}
        if (ficha == null) {return null;} if (ficha.trim() == '') {return null;} if (!ficha.isNumeric()) {return null;}
        
        List<OpportunityLineItem> lineasOferta = 
            [SELECT Id, OpportunityId, KS_Producto__c, Product2Id, ProductCode, Name, Quantity, KS_Cantidad__c, TotalPrice, UnitPrice, ListPrice, ServiceDate, Description, 
             KS_Nombre__c, KS_Dto_base_1__c, KS_Dto_base_2__c, KS_Dto_adicional_1__c, KS_Dto_adicional_2__c, KS_precio_neto__c, KS_Descuento_neto__c, 
             KS_Dto_volumen__c, KS_Material_sin_cargo__c, KS_Ficha__c, KS_Prescrito__c, KS_Dto_Instalador__c, KS_Dto_cliente_final__c, 
             KS_Destinatario__c, CurrencyIsoCode, KS_Cantidad_Ficha__c, KS_Cantidad_Total__c, PricebookEntryId, KS_Material__c,
             KS_Comentarios__c, KS_Competencia__c, KS_Competidor__c, KS_Aprobacion__c, KS_Neto_Base__c, KS_Dto_Logistico__c,
             KS_Dto_SinCargo__c, KS_Dest_ClieFinal__c, KS_Dest_Distribuidor__c, KS_Dest_Instalador__c, KS_Referencia__c, KS_Orden__c,
             KS_Neto_por_fila__c, KS_Neto_Unitario__c, KS_Neto_Unitario_Cliente_Final__c, Ks_Neto_Unitario_Instalador__c, KS_Ficha_Nombre__c
             FROM OpportunityLineItem 
             WHERE OpportunityID = :idOferta AND KS_Ficha__c = :Decimal.valueOf(ficha)];
        
        TotalesFicha totales = new TotalesFicha(lineasOferta);
		return 'KSEVERYTHINGISFINE_' + totales.neto + '_' + totales.margen + '_' + totales.pvp;
    }
    
    global static String calcApproval(Opportunity oferta) {

        String errorTextOferta = null;
        String errorTextFicha = null;
        
        setTerritoryOferta(oferta);
        if (oferta.Territory2Id == null) { return null; }
        System.debug('-- JCAR ---------------------------------- - TerritoryId? ' + oferta.Territory2Id);
        
        Map<String,ID> terrType = new Map<String,ID>();
        List<Territory2Type> terrLst = [SELECT ID, DeveloperName FROM Territory2Type];
        for (Territory2Type tp : terrLst) {
            terrType.put(tp.DeveloperName, tp.ID);
        }

        List<KS_Organizacion_Cliente__c> orgClienteOferta = 
            [SELECT Id, KS_Responsable__c 
             FROM KS_Organizacion_Cliente__c 
             WHERE Id = :oferta.KS_Organizacion_Cliente__c
            ];
        ID responsable = orgClienteOferta.size()>0 ? orgClienteOferta.get(0).KS_Responsable__c : null;
        
        System.debug('-- JCAR ---------------------------------- - responsable? ' + responsable);
        
        Map<String,String> claveProducto = new Map<String,String>();
        Map<String,KS_Organizacion_Producto__c> mapOrgProducto = new Map<String,KS_Organizacion_Producto__c>();
        
        List<OpportunityLineItem> lineasOferta = 
            [SELECT Id, OpportunityId, KS_Producto__c, Product2Id, ProductCode, Name, Quantity, KS_Cantidad__c, TotalPrice, UnitPrice, ListPrice, ServiceDate, Description, 
             KS_Nombre__c, KS_Dto_base_1__c, KS_Dto_base_2__c, KS_Dto_adicional_1__c, KS_Dto_adicional_2__c, KS_precio_neto__c, KS_Descuento_neto__c, 
             KS_Dto_volumen__c, KS_Material_sin_cargo__c, KS_Ficha__c, KS_Prescrito__c, KS_Dto_Instalador__c, KS_Dto_cliente_final__c, 
             KS_Destinatario__c, CurrencyIsoCode, KS_Cantidad_Ficha__c, KS_Cantidad_Total__c, PricebookEntryId, KS_Material__c,
             KS_Comentarios__c, KS_Competencia__c, KS_Competidor__c, KS_Aprobacion__c, KS_Neto_Base__c, KS_Dto_Logistico__c,
             KS_Dto_SinCargo__c, KS_Dest_ClieFinal__c, KS_Dest_Distribuidor__c, KS_Dest_Instalador__c, KS_Referencia__c, KS_Orden__c,
             KS_Neto_por_fila__c, KS_Neto_Unitario__c, KS_Neto_Unitario_Cliente_Final__c, Ks_Neto_Unitario_Instalador__c, KS_Ficha_Nombre__c
             FROM OpportunityLineItem 
             WHERE OpportunityID = :oferta.ID];
        
        Set<ID> productosID = new Set<ID>();
        for (OpportunityLineItem oli : lineasOferta) {
            productosID.add(oli.Product2Id);
        }
        
        // Mapeo organizacionesProducto
        claveProducto = new Map<String,String>();
        mapOrgProducto = new Map<String,KS_Organizacion_Producto__c>();
        List<KS_Organizacion_Producto__c> orgProductos = [SELECT ID,KS_Producto__c,KS_Subserie__c,KS_Serie_Gama__c,KS_Familia__c
                                                          FROM KS_Organizacion_Producto__c
                                                          WHERE KS_Producto__c IN :productosID 
                                                          AND KS_Organizacion_de_Ventas__c = :oferta.KS_Organizacion_de_ventas__c
                                                          AND KS_Canal_de_distribucion__c = :oferta.KS_Canal__c
                                                          AND KS_Sector__c = :oferta.KS_Sector__c];
        System.debug('-- JCAR ---------------------------------- - ' + orgProductos.size() + ' orgProductos - ' + orgProductos);
        
        for (KS_Organizacion_Producto__c orgP : orgProductos) {
            String clave = ''; // Serie+Subserie+Familia
            clave += orgP.KS_Serie_Gama__c != null ? orgP.KS_Serie_Gama__c : '';
            clave += orgP.KS_Subserie__c != null ? orgP.KS_Subserie__c : '';
            clave += orgP.KS_Familia__c != null ? orgP.KS_Familia__c : '';
            claveProducto.put(orgP.KS_Producto__c, clave);
            mapOrgProducto.put(orgP.KS_Producto__c, orgP);
        }
        
        Map<String,Set<ID>> mapProductos = new Map<String,Set<ID>>();
        Map<String,Decimal> mapProductosQnt = new Map<String,Decimal>();
        Map<String,Decimal> mapProductosDto = new Map<String,Decimal>();
        Map<String,Decimal> mapProductosDtoMSC = new Map<String,Decimal>();
        Map<ID,OpportunityLineItem> prodOppLine = new Map<ID,OpportunityLineItem>();
        
        Map<String,Decimal> mapProductosQntMrgn = new Map<String,Decimal>();        
        List<OpportunityLineItem> lineasOportunidad = new List<OpportunityLineItem>();
        List<Opportunity> ofertasLst = new List<Opportunity>();
        Map<ID,String> orgVentMap = new Map<ID,String>();
        Map<ID,String> paisesMap = new Map<ID,String>();
        List<String> clavesSerieFamilia = new List<String>();
        Map<ID,ID> responsables = new Map<ID,ID>();
        
        Set<String> serieSet = new Set<String>(); List<String> series = new List<String>();
        Set<String> subserieSet = new Set<String>(); List<String> subseries = new List<String>();
        Set<String> familiaSet = new Set<String>(); List<String> familias = new List<String>();
        
        System.debug('-- JCAR ---------------------------------- - ' + claveProducto.size() + ' claveProducto - ' + claveProducto);
        
        oferta.KS_Nivel2__c = false; oferta.KS_Nivel3__c = false; oferta.KS_Nivel4__c = false;
        oferta.KS_Resp_Conectividad__c = null; oferta.KS_Resp_Iluminacion__c = null;
        oferta.KS_Resp_Jefe_de_Area__c = null; oferta.KS_Resp_Negocio_Iberia_2__c = null;
        oferta.KS_Resp_negocio_iberia__c = null; oferta.KS_Resp_resto_de_gamas__c = null;
        oferta.KS_Resp_Sist_Control__c = null; oferta.KS_Resp_Vehiculo_Electrico__c = null;
        
        for (OpportunityLineItem prOfer : lineasOferta) {
            
            if (claveProducto.containsKey(prOfer.Product2Id)) {
                
                String clave = claveProducto.get(prOfer.Product2Id);
                
                Set<ID> productos = new Set<ID>();
                if (mapProductos.containsKey(clave))
                { productos = mapProductos.get(clave); }
                productos.add(prOfer.Product2Id); mapProductos.put(clave, productos);
                
                Decimal qnt = 0;
                if (prOfer.KS_Material_sin_cargo__c) {
                    
                    if ( mapProductosQntMrgn.containsKey(clave) ) 
                    { qnt = mapProductosQntMrgn.get(clave); }
                    mapProductosQntMrgn.put(clave, qnt + prOfer.KS_Cantidad__c);                            
                }
                qnt = 0; // Total
                if ( mapProductosQnt.containsKey(clave) ) 
                { qnt = mapProductosQnt.get(clave); }
                mapProductosQnt.put(clave, qnt + prOfer.KS_Cantidad__c); 
                
                lineasOportunidad.add(prOfer);
                ofertasLst.add(oferta);
                clavesSerieFamilia.add(clave);
                orgVentMap.put(oferta.ID,oferta.KS_Organizacion_de_ventas__c);
                paisesMap.put(oferta.ID,oferta.KS_Pais__c);
                responsables.put(oferta.ID,responsable);
                
                KS_Organizacion_Producto__c orgP = mapOrgProducto.get(prOfer.Product2Id);
                serieSet.add(orgP.KS_Serie_Gama__c);
                subSerieSet.add(orgP.KS_Subserie__c);
                familiaSet.add(orgP.KS_Familia__c);
            }
        }
        
        series.addAll(serieSet);
        subseries.addAll(subSerieSet);
        familias.addAll(familiaSet);
        
        System.debug('-- JCAR ---------------------------------- - ' + lineasOportunidad.size() + ' lineasOportunidad - ' + lineasOportunidad);
        System.debug('-- JCAR ---------------------------------- - ' + responsables.size() + ' responsables - ' + responsables);      
        System.debug('-- JCAR ---------------------------------- - ' + ofertasLst.size() + ' ofertasLst - ' + ofertasLst);
        System.debug('-- JCAR ---------------------------------- - ' + orgVentMap.size() + ' orgVentMap - ' + orgVentMap);
        System.debug('-- JCAR ---------------------------------- - ' + paisesMap.size() + ' paisesMap - ' + paisesMap);
        System.debug('-- JCAR ---------------------------------- - ' + clavesSerieFamilia.size() + ' clavesSerieFamilia - ' + clavesSerieFamilia);        
        
        Set<String> serProducto = new Set<String>();
        Set<String> famProducto = new Set<String>();
        
        for (OpportunityLineItem prOfer : lineasOportunidad) {
            
            prOfer.KS_Necesita_aprobacion__c = false;
            if (prOfer.KS_Dto_adicional_2__c != null && prOfer.KS_Dto_adicional_2__c > 0 && claveProducto.containsKey(prOfer.Product2Id)) {
                
                // En caso de que sea material sin cargo hay que dividir su 100% por el total de productos de esa subserie
                String clave = claveProducto.get(prOfer.Product2Id);
                Decimal dtoPr = prOfer.KS_Dto_adicional_2__c;
                if (prOfer.KS_Material_sin_cargo__c) {
                    
                    /*Decimal total = mapProductosQnt.get(clave); Decimal totalMrgn = mapProductosQntMrgn.get(clave);
                    dtoPr = (totalMrgn/total)*100;*/
                    if ( prOfer.KS_Dest_Distribuidor__c ) { dtoPr = (prOfer.TotalPrice / oferta.KS_Distribuidor_importe_PVP__c) * prOfer.KS_Dto_SinCargo__c; }
                    if ( prOfer.KS_Dest_Instalador__c ) { dtoPr = (prOfer.TotalPrice / oferta.KS_Instalador_Importe_PVP__c) * prOfer.KS_Dto_SinCargo__c; }
                    if ( prOfer.KS_Dest_ClieFinal__c ) { dtoPr = (prOfer.TotalPrice / oferta.KS_Cliente_final_Importe_PVP__c) * prOfer.KS_Dto_SinCargo__c; }                    
                    
                    Decimal dtoad2 = mapProductosDtoMSC.containsKey(clave) ? mapProductosDtoMSC.get(clave) : 0;
                    dtoad2 = dtoPr > dtoad2 ? dtoPr : dtoad2;
                    mapProductosDtoMSC.put(clave, dtoad2);
                
                } else {
                    Decimal dtoad2 = mapProductosDto.containsKey(clave) ? mapProductosDto.get(clave) : 0;
                    dtoad2 = dtoPr > dtoad2 ? dtoPr : dtoad2;
                    mapProductosDto.put(clave, dtoad2);                    
                }
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - ' + mapProductosDtoMSC.size() + ' mapProductosDtoMSC - ' + mapProductosDtoMSC);
        System.debug('-- JCAR ---------------------------------- - ' + mapProductosDto.size() + ' mapProductosDto - ' + mapProductosDto);
        System.debug('-- JCAR ---------------------------------- - ' + mapProductos.size() + ' mapProductos - ' + mapProductos);
        
        if (mapProductosDto.size() > 0 || mapProductosDtoMSC.size() > 0) {
            KS_Aprobaciones_Controller.setAprobacionesOferta(mapProductosDto, mapProductosDtoMSC, mapProductos, responsables, 
                                                             lineasOportunidad, ofertasLst, orgVentMap, clavesSerieFamilia,
                                                             subseries, series, familias, paisesMap);
        }         

        System.debug('-- JCAR ---------------------------------- - UPSERT ' + lineasOportunidad.size() + ' productos_oferta - ' + lineasOportunidad);
        Database.UpsertResult[] results = Database.upsert(lineasOportunidad, false);
        
        Set<Decimal> errorProfer = new Set<Decimal>();
        Integer index = 0;
        for(Database.UpsertResult res : results) {
            
            if(!res.isSuccess()){ 
                
                OpportunityLineItem ol = lineasOportunidad.get(index);
                System.debug('-- JCAR ---------------------------------- - ERROR producto_oferta - ' + ol.ID + ' - ' + res);
                errorTextFicha = 'Fallo al actualizar línea de oportunidad. FICHA: ' 
                    + ol.KS_Ficha__c + ' PRODUCTO: ' + OL.KS_Material__c + ' -- ' + res.getErrors()[0].getMessage();
                
                errorProfer.add(ol.KS_Ficha__c);
                return errorTextFicha;
            }
            index++;
        }        
        
        Database.UpsertResult result = Database.upsert(oferta, false);
        
        errorTextOferta = null;
        if (!result.isSuccess()) {
            System.debug('-- JCAR ---------------------------------- - oferta UPSERT ERROR ' + result.getErrors()[0].getMessage());
            errorTextOferta = 'Fallo en Oferta: ' + result.getErrors()[0].getMessage();
            return errorTextOferta;
        }        
        
        return null;
    }
    
    global static void setTerritoryOferta(Opportunity oferta) {
        List<ObjectTerritory2Association> taccLst = 
            [SELECT Id, ObjectId, Territory2Id, Territory2.KS_Organizacion_Ventas__c, SobjectType
             FROM ObjectTerritory2Association WHERE ObjectId = :oferta.KS_Distribuidor__c
             AND Territory2.KS_Organizacion_Ventas__c = :oferta.KS_Organizacion_de_ventas__c];
        System.debug('-- JCAR ---------------------------------- - setTerritoryOferta ' + taccLst.size() + ' taccLst - ' + taccLst);
        if (!taccLst.isEmpty())
        {  oferta.Territory2Id = taccLst[0].Territory2Id; }
    }
    
    global static String calcDtoLogistic(Opportunity oferta) {
        
        List<OpportunityLineItem> productosLst = 
            [SELECT Id, OpportunityId, KS_Producto__c, Product2Id, ProductCode, Name, Quantity, KS_Cantidad__c, TotalPrice, UnitPrice, ListPrice, ServiceDate, Description, 
             KS_Nombre__c, KS_Dto_base_1__c, KS_Dto_base_2__c, KS_Dto_adicional_1__c, KS_Dto_adicional_2__c, KS_precio_neto__c, KS_Descuento_neto__c, 
             KS_Dto_volumen__c, KS_Material_sin_cargo__c, KS_Ficha__c, KS_Prescrito__c, KS_Dto_Instalador__c, KS_Dto_cliente_final__c, 
             KS_Destinatario__c, CurrencyIsoCode, KS_Cantidad_Ficha__c, KS_Cantidad_Total__c, PricebookEntryId, KS_Material__c,
             KS_Comentarios__c, KS_Competencia__c, KS_Competidor__c, KS_Aprobacion__c, KS_Neto_Base__c, KS_Dto_Logistico__c,
             KS_Dto_SinCargo__c, KS_Dest_ClieFinal__c, KS_Dest_Distribuidor__c, KS_Dest_Instalador__c, KS_Referencia__c, KS_Orden__c,
             KS_Neto_por_fila__c, KS_Neto_Unitario__c, KS_Neto_Unitario_Cliente_Final__c, Ks_Neto_Unitario_Instalador__c, KS_Ficha_Nombre__c
             FROM OpportunityLineItem 
             WHERE OpportunityID = :oferta.ID];
        
        Set<ID> productosID = new Set<ID>();
        for (OpportunityLineItem oli : productosLst) {
            productosID.add(oli.Product2Id);
        }
        
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + productosID.size() + ' productosID - ' + productosID);
        
        Map<String, Integer> jerarquiaIndex = new Map<String, Integer>();
        Map<String, String> jerarquia = new Map<String, String>(); Set<String> jerarquiaOferta = new Set<String>();
        // Jerarquía de la cuenta de la oferta
        Id cuentActual = oferta.KS_Distribuidor__c; Id cuentSuperior = null;
        Boolean stop = false;
        Integer index = 1;
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

        String canal = oferta.KS_Canal__c != null ? oferta.KS_Canal__c : '10';
        
        List<String> seriesOferta = new List<String>();
        Map<String,Set<ID>> serieProductos = new Map<String,Set<ID>>();
        Map<String,Decimal> serieImporteTotal = new Map<String,Decimal>();
        List<String> familiasOferta = new List<String>();
        Map<String,Set<ID>> familiaProductos = new Map<String,Set<ID>>();
        Map<String,Decimal> familiaImporteTotal = new Map<String,Decimal>();

        // GET ORGANIZACIONES PRODUCTO
        Map<ID,KS_Organizacion_Producto__c> orgProductos = new Map<ID,KS_Organizacion_Producto__c>();
        List<ID> idprod = new List<ID>(); idprod.addAll(productosID);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR canal - ' + canal);
        List<KS_Organizacion_Producto__c> orgProductosLst = [SELECT ID,KS_Producto__c,KS_Serie_Gama__c,KS_Familia__c FROM KS_Organizacion_Producto__c 
                                                          WHERE KS_Producto__c in :idprod AND KS_Canal_de_distribucion__c = :canal];
        for (KS_Organizacion_Producto__c orgrod : orgProductosLst) {
            orgProductos.put(orgrod.KS_Producto__c, orgrod);
        }
        
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + productosLst.size() + ' productosLst - ' + productosLst);
        
        // POR SERIE Y POR FAMILIA        
        for (OpportunityLineItem prOfer : productosLst) {
            
            KS_Organizacion_Producto__c orgrod = orgProductos.get(prOfer.KS_Producto__c);
            
            if (orgrod != null && prOfer.Product2Id != null && prOfer.KS_Neto_Base__c != null && prOfer.KS_Cantidad__c != null  && prOfer.KS_Cantidad_Ficha__c != null) {
                
                Set<ID> oppSerie = new Set<ID>();
                Decimal importeSerie = 0;
                if (orgrod.KS_Serie_Gama__c != null && serieProductos.containsKey(orgrod.KS_Serie_Gama__c)) {
                    oppSerie = serieProductos.get(orgrod.KS_Serie_Gama__c);
                }
                oppSerie.add(prOfer.Product2Id);
                serieProductos.put(orgrod.KS_Serie_Gama__c, oppSerie);
                if (orgrod.KS_Serie_Gama__c != null && serieImporteTotal.containsKey(orgrod.KS_Serie_Gama__c)) {
                    importeSerie = serieImporteTotal.get(orgrod.KS_Serie_Gama__c);
                }
                importeSerie = importeSerie + (prOfer.KS_Neto_Base__c * prOfer.KS_Cantidad__c * prOfer.KS_Cantidad_Ficha__c);
                serieImporteTotal.put(orgrod.KS_Serie_Gama__c, importeSerie);
                
                Set<ID> oppFamilia = new Set<ID>();
                Decimal importeFamilia = 0;
                if (orgrod.KS_Familia__c != null && familiaProductos.containsKey(orgrod.KS_Familia__c)) {
                    oppFamilia = familiaProductos.get(orgrod.KS_Familia__c);
                }
                oppFamilia.add(prOfer.Product2Id);
                familiaProductos.put(orgrod.KS_Familia__c, oppFamilia);
                if (orgrod.KS_Familia__c != null && familiaImporteTotal.containsKey(orgrod.KS_Familia__c)) {
                    importeFamilia = familiaImporteTotal.get(orgrod.KS_Familia__c);
                }
                importeFamilia = importeFamilia + (prOfer.KS_Neto_Base__c * prOfer.KS_Cantidad__c * prOfer.KS_Cantidad_Ficha__c);
                familiaImporteTotal.put(orgrod.KS_Familia__c, importeFamilia);
            }
        }
        
        seriesOferta.addAll(serieProductos.keySet());
        familiasOferta.addAll(familiaProductos.keySet());
        List<String> cuentasOferta = new List<String>(); cuentasOferta.addAll(jerarquiaOferta);
        
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + familiasOferta.size() + ' familiasOferta - ' + familiasOferta);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + seriesOferta.size() + ' seriesOferta - ' + seriesOferta);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + cuentasOferta.size() + ' cuentasOferta - ' + cuentasOferta);
        
        // CONDICIONES COMERCIALES (variedad y volumen) de la OFERTA
        List<KS_Condicion_Comercial__c> ccOfertaLst = [SELECT ID,KS_Condicion__c,KS_Serie_single__c,KS_Familia__c,KS_Cliente_Jerarquia__c,
                                                       KS_Escala_Importe__c,KS_Escala_Unidades__c,KS_Porcentaje__c FROM KS_Condicion_Comercial__c
                                                       WHERE (KS_Familia__c in :familiasOferta OR KS_Serie_single__c in :seriesOferta)
                                                       AND (KS_Cliente_Jerarquia__c IN :cuentasOferta OR KS_Cliente_Jerarquia__c = NULL)
                                                       AND (KS_Condicion__c = 'ZDVA' OR KS_Condicion__c = 'ZDVR')
                                                       AND (KS_Canal__c = :canal OR KS_Canal__c = NULL)
                                                       AND (KS_Familia__c != NULL OR KS_Serie_single__c != NULL)];
        
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + ccOfertaLst.size() + ' ccOfertaLst - ' + ccOfertaLst);
        
        if (ccOfertaLst.isEmpty()) {return null;}
        
        Set<Integer> jerarquiaKey = new Set<Integer>();

        Map<String,Integer> indexSerie = new Map<String,Integer>();
        Map<String,Integer> indexFamilia = new Map<String,Integer>();
        
        Map<String,KS_Condicion_Comercial__c> serieVariedad = new Map<String,KS_Condicion_Comercial__c>();
        Map<String,KS_Condicion_Comercial__c> serieVolumen = new Map<String,KS_Condicion_Comercial__c>();
        Map<String,KS_Condicion_Comercial__c> familiaVariedad = new Map<String,KS_Condicion_Comercial__c>();
        Map<String,KS_Condicion_Comercial__c> familiaVolumen = new Map<String,KS_Condicion_Comercial__c>();       
        
        Map<Integer, KS_Condicion_Comercial__c> mapUnidadeSerieCC = new Map<Integer, KS_Condicion_Comercial__c>();
        Map<Integer, KS_Condicion_Comercial__c> mapImporteSerieCC = new Map<Integer, KS_Condicion_Comercial__c>();
        Map<Integer, KS_Condicion_Comercial__c> mapUnidadeFamiliaCC = new Map<Integer, KS_Condicion_Comercial__c>();
        Map<Integer, KS_Condicion_Comercial__c> mapImporteFamiliaCC = new Map<Integer, KS_Condicion_Comercial__c>();        
        
        Map<Integer, Set<String>> mapUnidadeSerie = new Map<Integer, Set<String>>();
        Map<Integer, Set<String>> mapImporteSerie = new Map<Integer, Set<String>>();
        Map<Integer, Set<String>> mapUnidadeFamilia = new Map<Integer, Set<String>>();
        Map<Integer, Set<String>> mapImporteFamilia = new Map<Integer, Set<String>>();
        
        for (KS_Condicion_Comercial__c cc : ccOfertaLst) {
            
            Map<String, KS_Condicion_Comercial__c> logisticMap = null;
            Map<Integer, Set<String>> mapJerarquiaSet = null;
            Map<Integer, KS_Condicion_Comercial__c> mapJerarquiaCC = null;
            
            if (cc.KS_Condicion__c == 'ZDVR' && cc.KS_Serie_single__c != null) { // Variedad
                logisticMap = serieVariedad;
                mapJerarquiaSet = mapUnidadeSerie;
                mapJerarquiaCC = mapUnidadeSerieCC;
            } else if (cc.KS_Condicion__c == 'ZDVA' && cc.KS_Serie_single__c != null) { // Volumen 
                logisticMap = serieVolumen;
                mapJerarquiaSet = mapImporteSerie;
                mapJerarquiaCC = mapImporteSerieCC;
            } else if (cc.KS_Condicion__c == 'ZDVR' && cc.KS_Familia__c != null) { // Variedad
                logisticMap = familiaVariedad;
                mapJerarquiaSet = mapUnidadeFamilia;
                mapJerarquiaCC = mapUnidadeFamiliaCC;
            } else if (cc.KS_Condicion__c == 'ZDVA' && cc.KS_Familia__c != null) { // Volumen 
                logisticMap = familiaVolumen;
                mapJerarquiaSet = mapImporteFamilia;
                mapJerarquiaCC = mapImporteFamiliaCC;
            }
            
            Map<String,Integer> indexSerieFamilia = null;
            if (cc.KS_Serie_single__c != null) {
                indexSerieFamilia = indexSerie;
            } else if (cc.KS_Familia__c != null) {
                indexSerieFamilia = indexFamilia;
            }
                        
            String valor = cc.KS_Serie_single__c != null ? cc.KS_Serie_single__c : cc.KS_Familia__c;
            
            Integer idx = 0;
            Set<String> sfSet = new Set<String>();
            if (mapJerarquiaSet.containsKey(idx)) {
                sfSet = mapJerarquiaSet.get(idx);
            }
            
            if (logisticMap.containsKey(valor)) {
                
                if (indexSerieFamilia.containsKey(valor))
                { idx = indexSerieFamilia.get(valor); }
                
                String jc = jerarquia.get(cc.KS_Cliente_Jerarquia__c);
                
                if (jc == 'NULL' || jc == cc.KS_Cliente_Jerarquia__c) {
                    logisticMap.put(valor, cc);
                    sfSet.add(valor);
                    
                } else if ( jerarquiaIndex.get(jc) < idx ) { // está más abajo en la jerarquia
                    
                    logisticMap.put(valor, cc);
                    idx = jerarquiaIndex.get(jc);
                    sfSet.add(valor);
                }
                
                indexSerieFamilia.put(valor, idx);
                jerarquiaKey.add(idx);
                
            } else {
                
                logisticMap.put(valor, cc);
                jerarquiaKey.add(idx);
                sfSet.add(valor);
            }
            
            mapJerarquiaSet.put(idx, sfSet);
            
            KS_Condicion_Comercial__c cj = new KS_Condicion_Comercial__c();
            cj.KS_Porcentaje__c = cc.KS_Porcentaje__c;
            if (cc.KS_Condicion__c == 'ZDVR') {
                cj.KS_Escala_Unidades__c = cc.KS_Escala_Unidades__c;
            } else if (cc.KS_Condicion__c == 'ZDVA') {
                cj.KS_Escala_Importe__c = cc.KS_Escala_Importe__c;
            }
            mapJerarquiaCC.put(idx, cj);
                
            if (cc.KS_Serie_single__c != null) {
                indexSerie = indexSerieFamilia;
            } else if (cc.KS_Familia__c != null) {
                indexFamilia = indexSerieFamilia;
            }            
            
            if (cc.KS_Condicion__c == 'ZDVR' && cc.KS_Serie_single__c != null) { // Variedad
                serieVariedad = logisticMap;
                mapUnidadeSerie = mapJerarquiaSet;
                mapUnidadeSerieCC = mapJerarquiaCC;
            } else if (cc.KS_Condicion__c == 'ZDVA' && cc.KS_Serie_single__c != null) { // Volumen 
                serieVolumen = logisticMap;
                mapImporteSerie = mapJerarquiaSet;
                mapImporteSerieCC = mapJerarquiaCC;
            } else if (cc.KS_Condicion__c == 'ZDVR' && cc.KS_Familia__c != null) { // Variedad
                familiaVariedad = logisticMap;
                mapUnidadeFamilia = mapJerarquiaSet;
                mapUnidadeFamiliaCC = mapJerarquiaCC;
            } else if (cc.KS_Condicion__c == 'ZDVA' && cc.KS_Familia__c != null) { // Volumen 
                familiaVolumen = logisticMap;
                mapImporteFamilia = mapJerarquiaSet;
                mapImporteFamiliaCC = mapJerarquiaCC;
            } 
        }

        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + productosLst.size() + ' productosLst - ' + productosLst);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + orgProductos.size() + ' orgProductos - ' + orgProductos);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + serieImporteTotal.size() + ' serieImporteTotal - ' + serieImporteTotal);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + serieProductos.size() + ' serieProductos - ' + serieProductos);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + familiaImporteTotal.size() + ' familiaImporteTotal - ' + familiaImporteTotal);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + familiaProductos.size() + ' familiaProductos - ' + familiaProductos);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + serieVariedad.size() + ' serieVariedad - ' + serieVariedad);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + serieVolumen.size() + ' serieVolumen - ' + serieVolumen);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + familiaVariedad.size() + ' familiaVariedad - ' + familiaVariedad);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + familiaVolumen.size() + ' familiaVolumen - ' + familiaVolumen);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + mapUnidadeSerie.size() + ' serieVariedad - ' + serieVariedad);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + mapImporteSerie.size() + ' mapImporteSerie - ' + mapImporteSerie);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + mapUnidadeFamilia.size() + ' mapUnidadeFamilia - ' + mapUnidadeFamilia);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + mapImporteFamilia.size() + ' mapImporteFamilia - ' + mapImporteFamilia);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + mapUnidadeSerieCC.size() + ' mapUnidadeSerieCC - ' + mapUnidadeSerieCC);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + mapImporteSerieCC.size() + ' mapImporteSerieCC - ' + mapImporteSerieCC);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + mapUnidadeFamiliaCC.size() + ' mapUnidadeFamiliaCC - ' + mapUnidadeFamiliaCC);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR ' + mapImporteFamiliaCC.size() + ' mapImporteFamiliaCC - ' + mapImporteFamiliaCC);
        
        Map<String, Decimal> mapUnidadeSerieDto = new Map<String, Decimal>();
        Map<String, Decimal> mapImporteSerieDto = new Map<String, Decimal>();
        Map<String, Decimal> mapUnidadeFamiliaDto = new Map<String, Decimal>();
        Map<String, Decimal> mapImporteFamiliaDto = new Map<String, Decimal>();
        
        Map<String, Decimal> mapUnidadeDto = new Map<String, Decimal>();
        Map<String, Decimal> mapImporteDto = new Map<String, Decimal>();
        
        for (Integer jk : jerarquiaKey) {

            KS_Condicion_Comercial__c jkSerieUnidad = mapUnidadeSerieCC.get(jk);
            KS_Condicion_Comercial__c jkSerieImport = mapImporteSerieCC.get(jk);
            KS_Condicion_Comercial__c jkFamiliaUnidad = mapUnidadeFamiliaCC.get(jk);
            KS_Condicion_Comercial__c jkFamiliaImport = mapImporteFamiliaCC.get(jk);
            
            // SUMATORIOS
            
            Decimal elementosSerie = 0;
            if (mapUnidadeSerie.containsKey(jk)) {
                for (String serie : mapUnidadeSerie.get(jk)) {
                    if (serieProductos.containsKey(serie)) {
                        elementosSerie += serieProductos.get(serie).size();
                    }
                }
            }
            
            Decimal importeSerie = 0;
            if (mapImporteSerie.containsKey(jk)) {
                for (String serie : mapImporteSerie.get(jk)) {
                    if (serieImporteTotal.containsKey(serie)) {
                        importeSerie += serieImporteTotal.get(serie);
                    }
                }
            }

            Decimal elementosFamilia = 0;
            if (mapUnidadeFamilia.containsKey(jk)) {
                for (String familia : mapUnidadeFamilia.get(jk)) {
                    if (familiaProductos.containsKey(familia)) {
                        elementosFamilia += familiaProductos.get(familia).size();
                    }
                }
            }

            Decimal importeFamilia = 0;
            if (mapImporteFamilia.containsKey(jk)) {
                for (String familia : mapImporteFamilia.get(jk)) {
                    if (familiaImporteTotal.containsKey(familia)) {
                        importeFamilia += familiaImporteTotal.get(familia);
                    }
                }
            }
            
            // CÁLCULOS
            
            if (mapUnidadeSerie.containsKey(jk)) {
                if (elementosSerie + elementosFamilia > mapUnidadeSerieCC.get(jk).KS_Escala_Unidades__c) {
                    for (String serie : mapUnidadeSerie.get(jk)) {
                        mapUnidadeSerieDto.put(serie, mapUnidadeSerieCC.get(jk).KS_Porcentaje__c);
                    }
                }
            }
            
            if (mapImporteSerie.containsKey(jk)) {
                if (importeSerie + importeFamilia > mapImporteSerieCC.get(jk).KS_Escala_Importe__c) {
                    for (String serie : mapImporteSerie.get(jk)) {
                        mapImporteSerieDto.put(serie, mapImporteSerieCC.get(jk).KS_Porcentaje__c);
                    }
                }
            }

            if (mapUnidadeFamilia.containsKey(jk)) {
                if (elementosFamilia + elementosSerie > mapUnidadeFamiliaCC.get(jk).KS_Escala_Unidades__c) {
                    for (String familia : mapUnidadeFamilia.get(jk)) {
                        mapUnidadeFamiliaDto.put(familia, mapUnidadeFamiliaCC.get(jk).KS_Porcentaje__c);
                    }
                }
            }

            if (mapImporteFamilia.containsKey(jk)) {
                if (importeFamilia + importeSerie > mapImporteFamiliaCC.get(jk).KS_Escala_Importe__c) {
                    for (String familia : mapImporteFamilia.get(jk)) {
                        mapImporteFamiliaDto.put(familia, mapImporteFamiliaCC.get(jk).KS_Porcentaje__c);
                    }
                }
            }            
        }
        
        List<OpportunityLineItem> productosUpdate = new List<OpportunityLineItem>();
        for (OpportunityLineItem prOfer : productosLst) {
            
            System.debug('-- JCAR ---------------------------------- - SET VA/VR prOfer - ' + prOfer);
            
            KS_Organizacion_Producto__c orgrod = orgProductos.get(prOfer.KS_Producto__c);
            if (orgrod == null) {continue;}
            String serie = orgrod.KS_Serie_Gama__c;
            String familia = orgrod.KS_Familia__c;
            
            System.debug('-- JCAR ---------------------------------- - SET VA/VR serie - ' + serie);
            System.debug('-- JCAR ---------------------------------- - SET VA/VR familia - ' + familia);

            prOfer.KS_Volumen_OK__c = false;
            prOfer.KS_Variedad_OK__c = false;
            
            prOfer.KS_dto_volumen__c = null;
            prOfer.KS_dto_variedad__c = null;     
            
            if (mapUnidadeSerieDto.containsKey(serie) && mapUnidadeSerieDto.get(serie)>0) {
                prOfer.KS_dto_variedad__c = mapUnidadeSerieDto.get(serie);
            }
            if (mapImporteSerieDto.containsKey(serie) && mapImporteSerieDto.get(serie)>0) {
                prOfer.KS_dto_volumen__c = mapImporteSerieDto.get(serie);
            }
            if (mapUnidadeFamiliaDto.containsKey(familia) && mapUnidadeFamiliaDto.get(familia)>0) {
                prOfer.KS_dto_variedad__c = mapUnidadeFamiliaDto.get(familia);
            }
            if (mapImporteFamiliaDto.containsKey(familia) && mapImporteFamiliaDto.get(familia)>0) {
                prOfer.KS_dto_volumen__c = mapImporteFamiliaDto.get(familia);
            }
            
            prOfer.KS_Volumen_OK__c = prOfer.KS_Dto_Volumen__c != null && prOfer.KS_Dto_Volumen__c > 0;
            prOfer.KS_Variedad_OK__c = prOfer.KS_Dto_Variedad__c != null && prOfer.KS_Dto_Variedad__c > 0;
            
            productosUpdate.add(prOfer);
        }        

        if (productosUpdate.size()>0) {
            System.debug('-- JCAR ---------------------------------- - UPSERT VA/VR ' + productosUpdate.size() + ' productosUpdate - ' + productosUpdate);
            try {
                upsert productosUpdate;
            } catch (Exception e) {
                System.debug('-- JCAR ---------------------------------- - UPSERT VA/VR ERROR - ' + e.getMessage());
                return e.getMessage();
            }
        }
        
        return null;
    }
}