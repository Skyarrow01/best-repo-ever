({
	doInit : function(component, event, helper) {
        var action = component.get ('c.getProjectId');
        action.setParams ({
            "taskId" : component.get('v.recordId')
        });
        action.setCallback (this, function(response) {
            var projectId = response.getReturnValue();
            component.set ('v.projectId', projectId);
            $A.createComponent(
                "TVA_CFB:Docuvault_UploadFiles",
                {
                    "recordId": projectId,
                    "enableFolder" : true,
                    "FolderRequired" : true
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