/**
 * @author anthony.beran@slalom.com
 * @date 6/25/18
 * @version 1.0
 * @description TriggerUtility
 */

public with sharing class TriggerUtility {
    /*
     * Insert/Undelete has no old record values
     * Delete has no new record values
     * Update has new and old record values
     */
    @TestVisible
    public static String getOperation(Boolean newRecordValues, Boolean oldRecordValues) {
        if(!oldRecordValues) {
            return 'insert';
        }
        else if(!newRecordValues) {
            return 'delete';
        }
        else {
            return 'update';
        }
    }
}