public class KS_Oferta_SearchProductos_Controller {

    public SearchKey searchKey {get;set;}
    public class SearchKey {
        
        public String name {get;set;}
        public String code {get;set;}
        public String gama {get;set;}
        public String subs {get;set;}
        public String famy {get;set;}
    }
    
    public String ofertaFicha {get;set;}
    public String idiomaActual {get;set;}
    public String letraClave  {get;set;}
    public String selectList {get;set;}
    public Boolean isPanelSelectProduct {get;set;}
    
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
    
    public List<String> estadosValidos;
    
    public List<Id> lstIdProductSelect {get;set;}
    List<Product2> lstProductSelect {get;set;}
    public Map<String, String> prodSAPSF {get;set;}
    public Map<String, KS_Organizacion_Producto__c> mapOrgProducto {get;set;}
    
    public List<wrProduct> lstWrProduct {get;set;}
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
    
    public Map<Id,Product2> mapIdProductSelect {get;set;}
    public Boolean getHaveSelected() {
        return !mapIdProductSelect.isEmpty();
    }
    
    public String selectAddRow {get;set;}
    public String selectAddProd {get;set;}
    public Integer ofertaFilas {get;set;}
    
    public Boolean searchProds {get;set;}
    
    public KS_Oferta_SearchProductos_Controller(ApexPages.StandardController controller) {
        
        searchKey = new SearchKey();
        
        searchKey.code = ApexPages.currentPage().getParameters().get('codProducto');
        selectAddRow = ApexPages.currentPage().getParameters().get('rowProducto');
        selectAddProd = ApexPages.currentPage().getParameters().get('idProducto');
        ofertaFilas = selectAddRow != null ? selectAddRow.length(): 0;
        ofertaFicha = ApexPages.currentPage().getParameters().get('ficha');
        searchProds = false;
        
        System.debug('-- JCAR ---------------------------------- KS_Oferta_SearchProductos_Controller - selectAddRow : ' + selectAddRow );
        System.debug('-- JCAR ---------------------------------- KS_Oferta_SearchProductos_Controller - ofertaFilas : ' + ofertaFilas );
        System.debug('-- JCAR ---------------------------------- KS_Oferta_SearchProductos_Controller - ofertaFicha : ' + ofertaFicha );
        
        seleccion = new KS_Serie_Familia__c();
        
        oferta = (Opportunity)controller.getRecord();
        if (oferta.ID != null) {
            
            oferta = [SELECT ID, Name, Pricebook2Id, KS_Organizacion_de_ventas__c, KS_Canal__c, KS_Sector__c,
                      KS_max_ficha__c, KS_min_ficha__c, KS_Pais__c, KS_Organizacion_Cliente__c, KS_Lista_de_precios__c, KS_Distribuidor__c 
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
        
        lstWrProduct = new List<wrProduct>();
    }
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////
    ///  PANEL SELECT PRODUCT                                                              ///
    //////////////////////////////////////////////////////////////////////////////////////////
    public ApexPages.StandardSetController setCon {
        get {
            if (setCon == null && searchProds) {
                
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

				String canal = oferta.KS_Canal__c != null ? oferta.KS_Canal__c : '10';
                List<String> materiales = new List<String>();
                Set<String> IDproductos = new Set<String>();
                List<KS_Condicion_Comercial__c> condiciones = [SELECT Id, KS_Tarifa__c, KS_Material__c, KS_Condicion__c, KS_Importe__c, KS_Cliente_Jerarquia__c
                                                               FROM KS_Condicion_Comercial__c WHERE KS_Material__c != null 
                                                               AND (
                                                                   (KS_Condicion__c = 'PR00' 
                                                                    AND KS_Tarifa__c = :oferta.KS_Lista_de_precios__c
                                                                    AND KS_Canal__c = :canal
                                                                    AND KS_Sector__c = :oferta.KS_Sector__c
                                                                   )
                                                                    OR (KS_Condicion__c = null AND KS_Tarifa__c = NULL 
                                                                        AND KS_CountryCode__c = :oferta.KS_Pais__c 
                                                                        AND KS_Canal__c = '20')
                                                                   )
                                                               ];
                System.debug('-- JCAR ---------------------------------- - SELECT ' + condiciones.size() + ' condiciones - ' + condiciones);
                for (KS_Condicion_Comercial__c con : condiciones) {
                    IDproductos.add(con.KS_Material__c);
                }
                
                mapOrgProducto = new Map<String, KS_Organizacion_Producto__c>();
                List<KS_Organizacion_Producto__c> orgProductos = [SELECT ID, KS_Producto__c, KS_Familia__c, KS_Subserie__c, KS_Serie_Gama__c
                                                                  FROM KS_Organizacion_Producto__c 
                                                                  WHERE KS_Canal_de_distribucion__c = :canal 
                                                                  AND KS_Sector__c = :oferta.KS_Sector__c
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
                

                System.debug('--------------------------------serg - palabraClave: ' + palabraClaveTemp + ' - ' + codigoClaveTemp + ' - ' + serieClaveTemp + ' - ' + subserieClaveTemp + ' - ' + familiaClaveTemp);
                
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

                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(productosQRY));
                setCon.setpageSize(25);
            
                System.debug('-- JCAR ---------------------------------- - SELECT product2 - ' + setCon);
                
                Map<String, KS_Organizacion_Producto__c> mapOrgProductoTMP = new Map<String, KS_Organizacion_Producto__c>();
                List<Product2> lstProd = (List<Product2>) setCon.getRecords();
                for(Product2 prod : lstProd) {
                    if (mapOrgProducto.containsKey(prod.ID)) {
                        mapOrgProductoTMP.put(prod.ID, mapOrgProducto.get(prod.ID));
                    }
                }
                mapOrgProducto = mapOrgProductoTMP;
            }
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
        searchProds = true;
        setcon = null;
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
    
    public PageReference cancel() {
        PageReference pg = null;
        if (oferta != null && oferta.ID != null) {
            pg = new PageReference('/' + oferta.ID);
            if (selectAddRow != null && selectAddRow.trim() != '') {
                pg = backToAddProductos(false);
            }
        } else {
            pg = new PageReference('/');
        }
        if (pg!=null) {pg.setRedirect(true);}
        return pg;
    }
    
    public PageReference selProducto() {
        PageReference pg = null;
        if (oferta != null && oferta.ID != null) {
            pg = new PageReference('/' + oferta.ID);
            if (selectAddRow != null && selectAddRow.trim() != '') {
                pg = backToAddProductos(true);
            }
        } else {
            pg = new PageReference('/');
        }
        if (pg!=null) {pg.setRedirect(true);}
        return pg;
    }
    
    private PageReference backToAddProductos(Boolean sendIDProd) {
        return new PageReference(
            '/apex/KS_Oferta_AddProductos?' 
            + 'id='+oferta.ID
            + '&rowProducto='+selectAddRow
            + (sendIDProd ? '&idProducto='+selectAddProd : '')
            + '&ficha='+ofertaFicha
            + '&fichaLineas='+selectAddRow.length());
    }
}