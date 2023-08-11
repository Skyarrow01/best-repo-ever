({
    doInit : function(component, event, helper) {
        
        window.setTimeout( function() {
            helper.docuvaultEvent (component, event, helper, true, false, false);
        }, 500);
        
        var hrefURL = window.location.pathname;
        var cloudFileId = component.get("v.CloudFileId");
        component.set('v.CloudFileId', cloudFileId);
        
        var action = component.get ('c.fetchObjectURL');
        action.setParams ({
            "searchUrlPath" : hrefURL,
            "cloudFileId":cloudFileId
        });
        action.setCallback (this, function(response) {
            var response = response.getReturnValue();
            if(response.objectName == 'inspire1__Project__c'){
                component.set('v.objectName','project');
            }
            else if(response.objectName == 'Task'){
                component.set('v.objectName','task');
            }
            var objName = component.get ('v.objectName');
            if (!$A.util.isUndefined (objName) && !$A.util.isEmpty (objName)) {
                component.set ('v.showSpinner', false);
                component.set('v.projectId', response.objectId);
                component.set('v.cloudFileName', response.cloudFileName);
                component.set ('v.showChooseFolders', true);
            } else {
                helper.docuvaultEvent (component, event, helper, false, true, true);
                helper.showToast (component, event, helper, 'error', 'Not able to copy the document. Please try again.');
            }
        });
        $A.enqueueAction(action);  
    },
    folderSelectionEvent : function(component, event, helper) {
        var folderVal = event.getParam("folderName");
        component.set('v.selectedFolder',folderVal);
    },
    nameChangeHandler : function(component, event, helper) {
        var inputName = event.getParam("value"); 
        component.set('v.cloudFileName',inputName);
    },
    copyFileHandler : function(component, event, helper) {
        
        var copyFileAction = component.get('c.copyFileToProject');
        var folder = component.get('v.selectedFolder');
        if (!$A.util.isUndefined (folder) && !$A.util.isEmpty (folder)) {
            component.set('v.showSpinner',true);
            copyFileAction.setParams ({
                "cloudFileId" : component.get("v.CloudFileId"),
                "fileName": component.get('v.cloudFileName'),
                "folder": folder,
                "parentProjectId": component.get('v.projectId')
            });
            copyFileAction.setCallback (this, function(response) {
                var response = response.getReturnValue();
                window.setTimeout( function() {
                    component.set('v.showSpinner',false);
                    helper.docuvaultEvent (component, event, helper, false, true, true);
                    helper.showToast (component, event, helper, 'success', 'File is getting copied to the Project.');
                }, 1000);
            });
            
            $A.enqueueAction(copyFileAction); 
        } else {
            helper.showToast (component, event, helper, 'error', 'Please choose folder.');
        }
    }
})