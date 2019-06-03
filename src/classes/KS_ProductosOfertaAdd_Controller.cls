global without sharing class KS_ProductosOfertaAdd_Controller {

    public SearchKey searchKey {get;set;}
    /*public List<SelectOption> selectSerie {get;set;} // Se han creado métodos get
    public List<SelectOption> selectSubSerie {get;set;}
    public List<SelectOption> selectFamilia {get;set;}*/
    
    public String ficha {get;set;}
    public String idiomaActual {get;set;}
    //public String palabraClave {get;set;}
    public String letraClave  {get;set;}
    public String selectList {get;set;}
    public Boolean isPanelSelectProduct {get;set;}
    
    public List<String> estadosValidos;
    
    public List<Id> lstIdProductSelect {get;set;}
    List<Product2> lstProductSelect {get;set;}
    public Map<String, String> prodSAPSF {get;set;}
    public Map<String, KS_Organizacion_Producto__c> mapOrgProducto {get;set;}
    public List<wrProduct> lstWrProduct {get;set;}
    public Map<Id,Product2> mapIdProductSelect {get;set;}
    public Boolean getHaveSelected() {
        return !mapIdProductSelect.isEmpty();
    }
    
    public List<wrOppLineItem> lstWrOli {get;set;}
    public List<OpportunityLineItem> lstOppLineItem {get;set;}
    
    public String styleError {get;set;}
    public String errorTextOferta{get;set;}
    public Boolean getHaveErrorOferta() {
        return errorTextOferta!=null&&errorTextOferta!='';
    }    
    public String errorTextFicha{get;set;}
    public Boolean getHaveErrorFicha() {
        return errorTextFicha!=null&&errorTextFicha!='';
    }
    
    public Opportunity oferta {get;set;} // Objeto principal
    public KS_Serie_Familia__c seleccion {get;set;}
    
    public KS_ProductosOfertaAdd_Controller(ApexPages.StandardController controller) {
        
        searchKey = new SearchKey();
        
        seleccion = new KS_Serie_Familia__c();
        ficha = ApexPages.currentPage().getParameters().get('ficha');
        oferta = (Opportunity)controller.getRecord();
        if (oferta.ID != null) {
            
            oferta = [SELECT ID, Name, Pricebook2Id, KS_Organizacion_de_ventas__c, KS_Canal__c, KS_Sector__c,
                      KS_max_ficha__c, KS_Pais__c, KS_Organizacion_Cliente__c, KS_Lista_de_precios__c, KS_Distribuidor__c 
                      FROM Opportunity WHERE ID = :oferta.ID ];
            isPanelSelectProduct = true;
            mapIdProductSelect = new Map<Id,Product2>();
            styleError = 'error';
            String idioma = userInfo.getLanguage();
            idiomaActual = idioma.split('_')[0];
            System.debug('----------------------------------------SERG - idiomaActual : ' + idiomaActual );
            
            seleccion.KS_Org_ventas__c = oferta.KS_Organizacion_de_ventas__c;
        }       
        
        estadosValidos = new List<String>();
        List<KS_Configuracion__mdt> confLst = [SELECT KS_Estado_Producto_Ofertable__c FROM KS_Configuracion__mdt WHERE DeveloperName = 'CONF'];
        KS_Configuracion__mdt conf = null;
        if (confLst.size()>0) { 
            conf = confLst[0]; 
            estadosValidos.addAll(conf.KS_Estado_Producto_Ofertable__c.split(';'));
        }
    }
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    ///  PANEL SELECT PRODUCT                                                               ///
    ///////////////////////////////////////////////////////////////////////////////////////////
    public ApexPages.StandardSetController setCon {
        get {
            if (setCon == null) {
                
                String palabraClaveTemp;
                String codigoClaveTemp;
                String serieClaveTemp; searchKey.gama = seleccion.KS_Serie__c;
                String subserieClaveTemp; searchKey.subs = seleccion.KS_Subserie__c;
                String familiaClaveTemp; searchKey.famy = seleccion.KS_Familia__c;
                
                if(letraClave==null) {
                    palabraClaveTemp = '%' + ( searchKey.name!=null ? searchKey.name : '' ) + '%';
                } else {
                    palabraClaveTemp = letraClave + '%';
                    letraClave = null;
                }
                
                codigoClaveTemp = '%' + ( searchKey.code!=null ? searchKey.code : '' ) + '%';
                serieClaveTemp = '%' + ( searchKey.gama!=null ? searchKey.gama : '' ) + '%';
                subserieClaveTemp = '%' + ( searchKey.subs!=null ? searchKey.subs : '' ) + '%';
                familiaClaveTemp = '%' + ( searchKey.famy!=null ? searchKey.famy : '' ) + '%';
                
                palabraClaveTemp = palabraClaveTemp.replace('*', '%'); 
                codigoClaveTemp = codigoClaveTemp.replace('*', '%');
                
                System.debug('-- JCAR ---------------------------------- - SELECT product2 - ' + setCon);
                
                List<String> materiales = new List<String>();
                Set<String> IDproductos = new Set<String>();
                List<KS_Condicion_Comercial__c> condiciones = [SELECT Id, KS_Tarifa__c, KS_Material__c, KS_Condicion__c, KS_Importe__c, KS_Cliente_Jerarquia__c
                                                               FROM KS_Condicion_Comercial__c WHERE KS_Material__c != null 
                                                               AND ((KS_Condicion__c = 'PR00' AND KS_Tarifa__c = :oferta.KS_Lista_de_precios__c)
                                                                    OR (KS_Condicion__c = null AND KS_Tarifa__c = NULL 
                                                                        AND KS_CountryCode__c = :oferta.KS_Pais__c 
                                                                        AND KS_Canal__c = '20')
                                                                   )
                                                               ];
                System.debug('-- JCAR ---------------------------------- - SELECT ' + condiciones.size() + ' condiciones - ' + condiciones);
                for (KS_Condicion_Comercial__c con : condiciones) {
                    //materiales.add(con.KS_Material__c);
                    //System.debug('-- JCAR ---------------------------------- - PRODUCTO: ' + con.KS_Material__c);
                    IDproductos.add(con.KS_Material__c);
                }
                
                mapOrgProducto = new Map<String, KS_Organizacion_Producto__c>();
                String canal = oferta.KS_Canal__c != null ? oferta.KS_Canal__c : '10';
                List<KS_Organizacion_Producto__c> orgProductos = [SELECT ID, KS_Producto__c, KS_Familia__c, KS_Subserie__c, KS_Serie_Gama__c
                                                                  FROM KS_Organizacion_Producto__c WHERE KS_Canal_de_distribucion__c = :canal 
                                                                  /*AND KS_Familia__c like :familiaClaveTemp 
                                                                  AND KS_Subserie__c like :subserieClaveTemp 
                                                                  AND KS_Serie_Gama__c like :serieClaveTemp */
                                                                  AND KS_Producto__c in :IDproductos
                                                                  AND KS_Estatus_Comercial__c in :estadosValidos
                                                                  AND KS_Organizacion_de_Ventas__c = :oferta.KS_Organizacion_de_ventas__c];
                System.debug('-- JCAR ---------------------------------- - SELECT ' + orgProductos.size() + ' orgProductos - ' + orgProductos);
                for (KS_Organizacion_Producto__c orgP : orgProductos) {
                    //System.debug('-- JCAR ---------------------------------- - PRODUCTO: ' + orgP.KS_Producto__c);
                    
                    if (seleccion.KS_Familia__c != null && (seleccion.KS_Familia__c == orgP.KS_Familia__c || seleccion.KS_Familia__c == '---') ) {
                        
                        if (seleccion.KS_Serie__c != null && seleccion.KS_Serie__c == orgP.KS_Serie_Gama__c) {
                            
                            if (seleccion.KS_Subserie__c != null && seleccion.KS_Subserie__c == orgP.KS_Subserie__c) {
                                
                                materiales.add(orgP.KS_Producto__c);
                                mapOrgProducto.put(orgP.KS_Producto__c, orgP);
                            
                            } else if (seleccion.KS_Subserie__c == null) {
                                
                                materiales.add(orgP.KS_Producto__c);
                                mapOrgProducto.put(orgP.KS_Producto__c, orgP);
                            }
                            
                        } else if (seleccion.KS_Serie__c == null && seleccion.KS_Subserie__c == null) {
                            
                            materiales.add(orgP.KS_Producto__c);
                            mapOrgProducto.put(orgP.KS_Producto__c, orgP);
                        }

                    } else if (seleccion.KS_Serie__c == null && seleccion.KS_Subserie__c == null && seleccion.KS_Familia__c == null) {
                        
                        materiales.add(orgP.KS_Producto__c);
                        mapOrgProducto.put(orgP.KS_Producto__c, orgP);
                    }
                }
                

                System.debug('--------------------------------serg - palabraClave: ' + palabraClaveTemp + ' - ' + codigoClaveTemp + ' - ' + serieClaveTemp + ' - ' + subserieClaveTemp + ' - ' + familiaClaveTemp);/*
                if(idiomaActual=='en' && palabraClaveTemp=='%%') { 
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator([ select id, Name, ProductCode, Family, KS_Id_SAP__c, KS_Tipo_de_material__c, KS_Nombre_Producto_ES__c, KS_Descripcion_corta_ES__c, KS_Nombre_Producto_EN__c, KS_Descripcion_corta_EN__c, isActive from Product2 where id in :materiales AND isActive = true order by KS_Nombre_Producto_EN__c limit 4000 ]));                       
                } else if(idiomaActual=='en' && palabraClaveTemp!='%%') {
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator([ select id, Name, ProductCode, Family, KS_Id_SAP__c, KS_Tipo_de_material__c, KS_Nombre_Producto_ES__c, KS_Descripcion_corta_ES__c, KS_Nombre_Producto_EN__c, KS_Descripcion_corta_EN__c, isActive from Product2 where id in :materiales AND isActive = true and KS_Nombre_Producto_EN__c like :palabraClaveTemp order by KS_Nombre_Producto_EN__c limit 4000 ]));                       
                
                } else if(idiomaActual=='fr' && palabraClaveTemp=='%%') {
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator([ select id, Name, ProductCode, Family, KS_Id_SAP__c, KS_Tipo_de_material__c, KS_Nombre_Producto_ES__c, KS_Descripcion_corta_ES__c, KS_Nombre_Producto_FR__c, KS_Descripcion_corta_FR__c, isActive from Product2 where id in :materiales AND isActive = true order by KS_Nombre_Producto_FR__c limit 4000 ]));                       
                } else if(idiomaActual=='fr' && palabraClaveTemp!='%%') {                    
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator([ select id, Name, ProductCode, Family, KS_Id_SAP__c, KS_Tipo_de_material__c, KS_Nombre_Producto_ES__c, KS_Descripcion_corta_ES__c, KS_Nombre_Producto_FR__c, KS_Descripcion_corta_FR__c, isActive from Product2 where id in :materiales AND isActive = true and KS_Nombre_Producto_FR__c like :palabraClaveTemp order by KS_Nombre_Producto_FR__c limit 4000 ]));   
                
                } else {
                    if(palabraClaveTemp=='%%') {
                        setCon = new ApexPages.StandardSetController(Database.getQueryLocator([ select id, Name, ProductCode, Family, KS_Id_SAP__c, KS_Tipo_de_material__c, KS_Nombre_Producto_ES__c, KS_Descripcion_corta_ES__c, isActive from Product2 where id in :materiales AND isActive = true order by KS_Nombre_Producto_ES__c limit 4000 ]));                       
                    } else {
                        setCon = new ApexPages.StandardSetController(Database.getQueryLocator([ select id, Name, ProductCode, Family, KS_Id_SAP__c, KS_Tipo_de_material__c, KS_Nombre_Producto_ES__c, KS_Descripcion_corta_ES__c, isActive from Product2 where id in :materiales AND isActive = true and KS_Nombre_Producto_ES__c like :palabraClaveTemp order by KS_Nombre_Producto_ES__c limit 4000 ]));   
                    }
                }*/
                
                String name = searchKey.name != null ? searchKey.name : '';
                String code = searchKey.code != null ? searchKey.code : '';
                name = name.replace('*', '%');
                code = code.replace('*', '%');
                
                List<String> nombres = name.split(';');
                List<String> codigos = code.split(';');
                
                System.debug('-- JCAR ---------------------------------- - SEARCHKEY ' + nombres.size() + ' nombres - ' + nombres);
                System.debug('-- JCAR ---------------------------------- - SEARCHKEY ' + codigos.size() + ' codigos - ' + codigos);
                
                String productosQRY = 'select id, Name, ProductCode, Family, KS_Id_SAP__c, KS_Tipo_de_material__c, KS_Nombre_Producto__c, KS_Descripcion_corta__c, isActive';
                productosQRY += ' from Product2 where id in :materiales AND isActive = true';
                
                if (nombres.size()>1) 
                { 
                    Integer index = 0;
                    while (index < nombres.size()) {
                        
                        String nameS = '%' + nombres[index] + '%';
                        if (index == 0) {
                            productosQRY += ' AND ( (KS_Nombre_Producto__c like \''+nameS+'\'';
                            productosQRY += ' OR KS_Descripcion_corta__c like \''+nameS+'\')';
                        } else {
                            productosQRY += ' OR (KS_Nombre_Producto__c like \''+nameS+'\'';
                            productosQRY += ' OR KS_Descripcion_corta__c like \''+nameS+'\')';
                        }
                        
                        index++;
                    }
                    productosQRY += ' )';
                }
                else 
                { 
                    String nameS = '%' + nombres[0] + '%';
                    productosQRY += ' and (KS_Nombre_Producto__c like \''+nameS+'\'';
                    productosQRY += ' OR KS_Descripcion_corta__c like \''+nameS+'\')';
                }
                
                if (codigos.size()>1) 
                { 
                    Integer index = 0;
                    while (index < codigos.size()) {
                        
                        String codeS = '%' + codigos[index] + '%';
                        if (index == 0) {
                            productosQRY += ' AND ( KS_Id_SAP__c like \''+codeS+'\'';
                        } else {
                            productosQRY += ' OR KS_Id_SAP__c like \''+codeS+'\'';                           
                        }
                        
                        index++;
                    }
                    productosQRY += ' )';
                }
                else 
                { 
                    String codeS = '%' + codigos[0] + '%';
                    productosQRY += ' AND KS_Id_SAP__c like \''+codeS+'\'';
                }                

                productosQRY += ' order by KS_Nombre_Producto__c limit 4000';
                
                System.debug('-- JCAR ---------------------------------- - STRING productosQRY - ' + productosQRY);
                
                /*setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [ select id, Name, ProductCode, Family, KS_Id_SAP__c, KS_Tipo_de_material__c, KS_Nombre_Producto__c, KS_Descripcion_corta__c, isActive 
                     from Product2 where id in :materiales AND isActive = true 
                     and KS_Nombre_Producto__c like :palabraClaveTemp 
                     and KS_Descripcion_corta__c like :palabraClaveTemp 
                     and KS_Id_SAP__c like :codigoClaveTemp 
                     order by KS_Nombre_Producto__c limit 4000 ]));*/
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(productosQRY));
                setCon.setpageSize(25);
            }
            System.debug('-- JCAR ---------------------------------- - SELECT product2 - ' + setCon);
            
            Map<String, KS_Organizacion_Producto__c> mapOrgProductoTMP = new Map<String, KS_Organizacion_Producto__c>();
            List<Product2> lstProd = (List<Product2>) setCon.getRecords();
            for(Product2 prod : lstProd) {
                if (mapOrgProducto.containsKey(prod.ID)) {
                    mapOrgProductoTMP.put(prod.ID, mapOrgProducto.get(prod.ID));
                }
            }
            mapOrgProducto = mapOrgProductoTMP;
            
            return SetCon;
        }
        set;       
    }  

    public List<wrProduct> getProductos() {
        
        List<Product2> lstProd = (List<Product2>) setCon.getRecords();
        mapOrgProducto = new Map<String, KS_Organizacion_Producto__c>();
        
        List<ID> prodIDLst = new List<ID>();
        for(Product2 prod : lstProd) { prodIDLst.add(prod.ID); }
        String canal = oferta.KS_Canal__c != null ? oferta.KS_Canal__c : '10';
        List<KS_Organizacion_Producto__c> orgProductos = [SELECT ID, KS_Producto__c, KS_Familia__c, KS_Subserie__c, KS_Serie_Gama__c
                                                          FROM KS_Organizacion_Producto__c WHERE KS_Canal_de_distribucion__c = :canal 
                                                          AND KS_Producto__c in :prodIDLst
                                                          AND KS_Estatus_Comercial__c in :estadosValidos
                                                          AND KS_Organizacion_de_Ventas__c = :oferta.KS_Organizacion_de_ventas__c];        
        for (KS_Organizacion_Producto__c oP : orgProductos) { mapOrgProducto.put(oP.KS_Producto__c, oP); }
        
        lstWrProduct = new List<wrProduct>();
        for(Product2 prod : lstProd) {
            
            KS_Organizacion_Producto__c orgProd = new KS_Organizacion_Producto__c();
            if (mapOrgProducto.containsKey(prod.ID)) {
                orgProd = mapOrgProducto.get(prod.ID);
            }
            wrProduct wrProd;
            
            if(mapIdProductSelect.get(prod.Id)!=null) {
                wrProd = new wrProduct(true, prod, orgProd);
            } else {
                wrProd = new wrProduct(false, prod, orgProd);
            }
            lstWrProduct.add(wrProd);
        }
        return lstWrProduct;
    }
    
    public void getProductosFilter(){
        for(wrProduct wp : lstWrProduct)                
            if(wp.isSelect && mapIdProductSelect.get(wp.product.Id)==null)
                mapIdProductSelect.put(wp.product.Id, wp.product);
        setcon = null;
        //setCon.getRecords(); 
        getProductos();
    }
    
    public void saveProdSelect_Next(){
        //Guardamos Id de Productos seleccionados
        for(wrProduct wp : lstWrProduct) {   
            if(wp.isSelect && mapIdProductSelect.get(wp.product.Id)==null) {
                mapIdProductSelect.put(wp.product.Id, wp.product); } 
            if(!wp.isSelect && mapIdProductSelect.get(wp.product.Id)!=null) {
                mapIdProductSelect.remove(wp.product.ID); }
        }
        setCon.next();
    }
    
    public void saveProdSelect_Previous(){
        //Guardamos Id de Productos seleccionados
        for(wrProduct wp : lstWrProduct) 
            if(wp.isSelect && mapIdProductSelect.get(wp.product.Id)==null) 
                mapIdProductSelect.put(wp.product.Id, wp.product);

        setCon.previous();
    }
    
    //Pedimos precios y descuentos de la lista de Productos seleccionados
    public void saveSelectList(){

        List<String> materiales = new List<String>();
        System.debug('-- JCAR ---------------------------------- - PRODUCTOS LIST ' + lstWrProduct.size() + ' lstWrProduct - ' + lstWrProduct);
        for(wrProduct wp : lstWrProduct) {
            if(wp.isSelect && mapIdProductSelect.get(wp.product.ID)==null) {
                mapIdProductSelect.put(wp.product.ID, wp.product);
                materiales.add(wp.product.ID);
            }
        }

        Map<String, KS_ProductoOferta_SetCondicionaComercial.Condicion> condicionesPorMaterial = KS_ProductoOferta_SetCondicionaComercial.condicionesPorMaterial(mapIdProductSelect, oferta);
        System.debug('-- JCAR ---------------------------------- - SELECTED CONDICIONES ' + condicionesPorMaterial.size() + ' condicionesPorMaterial - ' + condicionesPorMaterial);
        
        System.debug('-- JCAR ---------------------------------- - SELECTED PRODUCTOS MAP ' + mapIdProductSelect.size() + ' mapIdProductSelect - ' + mapIdProductSelect);
        //Lista con los seleccionados anteriormente + los nuevos seleccionados
        lstProductSelect = mapIdProductSelect.values().size()>0? mapIdProductSelect.values() : new List<Product2>();
        
        Map<ID,ID> productPriceMAP = new Map<ID,ID>();
        List<ID> productIDlst = new List<ID>(); productIDlst.addAll(mapIdProductSelect.keySet());
        List<PriceBookEntry> productIDsinPriceBook = new List<PriceBookEntry>();
        // Necesitamos las pricebook son of a fridge cuando es un objeto estandar de SF
        if ( oferta.Pricebook2Id == null ) {
            Pricebook2 priceBookStandard = [SELECT Id FROM Pricebook2 WHERE isStandard = true and isActive = true];
            if (priceBookStandard != null)  {
                oferta.Pricebook2Id = priceBookStandard.ID;
                update oferta;
            }            
        }
        List<PriceBookEntry> priceBookList = [SELECT Id, Product2Id, Product2.Id, Product2.Name, Product2.ProductCode, Product2.KS_Id_SAP__c FROM PriceBookEntry WHERE Product2Id in :productIDlst AND PriceBook2.ID = :oferta.Pricebook2Id];

        System.debug('-- JCAR ---------------------------------- - SELECT ' + priceBookList.size() + ' priceBook - ' + priceBookList);
        
        for (PriceBookEntry pb : priceBookList) {
            
            productPriceMAP.put(pb.Product2Id, pb.ID);
        }
        for(String prodID : mapIdProductSelect.keySet()){
       
            System.debug('-- JCAR ---------------------------------- - !productPriceMAP.containsKey('+prodID+') ' + !productPriceMAP.containsKey(prodID));
            
            if (!productPriceMAP.containsKey(prodID)) {
                PriceBookEntry pbe = new PriceBookEntry();
                pbe.Pricebook2Id = oferta.Pricebook2Id;
                pbe.Product2Id = prodID;
                pbe.IsActive = true;
                pbe.UnitPrice = 0;
                productIDsinPriceBook.add(pbe);
            }
        }
        System.debug('-- JCAR ---------------------------------- - INSERT ' + productIDsinPriceBook.size() + ' priceBook - ' + productIDsinPriceBook);
        insert productIDsinPriceBook;
        for (PriceBookEntry pb : productIDsinPriceBook) {
            
            productPriceMAP.put(pb.Product2Id, pb.ID);
        }
        
        Decimal newFicha = 1;
        if (ficha != null && ficha != '') {
            newFicha = Decimal.valueOf(ficha);
        } else {
            newFicha = oferta.KS_max_ficha__c != null ? oferta.KS_max_ficha__c + 1 : 1;    
        }
        System.debug('---------------------------------------- JCAR - FICHA : ' + newFicha );             
        
        prodSAPSF = new Map<String, String>();
        
        if(lstProductSelect.size()>0){
            isPanelSelectProduct = false;  
            
            Decimal cantFicha = 1;
            List<OpportunityLineItem> canFicha =
                [SELECT KS_Cantidad_Ficha__c FROM OpportunityLineItem
                 WHERE OpportunityID = :oferta.ID and KS_Ficha__c = :newFicha];
            for (OpportunityLineItem op : canFicha) {
                cantFicha = op.KS_Cantidad_Ficha__c;
            }
            
            lstOppLineItem = new List<OpportunityLineItem>();
            lstWrOli = new List<wrOppLineItem>();
            for(Product2 prod : lstProductSelect){
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                oppLineItem.OpportunityId = oferta.Id;
                oppLineItem.KS_Cantidad__c = 1;
                oppLineItem.KS_Cantidad_Ficha__c = cantFicha;
                oppLineItem.Quantity = 1;
                oppLineItem.PricebookEntryId = productPriceMAP.get(prod.ID);
                
                oppLineItem.UnitPrice = 0;
                if (condicionesPorMaterial.containsKey(prod.ID)) {
                    KS_ProductoOferta_SetCondicionaComercial.Condicion condi = condicionesPorMaterial.get(prod.ID);
                    oppLineItem = condi.toProducto(oppLineItem);// oppLineItem.UnitPrice = condi.precio();
                }

                oppLineItem.KS_Ficha__C = newFicha;
                
                lstOppLineItem.add(oppLineItem);
                String nombreProd = prod.KS_Nombre_Producto__c != '' ? prod.KS_Nombre_Producto__c : prod.KS_Descripcion_corta__c;               
                String codProd = prod.KS_Id_SAP__c;
                
                prodSAPSF.put(codProd, prod.ID);
                
                wrOppLineItem wrOli = new wrOppLineItem(codProd, nombreprod, oppLineItem, '');
                lstWrOli.add(wrOli);
            }

        }        
    }    
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    ///  PANEL PRICE PRODUCT                                                                ///
    ///////////////////////////////////////////////////////////////////////////////////////////    
    
    //Guardamos precios/descuetos
    public PageReference savePrice() {

        System.debug('lstWrOli: ' + lstWrOli);

        System.debug('-- JCAR ---------------------------------- - INSERT ' + lstOppLineItem.size() + ' lstOppLineItem - ' + lstOppLineItem);
        Database.UpsertResult[] results = Database.upsert(lstOppLineItem,false);
        System.debug('----------------------------------------SERG - results : ' + results );               
        Integer index = 0;
        for(Database.UpsertResult res : results) {
            if(!res.isSuccess()){ 
                
                Product2 pr = lstProductSelect.get(index);               
                System.debug('-- JCAR ---------------------------------- - ERROR producto_oferta - ' + pr.ID + ' - ' + res);
                errorTextFicha = pr.KS_ID_SAP__c + ' -- ' + res.getErrors()[0].getMessage();
                return null;
            }
            index++;
        }
        
        System.debug('----------------------------------------SERG - redirect: ' + oferta);                
        
        PageReference pageRef = new PageReference( '/apex/KS_Oferta?id=' + oferta.Id );
        pageRef.SetRedirect(true);
        System.debug('----------------------------------------SERG - pageRef : ' + pageRef );               
        return pageRef;
    }
    
    public PageReference cancel() {
        PageReference pageRef = new PageReference( '/apex/KS_Oferta?id=' + oferta.Id );
        pageRef.SetRedirect(true);
        System.debug('----------------------------------------SERG - pageRef : ' + pageRef );               
        return pageRef;        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    ///  WRAPPER CLASSES                                                                    ///
    ///////////////////////////////////////////////////////////////////////////////////////////
    public class wrProduct{ // SELECT PRODUCT
        public boolean isSelect {get; set;}
        public Product2 product {get; set;}
        public KS_Organizacion_Producto__c orgProduct {get; set;}
        
        public wrProduct(Boolean sel, Product2 prod, KS_Organizacion_Producto__c orgProd){
            isSelect = sel;
            product = prod;
            orgProduct = orgProd;
        }
    }
    public class wrOppLineItem { // ADD PRODUCT
        public String nameProduct {get; set;}
        public String codeProduct {get; set;}
        public OpportunityLineItem oppLineItem {get; set;}
        public String styleError {get;set;}
        
        public wrOppLineItem(String code, String name, OpportunityLineItem opi, String sErr){
            codeProduct = code;
            nameProduct = name;
            oppLineItem = opi;
            styleError = sErr;
        }
    }
    
    public class SearchKey {
        
        public String name {get;set;}
        public String code {get;set;}
        public String gama {get;set;}
        public String subs {get;set;}
        public String famy {get;set;}
    }
    public List<SelectOption> getSelectSerie() {
        List<PicklistEntry> entryL = KS_Organizacion_Producto__c.KS_Serie_Gama__c.getDescribe().getPickListValues();
        List<SelectOption> selectL = new List<SelectOption>(); selectL.add(new SelectOption('', ''));
        for (PicklistEntry entry : entryL) {
            selectL.add(new SelectOption(entry.getLabel(), entry.getLabel()));
        }
        return selectL;
    }
    public List<SelectOption> getSelectSubSerie() {
        List<PicklistEntry> entryL = KS_Organizacion_Producto__c.KS_Subserie__c.getDescribe().getPickListValues();
        List<SelectOption> selectL = new List<SelectOption>(); selectL.add(new SelectOption('', ''));
        for (PicklistEntry entry : entryL) {
            selectL.add(new SelectOption(entry.getLabel(), entry.getLabel()));
        }
        return selectL;
    }
    public List<SelectOption> getSelectFamilia() {
        List<PicklistEntry> entryL = KS_Organizacion_Producto__c.KS_Familia__c.getDescribe().getPickListValues();
        List<SelectOption> selectL = new List<SelectOption>(); selectL.add(new SelectOption('', ''));
        for (PicklistEntry entry : entryL) {
            selectL.add(new SelectOption(entry.getLabel(), entry.getLabel()));
        }
        return selectL;
    }
}