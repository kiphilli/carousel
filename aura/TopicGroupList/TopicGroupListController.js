({
    init: function(component, event, helper) {
        helper.getGroups(component, helper, component.get('v.recordId'));
    },

    navigateToRecord: function(component, event, helper) {
        var recordId = event.currentTarget.dataset.id;
        var navEvt = $A.get('e.force:navigateToSObject');
        navEvt.setParams({
            recordId: recordId
        });
        navEvt.fire();
    }
})