({
	showToast : function(component, event, helper,type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": message
        });
        toastEvent.fire();          
    },
    docuvaultEvent : function(component, event, helper, enableClose, closeModal, refreshParent) {
        var appEvent = $A.get("e.TVA_CFB:Docuvault_DynamicModalAction");
        appEvent.setParams({ 
            "isRecordAction" : true,
            "enableClose" : enableClose,
            "closeModal" : closeModal,
            "refreshParent" : refreshParent
        });
        appEvent.fire();
    }
})