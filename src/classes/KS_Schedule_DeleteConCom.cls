global without sharing class KS_Schedule_DeleteConCom implements Schedulable {
    global void execute(SchedulableContext sc) {
        KS_Schedule_SIMON_Controller.callScheduleDeleteConComerciales_Manual();
    }
}