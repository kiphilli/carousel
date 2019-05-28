/**
 * Created by robert.truitt on 3/16/2017.
 */
@IsTest
public with sharing class BMGF_Resource_Controller_Test {
//    @isTest(SeeAllData=false)

    static testMethod void testResourceControllerNoFiles() {
        new PSSiteBuilder('PS Community')
            .buildInsert();

        Test.startTest();
        CollaborationGroup cg = new CollaborationGroupBuilder('Test Group1')
            .buildInsert();
        Test.stopTest();

        PS_Group__c psGroup = [
            SELECT Id
            FROM PS_Group__c
            WHERE Group_Name__c = 'Test Group1'
            LIMIT 1
        ];

        PS_Group_Resource__c psGrpResource = new PS_Group_Resource__c();
        //psGrpResource = 'Test Resource';
        psGrpResource.Type__c = 'Feature Carousel';
        psGrpResource.External_url__c = 'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png';
        psGrpResource.Caption__c = 'Google\'s photo';
        psGrpResource.PS_Group__c = psGroup.Id;
        insert psGrpResource;

        BMGF_Resource_Controller.getResources('', 'PS_Group__c', 'PS_Group_Resource__c', '', 'PS_Group__c', '', '', '', '', '', '', 'PS_Group_Resource__c.Type__c', 'CreatedDate', false, 'Group_Name__c');
        BMGF_Resource_Controller.getResources('', 'PS_Group__c', 'PS_Group_Resource__c', '', 'PS_Group__c', '', '', '', '', 'PS_Group_Resource__c.External_URL__c', '', 'PS_Group_Resource__c.Type__c', 'CreatedDate', false, 'Group_Name__c');
        BMGF_Resource_Controller.getResources(cg.Id, 'PS_Group__c', 'PS_Group_Resource__c', '', 'PS_Group__c', '', '', '', '', 'PS_Group_Resource__c.External_URL__c', '', 'PS_Group_Resource__c.Type__c', 'CreatedDate', true, 'Group_Name__c');
    }

    static testMethod void testResourceController() {
        new PSSiteBuilder('PS Community')
            .buildInsert();

        Test.startTest();
        CollaborationGroup cg = new CollaborationGroupBuilder('Test Group1')
            .buildInsert();
        Test.stopTest();

        PS_Group__c psGroup = [
            SELECT Id
            FROM PS_Group__c
            WHERE Group_Name__c = 'Test Group1'
            LIMIT 1
        ];

        PS_Group_Resource__c psGrpResource = new PS_Group_Resource__c();
        //psGrpResource = 'Test Resource';
        psGrpResource.Type__c = 'Feature Carousel';
        psGrpResource.External_url__c = 'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png';
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

        BMGF_Resource_Controller.getResources('', 'PS_Group__c', 'PS_Group_Resource__c', '', 'PS_Group__c', '', '', '', '', '', '', 'PS_Group_Resource__c.Type__c', 'CreatedDate', false, 'Group_Name__c');
        BMGF_Resource_Controller.getResources('', 'PS_Group__c', 'PS_Group_Resource__c', '', 'PS_Group__c', '', '', '', '', 'PS_Group_Resource__c.External_URL__c', '', 'PS_Group_Resource__c.Type__c', 'CreatedDate', false, 'Group_Name__c');
        BMGF_Resource_Controller.getResources(cg.Id, 'PS_Group__c', 'PS_Group_Resource__c', '', 'PS_Group__c', '', '', '', '', 'PS_Group_Resource__c.External_URL__c', '', 'PS_Group_Resource__c.Type__c', 'CreatedDate', true, 'Group_Name__c');
    }
}