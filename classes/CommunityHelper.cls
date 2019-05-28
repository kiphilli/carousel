/**
 * @author anthony.beran@slalom.com
 * @date 3/9/18
 * @version 1.0
 * @description Helper class for community related code
 */
public with sharing class CommunityHelper {

    /**
     * @author anthony.beran@slalom.com
     * @date 03/09/18
     * @version 1.0
     * @description Returns the absolute base url for the community with the prefix
     * @param networkId Id of community
     *
     * @return Absolute base url of community. If used in a non-community context returns null. Will thrown an exception
     * if the networkId parameter is a non-Network Id
     */
    @TestVisible
    private static String getSiteUrl(Id networkId, Boolean includePrefix) {
        if ( null == networkId ) {
            return networkId;
        } else {
            ConnectApi.Community community = ConnectApi.Communities.getCommunity(networkId);
            return includePrefix ? community.siteUrl + '/s' : community.siteUrl;
        }
    }

    /**
     * @author anthony.beran@slalom.com
     * @date 03/09/18
     * @version 1.0
     * @description Proxy method to get the base url of the community. Abstracts away the need for the end user to pass in
     * the network id. Returns the absolute base url for the community with the prefix. Useful for generating correct
     * urls for community pages
     *
     * @return String url
     */
    public static String getSiteUrlWithPrefix() {
        Id networkId = Network.getNetworkId();
        return CommunityHelper.getSiteUrl(networkId, true);
    }

    /**
     * @author anthony.beran@slalom.com
     * @date 04/06/18
     * @version 1.0
     * @description Return the base url form the community without the prefix. Useful when needing to
     * reference /servlet for example
     *
     * @return String url
     */
    public static String getSiteUrl() {
        Id networkId = Network.getNetworkId();
        return CommunityHelper.getSiteUrl(networkId, false);
    }

    /**
     * @author anthony.beran@slalom.com
     * @date 06/11/18
     * @version 1.0
     * @description Return true or false if current user has edit rights to the component
     *
     * @param groupId
     *
     * @return Boolean
     */
    public static Boolean getEditPermission(Id groupId) {
        List<CollaborationGroupMember> groupMembers = [
            SELECT CollaborationRole
            FROM CollaborationGroupMember
            WHERE MemberId = :UserInfo.getUserId()
            AND CollaborationGroupId = :groupId
            LIMIT 1
        ];

        if ( !groupMembers.isEmpty() ) {
            return 'Admin' == groupMembers[0].CollaborationRole;
        } else {
            return false;
        }
    }

    /**
     * @author anthony.beran@slalom.com
     * @date 07/04/18
     * @version 1.0
     * @description return white spaced stripped version of the user's browser
     *
     * @return String
     */
    public static String getBrowserVersion() {
        List<LoginHistory> lh = [
            SELECT NetworkId, Status, UserId, Browser, LoginTime
            FROM LoginHistory
            WHERE UserId = :UserInfo.getUserId()
            ORDER BY LoginTime DESC
            LIMIT 1
        ];

        if ( !lh.isEmpty() ) {
            return lh[0].Browser.deleteWhitespace();
        } else {
            return '';
        }
    }

    /**
     * @author anthony.beran@slalom.com
     * @date 12/27/18
     * @version 1.0
     * @description Queries if User belongs to one of the profiles
     *
     * @param userId
     * @param profileNames
     *
     * @return Boolean - If user's profile is in the list of profiles to search
     */
    public static Boolean isUserInProfile(Id userId, List<String> profileNames) {
        String userProfileName = [
            SELECT Profile.Name
            FROM User
            WHERE Id = :userId
        ].Profile.Name;

        return profileNames.contains(userProfileName);
    }

    /**
     * @author anthony.beran@slalom.com
     * @date 08/31/18
     * @version 1.0
     * @description - Generic method that returns picklist values via a JSON object
     *
     * @param obj String:   Name of the Object
     * @param field String: Name of the picklist field
     *
     * @return String:  JSON serialized List<pickListOption>
     */
    public static List<PickListOption> getPicklistOptions(String obj, String field) {
        List<PickListOption> options = new List<PickListOption>();
        Schema.SObjectType convertType = Schema.getGlobalDescribe().get(obj.toLowerCase());

        if ( null != convertType ) {
            SObject genericObject = convertType.newSObject();
            Schema.SObjectType objType = genericObject.getSObjectType();
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();

            for (Schema.PicklistEntry picklistEntry : fieldMap.get(field).getDescribe().getPicklistValues()) {
                options.add(new PickListOption(picklistEntry.getLabel(), picklistEntry.getValue()));
            }
        }


        return options;
    }

    /**
     * wrapper class used by getPicklistOptions to allow for serialization of the picklist values
     */
    public class PickListOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public PickListOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}