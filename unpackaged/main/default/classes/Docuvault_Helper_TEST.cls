@istest
private class Docuvault_Helper_TEST {
    private testMethod static void validateCheckInCheckOut(){
        
        TVA_CFB__Cloud_Files_Region_Endpoints__c regionEndPoints = NEW TVA_CFB__Cloud_Files_Region_Endpoints__c ();
        regionEndPoints.TVA_CFB__Endpoint_URL__c = 'https://s3.amazonaws.com';
        regionEndPoints.Name = 'us-east-1';
        insert regionEndPoints ;

        TVA_CFB__CloudFiles_MIME_Types__c mimeType = new TVA_CFB__CloudFiles_MIME_Types__c ();
        mimeType.name = 'docx';
        mimeType.TVA_CFB__Content_Type__c = 'test';
        insert mimeType;
        
        TVA_CFB__CloudFiles_Settings__c customSettings = NEW TVA_CFB__CloudFiles_Settings__c ();
        customSettings.TVA_CFB__bucket_name__c = 'testBucket';
        customSettings.TVA_CFB__Access_Key__c = 'testAccess';
        customSettings.TVA_CFB__Secret_Key__c = 'testScret';
        customSettings.TVA_CFB__Amazon_URL__c = 'https://s3.amazonaws.com';
        customSettings.TVA_CFB__Office_365_Login_URL__c = 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize';
        insert customSettings;
        
        inspire1__Project__c projectRec = new inspire1__Project__c();
        projectRec.Name = 'Test Project';
        insert projectRec;
         
        
        TVA_CFB__Cloud_Files__c cloudFile = new TVA_CFB__Cloud_Files__c();
        cloudFile.Name = 'Pre-Launch Checklist & Project Kick-off Info Form test test test.docx';
        cloudFile.TVA_CFB__File_Type__c = 'docx';
        cloudFile.TVA_CFB__Version__c = 1;
        cloudFile.TVA_CFB__Storage_Server__c = 'AWS S3';
        cloudFile.TVA_CFB__Office_File_Id__c = 'test';
        cloudfile.Locked__c = false;
        cloudFile.Project__c = projectRec.Id;
        cloudFile.TVA_CFB__Folder__c = 'Documentation';
        cloudFile.TVA_CFB__Bucket_Name__c = 'Testing Bucket';
        cloudFile.TVA_CFB__Region__c = 'us-east-1';
        cloudFile.TVA_CFB__External_File_Name__c = 'External Test File';
        cloudFile.TVA_CFB__File_Size_in_Bytes__c = 24;
        cloudFile.TVA_CFB__Parent_Id__c = projectRec.Id;
        cloudFile.Check_In_Comments__c = '';
        insert cloudFile;  
        
        cloudFile.Name = 'Pre-Launch Checklist & Project Kick-off Info Form test test test.png';
        cloudFile.TVA_CFB__Version__c =2;
        cloudFile.TVA_CFB__Office_File_Id__c = '123';
        cloudFile.TVA_CFB__File_Type__c = 'docx';
        update cloudFile;
        
        
        TVA_CFB__Version_History__c versionFile = new TVA_CFB__Version_History__c();
        versionFile.Name = String.valueOf(5);
        versionFile.TVA_CFB__Cloud_Files__c = cloudFile.Id;
        insert versionFile;
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject='Donni';
        t.Status='Not Started';
        t.Priority='Normal';
        t.whatId = projectRec.Id;
        insert t;
        
        ContentNote cn = new ContentNote();
        cn.Title = '';
        String body = 'test';
        cn.Content = Blob.valueOf(body.escapeHTML4());
        
        ContentNote cn1 = new ContentNote();
        cn1.Title = '';
        cn1.Content = Blob.valueOf(body.escapeHTML4());
        
        ContentNote cn2 = new ContentNote();
        cn2.Title = '';
        cn2.Content = Blob.valueOf(body.escapeHTML4());
        
        ContentNote cn3 = new ContentNote();
        cn3.Title = 'test';
        cn3.Content = Blob.valueOf(body.escapeHTML4());
        insert cn3;
        
                
        Test.startTest();
        
        String  message = Docuvault_Helper.checkIn(cn1, cloudFile.Id);
        system.assertEquals(message, 'Please upload new version');
        
        TVA_CFB__Cloud_Files__c cFile = Docuvault_Helper.cloudFileDetails(cloudFile.Id);
        
        String returnMessage = Docuvault_Helper.checkOut(cn, cloudFile.Id);
        
        String successMessage = Docuvault_Helper.cloudFileCheckIn(cn2, cloudFile.Id);
        system.assertEquals(successMessage, 'success');
        
        Docuvault_Helper.cancelCheckOut2(cn1,cloudFile.Id);
        try {
            Docuvault_Helper.getUpdatedDocument(cloudFile.Id);
        } catch (Exception e) {}
        
        Docuvault_Helper.getRelatedNotes(cloudFile.Id);
        
        Docuvault_Helper.restoreCheckinComments(cloudFile.Id);
        
        Docuvault_Helper.copyFileToProject(cloudFile.Id,'','',projectRec.Id);
        
        Docuvault_Helper.getProjectFolders(t.Id, 'Project');
        
        Docuvault_Helper.getParentId(t.id,false);
        
        Docuvault_Helper.getParentId(t.id,true);
                
        Docuvault_Helper.fetchVersionRecords(cloudFile.Id);
        
        Docuvault_Helper.fetchObjectURL('/'+projectRec.Id+'/'+'test',cloudFile.Id);
        
        Docuvault_Helper.getProfileName();
        Docuvault_helper.getUpdatedDocumentCallout (cloudFile.Id);
        
        Docuvault_Helper.getProjectId(t.Id);
        apexPages.currentPage().getParameters().put('id',versionFile.Id);
        apexpages.currentpage().getparameters().put('cloudFileId',cloudFile.Id);
        Docuvault_Helper obj = new Docuvault_Helper();
        obj.restoreFile();
                
        Test.stopTest();
        
    }
}