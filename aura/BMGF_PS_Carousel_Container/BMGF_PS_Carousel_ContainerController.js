({
    doInit: function(component, event, helper) {
        //dynamically create Carousel component
        var isGroup = component.get("v.isGroupPage") == 'true';

        if ( isGroup ) {
            helper.getGroupName(component, helper);
        } else {
            component.set('v.psGroupId', component.get('v.recordId'));
            helper.getEditPermissions(component, helper);
        }
    },

    handleRefresh: function(component, event, helper) {
        var target = event.getParam('componentName');
        var componentName = component.getGlobalId();

        if ( target === componentName ) {
            helper.createComponent(component, helper);
        }
    },
})