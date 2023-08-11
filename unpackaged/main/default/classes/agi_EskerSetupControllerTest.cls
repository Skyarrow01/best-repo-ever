@isTest
public class agi_EskerSetupControllerTest {

    @testSetup
    static void setup(){
		insert new EskerSettings__c(Name='Default', Global_Enabled__c = true, Auto_Trigger_Enabled__c = true, Esker_Notification_Email__c = 'mysalesforcetest@gmail.com');
    }
    @isTest static void testloadpage(){
        agi_EskerSetupController.loadPage();
    }
    @isTest static void testupdateSettings(){
         EskerSettings__c setupRecord = [SELECT Id FROM EskerSettings__c WHERE Name='Default' LIMIT 1];
        agi_EskerSetupController.updateSettings(setupRecord.Id, true, true, 'mysalesforcetest@gmail.com');
    }
    @isTest static void testupdateSettings1(){
        EskerSettings__c setupRecord = [SELECT Id FROM EskerSettings__c WHERE Name='Default' LIMIT 1];
        
        agi_EskerSetupController.updateSettings(setupRecord.Id, false, true, 'mysalesforcetest@gmail.com');
    }
}