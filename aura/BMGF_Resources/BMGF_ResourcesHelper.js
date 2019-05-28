({
    getProfile: function(component, helper) {
        var action = component.get('c.getUserProfile');

        action.setCallback(this, function(val) {
            var state = val.getState();
            var ret = val.getReturnValue();

            if ( state === 'SUCCESS' ) {
                component.set('v.userProfile', ret);
                helper.initComponent(component, helper);
            } else {
                var toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({
                    title: 'Error',
                    message: 'An unexpected error happened. Please try reloading the page.',
                    type: 'error'
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    },

    initComponent: function(component) {
        var action = component.get("c.getResources");
        var isGroup = component.get("v.isGroupPage")=='true';
        action.setParams({
            recordId: component.get("v.recordId"),
            parentObjectName: component.get("v.parentObjectName"),
            childObjectName: component.get("v.childObjectName"),
            junctionObjectName: component.get("v.junctionObjectName"),
            parentRelationshipField: component.get("v.parentRelationField"),
            childRelationshipField: component.get("v.childRelationField"),
            parentSearchExpr: component.get("v.parentSearchExpr"),
            childSearchExpr: component.get("v.childSearchExpr"),
            junctionSearchExpr: component.get("v.junctionSearchExpr"),
            photoVideoUrlField: component.get("v.photoVideoUrlField"),
            descriptionField: component.get("v.descriptionField"),
            groupByFields: component.get("v.groupByFields"),
            orderBy: component.get("v.orderBy"),
            isGroupPage : isGroup,
            groupNameField : component.get("v.groupNameField")
        });
        action.setCallback(this, function(val) {

            var state = val.getState();

            if (state === "SUCCESS") {
                var resourceList = val.getReturnValue();
                var validResources = [];
                var resourceItemIds = [];
                var userProfile = component.get('v.userProfile');

                if (resourceList != null && resourceList.length > 0) {
                    resourceList.forEach(function(item) {
                        var excludedProfiles = item.hasOwnProperty('excludedProfiles') ? item.excludedProfiles.split(';'): [];

                        if ( item.display && excludedProfiles.indexOf(userProfile) === -1 ) {
                            validResources.push(item);
                        }
                        resourceItemIds.push(item.id);
                    });

                    component.set("v.resourceList", validResources);
                    component.set("v.resourceListSize", validResources.length);
                    component.set('v.recordIdList', resourceItemIds);

                    //call callback method if defined
                    var actionCallBack = component.get("v.callBackNotEmptyResources");
                    if (actionCallBack != null)
                        $A.enqueueAction(actionCallBack);

                } else {

                    //call callback method if defined
                    var actionCallBack = component.get("v.callBackEmptyResources");
                    if (actionCallBack != null)
                        $A.enqueueAction(actionCallBack);
                }

                var buttons = component.find('editButton');
                if ( buttons instanceof Array ) {
                    buttons.forEach(function(item) {
                        $A.util.removeClass(item, 'slds-hidden');
                    });
                } else {
                    $A.util.removeClass(buttons, 'slds-hidden');
                }



            } else if (state === "ERROR") {
                var errors = val.getError();
                var errMsg = '';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    loadRecords: function(component) {
        var action = component.get('c.getRecords');
        action.setParams({
            records: component.get('v.recordIdList')
        });

        action.setCallback(this, function(val) {
            var state = val.getState();
            var ret = val.getReturnValue();

            $A.util.toggleClass(component.find('spinner'), 'slds-hidden');

            if ( state === 'SUCCESS' ) {
                var cols = [
                    { label: 'Description', fieldName: 'Description__c', type: 'text', editable: false },
                    { label: 'Edit', type: 'button', initialWidth: 100,
                        typeAttributes: {
                            title: 'Click to Edit', name: 'edit', iconName: 'utility:edit'
                        }
                    },
                    { label: 'Delete', type: 'button', initialWidth: 100,
                        typeAttributes: {
                            title: 'Click to Delete', name: 'delete', iconName: 'utility:delete'
                        }
                    }
                ];

                var parsedReply = JSON.parse(ret);
                var resources = [];
                parsedReply.forEach(function(item) {
                    resources.push(item.resource);
                });

                $A.createComponent('c:BMGF_PS_Carousel_Edit', {
                        originId: component.get('v.originId'),
                        carouselType: component.get('v.carouselType'),
                        psGroupId: component.get('v.psGroupId'),
                        rawData: parsedReply,
                        data: resources,
                        columns: cols,
                        recordIdList: component.get('v.recordIdList')
                    },
                    function(component, status) {
                        if (status === "SUCCESS") {
                            component.set('v.overlay', component.find('overlayLib').showCustomModal({
                                header: 'Edit Resources',
                                body: component
                            }));
                        }
                    });
            } else {
                //TODO: setup PostMessage event e.g. GP Internal
                var toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({
                    title: 'Error',
                    message: 'An unexpected error happened. Please try reloading the page.',
                    type: 'error'
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    },
})