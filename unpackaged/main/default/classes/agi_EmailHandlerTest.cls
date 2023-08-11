@isTest
public class agi_EmailHandlerTest {
    @testSetup
    static void setup(){
		insert new EskerSettings__c(Name='Default', Global_Enabled__c = true, Auto_Trigger_Enabled__c = true, Esker_Notification_Email__c = 'mysalesforcetest@gmail.com');
    } 
    
    @isTest static void testEmailHandler() {
        Account myTestAccount = new Account(Name='MyTestAccount', Esker_Account__c=true);
		insert myTestAccount;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Orders').getRecordTypeId();
        Case aTestCase = new Case(Account=myTestAccount, RecordTypeId=recordTypeId); 
        
        insert aTestCase;
        Id theCaseId = aTestCase.Id;
        
        Test.startTest();        
        insert new EmailMessage(Incoming=true, FromAddress='mysalesforcetest@gmail.com', ParentId=theCaseId,
                               FromName='John Doe', HtmlBody='<html><body>foo</body></html>',
                               TextBody='Foo', MessageDate=DateTime.now());
		List<EmailMessage> email = [SELECT Id, 
                                        Subject, HtmlBody, TextBody, ParentId
                                    FROM EmailMessage
                                    WHERE Id = :theCaseId LIMIT 1];
        boolean op = agi_EmailHandler.forwardToEsker(theCaseId);
        Test.stopTest();
        System.assertEquals(true, op);
    }
    
     @isTest static void testEmailHandlerwithhtmlbody() {
        Account myTestAccount = new Account(Name='MyTestAccount', Esker_Account__c=true);
		insert myTestAccount;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Orders').getRecordTypeId();
        Case aTestCase = new Case(Account=myTestAccount, RecordTypeId=recordTypeId); 
        
        insert aTestCase;
        Id theCaseId = aTestCase.Id;
        Test.startTest();        
        insert new EmailMessage(Incoming=true, FromAddress='mysalesforcetest@gmail.com', 
                                FromName='John Doe', MessageDate=DateTime.now(),
                                ParentId=theCaseId,HtmlBody='Test' );
		List<EmailMessage> email = [SELECT Id, 
                                        Subject, HtmlBody, TextBody, ParentId
                                    FROM EmailMessage
                                    WHERE Id = :theCaseId LIMIT 1];
        System.debug(email);
        Boolean op = agi_EmailHandler.forwardToEsker(theCaseId);
        Test.stopTest();
        System.assertEquals(true, op);
    }
    
    @isTest static void testEmailHandlerwithlatestsenttoesker() {
        Account myTestAccount = new Account(Name='MyTestAccount', Esker_Account__c=true);
		insert myTestAccount;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Orders').getRecordTypeId();
        Case aTestCase = new Case(Account=myTestAccount, RecordTypeId=recordTypeId, Latest_Sent_to_Esker__c=DateTime.now()); 
        
        insert aTestCase;
        Id theCaseId = aTestCase.Id;
        Test.startTest();        
        insert new EmailMessage(Incoming=true, FromAddress='mysalesforcetest@gmail.com', ParentId=theCaseId,
                               FromName='John Doe', HtmlBody='<html><body>foo</body></html>',
                               MessageDate=DateTime.now(), Subject='Test');
		List<EmailMessage> email = [SELECT Id, Subject, HtmlBody, TextBody, ParentId
                                    FROM EmailMessage
                                    WHERE Id = :theCaseId LIMIT 1];
        Boolean op = agi_EmailHandler.forwardToEsker(theCaseId);
        Test.stopTest();
        System.assertEquals(true, op);
    }
    
    @isTest static void testsendemail() {
        
        List<Id> emailIds = new List<Id> ();
        Boolean op = agi_EmailHandler.sendEmail(null,null,null,null,emailIds, null, null);
        System.assertEquals(false, op);
    }
     @isTest static void testsendemail1() {
        Account myTestAccount = new Account(Name='MyTestAccount', Esker_Account__c=true);
		insert myTestAccount;
   
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Orders').getRecordTypeId();
        Case aTestCase = new Case(Account=myTestAccount, RecordTypeId=recordTypeId, Latest_Sent_to_Esker__c=DateTime.now()); 
        
        insert aTestCase;
        Id theCaseId = aTestCase.Id;
        Test.startTest();      
        EmailMessage myEmail = new EmailMessage(Incoming=true, FromAddress='mysalesforcetest@gmail.com', ParentId=theCaseId);
        insert myEmail;
        List<Id> emailIds = new List<Id> ();
        emailIds.add(myEmail.Id);
        Boolean op = agi_EmailHandler.sendEmail(null,'test','testsalesforce@gmail.com',theCaseId,emailIds, false, null);
        System.assertEquals(true, op);
    }
        
    @isTest static void testEmailHandlerwithcontentdoc() {
        Account myTestAccount = new Account(Name='MyTestAccount', Esker_Account__c=true);
		insert myTestAccount;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Orders').getRecordTypeId();
        Case aTestCase = new Case(Account=myTestAccount, RecordTypeId=recordTypeId, Latest_Sent_to_Esker__c=DateTime.now()); 
        
        insert aTestCase;
        Id theCaseId = aTestCase.Id;
        
        Test.startTest();        
   
        EmailMessage myEmail = new EmailMessage(Incoming=true, FromAddress='mysalesforcetest@gmail.com', ParentId=theCaseId,
                                               HtmlBody='<html><body>test</body></html>', FromName='John Doe',
                                               MessageDate=DateTime.now(), Subject='Test');
        insert myEmail;
        ContentVersion cv = new ContentVersion(Title='My Test Title', PathOnClient='foo.pdf', VersionData=Blob.valueOf('string'), ContentLocation='s');
        insert cv;
        Id cvId = cv.Id;
        List<ContentVersion> myVersions = [SELECT Id, ContentDocumentId
                                  	FROM ContentVersion
                                  	WHERE Id = :cvId];
        Id cdId = myVersions[0].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=cdId, LinkedEntityId=myEmail.Id);
        insert cdl;
		
        Boolean op = agi_EmailHandler.sendEmail(myEmail.Id,true);
        Test.stopTest();
        System.assert(cdl!= null);
        System.assertEquals(true, op);
    }
        
    @isTest static void testEmailHandlerenablebutton() {
        Boolean op = agi_EmailHandler.enableButton();
        System.assertEquals(true, op);
    }

     @isTest static void testEmailHandlerwithnobody() {
        Account myTestAccount = new Account(Name='MyTestAccount', Esker_Account__c=true);
		insert myTestAccount;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Orders').getRecordTypeId();
        Case aTestCase = new Case(Account=myTestAccount, RecordTypeId=recordTypeId); 
        
        insert aTestCase;
        Id theCaseId = aTestCase.Id;
        Test.startTest();        
        insert new EmailMessage(Incoming=true, FromAddress='mysalesforcetest@gmail.com', 
                                FromName='John Doe', MessageDate=DateTime.now(),
                                ParentId=theCaseId);
		List<EmailMessage> email = [SELECT Id, 
                                        Subject, HtmlBody, TextBody, ParentId
                                    FROM EmailMessage
                                    WHERE Id = :theCaseId LIMIT 1];
        System.debug(email);
        Boolean op = agi_EmailHandler.forwardToEsker(theCaseId);
        Test.stopTest();
        System.assertEquals(true, op);
    }    

     @isTest static void testEmailHandlerwitemptyStringHtmlBody() {
        Account myTestAccount = new Account(Name='MyTestAccount', Esker_Account__c=true);
		insert myTestAccount;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Orders').getRecordTypeId();
        Case aTestCase = new Case(Account=myTestAccount, RecordTypeId=recordTypeId); 
        
        insert aTestCase;
        Id theCaseId = aTestCase.Id;
        Test.startTest();        
        insert new EmailMessage(Incoming=true, FromAddress='mysalesforcetest@gmail.com', 
                                FromName='John Doe', MessageDate=DateTime.now(),
                                HtmlBody='',
                                ParentId=theCaseId);
		List<EmailMessage> email = [SELECT Id, 
                                        Subject, HtmlBody, TextBody, ParentId
                                    FROM EmailMessage
                                    WHERE Id = :theCaseId LIMIT 1];
        System.debug(email);
        Boolean op = agi_EmailHandler.forwardToEsker(theCaseId);
        Test.stopTest();
        System.assertEquals(true, op);
    }    

     @isTest static void testEmailHandlerwitemptyStringTextBody() {
        Account myTestAccount = new Account(Name='MyTestAccount', Esker_Account__c=true);
		insert myTestAccount;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Orders').getRecordTypeId();
        Case aTestCase = new Case(Account=myTestAccount, RecordTypeId=recordTypeId); 
        
        insert aTestCase;
        Id theCaseId = aTestCase.Id;
        Test.startTest();        
        insert new EmailMessage(Incoming=true, FromAddress='mysalesforcetest@gmail.com', 
                                FromName='John Doe', MessageDate=DateTime.now(),
                                TextBody='',
                                ParentId=theCaseId);
		List<EmailMessage> email = [SELECT Id, 
                                        Subject, HtmlBody, TextBody, ParentId
                                    FROM EmailMessage
                                    WHERE Id = :theCaseId LIMIT 1];
        System.debug(email);
        Boolean op = agi_EmailHandler.forwardToEsker(theCaseId);
        Test.stopTest();
        System.assertEquals(true, op);
    }    
    
}