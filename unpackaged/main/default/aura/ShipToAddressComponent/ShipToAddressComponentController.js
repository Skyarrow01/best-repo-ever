({
    doInit: function(component, event, helper) {
      	var Id;
        console.log('recordId'+component.get('v.recordId'));
        if (component.get('v.recordId')) {
            Id = component.get('v.recordId');
        } else {
            
            var pageRef = component.get("v.pageReference");
            if (pageRef) {
                var state = pageRef.state; // state holds any query params
                var base64Context = state.inContextOfRef;
                
                if (base64Context.startsWith("1\.")) {
                    base64Context = base64Context.substring(2);
                }
                var addressableContext = JSON.parse(window.atob(base64Context));
                
                if (addressableContext.attributes.recordId) {
                    Id = addressableContext.attributes.recordId;
                }
            }
        }
        
        if (Id && Id.startsWith('001')) {
            component.set('v.parentAccountId', Id); 
        } else if(Id && Id.startsWith('003')) {
             component.set('v.parentContactId', Id);
        }
        
        helper.getContactRecord(component, event, helper, Id);
    },
    //Show the modal window on click in the input field
    OpenModal : function(component, event, helper) {
        component.set('v.AddressList', null);
        component.set("v.showModalBox", true);
    }, 
    //close the modal window on click of cancel button
    closeModal: function(component, event, helper) {
        component.set("v.showModalBox", false);
    },
    //On search of address get address list from the API
    keyPressController: function(component, event, helper) {
        helper.getAddressRecommendations(component,event);
    },
    //Get city, state, country and other details from selected address
    selectOption:function(component, event, helper) {
        helper.getAddressDetailsByPlaceId(component, event);
    },
    handleSave: function(component, event, helper) {
        console.log('save called');
    	component.find("recordViewForm").submit();
	},
    handleCancel: function(component, event, helper) {
        helper.closeCurrentTab(component, event, helper);
    },
    handleSubmit: function(component, event, helper) {
        component.set('v.showSpinner', true);
    },
    handleSuccess: function(component, event, helper) {
        var payload = event.getParams().response;	
		var workspaceAPI = component.find("workspace");
        
        var focusedTabId;
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            focusedTabId = response.tabId;
            
        }) .catch(function(error) {
            console.log(error);
        });
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": payload.id
        });
        navEvt.fire();
        component.set('v.showSpinner', false);
        
        setTimeout(function(){
            //close the subtab
        	workspaceAPI.closeTab({tabId: focusedTabId});
        }, 1000);
    },
    clear: function(component, event, helper) {
        component.set('v.searchKey', '');
        component.set('v.AddressList', null);
    }
})