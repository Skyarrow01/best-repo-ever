@isTest
public class agi_QueuedTest {
	@testSetup
    static void setup() {
        insert new EmailMessage(Incoming=true, 
                                FromAddress='mysalesforcetest@gmail.com', 
                                FromName='Test Account',
                                Subject='Test Subject',
                                MessageDate=DateTime.now());
    }
    
	static testmethod void testQueueable() {
        Set<Id> myIds = new Set<Id>();
        
        EmailMessage theTestRecord = [SELECT ID from EmailMessage
                                     	WHERE FromAddress='mysalesforcetest@gmail.com' LIMIT 1];
        myIds.add(theTestRecord.Id);
        
		agi_Queued theQueue = new agi_Queued(myIds);
        
        Test.startTest();        
        System.enqueueJob(theQueue);
        Test.stopTest(); 		        
    }
}