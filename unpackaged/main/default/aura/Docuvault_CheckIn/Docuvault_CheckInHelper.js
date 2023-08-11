({
	docuvaultEvent : function(component, event, helper, enableClose, closeModal, refreshParent) {
        try {
            var appEvent = $A.get("e.TVA_CFB:Docuvault_DynamicModalAction");
            if (!$A.util.isUndefined (appEvent)) {
                appEvent.setParams({ 
                    "isRecordAction" : true,
                    "enableClose" : enableClose,
                    "closeModal" : closeModal,
                    "refreshParent" : refreshParent
                });
                appEvent.fire();
            }
        }catch (e) {}
    },
    showToast : function(component, event, helper,type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": message
        });
        toastEvent.fire();          
    },
    getDocumentFromOffice : function (component, event, helper, cloudFileId) {
        var action = component.get("c.getUpdatedDocument");  
        action.setParams({
            "cloudFileId":cloudFileId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            helper.docuvaultEvent (component, event, helper, false, true, true);
            if(result == $A.get ('$Label.TVA_CFB.This_Document_is_not_uploaded_for_editing'))
            {
                helper.showToast (component, event, helper, 'Error', result);
            } else if(result == $A.get ('$Label.TVA_CFB.We_are_getting_the_Document_Please_wait'))
            {
                helper.showToast (component, event, helper, 'Success',result); 
            }
            else
            {
                helper.showToast (component, event, helper, 'success', 'Checkin completed. We are fetching the new version please wait.'); 
            }
            
        });
        $A.enqueueAction(action);
        
    }
})