({
    doInit: function(component, event, helper) {
        var action = component.get('c.getDocumentUrl');

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var docs =JSON.parse(response.getReturnValue());
                component.set('v.uploadDocumentUrl', docs.Image_Optimization__c);
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

    loadRecords: function(component) {
        var action = component.get('c.getRecords');
        action.setParams({
            records: component.get('v.recordIdList')
        });
    },

    handleRowAction: function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'edit':
                helper.editRow(component, helper, row);
                break;
            case 'delete':
                helper.handleDeleteRow(component, helper, row);
                break;
        }
    },

    handleNew: function(component, event, helper) {
        helper.createRow(component, helper);
    },

    returnToList: function(component, event, helper) {
        component.set('v.isEditing', false);
    },

    finalizeInsert: function(component, event, helper) {
        var evt = $A.get("e.c:BMGF_evtPostMessage");
        evt.setParams({
            title: 'Success!',
            message: 'The record has been created successfully.',
            type: 'success',
            duration: 1000
        });
        evt.fire();

        component.set('v.isEditing', false);
    },

    handleUploadFinished: function(component, event, helper) {
        var uploadedFiles = event.getParam('files');
        component.set('v.uploadedFileId', uploadedFiles[0].documentId);
        component.set('v.uploadedFileName', uploadedFiles[0].name);

        $A.util.toggleClass(component.find('spinner'), 'slds-hidden');

        helper.updatePhoto(component, helper, component.get('v.uploadedFileId'));
    },

    handlePromptMessage: function(component, event, helper) {
        var message = event.getParam('message');

        //close the prompt modal
        component.get('v.overlay').then(
            function (modal) {
                modal.close();
            }
        );

        if ('confirm' === message ) {
            helper.deleteRow(component, helper);
        }
    },

    handleMessage: function(component, event, helper) {
        var body = {},
            messageBody = event.getParam('body');

        if (typeof messageBody !== 'undefined' ) {
            body = JSON.parse(messageBody);
        }

        switch ( event.getParam('id') ) {
            case 'update':
                helper.loadRows(component);
                helper.refreshPageComponent(component);
                component.set('v.isEditing', false);

                var evt = $A.get("e.c:BMGF_evtPostMessage");
                evt.setParams({
                    title: 'Success!',
                    message: 'The record has been updated successfully.',
                    type: 'success',
                    duration: 1000
                });
                evt.fire();
                break;
            case 'insert':
                var recordIds = component.get('v.recordIdList');
                var record = JSON.parse(body.record);
                recordIds.push(record.Id);
                component.set('v.currentRecord', record);
                component.set('v.recordIdList', recordIds);
                component.set('v.currentRecordImageUrl', null);
                component.set('v.editFields', false);

                //skip image if type if video
                if ('Video' === component.get('v.carouselType') ) {
                    component.set('v.editImage', false);
                    component.set('v.isEditing', false);
                } else {
                    component.set('v.editImage', true);
                }

                helper.loadRows(component);
                helper.refreshPageComponent(component);
                break;
            case 'cancel':
                component.set('v.isEditing', false);
                break;
        }
    }
})