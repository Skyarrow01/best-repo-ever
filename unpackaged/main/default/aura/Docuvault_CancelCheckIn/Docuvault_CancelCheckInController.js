({
	doInit : function(component, event, helper) {
        
        var cloudFileId = component.get('v.recordId');
        var cloudId = component.get('v.CloudFileId');
        var isFromRecord = component.get ('v.isFromRecord');
        if (!$A.util.isUndefined (cloudId) && !$A.util.isEmpty (cloudId)) {
            cloudFileId = cloudId;
            isFromRecord = false;
            component.set ('v.isFromRecord', false);
            window.setTimeout( function() {
                helper.docuvaultEvent (component, event, helper, true, false, false);
            }, 500);
        }
        var pAction = component.get("c.getProfileName");
        pAction.setCallback(this, function(pRes){
            
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
                    if (pRes.getReturnValue() != 'System Administrator' && !$A.util.isEmpty (checkOutUserId) && !$A.util.isUndefined (checkOutUserId)  && res.TVA_CFB__Office_File_Last_Modified_By__c != loggedInUserId) {
                        component.set ('v.showComponent', false);
                        component.set ('v.loading', false);
                        
                        if (!isFromRecord) {
                            helper.docuvaultEvent (component, event, helper, false, true, false);
                        } else {
                            var dismissActionPanel = $A.get("e.force:closeQuickAction");
                            dismissActionPanel.fire();
                        }
                        helper.showToast(component, event, helper, 'Error', 'Document is locked by '+checkOutUser
                                         +'. Please wait till they checkin.'); 
                        
                    } else {
                        
                        if (res.Locked__c == true) {
                            component.set ('v.showComponent', true);
                            component.set ('v.loading', false);
                        } else {
                            component.set ('v.showComponent', false);
                            component.set ('v.loading', false);
                            if (!isFromRecord) {
                                helper.docuvaultEvent (component, event, helper, false, true, false);
                            } else {
                                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                dismissActionPanel.fire();
                            }
                            helper.showToast(component, event, helper, 'Error', 'Document is not locked, not available for Checkin'); 
                            
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        });
        $A.enqueueAction(pAction);
	},
    cancelCheckOutActn : function(component, event, helper){
        component.set ('v.loading', true);
        var isFromRecord = component.get ('v.isFromRecord');
        var cloudFileId = component.get('v.recordId');
        var cloudId = component.get('v.CloudFileId');
        if (!$A.util.isUndefined (cloudId) && !$A.util.isEmpty (cloudId)) {
            cloudFileId = cloudId;
        }
        var action = component.get("c.cancelCheckOut2");
        action.setParams({
            nt : component.get("v.note"),
            "cloudFileId": cloudFileId
        });
        action.setCallback(this, function(response){
            component.set ('v.loading', false);
            if (response.getReturnValue() == 'Success') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "Checkout cancelled successfully."
                });
                toastEvent.fire();
                if (!isFromRecord) {
                    helper.docuvaultEvent (component, event, helper, false, true, true); 
                } else {
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
            } else {
                helper.showToast(component, event, helper, 'Error', response); 
            }
        });
        $A.enqueueAction(action);
    }
})