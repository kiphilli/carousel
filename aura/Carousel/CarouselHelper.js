/**
 * Created by Robert on 12/11/2017.
 */
({
    doInit: function(c, event, helper) {
        var action = c.get("c.getCarouselItems");
        var isGroup = c.get("v.isGroupPage") == 'true';

        action.setParams({
            recordId: c.get("v.recordId"),
            parentObjectName: c.get("v.parentObjectName"),
            childObjectName: c.get("v.childObjectName"),
            junctionObjectName: c.get("v.junctionObjectName"),
            parentRelationshipField: c.get("v.parentRelationField"),
            childRelationshipField: c.get("v.childRelationField"),
            imageField: c.get("v.imageField"),
            parentSearchExpr: c.get("v.parentSearchExpr"),
            childSearchExpr: c.get("v.childSearchExpr"),
            junctionSearchExpr: c.get("v.junctionSearchExpr"),
            captionField: c.get("v.captionField"),
            linkField: c.get("v.linkField"),
            orderBy: c.get("v.orderBy"),
            isGroupPage: isGroup,
            groupNameField: c.get("v.groupNameField"),
            isVideoField: c.get("v.isVideoField"),
            isEmbeddedField: c.get("v.isEmbeddedField")
        });

        action.setCallback(this, function(val) {
            var state = val.getState();

            if (state === "SUCCESS") {
                var carouselContainer = val.getReturnValue();
                if (carouselContainer.carouselParentItems != null && carouselContainer.carouselParentItems.length > 0) {
                    var carouselItems = [];
                    var carouselItemIds = [];
                    carouselContainer.carouselParentItems.forEach(function(parItem) {
                        parItem.carouselItems.forEach(function(item) {
                            if (false === item.isExpired && item.hasOwnProperty('assetUrl') ) {
                                carouselItems.push(item);
                            }

                            carouselItemIds.push(item.id);
                        });
                    });
                    c.set('v.recordIdList', carouselItemIds);
                    c.set("v.carouselItems", carouselItems);

                    var emptyEvent = c.getEvent("emptyCarousel");
                    emptyEvent.setParams({
                        "isCarouselEmpty": false
                    });
                    emptyEvent.fire();

                    //call callback method if defined
                    var actionCallBack = c.get("v.callBackNotEmptyCarousel");
                    if (actionCallBack != null)
                        $A.enqueueAction(actionCallBack);

                } else {
                    var carouselContainer = c.find('cc');
                    $A.util.addClass(carouselContainer, 'slds-hide');

                    //register event
                    var emptyEvent = c.getEvent("emptyCarousel");
                    emptyEvent.setParams({
                        "isCarouselEmpty": true
                    });
                    emptyEvent.fire();

                    //call callback method if defined
                    var actionCallBack = c.get("v.callBackEmptyCarousel");
                    if (actionCallBack != null)
                        $A.enqueueAction(actionCallBack);
                }

                c.set('v.slidesLoaded', true);

                var buttons = c.find('editButton');
                if ( buttons instanceof Array ) {
                    buttons.forEach(function(item) {
                        $A.util.removeClass(item, 'slds-hidden');
                    });
                } else {
                    $A.util.removeClass(buttons, 'slds-hidden');
                }
            }

        });

        $A.enqueueAction(action);
    },

    startCarousel: function(component) {
        component.set('v.slickLoaded', true);
        var ccItems = component.get("v.carouselItems");

        if (!$A.util.isEmpty(ccItems)) {
            var swiperOptions = {};
            var slidesToShow = component.get("v.slidesToShow");

            if (ccItems.length>1)
            {
                if(slidesToShow>1) {
                    swiperOptions.slidesPerView = slidesToShow;
                    swiperOptions.spaceBetween = 5;
                }
                swiperOptions.navigation = {
                    nextEl: component.find('nextBtn').getElement(),
                    prevEl: component.find('prevBtn').getElement(),
                };
                swiperOptions.pagination = {
                    el: component.find('navDots').getElement(),
                    clickable: true,
                    renderBullet: function(index, className) {
                        return '<span class="' + className + '"></span>';
                    }
                };
                var autoPlayInterval = component.get("v.autoPlayInterval");
                if (!$A.util.isEmpty(autoPlayInterval)) swiperOptions.autoplay = {
                    delay: autoPlayInterval
                };
            }

            new Swiper(component.find('carouselContainer').getElement(), swiperOptions);
        }
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
                    { label: 'Header', fieldName: 'Carousel_Caption__c', type: 'text', editable: false },
                    { label: 'Inactive', fieldName: 'Is_Expired__c', type: 'boolean', editable: false },
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
                            header: 'Edit Carousel',
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

    attemptInitCarousel: function(component, event, helper) {
        var jsLoaded = component.get('v.jsLoaded'),
            slidesLoaded = component.get('v.slidesLoaded'),
            slickLoaded = component.get('v.slickLoaded');

        if ( jsLoaded && slidesLoaded && !slickLoaded ) {
            helper.startCarousel(component);
        }
    }
})