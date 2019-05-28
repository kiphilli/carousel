/**
 * Created by robert.truitt@Slalom on 3/1/2017.
 */
({
    doInit: function(component, event, helper) {
        helper.getProfile(component, helper);
    },

    /* i wanted to use salesforce preview viewer but the icon images don't include the community name so don't show */
    openResource : function(component, event, helper){
         $A.get('e.lightning:openFiles').fire({
                recordIds: [event.target.id]
            });
    },

    editResource: function(component, event, helper) {
        $A.util.toggleClass(component.find('spinner'), 'slds-hidden');
        helper.loadRecords(component);
    }
})