({
    redirectToEditPage : function(component, event, helper) {
        /*var editRecordEvent = $A.get("e.force:editRecord");
        console.log('caseId'+component.get("v.caseId"));
        editRecordEvent.setParams({
            "recordId": component.get("v.caseId")
        });
        editRecordEvent.fire();*/
        var parentId = component.get('v.originalCaseId') != '' ? component.get('v.originalCaseId') : null;
        var partNumber = component.get('v.partNumber') != '' ? component.get('v.partNumber') : null;
        var product = component.get('v.product') != '' ? component.get('v.product') : null;
        var createBacklineCase = $A.get("e.force:createRecord");
        createBacklineCase.setParams({
            "entityApiName": "Case",
            'recordTypeId' : component.get('v.recordTypeId'),
            "defaultFieldValues": {
                'Agency_Approval_Case__c' : component.get('v.agencyApproval'),
                'Description' : component.get('v.description'),
                'ParentId' : parentId,
                'Part_Number__c' : partNumber,
                'Product__c' : product,
                'Silo__c' : component.get('v.silo'),
                'Subject' : component.get('v.subject')
            }
        });
        createBacklineCase.fire();
    }
})