({
	oninit : function(component, event, helper) {
		let action = component.get("c.navigateToCreditForm");
        
        action.setParams({
            recId:component.get("v.recordId")
            
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                let showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    title:'',
                    type: 'success',
                    mode: 'dismissible',
                    message: 'Mail Sent'
                });
                showToast.fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }else{
                let showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    title:'',
                    type: 'error',
                    mode: 'dismissible',
                    message: 'Failed to send the mail'
                });
                showToast.fire();
            }
        });
        $A.enqueueAction(action);
	}
})