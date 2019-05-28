/**
 * @author anthony.beran@slalom.com
 * @date 3/9/18
 * @version 1.0
 * @description Unit tests for CommunityHelper
 */
@IsTest(SeeAllData=true)
public with sharing class CommunityHelperTest {

    public static testMethod void getSiteUrl() {
        //test
        Test.startTest();
        String url = CommunityHelper.getSiteUrl();
        Test.stopTest();

        //assert
        System.assert(null == url, 'Expected null since not in community context. Got ' + url);
    }

    public static testMethod void getSiteUrlWithPrefix() {
        //test
        Test.startTest();
        String url = CommunityHelper.getSiteUrlWithPrefix();
        Test.stopTest();

        //assert
        System.assert(null == url, 'Expected null since not in community context. Got ' + url);
    }

    public static testMethod void getSiteUrlWithCommunity() {
        //setup
        Id runningUserProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'PS System Administrator'
            LIMIT 1
        ].Id;

        User runningUser = [
            SELECT Id, UserRoleId
            FROM User
            WHERE IsActive = TRUE
            AND UserRoleId != NULL
            AND ProfileId = :runningUserProfileId
            LIMIT 1
        ];

        NetworkMember membership = [
            SELECT networkID
            FROM NetworkMember
            WHERE memberID = :runningUser.id
            LIMIT 1
        ];

        //test
        Test.startTest();
        String url = CommunityHelper.getSiteUrl(membership.networkID, false);
        Test.stopTest();

        //assert
        System.assert(0 == url.indexOf('https://'), 'Expected valid url. Got ' + url);
        System.assert('/s' != url.right(2), 'Expected valid url without /s prefix. Got ' + url);

    }

    public static testMethod void getSiteUrlWithCommunityPrefix() {
        //setup
        Id runningUserProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'PS System Administrator'
            LIMIT 1
        ].Id;

        User runningUser = [
            SELECT Id, UserRoleId
            FROM User
            WHERE IsActive = TRUE
            AND UserRoleId != NULL
            AND ProfileId = :runningUserProfileId
            LIMIT 1
        ];

        NetworkMember membership = [
            SELECT networkID
            FROM NetworkMember
            WHERE memberID = :runningUser.id
            LIMIT 1
        ];

        //test
        Test.startTest();
        String url = CommunityHelper.getSiteUrl(membership.networkID, true);
        Test.stopTest();

        //assert
        System.assert('/s' == url.right(2), 'Expected valid url without /s prefix. Got ' + url);
    }

    public static testMethod void getEditPermissionNotaMember() {
        CollaborationGroup g = new CollaborationGroup(
            Name = 'test group for unit tests',
            CollaborationType = 'Public'
        );
        insert g;


        Id runningUserProfileId = [ SELECT Id
        FROM Profile
        WHERE Name = 'PS System Administrator'
        LIMIT 1
        ].Id;
        User runningUser = [Select Id,UserRoleId from User where IsActive = TRUE AND UserRoleId != NULL AND ProfileId = :runningUserProfileId LIMIT 1];

        System.runAs(runningUser) {
            Boolean canEdit = CommunityHelper.getEditPermission(g.Id);

            System.assert(false == canEdit, 'Expect false when user does not belong to the group');

        }
    }

    public static testMethod void getEditPermissionIsAdminMember() {
        CollaborationGroup g = new CollaborationGroup(
            Name = 'test group for unit tests',
            CollaborationType = 'Public'
        );
        insert g;


        Id runningUserProfileId = [ SELECT Id
        FROM Profile
        WHERE Name = 'PS System Administrator'
        LIMIT 1
        ].Id;
        User runningUser = [Select Id,UserRoleId from User where IsActive = TRUE AND UserRoleId != NULL AND ProfileId = :runningUserProfileId LIMIT 1];

        insert new CollaborationGroupMember(
            CollaborationRole = 'Admin',
            MemberId = runningUser.Id,
            CollaborationGroupId = g.Id
        );

        System.runAs(runningUser) {
            Boolean canEdit = CommunityHelper.getEditPermission(g.Id);
            System.assert(true == canEdit, 'Expect true when user is admin of group');

        }
    }

    public static testMethod void getBrowserVersion() {
        Id runningUserProfileId = [ SELECT Id
        FROM Profile
        WHERE Name = 'PS System Administrator'
        LIMIT 1
        ].Id;
        User runningUser = [Select Id,UserRoleId from User where IsActive = TRUE AND UserRoleId != NULL AND ProfileId = :runningUserProfileId LIMIT 1];

        System.runAs(runningUser) {
            Test.startTest();
            String browser = CommunityHelper.getBrowserVersion();
            Test.stopTest();

            System.assert(null != browser);
        }
    }

    public static testMethod void userInProfileList() {
        List<String> profileList = new List<String>{'PS System Administrator'};
        User runningUser = new PSUserBuilder()
            .withUserName('profile.in.list@ps.test.com')
            .withProfile('PS System Administrator')
            .buildInsert();

        User runningUser2 = new PSUserBuilder()
            .withUserName('profile.not.in.list@ps.test.com')
            .buildInsert();

        System.runAs(runningUser) {
            Test.startTest();
            Boolean result = CommunityHelper.isUserInProfile(runningUser.Id, profileList);
            Boolean result2 = CommunityHelper.isUserInProfile(runningUser2.Id, profileList);
            Test.stopTest();

            System.assert(true == result, 'Expect user profile to be in the list');
            System.assert(false == result2, 'Expect user profile to not be in the list');
        }
    }
}