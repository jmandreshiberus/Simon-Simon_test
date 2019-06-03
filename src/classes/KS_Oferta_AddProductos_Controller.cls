global without sharing class KS_Oferta_AddProductos_Controller {

    /* JCAR 170410 - Oferta_AddProductos
     * 
     * + DISEÑO INICIAL DEMO (1 jornada Edgard, 2 jornadas Ambroirse, 1 jornada JCAR) - 4 jornadas
     * 
     * + Autocompletar con carga de datos (Condiciones Comerciales) (getDatosProducto) - JCAR 170410
     * + Añadir, Borrar, Duplicar productos a la ficha/oferta (addProducto, delProducto, dupProducto) - JCAR 170411
     * + Reordenar productos de la ficha/oferta (sortProductos) - JCAR 170412
     * + Guardar/Cargar productos de ficha/oferta seleccionada (saveLineas, loadOpportunityLineItems) - JCAR 170412
     * 
     * + Crear, Duplicar y Borrar ficha (addFicha, dupFicha(dupProducto), delFicha) - JCAR 170413
     * + Navegar entre fichas existentes de la oferta (changeFicha)(funciona por campo onchange 4now) - JCAR 170413
     * 
     * + Importar productos desde lista de referencias (Referencia, addReferencias) - JCAR 170418, 170419
     * + Buscar productos, usará la antigua VF y volverá a la nueva (selProducto, getParamFromSearch) - JCAR 170419, 170420
     * + Guardado de seguridad cuando se efectúan cambios: Añadir/Buscar/Duplicar producto - JCAR 170421
	 * + Guardado al Ordenar producto (KS_Orden__c) - JCAR 170428
	 * + Material sin cargo - JCAR 170428
	 * + Guardado al modificar campos del producto - JCAR 170428
	 * 
     * + Selector de fichas (Picklist con todas las fichas existentes + creadas en caliente) - JCAR 170426
     * + Total de fichas: Neto (suma de netos), PVP (suma de brutos), DTO Distribuidor (diferencia entre bruto y neto) - JCAR 170427
	 * + Dto. Logístico - JCAR 170427
	 * - Aprobaciones - JCAR 170428, 170502 - FALTA COMPROBACIÓN CON DATOS (TEST PRODUCTIVO?)
	 * 
	 * + Añadir labels multilenguaje - JCAR 170502
	 * + Gestión de errores - JCAR 170502
     * 
     * // PRODUCTOS CON PRICEBOOK Y TARIFA VÁLIDA:
     * // 82062-60, K01/6, K01/7, K01/9, K01/14
     */
    
    public Opportunity oferta {get;set;} // Objeto principal
    public Map<String, OpportunityLineItem> productosOferta {get;set;} // Objeto secundario
    public Map<String, Product2> productosSalesF {get;set;} // Objeto terciario
    public Map<String, String> productosSalesFID {get;set;}
	public List<Decimal> orden {get;set;}
    public Map<Decimal,String> productos {get;set;}
    public Map<String, String> productosMaterial {get;set;}
    public Map<String, Boolean> productosSeleccion {get;set;}
    
    public String productoLookup {get;set;}
    public String productoIDROW {get;set;}
    public Integer productosADD {get;set;}
    
    public Integer totalProductos {get;set;}
    public String prodKey {get;set;}
    
    public Set<Decimal> fichas {get;set;}
    public Decimal fichaSelect {get;set;}
    public Decimal fichaMaxima {get;set;}
    public Decimal getFichaMaximaVal() {
        return fichaList.size();//fichaSelect > oferta.KS_max_ficha__c ? fichaSelect : oferta.KS_max_ficha__c;
    }
    public Decimal getFichaActualIndex() {
        Integer i = 0;
        List<Decimal> fichas = new List<Decimal>(); 
        fichas.addAll(fichaList.keySet()); fichas.sort();
        for (Decimal f : fichas) {
            if (f == fichaSelect) { return ++i; }
            i++;
        }
        return 1;
    }
    public Decimal fichaCantidad {get;set;}
    public String fichaComentario {get;set;}
    public String fichaNombre {get;set;}
    public Boolean fromSearch {get;set;}
	public OpportunityLineItem fichaComp {get;set;}
    
    public Map<Decimal, SelectOption> fichaList {get;set;}
    public Map<Decimal,String> fichasOferta {get;set;}
    public List<SelectOption> getFichasSelect() {
        fichaList = fichaList != null ? fichaList : calcFichaList();
        List<SelectOption> sL = new List<SelectOption>();
        List<Decimal> fichas = new List<Decimal>(); 
        fichas.addAll(fichaList.keySet()); fichas.sort();
        for (Decimal f : fichas) {
            String nameFicha = (String)fichasOferta.get(f);
            nameFicha = nameFicha != null ? nameFicha : stringNewFicha;
            sL.add(new SelectOption(''+f, nameFicha));
        }
        return sL;
    }
    
    public String oppLineToDel {get;set;}
    public String oppLineToSave {get;set;}
    public Boolean getSaveLinea() {
        System.debug('-- JCAR ---------------------------------- - getSaveLinea? lineToSave is ' + oppLineToSave);
        return oppLineToSave != null && oppLineToSave.trim() != '';
    }
    
    public String getSalir() {
        if (oferta != null && oferta.ID != null) {
            return '/'+oferta.ID;
        } else {
            return '/006';
        }
    }
    
    public String referencias {get;set;}
    public Boolean getHaveReferencias() {
        if(referencias != null && referencias.trim() != '') {
            return referencias.contains(',');
        }
        return false;
    }
    public String validacionReferencias {get;set;}
    public Boolean getErrorReferencias() {
        return validacionReferencias != null && validacionReferencias.trim() != '';
    }
    public String errorGeneric {get;set;}
    public Boolean getHaveError() {
        return errorGeneric !=null && errorGeneric.trim() !='';
    }   
    public String errorTextOferta {get;set;}
    public Boolean getHaveErrorOferta() {
        return errorTextOferta !=null && errorTextOferta.trim() !='';
    }    
    public String errorTextFicha {get;set;}
    public Boolean getHaveErrorFicha() {
        return errorTextFicha !=null && errorTextFicha.trim() !='';
    }
    
    public String getPricelssProduct() {return 'SF-SERVICIOS';}
    
    /* Pone a null todos los string de error, usar al principio de cualquier acción */
    private void resetErrores() {
        validacionReferencias = null;
        errorTextOferta = null;
        errorTextFicha = null;
        errorGeneric = null;
    }
    
    public KS_Oferta_Utils.TotalesFicha totales {get;set;}
    public String focusLinea {get;set;}
    public Boolean getHaveFocusLinea() {
        return focusLinea != null && focusLinea.trim() != '';
    }
    
    public Map<Boolean, String> getAprobacionClass() {
        Map<Boolean, String> aprobs = new Map<Boolean, String>();
        aprobs.put(true, 'fa-exclamation-triangle'); // KS_Necesita_aprobacion__c
        aprobs.put(false, 'fa-check-circle');
        return aprobs;
    }
    public Map<Boolean, String> getAprobacionColor() {
        Map<Boolean, String> aprobs = new Map<Boolean, String>();
        aprobs.put(true, 'orange'); // KS_Necesita_aprobacion__c
        aprobs.put(false, 'green');
        return aprobs;
    }
    
    private String stringNewFicha = Label.ks_btn_new_fem + ' ' + Label.Oferta_Ficha;
    
    public String getWhereClause() {
        String condiciones = ' KS_Tarifa__c = \'' + oferta.KS_Lista_de_precios__c + '\' ';
        condiciones += ' AND KS_Organizacion_Ventas__c = \'' + oferta.KS_Organizacion_de_Ventas__c + '\' ';
        condiciones += ' AND KS_Canal__c = \'' + oferta.KS_Canal__c + '\' ';
        condiciones += ' AND KS_Sector__c = \'' + oferta.KS_Sector__c + '\' ';
        return condiciones;
    }
    
    public Boolean prescritGlobal {set;get;}
    public Boolean getPrescritGlobalValue() {
        if (productosOferta.isEmpty()) {return false;}
        for (OpportunityLineItem oli : productosOferta.values()) {
            if (!oli.KS_Prescrito__c) { return false; }
        }
        return true;
    }
    public Boolean sincargoGlobal {set;get;}
    public Boolean getSincargoGlobalValue() {
        if (productosOferta.isEmpty()) {return false;}
        for (OpportunityLineItem oli : productosOferta.values()) {
            if (!oli.KS_Material_sin_cargo__c) { return false; }
        }
        return true;
    }
    
    public KS_Oferta_AddProductos_Controller(ApexPages.StandardController controller) {

        // INICIALIZACIÓN MAPEOS
        initData();
        
        // INICIALIZACIÓN DATOS
        prodKey = '_KS_';
        fichaSelect = 1;
        fichaCantidad = 1;
        fichaComp = new OpportunityLineItem();
        productosADD = 10; // Valor por defecto de productos a añadir, solamente se usará cuando se lance el método de añadir
        getParam();
        fromSearch = (productoIDROW != null && productoIDROW != '');
        
        // CARGA DE DATOS EXISTENTES
        oferta = (Opportunity)controller.getRecord();
        
        initOferta();
        if (fromSearch) 
        { getParamFromSearch(); setLineasFromSearch(); }
        
        resetErrores();
    }
    
    private void getParam() {
        
        String paramFicha = ApexPages.currentPage().getParameters().get('ficha');
        if (paramFicha != null && paramFicha.trim() != '' && paramFicha.isNumeric()) { 
            fichaSelect = Integer.valueOf(paramFicha);
        }
        String paramRowProd = ApexPages.currentPage().getParameters().get('rowProducto');
        if (paramRowProd != null && paramRowProd.trim() != '') {
            productoIDROW = paramRowProd;
        }
    }
    
    private void getParamFromSearch() {

        String paramIdProd = ApexPages.currentPage().getParameters().get('idProducto');
        if (paramIdProd != null && paramIdProd.trim() != '') {
            productoLookup = paramIdProd;
        }
        String paramFichaLineas = ApexPages.currentPage().getParameters().get('fichaLineas');
        if (paramFichaLineas != null && paramFichaLineas != '' && paramFichaLineas.isNumeric()) { 
            totalProductos = Integer.valueOf(paramFichaLineas);
        }
    }
    
    private void initData() {
        productosOferta = new Map<String, OpportunityLineItem>();
        orden = new List<Decimal>();
        productos = new Map<Decimal,String>();
        productosMaterial = new Map<String, String>();
        productosSalesF = new Map<String, Product2>();
        productosSalesFID = new Map<String, String>();
        productosSeleccion = new Map<String, Boolean>();
        totalProductos = 0;
        focusLinea = null;
    }
    
    private void initOferta() {
        oferta = oferta != null ? oferta : new Opportunity();
        totales = new KS_Oferta_Utils.TotalesFicha();
        
        if (oferta.ID != null) {
            
            oferta = [ SELECT Id, IsDeleted, AccountId, KS_Distribuidor__c, RecordTypeId, Name, Description, StageName, Amount, CloseDate, Type, 
                      NextStep, LeadSource, IsClosed, IsWon, ForecastCategory, ForecastCategoryName, CurrencyIsoCode, CampaignId, KS_Referencia__c,  
                      HasOpportunityLineItem, Pricebook2Id, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                      SystemModstamp, LastActivityDate, FiscalQuarter, FiscalYear, Fiscal, LastViewedDate, LastReferencedDate, HasOpenActivity, 
                      HasOverdueTask, KS_Funciona__c, KS_Contabiliza__c, KS_Obra__c, KS_Subetapa__c, KS_Dto_Volumen__c, 
                      KS_Organizacion_de_Ventas__c, KS_Canal__c, KS_Sector__c, KS_Lista_de_precios__c,
                      KS_Oferta_ID__c, KS_Importe_total_fichas__c, KS_Probabilidad__c, KS_Instalador__c, KS_Cliente_final__c, 
                      KS_Organizacion_Cliente__c, KS_Organizacion__c, KS_min_ficha__c, KS_max_ficha__c, KS_sum_condicion_obra__c, 
                      KS_Margen_Distribuidor__c, KS_Margen_Instalador__c, KS_Margen_Cliente__c, KS_Margen_Operacion__c, KS_Margen_Intervinientes__c,
                      KS_descuento_total_operacion__c, KS_Importe_total_Instalador_c__c, KS_Importe_total_Cliente_Final__c, PVP_con_MSC_para_distribuidor__c, 
                      KS_Distribuidor_importe_PVP__c , KS_Distribuidor_MSC_en_PVP__c, MSC_Distribuidor__c, KS_Instalador_Importe_PVP__c, KS_Instalador_MSC_en_PVP__c, 
                      MSC_Instalador__c, KS_Cliente_final_Importe_PVP__c, KS_Cliente_final_MSC_en_PVP__c, MSC_Cliente_Final__c,                      
                      KS_Descuento_total_Distribuidor__c, KS_PVP_con_MSC_para_Instalador__c,PVP_con_MSC_para_Instalador_fx__c, KS_PVP_con_MSC_para_Cliente_Final__c, KS_Submitted_for_Approval__c,
                      KS_Descuento_total_Instalador__c, KS_Descuento_total_Cliente_Final__c, KS_Agente_de_contabilizacion__c, KS_Nivel2__c,KS_Nivel3__c,KS_Nivel4__c,
                      KS_Nivel_de_aprobacion_de_4__c, KS_Resp_Iluminacion__c, KS_Resp_Conectividad__c, KS_Resp_Sist_Control__c, KS_Resp_Vehiculo_Electrico__c, KS_Resp_resto_de_gamas__c, KS_Resp_negocio_iberia__c,
                      KS_Margen_distribuidor_pctge__c, KS_Margen_instalador_pctge__c, KS_Estado_de_aprobacion__c, KS_Aprobado__c, 
                      KS_Resp_Jefe_de_Area__c, KS_Resp_Negocio_Iberia_2__c, Territory2Id, KS_Protected__c, KS_Oferta_Origen_String__c, KS_Oferta_Origen__c, 
                      KS_Area__c, KS_Delegacion__c, KS_Zona__c, KS_AreaF__c, KS_DelegacionF__c, KS_ZonaF__c, KS_Pais__c, KS_Suma_Dto_Ad2__c
                      FROM Opportunity WHERE ID = :oferta.ID ];
            
            System.debug('-- JCAR ---------------------------------- - initOferta oferta = ' + oferta);
            
            Boolean newFicha = false;
            if (fichaSelect != null && fichaSelect == 0) { // Normalmente vendrá de la Oferta como 0, significa "Nueva ficha"
                fichaSelect = oferta.KS_max_ficha__c != null ? oferta.KS_max_ficha__c+1 : 0; 
                newFicha = true;
            }
            // Selección de ficha actual: Si viene de búsqueda, el parametro tiene prioridad. 
            // Si no pero hay ficha informada, la ficha debe estar entre la minima y maxima de la oferta
            // o se asignará la minima si es inferior y la maxima si es superior
            else if (fichaSelect != null && fromSearch) { fichaSelect = fichaSelect; } // Asignación tonta
            else if (fichaSelect != null && fichaSelect < oferta.KS_min_ficha__c) { fichaSelect = oferta.KS_min_ficha__c; }
            else if (fichaSelect != null && fichaSelect > oferta.KS_max_ficha__c) { fichaSelect = oferta.KS_max_ficha__c; }
            else if (fichaSelect != null) { fichaSelect = fichaSelect; } // Asignación tonta
            else { fichaSelect = oferta.KS_min_ficha__c; }
            if (fichaSelect == null || fichaSelect == 0) { fichaSelect = 1; }
            
            // La ficha máxima será la select si es superior o la maxima de la ofera
            if (oferta.KS_max_ficha__c == null) { fichaMaxima = fichaSelect; }
            else if (fichaSelect > oferta.KS_max_ficha__c) { 
                fichaMaxima = fichaSelect;
                if (fromSearch) { newFicha = true; }
            }
            else { fichaMaxima = oferta.KS_max_ficha__c; }

            System.debug('-- JCAR ---------------------------------- - initOferta fichaMinima = ' + oferta.KS_min_ficha__c);
            System.debug('-- JCAR ---------------------------------- - initOferta fichaSelect = ' + fichaSelect);
            System.debug('-- JCAR ---------------------------------- - initOferta fichaMaxima = ' + fichaMaxima);
            
            // Generamos la lista de fichas con todo lo sabido
            fichaList = calcFichaList();
            if (newFicha) {
                fichaList.put(fichaSelect, new SelectOption(''+fichaSelect, stringNewFicha) );
                fichasOferta.put(fichaSelect, stringNewFicha);
            }
			// Obtenemos las lineas de oportuniad (productos) a partir de la ficha selccionada
            loadOpportunityLineItems();
            
            if (productosOferta.isEmpty()) {
                productosADD = 5; // Añadimos 5 "productos" vacíos a la nueva ficha
                addProductos();
            }
        }        
    }
    
    public void loadOpportunityLineItems() {
        
        if (oferta.ID != null) {
           
            List<OpportunityLineItem> oliLst = 
                [SELECT Id, OpportunityId, KS_Obra__c, KS_Producto__c, Product2Id, ProductCode, Name, Quantity, KS_Cantidad__c, TotalPrice, UnitPrice, ListPrice, ServiceDate, Description, 
                 KS_Nombre__c, KS_Dto_base_1__c, KS_Dto_base_2__c, KS_Dto_Campaign__c, KS_Dto_adicional_1__c, KS_Dto_adicional_2__c, KS_precio_neto__c, KS_Descuento_neto__c, 
                 KS_Dto_volumen__c, KS_Material_sin_cargo__c, KS_Ficha__c, KS_Prescrito__c, KS_Dto_Instalador__c, KS_Dto_cliente_final__c, 
                 KS_Destinatario__c, CurrencyIsoCode, KS_Cantidad_Ficha__c, KS_Cantidad_Total__c, PricebookEntryId, KS_Material__c,
                 KS_Comentarios__c, KS_Competencia__c, KS_Competidor__c, KS_Necesita_aprobacion__c, KS_Aprobacion__c, KS_Neto_Base__c, KS_Dto_Logistico__c,
                 KS_Dto_SinCargo__c, KS_Dest_ClieFinal__c, KS_Dest_Distribuidor__c, KS_Dest_Instalador__c, KS_Referencia__c, KS_Orden__c,
                 KS_Neto_por_fila__c, KS_Neto_Unitario__c, KS_Neto_Unitario_Cliente_Final__c, Ks_Neto_Unitario_Instalador__c, KS_Ficha_Nombre__c, KS_Desc_Manual__c
                 FROM OpportunityLineItem 
                 WHERE OpportunityID = :oferta.ID AND KS_Ficha__c = :fichaSelect ORDER BY KS_Orden__c ASC];
            
            totalProductos = oliLst.size();
            if (totalProductos>0) {
                
                Map<String,String> tmp_prodOppMap = new Map<String,String>();
                for (OpportunityLineItem oli : oliLst) {
                    tmp_prodOppMap.put(oli.ID, oli.Product2Id);
                }
                
                Map<String,Product2> tmp_prodMap = new Map<String,Product2>();
                List<Product2> prodLstTMP = 
                    [SELECT ID, Name, ProductCode, Family, 
                     KS_Id_SAP__c, KS_Tipo_de_material__c, KS_Nombre_Producto__c, KS_Descripcion_corta__c, isActive
                     FROM Product2 WHERE ID in :tmp_prodOppMap.values()];
                for (Product2 prod : prodLstTMP) {
                    tmp_prodMap.put(prod.ID, prod);
                }
                
                Integer index = productos.size();
                for (OpportunityLineItem oli : oliLst) {
                    oli.KS_Orden__c = index;
                    oli.KS_Ficha__c = fichaSelect;
                    Product2 prod = tmp_prodMap.get(oli.Product2Id);
                    //oli.KS_Necesita_aprobacion__c = true;
                    createOppLine(oli, prod, index);
                    index++;
                    fichaCantidad = oli.KS_Cantidad_Ficha__c;
                    fichaComentario = oli.KS_Comentarios__c;
                    fichaNombre = oli.KS_Ficha_Nombre__c;
                    fichaComp.KS_Competidor__c = oli.KS_Competidor__c;
                }

                // Calculamos totales actuales
                totales.calc(productosOferta.values());
            }
            
            if (fichaNombre == null) {
                fichaNombre = stringNewFicha;
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - loadOpportunityLineItems productosOferta = ' + productosOferta);
    }
    
    private OpportunityLineItem createOppLine(OpportunityLineItem oli, Product2 prod, Decimal index) {
        
        //System.debug('-- JCAR ---------------------------------- - createOppLine oli = ' + oli);
        //System.debug('-- JCAR ---------------------------------- - createOppLine prod = ' + prod);
        //System.debug('-- JCAR ---------------------------------- - createOppLine index = ' + index);
        
        String key = prodKey + (index < 10 ? '00'+index : (index < 100 ? '0'+index : index+''));
        //System.debug('-- JCAR ---------------------------------- - createOppLine key = ' + key);
        oli = oli != null ? oli : new OpportunityLineItem(KS_Orden__c = index);
        
        if(prod != null && prod.KS_Id_SAP__c == getPricelssProduct()) {
            if (oli.KS_Desc_Manual__c == null || (oli.KS_Desc_Manual__c != null && oli.KS_Desc_Manual__c.trim() != '')) 
            { oli.KS_Desc_Manual__c = prod.KS_descripcion_corta__c; }
        }
        
        orden.add(index);
        productos.put(index,key);
        productosOferta.put(key, oli);
        productosMaterial.put(key, prod != null ? prod.KS_Id_SAP__c : '');
        productosSalesF.put(key, prod != null ? prod : new Product2());
        productosSalesFID.put(key, prod != null ? ''+prod.ID : '');
        productosSeleccion.put(key,false);
        
        return oli;
    }
    
    public PageReference callSaveLineasRefresh() {
        callSaveLineas();
        if (!getHaveError()) {
            PageReference pg = new PageReference(
                '/apex/KS_Oferta_AddProductos?' 
                + 'id='+oferta.ID
                + '&ficha='+fichaSelect);
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }
    public void callSaveLineas() {
        try { saveLineas(); } 
        catch(Exception ex) { 
            errorGeneric = '## ERROR ## ' + ex.getMessage(); System.debug('callSaveLineas ' + errorGeneric);
            oppLineToSave = null;
            oppLineToDel = null;
        }
    }
    private void saveLineas() {

        if (!canSave()) {return;}
        
        if (getSaveLinea()) { 
            System.debug('-- JCAR ---------------------------------- - saveLineas oppLineToSave = ' + oppLineToSave);
            System.debug('-- JCAR ---------------------------------- - saveLineas oppLineToDel = ' + oppLineToDel);
            saveLineas(oppLineToSave); 
            deleteOldLinea(oppLineToDel);
        } 
        else { saveLineas(null); }
		oppLineToSave = null;
        oppLineToDel = null;

        changeFichaName(fichaSelect, fichaNombre);
    }
    private void saveLineas(String rowProducto) {
        
        Boolean oneLinea = rowProducto != null;
        resetErrores();
        sortProductos();
        setPriceBook(rowProducto);
        setFicha(rowProducto);
        
        List<OpportunityLineItem> saveOfertas = new List<OpportunityLineItem>();
        Integer emptyLines = 0;
        if (oneLinea) {
            System.debug('-- JCAR ---------------------------------- - saveLineas oneLinea = ' + rowProducto);
            OpportunityLineItem oppLin = productosOferta.get(rowProducto);
            if (productosMaterial.get(rowProducto)==getPricelssProduct()) { oppLin.TotalPrice = getTotalPrice(oppLin); oppLin.UnitPrice = null; productosOferta.put(rowProducto, oppLin); }
            
            saveOfertas.add(oppLin);
        } else {
            System.debug('-- JCAR ---------------------------------- - saveLineas productos = ' + productos);
            System.debug('-- JCAR ---------------------------------- - saveLineas productosOferta = ' + productosOferta);
            
            for (Decimal ord : productos.keySet()) {
                String prod = productos.get(ord);
                if (prod != null && prod.trim() != '') {
                    if (productosSalesFID.containsKey(prod) && productosSalesFID.get(prod) != null && productosSalesFID.get(prod).trim() != '') {
                        if (productosOferta.containsKey(prod) && productosOferta.get(prod) != null)
                        { 
                            OpportunityLineItem oppLin = productosOferta.get(prod);
                            if (productosMaterial.get(prod)==getPricelssProduct()) { oppLin.TotalPrice = getTotalPrice(oppLin); productosOferta.put(prod, oppLin); }
                            if (oppLin.TotalPrice != null 
                                && productosMaterial.get(prod)==getPricelssProduct()
                                && oppLin.ID == null) 
                            { oppLin.UnitPrice = null; }
                            saveOfertas.add(oppLin); 
                        }
                    } else {
                        emptyLines++;
                    }
                } else {
                    emptyLines++;
                }
            }            
        }
        
        System.debug('-- JCAR ---------------------------------- - saveLineas ' + saveOfertas.size() + ' saveOfertas = ' + saveOfertas);
        upsert saveOfertas;
        setOrgProducto(saveOfertas);

        if (!oneLinea) {
            System.debug('-- JCAR ---------------------------------- - emptyLines? ' + emptyLines);
            initData();
            loadOpportunityLineItems();
            if (emptyLines>0) { productosADD = emptyLines; addProductos(); }
        } else {
            OpportunityLineItem oli = productosOferta.get(rowProducto);
            oppLineToSave = null;
            //if (oli.ID != null) { oli = reloadOpportunityLine(oli); productosOferta.put(rowProducto,oli); }
        }
        totales.calc(productosOferta.values());
    }
    public List<OpportunityLineItem> setOrgProducto(List<OpportunityLineItem> oppLineLst) {
        
        List<OpportunityLineItem> oppToProcess = new List<OpportunityLineItem>();
        for (OpportunityLineItem oli : oppLineLst) {
            Boolean add = 
                oli.KS_SuperFamilia__c == null 
                || oli.KS_Familia__c == null
                || oli.KS_Serie__c == null
                || oli.KS_SubSerie__c == null;
            if (add) { oppToProcess.add(oli); }
        }
        if (oppToProcess.isEmpty()) { return oppLineLst; }
        oppToProcess = reloadOpportunityLine(oppToProcess);
        
        List<ID> prodID = new List<ID>(); 
        Map<ID, OpportunityLineItem> saveLst = new Map<ID, OpportunityLineItem>();
        Map<ID, List<OpportunityLineItem>> prodMAP = new Map<ID, List<OpportunityLineItem>>();
        for (OpportunityLineItem oli : oppToProcess) {
            if (oli.Product2Id != null) {
                
                List<OpportunityLineItem> oLlst = new List<OpportunityLineItem>();
                if (prodMAP.containsKey(oli.Product2Id)) { oLlst = prodMAP.get(oli.Product2Id);}
                
                Boolean add = 
                    oli.KS_SuperFamilia__c == null 
                    || oli.KS_Familia__c == null
                    || oli.KS_Serie__c == null
                    || oli.KS_SubSerie__c == null;

                if (add) {
                    prodID.add(oli.Product2Id); 
                    oLlst.add(oli);
                    prodMAP.put(oli.Product2Id, oLlst);
                }
            }
        }

        if (prodID.isEmpty()) {return oppLineLst;}
        List<KS_Organizacion_Producto__c> orgProdQRY =
            [SELECT ID, KS_Producto__c, KS_Superfamilia__c, KS_Familia__c, KS_Serie_Gama__c, KS_Subserie__c
             FROM KS_Organizacion_Producto__c WHERE KS_Producto__c IN :prodID 
             AND KS_Organizacion_de_Ventas__c = :oferta.KS_Organizacion_de_ventas__c
             AND KS_Canal_de_distribucion__c = :oferta.KS_Canal__c
             AND KS_Sector__c = :oferta.KS_Sector__c];
        for (KS_Organizacion_Producto__c org : orgProdQRY) {
            
            if (prodMAP.containsKey(org.KS_Producto__c)) {

                for (OpportunityLineItem oli : prodMAP.get(org.KS_Producto__c)) {

                    if ( oli.ID == null ) { continue; }
                    if ( saveLst.containsKey(oli.ID) ) { oli = saveLst.get(oli.ID); }
                    oli.KS_SuperFamilia__c = org.KS_Superfamilia__c;
                    oli.KS_Familia__c = org.KS_Familia__c;
                    oli.KS_Serie__c = org.KS_Serie_Gama__c;
                    oli.KS_Subserie__c = org.KS_Subserie__c;
                    saveLst.put(oli.ID, oli);
                }
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - setOrgProducto ' + saveLst.size() + ' saveLst = ' + saveLst);
        update saveLst.values();
        return oppLineLst;
    }
    public void setPriceBook() { setPriceBook(null); }
    public void setPriceBook(String rowProducto) {
        
        Boolean oneLinea = rowProducto != null;
        
        Map<ID,ID> productPriceMAP = new Map<ID,ID>();
        List<PriceBookEntry> productIDsinPriceBook = new List<PriceBookEntry>();
        
        Pricebook2 priceBookStandard = new Pricebook2();
        if ( oferta.Pricebook2Id == null && !Test.isRunningTest()) {
            priceBookStandard = [SELECT Id FROM Pricebook2 WHERE isStandard = true and isActive = true limit 1];           
        }
        
        if (priceBookStandard == null && Test.isRunningTest()) { priceBookStandard = new Pricebook2(ID=Test.getStandardPricebookId()); }
        if (priceBookStandard != null && oferta.Pricebook2Id == null)  {
            oferta.Pricebook2Id = priceBookStandard.ID;
            update oferta;
        } 
        
        List<ID> idProductosLst = new List<ID>();
        if (oneLinea) {
            System.debug('-- JCAR ---------------------------------- - setPriceBook oferta - ' + productosOferta.get(rowProducto));
            idProductosLst.add(productosSalesFID.get(rowProducto));
        } else {
            for (String idProd : productosSalesFID.values()) {
                if (idProd != null && idProd.trim() != '') {
                    idProductosLst.add(idProd);
                }
            }
        }
        System.debug('-- JCAR ---------------------------------- - setPriceBook ' + idProductosLst.size() + ' idProductosLst - ' + idProductosLst);

        List<PriceBookEntry> priceBookList = 
            [SELECT Id, Product2Id, Product2.Id, Product2.Name, Product2.ProductCode, Product2.KS_Id_SAP__c 
             FROM PriceBookEntry WHERE Product2Id in :idProductosLst AND PriceBook2.ID = :oferta.Pricebook2Id];
        
        System.debug('-- JCAR ---------------------------------- - setPriceBook SELECT ' + priceBookList.size() + ' priceBook - ' + priceBookList);
        for (PriceBookEntry pb : priceBookList) { productPriceMAP.put(pb.Product2Id, pb.ID); }        
        
        Set<String> prodKeys = new Set<String>();
        if (oneLinea) { prodKeys.add(rowProducto); }
        else { prodKeys = productosOferta.keySet(); }
        System.debug('-- JCAR ---------------------------------- - setPriceBook ' + prodKeys.size() + ' prodKeys - ' + prodKeys);
        
        Map<String, ID> needPriceBook = new Map<String, ID>();
        for (String pK : prodKeys) {
            OpportunityLineItem oli = productosOferta.get(pK);
            if (oli.PricebookEntryId == null && productosSalesFID.get(pK) != null && productosSalesFID.get(pK).trim() != '') {
                
                if (productPriceMAP.containsKey(productosSalesFID.get(pK))) 
                { oli.PricebookEntryId = productPriceMAP.get(productosSalesFID.get(pK)); }
                else
                { needPriceBook.put(pK, productosSalesFID.get(pK)); }
            }
            if (oli.TotalPrice != null && oli.ID == null) {
                oli.TotalPrice = null;
            }
            productosOferta.put(pK, oli);
        }
        
        if (!needPriceBook.isEmpty()) 
        { repairPriceBook(needPriceBook, oferta.Pricebook2Id, oferta.CurrencyIsoCode); }
    }
    private Map<ID, PricebookEntry> repairPriceBook(Map<String, ID> needPriceBook, ID priceBook, String currencyISO) {
        
        if (Test.isRunningTest()) { priceBook = Test.getStandardPricebookId(); }
        
        Map<ID, PricebookEntry> pbEMap = new Map<ID, PricebookEntry>();
        for (ID prod : needPriceBook.values()) {
            PricebookEntry pbe = new PricebookEntry();
            pbe.Pricebook2Id = priceBook;
            pbe.Product2Id = prod;
            pbe.UnitPrice = 0;
            pbe.IsActive = true;
            pbe.CurrencyIsoCode = currencyISO;
            pbEMap.put(prod,pbe);
        }
        
        insert pbEMap.values();
        for(String pK : needPriceBook.keySet()) {
            ID prod = needPriceBook.get(pK);
            ID pbe = pbEMap.get(prod).ID;
            OpportunityLineItem oli = productosOferta.get(pK);
            oli.PricebookEntryId = pbe;
            productosOferta.put(pK, oli);
        }
        
        return pbEMap;
    }
    
    public void setFicha() { setFicha(null); }
    public void setFicha(String rowProducto) {
        
        Boolean oneLinea = rowProducto != null;
        
        Set<String> prodKeys = new Set<String>();
        if (oneLinea) { prodKeys.add(rowProducto); }
        else { prodKeys = productosOferta.keySet(); }
        
        for (String pK : prodKeys) { 
            productosOferta.get(pK).KS_Ficha__c = fichaSelect; 
            productosOferta.get(pK).KS_Cantidad_Ficha__c = fichaCantidad;
            productosOferta.get(pK).KS_Comentarios__c = fichaComentario;
            productosOferta.get(pK).KS_Ficha_Nombre__c = fichaNombre;
            productosOferta.get(pK).KS_Competidor__c = fichaComp.KS_Competidor__c;
        }
    }
    private void setSelect() { setSelect(true); }
    private void setSelect(Boolean emptyToo) {
        for (String pK : productosOferta.keySet()) { 
            if (productosOferta.get(pK).PricebookEntryId != null) {
                productosSeleccion.put(pK, true);
            } else {
                productosSeleccion.put(pK, false);
            }
        }
    }
    
    public void callAddProductos() {
        try { addProductos(); } 
        catch(Exception ex) { errorGeneric = '## ERROR ## ' + ex.getMessage(); System.debug('callAddProductos ' + errorGeneric); }
    }
    private void addProductos() {

        resetErrores();
        System.debug('-- JCAR ---------------------------------- - addProductos productosADD = ' + productosADD);
        
        if (productosADD==null) {return;}
        if (productosADD<1) {return;}

        totalProductos = productos.size() + productosADD;
        
        sortProductos();
        Integer index = productos.size();
        while (index < totalProductos) {
            //System.debug('-- JCAR ---------------------------------- - addProductos index = ' + index);
            OpportunityLineItem oli = createOppLineEmpty(index);
            index++;
        }
        sortProductos();
    }
    
    private OpportunityLineItem createOppLineEmpty(Integer index) {
        return createOppLine(null, null, index);
    }
    
    public void callDelProductos() {
        try { delProductos(); } 
        catch(Exception ex) { errorGeneric = '## ERROR ## ' + ex.getMessage(); System.debug('callDelProductos ' + errorGeneric); }
    }
    private void delProductos() {

        resetErrores();
        List<OpportunityLineItem> lineasDELETE = new List<OpportunityLineItem>();
        Set<String> prodDELETE = new Set<String>();
        
        orden = new List<Decimal>();
        productos = new Map<Decimal, String>();
        System.debug('-- JCAR ---------------------------------- - delProductos productosSeleccion = ' + productosSeleccion);
        
        for (String pK : productosSeleccion.keySet()) {
            
            OpportunityLineItem oli = productosOferta.get(pK);
            if (productosSeleccion.get(pK)) {

                if (oli.ID != null) { lineasDELETE.add(oli); }
                prodDELETE.add(pK);
            
            } else {
                
                orden.add(oli.KS_Orden__c);
                productos.put(oli.KS_Orden__c,pK);
            }
        }
        
        if (prodDELETE.size()>0) {
            
            for (String pK : prodDELETE) {
                productosOferta.remove(pK);
                productosMaterial.remove(pK);
                productosSalesF.remove(pK);
                productosSalesFID.remove(pK);
                productosSeleccion.remove(pK);
            }
            if (lineasDELETE.size()>0) { delete lineasDELETE; }
        }

        if (!productosOferta.isEmpty()) {
            sortProductos();
            totales.calc(productosOferta.values());
        } else {
            totales.reset();
        }
    }
    
    public void callDupProductos() {
        try { dupProductos(); } 
        catch(Exception ex) { errorGeneric = '## ERROR ## ' + ex.getMessage(); System.debug('callDupProductos ' + errorGeneric); }
    }
    private void dupProductos() { dupProductos(false, true); }
    private void dupProductos(Boolean newFicha, Boolean emptyToo) {

        resetErrores();
        System.debug('-- JCAR ---------------------------------- - dupProductos ' + productosSeleccion.size() + ' productosSeleccion = ' + productosSeleccion);
        
        Map<Integer,String> prodDuplicar = new Map<Integer,String>();
        Integer totalProductosToAdd = productos.size()+1;
        Integer totalProductosToAddEmpty = 0;
        
        for (String pK : productosSeleccion.keySet()) {
            if (productosSeleccion.get(pK)) {
                String mat = productosSalesFID.get(pK);
                if (mat != null && mat.trim() != '') {
                    totalProductosToAdd++;
                    prodDuplicar.put(totalProductosToAdd,pK);                    
                } else if (emptyToo) {
                    totalProductosToAddEmpty++;
                }
            }
            productosSeleccion.put(pK,false);
        }
        
        System.debug('-- JCAR ---------------------------------- - dupProductos ' + prodDuplicar.size() + ' prodDuplicar = ' + prodDuplicar);

        for (Integer index : prodDuplicar.keySet()) {
            String pK = prodDuplicar.get(index);
            
            OpportunityLineItem oli = productosOferta.get(pK).clone(false,false,false,false);
            oli.KS_Orden__c = index;
            oli.KS_Ficha__c = fichaSelect;
            Product2 prod = productosSalesF.get(pK); 
            prod = prod != null ? prod : new Product2();
            
            String key = newFicha ? pK : ( prodKey + (index < 10 ? '00'+index : (index < 100 ? '0'+index : index+'')) );
            orden.add(index);
            productos.put(index,key);
            productosOferta.put(key,oli);
            productosMaterial.put(key, prod != null ? prod.KS_Id_SAP__c : '');
            productosSalesF.put(key,prod);
            productosSalesFID.put(key,prod.ID != null ? prod.ID : '');
            productosSeleccion.put(key,false);
        }
        
        System.debug('-- JCAR ---------------------------------- - dupProductos ' + productos.size() + ' productos = ' + productos);
        System.debug('-- JCAR ---------------------------------- - dupProductos totalProductosToAddEmpty = ' + totalProductosToAddEmpty);

        // Guardamos los cambios
        if (totalProductosToAdd > productos.size()) { saveLineas(); }
        
        if (totalProductosToAddEmpty>0) {
            productosADD = totalProductosToAddEmpty;
            addProductos();
        }
    }
    
    public void callDatosProducto() {
        try { getDatosProducto(); } 
        catch(Exception ex) { 
            String errorcito = ex.getMessage();
            errorcito = errorcito.contains('field integrity exception: PricebookEntryId, unknown') ? 'Product data corrupted (PricebookEntryId)' : errorcito;
            errorGeneric = '## ERROR ## ' + errorcito; System.debug('callDatosProducto ' + errorGeneric);
        }
    }
    private void getDatosProducto() { getDatosProducto(true, true); }
    private void getDatosProducto(Boolean sorting, Boolean autoSave) {
        
        if(sorting) { sortProductos(); }
        
        System.debug('-- JCAR ---------------------------------- - getDatosProducto lookUP = ' + productoLookup);
        System.debug('-- JCAR ---------------------------------- - getDatosProducto idRow = ' + productoIDROW);
        
        OpportunityLineItem oli = new OpportunityLineItem();
        Product2 prod = new Product2();
        
        if(productoLookup==null || productoIDROW == null) {return;}
        
        ID oldID = null;
        Decimal oldOrder = null;
        if (productosOferta.containsKey(productoIDROW)) { 
            oldID = productosOferta.get(productoIDROW).ID;
            oldOrder = productosOferta.get(productoIDROW).KS_Orden__c;
        }
        
        if(productoLookup.trim()!='' && productoIDROW != null){ // Se ha borrado el contenido?
            
            try { prod.ID = productoLookup;} catch (Exception e) {return;}
        }
        Boolean haveProd = prod.ID != null;

        //if (productosSalesF.containsKey(productoLookup)) { prod = productosSalesF.get(productoLookup);}
        if (haveProd && prod.KS_Id_SAP__c == null) {
            List<Product2> prodLstTMP = [SELECT ID, Name, ProductCode, Family, 
                                         KS_Id_SAP__c, KS_Tipo_de_material__c, KS_Nombre_Producto__c, KS_Descripcion_corta__c, isActive
                                         FROM Product2 WHERE ID = :prod.ID LIMIT 1];
            if ( !prodLstTMP.isEmpty() ) { prod = prodLstTMP.get(0); }
        }
        System.debug('-- JCAR ---------------------------------- - getDatosProducto productosSalesF = ' + prod);
        
        oli.OpportunityId = oferta.Id;
        oli.KS_Cantidad__c = 1;
        oli.KS_Cantidad_Ficha__c = fichaCantidad;
        oli.Quantity = fichaCantidad;
        oli.UnitPrice = 0;
        oli.KS_Ficha__c = fichaSelect;
        oli.KS_Orden__c = oldOrder;
        System.debug('-- JCAR ---------------------------------- - getDatosProducto productosOferta = ' + oli);
        
        System.debug('-- JCAR ---------------------------------- - getDatosProducto haveProd? ' + haveProd);
        if (haveProd) {
            Map<Id,Product2> mapIdProductSelect = new Map<Id,Product2>();
            mapIdProductSelect.put(prod.ID, prod);
            Map<String, KS_ProductoOferta_SetCondicionaComercial.Condicion> condicionesPorMaterial = KS_ProductoOferta_SetCondicionaComercial.condicionesPorMaterial(mapIdProductSelect, oferta);
            if (condicionesPorMaterial.containsKey(productoLookup)) {
                KS_ProductoOferta_SetCondicionaComercial.Condicion con = condicionesPorMaterial.get(productoLookup);
                System.debug('-- JCAR ---------------------------------- - getDatosProducto Condicion = ' + con);
                oli = con.toProducto(oli);
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - getDatosProducto productoIDROW? ' + productoIDROW);
        if (oli.UnitPrice == null) { oli.UnitPrice = 0; }
        productosOferta.put(productoIDROW,oli);
        productosSeleccion.put(productoIDROW,false);
        productosMaterial.put(productoIDROW, haveProd ? prod.KS_Id_SAP__c : '');
        productosSalesF.put(productoIDROW, haveProd ? prod : new Product2());
        productosSalesFID.put(productoIDROW, haveProd ? ''+prod.ID : '');
        
        System.debug('-- JCAR ---------------------------------- - getDatosProducto productosOferta > ' + productosOferta.get(productoIDROW));
        System.debug('-- JCAR ---------------------------------- - getDatosProducto productosSeleccion > ' + productosSeleccion.get(productoIDROW));
        System.debug('-- JCAR ---------------------------------- - getDatosProducto productosMaterial > ' + productosMaterial.get(productoIDROW));
        System.debug('-- JCAR ---------------------------------- - getDatosProducto productosSalesF > ' + productosSalesF.get(productoIDROW));
        System.debug('-- JCAR ---------------------------------- - getDatosProducto productosSalesFID > ' + productosSalesFID.get(productoIDROW));
        
        if (oldID != null) { deleteOldLinea(oldID); }
        if (autoSave&&haveProd) { saveLineas(productoIDROW); }
        if (haveProd) { focusLinea = productoIDROW; } else { focusLinea = null; }
        
        if (oli.ID != null) { oli = reloadOpportunityLine(oli); productosOferta.put(productoIDROW,oli); }
        if (oppLineToSave != null) {oppLineToSave=null;}
        if (oppLineToDel != null && oldID != null) {oppLineToDel=null;}
        else if (oldID == null) {deleteOldLinea(oppLineToDel);oppLineToDel=null;}
        totales.calc(productosOferta.values());
    }
    public void deleteOldLinea(ID oldID) {
        System.debug('-- JCAR ---------------------------------- - deleteOldLinea ' + oldID);
        if (oldID != null) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.ID = oldID;
            System.debug('-- JCAR ---------------------------------- - deleteOldLinea ' + oli);
            delete oli;
        }
    }
    private OpportunityLineItem reloadOpportunityLine(OpportunityLineItem oli) {
        
        if (oli == null) { return oli; } if (oli.ID == null) { return oli; }
        List<OpportunityLineItem> oliLst = new List<OpportunityLineItem>(); oliLst.add(oli);
        oliLst = reloadOpportunityLine(oliLst);
        return oliLst.get(0);
    }
    private List<OpportunityLineItem> reloadOpportunityLine(List<OpportunityLineItem> oliLst) {
        
        if (oliLst == null) { return oliLst; } 
        if (oliLst.isEmpty()) { return oliLst; }
        List<ID> oliID = new List<ID>();
        for (OpportunityLineItem oli : oliLst) { if (oli.ID != null) { oliID.add(oli.ID); } }
        
        oliLst = [SELECT Id, OpportunityId, KS_Obra__c, KS_Producto__c, Product2Id, ProductCode, Name, Quantity, KS_Cantidad__c, TotalPrice, UnitPrice, ListPrice, ServiceDate, Description, 
                  KS_Nombre__c, KS_Dto_base_1__c, KS_Dto_base_2__c, KS_Dto_Campaign__c, KS_Dto_adicional_1__c, KS_Dto_adicional_2__c, KS_precio_neto__c, KS_Descuento_neto__c, 
                  KS_Dto_volumen__c, KS_Material_sin_cargo__c, KS_Ficha__c, KS_Prescrito__c, KS_Dto_Instalador__c, KS_Dto_cliente_final__c, 
                  KS_Destinatario__c, CurrencyIsoCode, KS_Cantidad_Ficha__c, KS_Cantidad_Total__c, PricebookEntryId, KS_Material__c,
                  KS_Comentarios__c, KS_Competencia__c, KS_Competidor__c, KS_Necesita_aprobacion__c, KS_Aprobacion__c, KS_Neto_Base__c, KS_Dto_Logistico__c,
                  KS_Dto_SinCargo__c, KS_Dest_ClieFinal__c, KS_Dest_Distribuidor__c, KS_Dest_Instalador__c, KS_Referencia__c, KS_Orden__c,
                  KS_Neto_por_fila__c, KS_Neto_Unitario__c, KS_Neto_Unitario_Cliente_Final__c, Ks_Neto_Unitario_Instalador__c, KS_Ficha_Nombre__c,
                  KS_SuperFamilia__c, KS_Familia__c, KS_Serie__c, KS_SubSerie__c, KS_Desc_Manual__c
                  FROM OpportunityLineItem 
                  WHERE ID in :oliID];
        return oliLst;
    }
    
    public void sortProductos() {
        
        System.debug('-- JCAR ---------------------------------- - sortProductos OLD ' + productos);
        System.debug('-- JCAR ---------------------------------- - sortProductos ' + productosMaterial);
        
        // REORDENACIÓN
        // RESETEA LOS VALORES DE KS_ORDEN DE LAS LÍNEAS
        // SEGÚN EL ORDEN QUE HAYA EN LA VISUALFORCE

        List<Decimal> ordenTMP = new List<Decimal>();       
        Map<Decimal, String> productosTMP = new Map<Decimal, String>();
        Map<String, OpportunityLineItem> oldLines = new Map<String, OpportunityLineItem>();        
        Map<String, Product2> oldProds = new Map<String, Product2>();
        
        for (String pK : productosOferta.keySet()) {
            
            OpportunityLineItem oli = productosOferta.get(pK);
            ordenTMP.add(oli.KS_Orden__c);
            productosTMP.put(oli.KS_Orden__c, pK);
            oldLines.put(pK, oli);
            oldProds.put(pK, productosSalesF.get(pK));
        }
        
        System.debug('-- JCAR ---------------------------------- - sortProductos ordenTMP ' + ordenTMP);
        System.debug('-- JCAR ---------------------------------- - sortProductos productosTMP ' + productosTMP);
        System.debug('-- JCAR ---------------------------------- - sortProductos oldLines ' + oldLines);
        System.debug('-- JCAR ---------------------------------- - sortProductos oldProds ' + oldProds);

        orden = new List<Decimal>();
        productos = new Map<Decimal,String>();
        productosOferta = new Map<String, OpportunityLineItem>();
        productosMaterial = new Map<String, String>();
        productosSalesF = new Map<String, Product2>();
        productosSalesFID = new Map<String, String>();
        productosSeleccion = new Map<String, Boolean>();
        
        ordenTMP.sort(); Decimal newOrd = 0;
        for (Decimal ord : ordenTMP) {

            String oldK = productosTMP.get(ord);
            String key = prodKey + (newOrd < 10 ? '00'+newOrd : (newOrd < 100 ? '0'+newOrd : newOrd+''));
            orden.add(newOrd);
            productos.put(newOrd, key);
            
            OpportunityLineItem oli = oldLines.get(oldK);
            oli = oli != null ? oli : new OpportunityLineItem();
            oli.KS_Orden__c = newOrd;
            Product2 prod = oldProds.get(oldK);
            prod = prod != null ? prod : new Product2();
            
            productosOferta.put(key,oli);
            productosMaterial.put(key, prod.KS_Id_SAP__c != null ? prod.KS_Id_SAP__c : '');
            productosSalesF.put(key,prod);
            productosSalesFID.put(key, prod.ID != null ? ''+prod.ID : '');
            productosSeleccion.put(key,false);
            
            newOrd++;
        }

        System.debug('-- JCAR ---------------------------------- - sortProductos productosOferta ' + productosOferta);
        System.debug('-- JCAR ---------------------------------- - sortProductos productosMaterial ' + productosMaterial);
        System.debug('-- JCAR ---------------------------------- - sortProductos productosSalesF ' + productosSalesF);
        System.debug('-- JCAR ---------------------------------- - sortProductos productosSalesFID ' + productosSalesFID);
        
        System.debug('-- JCAR ---------------------------------- - sortProductos NEW ' + productos);
    }
    
    public void callAddFicha() {
        try { addFicha(); } 
        catch(Exception ex) { errorGeneric = '## ERROR ## ' + ex.getMessage(); System.debug('callAddFicha ' + errorGeneric); }
    }
    private void addFicha() {
        
        saveLineas(); // Guardamos ficha actual
        
        System.debug('-- JCAR ---------------------------------- - addFicha fichaSelect = ' + fichaSelect);
        
        resetErrores();
        moreFicha(); // Creamos nueva ficha
        totales.reset();
        initData();
        
        productosADD = 5; // Añadimos 5 "productos" vacíos a la nueva ficha
        addProductos();
        
        System.debug('-- JCAR ---------------------------------- - addFicha fichaSelect = ' + fichaSelect);
    }
    
    public void callDupFicha() {
        try { dupFicha(); } 
        catch(Exception ex) { errorGeneric = '## ERROR ## ' + ex.getMessage(); System.debug('callDupFicha ' + errorGeneric); }
    }
    private void dupFicha() {
        
        saveLineas();
        resetErrores();
        
        System.debug('-- JCAR ---------------------------------- - dupFicha fichaSelect = ' + fichaSelect);
        setSelect(false); // emptyToo = false
        moreFicha();
        
		//dupProductos(true, false); // newFicha = true, emptyToo = false
        
        for (OpportunityLineItem oli : productosOferta.values()) { oli.ID = null; }
        setFicha();
        saveLineas();
        
        totales.reset();
        initData();
        initOferta();
    }
    
    public void changeFichaName(Decimal num, String name) {
        fichasOferta.put(num, name);
        fichaList.get(num).setLabel(name);
    }
    public Map<Decimal, SelectOption> calcFichaList() {
        
        fichasOferta = fichasOferta != null ? fichasOferta : new Map<Decimal,String>();
        Map<Decimal, SelectOption> options = new Map<Decimal, SelectOption>();
        List<OpportunityLineItem> arFichas =
            [SELECT KS_Ficha__c, KS_Ficha_Nombre__c FROM OpportunityLineItem
             WHERE OpportunityID = :oferta.ID];
        for (OpportunityLineItem org : arFichas) {
            
            String nameFicha = org.KS_Ficha_Nombre__c;
            nameFicha = nameFicha != null ? nameFicha : stringNewFicha;
            
            options.put(org.KS_Ficha__c, 
                        new SelectOption(''+org.KS_Ficha__c, nameFicha)
                       );
            
            fichasOferta.put(org.KS_Ficha__c, nameFicha);
        }
        
        if (arFichas.isEmpty()) { 
            fichasOferta.put(fichaSelect, stringNewFicha);
            options.put(fichaSelect, new SelectOption(
                ''+fichaSelect, stringNewFicha));
        }
        
        System.debug('-- JCAR ---------------------------------- - calcFichaList options = ' + options.values());
        return options;
    }
    public void moreFicha() {
        
        fichaMaxima++;
        fichaSelect = fichaMaxima;
        fichaList = fichaList != null ? fichaList : calcFichaList();
        
        fichaNombre = stringNewFicha;
        fichaList.put(fichaSelect, new SelectOption(''+fichaSelect, fichaNombre));
        
        fichasOferta = fichasOferta != null ? fichasOferta : new Map<Decimal,String>();
        fichasOferta.put(fichaSelect, fichaNombre);
        
        fichaComentario = ''; fichaCantidad = 1; fichaComp = new OpportunityLineItem();
        System.debug('-- JCAR ---------------------------------- - moreFicha fichasOferta = ' + fichasOferta);
    }
    
    public void callDelFicha() {
        try { delFicha(); } 
        catch(Exception ex) { errorGeneric = '## ERROR ## ' + ex.getMessage(); System.debug('callDelFicha ' + errorGeneric); }
    }
    public void delFicha() {
        
        resetErrores();
        System.debug('-- JCAR ---------------------------------- - delFicha fichaSelect = ' + fichaSelect);
        setSelect();
        delProductos();
        
        // Lógica de cambio de ficha, borramos la ficha actual de las listas
        fichaList.remove(fichaSelect);
        fichaNombre = '';
        fichaCantidad = 1;
        fichaComentario = '';
        fichaComp = new OpportunityLineItem();
        fichaSelect = fichaSelect - 1;
        
        initData();
        initOferta();
        System.debug('-- JCAR ---------------------------------- - delFicha fichaSelect = ' + fichaSelect);
    }
    
    public void callChangeFicha() {
        try { changeFicha(); } 
        catch(Exception ex) { errorGeneric = '## ERROR ## ' + ex.getMessage(); System.debug('callChangeFicha ' + errorGeneric); }
    }
    private void changeFicha() {
        
        resetErrores();
        
        // guardado de ficha actual y sus líneas
        savePreviousFicha();
        System.debug('-- JCAR ---------------------------------- - changeFicha to ' + fichaSelect);
        fichaComentario = ''; fichaCantidad = 1; fichaComp = new OpportunityLineItem();
        
        if (!getHaveError()) {
            
            totales.reset();
            initData();
            loadOpportunityLineItems();
            if (productosOferta.isEmpty()) { productosADD = 5; addProductos(); } // Si al cargar la ficha esta está vacía, rellenamos
            
            fichasOferta = fichasOferta != null ? fichasOferta : new Map<Decimal,String>();
        }
        fichaNombre = fichasOferta.get(fichaSelect);
        System.debug('-- JCAR ---------------------------------- - changeFicha fichaNombre ' + fichaNombre);
    }
    private void savePreviousFicha() {
        Decimal fichaActual = 0;
        for (OpportunityLineItem oli : productosOferta.values()) {
            if (oli.KS_Ficha__c != null && oli.KS_Ficha__c > 0) {
                fichaActual = oli.KS_Ficha__c; break;
            }
        }
        Decimal fichaNueva = fichaSelect; fichaSelect = fichaActual;
        System.debug('-- JCAR ---------------------------------- - savePreviousFicha ficha: ' + fichaActual + ' to ' + fichaNueva);
        try { 
            saveLineas();
            if (!getHaveError()) { fichaSelect = fichaNueva; }
        } 
        catch (Exception ex) { errorGeneric = '## ERROR ## ' + ex.getMessage(); System.debug('savePreviousFicha ' + errorGeneric); }
        
    }
    
    public Class Referencia {
        String material {get;set;}
        String cantidad {get;set;}
        String dtoextra {get;set;}
        public Integer order {get;set;}
        public Referencia(String m, String c, String d) {
            material = m.toUpperCase();
            cantidad = c;
            dtoextra = d;
        }
        public OpportunityLineItem toLine(KS_Oferta_AddProductos_Controller controller, OpportunityLineItem oli) {
            //System.debug('-- JCAR ---------------------------------- - Referencia toLine ' + this);
            oli.KS_Cantidad__c = cantidad.isNumeric() ? Decimal.valueOf(cantidad) : 0;
            try { oli.KS_Dto_adicional_2__c = Decimal.valueOf(dtoextra); } catch (Exception e)
            { oli.KS_Dto_adicional_2__c = 0; }
            
            oli.OpportunityId = controller.oferta.ID;
            oli.KS_Cantidad_Ficha__c = controller.fichaCantidad;
            oli.Quantity = oli.KS_Cantidad__c * oli.KS_Cantidad_Ficha__c;
            oli.KS_Ficha__c = controller.fichaSelect;
            oli.UnitPrice = oli.UnitPrice != null ? oli.UnitPrice : 0;
            //System.debug('-- JCAR ---------------------------------- - Referencia toLine ' + oli);
            return oli;
        }
    }
    
    public void callAddReferencias() {
        try { addReferencias(); } 
        catch(Exception ex) { errorGeneric = '## ERROR ## ' + ex.getMessage(); System.debug(ex.getStackTraceString() + ' callAddReferencias ' + errorGeneric); }
    }
    private void addReferencias() {
        
        resetErrores();
        
        System.debug('-- JCAR ---------------------------------- - addReferencias referencias = ' + referencias);
        
        if (referencias == null) { return; }
        if (referencias != null && referencias.trim() == '') { return; }
        if (!getHaveReferencias()) { validacionReferencias = 'Formato inválido ' + referencias; return;}
        referencias = referencias.trim();
        List<String> refLst = referencias.split('\\|');

        System.debug('-- JCAR ---------------------------------- - addReferencias ' + refLst.size() + ' refLst = ' + refLst);
        
        Map<String, List<Referencia>> refMap = new Map<String, List<Referencia>>();
        List<String> materiales = new List<String>();
        Integer productos2ADD = 0;
        
        // MAPEO INICIAL
        // Contiene creación de lineas de oportunidad básicas
        Integer refOrder = 0;
        for (String ref : refLst) {
            List<String> refFields = ref.split(',');
            if (refFields.size()>=2) { // Total de campos válido según formato, en caso de que haya más de tres se ignorará el resto
                String refK = refFields.get(0); refK = refK.toUpperCase();
                if (refFields.size() == 2) { refFields.add('0'); }
                
                if (!refFields.get(1).isNumeric()) {
                    validacionReferencias = 'Cantidad inválida ' + refFields.get(0) + ':  ' + refFields.get(1); return;
                } else if (Integer.valueOf(refFields.get(1)) == 0) {
                    validacionReferencias = 'Cantidad inválida ' + refFields.get(0) + ':  ' + refFields.get(1); return;
                }
                
                try { Decimal.valueOf(refFields.get(2)); } catch (Exception e) 
                { validacionReferencias = 'Dto.Extra inválido ' + refFields.get(0) + ':  ' + refFields.get(2); return; }
                
                Referencia refObj = new Referencia(refFields.get(0),refFields.get(1),refFields.get(2));
                refObj.order = refOrder;
                
                List<Referencia> refsProd = new List<Referencia>();
                if (refMap.containsKey(refK)) {refsProd = refMap.get(refK);}
                refsProd.add(refObj); refMap.put(refK, refsProd);
                
                materiales.add(refFields.get(0).toUpperCase());
                productos2ADD++;
                refOrder++;
                
            } else {
                
                validacionReferencias = 'Formato inválido ' + ref; return;
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - addReferencias ' + refMap.size() + ' referencias = ' + refMap);
        
        // Carga de los productos que debemos sacar
        Map<Id,Product2> mapIdProductSelect = new Map<Id,Product2>(); Set<String> foundProductos = new Set<String>();
        List<Product2> prodLstTMP = [SELECT ID, Name, ProductCode, Family, 
                                     KS_Id_SAP__c, KS_Tipo_de_material__c, KS_Nombre_Producto__c, KS_Descripcion_corta__c, isActive
                                     FROM Product2 WHERE KS_Id_SAP__c = :materiales];
        for (Product2 prod : prodLstTMP) { mapIdProductSelect.put(prod.ID, prod); foundProductos.add(prod.KS_Id_SAP__c); }
        
        System.debug('-- JCAR ---------------------------------- - addReferencias ' + foundProductos.size() + ' foundProductos = ' + foundProductos);
        // Validación productos buscados por referencia
        for (String mat : materiales) {
            if (!foundProductos.contains(mat)) { 
                if (!getErrorReferencias()) {
                    validacionReferencias = 'Referencia no encontrada: ' + mat;
                } else {
                    validacionReferencias += '; ' + mat;
                }
            }
        }
        if (getErrorReferencias()) {
            System.debug('-- JCAR ---------------------------------- - addReferencias ERROR! ' + validacionReferencias);
            return;
        }

        System.debug('-- JCAR ---------------------------------- - addReferencias ' + mapIdProductSelect.size() + ' productos = ' + mapIdProductSelect);

        Map<String, KS_ProductoOferta_SetCondicionaComercial.Condicion> condicionesPorMaterial = KS_ProductoOferta_SetCondicionaComercial.condicionesPorMaterial(mapIdProductSelect, oferta);
        System.debug('-- JCAR ---------------------------------- - addReferencias ' + condicionesPorMaterial.size() + ' condicionesPorMaterial = ' + condicionesPorMaterial);

        if (!canSave()) { initData(); }
        
        List<OpportunityLineItem> saveRefs = new List<OpportunityLineItem>();
        Integer index = productos.size();
        for (String prodID : condicionesPorMaterial.keySet()) {
            KS_ProductoOferta_SetCondicionaComercial.Condicion con = condicionesPorMaterial.get(prodID);
            Product2 prod = mapIdProductSelect.get(prodID);

            //System.debug('-- JCAR ---------------------------------- - addReferencias prod = ' + prod.KS_Id_SAP__c);
            //System.debug('-- JCAR ---------------------------------- - addReferencias prod.referencias = ' + refMap.get(prod.KS_Id_SAP__c));
            for (Referencia ref : refMap.get(prod.KS_Id_SAP__c)) {

                OpportunityLineItem oli = new OpportunityLineItem();
                oli = con.toProducto(oli);
                //System.debug('-- JCAR ---------------------------------- - addReferencias toProducto OpportunityLineItem ' + oli);
                oli = ref.toLine(this,oli);
                //System.debug('-- JCAR ---------------------------------- - addReferencias toLine OpportunityLineItem ' + oli);
                oli.KS_Orden__c = index + ref.order;
                String key = prodKey + (oli.KS_Orden__c < 10 ? '00'+oli.KS_Orden__c : (oli.KS_Orden__c < 100 ? '0'+oli.KS_Orden__c : oli.KS_Orden__c+''));
                orden.add(oli.KS_Orden__c);
                productos.put(oli.KS_Orden__c,key);
                productosOferta.put(key,oli);
                productosMaterial.put(key,prod.KS_Id_SAP__c);
                productosSalesF.put(key,prod);
                productosSalesFID.put(key,prod.ID);
                productosSeleccion.put(key,false);
                
                saveRefs.add(oli);
                System.debug('-- JCAR ---------------------------------- - addReferencias new OpportunityLineItem ' + oli);
            }
        }
        
        setPriceBook();
        setFicha();
        insert saveRefs;
        initData();
        loadOpportunityLineItems();
        
        totalProductos = productos.size();
        referencias = null;
        totales.calc(productosOferta.values());
    }
    
    public PageReference callSelProducto() {
        try { return selProducto(); }
        catch(Exception ex) { errorGeneric = '## ERROR ## ' + ex.getMessage(); System.debug('callSelProducto ' + errorGeneric); }
        return null;
    }
    private PageReference selProducto() {
        
        PageReference pg = null;
        if(productoIDROW != null && productoIDROW.trim() != '' && productoIDROW.isNumeric()) {

            sortProductos(); // Aseguramos que el orden en la tabla sea el orden a la vuelta
            String order = getOrderRow(Integer.valueOf(productoIDROW));
            System.debug('-- JCAR ---------------------------------- - selProducto order = ' + order);
            System.debug('-- JCAR ---------------------------------- - selProducto ficha = ' + fichaSelect);
            
            String codProducto = productosMaterial.get(productos.get(Decimal.valueOf(productoIDROW)));
            System.debug('-- JCAR ---------------------------------- - selProducto codProducto = ' + codProducto);
            
            // Le enviamos :
            // - La id de la oferta (condiciones sobre las que se buscan los productos)
            // - Código del producto de la línea seleccionada, para hacer la búsqueda más directa (de productos de código similar)
            // - Línea actual donde se ejerce la busqueda, con la estructura de la ficha (para al volver, saber cual era)
            // - La ficha actual (para al volver, saber cual era)
            pg = new PageReference('/apex/KS_Oferta_SearchProductos?'
                                   + 'id=' + oferta.ID 
                                   + '&codProducto=' + (codProducto != null ? codProducto : '')
                                   + '&rowProducto=' + order
                                   + '&ficha=' + fichaSelect);
            pg.setRedirect(true);
            
            // "Autoguardado" de seguridad
            saveLineas();
        }
        return pg;
    }
    
    private String getOrderRow(Integer selected) {
        
        String order = '';
        Integer row = selected;
        Integer index = 0;
        while (index < productosOferta.size()) {
            
            String prod = productosMaterial.get( productos.get(index) );
            if (index == row) { 
                if (prod != null && prod != '') { order+= 'Y'; }
                else { order+= 'X'; }
            }
            else if (prod != null && prod != '') { order+= '1'; }
            else { order+= '0'; }
            index++;
        }
        return order;
    }
    
    public void setLineasFromSearch(){
        
        System.debug('-- JCAR ---------------------------------- - setLineasFromSearch');
        
        String selectedRow = null;
        OpportunityLineItem setLinea = null;
        Boolean save = false;
        ID oldID = null;
        
        // CONTROL DE LÍNEAS
        productosADD = totalProductos - productos.size();
        Boolean setProd = productoLookup != null && productoLookup != '';
        Boolean addLineas = false; addLineas = productosADD > 0 || (productosADD == 0 && setProd);
        if (productosADD < 0) 
        {return;} // Por si acaso, no debería pasar NUNCA
        else if (productosADD > 0) 
        { totalProductos = productos.size(); }
        else { /* No hacemos nada, no hay que añadir líneas nuevas */ }
        
        // Debemos crear la estructura de datos originales de antes de enviarlo al buscador
        // En caso de que addLineas sea true, significa que había más rows de las que hay guardadas
        if (addLineas) {
            
            // Recogemos los productos cargados de la BD (ya existentes)
            Map<Integer, OpportunityLineItem> oldOpp = new Map<Integer, OpportunityLineItem>();
            Map<Integer, Product2> oldPrd = new Map<Integer, Product2>();
            for (Decimal ord : productos.keySet()) {
                oldOpp.put(ord.intValue(), productosOferta.get(productos.get(ord)));
                oldPrd.put(ord.intValue(), productosSalesF.get(productos.get(ord)));
            }
            
            System.debug('-- JCAR ---------------------------------- - setLineasFromSearch productoLookup = ' + productoLookup);
            System.debug('-- JCAR ---------------------------------- - setLineasFromSearch productoIDROW = ' + productoIDROW);
            System.debug('-- JCAR ---------------------------------- - setLineasFromSearch oldOpp = ' + oldOpp);
            System.debug('-- JCAR ---------------------------------- - setLineasFromSearch oldPrd = ' + oldPrd);
            
            totalProductos = productos.size() + productosADD;
            initData();
            
            Integer index = 0; Integer order = 0;
            String ordenRows = productoIDROW;
            while (index < ordenRows.length()) { // ordenRows = '0101011X101001' for ex.
                
                String charAt = ordenRows.substring(index, index+1);
                System.debug('-- JCAR ---------------------------------- - setLineasFromSearch charAt = ' + charAt);
                
                // X/0 == estaba vacía, Y/1 == estaba informada
                
                if (charAt == '0' || (charAt == 'X' && productoLookup == null) ) 
                { createOppLineEmpty(index); }
                
                else if (charAt == '1' || (charAt == 'Y' && productoLookup == null) ) { 
                    
                    OpportunityLineItem oli = oldOpp.get(order); Product2 prod = oldPrd.get(order);
                    oli.KS_Orden__c = index;
                    createOppLine(oli, prod, index);
                    order++;
                }
                
                else if ( (charAt == 'X' || charAt == 'Y') && productoLookup != null) {
                    productoIDROW = prodKey + (index < 10 ? '00'+index : (index < 100 ? '0'+index : index+''));
                    if (charAt == 'Y') { oldID = oldOpp.get(order).ID; }
                    setLinea = createOppLineEmpty(index);
                    getDatosProducto(false, false);
                    if (charAt == 'Y') { order++;productosOferta.get(productos.get(index)).KS_Orden__c = index; }
                    selectedRow = productos.get(index);
                    save = true;
                    
                    productosOferta.put(selectedRow, setLinea);
                }
                
                index++;
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - setLineasFromSearch selectedRow? ' + selectedRow);
        System.debug('-- JCAR ---------------------------------- - setLineasFromSearch setLinea? ' + setLinea);
        System.debug('-- JCAR ---------------------------------- - setLineasFromSearch save? ' + save);
        // Autoguardado de línea nueva
        if (save) { 
            oppLineToSave = selectedRow;
            if (oldID!=null) { oppLineToDel = oldID; }
        }
        
        // Reset de variables
        //productoLookup = null;
        productoIDROW = null;
        productosADD = 10;
        
        System.debug('-- JCAR ---------------------------------- - setLineasFromSearch oppLineToSave = ' + oppLineToSave);
        System.debug('-- JCAR ---------------------------------- - setLineasFromSearch productosOferta = ' + productosOferta.get(oppLineToSave));
        System.debug('-- JCAR ---------------------------------- - setLineasFromSearch oppLineToDel = ' + oppLineToDel);
    }
    
    // DESCUENTOS LOGISTICOS
    public PageReference callCalcLogistico() {
        if (!canSave()) {return null;}
        try { return calcLogistico(); } 
        catch(Exception ex) { errorGeneric = '## ERROR ## ' + ex.getMessage(); System.debug('callCalcLogistico ' + errorGeneric); }
        return null;
    }
    private PageReference calcLogistico() {
        
        saveLineas();
        
        // MÉTODO TO LOCO QUE SACA VARIEDAD/VOLUMEN/DTO.LOGISTICO DE TODOS LOS PRODUCTOS DE LA OFERTA
        // SE ACTIVA POR BOTÓN Y CALCULA TODA LA OFERTA
        // AL FINAL, SE GUARDARÁ Y RECARGARÁ LA VF
        
        String error = KS_Oferta_Utils.calcDtoLogistic(oferta);
        if (error != null) {
            errorGeneric = error;
        } else {
            PageReference pg = new PageReference('/apex/KS_Oferta_AddProductos?'
                                                 + 'id=' + oferta.ID
                                                 + '&ficha=' + fichaSelect
                                                );
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }

    public PageReference callCalcAprobaciones() {
        if (!canSave()) {return null;}
        try { return calcAprobaciones(); } 
        catch(Exception ex) { errorGeneric = '## ERROR ## ' + ex.getMessage(); System.debug('callCalcAprobaciones ' + errorGeneric); }
        return null;
    }
    private PageReference calcAprobaciones() {
        
        saveLineas();
        
        String error = KS_Oferta_Utils.calcApproval(oferta);
        if (error != null) {
            errorGeneric = error;
        } else {
            PageReference pg = new PageReference('/apex/KS_Oferta_AddProductos?'
                                                 + 'id=' + oferta.ID
                                                 + '&ficha=' + fichaSelect
                                                );
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }
    
    public Boolean getSaved() { return !getNotSaved(); }
    public Boolean getNotSaved() {
        
        if (getHaveError()) {return true;}
        if (productosOferta.isEmpty()) {return true;}
        for (String pK : productosOferta.keySet()) {
            if (productosOferta.get(pK) == null) {return true;}
            if (productosOferta.get(pK).ID == null) {return true;}
        }
        return false;
    }
    
    public Boolean canSave() {
        if (productosOferta == null) { return false; }
        if (productosOferta != null && productosOferta.isEmpty()) { return false; }
        for (OpportunityLineItem oli : productosOferta.values()) {
            if (oli.PricebookEntryId != null) {return true;}
        }
        return false;
    }
    
    public void callCalcTotales() {
        try { calcTotales(); } 
        catch(Exception ex) { errorGeneric = '## ERROR ## ' + ex.getMessage(); System.debug('callCalcTotales ' + errorGeneric); }
    }
    private void calcTotales() {
        totales.calc(productosOferta.values());
    }
    
    public void marcarSinCargo() {
        if (productosOferta.isEmpty()) {return;}
        for (OpportunityLineItem oli : productosOferta.values()) {
            oli.KS_Material_sin_cargo__c = sinCargoGlobal;
            if (!sincargoGlobal) { oli.KS_Destinatario__c = null; }
        }
        if (!sinCargoGlobal) {saveLineas();}
    }
    
    public Decimal getTotalPrice(OpportunityLineItem oppLi) {
        oppLi.KS_Cantidad_Ficha__c = fichaCantidad;
        oppLi.Quantity = oppLi.KS_Cantidad__c * oppLi.KS_Cantidad_Ficha__c;
        return oppLi.UnitPrice * oppLi.Quantity;
    }
}