/**
 * @author anthony.beran@slalom.com
 * @date 6/25/18
 * @version 1.0
 * @description CollaborationGroupTrigger
 */
trigger CollaborationGroupTrigger on CollaborationGroup (after insert, after update, after delete, after undelete) {
    TriggerFactory.createHandler();
}