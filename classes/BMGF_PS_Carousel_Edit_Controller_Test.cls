/**
 * @author anthony.beran@slalom.com
 * @date 7/6/18
 * @version 1.0
 * @description BMGF_PS_Carousel_Edit_Controller_Test
 */
@IsTest
private class BMGF_PS_Carousel_Edit_Controller_Test {
    static testMethod void getDocumentUrl() {
        //setup
        Resource_CMS_Documents__c doc = new Resource_CMS_Documents__c(
            Name = 'Documents'
        );
        insert doc;

        //test
        Test.startTest();
        Resource_CMS_Documents__c document = (Resource_CMS_Documents__c) JSON.deserializeStrict(BMGF_PS_Carousel_Edit_Controller.getDocumentUrl(), Resource_CMS_Documents__c.class);
        Test.stopTest();

        //assert
        System.assert(null != document, 'Expect custom setting to not be null for "Documents"');
    }

    static testMethod void getRecord() {
        //setup
        PS_Group_Resource__c r = new PS_Group_Resource__c(
            Carousel_Caption__c = 'test caption'
        );
        insert r;

        //test
        Test.startTest();
        PS_Group_Resource__c resource = (PS_Group_Resource__c) JSON.deserializeStrict(BMGF_PS_Carousel_Edit_Controller.getRecord(r.Id), PS_Group_Resource__c.class);
        Test.stopTest();

        //assert
        System.assert(null != resource, 'Expect PS_Group_Resource__c record to be returned');
        System.assert('test caption' == resource.Carousel_Caption__c, 'Expect "test caption". Got ' + resource.Carousel_Caption__c);
    }

    static testMethod void createResource() {
        //setup
        PS_Group_Resource__c r = new PS_Group_Resource__c(
            Carousel_Caption__c = 'test caption'
        );

        //test
        Test.startTest();
        PS_Group_Resource__c resource = (PS_Group_Resource__c) JSON.deserializeStrict(BMGF_PS_Carousel_Edit_Controller.createResource(JSON.serialize(r)), PS_Group_Resource__c.class);
        Test.stopTest();

        //assert
        System.assert(null != resource, 'Expect PS_Group_Resource__c record to be returned');
        System.assert('test caption' == resource.Carousel_Caption__c, 'Expect "test caption". Got ' + resource.Carousel_Caption__c);
    }

    static testMethod void updateResource() {
        //setup
        PS_Group_Resource__c r = new PS_Group_Resource__c(
            Carousel_Caption__c = 'test caption'
        );
        insert r;

        //test
        Test.startTest();
        r.Carousel_Caption__c = 'new test caption';
        BMGF_PS_Carousel_Edit_Controller.updateResource(JSON.serialize(r));
        Test.stopTest();

        //assert
        PS_Group_Resource__c updatedResource = [
            SELECT Carousel_Caption__c
            FROM PS_Group_Resource__c
            WHERE Carousel_Caption__c = 'new test caption'
            LIMIT 1
        ];

        System.assert(null != updatedResource, 'Expect PS_Group_Resource__c record to be returned');
        System.assert('new test caption' == updatedResource.Carousel_Caption__c, 'Expect "test caption". Got ' + updatedResource.Carousel_Caption__c);
    }

    static testMethod void deleteResource() {
        //setup
        PS_Group_Resource__c r = new PS_Group_Resource__c(
            Carousel_Caption__c = 'test caption'
        );
        insert r;

        //test
        Test.startTest();
        BMGF_PS_Carousel_Edit_Controller.deleteResource(r.Id);
        Test.stopTest();

        //assert
        List<PS_Group_Resource__c> deletedResource = [
            SELECT Carousel_Caption__c
            FROM PS_Group_Resource__c
            WHERE Id = :r.Id
        ];

        System.assert(true == deletedResource.isEmpty(), 'Expect no PS_Group_Resource__c record to be returned');
    }

    static testMethod void updatePhoto() {
        //setup
        PS_Group_Resource__c r = new PS_Group_Resource__c(
            Carousel_Caption__c = 'test caption'
        );
        insert r;

        ContentVersion cv = new ContentVersion();
        cv.title = 'TestFile.txt';
        cv.PathOnClient = 'TestFile.txt';
        cv.VersionData = Blob.valueOf('Test file upload');
        insert cv;

        cv = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        //test
        Test.startTest();
        String imageUrl = BMGF_PS_Carousel_Edit_Controller.updatePhoto(r.Id, cv.ContentDocumentId);
        Test.stopTest();

        //assert
        List<ContentDocumentLink> files = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :r.Id
        ];
        System.assert(1 == files.size(), 'Expect only 1 file for resource. Got ' + files.size());
        System.assert(null != imageUrl, 'Expect image url');

    }
}