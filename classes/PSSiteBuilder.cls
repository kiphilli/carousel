/**
 * @author anthony.beran@slalom.com
 * @date 6/28/18
 * @version 1.0
 * @description PSSiteBuilder
 */

@IsTest
public with sharing class PSSiteBuilder {
    private PS_Site__c obj;

    public PSSiteBuilder(String name) {
        this.obj = new PS_Site__c(
            Name = name
        );
    }

    public PS_Site__c build() {
        return this.obj;
    }

    public PS_Site__c buildInsert() {
        insert this.obj;
        return this.obj;
    }
}