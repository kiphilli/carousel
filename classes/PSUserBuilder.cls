/**
 * @author anthony.beran@slalom.com
 * @date 2018-12-27
 * @version 1.0
 * @description PSUserBuilder
 */

@IsTest
public with sharing class PSUserBuilder {
    private User obj;
    private final String PROFILE_KEY = 'profileMap';
    private static final String PERMISSION_SET_KEY = 'permissionSetMap';

    public PSUserBuilder() {
        this.obj = new User(
            Username = 'test.ps.user@ps.com.test',
            Email = 'test.ps.user@ps.com.test',
            LastName = 'lname',
            Alias = 'testuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        this.withProfile('Standard User');
    }


    public User build() {
        return this.obj;
    }

    public User buildInsert() {
        insert this.obj;
        return this.obj;
    }

    public PSUserBuilder withProfile(String profileName) {
        Map<String, Object> profileMap = new Map<String, Object>();
        String cacheResult = SimpleMapCacheHelper.get(this.PROFILE_KEY);
        if ( null != cacheResult ) {
            profileMap = (Map<String, Object>) JSON.deserializeUntyped(cacheResult);
        } else {
            for ( Profile p : [
                SELECT Id, Name
                FROM Profile
            ] ) {
                profileMap.put(p.Name, (Object)p.Id);
            }

            SimpleMapCacheHelper.set(this.PROFILE_KEY, JSON.serialize(profileMap));
        }

        this.obj.ProfileId = (Id) profileMap.get(profileName);
        return this;
    }

    /**
     * @author anthony.beran@slalom
     * @date 06/14/18
     * @version 1.0
     * @description Adds permission sets to User. Unlike the rest of the 'with' method this requires the
     * User to already be inserted. This might require System.runAs to get around the mixed DML exception
     *
     * @param permissionSetNames
     *
     * @return PTUnitTestUserBuilder - current instance of the object
     */
    public static void addPermissionSets(Id userId, Set<String> permissionSetNames) {
        List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
        Map<String, Object> permissionSetMap = new Map<String, Object>();
        String cacheResult = SimpleMapCacheHelper.get(PSUserBuilder.PERMISSION_SET_KEY);

        if ( null != cacheResult ) {
            permissionSetMap = (Map<String, Object>) JSON.deserializeUntyped(cacheResult);
        } else {
            for ( PermissionSet p : [
                SELECT Id, Name
                FROM PermissionSet
            ] ) {
                permissionSetMap.put(p.Name, (Object)p.Id);
            }

            SimpleMapCacheHelper.set(PSUserBuilder.PERMISSION_SET_KEY, JSON.serialize(permissionSetMap));
        }

        for ( String ps : permissionSetNames ) {
            permissionSetAssignmentList.add(new PermissionSetAssignment(
                PermissionSetId = (Id) permissionSetMap.get(ps),
                AssigneeId = userId
            ));
        }

        if ( !permissionSetAssignmentList.isEmpty() ) {
            insert permissionSetAssignmentList;
        }
    }

    public PSUserBuilder withUserName(String v) {
        this.obj.Username = v;
        return this;
    }
}