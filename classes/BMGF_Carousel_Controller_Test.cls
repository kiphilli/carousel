/**
 * Created by robert.truitt on 3/16/2017.
 */

@IsTest
private class BMGF_Carousel_Controller_Test {
//    @isTest(SeeAllData=false)


    static testMethod void captionBuilder() {
        CollaborationGroup g = new CollaborationGroup(
            Name = 'test group',
            CollaborationType = 'Private'
        );
        Test.startTest();
        insert g;
        Test.stopTest();

        Map<String, SObject> objMap = new Map<String, SObject>();
        objMap.put('CollaborationGroup', g);
        String ret = BMGF_Carousel_Controller.captionBuilder(objMap, 'PS_Group_Resource__c.Carousel_Caption__c,PS_Group_Resource__c.Carousel_Description__c');

        System.assert('' == ret);
    }

    static testMethod void getRecords() {
        CollaborationGroup g = new CollaborationGroup(
            Name = 'test group',
            CollaborationType = 'Private'
        );
        Test.startTest();
        insert g;
        Test.stopTest();


        String ret = BMGF_Carousel_Controller.getRecords(new List<Id>{g.Id});
        System.assert('' != ret);
    }

    static testMethod void testGroupCarousel() {
        CollaborationGroup g = new CollaborationGroup(
            Name = 'test group',
            CollaborationType = 'Private'
        );
        Test.startTest();
        insert g;
        Test.stopTest();

        BMGF_Carousel_Controller.CarouselContainer cc = BMGF_Carousel_Controller.getCarouselItems(g.Id, 'PS_Group__c', 'PS_Group_Resource__c', '', 'PS_Group__c', '', '', '', '', '', 'PS_Group_Resource__c.Caption__c',
            'PS_Group_Resource__c.External_URL__c', 'CreatedDate', true, 'Group_Name__c', '', '');

        System.assert(0 == cc.carouselParentItems.size());
    }


    static testMethod void testCarousel() {
        new PSSiteBuilder('PS Community')
            .buildInsert();

        PS_Group__c psGroup = new PSGroupBuilder('new group')
            .withSite('PS Community')
            .buildInsert();


        PS_Group_Resource__c psGrpResource = new PS_Group_Resource__c();
        //psGrpResource = 'Test Resource';
        psGrpResource.Type__c = 'Feature Carousel';
        psGrpResource.External_url__c = '<img src="www.google.com"/>';
        psGrpResource.Caption__c = 'Google\'s photo';
        psGrpResource.PS_Group__c = psGroup.Id;
        insert psGrpResource;

        ContentVersion cv = new ContentVersion();
        cv.ContentURL = 'http://www.google.com/';
        cv.Title = 'Google.com';
        insert cv;

        cv = [Select ContentDocumentId, Id from ContentVersion where Id = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = psGrpResource.Id;
        cdl.ShareType = 'I';

        insert cdl;

        BMGF_Carousel_Controller.CarouselContainer cc = BMGF_Carousel_Controller.getCarouselItems('', 'PS_Group__c', 'PS_Group_Resource__c', '', 'PS_Group__c', '', '', '', '', '', 'PS_Group_Resource__c.Caption__c',
                'PS_Group_Resource__c.External_URL__c', 'CreatedDate', false, 'Group_Name__c', '', '');

        for (BMGF_Carousel_Controller.CarouselParentItem cpi : cc.carouselParentItems) {
            for (BMGF_Carousel_Controller.CarouselItem ci : cpi.carouselItems) {
                System.assertEquals(ci.caption, psGrpResource.Caption__c);
                System.assert(ci.assetUrl.endsWith(cv.Id));
                System.assertEquals(ci.linkUrl, psGrpResource.External_URL__c);
            }
        }
        BMGF_Carousel_Controller.getCarouselItems('', 'PS_Group__c', 'PS_Group_Resource__c', '', 'PS_Group__c', '', 'PS_Group_Resource__c.External_URL__c', '', '', '', 'PS_Group_Resource__c.Caption__c',
                'PS_Group_Resource__c.External_URL__c', 'CreatedDate', false, 'Group_Name__c', '', '');
        for (BMGF_Carousel_Controller.CarouselParentItem cpi : cc.carouselParentItems) {
            for (BMGF_Carousel_Controller.CarouselItem ci : cpi.carouselItems) {
                System.assertEquals(ci.caption, psGrpResource.Caption__c);
                System.assert(ci.assetUrl.endsWith(cv.Id));
                System.assertEquals(ci.linkUrl, psGrpResource.External_URL__c);
            }
        }

    }
}