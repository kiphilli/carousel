({
    createComponent: function(component, helper) {
        if ('Resource' === component.get('v.carouselType') ) {
            helper.createResource(component, helper);

        } else {

            if ( 'true' == component.get("v.isGroupPage") ) {
                helper.createCarousel(component, helper);
            } else {
                helper.createHomeCarousel(component, helper);
            }

        }
    },

    getGroupName: function(component, helper) {
        var action = component.get('c.getPSGroupId');
        
        action.setParams({
            groupId: component.get('v.recordId')
        });

        action.setCallback(this, function(val) {
            var state = val.getState();
            var ret = val.getReturnValue();

            if ( state === 'SUCCESS' ) {
                component.set('v.psGroupId', ret);
                helper.getEditPermissions(component, helper, component.get('v.recordId'));
            } else {
                var evt = $A.get("e.c:BMGF_evtPostMessage");

                evt.setParams({
                    title: 'Error',
                    message: 'Failed to get group name',
                    type: 'error',
                    mode: 'sticky'
                });

                evt.fire();
            }
        });

        $A.enqueueAction(action);
    },

    getEditPermissions: function(component, helper, recordId) {
        var action = component.get('c.getEditPermission');
        
        action.setParams({
            groupId: recordId,
            profileNames: component.get('v.editProfiles').split(',')
        });

        action.setCallback(this, function(val) {
            var state = val.getState();
            var ret = val.getReturnValue();

            if ( state === 'SUCCESS' ) {
                component.set('v.canEdit', ret);
                helper.createComponent(component, helper);
            } else {
                var evt = $A.get("e.c:BMGF_evtPostMessage");

                evt.setParams({
                    title: 'Error',
                    message: 'Failed to get edit permissions',
                    type: 'error',
                    mode: 'sticky'
                });

                evt.fire();
            }
        });

        $A.enqueueAction(action);
    },

    createHomeCarousel: function(component, helper) {
        var params = {
            parentSearchSpec: component.get('v.parentSearchExpr'),
            searchSpec: component.get('v.childSearchExpr'),
            canEdit: component.get('v.canEdit'),
            originId: component.getGlobalId(),
            psGroupId: component.get('v.psGroupId')
        };

        $A.createComponent('c:Home_Carousel', params, function(content, status, statusMessageList) {
            if (status === "SUCCESS") {
                component.set('v.body', content);
            } else {
                var evt = $A.get("e.c:BMGF_evtPostMessage");

                evt.setParams({
                    title: 'Error',
                    message: statusMessageList,
                    type: 'error',
                    mode: 'sticky'
                });

                evt.fire();
            }
        });
    },

    createCarousel: function(component, helper) {
        var params = {
            recordId: component.get('v.recordId'),
            carouselType: component.get('v.carouselType'),
            originId: component.getGlobalId(),
            Title: component.get('v.Title'),
            parentObjectName: component.get('v.parentObjectName'),
            childObjectName: component.get('v.childObjectName'),
            junctionObjectName: component.get('v.junctionObjectName'),
            parentRelationField: component.get('v.parentRelationField'),
            childRelationField: component.get('v.childRelationField'),
            linkField: component.get('v.linkField'),
            imageField: component.get('v.imageField'),
            orderBy: component.get('v.orderBy'),
            parentSearchExpr: component.get('v.parentSearchExpr'),
            childSearchExpr: component.get('v.childSearchExpr'),
            junctionSearchExpr: component.get('v.junctionSearchExpr'),
            captionField: component.get('v.captionField'),
            captionLocation: component.get('v.captionLocation'),
            captionAlign: component.get('v.captionAlign'),
            arrowLocation: component.get('v.arrowLocation'),
            slidesToShow: component.get('v.slidesToShow'),
            slidesToScroll: component.get('v.slidesToScroll'),
            noPadding: component.get('v.noPadding'),
            showDots: component.get('v.showDots'),
            imageHeight: component.get('v.imageHeight'),
            imageWidth: component.get('v.imageWidth'),
            isGroupPage: component.get('v.isGroupPage'),
            groupNameField: component.get('v.groupNameField'),
            enableLightBox: component.get('v.enableLightBox'),
            autoPlayInterval: component.get('v.autoPlayInterval'),
            isVideoField: component.get('v.isVideoField'),
            isEmbeddedField: component.get('v.isEmbeddedField'),
            editButtonLabel: component.get('v.editButtonLabel'),
            psGroupId: component.get('v.psGroupId'),
            canEdit: component.get('v.canEdit')
        };

            $A.createComponent('c:Carousel', params, function(content, status, statusMessageList) {
            if (status === "SUCCESS") {
                component.set('v.body', content);
            } else {
                var evt = $A.get("e.c:BMGF_evtPostMessage");

                evt.setParams({
                    title: 'Error',
                    message: statusMessageList,
                    type: 'error',
                    mode: 'sticky'
                });

                evt.fire();
            }

        });
    },

    createResource: function(component, helper) {

        var params = {
            recordId: component.get('v.recordId'),
            carouselType: component.get('v.carouselType'),
            originId: component.getGlobalId(),
            Title: component.get('v.Title'),
            parentObjectName: component.get('v.parentObjectName'),
            childObjectName: component.get('v.childObjectName'),
            junctionObjectName: component.get('v.junctionObjectName'),
            parentRelationField: component.get('v.parentRelationField'),
            childRelationField: component.get('v.childRelationField'),
            orderBy: component.get('v.orderBy'),
            parentSearchExpr: component.get('v.parentSearchExpr'),
            childSearchExpr: component.get('v.childSearchExpr'),
            junctionSearchExpr: component.get('v.junctionSearchExpr'),
            editButtonLabel: component.get('v.editButtonLabel'),
            photoVideoUrlField: component.get('v.photoVideoUrlField'),
            descriptionField: component.get('v.descriptionField'),
            groupByFields: component.get('v.groupByFields'),
            isGroupPage: component.get('v.isGroupPage'),
            groupNameField: component.get('v.groupNameField'),
            isPhotoDisplay: component.get('v.isPhotoDisplay'),
            psGroupId: component.get('v.psGroupId'),
            canEdit: component.get('v.canEdit')
        };

        $A.createComponent('c:BMGF_Resources', params, function(content, status, statusMessageList) {
            if (status === "SUCCESS") {
                component.set('v.body', content);
            } else {
                var evt = $A.get("e.c:BMGF_evtPostMessage");

                evt.setParams({
                    title: 'Error',
                    message: statusMessageList,
                    type: 'error',
                    mode: 'sticky'
                });

                evt.fire();
            }

        });
    }
})