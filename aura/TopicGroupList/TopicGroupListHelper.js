({
    getGroups: function(component, helper, recordId) {
        var action = component.get('c.getGroupsForRecord');
        action.setParams({
            topicId: recordId
        });

        action.setCallback(this, function(response) {
            var state = response.getState(),
                payload = response.getReturnValue();

            if ( state === 'SUCCESS' ) {
                component.set('v.groups', payload);
                component.set('v.groupsLoaded', true);
            } else {
                var errors = response.getError(),
                    errorString = '';

                errors.forEach(function(item) {
                    errorString += item.message + '\n';
                });

                component.find('notificationLib').showToast({
                    title: 'Error',
                    message: errorString,
                    variant: 'error',
                    mode: 'sticky'
                });
            }
        });

        $A.enqueueAction(action);
    }
})