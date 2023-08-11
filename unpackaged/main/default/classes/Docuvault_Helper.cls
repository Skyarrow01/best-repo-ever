/*
* Class name   : Docuvault_Helper
* Created By   : Docuvault Team
* Description  : For check In checkout and cancel checkin functionality 
*/
global with sharing class Docuvault_Helper {
    
    public String errorMessage { get; set; } 
    public string restoreStatus { get; set; }
    
    
    public void restoreFile () {
        restoreStatus = '';
        errorMessage = '';
        String versionFileId = apexpages.currentpage().getparameters().get ('id');
        String cloudFileId = apexpages.currentpage().getparameters().get ('cloudFileId');
        TVA_CFB__Version_history__c versionHistory = [SELECT Name FROM TVA_CFB__Version_history__c WHERE Id =: versionFileId];
        
        TVA_CFB.RestoreFileVersion obj = new TVA_CFB.RestoreFileVersion ();
        
        obj.updateId = versionFileId;
        obj.makeAsPrimary ();
        errorMessage = obj.errorMessage;
        restoreStatus = obj.pageURL;
        if (restoreStatus != '' || Test.isRunningTest ()) {
            TVA_CFB__Cloud_Files__c cloudFile = [SELECT 
                                                 Name,  TVA_CFB__Version__c, TVA_CFB__Parent_Id__c,
                                                 TVA_CFB__File_Size__c,Check_In_Comments__c
                                                 FROM 
                                                 TVA_CFB__Cloud_Files__c WHERE Id=: cloudFileId];
            
            cloudFile.Check_In_Comments__c = 'Restored document from v'+versionHistory.Name;
            update cloudFile;
            
            if (cloudFile.TVA_CFB__Parent_Id__c != Label.Docuvault_OrphanFiles) {
                Cloud_File_History__c objHis = new Cloud_File_History__c ();
                objHis.Cloud_Files__c = cloudFile.Id;
                objHis.Name = 'New Version Uploaded';
                objHis.Version__c = cloudFile.TVA_CFB__Version__c;
                objHis.File_name__c = cloudFile.Name;
                objHis.File_Size__c = cloudFile.TVA_CFB__File_Size__c;
                objHis.CheckInNotes__c = 'Restored document from v'+versionHistory.Name;
                insert objHis;
            }
        }
    }
    
    @AuraEnabled
    public static String getProfileName () {
        return [select Profile.name from User WHERE Id =: userInfo.getUserid ()].Profile.Name;
    }
    @AuraEnabled
    public static ID getProjectId (ID taskId) {
        return [SELECT WhatId FROM Task WHERE Id =: taskId].whatId;
    }
    @remoteAction
    global static void restoreCheckinComments (Id cloudFileId) {
        TVA_CFB__Cloud_Files__c cloudFile = [SELECT 
                                             Name, TVA_CFB__Version__c, TVA_CFB__Parent_Id__c,
                                             TVA_CFB__File_Size__c,Check_In_Comments__c
                                             FROM 
                                             TVA_CFB__Cloud_Files__c WHERE Id=: cloudFileId];
        
        cloudFile.Check_In_Comments__c = 'Restored document.';
        update cloudFile;
        if (cloudFile.TVA_CFB__Parent_Id__c != Label.Docuvault_OrphanFiles) {
            Cloud_File_History__c obj = new Cloud_File_History__c ();
            obj.Cloud_Files__c = cloudFile.Id;
            obj.Name = 'New Version Uploaded';
            obj.Version__c = cloudFile.TVA_CFB__Version__c;
            obj.File_name__c = cloudFile.Name;
            obj.File_Size__c = cloudFile.TVA_CFB__File_Size__c;
            obj.CheckInNotes__c = 'Restored document.';
            insert obj;
        }
    }
    
    @AuraEnabled
    public static void copyFileToProject (ID cloudFileId, String fileName, String folder, ID parentProjectId) {
        List <TVA_CFB__Cloud_Files__c> cloudFilesToInsert = new List <TVA_CFB__Cloud_Files__c> ();
        for (TVA_CFB__Cloud_Files__c cloudFile : [SELECT 
                                                  Name, TVA_CFB__Bucket_Name__c, TVA_CFB__Region__c, TVA_CFB__External_File_Name__c,
                                                  TVA_CFB__File_Size_in_Bytes__c, TVA_CFB__File_Type__c, TVA_CFB__Folder__c, Project__r.RecordTypeId
                                                  FROM
                                                  TVA_CFB__Cloud_Files__c 
                                                  WHERE 
                                                  Id =: cloudFileId])
        {
            TVA_CFB__Cloud_Files__c childCloudFile = new TVA_CFB__Cloud_Files__c ();
            childCloudFile.Name = fileName != null && fileName != '' ? fileName : cloudFile.name;
            childCloudFile.TVA_CFB__Bucket_Name__c = cloudFile.TVA_CFB__Bucket_Name__c;
            childCloudFile.TVA_CFB__Region__c = cloudFile.TVA_CFB__Region__c;
            childCloudFile.TVA_CFB__External_File_Name__c = cloudFile.TVA_CFB__External_File_Name__c;
            childCloudFile.TVA_CFB__File_Size_in_Bytes__c = cloudFile.TVA_CFB__File_Size_in_Bytes__c;
            childCloudFile.TVA_CFB__File_Type__c = cloudFile.TVA_CFB__File_Type__c;
            childCloudFile.TVA_CFB__Folder__c = folder != null && folder != '' ? folder : cloudFile.TVA_CFB__Folder__c;
            childCloudFile.TVA_CFB__Parent_ID__c = parentProjectId;
            if (String.valueOf (parentProjectId).startsWith ('00T')) {
                childCloudFile.Activity_Id__c = parentProjectId;
            } else {
                childCloudFile.Project__c = parentProjectId;
            }
            childCloudFile.Parent_Cloud_File_Id__c = cloudFile.Id;
            cloudFilesToInsert.add (childCloudFile); 
        }
        if (!cloudFilesToInsert.isEmpty ()) {
            insert cloudFilesToInsert;
            List <ID> cloudFileIds = new List <ID> ();
            for (TVA_CFB__Cloud_Files__c cloudFile : cloudFilesToInsert) {
                cloudFileIds.add (cloudFile.Id);
            }
            Database.executeBatch (new Docuvault_CopyAWSFile (cloudFileIds), 1);
            
        }
    }
    public static void trackFileNameChange (List <TVA_CFB__Cloud_Files__c> cloudFilesList, Map <ID, TVA_CFB__Cloud_Files__c> oldMap) {
        List <Cloud_File_History__c> cloudHistory = new List <Cloud_File_History__c> ();
        for (TVA_CFB__Cloud_Files__c cloudFile: cloudFilesList) {
            if (cloudFile.name != oldMap.get(cloudFile.Id).Name) {
                Cloud_File_History__c obj = new Cloud_File_History__c ();
                obj.Cloud_Files__c = cloudFile.Id;
                obj.Name = 'Document Name Changed';
                obj.Version__c = cloudFile.TVA_CFB__Version__c;
                obj.File_name__c = cloudFile.Name;
                obj.File_Size__c = cloudFile.TVA_CFB__File_Size__c;
                cloudHistory.add (obj);
            }
        }
        if (!cloudHistory.isEmpty ()) {
            insert cloudHistory;
        }
    }
    public static void renameCloudFile (List <TVA_CFB__Cloud_Files__c> cloudFilesList, Map <ID, TVA_CFB__Cloud_Files__c> oldMap) {
        for (TVA_CFB__Cloud_Files__c cloudFile: cloudFilesList) {
            System.debug (':::::'+cloudFile.Name);
            System.debug (':::::'+cloudFile.Id);
            try {
                String fileName = cloudFile.Name.replace ('.'+cloudFile.TVA_CFB__File_Type__c, '');
                if(fileName.length() > 60){
                    fileName = fileName.substring(0, 60);
                }
                String dateFormat = System.now().format('MM-dd-YY');
                if (fileName.startsWith('v') && fileName.left(3).endsWith('_')) {
                    fileName = fileName.removeStart (fileName.left (3));
                }
                String versionNum = cloudFile.TVA_CFB__Version__c != null ? String.valueOf (cloudFile.TVA_CFB__Version__c) : '1';
               
                fileName = 'v'+versionNum+'_'+fileName;
                
                String last9thCharacter = fileName.subString(fileName.length() - 9);
                if (last9thCharacter != null && last9thCharacter != '' && last9thCharacter.startsWith('_')) {
                    fileName = fileName.removeEnd (fileName.right (9));
                }
                fileName = fileName+'_'+dateFormat+'.'+cloudFile.TVA_CFB__File_Type__c;
                
                System.debug (':::::'+fileName);
                if (oldMap == null || oldMap.get (cloudFile.Id).Name != cloudFile.name || oldMap.get (cloudFile.Id).TVA_CFB__Version__c != cloudFile.TVA_CFB__Version__c) {
                    cloudFile.Name = fileName;
                }
            } catch (Exception e) {
                System.debug (e.getMessage () +' '+e.getLineNumber());
            }
            
        }
        
    }
    public static void copyCheckInCommentsForOfficeFiles (List <TVA_CFB__Cloud_Files__c> cloudFilesList, Map <ID, TVA_CFB__Cloud_Files__c> oldFilesMap) {
        Set <ID> cloudFileIds = new Set <ID> ();
        List<Cloud_File_History__c> cloudHistoryList = new List<Cloud_File_History__c>();
        Map<ID, TVA_CFB__Cloud_Files__c> cloudFileDetailsMap = new Map<Id, TVA_CFB__Cloud_Files__c>();
        for (TVA_CFB__Cloud_Files__c cloudFile: [SELECT
                                                 Name, TVA_CFB__Version__c, TVA_CFB__File_Size__c, TVA_CFB__Office_File_Id__c 
                                                 FROM
                                                 TVA_CFB__Cloud_Files__c 
                                                 WHERE
                                                 Id In: cloudFilesList ]) {
                                                     if (oldFilesMap.get (cloudFile.Id).TVA_CFB__Office_File_Id__c != cloudFile.TVA_CFB__Office_File_Id__c 
                                                         && cloudFile.TVA_CFB__Office_File_Id__c == null
                                                         && oldFilesMap.get (cloudFile.Id).TVA_CFB__Version__c != cloudFile.TVA_CFB__Version__c)
                                                     {
                                                         cloudFileIds.add (cloudFile.ID);
                                                     }
                                                     cloudFileDetailsMap.put(cloudFile.Id, cloudFile);
                                                 }
        if (!cloudFileIds.isEmpty ()) {
            List <TVA_CFB__Cloud_Files__c> cloudFilesToUpdate = new List <TVA_CFB__Cloud_Files__c> ();
            Map <Id, ID> contentDocumentIdMap = new Map <ID, ID> ();
            for (ContentDocumentLink link : [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: cloudFileIds])
            {
                contentDocumentIdMap.put (link.ContentDocumentId, link.LinkedEntityId);
            }
            for (ContentNote note : [SELECT TextPreview FROM ContentNote WHERE ID IN: contentDocumentIdMap.keySet () AND Title LIKE '%CheckIn' Order By CreatedDate DESC LIMIT 1])
            {
                TVA_CFB__Cloud_Files__c cloudFile = new TVA_CFB__Cloud_Files__c ();
                cloudFile.Id = contentDocumentIdMap.get (note.Id);
                cloudFile.Check_In_Comments__c = note.TextPreview;
                cloudFilesToUpdate.add (cloudFile);
                
                Cloud_File_History__c trackVersionObj = new Cloud_File_History__c ();
                trackVersionObj.Cloud_Files__c = cloudFileDetailsMap.get(cloudFile.Id).Id;
                trackVersionObj.Name = 'New Version Uploaded';
                trackVersionObj.Version__c = cloudFileDetailsMap.get(cloudFile.Id).TVA_CFB__Version__c;
                trackVersionObj.File_name__c = cloudFileDetailsMap.get(cloudFile.Id).name;
                trackVersionObj.File_Size__c = cloudFileDetailsMap.get(cloudFile.Id).TVA_CFB__File_Size__c;
                trackVersionObj.CheckInNotes__c = note.TextPreview;
                cloudHistoryList.add(trackVersionObj);
                
                Cloud_File_History__c trackCheckInObj = trackVersionObj.clone(false, false, false, false);
                trackCheckInObj.Name = 'Document Checked In';
                cloudHistoryList.add(trackCheckInObj);
            }
            
            if (!cloudFilesToUpdate.isEmpty()) {
                //update cloudFilesToUpdate;
            }
            if(!cloudHistoryList.isEmpty()){
                Insert cloudHistoryList;
            }
            
        }
        
    }
    @AuraEnabled
    public static List <String> getProjectFolders (id taskId , string type) {
        string projectId = '';
        if(type == 'task'){
            Task t = [SELECT WhatId FROM Task WHERE Id =: taskId];
            projectId = t.WhatId;
        }else if(type == 'Project'){
            projectId = taskId;
        }
        return TVA_CFB.CloudFileCategories.getFolderNames (projectId);
    }
    @AuraEnabled
    public static String cancelCheckOut2 (ContentNote nt, ID cloudFileId) {
        try {
            TVA_CFB__Cloud_Files__c cloudFile = [SELECT Name, TVA_CFB__File_Size__c, TVA_CFB__Version__c FROM TVA_CFB__Cloud_Files__c WHERE ID =: cloudFileId];
            if(nt != null && nt.Content != null && String.valueOf(nt.Content).length() > 1){
            } else {
                nt = new ContentNote ();
                nt.Content = Blob.ValueOf ('CheckOut cancelled by '+UserInfo.getName ());
            }
            nt.Title = 'v'+cloudFile.TVA_CFB__Version__c+' CheckIn';
            insert nt;
            
            ContentDocument cd = [select id from ContentDocument where id=:nt.Id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cd.id;
            cdl.LinkedEntityId = cloudFileId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            cloudFile.Locked__c = false;
            cloudFile.Check_In_At__c = Null;
            cloudFile.Check_In_By__c = Null;
            cloudFile.TVA_CFB__Office_File_Access_Date_Time__c = Null;
            cloudFile.TVA_CFB__Office_File_Last_Modified_By__c = Null;
            cloudFile.TVA_CFB__Office_File_Id__c = null;
            cloudFile.TVA_CFB__Office_File_URL__c = null;
            cloudFile.TVA_CFB__Office_Web_URL__c = null;
            //cloudFile.Check_In_Comments__c = 'CheckOut cancelled by '+UserInfo.getName ();
            Update cloudFile;
            
            contentNote note = [SELECT TextPreview FROM ContentNote WHERE Id =: nt.Id];
            
            Cloud_File_History__c obj = new Cloud_File_History__c ();
            obj.Cloud_Files__c = cloudFile.Id;
            obj.Name = 'Checkout Cancelled';
            obj.Version__c = cloudFile.TVA_CFB__Version__c ;
            obj.File_name__c = cloudFile.name;
            obj.File_Size__c = cloudFile.TVA_CFB__File_Size__c;
            obj.CheckInNotes__c = note.TextPreview;
            insert obj;
            
            return 'Success';
        } catch (DMLException e) {
            return e.getDmlMessage(0) + ' '+e.getLineNumber();
        } catch (Exception e) {
            return e.getMessage()+' '+e.getLineNumber();
        }
    }
    
    @AuraEnabled
    public static ID getParentId (String recordId, Boolean fileLibrary) {
        if (fileLibrary) {
            return Label.Docuvault_OrphanFiles;
        }
        if (recordId != null && recordId != ''){
            if (recordId.startsWith ('00T')) {
                return [SELECT WhatId FROM Task WHERE Id=:recordId].whatId;
            } else {
                return [SELECT inspire1__Project__c FROM inspire1__Project_Tasks__c WHERE ID =: recordID].inspire1__Project__c;
            }
        } else {
            return Label.Docuvault_OrphanFiles;
        }
    }
    @AuraEnabled
    public static TVA_CFB__Cloud_Files__c cloudFileDetails (ID cloudFileId) {
        return [SELECT Locked__c, TVA_CFB__File_Type__c, TVA_CFB__Office_File_Id__c, TVA_CFB__Office_File_Last_Modified_By__c,
                TVA_CFB__Office_File_Last_Modified_By__r.Name
                FROM TVA_CFB__Cloud_Files__c WHERE ID =: cloudFileId];
    }
    
    @AuraEnabled
    public static String checkOut (ContentNote nt, ID cloudFileId) {
        try {
            if(nt != null && nt.Content != null && String.valueOf(nt.content).length() > 1){
                TVA_CFB__Cloud_Files__c cloudFile = [SELECT Name, TVA_CFB__File_Size__c, TVA_CFB__Version__c FROM TVA_CFB__Cloud_Files__c WHERE ID =: cloudFileId];
                nt.Title = 'v'+cloudFile.TVA_CFB__Version__c+' CheckOut';
                insert nt;
                
                ContentDocument cd = [select id from ContentDocument where id=:nt.Id];
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = cd.id;
                cdl.LinkedEntityId = cloudFileId;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                insert cdl;
                
                cloudFile.Locked__c = true;
                cloudFile.TVA_CFB__Office_File_Last_Modified_By__c = UserInfo.getUserId();
                cloudFile.TVA_CFB__Office_File_Access_Date_Time__c = DateTime.now ();
                cloudFile.Check_In_At__c = Null;
                cloudFile.Check_In_By__c = Null;
                update cloudFile;
                
                contentNote note = [SELECT TextPreview FROM ContentNote WHERE Id =: nt.Id];
                
                Cloud_File_History__c obj = new Cloud_File_History__c ();
                obj.Cloud_Files__c = cloudFile.Id;
                obj.Name = 'Document Checked out';
                obj.Version__c = cloudFile.TVA_CFB__Version__c ;
                obj.File_name__c = cloudFile.name;
                obj.File_Size__c = cloudFile.TVA_CFB__File_Size__c;
                obj.CheckInNotes__c = note.TextPreview;
                insert obj;
                
                String downloadURL = getSignedURL (cloudFile.Id, 300, false);
                return 'success'+'-'+downloadURL;
            } else {
                return 'Please add checkout comments.';
            }
            
        } catch (DMLException e) {
            return e.getDmlMessage(0) + ' '+e.getLineNumber();
        } catch (Exception e) {
            return e.getMessage()+' '+e.getLineNumber();
        }
    }
    
    public static String getSignedURL ( ID cloudFileID, Integer expireTime, Boolean trackDownload) {
        String selectedCloudFileID = String.escapeSingleQuotes ( cloudFileID );
        String fileExpireURL = '';
        
        try {
            TVA_CFB__CloudFiles_Settings__c credentials = TVA_CFB__CloudFiles_Settings__c.getInstance ( UserInfo.getUserID () );
            
            Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndPoints = TVA_CFB__Cloud_Files_Region_Endpoints__c.getAll ();
            Map <String, String> cloudFileDetails = NEW Map <String, String> ();
            
            TVA_CFB__Cloud_Files__c obj = NEW TVA_CFB__Cloud_Files__c ();
            obj = [ SELECT 
                   TVA_CFB__Downloads__c, TVA_CFB__Region__c, TVA_CFB__File_type__c,
                   TVA_CFB__Bucket_Name__c, Name, TVA_CFB__External_File_name__c,
                   TVA_CFB__Storage_Server__c,TVA_CFB__Amazon_Version_ID__c, Project__c, Project__r.Name
                   FROM 
                   TVA_CFB__Cloud_Files__c 
                   WHERE 
                   ID =: selectedCloudFileID];
            
            if ( String.isNotBlank ( obj.TVA_CFB__Bucket_Name__c ) && String.isNotBlank ( obj.TVA_CFB__Region__c ) ) {
                cloudFileDetails.put ( 'ID', obj.ID );
                cloudFileDetails.put ( 'bucket', obj.TVA_CFB__Bucket_Name__c );
                cloudFileDetails.put ( 'region', obj.TVA_CFB__Region__c );
                
                String fileNameToDownload = obj.name;
                
                /*if (obj.Project__c != null) {
                    fileNameToDownload = fileNameToDownload.replace('.'+obj.TVA_CFB__File_type__c, '');                    
                    fileNameToDownload = fileNameToDownload+' - '+obj.Project__r.Name+' - '+obj.Project__c+'.'+obj.TVA_CFB__File_type__c;
                }*/
                
                cloudFileDetails.put ( 'fileName', fileNameToDownload);
                cloudFileDetails.put ( 'fileType', obj.TVA_CFB__File_type__c );
                cloudFileDetails.put ( 's3FileName', obj.ID+'.'+obj.TVA_CFB__File_type__c );
                
                if ( obj.TVA_CFB__External_File_name__c != null ) {
                    String fileName = obj.TVA_CFB__External_File_name__c;
                    fileName = EncodingUtil.URLEncode ( fileName , 'UTF-8' );
                    fileName = fileName .replace ( '+', '%20' );
                    fileName = fileName .replace ( '%2F', '/' );
                    
                    cloudFileDetails.put ( 'externalFileName', fileName );
                    cloudFileDetails.put ( 's3FileName', fileName );
                }
                fileExpireURL = TVA_CFB.amazonS3Authentication.generateDownloadLink ( credentials, regionEndPoints, 
                                                                                     cloudFileDetails, expireTime);
                
                if (fileExpireURL != null && fileExpireURL != '' && trackDownload) {
                    obj.TVA_CFB__Downloads__c = obj.TVA_CFB__Downloads__c + 1;
                    update obj;
                }
                
            }
            return fileExpireURL ;
        } catch (Exception e){
            return '';
        }
        
    }
   
    @AuraEnabled
    public static String cloudFileCheckIn(ContentNote nt, Id cloudFileId){
        try{
            TVA_CFB__Cloud_Files__c cloudFile =  [SELECT Name, TVA_CFB__File_Size__c, TVA_CFB__Version__c, TVA_CFB__Office_File_Id__c, TVA_CFB__File_Type__c FROM TVA_CFB__Cloud_Files__c WHERE Id =: cloudFileId];
            nt.Title = 'v'+cloudFile.TVA_CFB__Version__c+' CheckIn';
            insert nt;
            
            ContentDocument cd = [select id from ContentDocument where id=:nt.Id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cd.id;
            cdl.LinkedEntityId = cloudFileId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            ContentNote note = [SELECT TextPreview FROM ContentNote WHERE Id =: nt.Id];
            cloudFile.Locked__c = false;
            cloudFile.Check_In_Comments__c = note.TextPreview;
            cloudFile.Check_In_At__c = DateTime.Now ();
            cloudFile.Check_In_By__c = UserInfo.getUserId();
            cloudFile.TVA_CFB__Office_File_Access_Date_Time__c = Null;
            cloudFile.TVA_CFB__Office_File_Last_Modified_By__c = Null;
            Update cloudFile;
            
            Cloud_File_History__c trackVersionObj = new Cloud_File_History__c ();
            trackVersionObj.Cloud_Files__c = cloudFile.Id;
            trackVersionObj.Name = 'New Version Uploaded';
            trackVersionObj.Version__c = cloudFile.TVA_CFB__Version__c;
            trackVersionObj.File_name__c = cloudFile.Name;
            trackVersionObj.File_Size__c = cloudFile.TVA_CFB__File_Size__c;
            trackVersionObj.CheckInNotes__c = note.TextPreview;
            insert trackVersionObj;
            
            Cloud_File_History__c trackCheckInObj = trackVersionObj.clone(false, false, false, false);
            trackCheckInObj.Name = 'Document Checked In';
            insert trackCheckInObj;
            
            return 'success';
        }catch(DMLException e){
            return e.getDmlMessage(0) + ' '+e.getLineNumber();
        } catch (Exception e){
            return e.getMessage()+' '+e.getLineNumber();
        }
    }
    @AuraEnabled
    public static String checkIn (ContentNote nt, ID cloudFileId) {
        try {
            
            if(nt != null && nt.Content != null && String.valueOf(nt.content).length() > 1) {
                TVA_CFB__Cloud_Files__c cloudFile = new TVA_CFB__Cloud_Files__c ();
                cloudFile = [SELECT Name, TVA_CFB__File_Size__c, TVA_CFB__Version__c, TVA_CFB__Office_File_Id__c, TVA_CFB__File_Type__c FROM TVA_CFB__Cloud_Files__c WHERE ID =: cloudFileId];
                
                String fileType = cloudFile.TVA_CFB__File_Type__c.toLowercase();
                if (cloudFile.TVA_CFB__Office_File_Id__c != null) {
                    nt.Title = 'v'+cloudFile.TVA_CFB__Version__c+' CheckIn';
                    insert nt;
                    ContentDocument cd = [select id from ContentDocument where id=:nt.Id];
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = cd.id;
                    cdl.LinkedEntityId = cloudFileId;
                    cdl.ShareType = 'V';
                    cdl.Visibility = 'AllUsers';
                    insert cdl;
                    return 'success';
                } else {
                    return 'Please upload new version';
                }  
            } else {
                return 'Please add checkin comments.';
            }
            
        } catch (DMLException e) {
            return e.getDmlMessage(0) + ' '+e.getLineNumber();
        } catch (Exception e) {
            return e.getMessage()+' '+e.getLineNumber();
        }
    }
    
    @AuraEnabled
    public static String getUpdatedDocument (Id cloudFileId)
    {
        String selectedCloudFileID = String.escapeSingleQuotes ( cloudFileID );
        String updatedDocument = '';
        TVA_CFB__Cloud_Files__c cloudFile = new TVA_CFB__Cloud_Files__c();
        cloudFile = [SELECT 
                     Name, TVA_CFB__Office_File_Id__c, TVA_CFB__Parent_ID__c,
                     TVA_CFB__Office_File_Last_Modified_By__r.name,
                     TVA_CFB__Version__c,TVA_CFB__File_Size_in_Bytes__c,TVA_CFB__Annotations__c,CreatedDate,
                     TVA_CFB__External_File_Name__c,TVA_CFB__File_Type__c,
                     TVA_CFB__Office_File_Last_Modified_By__c 
                     FROM 
                     TVA_CFB__Cloud_Files__c 
                     WHERE 
                     Id =: selectedCloudFileID];
        if ( cloudFile.TVA_CFB__Office_File_Id__c == null )
        {
            updatedDocument = 'This document is not available for editing.';
            
        } else if (cloudFile.TVA_CFB__Office_File_Last_Modified_By__c != UserInfo.getUserID()
                   && cloudFile.TVA_CFB__Office_File_Last_Modified_By__c !=null) {
                       updatedDocument = cloudFile.TVA_CFB__Office_File_Last_Modified_By__r.name+' is editing this document. Please wait.';
                   } else {
                       getUpdatedDocumentCallout ( selectedCloudFileID );
                       updatedDocument = 'We are fetching the document please wait..';
                   }
        
        return updatedDocument;
    }
    
    
    @future (Callout = true)
    public static void getUpdatedDocumentCallout (ID cloudFileId) {
        String selectedCloudFileID = String.escapeSingleQuotes ( cloudFileID );
        TVA_CFB__CloudFiles_Settings__c s3Credentials = TVA_CFB__CloudFiles_Settings__c.getInstance ( userInfo.getUserId () );
        Map <String, TVA_CFB__Cloud_Files_Region_Endpoints__c> regionEndpoints = TVA_CFB__Cloud_Files_Region_Endpoints__c.getAll ();
        
        TVA_CFB__CloudFiles_Settings__c settings = TVA_CFB__CloudFiles_Settings__c.getInstance ( UserInfo.getUserID() );
        Docuvault_Helper obj = new Docuvault_Helper ();
        Docuvault_Helper.AuthenticationKeys tokens = obj.createRefreshToken (selectedCloudFileID);
        String accessToken = tokens.accessToken;
        TVA_CFB__Cloud_Files__c cloudFile = new TVA_CFB__Cloud_Files__c();
        try
        {
            cloudFile = [SELECT 
                         Name, TVA_CFB__Office_File_Id__c, TVA_CFB__Parent_ID__c,TVA_CFB__Office_File_Last_Modified_By__c,
                         TVA_CFB__Amazon_Version_ID__c,TVA_CFB__Version__c,TVA_CFB__File_Size_in_Bytes__c,TVA_CFB__Annotations__c,
                         CreatedDate, TVA_CFB__External_File_Name__c, TVA_CFB__File_Type__c, TVA_CFB__Bucket_Name__c, TVA_CFB__Region__c
                         FROM 
                         TVA_CFB__Cloud_Files__c 
                         WHERE 
                         Id =: selectedCloudFileID];
        } catch (Exception e) {}
        String region = cloudFile.TVA_CFB__Region__c;
        String bucketName = cloudFile.TVA_CFB__Bucket_Name__c;
        String fileName = '';
        
        if ( String.isNotBlank ( cloudFile.TVA_CFB__External_File_Name__c ) ) {
            fileName = cloudFile.TVA_CFB__External_File_Name__c;
        } else {
            fileName = cloudFile.Id + '.' + cloudFile.TVA_CFB__File_Type__c;
        }
        
        String authorization = 'Authorization';
        String authorizationVal = 'Bearer '+accessToken;
        
        HttpRequest req = new HttpRequest ();
        req.setMethod ( 'GET' );
        req.setEndpoint ( settings.TVA_CFB__Office_365_Endpoint__c+'/drive/items/'+cloudFile.TVA_CFB__Office_File_Id__c );
        req.setHeader ( 'Content-Type', 'application/JSON' );
        req.setHeader (authorization , authorizationVal );
        req.setHeader ( 'Accept', 'application/JSON' );
        
        Http http = new HTTP ();
        HttpResponse res = new HttpResponse ();
        String bodyString = '';
        
        if ( !Test.isRunningTest () ) {
            res = http.send ( req );
            bodyString = res.getBody ();
            if (res.getStatusCode () == 400) {
                if (res.getBody().Length() >= 131072) {
                    cloudFile.TVA_CFB__Office_365_Error__c = res.getBody().Left(131071);
                } else {
                    cloudFile.TVA_CFB__Office_365_Error__c = res.getBody();
                }
            }
        }
        if ( Test.isRunningTest () ) {
            bodyString = '{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#users(test%40bigworks.co)/drive/items/$entity","@microsoft.graph.downloadUrl":"https://public.bn.files.1drv.com/y4mm1N136MSK8mA7P08ReeMImfdbDKVd0zZmFVnpZ767zco8Nyfr4yUJiOfTXnLBRQLd9N70GtfGtpnNVznioKIgy5cZVUeZYB-fxl9G78qunA34lHAhJCI78E3cXd3yq0X4ZTt5ny1js02WMfdQcg5F9nVzn4BR0wv8dfr8vnLjDFgo29NL_B1S1DjAfE4TFQk3pPylh0wsZXg8G1_lnShWPWi3Fzx2WVJuAohjfBPTi1ZTeh9z3ac38Kf3HnwCm92G4DCb5pwcbYMWjvoZLQngPK9kN0AE2d5mLdYlhJA5F8","createdDateTime":"2020-11-06T12:15:55.183Z","cTag":"aYzpEQjIxODIyMTlDOTgxNERGITE1NS4yNzY","eTag":"aREIyMTgyMjE5Qzk4MTRERiExNTUuMjE","id":"DB2182219C9814DF!155","lastModifiedDateTime":"2020-11-09T08:28:08.42Z","name":"instance logins.txt","size":642,"webUrl":"https://1drv.ms/t/s!AN8UmJwhgiHbgRs","reactions":{"commentCount":0},"createdBy":{"user":{"displayName":"vinathi varakantham","id":"db2182219c9814df"}},"lastModifiedBy":{"user":{"displayName":"vinathi varakantham","id":"db2182219c9814df"}},"parentReference":{"driveId":"db2182219c9814df","driveType":"personal","id":"DB2182219C9814DF!101","path":"/drive/root:"},"file":{"mimeType":"text/plain","hashes":{"quickXorHash":"lNPKZI38wS4+7rf1GJVh4j5AQfU=","sha1Hash":"1ED3A8CC44DCF8F03220E25B32ACF6D60CA95351","sha256Hash":"B6645BE05AC4E3BCEDE087C5DB578FDE437DD0F79E8885BE771C0E39527C9DF2"}},"fileSystemInfo":{"createdDateTime":"2020-11-06T12:15:55.183Z","lastModifiedDateTime":"2020-11-09T08:28:08.42Z"}}';
        }
        
        Map <String, Object> objectMap = (Map <String, Object>)JSON.deserializeUntyped ( bodyString );
        String urlToInsert = String.valueOf( objectMap.get ( '@microsoft.graph.downloadUrl') ).subStringBefore( '.com' );
        urlToInsert = urlToInsert+'.com'; 
        
        HttpResponse res2 = new HttpResponse ();
        req.setEndpoint( String.valueOf ( objectMap.get( '@microsoft.graph.downloadUrl' ) ) );
        if (!Test.isRunningTest ()) {
            res2 = http.send ( req );
            if (res2.getStatusCode () == 400) {
                if (res2.getBody().Length() >= 131072) {
                    cloudFile.TVA_CFB__Office_365_Error__c = res2.getBody().Left(131071);
                } else {
                    cloudFile.TVA_CFB__Office_365_Error__c = res2.getBody();
                }
            }
        }
        System.debug (res2);
        if ( Test.isRunningTest () ) {
            res2.setHeader ( 'Location', 'test.com' );
            res2.setStatusCode ( 200 );
        } 
        
        
        if ( res2.getStatusCode ()  == 200)
        {
            bodyString = res2.getBody ();
            String responseCode = String.valueOf ( res2.getStatusCode () );
            String objectCreatedDate = cloudFile.CreatedDate.formatGmt ( 'yyyy-MM-dd' ) 
                + 'T' + cloudFile.CreatedDate.formatGmt ( 'HH:mm:ss' ) +'Z';
            
            Map <String, String> contentTypeMap = New Map <String, String> ();
            for (TVA_CFB__CloudFiles_MIME_Types__c fileMIMETypes : [SELECT
                                                                    Name, TVA_CFB__Content_Type__c 
                                                                    FROM 
                                                                    TVA_CFB__CloudFiles_MIME_Types__c 
                                                                    WHERE 
                                                                    Name != NULL])
            {
                contentTypeMap.put ( fileMIMETypes.Name, fileMIMETypes.TVA_CFB__Content_Type__c );
            }
            
            String mimeType = cloudFile.TVA_CFB__File_Type__c;
            if ( mimeType != null && contentTypeMap.containsKey ( mimeType.toLowerCase () ) ) {
                mimeType = contentTypeMap.get ( mimeType );
            }
            
            Map <String, String> mapCFileDetails = NEW Map <String, String> ();
            mapCFileDetails.put ( 'bucket', bucketName );
            mapCFileDetails.put ( 'fileName', fileName );
            mapCFileDetails.put ( 'region', region );
            mapCFileDetails.put ( 'cType', mimeType );
            
            String parentObjectName = TVA_CFB.amazonS3Authentication.getCurrentRecordID ( cloudFile.TVA_CFB__Parent_ID__c );
            Map <String, String> metaDataMap = NEW Map <String, String> ();
            metaDataMap.put ( 'x-amz-meta-filename', cloudFile.Name );
            metaDataMap.put ( 'x-amz-meta-objectcreateddate', objectCreatedDate );
            metaDataMap.put ( 'x-amz-meta-ownername',userInfo.getName () );
            metaDataMap.put ( 'x-amz-meta-parentid',cloudFile.TVA_CFB__Parent_ID__c );
            metaDataMap.put ( 'x-amz-meta-parentobjectname', parentObjectName );
            
            HTTPResponse response = NEW HTTPResponse ();
            Blob body = res2.getBodyAsBlob ();
            if ( !Test.isRunningTest() ) {
                response = TVA_CFB.AmazonS3Authentication.UploadAttachmentToS3 (s3Credentials, 
                                                                                mapCFileDetails,
                                                                                metaDataMap, 
                                                                                regionEndPoints,
                                                                                body);
            }
            if ( Test.isRunningTest() ) {
                response.setStatusCode (200);
                response.setHeader ( 'ETag', '"test"' );
                response.setHeader ( 'x-amz-version-id', 'test' );
            }
            
            if ( response.getStatusCode() == 200 ) {
                String Etag = response.getHeader( 'ETag' ).removeStart( '"' ).removeEnd ( '"' );
                
                TVA_CFB__version_History__c versionFile = NEW TVA_CFB__version_History__c ();
                versionFile.TVA_CFB__Cloud_Files__c = cloudFile.Id;
                versionFile.TVA_CFB__Amazon_Version_ID__c = cloudFile.TVA_CFB__Amazon_Version_ID__c;
                versionFile.Name = String.valueOf (cloudFile.TVA_CFB__Version__c);
                versionFile.TVA_CFB__File_Name__c = cloudFile.Name;
                versionFile.TVA_CFB__File_Size_in_Bytes__c = cloudFile.TVA_CFB__File_Size_in_Bytes__c;
                versionFile.TVA_CFB__File_Type__c = cloudFile.TVA_CFB__File_Type__c;
                versionFile.TVA_CFB__Annotations__c = cloudFile.TVA_CFB__Annotations__c;
                insert versionFile;
                
                if ( cloudFile.Name.length () > 75 ) {
                    String fileType = cloudFile.TVA_CFB__File_Type__c;
                    if (fileType == NULL)
                        fileType = '';
                    else
                        fileType = '.'+fileType;
                    cloudFile.Name = cloudFile.Name.subString ( 0, 75 )+fileType;
                }
                cloudFile.TVA_CFB__Version__c = cloudFile.TVA_CFB__Version__c+1;
                cloudFile.TVA_CFB__Annotations__c = NULL;
                cloudFile.TVA_CFB__Office_File_Id__c = NULL;
                cloudFile.TVA_CFB__Office_File_Last_Modified_By__c = NULL;
                cloudFile.TVA_CFB__Office_File_URL__c = NULL;
                cloudFile.TVA_CFB__E_Tag__c = Etag;
                cloudFile.TVA_CFB__Amazon_Version_ID__c = response.getHeader ('x-amz-version-id');
                cloudFile.TVA_CFB__Reponse_Code__c = responseCode;
                cloudFile.Locked__c = false;
                cloudFile.Check_In_At__c = DateTime.Now ();
                cloudFile.Check_In_By__c = UserInfo.getUserId();
                if (cloudFile.TVA_CFB__Office_File_Id__c == null) {
                    cloudFile.TVA_CFB__Office_File_Last_Modified_By__c = Null;
                    cloudFile.TVA_CFB__Office_File_Access_Date_Time__c = Null;
                }
                Map <Id, ID> contentDocumentIdMap = new Map <ID, ID> ();
                for (ContentDocumentLink link : [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: cloudFile.ID Order by ContentDocument.ContentModifiedDate DESC ])
                {
                    contentDocumentIdMap.put (link.ContentDocumentId, link.LinkedEntityId);
                }
                for (ContentNote note : [SELECT TextPreview FROM ContentNote WHERE ID IN: contentDocumentIdMap.keySet () AND Title LIKE '%CheckIn' Order By CreatedDate DESC LIMIT 1])
                {
                    cloudFile.Check_In_Comments__c = note.TextPreview;
                }
                if(tokens.refreshToken != null) {
                    obj.getRefreshToken(tokens.refreshToken);
                }
            }
        }
        
        update cloudFile;
    }
    public  AuthenticationKeys createRefreshToken (String cloudFileId) {
        AuthenticationKeys obj = new AuthenticationKeys ();
        TVA_CFB__CloudFiles_Settings__c settings = TVA_CFB__CloudFiles_Settings__c.getInstance (UserInfo.getUserID ());
        TVA_CFB__Office365_User_Tokens__c userTokens = new TVA_CFB__Office365_User_Tokens__c ();
        try {
            userTokens = [SELECT TVA_CFB__Refresh_Token__c,TVA_CFB__Refresh_Token_1__c,TVA_CFB__Refresh_Token_2__c,
                          TVA_CFB__Refresh_Token_3__c,TVA_CFB__Refresh_Token_4__c, Name FROM TVA_CFB__Office365_User_Tokens__c
                          WHERE Name =: UserInfo.getUserID ()];
        } catch (Exception e) {}
        
        String refreshToken = '';
        
        refreshToken = userTokens.TVA_CFB__Refresh_Token__c != null ? userTokens.TVA_CFB__Refresh_Token__c : refreshToken;     
        refreshToken = userTokens.TVA_CFB__Refresh_Token_1__c != null ? refreshToken+userTokens.TVA_CFB__Refresh_Token_1__c : refreshToken;     
        refreshToken = userTokens.TVA_CFB__Refresh_Token_2__c != null ? refreshToken+userTokens.TVA_CFB__Refresh_Token_2__c : refreshToken;     
        refreshToken = userTokens.TVA_CFB__Refresh_Token_3__c != null ? refreshToken+userTokens.TVA_CFB__Refresh_Token_3__c : refreshToken;     
        refreshToken = userTokens.TVA_CFB__Refresh_Token_4__c != null ? refreshToken+userTokens.TVA_CFB__Refresh_Token_4__c : refreshToken;     
        
        String reqBody = 'client_id='+settings.TVA_CFB__Office_365_Client_ID__c
            +'&refresh_token='+refreshToken+'\r\n'
            +'&redirect_uri='+settings.TVA_CFB__Office_365_Redirect_URL__c
            +'&grant_type=refresh_token'
            +'&client_secret='+settings.TVA_CFB__Office_365_Client_Secret__c;
        System.debug (reqBody);
        
        HTTPRequest req = new HttpRequest ();
        req.setEndpoint (settings.TVA_CFB__Office_365_Login_URL__c.replace ('authorize', 'token'));
        req.SetMethod ('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setTimeout (120000);
        req.setBody (reqBody);
        
        Http http = new HTTP ();
        HTTPResponse res = new HTTPResponse ();
        if (Test.isRunningTest ()) {
            res.setBody ('{"access_token" : "test", "refresh_token" : "test"}');
        }
        else {
            res = http.send (req);
        }
        
        TVA_CFB.Office365AccessToken accessTokenJSON = TVA_CFB.Office365AccessToken.parse (res.getBody());
        obj.accessToken = accessTokenJSON.access_token;
        obj.refreshToken = accessTokenJSON.refresh_token;
        return obj;
    }
    
    public void getRefreshToken (String refreshToken) {
        TVA_CFB__Office365_User_Tokens__c userTokens = new TVA_CFB__Office365_User_Tokens__c ();
        try {
            userTokens = [SELECT TVA_CFB__Refresh_Token__c,TVA_CFB__Refresh_Token_1__c,TVA_CFB__Refresh_Token_2__c,
                          TVA_CFB__Refresh_Token_3__c,TVA_CFB__Refresh_Token_4__c, Name FROM TVA_CFB__Office365_User_Tokens__c
                          WHERE Name =: UserInfo.getUserID ()];
        } catch (Exception e) {}
        
        if (refreshToken != null && refreshToken != '') {
            if (refreshToken.length () < 255) {
                userTokens.TVA_CFB__Refresh_Token__c = refreshToken;
            }
            if (refreshToken.length() > 0 && refreshToken.length () >= 255)
            {
                userTokens.TVA_CFB__Refresh_Token__c = refreshToken.left(255);
                refreshToken = refreshToken.replace(userTokens.TVA_CFB__Refresh_Token__c, '');
            }
            if (refreshToken.length() >= 0)
            {
                userTokens.TVA_CFB__Refresh_Token_1__c = refreshToken.left(255);
                refreshToken = refreshToken.replace(userTokens.TVA_CFB__Refresh_Token_1__c, '');
            }
            if (refreshToken.length() > 0)
            {
                userTokens.TVA_CFB__Refresh_Token_2__c = refreshToken.left(255);
                refreshToken = refreshToken.replace(userTokens.TVA_CFB__Refresh_Token_2__c , '');
            }
            if (refreshToken.length() > 0)
            {
                userTokens.TVA_CFB__Refresh_Token_3__c = refreshToken.left(255);
                refreshToken = refreshToken.replace(userTokens.TVA_CFB__Refresh_Token_3__c , '');
            }
            if (refreshToken.length() > 0)
            {
                userTokens.TVA_CFB__Refresh_Token_4__c = refreshToken.left(255);
                refreshToken = refreshToken.replace(userTokens.TVA_CFB__Refresh_Token_4__c , '');
            }
            userTokens.Name = UserInfo.getUserID ();
            
            if (String.isNotBlank (userTokens.id)) {
                update userTokens;
            } else {
                insert userTokens;
            }
        }             
    }
    
    @auraEnabled
    public static List<noteDetails> getRelatedNotes(String recordId){
        List<noteDetails> notes = new List <noteDetails> ();
        Set <ID> contentDocumentIds = new Set <ID> ();
        Map<ContentNote, List<ContentNote>> contentNoteMap = new Map<ContentNote, List<ContentNote>>();
        for (ContentDocumentLink link : [SELECT ContentDocumentId  FROM ContentDocumentLink WHERE LinkedEntityId = :recordId])
        {
            contentDocumentIds.add (link.ContentDOcumentId);
        }
        if (contentDocumentIds.size () > 0) {
            contentNote keyNote = new ContentNote();
            for (ContentNote note : [SELECT Title,TextPreview, CreatedBy.Name, Lastmodifieddate,LastModifiedBy.Name FROM ContentNote WHERE ID IN: contentDocumentIds order by CreatedDate asc])
            {  
                if(note.Title.contains('CheckOut')) {
                    keyNote = note;
                    contentNoteMap.put(keyNote, new List<ContentNote>{});
                }else{
                    contentNoteMap.get(keyNote).add(note);
                }
            }
            
            for(ContentNote cnNote : contentNoteMap.keySet()){
                NoteDetails obj = new NoteDetails();
                obj.CheckOutBy = cnNote.LastModifiedBy.Name;
                DateTime checkOutDate = cnNote.Lastmodifieddate;
                String checkOutdateFormat = checkOutDate.format('MM/dd/YYYY hh:mm a');
                obj.CheckOutAt = checkOutdateFormat;
                obj.CheckOutComments = cnNote.TextPreview;
                obj.key = cnNote.Id;
                
                List<ContentNote> newContentList = contentNoteMap.get(cnNote); 
                for (ContentNote checkInNote : contentNoteMap.get(cnNote)) {
                    obj.CheckInBy = checkInNote.LastModifiedBy.Name;
                    DateTime checkInModifiedDate =  checkInNote.Lastmodifieddate;
                    String DateFormat = checkInModifiedDate.format('MM/dd/YYYY hh:mm a');
                    obj.CheckInAt = DateFormat;
                    obj.CheckInComments = checkInNote.TextPreview;
                }
                notes.add (obj);
            }
        }
        return notes;
    }   
    @AuraEnabled
    public static List <versionDetails> fetchVersionRecords(Id recordId) {
        Boolean hasRestorePermission = FeatureManagement.checkPermission('Docuvault_Restore');
        
        List <versionDetails> versionDetailsList = new List <versionDetails> ();
        TVA_CFB__Cloud_Files__c cloudFile = [SELECT Id, Name, 
                                             (SELECT Id FROM TVA_CFB__Version_History__r), TVA_CFB__Version__c, TVA_CFB__Download_File__c, Check_In_Comments__c, LastModifiedDate, Last_Modified_By__c 
                                             FROM TVA_CFB__Cloud_Files__c 
                                             WHERE Id =: recordId];
        
        versionDetails obj = new versionDetails();
        obj.Version = String.valueof(cloudFile.TVA_CFB__Version__c);
        obj.FileName = cloudFile.Name;
        obj.CheckinComments= cloudFile.Check_In_Comments__c != null ? String.valueof(cloudFile.Check_In_Comments__c).escapeHtml4() : '';
        obj.LastModifiedDate = cloudFile.LastModifiedDate.format('MM/dd/yyyy hh:mm a');
        obj.recordId = cloudFile.Id;
        obj.VersionId = '/'+cloudFile.Id;  
        obj.isCloudFile = true;  
        obj.cloudFileId = cloudFile.Id; 
        obj.LastModifiedBy = cloudFile.Last_Modified_By__c;
        versionDetailsList.add(obj);
        
        for (TVA_CFB__Version_History__c history : [SELECT Name, TVA_CFB__File_Name__c, 
                                                    Check_In_Comments__c, TVA_CFB__Download_File__c, 
                                                    TVA_CFB__Restore__c, LastModifiedDate, LastModifiedBy.name, 
                                                    TVA_CFB__Cloud_Files__c, CreatedDate, CreatedBy.Name
                                                    FROM TVA_CFB__Version_History__c 
                                                    WHERE
                                                    TVA_CFB__Cloud_Files__c=: recordId 
                                                    ORDER BY CreatedDate DESC])
        {
            versionDetails objs = new versionDetails();
            objs.Version = history.Name;
            objs.FileName = history.TVA_CFB__File_Name__c;
            objs.CheckinComments= history.Check_In_Comments__c != null ? String.valueof(history.Check_In_Comments__c.stripHtmlTags()) : '';
            objs.LastModifiedDate = history.CreatedDate.format('MM/dd/yyyy hh:mm a');
            objs.VersionId = '/'+history.Id;
            objs.recordId = history.Id;
            objs.cloudFileId = history.TVA_CFB__Cloud_Files__c;
            objs.isCloudFile = false;  
            objs.LastModifiedBy = history.CreatedBy.name;
            objs.showRestore = false;
            if (hasRestorePermission) {
                objs.showRestore = true;
            }
            versionDetailsList.add(objs);
        }          
        return versionDetailsList;
    }
    
    @AuraEnabled
    public static objectDetails fetchObjectURL(String searchUrlPath, Id cloudFileId) {
        List<String> lstUrls=new List<String>();
        List<String> matchedValues = new List<String>();
        Id matchedId;
        
        TVA_CFB__Cloud_Files__c  cloudFile = [SELECT Id, Name, TVA_CFB__File_Type__c FROM TVA_CFB__Cloud_Files__c WHERE Id =: cloudFileId];
        
        lstUrls.addAll(searchUrlPath.split('/'));
        for(integer i=0;i<lstUrls.size();i++){
            if(lstUrls[i].length() == 18){
                matchedValues.add(lstUrls[i]);
            }
        }
        for(integer i=0;i<matchedValues.size();i++){
            try {
                matchedId = matchedValues[i];
            } catch (Exception e) {
                
            }
        } 
        String sObjName = matchedId.getSObjectType().getDescribe().getName();
        objectDetails obj = new objectDetails();
        String fileName = cloudFile.Name.replace('.'+cloudFile.TVA_CFB__File_Type__c,'');
        if(fileName.length()<= 60){
            obj.cloudFileName =   fileName; 
        }else{
            obj.cloudFileName = fileName.substring(0, 60);
        }
        obj.objectId = matchedId;
        obj.objectName = sObjName;
        return obj;
    }
    
    public class objectDetails{
        @AuraEnabled Public Id objectId;
        @AuraEnabled Public String objectName;
        @AuraEnabled Public String cloudFileName;
    }
    
    public class versionDetails{
        @AuraEnabled Public String version;
        @AuraEnabled Public String fileName;
        @AuraEnabled Public String checkInComments;
        @AuraEnabled Public String lastModifiedDate;
        @AuraEnabled Public String lastModifiedBy;
        @AuraEnabled Public String versionId;  
        @AuraEnabled public Id recordId;
        @AuraEnabled public Id cloudFileId;
        @AuraEnabled public boolean isCloudFile;
        @AuraEnabled public boolean showRestore;
    }
    public class noteDetails {
        @AuraEnabled public String checkOutBy;
        @AuraEnabled public String checkOutAt;
        @AuraEnabled public String checkOutComments;
        @AuraEnabled public String checkInBy ;
        @AuraEnabled public String checkInAt;
        @AuraEnabled public String checkInComments;
        @AuraEnabled public Id key;
    }
    
    public class AuthenticationKeys {
        public String accessToken;
        public String refreshToken;
    }
}