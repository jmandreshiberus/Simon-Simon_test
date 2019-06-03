global without sharing class KS_Oferta_PDF_Controller {
    
    public Opportunity oferta {get;set;}
    public KS_Oferta_pendiente__c ofertaPendiente {get;set;}
    public String getFechaPDF() { 
        if (ofertaPendiente==null) {return '';}
        return ofertaPendiente.CreatedDate.format('dd/MM/YYYY');
    }

    public Map<Decimal,List<OpportunityLineItem>> productosOferta {get;set;} // Mapeo de: String "Ficha", Lista "Productos Oferta"
    private List<OpportunityLineItem> productosLst {get;set;} // Todos los productosOferta
    public Boolean getHasProductos() { return productosLst != null && !productosLst.isEmpty(); }
    public Set<Decimal> getFichas() { return (productosOferta != null && !productosOferta.isEmpty()) ? productosOferta.keySet() : new Set<Decimal>(); }    
    public Boolean getHasDetalle() {return ofertaPendiente != null && ofertaPendiente.KS_Detalle__c;}
    
    public Map<Decimal,String> totalImporte {get;set;}
    public Map<Decimal,String> totalCantidad {get;set;}
    public Map<Decimal,Integer> totalCantidadFicha {get;set;}
    public Map<Decimal,String> totalImporteFicha {get;set;}
    public Map<Decimal,String> comentario {get;set;}
    public Map<Decimal,String> nombre {get;set;}
    public Map<Decimal,String> precioUnidad {get;set;}
    public Map<Decimal,String> precioCntdad {get;set;}
    
    public Integer getNumFichas() { return getFichas().size(); }

    public String fileName {get;set;}
    public Boolean noattach {get;set;}
    
    public Boolean getIsMarcaSimon() {
        if (oferta == null) {return false;}
        if (oferta.KS_Organizacion_de_ventas__c == null) {return false;}
        return oferta.KS_Organizacion_de_ventas__c == 'SI10';
    }
    public Boolean getIsMarcaFluvia() {
        if (oferta == null) {return false;}
        if (oferta.KS_Organizacion_de_ventas__c == null) {return false;}
        return oferta.KS_Organizacion_de_ventas__c == 'FL31';
    } 
    public Boolean getIsMarcaDefault() {
        return !getIsMarcaSimon() && ! getIsMarcaFluvia();
    }
    
    public String getFecha() {
        return Datetime.now().format('dd\'/\'MM\'/\'YYYY kk\':\'mm');
    }
    
    public KS_Oferta_PDF_Controller(ApexPages.StandardController controller) {    
        
		noattach = false;
        String noattachS = ApexPages.currentPage().getParameters().get('noattach');
        noattach = noattachS != null ? Boolean.valueOf(noattachS) : false;
        
        ofertaPendiente = (KS_Oferta_pendiente__c)controller.getRecord();
        if (ofertaPendiente != null) {
            ofertaPendiente = [SELECT Id, KS_Oferta__c, KS_Cuenta__c, KS_Obra__c, KS_Detalle__c, KS_Cliente_Name__c, 
                               KS_Contacto__c, KS_Contacto_Name__c, KS_Obra_Name__c, KS_Cuenta_Direccion__c,
                               CreatedById, KS_Creador_Name__c, CreatedDate FROM KS_Oferta_pendiente__c WHERE ID = :ofertaPendiente.ID];
            
            if (ofertaPendiente.KS_Oferta__c != null) { // OJO: Siempre debería entrar, sustituye edición y visualización
                
                oferta = [ SELECT Id, IsDeleted, KS_Distribuidor__c, AccountId, RecordTypeId, Name, Description, StageName, Amount, CloseDate, Type, 
                          NextStep, LeadSource, IsClosed, IsWon, ForecastCategory, ForecastCategoryName, CurrencyIsoCode, CampaignId, 
                          HasOpportunityLineItem, Pricebook2Id, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                          SystemModstamp, LastActivityDate, FiscalQuarter, FiscalYear, Fiscal, LastViewedDate, LastReferencedDate, HasOpenActivity, 
                          HasOverdueTask, KS_Funciona__c, KS_Contabiliza__c, KS_Obra__c, KS_Subetapa__c, KS_Dto_Volumen__c, 
                          KS_Oferta_ID__c, KS_Importe_total_fichas__c, KS_Probabilidad__c, KS_Instalador__c, KS_Cliente_final__c, 
                          KS_Organizacion_Cliente__c, KS_Organizacion__c, KS_max_ficha__c, KS_Lista_de_precios__c, KS_sum_condicion_obra__c, 
                          KS_Margen_Distribuidor__c, KS_Margen_Instalador__c, KS_Margen_Cliente__c, KS_Margen_Operacion__c, KS_Margen_Intervinientes__c,
                          KS_descuento_total_operacion__c, KS_Importe_total_Instalador_c__c, KS_Importe_total_Cliente_Final__c, PVP_con_MSC_para_distribuidor__c, 
                          KS_Descuento_total_Distribuidor__c, KS_PVP_con_MSC_para_Instalador__c, KS_PVP_con_MSC_para_Cliente_Final__c, 
                          KS_Descuento_total_Instalador__c, KS_Descuento_total_Cliente_Final__c, KS_Organizacion_de_ventas__c, KS_Distribuidor_importe_PVP__c 
                          FROM Opportunity WHERE ID = :ofertaPendiente.KS_Oferta__c];
                setProductosFromOferta();
                mapProductosOferta();
                
                String fechaName = Datetime.now().format('YYYYMMdd\'_\'kkmmss');
                fileName = oferta.KS_Oferta_ID__c + '_' + fechaName + '.pdf';
                Apexpages.currentPage().getHeaders().put( 'content-disposition', 'inline; filename=' + fileName);
                for (String k : Apexpages.currentPage().getHeaders().keySet()) {
                    System.debug('-- JCAR ---------------------------------- - getHeaders - ' + k + ' : ' + Apexpages.currentPage().getHeaders().get(k));
                }
            }
        }
    }
    
    public void/*Pagereference*/ attachBUILD() {
        
        Pagereference pg = null;
        if (!noattach) {
            pg = Page.KS_Oferta_PDF;
            pg.getParameters().put('id',ofertaPendiente.ID);
            pg.getParameters().put('noattach','true');
            Blob pdf1 = pg.getcontentAsPdf();
            Attachment a = new Attachment();
            a.ParentId = ofertaPendiente.ID;
            a.Body = Pdf1;
            a.Name = fileName;
            a.ContentType = 'application/pdf';
            upsert a;
        }
        noattach = false;
        //return pg;
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
        }

        // Añadimos totales y creamos mapeos/listas
        Decimal lastFicha = 0;
        for (Decimal ficha : productosOferta.keySet()) {
            String divisa = productosOferta.get(ficha).get(0).CurrencyIsoCode;
            setTotalImporte(ficha, divisa);
            setTotalCantidad(ficha);
            setTotalCantidadFicha(ficha);
            setTotalImporteFicha(ficha);
            setNombreFich(ficha);
            setComentario(ficha);
            setPrecioToFormat(ficha);
        }
    }
    
    public void setProductosFromOferta() {
        productosLst = [SELECT Id, OpportunityId, KS_Producto__c, Product2Id, ProductCode, Name, Quantity, KS_Cantidad__c, TotalPrice, UnitPrice, ListPrice, ServiceDate, Description, 
                        KS_Descripcion__c, KS_Dto_base_1__c, KS_Dto_base_2__c, KS_Dto_adicional_1__c, KS_Dto_adicional_2__c, KS_precio_neto__c, KS_Descuento_neto__c, 
                        KS_Dto_logistico__c, KS_Material_sin_cargo__c, KS_Ficha__c, KS_Prescrito__c, KS_Dto_Instalador__c, KS_Dto_cliente_final__c, 
                        KS_Destinatario__c, CurrencyIsoCode, KS_Cantidad_Ficha__c, KS_Cantidad_Total__c, PricebookEntryId, KS_Material__c,
                        KS_Comentarios__c, KS_Competencia__c, KS_Competidor__c, KS_Bruto_Cantidad__c, KS_Referencia__c, KS_Ficha_Nombre__c, KS_Orden__c
                        FROM OpportunityLineItem WHERE OpportunityID = :oferta.ID ORDER BY KS_Ficha__c, KS_Orden__c ASC];
        productosLst = productosLst != null ? productosLst : new List<OpportunityLineItem>(); // Por si acaso
    }  

    private void setNombreFich(Decimal ficha) {
        nombre = nombre != null ? nombre : new Map<Decimal,String>();
        String nomS = '';
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        for (OpportunityLineItem opL : prdctsLst) {
            nomS = opL.KS_Ficha_Nombre__c;
        }
        nomS = nomS != null ? nomS : OpportunityLineItem.fields.KS_Ficha__c.getDescribe().getLabel() + ' ' + ficha;
        nombre.put(ficha, nomS);
    }
    private void setComentario(Decimal ficha) {
        comentario = comentario != null ? comentario : new Map<Decimal,String>();
        String comS = '';
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        for (OpportunityLineItem opL : prdctsLst) {
            comS = opL.KS_Comentarios__c;
        }
        comentario.put(ficha, comS != null ? comS : '');
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
        totalImporte.put(ficha, stotal);
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
    private void setTotalImporteFicha(Decimal ficha) {
        
        totalImporteFicha = totalImporteFicha != null ? totalImporteFicha : new Map<Decimal,String>();
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        
        Decimal totalCantidad = 0;
        totalCantidad = prdctsLst.get(0).KS_Cantidad_Ficha__c; totalCantidad = totalCantidad > 0 ? totalCantidad : 1;   
        
        Decimal totalImporte = 0;
        for (OpportunityLineItem prOfer : prdctsLst) { 
            totalImporte += (prOfer.UnitPrice*prOfer.KS_Cantidad__c);
        }
        
        Decimal total = totalCantidad*totalImporte;
        //System.debug('-- JCAR ---------------------------------- - total ' + total);
        String stotal = format2Decimal(total);
        totalImporteFicha.put(ficha, stotal);
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
    
    private void setPrecioToFormat(Decimal ficha) {
        if ( !productosOferta.containsKey(ficha) ) { return; }
        precioUnidad = precioUnidad != null ? precioUnidad : new Map<Decimal,String>();
        precioCntdad = precioCntdad != null ? precioCntdad : new Map<Decimal,String>();
        
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        for (OpportunityLineItem prOfer : prdctsLst) {
            
            Decimal precioU = prOfer.UnitPrice;
            String sPrecioU = format2Decimal(precioU);
            precioUnidad.put(precioU, sPrecioU);
            
            Decimal precioC = prOfer.KS_Bruto_Cantidad__c;
            String sPrecioC = format2Decimal(precioC);
            precioCntdad.put(precioC, sPrecioC);            
        }
    }
    
    public String getImporteTotalOferta() {
        return format2Decimal(oferta.Amount);
    }
}