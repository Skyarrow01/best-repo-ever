({
	getSelectedValue : function(component, event, helper) {
        var selectedVal = component.get ("v.selectedValue");
        var evt = $A.get("e.TVA_CFB:ChooseFoldersEvent");
        evt.setParams({ "folderName": selectedVal});
        evt.fire();
	},
    
    doInit : function(component, event, helper) {
       
        var recordID = component.get("v.recordId"); 
        component.set ('v.showSpinner', true);
        var action = component.get ('c.getProjectFolders');
        var type = component.get("v.type");
        action.setParams ({
            'taskId' : recordID,
            'type':type
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var folderresult = response.getReturnValue();
                var opts = [];
                for (var i=0; i < folderresult.length; i++ )
                    opts.push ({value: folderresult[i], label: folderresult[i]});
                component.set ("v.folders", opts);
                component.set ('v.showSpinner', false);
            }
        });
        $A.enqueueAction(action);
        component.set("v.selectedValue", "");
    }
})