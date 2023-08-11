({
	doInit : function(component, event, helper) {
		helper.fetchAllQueues(component, event, helper);	
	},
    
    getSelectedQueueDetails: function(component, event, helper) {
        component.set('v.isLoading', true);
        
        var selectedItem = event.currentTarget;
        var recId = selectedItem.dataset.record;
        var recName = selectedItem.dataset.queuename;
        
        component.set('v.chosenQueueId', recId);
        component.set('v.chosenQueueName', recName);
        
        helper.fetchDataTableValues(component, event, helper);
    },
    
    updateAssignSelectedText: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        cmp.set('v.AssignUserSelectedRowsCount', selectedRows.length);
        cmp.set('v.assignUserList', selectedRows);
    },
    
    updateRemoveSelectedText: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        cmp.set('v.RemoveUserSelectedRowsCount', selectedRows.length);
        cmp.set('v.removeUserList', selectedRows);
    },
    
    backToHomePage: function(component, event, helper) {
        component.set('v.chosenQueueId', '');
        component.set('v.chosenQueueName', '');
    },
    
    assignUsers: function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.assignUsersToTheQueue(component, event, helper);
    },
    
    removeAssignedUsers: function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.removeAssignedUsersFromQueue(component, event, helper);
    }
})