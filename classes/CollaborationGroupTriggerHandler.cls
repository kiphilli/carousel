/**
 * @author anthony.beran@slalom.com
 * @date 6/25/18
 * @version 1.0
 * @description CollaborationGroupTriggerHandler
 */

public with sharing class CollaborationGroupTriggerHandler {
    public static void syncPSGroup(List<CollaborationGroup> newList, Map<Id, CollaborationGroup> oldMap) {
        String operation = TriggerUtility.getOperation(newList != null, oldMap != null);

        switch on operation {
            when 'insert' {
                CollaborationGroupTriggerHandler.handleInsert(newList);
            }
            when 'update' {
                CollaborationGroupTriggerHandler.handleUpdate(newList, oldMap);
            }
            when 'delete' {
                CollaborationGroupTriggerHandler.handleDelete(oldMap);
            }
        }
    }

    private static void handleInsert(List<CollaborationGroup> newList) {
        List<PS_Group__c> psGroups = new List<PS_Group__c>();
        List<CollaborationGroup_Proxy__c> collaborationGroupProxies = new List<CollaborationGroup_Proxy__c>();

        for ( CollaborationGroup g : newList ) {
            psGroups.add(new PSGroupBuilder(g.Name)
                .withCollaborationGroup((String) g.Id)
                .build()
            );

            collaborationGroupProxies.add(new CollaborationGroupProxyBuilder(g.Name)
                .withNetwork((String) Network.getNetworkId())
                .withCollaborationGroup((String) g.Id)
                .build()
            );
        }

        insert psGroups;
        insert collaborationGroupProxies;
    }

    private static void handleUpdate(List<CollaborationGroup> newList, Map<Id, CollaborationGroup> oldMap) {
        Map<String, String> groupNameMap = new Map<String, String>();

        for ( CollaborationGroup g : newList ) {
            if ( g.Name != oldMap.get(g.Id).Name ) {
                groupNameMap.put(oldMap.get(g.Id).Name, g.Name);
            }
        }

        if ( !groupNameMap.isEmpty() ) {
            List<PS_Group__c> psGroups = [
                SELECT Group_Name__c
                FROM PS_Group__c
                WHERE Group_Name__c IN :groupNameMap.keySet()
            ];

            for ( PS_Group__c psGroup : psGroups ) {
                psGroup.Group_Name__c = groupNameMap.get(psGroup.Group_Name__c);
            }
            update psGroups;
        }
    }

    private static void handleDelete(Map<Id, CollaborationGroup> oldMap) {
        Set<String> groupNames = new Set<String>();

        for ( CollaborationGroup g : oldMap.values() ) {
            groupNames.add(g.Name);
        }

        List<PS_Group__c> psGroups = [
            SELECT Id
            FROM PS_Group__c
            WHERE Group_Name__c IN :groupNames
        ];
        List<CollaborationGroup_Proxy__c> collaborationGroupProxies = [
            SELECT Id
            FROM CollaborationGroup_Proxy__c
            WHERE CollaborationGroup_Id__c IN :oldMap.keySet()
        ];

        if ( !psGroups.isEmpty() ) {
            delete psGroups;
        }

        if ( !collaborationGroupProxies.isEmpty() ) {
            delete collaborationGroupProxies;
        }
    }
}