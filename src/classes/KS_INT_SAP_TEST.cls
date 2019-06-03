@isTest
public class KS_INT_SAP_TEST {

    public static testMethod void testDelPedido(){
        
        KS_Trigger_Test.disableTrigger();
        KS_Pedido__c pedido = new KS_Pedido__c();
        pedido.KS_Numero_pedido__c = 'TEST_TEST';
        KS_INT_GEN.KS_Pedido pedidoSAP = new KS_INT_GEN.KS_Pedido();
        pedidoSAP.KS_documento_de_ventas = pedido.KS_Numero_pedido__c;
        
        insert pedido;
        KS_Trigger_Test.enableTrigger();
        
        List<KS_INT_GEN.KS_Pedido> lstPedidoSAP = new List<KS_INT_GEN.KS_Pedido>();
        lstPedidoSAP.add(pedidoSAP);
        List<KS_INT_GEN.KS_Resultado> res = KS_INT_SAP.DelPedidos(lstPedidoSAP);
        System.debug(Logginglevel.ERROR,'-- TEST FINAL RESULT ------------------------------ JCAR testDelPedido -- ' +  res);
    }
    
    public static testMethod void testDelEntrega(){
        
        KS_Trigger_Test.disableTrigger();
        KS_Entrega__c entrega = new KS_Entrega__c();
        entrega.KS_Numero_entrega__c = 'TEST_TEST';
        KS_INT_GEN.KS_Entrega entregaSAP = new KS_INT_GEN.KS_Entrega();
        entregaSAP.KS_Numero_Entrega = entrega.KS_Numero_entrega__c;
        
        insert entrega;
        KS_Trigger_Test.enableTrigger();
        
        List<KS_INT_GEN.KS_Entrega> lstEntregaSAP = new List<KS_INT_GEN.KS_Entrega>();
        lstEntregaSAP.add(entregaSAP);
        List<KS_INT_GEN.KS_Resultado> res = KS_INT_SAP.DelEntregas(lstEntregaSAP);
        System.debug(Logginglevel.ERROR,'-- TEST FINAL RESULT ------------------------------ JCAR testDelEntrega -- ' +  res);
    }
    
    public static testMethod void testSetCliente(){
        List<Account> a = KS_INT_SAP_TEST.createCuentaSAP(true, 'TESTCLIENT');
        if (a.isEmpty()) {return;}
        List<Account> b = KS_INT_SAP_TEST.createCuentaSAP(false, a.get(0).KS_ID_SALESFORCE__c);
        if (b.isEmpty()) {return;}
        
        System.debug(Logginglevel.ERROR,'-- TEST RESULT ------------------------------ JCAR testSetCliente Account a -- ' +  a);
        System.debug(Logginglevel.ERROR,'-- TEST RESULT ------------------------------ JCAR testSetCliente Account b -- ' +  b);
        
        if (a.get(0).ID != b.get(0).ID) { 
            String error = 
                '-- TEST RESULT ERROR -- WRONG ASIGNACIÓN DE ID ' +
                a.get(0).ID + ' != ' + b.get(0).ID;
            System.debug(Logginglevel.ERROR,error);
            throw new TestException(error);
        } 
        
        Set<ID> accounts = new Set<ID>(); accounts.add(a.get(0).ID);
        KS_OrgCliente_Trigger.futureUpdateCall(accounts);
    }
    
    public static List<Account> createCuentaSAP(Boolean idSAP, String idExterna) 
    {return createCuentaSAP(idSAP, idExterna, null);}
    public static List<Account> createCuentaSAP(Boolean idSAP, String idExterna, String idSecundaria) {
        
        List<KS_INT_GEN.KS_Cliente> lstCliente = new List<KS_INT_GEN.KS_Cliente>();
        List<KS_INT_GEN.KS_Resultado> lstResult = new List<KS_INT_GEN.KS_Resultado>();
        
        KS_INT_GEN.KS_Cliente clie = new KS_INT_GEN.KS_Cliente();
        KS_INT_GEN.KS_OrganizacionCliente orgClie = new KS_INT_GEN.KS_OrganizacionCliente();
        
        if (idSAP) { clie.KS_Numero_de_deudor = idExterna;/*'TESTCLIENT';*/ }
        else { clie.KS_Clave_de_grupo = idExterna; clie.KS_Numero_de_deudor = idSecundaria; }
        
        clie.KS_Nombre_1 = 'NAME1';
        clie.KS_Nombre_2 = 'NAME2';
        clie.KS_Nombre_3 = 'NAME3';
        clie.KS_Nombre_4 = 'NAME4';
        clie.KS_N_de_telefono_1 = '666666666';
        clie.KS_Pais_Cliente = 'ES';
        clie.KS_Poblacion = 'Barcelona';
        clie.KS_Codigo_Postal = '08907';
        clie.KS_Calle_y_N = 'Calle de gracia';
        clie.KS_Grupo_de_ctas_deudor = '0001';
        clie.KS_Idioma = 'ES';
        clie.KS_N_identificacion_fiscal_suplementario = '1';
        clie.KS_Numero_de_identificacion_fiscal_1 = '1';
        clie.KS_N_de_telefono_2 = '1';
        
        orgClie.KS_Moneda = 'EUR';
        orgClie.KS_Bloqueo_de_entrega_para_cliente = '01';
        orgClie.KS_Bloqueo_de_factura_para_cliente = '01';
        orgClie.KS_Bloqueo_de_pedido_para_cliente = '01';
        orgClie.KS_Cliente_Dest_Mercancias = clie.KS_Numero_de_deudor;
        orgClie.KS_Cliente_solicitante = clie.KS_Numero_de_deudor;
        orgClie.KS_Incoterms_parte_1 = 'AAA';
        orgClie.KS_Incoterms_parte_2 = 'BBB';
        orgClie.KS_Organizacion_de_ventas = 'SI10';
        orgClie.KS_Canal_de_distribucion = '10';
        orgClie.KS_Lista_de_precios = '00';
        orgClie.KS_Sector = '10';
        orgClie.KS_Peticion_de_borrado_para_cliente = true;
        orgClie.KS_Oficinas_de_ventas = '1010';
        orgClie.KS_Grupo_de_vendedores = '000';
        orgClie.KS_Clasificacion_de_Clientes = 'AA';
        orgClie.KS_Sociedad = 'SI10';
        orgClie.KS_Bloqueo_contabilizacion_para_sociedad = true; //Boolean
        orgClie.KS_Clave_de_condiciones_de_pago = '0001';
        orgClie.KS_Peticion_borrado_para_reg_maestro = true;
        
        clie.lstOrgClientes = new List<KS_INT_GEN.KS_OrganizacionCliente>();
        clie.lstOrgClientes.add(orgClie);
        lstCliente.add(clie);
        lstResult = KS_INT_SAP.setCliente(lstCliente);
        
        List<Account> a = [SELECT ID, KS_Id_SAP__c, KS_Id_Salesforce__c,
                           Name, Phone, BillingCountryCode, BillingCity, BillingPostalCode, BillingStreet, 
                           KS_Grupo_de_ctas_deudor__c, KS_Idioma__c, KS_Nombre_2__c, 
                           KS_N_identificacion_fiscal_suplementario__c, KS_Numero_de_identificacion_fiscal_1__c,
                           KS_N_de_telefono_2__c, KS_Actividad__c, KS_Canal__c
                           FROM Account WHERE KS_Id_SAP__c = :idExterna OR KS_Id_Salesforce__c = :idExterna];
        
        return a;
    }
    public class TestException extends Exception {}    
    
}