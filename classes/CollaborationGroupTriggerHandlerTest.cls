/**
 * @author anthony.beran@slalom.com
 * @date 6/25/18
 * @version 1.0
 * @description CollaborationGroupTriggerHandlerTest
 */
@IsTest
private class CollaborationGroupTriggerHandlerTest {

    @TestSetup
    static void setup() {
        PS_Site__c site = new PS_Site__c(
            Name = 'PS Community'
        );
        insert site;
    }


    static testMethod void insertGroup() {
        //setup
        CollaborationGroup g = new CollaborationGroupBuilder('new group')
            .build();

        //test
        Test.startTest();
        insert g;
        Test.stopTest();

        //assert
        List<PS_Group__c> psGroups = [
            SELECT Group_Name__c
            FROM PS_Group__c
            WHERE Group_Name__c = 'new group'
        ];

        System.assert(1 == psGroups.size(), 'Expect 1 record. Got ' + psGroups.size());
    }

    static testMethod void updateGroupName() {
        //setup
        CollaborationGroup g = new CollaborationGroupBuilder('new group')
            .buildInsert();

        //test
        Test.startTest();
        g.Name = 'even newer group name';
        update g;
        Test.stopTest();

        //assert
        List<PS_Group__c> psGroups = [
            SELECT Group_Name__c
            FROM PS_Group__c
            WHERE Group_Name__c IN ('new group', 'even newer group name')
        ];

        System.assert(1 == psGroups.size(), 'Expect 1 record. Got ' + psGroups.size());
        System.assert('even newer group name' == psGroups[0].Group_Name__c, 'Expect "even newer group name". Got ' + psGroups[0].Group_Name__c);
    }

    static testMethod void deleteGroup() {
        //setup
        CollaborationGroup g = new CollaborationGroupBuilder('new group')
            .buildInsert();

        //test
        Test.startTest();
        delete g;
        Test.stopTest();

        //assert
        List<PS_Group__c> psGroups = [
            SELECT Group_Name__c
            FROM PS_Group__c
            WHERE Group_Name__c = 'new group'
        ];

        List<CollaborationGroup_Proxy__c> collaborationGroupProxies = [
            SELECT Id
            FROM CollaborationGroup_Proxy__c
            WHERE CollaborationGroup_Id__c = :g.Id
        ];

        System.assert(0 == psGroups.size(), 'Expect 0 record. Got ' + psGroups.size());
        System.assert(0 == collaborationGroupProxies.size(), 'Expect 0 record. Got ' + collaborationGroupProxies.size());
    }
}