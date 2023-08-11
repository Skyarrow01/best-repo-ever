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
                component.set ('v.fileType', res.TVA_CFB__File_Type__c.toLowerCase());
                if (res.Locked__c == false) {
                    component.set ('v.showComponent', true);
                    component.set ('v.loading', false);
                } else {
                    component.set ('v.showComponent', false);
                    component.set ('v.loading', false);
                    helper.docuvaultEvent (component, event, helper, false, true, true);
                    helper.showToast(component, event, helper, 'Error', 'This document is locked, not available for Checkout'); 
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    download : function(component, event, helper) {
        component.set ('v.loading', true);
        var cloudFileId = component.get("v.CloudFileId");
        var cNote = component.get("v.note");
        var action = component.get("c.checkOut");
        action.setParams({
            nt : cNote,
            cloudFileId : cloudFileId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                component.set ('v.loading', false); 
                var res = response.getReturnValue();
                if (res.indexOf('success') > -1) {
                    helper.docuvaultEvent (component, event, helper, false, true, true);
                    res = res.replace ('success-','');
                    window.open (res);
                    
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
    editOnline : function(component, event, helper) {
        component.set ('v.loading', true);
        var cloudFileId = component.get("v.CloudFileId");
        var cNote = component.get("v.note");
        var action = component.get("c.checkOut");
        action.setParams({
            nt : cNote,
            cloudFileId : cloudFileId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                component.set ('v.loading', false); 
                var res = response.getReturnValue();
                if (res.indexOf('success') > -1) {
                    helper.docuvaultEvent (component, event, helper, false, true, true);

                    window.open ('/apex/TVA_CFB__Office_Login?state='+cloudFileId);
                } else {
                    helper.showToast(component, event, helper, 'Error', res); 
                }
            } else if(state == "ERROR"){
                component.set ('v.loading', false);
                alert('Error in calling server side action');
            }
        });
               
        $A.enqueueAction(action);
    }
})