public without sharing class agi_EskerSetupController {

    @AuraEnabled
    public static EskerSettings__c loadPage()
    {
        EskerSettings__c theSetting = null;
        
        List<EskerSettings__c> settings = [SELECT Auto_Trigger_Enabled__c,Esker_Notification_Email__c,Global_Enabled__c,Id,Name
                                          	FROM EskerSettings__c
                                          	WHERE Name = 'Default'];
        
        if (settings.size() > 0)
            theSetting = settings[0];
        else {
            throw new NoDataFoundException();
        }

        return theSetting;
    }
    
    @AuraEnabled
    public static void doJack()
    {
        
    }
    
    @AuraEnabled
    public static void updateSettings(String recordId, Boolean intEnabled, Boolean triggerEnabled, String eskerEmail)
    {
        EskerSettings__c settingRecord = [SELECT Id
                                         	FROM EskerSettings__c
                                         	WHERE Id = :recordId
                                         	LIMIT 1];
        
        settingRecord.Auto_Trigger_Enabled__c = triggerEnabled;
        settingRecord.Global_Enabled__c = intEnabled;
        settingRecord.Esker_Notification_Email__c = eskerEmail;
        
        update settingRecord;
    }
    
}