({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var fileLibrary = component.get ('v.fileLibrary');
        var action = component.get ('c.getParentId');
        action.setParams ({recordId : recordId, fileLibrary : fileLibrary});
        action.setCallback (this, function(response) {
            var parentRecId = response.getReturnValue(); 
            $A.createComponent(
                "TVA_CFB:Docuvault_FolderStructure",
                {
                    "recordId": parentRecId,
                    "Label":component.get ('v.label'),
                    "enableDownloadAllFiles": component.get ('v.enableDownloadAllFiles'),
                    "enableThumbnailIcon": true,
                    "enablefolderRename" : false,
                    "enableFolderPublicLink" : false,
                    "enableFolderPasswordProtectedLink" : false,
                    "enableFolderRemoveLink" : false,
                    "enableChangeFolder" : component.get ('v.enableChangeFolder'),
                    "enableFolderDownload" : false,
                    "enableThumbnailPreview" : false,
                    "enableRecord_Download" : true,
                    "enableRecord_ViewFile" : true,
                    "enableRenameFile" : component.get ('v.enableRenameFile'),
                    "enableRecord_VersionUpload" : component.get ('v.uploadNewVersion'),
                    "enableRecord_PublicLink" : false,
                    "enableRecord_PasswordProtectedLink" : component.get ('v.enablePasswordLink'),
                    "enableUploadAS_SF_File" : false,
                    "enableRecord_DeleteFile" : component.get ('v.enableDelete'),
                    "searchFields" : "",
                    "tableColumns" : component.get('v.tableColumns'),
                    "hoverLayout" : "",
                    "dynamicRecordActions" : "{}",
                    "recordActions" : component.get('v.recordActions')
                },
                function(upload, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = component.get("v.body");
                        body.push(upload);
                        component.set("v.body", body);
                    }
                }
            );
            
        });
        $A.enqueueAction(action);
        
    }
})