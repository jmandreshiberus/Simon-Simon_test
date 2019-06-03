global with sharing class KS_ProductosOferta_Controller {

    
    public boolean redirectToAdd {get;set;}
    
    public Opportunity oferta {get;set;} // Objeto principal
    public Map<Decimal,List<OpportunityLineItem>> productosOferta {get;set;} // Mapeo de: String "Ficha", Lista "Productos Oferta"
    private List<OpportunityLineItem> productosLst {get;set;} // Todos los productosOferta
    public Boolean getHasProductos() { return productosLst != null && !productosLst.isEmpty(); }
    public Set<Decimal> getFichas() { return (productosOferta != null && !productosOferta.isEmpty()) ? productosOferta.keySet() : new Set<Decimal>(); }    
    
    public Map<Decimal,String> totalImporte {get;set;}
    public Map<Decimal,String> totalCantidad {get;set;}
    public Map<Decimal,Integer> totalCantidadFicha {get;set;}
    
    public Map<Decimal,String> fichaComentarios {get;set;}
    public Map<Decimal,String> fichaCompetencia {get;set;}
    
    public List<SelectOption> getCompetencias()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =
            OpportunityLineItem.KS_Competencia__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public Map<String,Boolean> isDelete {get;set;}
    public Map<Decimal,Boolean> isEdit {get;set;}
    public Boolean addToFicha {get;set;}
    public Decimal fichaToEdit {get;set;}
    public Boolean getHaveEdit() {
        for (Decimal ficha : productosOferta.keySet()) {
            if (isEdit.get(ficha)) {
                return true;
            }
        }
        return false;
    }
    
    public List<SelectOption> fichaSelect {get;set;}
    
    public String errorText {get;set;}
    public Boolean getHaveError() {
        return errorText!=null&&errorText!='';
    }

    private void setComentariosFicha(Decimal ficha) {
        if ( !productosOferta.containsKey(ficha) ) { return; }
        fichaComentarios = fichaComentarios != null ? fichaComentarios : new Map<Decimal,String>();
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        String cmt = prdctsLst.get(0).KS_Comentarios__c;
        fichaComentarios.put(ficha, cmt != null ? cmt : '');
    }     
    private void setCompetenciaFicha(Decimal ficha) {    
        if ( !productosOferta.containsKey(ficha) ) { return; }
        fichaCompetencia = fichaCompetencia != null ? fichaCompetencia : new Map<Decimal,String>();
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        String cmp = prdctsLst.get(0).KS_Competencia__c;
        fichaCompetencia.put(ficha, cmp != null ? cmp : '');
    }

    private void setTotalCantidadFicha(Decimal ficha) {
        if ( !productosOferta.containsKey(ficha) ) { return; }
        totalCantidadFicha = totalCantidadFicha != null ? totalCantidadFicha : new Map<Decimal,Integer>();
        Decimal total = 0;
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        // Calculamos el total de productos de la ficha introducida
        total = prdctsLst.get(0).KS_Cantidad_Ficha__c; total = total > 0 ? total : 1;
        totalCantidadFicha.put(ficha, Integer.valueOf(total));
    }
    private void setTotalImporte(Decimal ficha, String divisa) {
        if ( !productosOferta.containsKey(ficha) ) { return; }
        totalImporte = totalImporte != null ? totalImporte : new Map<Decimal,String>();
        Decimal total = 0;
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        // Calculamos el importe total de la ficha introducida
        for (OpportunityLineItem prOfer : prdctsLst) { 
            total += (prOfer.UnitPrice*prOfer.KS_Cantidad__c);
        }
        total.setscale(2);
        String stotal = format2Decimal(total);
        totalImporte.put(ficha, divisa + ' ' + stotal);
    }
    private void setTotalCantidad(Decimal ficha) {
        if ( !productosOferta.containsKey(ficha) ) { return; }
        totalCantidad = totalCantidad != null ? totalCantidad : new Map<Decimal,String>();
        Decimal total = 0;
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        // Calculamos el total de productos de la ficha introducida
        for (OpportunityLineItem prOfer : prdctsLst) { 
            total += prOfer.KS_Cantidad__c;
        }
        String stotal = format2Decimal(total);
        totalCantidad.put(ficha, stotal);
    }
    
    private String format2Decimal(Decimal total) {
        String format = total.format();
        List<String> formatL = format.split(',');
        if (formatL.size()<2) {
            return format+',00';
        } else if (formatL.get(1).length()<2) {
            return format+'0';
        }
        return format;
    }
   
    public KS_ProductosOferta_Controller(ApexPages.StandardController controller) {
        
        oferta = (Opportunity)controller.getRecord();
        if (oferta.ID != null) { // OJO: Siempre debería entrar, ya que esta VF será complementaria de una Oferta existente
            
            oferta = [ SELECT ID, Name, Pricebook2Id, KS_max_ficha__c, KS_Organizacion_Cliente__c, KS_Lista_de_precios__c FROM Opportunity WHERE ID = :oferta.ID ];
            // Teniendo la ID de la oferta, podemos saber los productosOferta inmediatamente
            setProductosFromOferta();
            
            isEdit = isEdit != null ? isEdit : new Map<Decimal,Boolean>();
            isDelete = isDelete != null ? isDelete : new Map<String,Boolean>();
            mapProductosOferta();
        }
        
        redirectToAdd = false;
    }
    
    private void mapProductosOferta() {
        
        productosOferta = new Map<Decimal,List<OpportunityLineItem>>();
        // Mapeamos!
        for (OpportunityLineItem prOfer : productosLst) {
            
            profer.KS_Cantidad__c = profer.KS_Cantidad__c != null ? profer.KS_Cantidad__c : 1;
            Decimal ficha = prOfer.KS_Ficha__c;
            
            //System.debug('-- JCAR ---------------------------------- - ficha ' + ficha);
            ficha = (ficha != null) ? ficha : 0; // Por probar
            
            if ( !productosOferta.containsKey(ficha) ) {
                
                List<OpportunityLineItem> productos4Map = new List<OpportunityLineItem>();
                productos4Map.add(prOfer);
                productosOferta.put(ficha, productos4Map);
                
            } else {
                productosOferta.get(ficha).add(prOfer);
            }

            isDelete.put(prOfer.ID, false);
        }

        fichaSelect = fichaSelect != null ? fichaSelect : new List<SelectOption>();
        // fichaSelect.add(new SelectOption('','-')); // Este es el Otros
        // Añadimos totales y creamos mapeos/listas
        Decimal lastFicha = 0;
        for (Decimal ficha : productosOferta.keySet()) {
            String divisa = productosOferta.get(ficha).get(0).CurrencyIsoCode;
            setTotalImporte(ficha, divisa);
            setTotalCantidad(ficha);
            setTotalCantidadFicha(ficha);
            setComentariosFicha(ficha);
            setCompetenciaFicha(ficha);
            isEdit.put(ficha, (ficha==0));
            if (ficha>0) { 
                fichaSelect.add(new SelectOption(ficha.format(),ficha.format()));
                lastFicha = ficha;
            }
        }
        lastFicha++;
        fichaSelect.add(new SelectOption(lastFicha.format(),lastFicha.format()));
    }
    
    public void enableEdit() {
        
        
        if ( fichaToEdit == null ) { return; }
        isEdit.put(fichaToEdit, true);
        return;
    }
    
    public void save() {
        
        errorText = '';
        
        List<OpportunityLineItem> saveLst = new List<OpportunityLineItem>();
        List<OpportunityLineItem> deleLst = new List<OpportunityLineItem>();
        for (Decimal ficha : productosOferta.keySet()) {
            // Aqui se recorren los productos, se crea una macrolista
            for (OpportunityLineItem prOfer : productosOferta.get(ficha)) {
                if (isDelete.get(prOfer.ID)) {
                    deleLst.add(prOfer);
                } else {
                    
                    prOfer.KS_Cantidad_Ficha__c = totalCantidadFicha.get(prOfer.KS_Ficha__c);
                    prOfer.KS_Comentarios__c = fichaComentarios.get(prOfer.KS_Ficha__c);
                    prOfer.KS_Competencia__c = fichaCompetencia.get(prOfer.KS_Ficha__c);
                    saveLst.add(prOfer);
                }
            }
            isEdit.put(ficha, false); // Reset de edición
        }
        // Aqui se deletea lo marcado
        System.debug('-- JCAR ---------------------------------- - DELETE ' + deleLst.size() + ' productos_oferta - ' + deleLst);
        delete deleLst;
        // Aqui se guarda la macrolista
        System.debug('-- JCAR ---------------------------------- - UPSERT ' + saveLst.size() + ' productos_oferta - ' + saveLst);
        Database.UpsertResult[] results = Database.upsert(saveLst, false);
        
        Set<Decimal> errorProfer = new Set<Decimal>();
        Integer index = 0;
        for(Database.UpsertResult res : results) {
            if(!res.isSuccess()){ 
                
                OpportunityLineItem ol = saveLst.get(index);
                System.debug('-- JCAR ---------------------------------- - ERROR producto_oferta - ' + ol.ID + ' - ' + res);
                errorText = 'Fallo al actualizar línea de oportunidad. FICHA: ' 
                    + ol.KS_Ficha__c + ' PRODUCTO: ' + OL.ProductCode + ' -- ' + res.getErrors()[0].getMessage();
                
                errorProfer.add(ol.KS_Ficha__c);
            }
            index++;
        }
     
        // Aqui se remapea con la macrolista!
        productosLst = saveLst;
        mapProductosOferta();
        
        for (Decimal ficha : errorProfer) {
            isEdit.put(ficha, true);
        }
    }

    
    public PageReference addProducts() {
        addToFicha = false;
        redirectToAdd = true;
        return null;
        
        PageReference pageRef = new PageReference( '/apex/KS_ProductosOfertaAdd?id=' + oferta.Id );
        pageRef.SetRedirect(true);
        System.debug('----------------------------------------SERG - pageRef : ' + pageRef );
        return pageRef;
    }
    public PageReference addProductsToFicha() {
        addToFicha = true;
        redirectToAdd = true;
        return null;
        
        PageReference pageRef = new PageReference( '/apex/KS_ProductosOfertaAdd?id=' + oferta.Id + '&ficha=' + fichaToEdit);
        pageRef.SetRedirect(true);
        System.debug('----------------------------------------SERG - pageRef : ' + pageRef );
        return pageRef;        
    }    

    public void duplicar() {

        // A partir de la ficha seleccionada, se crea una copia de sus productos_oferta con una nueva ficha, que será la máxima actual + 1
        Decimal newFicha = oferta.KS_max_ficha__c != null ? oferta.KS_max_ficha__c + 1 : 1;
        List<OpportunityLineItem> dupliductos = new List<OpportunityLineItem>();
               
        for (OpportunityLineItem prOfer : productosOferta.get(fichaToEdit)) {
            
            OpportunityLineItem oppLineItem = new OpportunityLineItem();
            oppLineItem.OpportunityId = oferta.Id;
            oppLineItem.KS_Ficha__C = newFicha;
            oppLineItem.UnitPrice = prOfer.UnitPrice;
            oppLineItem.KS_Cantidad__c = prOfer.KS_Cantidad__c;
            oppLineItem.KS_Cantidad_Ficha__c = prOfer.KS_Cantidad_Ficha__c;
            oppLineItem.Quantity = prOfer.Quantity;
            oppLineItem.PricebookEntryId = prOfer.PricebookEntryId;
            dupliductos.add(oppLineItem);
        }
        System.debug('-- JCAR ---------------------------------- - INSERT ' + dupliductos.size() + ' productos_oferta - ' + dupliductos);
        Database.SaveResult[] results = Database.insert(dupliductos,false); 
        System.debug('-- JCAR ---------------------------------- - ERRORS? ' + results.size() + ' results - ' + results);

        //List<OpportunityLineItem> dupliductosOK = new List<OpportunityLineItem>();

        Integer index = 0;
        for(Database.SaveResult res : results) {
            OpportunityLineItem pr = dupliductos.get(index);
            if(!res.isSuccess()){
                System.debug('-- JCAR ---------------------------------- - ERROR producto_oferta - ' + pr.ID + ' - ' + res);
                errorText = 'Fallo al insertar línea de oportunidad. PRODUCTO: ' + pr.ProductCode + ' -- ' + res.getErrors()[0].getMessage();
            }
            index++;
        }
        
        // Relanzamos la query
        setProductosFromOferta();
        fichaToEdit = newFicha;
        // save(); // Guardado de "porsiaca"¿?
        mapProductosOferta();
        enableEdit();
    }
    
    public void deleteFicha() {

        for (OpportunityLineItem prOfer : productosOferta.get(fichaToEdit)) {
            isDelete.put(prOfer.ID, true);
        }
        save();
    }
    
    public void setProductosFromOferta() {
        productosLst = [SELECT Id, OpportunityId, Product2Id, ProductCode, Name, Quantity, KS_Cantidad__c, TotalPrice, UnitPrice, ListPrice, ServiceDate, Description, 
                        KS_Dto_base_1__c, KS_Dto_base_2__c, KS_Dto_adicional_1__c, KS_Dto_adicional_2__c, KS_precio_neto__c, KS_Descuento_neto__c, 
                        KS_Dto_logistico__c, KS_Material_sin_cargo__c, KS_Ficha__c, KS_Prescrito__c, KS_Dto_Instalador__c, KS_Dto_cliente_final__c, 
                        KS_Destinatario__c, CurrencyIsoCode, KS_Cantidad_Ficha__c, KS_Cantidad_Total__c, PricebookEntryId, KS_Material__c,
                        KS_Comentarios__c, KS_Competencia__c
                        FROM OpportunityLineItem WHERE OpportunityID = :oferta.ID ORDER BY KS_Ficha__c ASC];
        productosLst = productosLst != null ? productosLst : new List<OpportunityLineItem>(); // Por si acaso        
    }
    
    public PageReference cancel() {
        fichaToEdit = null;
        mapProductosOferta();
        return null; 
    }  
}