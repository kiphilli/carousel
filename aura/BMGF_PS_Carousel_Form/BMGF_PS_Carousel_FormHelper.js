({
    createRecord: function(component, fields) {
        var record = {
            Carousel_Caption__c: fields.Carousel_Caption__c,
            Carousel_Description__c: fields.Carousel_Description__c,
            External_URL__c: fields.External_URL__c,
            Feature_Carousel_Sort_Order__c: fields.Feature_Carousel_Sort_Order__c,
            Expiration_Date__c: fields.Expiration_Date__c,
            Start_Date__c: fields.Start_Date__c
        };

        //set default values
        record.Type__c = 'Feature Carousel';
        record.PS_Group__c = component.get('v.psGroupId');

        var action = component.get('c.createResource');
        var params = {
            record: JSON.stringify(record)
        };

        action.setParams(params);

        action.setCallback(this, function(response) {
            var evt;
            if (response.getState() === 'SUCCESS') {
                evt = component.getEvent('cmpMessage');
                evt.setParams({
                    id: 'insert',
                    body: JSON.stringify({record: response.getReturnValue()})
                });
            } else {
                evt = $A.get("e.c:BMGF_evtPostMessage");

                var errors = response.getError(),
                    errorMsg;
                if ( errors.length > 0 ) {
                    var error = errors[0];
                    if (error.pageErrors.length > 0 ) {
                        errorMsg = error.pageErrors[0].message;
                    } else {
                        errorMsg = errors[0].message;
                    }
                } else {
                    errorMsg = 'Failed to create carousel slide.';
                }

                evt.setParams({
                    title: 'Error',
                    message: errorMsg,
                    type: 'error',
                    mode: 'dismissible'
                });
            }
            evt.fire();
        });

        $A.enqueueAction(action);
    },

    updateRecord: function(component, recordId, fields) {
        var record = {
            Id: recordId,
            Carousel_Caption__c: fields.Carousel_Caption__c,
            Carousel_Description__c: fields.Carousel_Description__c,
            External_URL__c: fields.External_URL__c,
            Feature_Carousel_Sort_Order__c: fields.Feature_Carousel_Sort_Order__c,
            Expiration_Date__c: fields.Expiration_Date__c,
            Start_Date__c: fields.Start_Date__c
        };

        var action = component.get('c.updateResource');
        var params = {
            record: JSON.stringify(record)
        };

        action.setParams(params);

        action.setCallback(this, function(response) {
            var evt;
            if (response.getState() === 'SUCCESS') {
                evt = component.getEvent('cmpMessage');
                evt.setParams({
                    id: 'update',
                    body: JSON.stringify({recordId: recordId})
                });
            } else {
                evt = $A.get("e.c:BMGF_evtPostMessage");

                var errors = response.getError(),
                    errorMsg;
                if ( errors.length > 0 ) {
                    var error = errors[0];
                    if (error.pageErrors.length > 0 ) {
                        errorMsg = error.pageErrors[0].message;
                    } else {
                        errorMsg = errors[0].message;
                    }
                } else {
                    errorMsg = 'Failed to create carousel slide.';
                }

                evt.setParams({
                    title: 'Error',
                    message: errorMsg,
                    type: 'error',
                    mode: 'dismissible'
                });
            }
            evt.fire();
        });

        $A.enqueueAction(action);
    },

    getBrowserVersion: function(component, helper) {
        var action = component.get('c.getBrowserVersion');
        action.setStorable();

        action.setCallback(this, function(val) {
            var state = val.getState();
            var ret = val.getReturnValue();

            if ( state === 'SUCCESS' ) {
                $A.util.addClass(component, ret);
            } else {
                var evt = $A.get("e.c:BMGF_evtPostMessage");

                evt.setParams({
                    title: 'Error',
                    message: 'Failed to get browser version',
                    type: 'error',
                    mode: 'sticky'
                });

                evt.fire();
            }
        });

        $A.enqueueAction(action);
    },

    loadRecord: function(component, event, helper) {
        var action = component.get('c.getRecord');
        action.setParams({
            recordId: component.get('v.recordId')
        });

        action.setCallback(this, function(val) {
            var state = val.getState();
            var ret = val.getReturnValue();

            if ( state === 'SUCCESS' ) {
                component.set('v.resourceRecord', JSON.parse(ret));
            } else {
                var evt = $A.get("e.c:BMGF_evtPostMessage");

                evt.setParams({
                    title: 'Error',
                    message: 'Failed to load record',
                    type: 'error',
                    mode: 'sticky'
                });

                evt.fire();
            }
        });

        $A.enqueueAction(action);
    }
})