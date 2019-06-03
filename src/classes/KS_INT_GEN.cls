global class KS_INT_GEN {
    
    /////////////////////////////
    // CLIENTE (DISTRIBUCION) //
    ///////////////////////////    

    global class KS_Cliente {        
        webservice string KS_Numero_de_deudor       {get; set;}     //KS_Id_SAP__c
        webservice string KS_Clave_de_grupo       	{get; set;}     //KS_Id_Salesforce__c
        webservice string KS_Nombre_3               {get; set;}     //Name Comercial
        webservice string KS_Nombre_4               {get; set;}     //Name Comercial
        webservice string KS_N_de_telefono_1        {get; set;}     //Phone
        webservice string KS_Pais_Cliente           {get; set;}     //BillingCountryCode
        webservice string KS_Poblacion              {get; set;}     //BillingStateCode / BillingCity
        webservice string KS_Codigo_Postal          {get; set;}     //BillingPostalCode
        webservice string KS_Calle_y_N              {get; set;}     //BillingStreet
          
        webservice string KS_Grupo_de_ctas_deudor                   {get; set;}
        webservice string KS_Idioma                                 {get; set;}
        webservice string KS_Nombre_1                               {get; set;} //Nombre Fiscal
        webservice string KS_Nombre_2                               {get; set;} //Nombre Fiscal 
        webservice string KS_N_identificacion_fiscal_suplementario  {get; set;}
        webservice string KS_Numero_de_identificacion_fiscal_1      {get; set;}
        webservice string KS_N_de_telefono_2                        {get; set;}
                   
        webservice Boolean KS_Peticion_de_borrado_para_cliente      {get; set;}
        webservice List<KS_OrganizacionCliente> lstOrgClientes      {get; set;}
    }
    
    //////////////////////////////////////////
    // ORGANIZACION CLIENTE (DISTRIBUCION) //
    ////////////////////////////////////////    

    global class KS_OrganizacionCliente {       
        webservice string KS_Moneda                                 {get; set;}     //CurrencyIsoCode
        webservice string KS_Sector                                 {get; set;}     //KS_Sector_Distribuidor__c
        webservice string KS_Canal_de_distribucion                  {get; set;}         
        webservice string KS_Organizacion_de_ventas                 {get; set;}           
        
        webservice String KS_Numero_Personal 						{get; set;}
        webservice string KS_Cliente_Distribucion                   {get; set;}
        webservice string KS_Bloqueo_de_entrega_para_cliente        {get; set;}
        webservice string KS_Bloqueo_de_factura_para_cliente        {get; set;}
        webservice string KS_Bloqueo_de_pedido_para_cliente         {get; set;}
        webservice string KS_Clasificacion_de_Clientes              {get; set;}
        webservice string KS_Grupo_de_vendedores                    {get; set;}    
        webservice string KS_Incoterms_parte_1                      {get; set;}
        webservice string KS_Incoterms_parte_2                      {get; set;}  
        webservice string KS_Oficinas_de_ventas                     {get; set;}
        webservice Boolean KS_Peticion_de_borrado_para_cliente      {get; set;}    
        webservice string KS_Lista_de_precios                       {get; set;}     
        webservice string KS_Cliente_Dest_Mercancias                {get; set;}    
        webservice string KS_Cliente_solicitante                    {get; set;} 
        webservice Boolean KS_Bloqueo_contabilizacion_para_sociedad {get; set;}
        webservice string KS_Clave_de_condiciones_de_pago           {get; set;}  
        webservice Boolean KS_Peticion_borrado_para_reg_maestro     {get; set;}           
        webservice string KS_Sociedad                               {get; set;}    
    }    
        
    ////////////////////////////
    // JERARQUIA DE CLIENTES //
    //////////////////////////
    global class KS_JerarquiaCliente {                   
        webservice Decimal KS_Asignacion_de_jerarquia            {get; set;}
        webservice string KS_Canal_de_distribucion               {get; set;}    
        webservice string KS_Canal_de_distribucion_superior      {get; set;}    
        webservice string KS_Cliente_distribuidor                {get; set;}    
        webservice Date KS_Fin_de_validez_de_la_asignacion       {get; set;}    
        webservice Date KS_Inicio_de_validez_de_la_asignacion    {get; set;}    
        webservice string KS_Cliente_distribuidor_superior       {get; set;}    
        webservice string KS_Organizacion_de_ventas              {get; set;}
        webservice string KS_Organizacion_de_ventas_superior     {get; set;}
        webservice string KS_Sector                              {get; set;}
        webservice string KS_Sector_superior                     {get; set;}        
    }
    
    //////////////////////////
    // MATERIAL - PRODUCTO //
    ////////////////////////    
    global class KS_Producto {
        webservice string KS_Numero_de_material                     {get; set;}     //KS_Id_SAP__c         
        webservice String KS_Codigo_EAN_Material                    {get; set;}
        
        webservice Decimal KS_Peso_bruto                            {get; set;}  
        webservice Decimal KS_Peso_neto                             {get; set;}   
        webservice string KS_Tipo_de_material                       {get; set;}          
        
        webservice string KS_Nombre_Producto_ES                  	{get; set;}
        webservice string KS_Nombre_Producto_EN                  	{get; set;}
        webservice string KS_Nombre_Producto_FR                  	{get; set;}
        webservice string KS_Nombre_Producto_IT                  	{get; set;}
        webservice string KS_Nombre_Producto_DE                  	{get; set;}
        webservice string KS_Nombre_Producto_ZH                  	{get; set;}
        webservice string KS_Nombre_Producto_PT                  	{get; set;}
        webservice string KS_Nombre_Producto_RU                  	{get; set;}        
        
        webservice string KS_Descripcion_corta_ES                   {get; set;}
        webservice string KS_Descripcion_corta_EN                   {get; set;}
        webservice string KS_Descripcion_corta_FR                   {get; set;}
        webservice string KS_Descripcion_corta_IT                   {get; set;}
        webservice string KS_Descripcion_corta_DE                   {get; set;}
        webservice string KS_Descripcion_corta_ZH                   {get; set;}
        webservice string KS_Descripcion_corta_PT                   {get; set;}
        webservice string KS_Descripcion_corta_RU                   {get; set;}        

        webservice List<KS_OrganizacionProducto> lstOrgProductos    {get; set;}    
    }
    
    /////////////////////////////
    // ORGANIZACION PRODUCTOS //
    ///////////////////////////    
    global class KS_OrganizacionProducto {
        webservice boolean KS_eCatalogo                         {get; set;}     
        webservice string KS_Estatus_Comercial                  {get; set;}    
        webservice Date KS_Fecha_de_validez_Estatus_Comercial   {get; set;}   //Fecha validez Estatus Comercial
        webservice string KS_Jerarquia_Producto                 {get; set;}         
        webservice string KS_Serie_Gama                         {get; set;}     
        webservice string KS_Subserie                           {get; set;}
        webservice string KS_Familia                            {get; set;}        
        webservice string KS_Superfamilia                       {get; set;}         
        webservice Decimal KS_Unidad_de_entrega                 {get; set;} 
        webservice string KS_Unidad_medida_de_entrega           {get; set;}   
        webservice string KS_Organizacion_de_Ventas             {get; set;} 
        webservice string KS_Canal_de_distribucion              {get; set;} 
        webservice string KS_Sector                             {get; set;} 
    }
    
    /////////////////////////////
    // JERARQUIA DE PRODUCTOS //
    ///////////////////////////
    global class KS_JerarquiaProducto {
        webservice string KS_Jerarquia_Producto         {get; set;} //KS_Id_SAP
        webservice decimal KS_Numero_Nivel_Jerarquia    {get; set;} 
        
        webservice string KS_Denominacion_ES              {get; set;}
        webservice string KS_Denominacion_EN              {get; set;}
        webservice string KS_Denominacion_FR              {get; set;}
        webservice string KS_Denominacion_IT              {get; set;}
        webservice string KS_Denominacion_DE              {get; set;}
        webservice string KS_Denominacion_ZH              {get; set;}
        webservice string KS_Denominacion_PT              {get; set;}
        webservice string KS_Denominacion_RU              {get; set;}          
    }    

      /////////////////////////////
     // CONDICIONES COMERCIALES //
    /////////////////////////////
    global class KS_CondicionComercial {

        webservice string KS_Cliente {get; set;} // > Account
        webservice string KS_NumeroMaterial {get; set;} // KS_Material__c = Product2.KS_Id_SAP__c
        webservice String KS_JerarquiaProducto1 {get; set;} // KS_PRODH1__c, KS_Jerarquia_Producto__c.KS_Id_SAP__c
        webservice String KS_JerarquiaProducto2 {get; set;} // KS_PRODH2__c, KS_Jerarquia_Producto__c.KS_Id_SAP__c
        webservice String KS_JerarquiaProducto3 {get; set;} // KS_PRODH3__c, KS_Jerarquia_Producto__c.KS_Id_SAP__c
        webservice String KS_JerarquiaProducto4 {get; set;} // KS_PRODH4__c, KS_Jerarquia_Producto__c.KS_Id_SAP__c
        
        webservice String KS_Pais {get; set;}
        webservice String KS_Canal {get; set;}  // picklist
        webservice Decimal KS_Cantidad_Base {get; set;} // número
        webservice String KS_Condicion {get; set;}  // picklist
        webservice Decimal KS_Escala_Importe {get; set;} // divisa
        webservice Decimal KS_Escala_Unidades {get; set;} // número
        webservice String KS_Familia {get; set;}  // picklist
        webservice Date KS_Fecha_Fin {get; set;} // fecha
        webservice Date KS_Fecha_Inicio {get; set;} // fecha
        webservice Decimal KS_Importe {get; set;}  // divisa
        webservice String KS_Organizacion_Ventas {get; set;}  // picklist
        webservice Decimal KS_Porcentaje {get; set;} // porcentaje
        webservice String KS_Sector {get; set;}  // picklist
        webservice String KS_Serie {get; set;}  // picklist
        webservice String KS_Subserie {get; set;}  // picklist
        webservice String KS_Tarifa {get; set;}  // picklist
    }  
    
      /////////////
     // PEDIDOS //
    /////////////    
    global class KS_Pedido {
        
        webservice String KS_Numero_Personal {get; set;}
        webservice String KS_Numero_de_pedido_del_cliente {get; set;} // ID_SAP
        webservice String KS_documento_de_ventas {get; set;}
        webservice Date KS_Fecha_creacion_registro_en_SAP {get; set;}
        webservice String KS_Hora_registrada {get; set;}
        webservice String KS_Nombre_del_responsable {get; set;}
        webservice String KS_Clase_de_documento_de_ventas {get; set;}
        webservice String KS_Motivo_de_pedido {get; set;}
        webservice String KS_Bloqueo_de_nota_de_entrega {get; set;}
        webservice String KS_Bloqueo_de_clases_de_facturas {get; set;}
        webservice Decimal KS_Valor_neto_del_pedido {get; set;}
        webservice String CurrencyIsoCode {get; set;}
        webservice String KS_Organizacion_de_ventas {get; set;}
        webservice String KS_Canal_de_distribucion {get; set;}
        webservice String KS_Sector {get; set;}
        webservice String KS_Grupo_de_vendedores {get; set;}
        webservice String KS_Oficina_de_ventas {get; set;}
        webservice Date KS_Fecha_preferente_de_entrega {get; set;}
        webservice String KS_Condicion_de_expedicion {get; set;}
        webservice String KS_Clase_de_pedido_de_cliente {get; set;}
        webservice Date KS_Fecha_del_pedido_de_compras_cliente {get; set;}
        webservice String KS_Solicitante {get; set;}
        webservice String KS_Destinatario {get; set;}
        webservice String KS_Resp_Pago {get; set;}
        webservice String KS_Dest_Factura {get; set;}
        webservice String KS_Vendedor {get; set;}
        webservice String KS_Comisionista {get; set;}
        webservice String KS_Oferta {get; set;}
        webservice String KS_Nombre_de_usuario {get; set;}
        webservice Date KS_Fecha {get; set;}
        webservice String KS_Hora_del_dia {get; set;}
        webservice String KS_Numero_de_ticket_Attend {get; set;}
        webservice String KS_Estado {get; set;}
    }
    
      //////////////
     // ENTREGAS //
    //////////////    
    global class KS_Entrega {
        
        webservice String KS_Numero_Personal {get; set;}
        webservice String KS_Numero_Entrega {get; set;}
        webservice Date KS_Fecha_de_creacion_del_registro {get; set;}
        webservice String KS_Hora_registrada {get; set;}
        webservice String KS_Organizacion_de_ventas {get; set;}
        webservice String KS_Clase_de_entrega {get; set;}
        webservice String KS_Entrega_completa_por_pedido {get; set;}
        webservice Date KS_Fecha_de_entrega {get; set;}
        webservice Date KS_Fecha_prevista_para_movimiento {get; set;}
        webservice Date KS_Fecha_movimiento_de_mercancias_real {get; set;}
        webservice String KS_Incoterms_parte_1 {get; set;}
        webservice String KS_Incoterms_parte_2 {get; set;}
        webservice String KS_Prioridad_de_entrega {get; set;}
        webservice String KS_Condicion_de_expedicion {get; set;}
        webservice String KS_Solicitante {get; set;}
        webservice String KS_Destinatario {get; set;}
        webservice String KS_Transportista {get; set;}
        webservice Decimal KS_Peso_total {get; set;}
        webservice Decimal KS_Peso_neto {get; set;}
        webservice String KS_Unidad_de_peso {get; set;}
        webservice Decimal KS_Volumen {get; set;}
        webservice String KS_Unidad_de_volumen {get; set;}
        webservice Integer KS_Cantidad_total_de_bultos_de_entrega {get; set;}
        webservice String KS_Estado {get; set;}
    }    
    
      //////////////
     // FACTURAS //
    //////////////    
    global class KS_Factura {
        
        webservice String KS_Numero_Personal {get; set;}
        webservice String KS_Numero_Factura {get; set;}
        webservice String KS_Clase_de_factura {get; set;}
        webservice String KS_Tipo_de_documento_comercial {get; set;}
        webservice String CurrencyIsoCode {get; set;}
        webservice String KS_Organizacion_de_ventas {get; set;}
        webservice String KS_Canal_de_distribucion {get; set;}
        webservice Date KS_Fecha_de_factura_para_el_indice {get; set;}
        webservice Integer KS_Ejercicio {get; set;}
        webservice Integer KS_Periodo_contable {get; set;}
        webservice String KS_Incoterms_parte_1 {get; set;}
        webservice String KS_Incoterms_parte_2 {get; set;}
        webservice String KS_Indicador_de_exportacion {get; set;}
        webservice String KS_Status_para_la_transferencia_a_contab {get; set;}
        webservice Decimal KS_Tipo_de_cambio_de_moneda_para_conta {get; set;}
        webservice String KS_Ind_fijacion_tipo_cambio_sin_determ {get; set;}
        webservice Integer KS_Dias_valor_adicionales {get; set;}
        webservice Date KS_Fecha_de_valor {get; set;}
        webservice String KS_Clave_de_condiciones_de_pago {get; set;}
        webservice String KS_via_de_pago {get; set;}
        webservice String KS_Sociedad {get; set;}
        webservice Decimal KS_Valor_neto_en_moneda_de_documento {get; set;}
        webservice String KS_Nombre_del_responsable {get; set;}
        webservice String KS_Hora_registrada {get; set;}
        webservice Date KS_Fecha_de_creacion_del_registro {get; set;}
        webservice String KS_Solicitante {get; set;}
        webservice String KS_Destinatario {get; set;}
        webservice String KS_Resp_pago {get; set;}
        webservice String KS_Dest_Factura {get; set;}
        webservice String KS_Vendedor {get; set;}
        webservice String KS_Comisionista {get; set;}
        webservice String KS_Factura_esta_anulada {get; set;}
        webservice String KS_Estado {get; set;}
    }     
    
    ///////////////////////////
    // RESULTADO INTEGRACION //
    //////////////////////////  
    global class KS_Resultado {
        webservice string tipo {get; set;}
        webservice string codigo {get; set;}
        webservice string descripcion {get; set;}
    }
    
}