/**
 * @author anthony.beran@slalom.com
 * @date 6/25/18
 * @version 1.0
 * @description CollaborationGroup_TriggerHandler
 */

public with sharing class CollaborationGroup_TriggerHandler extends TriggerFactoryHandlerBase {
    public override void OnAfterInsert(List<SObject> newList) {
        CollaborationGroupTriggerHandler.syncPSGroup((List<CollaborationGroup>) newList, null);
    }

    public override void OnAfterUpdate(List<SObject> oldList, List<SObject> newList, Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        CollaborationGroupTriggerHandler.syncPSGroup((List<CollaborationGroup>) newList, (Map<Id, CollaborationGroup>) oldMap);
    }

    public override void OnUnDelete(List<SObject> newList) {
        CollaborationGroupTriggerHandler.syncPSGroup((List<CollaborationGroup>) newList, null);
    }

    public override void OnAfterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
        CollaborationGroupTriggerHandler.syncPSGroup(null, (Map<Id, CollaborationGroup>) oldMap);
    }
}