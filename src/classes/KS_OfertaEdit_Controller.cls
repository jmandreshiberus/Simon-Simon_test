public class KS_OfertaEdit_Controller {

    public Opportunity oferta {get;set;}
    public KS_OfertaEdit_Controller(ApexPages.StandardController controller) {
        oferta = (Opportunity)controller.getRecord();
    }
}