global without sharing class TerritoryMangRule
{
    webService static void fireTerritoryManagementViaSoap(/*List<Account> lstAccountToUpdate*/List<ID> accounts) 
    { 
        
        System.debug('----------------------------------------JCAR - isRunningTest? : ' + Test.isRunningTest());
        if (Test.isRunningTest()) {return;}

        List<KS_Configuracion__mdt> confLst = [SELECT KS_webService_User__c, KS_webService_Pass__c, KS_webService_Token__c
                                               FROM KS_Configuracion__mdt WHERE DeveloperName = 'CONF'];
        KS_Configuracion__mdt conf = null;
        if (confLst.size()>0) { conf = confLst[0]; }
        else {return;}
        
        Organization currOrg = [Select IsSandbox from Organization limit 1];
        System.debug('----------------------------------------JCAR - IsSandbox? : ' + currOrg.IsSandbox);
        
        String endPoint= currOrg.IsSandbox ? 'https://test.salesforce.com/services/Soap/u/37.0' : 'https://login.salesforce.com/services/Soap/u/37.0';
        
        partnerSoapSforceCom.Soap obj = new partnerSoapSforceCom.Soap();
        obj.endpoint_x = endPoint; //obj.endpoint_x =loginResult.ServerUrl;
        partnerSoapSforceCom.LoginResult loginResult = obj.login(conf.KS_webService_User__c, conf.KS_webService_Pass__c+conf.KS_webService_Token__c);   
        obj.SessionHeader = new partnerSoapSforceCom.SessionHeader_element();
        obj.endpoint_x = loginResult.ServerUrl;
        obj.Sessionheader.sessionid = loginResult.sessionid;
        List<sobjectPartnerSoapSforceCom.sObject_x> lst = new List<sobjectPartnerSoapSforceCom.sObject_x>();
        for(ID ac:accounts)
        {
            sobjectPartnerSoapSforceCom.sObject_x tmpObj = new sobjectPartnerSoapSforceCom.sObject_x();
            tmpObj.type_x = 'Account';
            tmpObj.Id = ac;
            lst.add(tmpObj);
        }
        partnerSoapSforceCom.AssignmentRuleHeader_element  obj1 = new partnerSoapSforceCom.AssignmentRuleHeader_element();
        obj1.useDefaultRule = true;
        obj.AssignmentRuleHeader = obj1;
        
        System.debug('-- JCAR ---------------------------------- - fireTerritoryManagementViaSoap.accounts? ' + lst.size() + ' accounts - ' + lst);
        partnerSoapSforceCom.SaveResult[] lst1 =obj.update_x(lst);
        System.debug('-- JCAR ---------------------------------- - partnerSoapSforceCom.SaveResult? ' + lst1.size() + ' SaveResult - ' + lst1);
    }
}