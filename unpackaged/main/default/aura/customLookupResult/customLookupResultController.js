({
    selectProduct : function(component, event, helper){      
        // get the selected Account from list  
        var getSelectProduct = component.get("v.oProduct");
        // call the event   
        var compEvent = component.getEvent("oSelectedProductEvent");
        // set the Selected Account to the event attribute.  
        compEvent.setParams({"productByEvent" : getSelectProduct });  
        // fire the event  
        compEvent.fire();
    },
})