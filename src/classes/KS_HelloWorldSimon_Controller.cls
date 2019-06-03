public with sharing class KS_HelloWorldSimon_Controller {

    public KS_HelloWorldSimon_Controller(ApexPages.StandardController controller) {

    }

    public void llamada() {
       
       //KS_WS_Magento.result_element
       KS_SAP_HelloWorld.HTTP_Port wsMag = new KS_SAP_HelloWorld.HTTP_Port();
       String result = wsMag.SI_SFDC_HelloWorldSimon_Out_Http('Hello World Simon-SF');
       System.debug('-------------------------SERG - result : ' + result );
    
    }
}