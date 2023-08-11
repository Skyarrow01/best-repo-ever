trigger Docuvault_CloudFilesTrigger on TVA_CFB__Cloud_Files__c (before insert, before update, after update) {

    if (Trigger.isUpdate) {
        Docuvault_Helper.copyCheckInCommentsForOfficeFiles (Trigger.New, Trigger.oldMap);
    }
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        Docuvault_Helper.renameCloudFile (Trigger.New, Trigger.oldMap);
    }   
    
    if (Trigger.isAfter && trigger.isUpdate) {
        Docuvault_Helper.trackFileNameChange (Trigger.New, Trigger.oldMap);
    } 
}