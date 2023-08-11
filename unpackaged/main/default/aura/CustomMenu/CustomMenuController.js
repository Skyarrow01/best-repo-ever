({
    onClick : function(c, e, h) {    
        h.closeLeftNavMenu(c);
        
        var id = e.target.dataset.menuItemId;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": id
        });
        navEvt.fire(); 
    },
    
    doInit : function(component, event, helper) {
        helper.fetchSubtopicsInformation(component, event, helper);
        helper.fetchCurrentUserProfile(component, event, helper);
    },
    
    linkRedirect : function(component, event, helper) {
        helper.closeLeftNavMenu(component);
        
        var selectedItem = event.currentTarget;
        var url = selectedItem.dataset.link;
        console.log('url'+url);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": url
        });
        urlEvent.fire();
    },
    
    announcementRedirect :function(component, event, helper) {
        helper.closeLeftNavMenu(component);
        
        var selectedItem = event.currentTarget;
        var url = selectedItem.dataset.link;
        var recordId = selectedItem.dataset.recordid;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": url+'/?topic_id='+recordId
        });
        urlEvent.fire();
    },
    
    toggleNav : function(component, event, helper) {
        helper.displayLeftNavMenu(component);
    }
    
})