/**
* @author  robert.truitt@Slalom.com
* @version 1.0
* @date   2/22/2017
* @description  Helper for carousel and resource controllers.  This will pull all files/photovideourl tied to a child record
* or the child side of a many to many junction and return them in a Container class holding parent object and a
* child class containing child object,junction object and all files attached.  Allows you to specify search specs on
* all objects.
*/
public without sharing class BMGF_Resource_Helper {


    /**
    * @description parent record object with attached child resource
    */
    public class ResourceItem {
        public SObject parentObject;
        public List<ResourceChildItem> childItems {
            get {
                if (childItems == null) {
                    childItems = new List<ResourceChildItem>();
                }
                return childItems;
            }
            set;
        }
    }
    /**
    * @description child records to parent object with junction object (if specified) child object
    * and files(if there are any)
    */
    public class ResourceChildItem {
        public Id parentId;
        public SObject junctionObject;
        public SObject childObject;
        public List<ContentVersion> files {
            get {
                if (files == null) {
                    files = new List<ContentVersion>();
                }
                return files;
            }
            set;
        }
    }

    public static Boolean userHasCarouselEditRights(Id userId, List<String> profileNames) {
        return CommunityHelper.isUserInProfile(userId, profileNames);
    }


    /**
    * @description retrieve the community url prefix
    * @return community url ex: /givingpledge
    */
    public static String communityUrlPrefix {
        get {
            if (String.isEmpty(communityUrlPrefix)) {
                try {
                    communityUrlPrefix = [Select UrlPathPrefix from Network where Id = :Network.getNetworkId() Limit 1].UrlPathPrefix;
                } catch (QueryException qe) {
                    communityUrlPrefix = '';
                }
            }
            return communityUrlPrefix;
        }
        set;
    }

    /**
    * @description retrieve the community url
    * @return community url ex: host.force.com/givingpledge/
    */
    public static String communityUrl {
        get {
            if (String.isEmpty(communityUrl)) {
                String hostName = System.Url.getSalesforceBaseURL().toExternalForm();
                communityUrl = hostName + '/' + communityUrlPrefix;
            }
            return communityUrl;
        }
        set;
    }

    /**
    * @description url to retreive contentversion(files)
    */
    public static String FILE_URL_PREFIX = '/sfc/servlet.shepherd/version/download/';

    /**
    * @description retrieve a map of document id to list<parent ids>
    * @param objectIds  record id's that have files(contentversion) attached
    * @return return list of content document id's and the parent records tied to them (since a file can have multiple parents)
    */
    public static Map<Id, Set<Id>> getDocumentToParentIdMap(Set<Id> objectIds) {
        Map<Id, Set<Id>> conDocIdToEntityIdMap = new Map<Id, Set<Id>>();
        if (!objectIds.isEmpty()) {
            for (ContentDocumentLink cdl : [
                    SELECT ContentDocument.Id, LinkedEntityId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId in :objectIds
            ]) {
                if (!conDocIdToEntityIdMap.containsKey(cdl.ContentDocument.Id) || conDocIdToEntityIdMap.get(cdl.ContentDocument.Id) == null) {
                    Set<Id> entityIds = new Set<Id>();
                    entityIds.add(cdl.LinkedEntityId);
                    conDocIdToEntityIdMap.put(cdl.ContentDocument.Id, entityIds);
                } else {
                    conDocIdToEntityIdMap.get(cdl.ContentDocument.Id).add(cdl.LinkedEntityId);
                }
            }
        }
        System.debug(conDocIdToEntityIdMap);
        return conDocIdToEntityIdMap;
    }

//hopefully the resource list does not have over 200 items but just incase looping every 200
//would have rather used the UserAccess.HasReadAccess foreign key field but since we're using Sobject
//and not using concrete classes it is not available. If this ever becomes a sql limitation issue
//will need to cast to concrete type and this will break how re-usable this code is.
//have to do the same for parent and child objects, so limiting it to around ~5800 resource items
//will need to revisit if salesforce ever implements a way to dynamically typecast
    /**
    * @description Check if records are readable by the user. Security check.
    * TODO: move to utility class
    * @param List<Id> visibilityCheckIds   List of Id's to check
    * @return Set<Id>
    */
    public static Set<Id> getReadableRecords(List<Id> visibilityCheckIds) {
        Set<Id> accessableRecordIds = new Set<Id>();
        Set<Id> sortedRecordIds = new Set<Id>();
        for (Integer i = 0; i < visibilityCheckIds.size() && Limits.getQueries() < Limits.getLimitQueries() - 70;) {
            List<Id> parIdOffsetList = new List<Id>();
            for (Integer j = 0; j < visibilityCheckIds.size() && j < 200; j++) {
                parIdOffsetList.add(visibilityCheckIds.get(i + j));
            }
            i += 200;
            for (UserRecordAccess ura : [
                    SELECT RecordId
                    FROM UserRecordAccess
                    WHERE UserId = :UserInfo.getUserId() AND HasReadAccess = true AND RecordId IN :parIdOffsetList
                    LIMIT 200
            ]) {
                accessableRecordIds.add(ura.RecordId);
            }
        }
//the id's come in sorted via the order by.  Resorting them after the UserRecordAccess check.
        for (Id sortedId : visibilityCheckIds) {
            if (accessableRecordIds.contains(sortedId)) {
                sortedRecordIds.add(sortedId);
            }
        }
        return sortedRecordIds;
    }

    /**
    * @description query builder to strip all object names from queryFieldsCSV and convert to Set to remove duplicates
    * @param objectName         objectname to strip and query for
    * @param recordId           recordId (optional) one or expression :accountIds
    * @param orderBy            sort order
    * @param queryFieldsCSV     fields to query for in csv format( object.field or field )
    * @param searchSpec         object search spec
    * @return return soql string to use in Database.query
    */
    public static String queryBuilder(String objectName, String recordId, String orderBy,
            String queryFieldsCSV, String searchSpec) {
        Set<String> queryFieldsSet = new Set<String>();
        //add orderby for list sorting if needed
        if (String.isNotEmpty(orderBy)) {
            queryFieldsSet.add(stripObjectName(objectName, orderBy));
        }

        if (String.isNotEmpty(queryFieldsCSV)) {
            for (String fieldString : queryFieldsCSV.split(',')) {
                if (String.isNotEmpty(fieldString)) {
                    System.debug('queryBuilder adding Field:' + stripObjectName(objectName, fieldString));
                    queryFieldsSet.add(stripObjectName(objectName, fieldString));
                }
            }
        }

        return queryBuilder(recordId, queryFieldsSet, objectName, searchSpec, orderBy);
    }

    /**
    * @description Strip object name from object.field string
    * @param objectName     objectname to strip
    * @param fieldString    field string to strip object name out of
    * @return return field name without object
    */
    public static String stripObjectName(String objectName, String fieldString) {
        return fieldString.trim().toLowerCase().replace(objectName.trim().toLowerCase() + '.', '');
    }

    /**
    * @description Build soql query with inputs
    * @param recordId       recordId (optional) one or expression :accountIds
    * @param queryFields    Set of fields to query for
    * @param objectName     object we're querying
    * @param searchSpec     object search spec
    * @param orderBy        sort order
    * @return return soql string to use in Database.query
    */
    public static String queryBuilder(String recordId, Set<String> queryFields, String objectName, String searchSpec, String orderBy) {
        SObjectType sObjType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> objFieldMap = sObjType.getDescribe().fields.getMap();
        Map<String, String> objFieldsLowerCase = new Map<String, String>();

        System.debug('objectName is: ' + objectName);
        System.debug('objFieldMap is: ' + objFieldMap);
        System.debug('orderBy1 is: ' + orderBy);

        //converting to lowercase for easier matching
        for (String field : objFieldMap.keySet()) {
            objFieldsLowerCase.put(field, String.valueOf(objFieldMap.get(field).getDescribe().getType()).toLowerCase());
        }

        String searchString = '';
        //adding id incase it's missing
        queryFields.add('id');
        for (String field : queryFields) {
            if (String.isNotEmpty(field)) {
                System.debug('Field Value: ' + field);
                String searchField = '';
                if (field.contains('.')) {
                    String relationObjString = field.substringBefore('.').replace('__r', '__c');
                    if (objFieldsLowerCase.containsKey(relationObjString)) {
                        if (objFieldsLowerCase.get(relationObjString).equalsIgnoreCase('reference')) {
                            searchField = field.replace('__c.', '__r.');
                        }
                    }
                } else if (objFieldsLowerCase.containsKey(field)) {
                    searchField = field.toLowerCase();
                }
                if (String.isNotEmpty(searchField)) {
                    if (String.isEmpty(searchString)) {
                        System.debug(searchField + String.isEmpty(searchField));
                        searchString = 'Select ' + searchField;
                    } else {
                        searchString += ',' + searchField;
                    }
                }
            }
        }
        searchString += ' from ' + objectName;

        String queryWhereClause = '';

        if (String.isNotEmpty(searchSpec)) {
            queryWhereClause += searchSpec;
            if (String.isNotEmpty(recordId)) {
                if (recordId.contains(':')) {
                    queryWhereClause += ' and Id in ' + recordId;
                } else {
                    queryWhereClause += ' and Id = :recordId';
                }
            }
        } else {
            if (String.isNotEmpty(recordId)) {
                if (recordId.contains(':')) {
                    queryWhereClause += ' Id in ' + recordId;
                } else {
                    queryWhereClause += ' Id = :recordId';
                }
            }
        }

        if (String.isNotEmpty(queryWhereClause)) {
            searchString += ' where ' + queryWhereClause;
        }

        if (String.isNotEmpty(orderBy)) {
            String orderByStripped = stripObjectName(objectName, orderBy);
            if (orderByStripped.contains('.')) {
                String relationObjString = orderByStripped.toLowerCase().substringBefore('.').replace('__r', '__c');
                
                System.debug('objectName is: ' + objectName);
                System.debug('orderBy is: ' + orderBy);
                System.debug('orderByStripped is: ' + orderByStripped);
                System.debug('relationObjString is: ' + relationObjString);
                System.debug('objFieldsLowerCase is: ' + objFieldsLowerCase);
                for (String key : objFieldsLowerCase.keySet()) {
                    System.debug('objFieldsLowerCase key is: ' + key);
                }
                /*for(String item : objFieldsLowerCase){
                    System.debug('Field in objFieldsLowerCase is:' + item);
                }*/
                if (objFieldsLowerCase.containsKey(relationObjString)) {
                    if (objFieldsLowerCase.get(relationObjString).equalsIgnoreCase('reference')) {
                        searchString += ' order by ' + orderByStripped.replace('__c.', '__r.');
                    }
                }
            } else if (objFieldsLowerCase.containsKey(orderByStripped.substringBefore(' ').toLowerCase())) { //substring incase it has desc or asc
                searchString += ' order by ' + orderByStripped;
            }
        }
        System.debug('The searchString: ' + searchString);
        return searchString;
    }

    /**
    * @description Check if object is accessable
    * @param objName          sObject api name
    * @return true or false if object is accessable
    */
    //TODO: move to utility class
    public static Boolean isObjectAccessable(String objName) {
        Boolean isAccessable = true;
        try {
            Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objName);
            isAccessable = sObjType.getDescribe().isAccessible();
        } catch (Exception ex) {
        }
        return isAccessable;
    }

    /**
    * @description Retrieve map of parent object record to resource Item
    * @param parentMap          sObject api name
    * @param parentObjectIds    parent Ids
    * @return returns a map of parent record to parent resource item
    */
    private static Map<Id, ResourceItem> getParentRecToResourceItemMap(Map<Id, SObject> parentMap, Set<Id> parentObjectIds,
            String parentObjectName) {
        Map<Id, ResourceItem> parentIdToResourceItemMap = new Map<Id, ResourceItem>();
        for (Id parentId : parentObjectIds) {
            ResourceItem rpi = new ResourceItem();
            SObject parentRecord = parentMap.get(parentId);
            rpi.parentObject = parentRecord;
            parentIdToResourceItemMap.put(parentRecord.Id, rpi);
        }
        return parentIdToResourceItemMap;
    }

    /**
    * @description retrieve list of Resource Items with parent/child/junction and files(Content Version)
    *                           object in the returned list
    * @param parentObjectName           Parent Object Name
    * @param parentSearchExpr           Soql Search Expression for the parent object (use recordid for Id search)
    * @param junctionObjectName         Junction Object Name if required
    * @param junctionSearchExpr         Soql Search Expression for the junction object
    * @param parentRelationshipField    Parent relatinship field for Junction Object if specified
    * @param childRelationshipField     Child relationship field for Junction object if specified
    * @param childObjectName            Child Object Name
    * @param childSearchExpr            Soql Search Expression for the child object (resource containing object)
    * @param queryFieldsCSV             comma seperated string of fields to retrieve  object.field format
    * @param recordId                   Record Id if specfically pulling one Parent record
    * @param orderBy                    Order By Field (obect.field)
    * @return List of resource and their related objects
    */
    public static List<ResourceItem> getResources(String parentObjectName, String parentSearchExpr,
            String junctionObjectName, String junctionSearchExpr, String parentRelationshipField,
            String childRelationshipField, String childObjectName, String childSearchExpr, String queryFieldsCSV,
            String recordId, String orderBy) {
                System.debug('FOO');
                System.debug(orderBy);
        List<ResourceItem> resourceItems = new List<ResourceItem>();
        String queryFields = String.isNotEmpty(junctionObjectName) ? queryFieldsCSV.replace(childObjectName, childRelationshipField.replace('__c', '__r')) : queryFieldsCSV;
        try {
            Boolean ignoreParentVisibility = false;
            if (parentObjectName.equalsIgnoreCase('PS_Group__c')) {
                /* there's a limit of 10 custom objects per community so setting this one to non
                    readable and ignoring visibility on it */
                ignoreParentVisibility = true;
            }
            if (ignoreParentVisibility || isObjectAccessable(parentObjectName)) {
                String parentSearchString = queryBuilder(parentObjectName, recordId, orderBy, queryFields, parentSearchExpr);

                Map<Id, SObject> parentMap = new Map<Id, SObject>(Database.query(parentSearchString));
                Set<Id> parentObjectIds = ignoreParentVisibility ? parentMap.keySet() : getReadableRecords(new List<Id>(parentMap.keySet()));
                Map<String, ResourceChildItem> resourceChildMap = new Map<String, ResourceChildItem>();
                if (!parentObjectIds.isEmpty()) {
                    Map<Id, ResourceItem> parentIdToResourceItemMap =
                            getParentRecToResourceItemMap(parentMap, parentObjectIds, parentObjectName);
                    resourceItems.addAll(parentIdToResourceItemMap.values());
                    Set<Id> childObjectIds;
                    Map<Id, Set<SObject>> childIdToRecordMap = new Map<Id, Set<SObject>>();
                    String childSearchString = '';
                    if (String.isNotEmpty(junctionObjectName)) {
                        String queryExpression = String.isNotEmpty(junctionSearchExpr) ? ' ' + junctionSearchExpr + ' ' : '';

                        if (String.isNotEmpty(childSearchExpr)) {
                            if (String.isNotEmpty(queryExpression)) queryExpression += ' and ';
                            queryExpression += childRelationShipField.replace('__c', '__r') + '.' + childSearchExpr.trim();
                            queryExpression += ' and ' + parentRelationshipField + ' in :parentObjectIds';
                        } else {
                            if (String.isNotEmpty(queryExpression)) queryExpression += ' and ';
                            queryExpression += parentRelationshipField + ' in :parentObjectIds';
                        }

                        String childSearchFields = queryFields + ',' + parentRelationshipField + ','
                                + childRelationshipField + ',' + childRelationShipField.replace('__c', '__r') + '.Id';
                        childSearchString = queryBuilder(junctionObjectName, '', orderBy,
                                childSearchFields, queryExpression);

                        System.debug(childSearchString + parentObjectIds);
                    } else {
                        String queryExpression = parentRelationshipField + ' in :parentObjectIds';
                        queryExpression += String.isNotEmpty(childSearchExpr) ? ' and ' + childSearchExpr : '';

                        String childSearchFields = queryFields + ',' + parentRelationshipField;
                        childSearchString = queryBuilder(childObjectName, '', orderBy, childSearchFields, queryExpression);

                    }
                    for (Sobject sObj : Database.query(childSearchString)) {

                        Id childId = (Id) (String.isNotEmpty(junctionObjectName) ? sObj.get(childRelationshipField) : sObj.Id);
                        ResourceItem resourceParent = parentIdToResourceItemMap.get((Id) sObj.get(parentRelationshipField));
                        if (resourceParent.childItems == null) {
                            resourceParent.childItems = new List<ResourceChildItem>();
                        }

                        ResourceChildItem rci = new ResourceChildItem();
                        if (String.isNotEmpty(junctionObjectName)) {
                            rci.junctionObject = sObj;
                            rci.childObject = sObj.getSObject(childRelationshipField.replace('__c', '__r'));
                        } else {
                            rci.childObject = sObj;
                        }
                        rci.parentId = (String) sObj.get(parentRelationshipField);
                        String mapId = (String) rci.parentId + childId;
                        resourceChildMap.put(mapId, rci);
                        resourceParent.childItems.add(rci);

                        if (!childIdToRecordMap.containsKey(childId) || childIdToRecordMap.get(childId) == null) {
                            Set<SObject> childObjs = new Set<SObject>();
                            childObjs.add(sObj);
                            childIdToRecordMap.put(childId, childObjs);
                        } else {
                            childIdToRecordMap.get(childId).add(sObj);
                        }
                    }
                    childObjectIds = getReadableRecords(new List<Id>(childIdToRecordMap.keySet()));
                    System.debug('childObjectIds' + ' ' + childObjectIds);
                    Map<Id, Set<Id>> conDocIdToChildIdMap = getDocumentToParentIdMap(childObjectIds);


                    if (!conDocIdToChildIdMap.isEmpty()) {

                        for (ContentVersion contentVersion : [
                                Select Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, Title, Description, FileType, CreatedDate
                                from ContentVersion
                                where ContentDocumentId in :conDocIdToChildIdMap.keySet()
                        ]) {
                            System.debug('conDocIdToChildIdMap' + conDocIdToChildIdMap.get(contentVersion.ContentDocumentId));
                            if (contentVersion.Id == contentVersion.ContentDocument.LatestPublishedVersionId) {
                                for (Id childId : conDocIdToChildIdMap.get(contentVersion.ContentDocumentId)) {
                                    System.debug('Child Id: ' + childId);
                                    for (SObject juncObj : childIdToRecordMap.get(childId)) {
                                        System.debug('childIdToRecordMap(' + childId + ' ' + juncObj.Id + '):' + childIdToRecordMap.get(childId));
                                        String parentId = (String) juncObj.get(parentRelationshipField);
                                        ResourceChildItem rci = resourceChildMap.get(parentId + childId);

                                        if (rci.files == null) {
                                            rci.files = new List<ContentVersion>();
                                        }
                                        System.debug('Adding for child Id (' + childId + ') Content Version Id (' + contentVersion.Id + ')');

                                        rci.files.add(contentVersion);
                                    }
                                }
                            }
                        }
                    }
                }
            }

        } catch (Exception e) {
            throw e;
        }

        return resourceItems;
    }

}