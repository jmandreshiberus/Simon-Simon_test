/**
 * Test class assumes Chatter Feed Tracking is enabled for Account object.
 */
@isTest
private class ConvertNotesToContentNotesBatchableTest {

    @isTest
    static void test_schedulable() {

        Test.startTest();

        System.schedule( 'Conversion Job', '0 0 13 * * ?', new ConvertNotesToContentNotesSchedulable() );

        Test.stopTest();

    }

    @isTest
    static void test_real_time_trigger() {

        Convert_Notes_to_ContentNotes_Settings__c settings = Convert_Notes_to_ContentNotes_Settings__c.getInstance();
        settings.Convert_in_Near_Real_Time__c = true;
        settings.Delete_Note_Once_Converted__c = true;

        upsert settings;

        Account acct = ConvertAttachmentsKSUtils.newAccount(null, 'Test Account', 1, ConvertAttachmentsKSUtils.getRecordType());
        insert acct;

        Test.startTest();

        Note note = new Note(
            title = 'Hello World.txt',
            body = 'Goodnight Moon',
            parentId = acct.id
        );

        insert note;

        Test.stopTest();

        // because the trigger invokes a queueable which is asynchronous
        // we are unable to assert the side effects here, all we can do
        // is test that nothing blows up and assume we are getting code coverage

    }

    @isTest
    static void test_scope_conversion() {

        Convert_Notes_to_ContentNotes_Settings__c settings = Convert_Notes_to_ContentNotes_Settings__c.getInstance();
        settings.Convert_If_Feed_Tracking_Disabled__c = true;
        settings.Delete_Note_Once_Converted__c = true;
        settings.Share_Private_Notes__c = true;
        settings.Conversion_Result_Email_Notifications__c = 'test@example.com';

        upsert settings;

        Profile p = ConvertAttachmentsKSUtils.getProfile();

        User user1, user2;

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_tools_runas.htm
        System.runAs( new User( id = UserInfo.getUserId() ) ) {

            user1 = ConvertAttachmentsKSUtils.newUser( p.id, 'Alpha', 'User 1', 'user_1@example.com' );
            user2 = ConvertAttachmentsKSUtils.newUser( p.id, 'Beta',  'User 2', 'user_2@example.com' );

            insert new List<User>{ user1, user2 };

        }

        Map<String, ID> rtM = ConvertAttachmentsKSUtils.getRecordType();
        
        Account acct1 = ConvertAttachmentsKSUtils.newAccount(user1.id, 'Test Account', 1, rtM);
        insert acct1;

        Account acct2 = ConvertAttachmentsKSUtils.newAccount(user2.id, 'Test Account', 2, rtM);
        insert acct2;

        Note note1 = new Note(
            title = 'Hello World 1.txt',
            body = 'Goodnight Moon',
            parentId = acct1.id,
            ownerId = user1.id
        );

        insert note1;

        Note note2 = new Note(
            title = 'Hello World 2.txt',
            body = 'Goodnight Moon 2',
            parentId = acct2.id,
            ownerId = user2.id
        );

        insert note2;

        Test.startTest();

        ConvertNotesToContentNotesOptions options = new ConvertNotesToContentNotesOptions( settings );
        options.parentIds = new Set<ID>{ acct1.id };

        ConvertNotesToContentNotesBatchable batchable = new ConvertNotesToContentNotesBatchable( options );

        Database.executeBatch( batchable, 100 );

        Test.stopTest();

        List<ContentVersion> cv = [ SELECT id, contentDocumentId, original_record_id__c FROM ContentVersion WHERE isLatest = true ];
        System.assertEquals( 1, cv.size() );
        System.assertEquals( note1.id, cv[0].original_record_id__c );

        ContentDocumentLink cdl = [ SELECT id, linkedEntityId FROM ContentDocumentLink WHERE contentDocumentId = :cv.get(0).contentDocumentId AND linkedEntityId = :acct1.id ];
        System.assert( cdl != null );

    }

    @isTest
    static void test_preserve_original_owner() {

        Profile p = ConvertAttachmentsKSUtils.getProfile();

        User user1, user2;

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_tools_runas.htm
        System.runAs( new User( id = UserInfo.getUserId() ) ) {

            user1 = ConvertAttachmentsKSUtils.newUser( p.id, 'Alpha', 'User 1', 'user_1@example.com' );
            user2 = ConvertAttachmentsKSUtils.newUser( p.id, 'Beta',  'User 2', 'user_2@example.com' );

            insert new List<User>{ user1, user2 };

        }

        Account acct = ConvertAttachmentsKSUtils.newAccount(user1.id, 'Test Account', 1, ConvertAttachmentsKSUtils.getRecordType());
        insert acct;

        Note note1 = new Note(
            title = 'Hello World 1.txt',
            body = 'Goodnight Moon',
            parentId = acct.id,
            ownerId = user1.id
        );

        insert note1;

        Note note2 = new Note(
            title = 'Hello World 2.txt',
            body = 'Goodnight Moon 2',
            parentId = acct.id,
            ownerId = user2.id
        );

        insert note2;

        System.runAs( new User( id = UserInfo.getUserId() ) ) {

            user2.isActive = false;
            update user2;

        }

        // at this point we have notes:
        // one owned by an active user
        // one owned by an inactive user
        // after conversion the active user should own the new file
        // but the inactive user will not be related to the record

        Test.startTest();

        ConvertNotesToContentNotesBatchable batchable = new ConvertNotesToContentNotesBatchable();

        Database.executeBatch( batchable, 100 );

        Test.stopTest();

        List<ContentVersion> cv = [ SELECT id, contentDocumentId, original_record_id__c, original_record_parent_id__c, original_record_owner_id__c FROM ContentVersion WHERE isLatest = true ];
        System.assertEquals( 1, cv.size() );
        System.assertEquals( note1.id, cv[0].original_record_id__c );
        System.assertEquals( note1.parentId, cv[0].original_record_parent_id__c );
        System.assertEquals( note1.ownerId, cv[0].original_record_owner_id__c );

        ContentDocumentLink cdl = [ SELECT id, linkedEntityId FROM ContentDocumentLink WHERE contentDocumentId = :cv.get(0).contentDocumentId AND linkedEntityId = :acct.id ];
        System.assert( cdl != null );

    }
}