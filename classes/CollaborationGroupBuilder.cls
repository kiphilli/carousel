/**
 * @author anthony.beran@slalom.com
 * @date 6/28/18
 * @version 1.0
 * @description CollaborationGroupBuilder
 */

@IsTest
public with sharing class CollaborationGroupBuilder {
    private CollaborationGroup obj;

    public CollaborationGroupBuilder(String name) {
        this.obj = new CollaborationGroup(
            Name = name,
            CollaborationType = 'Public'
        );
    }

    public CollaborationGroup build() {
        return this.obj;
    }

    public CollaborationGroup buildInsert() {
        insert this.obj;
        return this.obj;
    }
}