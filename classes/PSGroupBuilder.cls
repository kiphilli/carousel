/**
 * @author anthony.beran@slalom.com
 * @date 6/25/18
 * @version 1.0
 * @description PSGroupBuilder
 */

public with sharing class PSGroupBuilder {
    private final String SITE_KEY = 'siteMap';
    private PS_Group__c obj;

    public PSGroupBuilder(String groupName) {
        this.obj = new PS_Group__c(
            Group_Name__c = groupName
        );
        this.withSite('PS Community');
    }

    public PS_Group__c build() {
        return this.obj;
    }

    public PS_Group__c buildInsert() {
        insert this.obj;
        return this.obj;
    }

    public PSGroupBuilder withCollaborationGroup(String v) {
        this.obj.CollaborationGroup_Id__c = v;
        return this;
    }

    public PSGroupBuilder withSite(String siteName) {
        Map<String, Object> siteMap = new Map<String, Object>();
        String cacheResult = SimpleMapCacheHelper.get(this.SITE_KEY);

        if ( null != cacheResult ) {
            siteMap = (Map<String, Object>) JSON.deserializeUntyped(cacheResult);
        } else {
            for ( PS_Site__c s : [
                SELECT Id, Name
                FROM PS_Site__c
            ] ) {
                siteMap.put(s.Name, (Object) s.Id);
            }

            SimpleMapCacheHelper.set(this.SITE_KEY, JSON.serialize(siteMap));
        }

        this.obj.PS_Site__c = (Id) siteMap.get(siteName);
        return this;
    }
}