/**
 * @author anthony.beran@slalom.com
 * @date 10/5/18
 * @version 1.0
 * @description TopicGroupListController
 */

public with sharing class TopicGroupListController {

    @AuraEnabled
    public static List<CollaborationGroup> getGroupsForRecord(Id topicId) {
        Set<Id> groupIds = new Set<Id>();
        Set<Id> collaborationGroupIds = new Set<Id>();

        /*
         * Salesforce limitation as of API 43
         * Implementation restriction: TopicAssignment only allows security evaluation for non-admin users when either (1) LIMIT is
         * specified and at most 1000 or (2) WHERE is specified and filter on Id or Entity
         */
        for ( TopicAssignment ta : [
            SELECT EntityId
            FROM TopicAssignment
            WHERE TopicId = :topicId
            AND EntityType = 'CollaborationGroup_Proxy'
            LIMIT 1000
        ]) {
            groupIds.add(ta.EntityId);
        }

        for ( CollaborationGroup_Proxy__c g : [
            SELECT CollaborationGroup_Id__c
            FROM CollaborationGroup_Proxy__c
            WHERE Id IN :groupIds
        ] ) {
            collaborationGroupIds.add(g.CollaborationGroup_Id__c);
        }

        return [
            SELECT Id, Name, Description, SmallPhotoUrl
            FROM CollaborationGroup
            WHERE Id IN :collaborationGroupIds
        ];


    }
}