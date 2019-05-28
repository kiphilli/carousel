/**
 * @author anthony.beran@slalom.com
 * @date 7/2/18
 * @version 1.0
 * @description BMGF_Resource_Container_Controller
 */

public with sharing class BMGF_Resource_Container_Controller {

    /**
     * @author anthony.beran@slalom.com
     * @date 06/27/2018
     * @version 1.0
     * @description Return the group name for the specified Id
     *
     * @param recordId
     *
     * @return String - Group name
     */
    @AuraEnabled
    public static Id getPSGroupId(Id groupId) {
        return [
            SELECT Id
            FROM PS_Group__c
            WHERE CollaborationGroup_Id__c = :groupId
        ].Id;
    }

    @AuraEnabled
    public static Boolean getEditPermission(String groupId, List<String> profileNames) {
        if ( null == groupId) {
            return BMGF_Resource_Helper.userHasCarouselEditRights(UserInfo.getUserId(), profileNames);
        } else {
            return CommunityHelper.getEditPermission(Id.valueOf(groupId));
        }

    }
}