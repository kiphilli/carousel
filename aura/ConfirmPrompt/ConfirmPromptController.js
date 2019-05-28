({
    cancel: function(component, event, helper) {
        var msgEvent = $A.get('e.c:evtMessage');
        msgEvent.setParams({
            message: 'cancel'
        });
        msgEvent.fire();
    },

    confirm: function(component, event, helper) {
        var msgEvent = $A.get('e.c:evtMessage');
        msgEvent.setParams({
            message: 'confirm'
        });
        msgEvent.fire();
    }
})