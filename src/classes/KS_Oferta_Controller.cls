global without sharing class KS_Oferta_Controller {

    public Boolean cargaInicial {get;set;}
    
    public Boolean redirectToAdd {get;set;}
    public String editMode {get;set;}
    public Boolean getEditOferta() { return editMode!=null; }
    
    public Opportunity oferta {get;set;} // Objeto principal
    public Map<Decimal,List<OpportunityLineItem>> productosOferta {get;set;} // Mapeo de: String "Ficha", Lista "Productos Oferta"
    @TestVisible private List<OpportunityLineItem> productosLst {get;set;} // Todos los productosOferta
    public Boolean getHasProductos() { return productosLst != null && !productosLst.isEmpty(); }
    public Set<Decimal> getFichas() { return (productosOferta != null && !productosOferta.isEmpty()) ? productosOferta.keySet() : new Set<Decimal>(); }
    
    public Map<ID,Descuentos> descuentosOferta {get;set;}
    
    public List<String> seriesOferta {get;set;}
    public Map<String,Set<ID>> serieProductos {get;set;}
    public Map<String,Decimal> serieImporteTotal {get;set;}
    public List<String> familiasOferta {get;set;}
    public Map<String,Set<ID>> familiaProductos {get;set;}
    public Map<String,Decimal> familiaImporteTotal {get;set;}
    
    @TestVisible private Map<String,String> claveProducto {get;set;}
    @TestVisible private Map<String,KS_Organizacion_Producto__c> mapOrgProducto {get;set;}
    @TestVisible private Map<String,Set<ID>> mapProductos {get;set;}
    @TestVisible private Map<String,Decimal> mapProductosDto {get;set;}
    @TestVisible private Map<String,Decimal> mapProductosQnt {get;set;}
    
    public Map<String,KS_Condicion_Comercial__c> serieVariedad {get;set;}
    public Map<String,KS_Condicion_Comercial__c> serieVolumen {get;set;}
    public Map<String,KS_Condicion_Comercial__c> familiaVariedad {get;set;}
    public Map<String,KS_Condicion_Comercial__c> familiaVolumen {get;set;}
    
    public String ofertaPendiente {get;set;}
    public List<KS_Oferta_pendiente__c> ofertasPendientes {get;set;}
    public Boolean getHaveOfertasPendientes() { return !ofertasPendientes.isEmpty(); }
    public List<SelectOption> getPendientes() {
        
        List<SelectOption> options = new List<SelectOption>();
        
        for( KS_Oferta_pendiente__c oP : ofertasPendientes)
        {
            if (oP.KS_Cuenta__c == null || oP.KS_Cliente_Name__c == null) {continue;}
            options.add(new SelectOption(oP.KS_Cuenta__c, oP.KS_Cliente_Name__c));
        }
        return options;
    }
    
    public Map<Decimal,String> totalImporte {get;set;}
    public Map<Decimal,String> totalCantidad {get;set;}
    public Map<Decimal,Integer> totalCantidadFicha {get;set;}
    
    public Map<Decimal,String> fichaNombres {get;set;}
    public Map<Decimal,String> fichaComentarios {get;set;}
    public Map<Decimal,OpportunityLineItem> fichaCompetencia {get;set;}
    
    public List<SelectOption> getCompetencias()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =
            OpportunityLineItem.KS_Competencia__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
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
    
    public String errorTextOferta {get;set;}
    public Boolean getHaveErrorOferta() {
        return errorTextOferta !=null&&errorTextOferta !='';
    }    
    public String errorTextFicha {get;set;}
    public Boolean getHaveErrorFicha() {
        return errorTextFicha !=null&&errorTextFicha !='';
    }

    @TestVisible private void setNombresFicha(Decimal ficha) {
        if ( !productosOferta.containsKey(ficha) ) { return; }
        fichaNombres = fichaNombres != null ? fichaNombres : new Map<Decimal,String>();
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        String nom = prdctsLst.get(0).KS_Ficha_Nombre__c;
        nom = nom != null ? nom : OpportunityLineItem.fields.KS_Ficha__c.getDescribe().getLabel() + ' ' + ficha;
        fichaNombres.put(ficha, nom);
    }  
    @TestVisible private void setComentariosFicha(Decimal ficha) {
        if ( !productosOferta.containsKey(ficha) ) { return; }
        fichaComentarios = fichaComentarios != null ? fichaComentarios : new Map<Decimal,String>();
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        String cmt = prdctsLst.get(0).KS_Comentarios__c;
        fichaComentarios.put(ficha, cmt != null ? cmt : '');
    }     
    @TestVisible private void setCompetenciaFicha(Decimal ficha) {    
        if ( !productosOferta.containsKey(ficha) ) { return; }
        fichaCompetencia = fichaCompetencia != null ? fichaCompetencia : new Map<Decimal,OpportunityLineItem>();
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        OpportunityLineItem ol = new OpportunityLineItem();
        ol.KS_Competidor__c = prdctsLst.get(0).KS_Competidor__c;
        fichaCompetencia.put(ficha, ol);
    }

    @TestVisible private void setTotalCantidadFicha(Decimal ficha) {
        if ( !productosOferta.containsKey(ficha) ) { return; }
        totalCantidadFicha = totalCantidadFicha != null ? totalCantidadFicha : new Map<Decimal,Integer>();
        Decimal total = 0;
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        // Calculamos el total de productos de la ficha introducida
        total = prdctsLst.get(0).KS_Cantidad_Ficha__c; total = total > 0 ? total : 1;
        totalCantidadFicha.put(ficha, Integer.valueOf(total));
    }
    @TestVisible private void setTotalImporte(Decimal ficha, String divisa) {
        if ( !productosOferta.containsKey(ficha) ) { return; }
        totalImporte = totalImporte != null ? totalImporte : new Map<Decimal,String>();
        Decimal total = 0;
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        // Calculamos el importe total de la ficha introducida
        for (OpportunityLineItem prOfer : prdctsLst) { 
            if (prOfer.UnitPrice != null && prOfer.KS_Cantidad__c != null) {
                total += (prOfer.UnitPrice*prOfer.KS_Cantidad__c);    
            } else {
                System.debug('-- JCAR ---------------------------------- - setTotalImporte NULL!!!! ' +  prOfer);
            }
        }
        total.setscale(2);
        String stotal = format2Decimal(total);
        totalImporte.put(ficha, divisa + ' ' + stotal);
    }
    @TestVisible private void setTotalCantidad(Decimal ficha) {
        if ( !productosOferta.containsKey(ficha) ) { return; }
        totalCantidad = totalCantidad != null ? totalCantidad : new Map<Decimal,String>();
        Decimal total = 0;
        List<OpportunityLineItem> prdctsLst = productosOferta.get(ficha);
        // Calculamos el total de productos de la ficha introducida
        for (OpportunityLineItem prOfer : prdctsLst) { 
            if (prOfer.KS_Cantidad__c != null) {
                total += prOfer.KS_Cantidad__c;
            } else {
                System.debug('-- JCAR ---------------------------------- - setTotalCantidad NULL!!!! ' +  prOfer);
            }
        }
        String stotal = format2Decimal(total);
        totalCantidad.put(ficha, stotal);
    }
    
    global static String format2Decimal(Decimal total) {
        String format = total.format();
        List<String> formatL = format.split(',');
        if (formatL.size()<2) {
            return format+',00';
        } else if (formatL.get(1).length()<2) {
            return format+'0';
        }
        return format;
    }
    
    @TestVisible private String profileID {get;set;}
    @TestVisible private String getProfile() {
        List<Profile> profLst = [SELECT ID,Name FROM Profile];
        for (Profile prof : profLst) {
            if (prof.ID == userInfo.getProfileId()) { return prof.Name; }
        }
        return '';
    }   
    public Boolean getValidUser() {
        if (profileID==null) {profileID=getProfile();}
        if (profileID=='') {return false;}
        if (profileID.startsWithIgnoreCase('Admin')) {return true;}
        if (profileID.startsWithIgnoreCase('System')) {return true;}
        if (profileID.containsIgnoreCase('Manager')) {return true;}
        if (oferta.OwnerId == userInfo.getUserId()) {return true;}
        return false;
    }
    public Boolean getAdminUser() {
        if (profileID==null) {profileID=getProfile();}
        if (profileID=='') {return false;}
        if (profileID.startsWithIgnoreCase('Admin')) {return true;}
        if (profileID.startsWithIgnoreCase('System')) {return true;}
        return false;
    }
    public Boolean getOwnerUser() {
        if (profileID==null) {profileID=getProfile();}
        if (profileID=='') {return false;}
        if (oferta.OwnerId == userInfo.getUserId()) {return true;}
        return false;
    }
    public Boolean getManagerUser() {
        if (profileID==null) {profileID=getProfile();}
        if (profileID=='') {return false;}
        if (profileID.containsIgnoreCase('Manager')) {return true;}
        return false;
    }    
    public Boolean getSubmitted() {
        return oferta != null && oferta.KS_Submitted_for_Approval__c;
    }
    public Boolean getApproval() {
        return oferta != null && oferta.KS_Aprobado__c;
    }
    public Boolean getClosed() {
        //System.debug('-- JCAR ---------------------------------- - oferta.StageName? ' +  oferta.StageName);
        return oferta != null 
            && ( oferta.StageName.containsIgnoreCase('Adjudicada') 
                 || oferta.StageName.containsIgnoreCase('Perdida'));
    }
    public Boolean getLocked() {
        System.debug('-- JCAR ---------------------------------- - getSubmitted? ' +  getSubmitted());
        System.debug('-- JCAR ---------------------------------- - getApproval? ' +  getApproval());
        System.debug('-- JCAR ---------------------------------- - getClosed? ' +  getClosed());
        return getSubmitted() || getApproval() || (getClosed() && !getAdminUser());
    }
    
    public Territory2 territorio;
    public String getTerritorio() {
        return territorio.Name;
    }
    
    public Map<String,ID> recordTypes {get;set;}
    public Boolean getOfertaRT() {
        //OR(ISNULL(oferta.RecordTypeId),CASESAFEID(oferta.RecordTypeId)='0124E0000008V2TQAU')
        if (oferta.RecordTypeId == null) {return true;}
        if (!recordTypes.containsKey('KS_Oferta')) {return true;}
        return oferta.RecordTypeId == recordTypes.get('KS_Oferta');
    }

    @TestVisible private Set<String> userGroup {get;set;}
    public Boolean getGroupValid() {
        if (userGroup == null) { userGroup = loadUserGroup(); }
        else if (!userGroup.isEmpty()) { userGroup = loadUserGroup(); }
        System.debug('-- JCAR ---------------------------------- - userGroup ' + userGroup);
        return userGroup.contains('Nueva_Oferta');
    }
    @TestVisible private Set<String> loadUserGroup() {
        userGroup = new Set<String>();
        List<GroupMember> lstGroupMember = 
            [SELECT GroupId, UserOrGroupId, Group.DeveloperName FROM GroupMember 
             WHERE userorgroupid =:UserInfo.getUserId()];
        for (GroupMember gm : lstGroupMember) {
            userGroup.add(gm.Group.DeveloperName);
        }
        return userGroup;
    }
    public KS_Oferta_Controller(ApexPages.StandardController controller) {
        
        recordTypes = new Map<String,ID>();
        List<RecordType> rtLst = [SELECT ID,DeveloperName FROM RecordType];
        for (RecordType rt : rtLst) {
            recordTypes.put(rt.DeveloperName, rt.ID);
        }
        
        userGroup = loadUserGroup();
        
        System.debug('-- JCAR ---------------------------------- - CONSTRUCTORA  KS_Oferta_Controller');
        
        profileID = getProfile();
        System.debug('-- JCAR ---------------------------------- - profileID ' + profileID);
        
        editMode = ApexPages.currentPage().getParameters().get('edit');
        System.debug('-- JCAR ---------------------------------- - editMode? ' +  editMode != NULL);
        
        oferta = (Opportunity)controller.getRecord();
        System.debug('-- JCAR ---------------------------------- - getRecord oferta ' + oferta);
        
        if (oferta.ID != null) { // OJO: Siempre debería entrar, sustituye edición y visualización
            
            oferta = [ SELECT Id, IsDeleted, AccountId, KS_Distribuidor__c, RecordTypeId, Name, Description, StageName, Amount, CloseDate, Type, 
                      NextStep, LeadSource, IsClosed, IsWon, ForecastCategory, ForecastCategoryName, CurrencyIsoCode, CampaignId, KS_Referencia__c,  
                      HasOpportunityLineItem, Pricebook2Id, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                      SystemModstamp, LastActivityDate, FiscalQuarter, FiscalYear, Fiscal, LastViewedDate, LastReferencedDate, HasOpenActivity, 
                      HasOverdueTask, KS_Funciona__c, KS_Contabiliza__c, KS_Obra__c, KS_Subetapa__c, KS_Dto_Volumen__c, KS_Canal__c,
                      KS_Oferta_ID__c, KS_Importe_total_fichas__c, KS_Probabilidad__c, KS_Instalador__c, KS_Cliente_final__c, 
                      KS_Organizacion_Cliente__c, KS_Organizacion__c, KS_max_ficha__c, KS_Lista_de_precios__c, KS_sum_condicion_obra__c, 
                      KS_Margen_Distribuidor__c, KS_Margen_Instalador__c, KS_Margen_Cliente__c, KS_Margen_Operacion__c, KS_Margen_Intervinientes__c,
                      KS_descuento_total_operacion__c, KS_Importe_total_Instalador_c__c, KS_Importe_total_Cliente_Final__c, PVP_con_MSC_para_distribuidor__c, 
                      KS_Distribuidor_importe_PVP__c , KS_Distribuidor_MSC_en_PVP__c, MSC_Distribuidor__c, KS_Instalador_Importe_PVP__c, KS_Instalador_MSC_en_PVP__c, 
                      MSC_Instalador__c, KS_Cliente_final_Importe_PVP__c, KS_Cliente_final_MSC_en_PVP__c, MSC_Cliente_Final__c,                      
                      KS_Descuento_total_Distribuidor__c, KS_PVP_con_MSC_para_Instalador__c,PVP_con_MSC_para_Instalador_fx__c, KS_PVP_con_MSC_para_Cliente_Final__c, KS_Submitted_for_Approval__c,
                      KS_Descuento_total_Instalador__c, KS_Descuento_total_Cliente_Final__c, KS_Organizacion_de_ventas__c, KS_Agente_de_contabilizacion__c, KS_Nivel2__c,KS_Nivel3__c,KS_Nivel4__c,
                      KS_Nivel_de_aprobacion_de_4__c, KS_Resp_Iluminacion__c, KS_Resp_Conectividad__c, KS_Resp_Sist_Control__c, KS_Resp_Vehiculo_Electrico__c, KS_Resp_resto_de_gamas__c, KS_Resp_negocio_iberia__c,
                      KS_Margen_distribuidor_pctge__c, KS_Margen_instalador_pctge__c, KS_Estado_de_aprobacion__c, KS_Aprobado__c, KS_Prescrito__c,
                      KS_Resp_Jefe_de_Area__c, KS_Resp_Negocio_Iberia_2__c, Territory2Id, KS_Protected__c, KS_Oferta_Origen_String__c, KS_Oferta_Origen__c, 
                      KS_Area__c, KS_Delegacion__c, KS_Zona__c, KS_Sector__c, KS_AreaF__c, KS_DelegacionF__c, KS_ZonaF__c, KS_Pais__c, KS_Suma_Dto_Ad2__c
                      FROM Opportunity WHERE ID = :oferta.ID ];
            
            if (oferta.KS_Organizacion_de_ventas__c != null && oferta.KS_Organizacion__c == null) {
                oferta.KS_Organizacion__c = oferta.KS_Organizacion_de_ventas__c;
            }
            if (oferta.KS_AreaF__c != null && oferta.KS_Area__c == null) {
                oferta.KS_Area__c = oferta.KS_AreaF__c;
            }
            if (oferta.KS_DelegacionF__c != null && oferta.KS_Delegacion__c == null) {
                oferta.KS_Delegacion__c = oferta.KS_DelegacionF__c;
            }
            if (oferta.KS_ZonaF__c != null && oferta.KS_Zona__c == null) {
                oferta.KS_Zona__c = oferta.KS_ZonaF__c;
            }

            territorio = new Territory2();
            if (oferta.Territory2Id != null) {
                List<Territory2> terrLst = [SELECT ID,NAME FROM Territory2 WHERE ID = :oferta.Territory2Id LIMIT 1];
                if (terrLst.size()>0) {
                    territorio = terrLst[0];
                }
            }
            
            System.debug('-- JCAR ---------------------------------- - oferta ' + oferta);
            // Teniendo la ID de la oferta, podemos saber los productosOferta inmediatamente
            setProductosFromOferta();
            setOfertasPendientes();
            
            isEdit = isEdit != null ? isEdit : new Map<Decimal,Boolean>();
            isDelete = isDelete != null ? isDelete : new Map<String,Boolean>();
            
            cargaInicial = true;
            mapProductosOferta();
            cargaInicial = false;
            
            yaPrescrito = oferta.KS_Prescrito__c;
        }
        
        redirectToAdd = false;
    }
    
    @TestVisible private void mapProductosOferta() {
        
        Set<ID> productosID = new Set<ID>();
        descuentosOferta = new Map<ID,Descuentos>();
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
            
            productosID.add(prOfer.Product2Id);
            
            Descuentos dtos = new Descuentos(prOfer);
            descuentosOferta.put(prOfer.ID, dtos);
        }
        
        System.debug('-- JCAR ---------------------------------- - ' + productosID.size() + ' productosID - ' + productosID);
        
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
        
        System.debug('-- JCAR ---------------------------------- - ' + claveProducto.size() + ' claveProducto - ' + claveProducto);
        
        fichaSelect = new List<SelectOption>(); // Reset/Init de select de ficha
        // fichaSelect.add(new SelectOption('','-')); // Este es el Otros
        // Añadimos totales y creamos mapeos/listas
        Decimal lastFicha = 0;
        for (Decimal ficha : productosOferta.keySet()) {
            String divisa = productosOferta.get(ficha).get(0).CurrencyIsoCode;
            setTotalImporte(ficha, divisa);
            setTotalCantidad(ficha);
            setTotalCantidadFicha(ficha);
            setNombresFicha(ficha);
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
        
        //System.debug('-- JCAR ---------------------------------- - ' + productosOferta.size() + ' productosOferta - ' + productosOferta);
        
        setVariedadVolumenToProducto(productosID);
    }
    
    public void enableEdit() {

        if ( fichaToEdit == null ) { return; }
        isEdit.put(fichaToEdit, true);
        return;
    }
    
    @TestVisible private Boolean validClienteOferta() {
        //return true;
        // Si no se ha informado uno de los dos, saltará la validación por obligatoriedad
        if (oferta.KS_Distribuidor__c == null || oferta.KS_Organizacion_Cliente__c == null) { return true; }
        
        ID userID = /*oferta.OwnerId != null ? oferta.OwnerId : */userInfo.getUserId();
        System.debug('-- JCAR ---------------------------------- - validClienteOferta? userID - ' + userID);
        List<KS_Usuario_MarcaArea__c> marcareas = [SELECT ID, KS_Usuario__c, KS_Marca__c, KS_Area__c
                                                   FROM KS_Usuario_MarcaArea__c
                                                   WHERE KS_Usuario__c = :userID AND KS_Marca__c != null AND KS_Area__c != NULL];
        List<String> validMarcareas = new List<String>();
        for (KS_Usuario_MarcaArea__c uma : marcareas) {
            if (uma.KS_Marca__c != null && uma.KS_Area__c != null) {
                validMarcareas.add(uma.KS_Marca__c + '-' + uma.KS_Area__c);
            }
        }
        System.debug('-- JCAR ---------------------------------- - validClienteOferta? ' + validMarcareas.size() + ' validMarcareas - ' + validMarcareas);
        
        KS_Organizacion_Cliente__c orgCLie = [SELECT ID,KS_Area__c,KS_Organizacion_de_Ventas__c
                                              FROM KS_Organizacion_Cliente__c
                                              WHERE ID = :oferta.KS_Organizacion_Cliente__c];
        if (orgCLie.KS_Area__c != null && orgCLie.KS_Organizacion_de_Ventas__c != null) {
            
            String marcarea = orgCLie.KS_Organizacion_de_Ventas__c + '-' + orgCLie.KS_Area__c;
            System.debug('-- JCAR ---------------------------------- - validClienteOferta? orgCLie.marcarea - ' + marcarea);
            for (String mca : validMarcareas) {
                if (marcarea.containsIgnoreCase(mca)) { return true; }
            }
        }
        
        errorTextOferta = 'El Cliente y/o Oferta Cliente seleccionados no son válidos para el Usuario.';
        return false;
    }
    
    public Boolean setAgenteOferta() {
        
        System.debug('-- JCAR ---------------------------------- - AGENTE setAgenteOferta ' + oferta.KS_Agente_de_contabilizacion__c);
        
        oferta.KS_Area__c = null;
        oferta.KS_Delegacion__c = null;
        oferta.KS_Zona__c = null;
        
        //return true; // Descomentar para desactivar
        if (!oferta.KS_Contabiliza__c){return true;} // No hay que hacer nada
        if (oferta.KS_Agente_de_contabilizacion__c == null){return true;} // Salta validación
        Boolean distriSelect = oferta.KS_Agente_de_contabilizacion__c.equalsIgnoreCase('Distribuidor');
        Boolean instalSelect = oferta.KS_Agente_de_contabilizacion__c.equalsIgnoreCase('Instalador');
        Boolean cliFinSelect = oferta.KS_Agente_de_contabilizacion__c.equalsIgnoreCase('Cliente final');
        
        ID cuentaID = null;
        if (distriSelect) { cuentaID = oferta.KS_Distribuidor__c; }
        if (instalSelect) { cuentaID = oferta.KS_Instalador__c; }
        if (cliFinSelect) { cuentaID = oferta.KS_Cliente_final__c; }
        if (cuentaID == null) {return true;} // Salta validación
        
        KS_Organizacion_Cliente__c orgCliente = null;
        orgCliente = getOrgClienteByClienteID(cuentaID);
        if (orgCliente == null) {return false;} // No hay org cliente válida
        
        System.debug('-- JCAR ---------------------------------- - AGENTE orgCliente ' + orgCliente);
        
        oferta.KS_Area__c = orgCliente.KS_Area__c;
        oferta.KS_Delegacion__c = orgCliente.KS_Delegacion__c;
        oferta.KS_Zona__c = orgCliente.KS_Zona__c;
        return true; // OK
    }
    public KS_Organizacion_Cliente__c getOrgClienteByClienteID(ID cuentaID) {
        
        System.debug('-- JCAR ---------------------------------- - AGENTE getOrgClienteByClienteID ' + cuentaID);
        
        List<KS_Organizacion_Cliente__c> orgClientes = 
            [SELECT ID, KS_Cliente_Distribucion__c, KS_Area__c, KS_Delegacion__c, KS_Zona__c
             FROM KS_Organizacion_Cliente__c 
             WHERE
             (KS_Cliente_Distribucion__c = :cuentaID
              OR (KS_Cliente_Distribucion__c = NULL AND KS_Cliente_Solicitante__c = :cuentaID)
              OR (KS_Cliente_Distribucion__c = NULL AND KS_Cliente_Solicitante__c = NULL AND KS_Cliente_Dest_Mercancias__c = :cuentaID)
             )
             AND (KS_Canal_de_distribucion__c = :(oferta.KS_Canal__c != null ? oferta.KS_Canal__c : '10')
                  OR KS_Canal_de_distribucion__c = NULL)
             AND KS_Sector_Distribuidor__c = :oferta.KS_Sector__c
             AND KS_Organizacion_de_ventas__c = :oferta.KS_Organizacion_de_ventas__c
             LIMIT 1];
        if (orgClientes.isEmpty()) { 
            errorTextOferta = 'No se ha encontrado una Organización Cliente válida para el '+oferta.KS_Agente_de_contabilizacion__c;
        } else {
            return orgClientes[0];
        }
        return null;
    }
    
    public PageReference save() {
        
        // VALIDACIÓN CLIENTE
        //Boolean isValidOferta = validClienteOferta() && setAgenteOferta();
        Boolean isValidOferta = setAgenteOferta();
        
        if (isValidOferta) {
            
            oferta.KS_Prescrito__c = checkPrescrito();
            System.debug('-- JCAR ---------------------------------- - oferta KS_Prescrito__c? ' + oferta.KS_Prescrito__c);
            
            if (oferta.KS_Organizacion_de_ventas__c != null && oferta.KS_Organizacion__c == null) {
                oferta.KS_Organizacion__c = oferta.KS_Organizacion_de_ventas__c;
            }            
            Database.UpsertResult result = Database.upsert(oferta, false);
            
            errorTextOferta = null;
            if (!result.isSuccess()) {
                System.debug('-- JCAR ---------------------------------- - oferta UPSERT ERROR ' + result.getErrors()[0].getMessage());
                errorTextOferta = 'Fallo en Oferta: ' + result.getErrors()[0].getMessage();
                return null;
            }
            
            saveFichas();
            if ((errorTextOferta!=null && errorTextOferta!='') || errorTextOferta == null) { return null; }
            
            return cancel();
        }
        return null;
    }
    
    public PageReference saveFichas() {
        
        errorTextFicha = '';
        
        System.debug('-- JCAR ---------------------------------- - ' + productosOferta.size() + ' FICHAS+productos_oferta - ' + productosOferta);
        
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
                    prOfer.KS_Competidor__c = fichaCompetencia.get(prOfer.KS_Ficha__c).KS_Competidor__c;
					prOfer.KS_Ficha_Nombre__c = fichaNombres.get(prOfer.KS_Ficha__c);
                    
                    prOfer.KS_Cantidad_Ficha__c = prOfer.KS_Cantidad_Ficha__c != null ? prOfer.KS_Cantidad_Ficha__c : 1;
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
                errorTextFicha = 'Fallo al actualizar línea de oportunidad. FICHA: ' 
                    + ol.KS_Ficha__c + ' PRODUCTO: ' + OL.KS_Material__c + ' -- ' + res.getErrors()[0].getMessage();
                
                errorProfer.add(ol.KS_Ficha__c);            
            }
            index++;
        }
        
        // Aqui se remapea con la macrolista!
        productosLst = saveLst;
        cargaInicial = false;
        mapProductosOferta();
        
        for (Decimal ficha : errorProfer) {
            isEdit.put(ficha, true);
        }
        
        System.debug('-- JCAR ---------------------------------- - ' + productosOferta.size() + ' productosOferta - ' + productosOferta);
        
        errorTextOferta = errorTextOferta != null ? errorTextOferta : errorTextFicha;
        if (errorTextOferta == null || (errorTextOferta != null && errorTextOferta =='')) {
            System.debug('-- JCAR ---------------------------------- - CARGA OK');
            return cancel();
        }
        System.debug('-- JCAR ---------------------------------- - CARGA KO');
        return null;
    }
    
    public PageReference sendApproval() {
        
        PageReference pr = testApproval();
        if (pr != null) {
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitted for approval. Please approve.');
            req.setObjectId(oferta.ID);
            Approval.ProcessResult result = Approval.process(req);            
            return pr;
        }
        RETURN NULL;
    }
    public PageReference testApproval() {

        setTerritoryOferta();
        if (oferta.Territory2Id == null && !Test.isRunningTest()) { return null; }
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
        
        mapProductos = new Map<String,Set<ID>>();
        mapProductosQnt = new Map<String,Decimal>();
        mapProductosDto = new Map<String,Decimal>();
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
        
        for (Decimal ficha : productosOferta.keySet()) {
         
            for (OpportunityLineItem prOfer : productosOferta.get(ficha)) {
                
                if (!isDelete.get(prOfer.ID) /*&& prOfer.KS_Dto_adicional_2__c != null && prOfer.KS_Dto_adicional_2__c > 0*/ && claveProducto.containsKey(prOfer.Product2Id)) {
                    
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
                return null;
            }
            index++;
        }        
        
        Database.UpsertResult result = Database.upsert(oferta, false);
        
        errorTextOferta = null;
        if (!result.isSuccess()) {
            System.debug('-- JCAR ---------------------------------- - oferta UPSERT ERROR ' + result.getErrors()[0].getMessage());
            errorTextOferta = 'Fallo en Oferta: ' + result.getErrors()[0].getMessage();
            return null;
        }        
        
        return cancel();
    }
    
    public void setTerritoryOferta() {
        List<ObjectTerritory2Association> taccLst = 
            [SELECT Id, ObjectId, Territory2Id, Territory2.KS_Organizacion_Ventas__c, SobjectType
             FROM ObjectTerritory2Association WHERE ObjectId = :oferta.KS_Distribuidor__c
             AND Territory2.KS_Organizacion_Ventas__c = :oferta.KS_Organizacion_de_ventas__c];
        System.debug('-- JCAR ---------------------------------- - setTerritoryOferta ' + taccLst.size() + ' taccLst - ' + taccLst);
        if (!taccLst.isEmpty())
        {  oferta.Territory2Id = taccLst[0].Territory2Id; }
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
            oppLineItem.UnitPrice = prOfer.UnitPrice;
            oppLineItem.Quantity = prOfer.Quantity;
            oppLineItem.PricebookEntryId = prOfer.PricebookEntryId;
            
            oppLineItem.KS_Variedad_OK__c = prOfer.KS_Variedad_OK__c;
            oppLineItem.KS_Volumen_OK__c = prOfer.KS_Volumen_OK__c;
            oppLineItem.KS_Comentarios__c = prOfer.KS_Comentarios__c;
            oppLineItem.KS_Competencia__c = prOfer.KS_Competencia__c;
            oppLineItem.KS_Descuento_neto__c = prOfer.KS_Descuento_neto__c;
            oppLineItem.KS_Necesita_aprobacion__c = prOfer.KS_Necesita_aprobacion__c;
            oppLineItem.KS_precio_neto__c = prOfer.KS_precio_neto__c;
            oppLineItem.KS_Cantidad__c = prOfer.KS_Cantidad__c;
            oppLineItem.KS_Cantidad_Ficha__c = prOfer.KS_Cantidad_Ficha__c;
            oppLineItem.KS_Ficha__C = newFicha;            
            
            oppLineItem.KS_Dto_base_1__c = prOfer.KS_Dto_base_1__c;
            oppLineItem.KS_Dto_base_2__c = prOfer.KS_Dto_base_2__c;
            oppLineItem.KS_Dto_adicional_1__c = prOfer.KS_Dto_adicional_1__c;
            oppLineItem.KS_Dto_adicional_2__c = prOfer.KS_Dto_adicional_2__c;
            oppLineItem.KS_Dto_Instalador__c = prOfer.KS_Dto_Instalador__c;
            oppLineItem.KS_Dto_cliente_final__c = prOfer.KS_Dto_cliente_final__c;
            oppLineItem.KS_Dto_Variedad__c = prOfer.KS_Dto_Variedad__c;
            oppLineItem.KS_dto_volumen__c = prOfer.KS_dto_volumen__c;
            oppLineItem.KS_ZPN0__c = prOfer.KS_ZPN0__c;
            oppLineItem.KS_Prescrito__c = prOfer.KS_Prescrito__c;
            oppLineItem.KS_Material_sin_cargo__c = prOfer.KS_Material_sin_cargo__c;
            oppLineItem.KS_Destinatario__c = prOfer.KS_Destinatario__c;
            
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
                errorTextFicha = 'Fallo al insertar línea de oportunidad. PRODUCTO: ' + pr.ProductCode + ' -- ' + res.getErrors()[0].getMessage();
            }
            index++;
        }
        
        // Relanzamos la query
        setProductosFromOferta();
        fichaToEdit = newFicha;
        // save(); // Guardado de "porsiaca"¿?
        mapProductosOferta();
        enableEdit();
        
        errorTextOferta = errorTextOferta != null ? errorTextOferta : errorTextFicha;
    }
    
    public PageReference deleteFicha() {
        System.debug('-- JCAR ---------------------------------- - DELETE FICHA ' + fichaToEdit);
        if (fichaToEdit == null) {return null;}
        else if (fichaToEdit != null && fichaToEdit != 0) {
            for (OpportunityLineItem prOfer : productosOferta.get(fichaToEdit)) {
                isDelete.put(prOfer.ID, true);
            }
            return saveFichas();
        }
        return null;
    }
    
    public void setProductosFromOferta() {
        productosLst = [SELECT Id, OpportunityId, KS_Producto__c, Product2Id, ProductCode, Name, Quantity, KS_Cantidad__c, TotalPrice, UnitPrice, ListPrice, ServiceDate, Description, 
                        KS_Nombre__c, KS_Dto_base_1__c, KS_Dto_base_2__c, KS_Dto_Campaign__c, KS_Dto_adicional_1__c, KS_Dto_adicional_2__c, KS_precio_neto__c, KS_Descuento_neto__c, 
                        KS_Dto_volumen__c, KS_Material_sin_cargo__c, KS_Ficha__c, KS_Prescrito__c, KS_Dto_Instalador__c, KS_Dto_cliente_final__c, 
                        KS_Destinatario__c, CurrencyIsoCode, KS_Cantidad_Ficha__c, KS_Cantidad_Total__c, PricebookEntryId, KS_Material__c,
                        KS_Ficha_Nombre__c, KS_Comentarios__c, KS_Competencia__c, KS_Competidor__c, KS_Aprobacion__c, KS_Neto_Base__c, KS_Dto_Logistico__c,
                        KS_Dto_SinCargo__c, KS_Dest_ClieFinal__c, KS_Dest_Distribuidor__c, KS_Dest_Instalador__c, KS_Referencia__c, KS_Orden__c
                        FROM OpportunityLineItem WHERE OpportunityID = :oferta.ID ORDER BY KS_Ficha__c ASC, KS_Orden__c ASC];
        productosLst = productosLst != null ? productosLst : new List<OpportunityLineItem>(); // Por si acaso
        System.debug('-- JCAR ---------------------------------- - SELECT ' + productosLst.size() + ' productosLst - ' + productosLst);
    }
    
    public void setOfertasPendientes() {
        ofertasPendientes = [SELECT Id, KS_Cuenta__c, KS_Cliente_Name__c, KS_Obra__c, KS_Oferta__c 
                             FROM KS_Oferta_pendiente__c WHERE KS_Oferta__c = :oferta.ID];
        ofertasPendientes = ofertasPendientes != null ? ofertasPendientes : new List<KS_Oferta_pendiente__c>(); // Por si acaso  
        ofertaPendiente = '';
    }    
    
    public PageReference cancelFichas() {
        fichaToEdit = null;
        mapProductosOferta();
        return null;
    }

    public PageReference cancel() {
        PageReference pageRef = new PageReference( '/apex/KS_Oferta?id=' + oferta.Id);
        pageRef.SetRedirect(true);
        System.debug('----------------------------------------SERG - pageRef : ' + pageRef );
        return pageRef;
    }    
    
    public PageReference editMode() {
        PageReference pageRef = new PageReference( '/apex/KS_Oferta?id=' + oferta.Id + '&edit=true' );
        pageRef.SetRedirect(true);
        System.debug('----------------------------------------SERG - pageRef : ' + pageRef );
        return pageRef;
    }
    
    public PageReference gotoPDF() {
        if (ofertaPendiente == null) { return null; }
        PageReference pageRef = new PageReference( '/apex/KS_Oferta_PDF?id=' + oferta.Id + '&cliente=' + ofertaPendiente );
        pageRef.SetRedirect(true);
        System.debug('----------------------------------------SERG - pageRef : ' + pageRef );
        return pageRef;
    }
    
    public void setVariedadVolumenToProducto(Set<ID> productosID) {

        System.debug('-- JCAR ---------------------------------- - SET setVariedadVolumenToProducto ENTER - cargaInicial? ' + cargaInicial);
        
        if (cargaInicial) {return;}
        
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
        
        seriesOferta = new List<String>();
        serieProductos = new Map<String,Set<ID>>();
        serieImporteTotal = new Map<String,Decimal>();
        familiasOferta = new List<String>();
        familiaProductos = new Map<String,Set<ID>>();
        familiaImporteTotal = new Map<String,Decimal>();

        // GET ORGANIZACIONES PRODUCTO
        Map<ID,KS_Organizacion_Producto__c> orgProductos = new Map<ID,KS_Organizacion_Producto__c>();
        List<ID> idprod = new List<ID>(); idprod.addAll(productosID);
        System.debug('-- JCAR ---------------------------------- - SET VA/VR canal - ' + canal);
        List<KS_Organizacion_Producto__c> orgProductosLst = [SELECT ID,KS_Producto__c,KS_Serie_Gama__c,KS_Familia__c FROM KS_Organizacion_Producto__c 
                                                          WHERE KS_Producto__c in :idprod AND KS_Canal_de_distribucion__c = :canal];
        for (KS_Organizacion_Producto__c orgrod : orgProductosLst) {
            orgProductos.put(orgrod.KS_Producto__c, orgrod);
        }
        
        List<OpportunityLineItem> productosLst = 
            [SELECT Id, OpportunityId, KS_Producto__c, Product2Id, ProductCode, Name, Quantity, KS_Cantidad__c, TotalPrice, UnitPrice, ListPrice, ServiceDate, Description, 
             KS_Nombre__c, KS_Dto_base_1__c, KS_Dto_base_2__c, KS_Dto_Campaign__c, KS_Dto_adicional_1__c, KS_Dto_adicional_2__c, KS_precio_neto__c, KS_Descuento_neto__c, 
             KS_Dto_volumen__c, KS_Material_sin_cargo__c, KS_Ficha__c, KS_Prescrito__c, KS_Dto_Instalador__c, KS_Dto_cliente_final__c, 
             KS_Destinatario__c, CurrencyIsoCode, KS_Cantidad_Ficha__c, KS_Cantidad_Total__c, PricebookEntryId, KS_Material__c,
             KS_Comentarios__c, KS_Competencia__c, KS_Competidor__c, KS_Aprobacion__c, KS_Neto_Base__c, KS_Dto_Logistico__c,
             KS_Dto_SinCargo__c, KS_Dest_ClieFinal__c, KS_Dest_Distribuidor__c, KS_Dest_Instalador__c, KS_Referencia__c, KS_Orden__c,
             KS_Neto_por_fila__c, KS_Neto_Unitario__c, KS_Neto_Unitario_Cliente_Final__c, Ks_Neto_Unitario_Instalador__c, KS_Ficha_Nombre__c
             FROM OpportunityLineItem 
             WHERE OpportunityID = :oferta.ID];
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
        
        if (ccOfertaLst.isEmpty()) {return;}
        
        Set<Integer> jerarquiaKey = new Set<Integer>();

        Map<String,Integer> indexSerie = new Map<String,Integer>();
        Map<String,Integer> indexFamilia = new Map<String,Integer>();
        
        serieVariedad = new Map<String,KS_Condicion_Comercial__c>();
        serieVolumen = new Map<String,KS_Condicion_Comercial__c>();
        familiaVariedad = new Map<String,KS_Condicion_Comercial__c>();
        familiaVolumen = new Map<String,KS_Condicion_Comercial__c>();       
        
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
                errorTextFicha = e.getMessage();
                System.debug('-- JCAR ---------------------------------- - UPSERT VA/VR ERROR - ' + errorTextFicha);
            }
        }
    }
    
    public PageReference unlock() {

        Approval.UnlockResult uR = Approval.unlock(oferta.ID, true);
        system.debug('resultado desbloquear:' + uR);

        if(!uR.isSuccess()){ 
            
            System.debug('-- JCAR ---------------------------------- - ERROR unlock - ' + uR);
            errorTextOferta = 'Fallo al desbloquear oferta: ' + uR.getErrors()[0].getMessage();
            return null;
        }
        
        oferta.KS_Aprobado__c = false;
        oferta.KS_Submitted_for_Approval__c = false;
        return save();
    }
    
    public Class Descuentos {
        
        private Decimal dtb1D = 0;
        private Decimal dtb2D = 0;
        private Decimal dta1D = 0;
        public Descuentos(OpportunityLineItem opp) {
            dtb1D = opp.KS_Dto_base_1__c;
            dtb2D = opp.KS_Dto_base_2__c;
            //dta1D = opp.KS_Dto_adicional_1__c;
            dta1D = opp.KS_Dto_Campaign__c;
        }
        
        public String getdtb1() { return returnDto(dtb1D); }
        public String getdtb2() { return returnDto(dtb2D); }
        public String getdta1() { return returnDto(dta1D); }
        
        private String returnDto(Decimal dto) {
            if (dto == null || (dto != null && dto==0)) {return '';}
            String format = format2Decimal(dto);
            return format+'%';            
        }
    }
    
    public PageReference editEtapaOferta() {
        PageReference pageRef = new PageReference( '/apex/KS_OfertaEtapa?id=' + oferta.Id);
        pageRef.SetRedirect(true);
        return pageRef;          
    }
    
    public PageReference calculateCondicionesComerciales() {

        Map<ID, Product2> productos = new Map<ID, Product2>();
        for (Decimal ficha : productosOferta.keySet()) {
            for (OpportunityLineItem prOfer : productosOferta.get(ficha)) {
                
                Product2 prod = new Product2();
                prod.ID = prOfer.KS_Producto__c;
                prod.KS_Id_SAP__c = prOfer.KS_Material__c;
                productos.put(prod.ID, prod);
                resetCondicionProducto(prOfer);
            }
        }
        
        System.debug('-- JCAR ---------------------------------- - SELECTED CONDICIONES ' + productos.size() + ' productos - ' + productos);
        Map<String, KS_ProductoOferta_SetCondicionaComercial.Condicion> condicionesPorMaterial = KS_ProductoOferta_SetCondicionaComercial.condicionesPorMaterial(productos, oferta);
        System.debug('-- JCAR ---------------------------------- - SELECTED CONDICIONES ' + condicionesPorMaterial.size() + ' condicionesPorMaterial - ' + condicionesPorMaterial);
        
        for (Decimal ficha : productosOferta.keySet()) {
            for (OpportunityLineItem prOfer : productosOferta.get(ficha)) {
                
                if (condicionesPorMaterial.containsKey(prOfer.KS_Producto__c)) {
                    
                    KS_ProductoOferta_SetCondicionaComercial.Condicion condi = condicionesPorMaterial.get(prOfer.KS_Producto__c);
                    prOfer = condi.toProducto(prOfer);
                }
            }
        }
        
        setVariedadVolumenToProducto(productos.keySet());
        
        Integer index = 0;
        Database.UpsertResult[] results = Database.upsert(productosLst, false);
        for(Database.UpsertResult res : results) {
                        
            if(!res.isSuccess()){ 

                OpportunityLineItem ol = productosLst.get(index);
                System.debug('-- JCAR ---------------------------------- - ERROR producto_oferta - ' + ol.ID + ' - ' + res);
                errorTextFicha = 'Fallo al actualizar línea de oportunidad. FICHA: ' 
                    + ol.KS_Ficha__c + ' PRODUCTO: ' + OL.KS_Material__c + ' -- ' + res.getErrors()[0].getMessage();   
            }
            index++;
        }
        
        if (errorTextOferta == null || (errorTextOferta != null && errorTextOferta =='')) {
            System.debug('-- JCAR ---------------------------------- - CARGA OK');
            return cancel();
        }
        System.debug('-- JCAR ---------------------------------- - CARGA KO');
        return null;
        //return saveFichas();
    }
    
    @TestVisible private void resetCondicionProducto(OpportunityLineItem oppL) {
        
        oppL.UnitPrice = 0;
        oppL.KS_Dto_base_1__c = null;
        oppL.KS_Dto_base_2__c = null;
        oppL.KS_Dto_adicional_1__c = null;
        oppL.KS_ZPN0__c = false;
    }
    
    public PageReference gotoDEMO() {
        
        System.debug('-- JCAR ---------------------------------- gotoDEMO - fichaToEdit? ' + fichaToEdit);
        
        PageReference pgrf = new PageReference('/apex/KS_Oferta_AddProductos?'
                                               +'id='+oferta.ID
                                               +(fichaToEdit != null ? '&ficha='+fichaToEdit : '')
                                              );
        pgrf.setRedirect(true);
        return pgrf;
    }
    
    public void reload(){ 
        System.debug('-- KS_OfertaEtapa RELOAD --');
        oferta.KS_Prescrito__c = checkPrescrito();
    }
    public Boolean yaPrescrito {get;set;}
    public Boolean checkPrescrito() { return oferta != null && oferta.KS_Prescrito__c; }
    public Boolean checkPrescritoAgente() {
        if (oferta != null && oferta.KS_Agente_de_contabilizacion__c != null
            && oferta.KS_Agente_de_contabilizacion__c == 'Cliente final') { return true; }
        if (oferta != null && oferta.KS_Agente_de_contabilizacion__c != null
            && oferta.KS_Agente_de_contabilizacion__c == 'Distribuidor') { return oferta.KS_Prescrito__c; }
        if (oferta != null && oferta.KS_Agente_de_contabilizacion__c != null
            && oferta.KS_Agente_de_contabilizacion__c == 'Instalador') { return yaPrescrito; }
        return false;
    }
    public Boolean getContabilizaDistribuidor() {
        return oferta != null && oferta.KS_Agente_de_contabilizacion__c != null
            && oferta.KS_Agente_de_contabilizacion__c == 'Distribuidor';
    } 
    public Boolean getPrescribeDistribuidor() {
        return oferta != null && getContabilizaDistribuidor() && oferta.KS_Prescrito__c;
    }
}