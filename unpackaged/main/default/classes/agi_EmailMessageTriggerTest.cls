@isTest
public class agi_EmailMessageTriggerTest {
    @testSetup
    static void setup(){
		insert new EskerSettings__c(Name='Default', Global_Enabled__c = true, Auto_Trigger_Enabled__c = true, Esker_Notification_Email__c = 'mysalesforcetest@gmail.com');
    }
    
    @isTest
    static void testOrdersTrigger(){
        Account myTestAccount = new Account(Name='MyTestAccount', Esker_Account__c=true);
		insert myTestAccount;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Orders').getRecordTypeId();
        Case aTestCase = new Case(Account=myTestAccount, RecordTypeId=recordTypeId); 
        
        insert aTestCase;
        Id theCaseId = aTestCase.Id;
        System.debug(theCaseId);
        
        Test.startTest();        
        insert new EmailMessage(Incoming=true, FromAddress='mysalesforcetest@gmail.com', ParentId=theCaseId);
		Test.stopTest();
        
        List<EmailMessage> emails = [SELECT Id FROM EmailMessage
                                    WHERE FromAddress='mysalesforcetest@gmail.com'];

        System.assert(theCaseId != null);
        System.assert(emails.size() == 1);
        
    }

    @isTest
    static void testOrdersInquiresTrigger(){
        Account myTestAccount = new Account(Name='MyTestAccount', Esker_Account__c=true);
		insert myTestAccount;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Orders/Inquiries').getRecordTypeId();
        Case aTestCase = new Case(Account=myTestAccount, RecordTypeId=recordTypeId); 
        
        insert aTestCase;
        Id theCaseId = aTestCase.Id;
        System.debug(theCaseId);
        
        Test.startTest();        
        insert new EmailMessage(Incoming=true, FromAddress='mysalesforcetest@gmail.com', ParentId=theCaseId);
		Test.stopTest();
        
        List<EmailMessage> emails = [SELECT Id FROM EmailMessage
                                    WHERE FromAddress='mysalesforcetest@gmail.com'];

        System.assert(theCaseId != null);
        System.assert(emails.size() == 1);
        
    }    
}