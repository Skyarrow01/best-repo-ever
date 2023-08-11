({
    
    fetchAllQueues : function(component, event, helper) {
        // call the apex class method 
        var action = component.get("c.fetchQueue");
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('storeResponse'+JSON.stringify(storeResponse));
                // set searchResult list with return value from server.
                component.set("v.listOfAllQueues", storeResponse);
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    
    fetchDataTableValues : function(component, event, helper) {
        component.set('v.assignUserList', null);
        component.set('v.removeUserList', null);
        
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text'}
        ]);
        
        // call the apex class method 
        var action = component.get("c.fetchUsersNotAssignedToQueue");
        action.setParams({
            'queueId' : component.get('v.chosenQueueId')
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('storeResponse'+JSON.stringify(storeResponse));
                if(storeResponse.assignUserData) {
                    component.set("v.AssignUserData", storeResponse.assignUserData);
                }
                
                if(storeResponse.removeUserData) {
                    component.set("v.RemoveUserData", storeResponse.removeUserData);
                }
                
            }
            component.set('v.isLoading', false);
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    
    assignUsersToTheQueue: function(component, event, helper) {
        var action = component.get("c.handleAssignUsersToQueue");
        action.setParams({
            'userListObj' : JSON.stringify(component.get('v.assignUserList')),
            'queueId' :component.get('v.chosenQueueId')
        });
        
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.fetchDataTableValues(component, event, helper);
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    
    removeAssignedUsersFromQueue: function(component, event, helper) {
        var action = component.get("c.handleRemoveUsersToQueue");
        action.setParams({
            'userListObj' : JSON.stringify(component.get('v.removeUserList')),
            'queueId' :component.get('v.chosenQueueId')
        });
        
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.fetchDataTableValues(component, event, helper);
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    }
    
})