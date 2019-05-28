/**
 * @author anthony.beran@slalom.com
 * @date 7/3/18
 * @version 1.0
 * @description BMGF_Resource_Container_Controller_Test
 */
@IsTest
private class BMGF_Resource_Container_Controller_Test {
    @TestSetup
    static void setup() {
        PS_Site__c site = new PS_Site__c(
            Name = 'PS Community'
        );
        insert site;
    }

    static testMethod void getPSGroupId() {
        CollaborationGroup g = new CollaborationGroup(
            Name = 'test group for unit tests',
            CollaborationType = 'Public'
        );
        insert g;


        Test.startTest();
        Id gId = BMGF_Resource_Container_Controller.getPSGroupId(g.Id);
        Test.stopTest();

        List<PS_Group__c> psGroups = [
            SELECT Id, Group_Name__c
            FROM PS_Group__c
            WHERE Group_Name__c = 'test group for unit tests'
            LIMIT 1
        ];

        System.assert(gId == psGroups[0].Id, 'Expect to find PS Group Id. Got ' + gId);
    }

    static testMethod void userHasCarouselEditRights() {
        String profileName = 'PS System Administrator';

        Id runningUserProfileId = [ SELECT Id
        FROM Profile
        WHERE Name = 'PS System Administrator'
        LIMIT 1
        ].Id;
        User runningUser = [Select Id,UserRoleId from User where IsActive = TRUE AND UserRoleId != NULL AND ProfileId = :runningUserProfileId LIMIT 1];


        Test.startTest();
        Boolean canEdit = BMGF_Resource_Helper.userHasCarouselEditRights(runningUser.Id, new List<String>{profileName});
        Test.stopTest();

        System.assert(true == canEdit, 'Expected true. Got ' + canEdit);
    }

    static testMethod void userHasNoCarouselEditRights() {
        String profileName = 'PS User';

        Id runningUserProfileId = [ SELECT Id
        FROM Profile
        WHERE Name = 'PS System Administrator'
        LIMIT 1
        ].Id;
        User runningUser = [Select Id,UserRoleId from User where IsActive = TRUE AND UserRoleId != NULL AND ProfileId = :runningUserProfileId LIMIT 1];


        Test.startTest();
        Boolean canEdit = BMGF_Resource_Helper.userHasCarouselEditRights(runningUser.Id, new List<String>{profileName});
        Test.stopTest();

        System.assert(false == canEdit, 'Expected false. Got ' + canEdit);
    }
}