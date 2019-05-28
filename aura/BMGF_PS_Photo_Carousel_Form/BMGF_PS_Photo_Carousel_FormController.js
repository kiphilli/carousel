({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        if ( null !== recordId ) {
            helper.loadRecord(component, helper);
        } else {
            component.set('v.resourceRecord', {});
        }
    },

    doRender: function(component, event, helper) {
        helper.getBrowserVersion(component, helper);
    },

    handleSubmit: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        var fields = component.get('v.resourceRecord');

        if (null === recordId ) {
            helper.createRecord(component, fields);
        } else {
            helper.updateRecord(component, recordId, fields);
        }
    },

    returnToList: function(component, event, helper) {
        var evt = component.getEvent('cmpMessage');
        evt.setParams({
            id: 'cancel'
        });
        evt.fire();
    }
})