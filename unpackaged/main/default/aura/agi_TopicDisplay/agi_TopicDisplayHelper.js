({
	getList : function(component) {
        var action = component.get("c.getTopicListing");
        action.setParams({
            "topicId": component.get("v.recordId"),
            "filterVal": component.get("v.optFilter"),
            "sortVal": component.get("v.optSort"),
            "userId": component.get("v.CurrentUser")
        });
     
		action.setCallback(this, function(response) {
            var status = response.getState();
            if (response.getState() === "ERROR"){
                let errors = response.getError();
                console.log('error =' + errors[0].message);
            }
            
			var result = response.getReturnValue();
            if (result != null){
                component.set("v.topics", result.listings);
                component.set("v.pins", result.pins);
                component.set("v.canPin", result.canPin);
                component.set("v.nextPageToken", result.nextPage);
            }
        });
        
        $A.enqueueAction(action);
	},
    
    getMore: function(component) {
        var action = component.get("c.loadMore");
        action.setParams({
            "originalTL": JSON.stringify(component.get("v.topics")),
            "originalPins": JSON.stringify(component.get("v.pins")),
            "nextPageToken": component.get("v.nextPageToken"),
            "topicId": component.get("v.recordId"),
            "filterVal": component.get("v.optFilter"),
            "sortVal": component.get("v.optSort"),
            "userId": component.get("v.CurrentUser")
        });
     
		action.setCallback(this, function(response) {
            var status = response.getState();
            if (response.getState() === "ERROR"){
                let errors = response.getError();
                console.log('error =' + errors[0].message);
            }
            
			var result = response.getReturnValue();
            component.set("v.topics", result.listings);
            component.set("v.pins", result.pins);
            component.set("v.canPin", result.canPin);
            component.set("v.nextPageToken", result.nextPage);
        });
        
        $A.enqueueAction(action);        
    },
    
    pin : function(component, flag, id){
        var action = component.get("c.changePinning");
        action.setParams({
            "toPin": flag,
            "feedId": id,
            "topicId": component.get("v.recordId")
        });
     
		action.setCallback(this, function(response) {
            var status = response.getState();
            if (response.getState() === "ERROR"){
                let errors = response.getError();
                console.log('error =' + errors[0].message);
            }
        });
        
        $A.enqueueAction(action);
        
    }
})