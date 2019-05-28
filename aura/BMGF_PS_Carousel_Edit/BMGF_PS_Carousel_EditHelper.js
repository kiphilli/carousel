({
    editRow: function (component, helper, row) {
        var rowIndex = helper.getRowIndex(component, row.Id);
        component.set('v.currentRecordImageUrl', component.get('v.rawData')[rowIndex].imgUrl);
        component.set('v.currentRecord', row);
        component.set('v.uploadedFileName', '');
        component.set('v.editFields', true);

        if ( 'Video' === component.get('v.carouselType') ) {
            component.set('v.editImage', false);
        } else {
            component.set('v.editImage', true);
        }

        helper.renderForm(component, helper);
    },

    renderForm: function(component, helper) {
        var resourceType = component.get('v.carouselType');
        var recordId = component.get('v.recordId');
        var psGroupId = component.get('v.psGroupId');
        var saveButtonLabel = null !== recordId ? 'Save' : 'Next';
        var typeMap = {
            Default: 'BMGF_PS_Carousel_Form',
            Photo: 'BMGF_PS_Photo_Carousel_Form',
            Video: 'BMGF_PS_Video_Carousel_Form',
            Resource: 'BMGF_PS_Resource_Form'
        };

        $A.createComponent('c:' + typeMap[resourceType], {
            recordId: recordId,
            psGroupId: psGroupId,
            saveButtonLabel: saveButtonLabel,
        }, function(newComponent, status) {
            if (status === "SUCCESS") {
                component.set('v.recordFormComponent', newComponent);
                component.set('v.isEditing', true);
            }
        });
    },

    createRow: function(component, helper) {
        component.set('v.mode', 'create');
        component.set('v.currentRecord', null);
        component.set('v.uploadedFileName', '');
        component.set('v.editImage', false);
        component.set('v.editFields', true);

        helper.renderForm(component, helper);
    },

    deleteRow: function(component, helper) {
        var row = component.get('v.rowToDelete'),
            rowIndex = component.get('v.data').indexOf(row),
            recordId = component.get('v.rawData')[rowIndex].id;

        var action = component.get('c.deleteResource');
        var params = {
            'recordId': recordId
        };

        action.setParams(params);

        action.setCallback(this, function(response) {
            var state = response.getState();
            var evt = $A.get("e.c:BMGF_evtPostMessage");

            if (state === "SUCCESS") {
                evt.setParams({
                    title: 'Success!',
                    message: 'The record has been deleted successfully.',
                    type: 'success',
                    duration: 1000
                });

                helper.loadRows(component);
                helper.refreshPageComponent(component, rowIndex);
            } else {
                var errors = response.getError(),
                    errorMsg = errors && errors[0] && errors[0].message ? errors[0].message : '';

                evt.setParams({
                    title: 'Error',
                    message: errorMsg,
                    type: 'error',
                    mode: 'sticky'
                });
            }
            evt.fire();
        });

        $A.enqueueAction(action);
    },

    handleDeleteRow: function(component, helper, row) {
        component.set('v.rowToDelete', row);

        $A.createComponent('c:ConfirmPrompt', {
                msg: component.getReference('c.handlePromptMessage'),
                title: 'Delete Slide',
                bodyContent: 'Are you sure you want to delete this Slide?'
            },
            function(content, status) {
                if (status === "SUCCESS") {
                    component.set('v.overlay', component.find('overlayLib').showCustomModal({
                        body: content
                    }));
                }
            }
        );
    },

    getRowIndex: function(component, id) {
        var rows = component.get('v.data');

        for( var i = 0, z = rows.length; i < z; i++ ) {
            if( id === rows[i].Id ) {
                return i;
            }
        }
    },

    updatePhoto: function(component, helper, fileId) {
        var action = component.get('c.updatePhoto'),
            recordId = component.get('v.currentRecord').Id;

        var params = {
            'recordId': recordId,
            'fileId': fileId
        };

        action.setParams(params);

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //update row attributes so the image is updated realtime to the user
                var imgUrl = response.getReturnValue();
                var rawData = component.get('v.rawData');
                var rowIndex = helper.getRowIndex(component, recordId);
                component.set('v.currentRecordImageUrl', imgUrl);
                rawData[rowIndex].imgUrl = imgUrl;
                component.set('v.rawData', rawData);
                $A.util.toggleClass(component.find('spinner'), 'slds-hidden');
                helper.refreshPageComponent(component);
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

    loadRows: function(component) {
        var action = component.get('c.getRecords');
        action.setParams({
            records: component.get('v.recordIdList')
        });

        action.setCallback(this, function(val) {
            var state = val.getState();
            var ret = val.getReturnValue();

            if ( state === 'SUCCESS' ) {

                var parsedReply = JSON.parse(ret);
                var resources = [];
                parsedReply.forEach(function(item) {
                    resources.push(item.resource);
                });

                component.set('v.rawData', parsedReply);
                component.set('v.data', resources);
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

    refreshPageComponent: function(component, rowIndex) {
        var evt = $A.get("e.c:BMGF_evtComponentRefresh");
        evt.setParams({
            componentName: component.get('v.originId')
        });
        evt.fire();
    }
})