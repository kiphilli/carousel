/**
 * @author anthony.beran@slalom.com
 * @date 6/20/18
 * @version 1.0
 * @description CarouselHelper helper class for PS_Group_Resource__c edit functionality
 */

public with sharing class CarouselHelper {

    /**
     * @author anthony.beran@slalom.com
     * @date 07/05/18
     * @version 1.0
     * @description Returns list of decorator objects for PS_Group_Resource__c
     *
     * @param records
     *
     * @return List<CarouselHelper.slideDecorator>
     */
    public static List<CarouselHelper.slideDecorator> getRecords(List<Id> records) {
        List<PS_Group_Resource__c> resources = new List<PS_Group_Resource__c>();
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();

        resources = [
            SELECT Carousel_Caption__c, Carousel_Description__c, Expiration_Date__c, External_URL__c, Feature_Carousel_Sort_Order__c, Slider_Url_c__c, Is_Expired__c, Description__c, Resource_Grouping_Name__c
            FROM PS_Group_Resource__c
            WHERE Id IN :records
            ORDER BY Feature_Carousel_Sort_Order__c ASC
        ];

        //test
        if ( !records.isEmpty() ) {
            contentDocumentLinks = [
                SELECT LinkedEntityId, ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :records
            ];
        }


        Map<Id, CarouselHelper.slideDecorator> slides = new Map<Id, CarouselHelper.slideDecorator>();
        for ( PS_Group_Resource__c r : resources ) {
            slides.put(r.Id, new CarouselHelper.slideDecorator(r));
        }

        for ( ContentDocumentLink c : contentDocumentLinks ) {
            if ( null != c.LinkedEntityId ) {
                String url = CommunityHelper.getSiteUrl() + BMGF_Resource_Helper.FILE_URL_PREFIX + c.ContentDocument.LatestPublishedVersionId;
                slides.get(c.LinkedEntityId).setImgUrl(url);
                break;
            }
        }

        return slides.values();
    }

    @TestVisible
    private class slideDecorator {
        PS_Group_Resource__c resource;
        public Id id;
        public String caption;
        public String description;
        public Date expiration;
        public String externalUrl;
        public Decimal sortOrder;
        public String url;
        public String imgUrl;
        public Boolean isExpired;

        public slideDecorator(PS_Group_Resource__c resource) {
            this.resource = resource;
            this.id = resource.Id;
            this.caption = resource.Carousel_Caption__c;
            this.description = resource.Carousel_Description__c;
            this.expiration = resource.Expiration_Date__c;
            this.externalUrl = resource.External_URL__c;
            this.sortOrder = resource.Feature_Carousel_Sort_Order__c;
            this.url = resource.Slider_Url_c__c;
            this.isExpired = resource.Is_Expired__c;
        }

        public void setImgUrl(String imgUrl) {
            this.imgUrl = imgUrl;
        }
    }
}