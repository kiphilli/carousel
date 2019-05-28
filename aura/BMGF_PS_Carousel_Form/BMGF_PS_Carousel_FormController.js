({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        if ( null !== recordId ) {
            helper.loadRecord(component, helper);
        } else {
            component.set('v.resourceRecord', {});
        }

        var action = component.get('c.getDocumentUrl');

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var docs = JSON.parse(response.getReturnValue());
                component.set('v.videoEmbedDocUrl', docs.Video_Embed__c);
            } else {
                var evt = $A.get("e.c:BMGF_evtPostMessage"),
                    errors = response.getError(),
                    errorMsg = errors && errors[0] && errors[0].message ? errors[0].message : '';

                evt.setParams({
                    title: 'Error',
                    message: errorMsg,
                    type: 'error',
                    mode: 'sticky'
                });

                evt.fire();
            }
        });

        $A.enqueueAction(action);
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