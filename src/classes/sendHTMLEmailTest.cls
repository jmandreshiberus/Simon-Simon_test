@isTest
private class sendHTMLEmailTest {
    
    static testMethod void testUserEmail(){
        
        // Test with standard profile
        
        Profile p = [select id from profile where name='Usuario estándar' or name = 'Standard User']; 
        
        User testUser = new User();
        testUser.email = 'test@test.com';
        testUser.Username ='test@test1234567890+angry_moose.com';
        testUser.alias ='testUser';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.localesidkey='en_US';
        testUser.emailencodingkey='UTF-8';
        testUser.languagelocalekey='en_US';
        testUser.localesidkey='en_US';
        testUser.ProfileId = p.Id;
        testUser.FirstName = 'Test';
        testUser.LastName = 'Test';
        testUser.Title = 'Some Person';
        testUser.IsActive = true;
        testUser.UserPermissionsInteractionUser = true;
        testUser.KS_IDSAP__c = '99999999';
        
        insert testUser;
        
        Test.startTest();
        
        // Test the email limits before running
        Integer emailbefore = Limits.getEmailInvocations();
        
        // Set all params save, email other addresses & save as activity
        
        sendHTMLEmailPlugin plugin = new sendHTMLEmailPlugin();
        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put('htmlBody', '<strong>Hello world</strong>');
        inputParams.put('Subject', 'Hello world');
        inputParams.put('Target Object Id', testUser.Id);
        inputParams.put('Sender Address', testUser.Email);
        inputParams.put('Priority', 'High');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = plugin.invoke(request);
        
		// Assert that the batch has decreased
    
        system.assertNotEquals(emailbefore,Limits.getEmailInvocations(),'should have decreased');
        
    	Test.stopTest();
    }
    
    
    static testMethod void testLeadEmail(){
        
        // Test that it saves as an activity with the lead
        
      	Lead testLead = new Lead();
		testLead.Salutation = 'Mr.';
        testLead.FirstName = 'Test';
        testLead.LastName = 'Test';
        testLead.Street = '12345 test Lane';
        testLead.City = 'Barcelona';
        testLead.State = 'Barcelona';
        testLead.PostalCode = '08001';
        testLead.Status ='Some Status';
        testLead.Company = 'Some Company';
        testLead.CountryCode = 'ES';
        testLead.Email = 'test@test.com';
        testLead.Title = 'Some Title';
        
        insert testLead;
        
        Test.startTest();
        
        // Test the email limits before running
        Integer emailbefore = Limits.getEmailInvocations();
        
        // Set all params save, email other addresses
        
        sendHTMLEmailPlugin plugin = new sendHTMLEmailPlugin();
        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put('htmlBody', '<strong>Hello world</strong>');
        inputParams.put('Subject', 'Hello world');
        inputParams.put('Target Object Id', testLead.Id);
        inputParams.put('Save As Activity', 'true');
        inputParams.put('Priority', 'Low');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = plugin.invoke(request);
        
		// Assert that the batch has decreased
    
        system.assertNotEquals(emailbefore,Limits.getEmailInvocations(),'should have decreased');
        
              
        // Assert that the activity was saved
        
        List<Task> t = new List<Task>([SELECT Id FROM Task WHERE whoId = :testLead.Id]);
        system.assertEquals(1, t.size());
        
    	Test.stopTest();
    }
    
    static testMethod void testContactEmail(){
        
        // Test that it saves as an activity with the user - test with standard profile

        // Create account for contact
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.BillingStreet = '12345 Test Lane';
        testAccount.BillingCity = 'Barcelona';
        testAccount.BillingCountryCode = 'ES';
        testAccount.BillingState = 'Barcelona';
        testAccount.BillingPostalCode = '08001';
        testAccount.Type = 'Some Type';
        testAccount.RecordTypeId = KS_TEST_FUNCTIONS.getRecordTypeStatic().get('KS_Distribuidores_SAP');
        testAccount.KS_Actividad__c = 'Distribuidor';
        testAccount.KS_Canal__c = 'Distribuidores SAP';
        
        insert testAccount;
          
        // Create new contact
      	Contact testContact= new Contact();
		testContact.Salutation = 'Mr.';
        testContact.FirstName = 'Test';
        testContact.LastName = 'Test';
        testContact.MailingStreet = '12345 test Lane';
        testContact.MailingCity = 'Barcelona';
        testContact.MailingState = 'Barcelona';
        testContact.MailingPostalCode = '68135';
        testContact.AccountId = testAccount.Id;
        testContact.MailingCountryCode = 'ES';
        testContact.Email = 'test@test.com';
        testContact.Title = 'Some Title';
        
        insert testContact;
        
        Test.startTest();
        
        // Test the email limits before running
        Integer emailbefore = Limits.getEmailInvocations();
        
        // Set all params save, email other addresses & save as activity
        
        sendHTMLEmailPlugin plugin = new sendHTMLEmailPlugin();
        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put('htmlBody', '<strong>Hello world</strong>');
        inputParams.put('Subject', 'Hello world');
        inputParams.put('Target Object Id', testContact.Id);
        inputParams.put('Priority', 'High');
        inputParams.put('Save As Activity', 'true');
        inputParams.put('Sender Display Name', 'test@test.com');
        inputParams.put('CC Email Addresses (comma-separated)', 'test@test.com, test123@test.com');
        inputParams.put('BCC Email Addresses (comma-separated)', 'test@test.com, test123@test.com');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = plugin.invoke(request);
        
		// Assert that the batch has decreased
    
        system.assertNotEquals(emailbefore,Limits.getEmailInvocations(),'should have decreased');
        
        // Assert that the activity was saved
        
        List<Task> t = new List<Task>([SELECT Id FROM Task WHERE whoId = :testContact.Id]);
        system.assertEquals(1, t.size());
        
    	Test.stopTest();
    }    
        
    static testMethod void testOtherEmail(){
        Test.startTest();
        
        // Test the email limits before running
        Integer emailbefore = Limits.getEmailInvocations();
        
        // Set all params save, email other addresses & save as activity
        
        sendHTMLEmailPlugin plugin = new sendHTMLEmailPlugin();
        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put('htmlBody', '<strong>Hello world</strong>');
        inputParams.put('Subject', 'Hello world');
        inputParams.put('Other Emails (comma-separated)', 'Test123@test.com, test345@test.com');
        inputParams.put('Priority', 'High');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = plugin.invoke(request);
        
		// Assert that the batch has decreased
    
        system.assertNotEquals(emailbefore,Limits.getEmailInvocations(),'should have decreased');
        
    	Test.stopTest();
    }
    
    // Tests the describe method
    static testMethod void describeTest() {

        sendHTMLEmailPlugin plugin = new sendHTMLEmailPlugin();
        Process.PluginDescribeResult result =  plugin.describe();
		
		// Assert there are 10 inputs        
        System.AssertEquals(result.inputParameters.size(), 11);

	}
}