/**
 * Created by robert.truitt@slalom.com on 2/6/2017.
 */
({
    doInit: function(c, event, helper) {
        helper.doInit(c, event, helper);
    },

    doRender: function(component, event, helper) {
        helper.attemptInitCarousel(component, event, helper);
    },

    doInitJS: function(c, event, helper) {
        $.noConflict(); if (typeof(window.$) === 'undefined') { window.$ = jQuery; }
        c.set('v.jsLoaded', true);
    },

    startCarousel : function(c, event, helper){
        helper.startCarousel(component);
    },

    editCarousel: function(component, event, helper) {
        $A.util.toggleClass(component.find('spinner'), 'slds-hidden');
        helper.loadRecords(component);
    },

    handleMouseEnter: function(component, event, helper) {
        $A.util.addClass(component, 'is_hover');
    },

    handleMouseLeave: function(component, event, helper) {
        $A.util.removeClass(component, 'is_hover');
    }
})