/**
 * @author anthony.beran@slalom.com
 * @date 6/13/18
 * @version 1.0
 * @description BMGF_PS_Carousel_Edit_Controller controller class for BMGF_PS_Carousel_Edit lightning component
 */

public with sharing class BMGF_PS_Carousel_Edit_Controller {

    /**
     * @author anthony.beran@slalom.com
     * @date 07/05/18
     * @version 1.0
     * @description Return custom setting Resource_CMS_Documents__c named 'Documents'
     *
     * @return String JSON serialized Resource_CMS_Documents__c record
     */
    @AuraEnabled
    public static String getDocumentUrl() {
        Resource_CMS_Documents__c documents = Resource_CMS_Documents__c.getValues('Documents');
        return JSON.serialize(documents);
    }

    /**
     * @author anthony.beran@slalom.com
     * @date 07/05/18
     * @version 1.0
     * @description Return browser user last logged into Salesforce with based on Login History
     *
     * @return String browser name with whitespace removed
     */
    @AuraEnabled
    public static String getBrowserVersion() {
        return CommunityHelper.getBrowserVersion();
    }

    /**
     * @author anthony.beran@slalom.com
     * @date 07/05/18
     * @version 1.0
     * @description Return PS_Group_Resource__c based on Id
     *
     * @param recordId
     *
     * @return String JSON serialized PS_Group_Resource__c record
     */
    @AuraEnabled
    public static String getRecord(Id recordId) {
        PS_Group_Resource__c r = [
            SELECT Carousel_Caption__c, Carousel_Description__c, Description__c, External_URL__c, Resource_Grouping_Name__c, Feature_Carousel_Sort_Order__c, Expiration_Date__c, Start_Date__c
            FROM PS_Group_Resource__c
            WHERE Id = :recordId
        ];

        return JSON.serialize(r);
    }

    /**
     * @author anthony.beran@slalom.com
     * @date 07/05/18
     * @version 1.0
     * @description Insert new PS_Group_Resource__c record from JSON
     *
     * @param record
     *
     * @return String JSON serialized inserted PS_Group_Resource__c record
     */
    @AuraEnabled
    public static String createResource(String record) {
        PS_Group_Resource__c r = (PS_Group_Resource__c) JSON.deserialize(record, PS_Group_Resource__c.class);
        insert r;

        return JSON.serialize(r);
    }

    /**
     * @author anthony.beran@slalom.com
     * @date 07/05/18
     * @version 1.0
     * @description Update PS_Group_Resource__c record from JSON
     *
     * @return String JSON serialized updated PS_Group_Resource__c record
     */
    @AuraEnabled
    public static void updateResource(String record) {
        PS_Group_Resource__c r = (PS_Group_Resource__c) JSON.deserialize(record, PS_Group_Resource__c.class);
        update r;
    }

    /**
     * @author anthony.beran@slalom.com
     * @date 07/05/18
     * @version 1.0
     * @description Update Chatter image file associated with a PS_Group_Resource__c record. If there is an existing
     * Chatter file, delete the old file so there is only ever 1 file associated with the record. Give the file 'AllUsers'
     * visibility so Community users can see the image on the Community.
     *
     * @param recordId
     * @param fileId
     *
     * @return String public visible url for the uploaded image that can be used in <img> tag.
     */
    @AuraEnabled
    public static String updatePhoto(String recordId, String fileId) {
        ContentDocument c = [
            SELECT Id,
            (
                SELECT Id FROM ContentVersions
                WHERE IsLatest = TRUE
            )
            FROM ContentDocument
            WHERE Id = :fileId
        ];

        FeedItem fi = new FeedItem();
        fi.Body = 'Carousel Image';
        fi.ParentId = recordId;
        fi.Visibility = 'AllUsers';
        insert fi;

        // Associate the file with the post
        FeedAttachment postAttachment = new FeedAttachment();
        postAttachment.FeedEntityId = fi.Id;
        postAttachment.Type = 'Content';
        postAttachment.RecordId = c.ContentVersions[0].Id;
        insert postAttachment;

        //finally clean up all other Files records for this object
        List<ContentDocumentLink> files = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            AND ContentDocumentId != :fileId
        ];

        if ( !files.isEmpty() ) {
            delete files;
        }

        return CommunityHelper.getSiteUrl() + BMGF_Resource_Helper.FILE_URL_PREFIX + postAttachment.RecordId;
    }

    /**
     * @author anthony.beran@slalom.com
     * @date 07/05/18
     * @version 1.0
     * @description Delete PS_Group_Resource__c based on the Id
     *
     * @param recordId
     */
    @AuraEnabled
    public static void deleteResource(Id recordId) {
        delete [
            SELECT Id
            FROM PS_Group_Resource__c
            WHERE Id = :recordId
        ];
    }

    /**
     * @author anthony.beran@slalom.com
     * @date 07/05/18
     * @version 1.0
     * @description return List PS_Group_Resource__c records based on List of Ids
     *
     * @param records
     *
     * @return String JSON serialized List<CarouselHelper.slideDecorator>
     */
    @AuraEnabled
    public static String getRecords(List<Id> records) {
        return JSON.serialize(CarouselHelper.getRecords(records));
    }
}