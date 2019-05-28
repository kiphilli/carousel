/**
 * @author anthony.beran@slalom.com
 * @date 10/9/18
 * @version 1.0
 * @description CollaborationGroupProxyBuilder
 */

public with sharing class CollaborationGroupProxyBuilder {
    private CollaborationGroup_Proxy__c obj;

    public CollaborationGroupProxyBuilder(String name) {
        this.obj = new CollaborationGroup_Proxy__c(
            Name = name
        );
    }

    public CollaborationGroup_Proxy__c build() {
        return this.obj;
    }

    public CollaborationGroup_Proxy__c buildInsert() {
        insert this.obj;
        return this.obj;
    }

    public CollaborationGroupProxyBuilder withNetwork(String v) {
        this.obj.Network_Id__c = v;
        return this;
    }

    public CollaborationGroupProxyBuilder withCollaborationGroup(String v) {
        this.obj.CollaborationGroup_Id__c = v;
        return this;
    }
}