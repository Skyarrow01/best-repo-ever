({
    doInit : function(component, event, helper) {
        window.setTimeout( function() {
            helper.docuvaultEvent (component, event, helper, true, false, false);
        }, 500);
        var cloudFileId = component.get("v.CloudFileId");
        var action = component.get("c.cloudFileDetails");
        action.setParams({
            cloudFileId : cloudFileId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                var res = response.getReturnValue();
                component.set ('v.cloudFile', res);
                var checkOutUser = '';
                var checkOutUserId = '';
                try {
                    checkOutUserId = res.TVA_CFB__Office_File_Last_Modified_By__c;
                    checkOutUser = res.TVA_CFB__Office_File_Last_Modified_By__r.Name;
                } catch(e) {}
                var loggedInUserId = $A.get("$SObjectType.CurrentUser.Id");
                if (!$A.util.isEmpty (checkOutUserId) && !$A.util.isUndefined (checkOutUserId)  && res.TVA_CFB__Office_File_Last_Modified_By__c != loggedInUserId) {
                    component.set ('v.showComponent', false);
                    component.set ('v.loading', false);
                    helper.docuvaultEvent (component, event, helper, false, true, false);
                    helper.showToast(component, event, helper, 'Error', 'Document is locked by '+checkOutUser
                                     +'. Please wait till they checkin.'); 
                } else {
                    if ($A.util.isEmpty(res.TVA_CFB__Office_File_Id__c)) {
                        component.set ('v.buttonLabel', 'Save & Proceed to Upload Version');
                    }
                    if (res.Locked__c == true) {
                        component.set ('v.showComponent', true);
                        component.set ('v.loading', false);
                    } else {
                        component.set ('v.showComponent', false);
                        component.set ('v.loading', false);
                        helper.docuvaultEvent (component, event, helper, false, true, false);
                        helper.showToast(component, event, helper, 'Error', 'Document is not locked, not available for Checkin'); 
                    }
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    saveContentNote : function(component, event, helper) {
        component.set ('v.loading', true);
        var cloudFileId = component.get("v.CloudFileId");
        var cNote = component.get("v.note");
        var action = component.get("c.checkIn");
        action.setParams({
            nt : cNote,
            "cloudFileId" : cloudFileId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                component.set ('v.loading', false); 
                var res = response.getReturnValue();
                if (res == 'success') {
                    var cloudFile = component.get ('v.cloudFile');
                    var officeFileId = cloudFile.TVA_CFB__Office_File_Id__c;
                    if (officeFileId != undefined && officeFileId != null && officeFileId != '') {
                        helper.getDocumentFromOffice (component, event, helper, cloudFileId);
                    } else {
                        helper.docuvaultEvent (component, event, helper, false, true, true);
                        helper.showToast (component, event, helper, 'success', 'Checkin completed. Please upload new version.'); 
                    }
                } else if(res == 'Please upload new version'){
                    component.set ('v.showComponent', false);
                    $A.createComponent(
                        "TVA_CFB:Docuvault_VersionUpload",
                        {
                            "aura:id" : "versionComp",
                            "parentID" : cloudFileId,
                            "refreshView" : true,
                            "selectedFileIndex" : 0
                        },
                        function (versionComp, status, errorMessage) {
                            if (status === "SUCCESS") {
                                var body = component.get("v.versionComponent");
                                body.push (versionComp);
                                component.set("v.versionComponent", body);
                                var modal = component.find('versionUploadModal');
                                $A.util.removeClass (modal, 'slds-hide');
                            }
                            else if (status === "INCOMPLETE") {
                            } 
                                else if (status === "ERROR") {
                                }
                        }
                    );
                } else {
                    helper.showToast(component, event, helper, 'Error', res); 
                }
            } else if(state == "ERROR"){
                component.set ('v.loading', false);
                alert('Error in calling server side action');
            }
        });
        
        $A.enqueueAction(action);
    },
    cancelCheckOutActn : function(component, event, helper){
        component.set ('v.loading', true);
        var action = component.get("c.cancelCheckOut2");
        action.setParams({
            nt : component.get("v.note"),
            "cloudFileId":component.get('v.CloudFileId')
        });
        action.setCallback(this, function(response){
            component.set ('v.loading', false);
            helper.docuvaultEvent (component, event, helper, false, true, true); 
            if (response.getReturnValue() == 'Success') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "Checkout cancelled successfully."
                });
                toastEvent.fire();
            } else {
                helper.showToast(component, event, helper, 'Error', response); 
            }
        });
        $A.enqueueAction(action);
    },
    
    checkinCloudFiles : function (component, event, helper){
        component.set ('v.loading', true);
        var cNote = component.get("v.note");
        var action = component.get("c.cloudFileCheckIn");
        action.setParams({
            nt : cNote,
            "cloudFileId":component.get('v.CloudFileId')
        });
        action.setCallback(this, function(response){
            component.set ('v.loading', false);
            helper.docuvaultEvent (component, event, helper, false, true, true);                  
        });
        $A.enqueueAction(action);
    }
})