({
    init : function (component) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        
        var inputVariables = [
            { name : "varOriginalCaseId", type : "String", value: component.get('v.recordId') }
        ];
        
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("Create_Backline_Escalation_from_Case", inputVariables);
    },
    
    handleStatusChange : function (component, event, helper) {
        if(event.getParam("status") === "FINISHED") {
            // Get the output variables and iterate over them
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            console.log('outputVariables'+JSON.stringify(outputVariables));
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                console.log('output value'+outputVar.name);
                // Pass the values to the component's attributes
                if(outputVar.name === "caseId") {
                    component.set("v.caseId", outputVar.value);
                    //helper.redirectToEditPage(component, event, helper);
                }
                if(outputVar.name === "varAgencyApproval") {
                    component.set("v.agencyApproval", outputVar.value);
                }
                if(outputVar.name === "varOriginalCaseId") {
                    component.set("v.originalCaseId", outputVar.value);
                }
                if(outputVar.name === "varCaseRecord") {
                    component.set("v.partNumber", outputVar.value.Product__c);
                    component.set("v.product", outputVar.value.Product__c);
                    component.set("v.description", outputVar.value.Description);
                    component.set("v.subject", outputVar.value.Subject);
                }
                if(outputVar.name === "varGetCustomMetadata") {
                    component.set("v.recordTypeId", outputVar.value.Record_Type_Id__c);
                }
                if(outputVar.name === "varSiloRecord") {
                    component.set("v.silo", outputVar.value.Silo__c);
                }
                if(outputVar.name === "varSiloRecord") {
                    component.set("v.silo", outputVar.value.Silo__c);
                }
            }
            console.log('calling helper');
            helper.redirectToEditPage(component, event, helper);
            
        }
    },
})