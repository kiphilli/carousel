/**
 * @author anthony.beran@slalom.com
 * @date 7/6/18
 * @version 1.0
 * @description CarouselHelper_Test
 */
@IsTest
private class CarouselHelper_Test {
    @TestSetup
    static void setup() {
        List<PS_Group_Resource__c> resources = new List<PS_Group_Resource__c>();
        Integer createCount = 4;

        for ( Integer i = 0; i < createCount; i++ ) {
            PS_Group_Resource__c r = new PS_Group_Resource__c(
                Carousel_Caption__c = i + 'test caption'
            );

            resources.add(r);
        }

        insert resources;

        ContentVersion cv = new ContentVersion();
        cv.title = 'TestFile.txt';
        cv.PathOnClient = 'TestFile.txt';
        cv.VersionData = Blob.valueOf('Test file upload');
        insert cv;

        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        BMGF_PS_Carousel_Edit_Controller.updatePhoto(resources[0].Id, cv.ContentDocumentId);
    }

    static testMethod void getRecords() {
        //setup
        List<PS_Group_Resource__c> resources = [
            SELECT Carousel_Caption__c
            FROM PS_Group_Resource__c
            WHERE Carousel_Caption__c IN ('0test caption', '1test caption')
        ];

        //test
        Test.startTest();
        List<CarouselHelper.slideDecorator> slides = CarouselHelper.getRecords(new List<Id>(new Map<Id, PS_Group_Resource__c>(resources).keySet()));
        Test.stopTest();

        System.assert(2 == slides.size());
        for ( CarouselHelper.slideDecorator s : slides ) {
            if ( '0test caption' == s.caption ) {
                System.assert(null != s.imgUrl, 'Expect resource to have file url');
            } else {
                System.assert(null == s.imgUrl, 'Expect resource to not have a file url. Got ' + s.imgUrl);
            }
        }
    }
}