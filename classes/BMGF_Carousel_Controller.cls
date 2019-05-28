/**
* Carousel Controller for BMGF_Carousel lightning component
*
* @author  robert.truitt@Slalom.com
* @version 1.0
* @since   2/6/2017
*/


public without sharing class BMGF_Carousel_Controller {
    public class InvalidGroupException extends Exception {
    }

    /**
    * @description Class containg Carousel Items
    */
    public class CarouselContainer {
        @AuraEnabled
        public List<CarouselParentItem> carouselParentItems;

        @AuraEnabled
        public String errorMessage;

        @AuraEnabled
        public String comUrlPrefix {
            get {
                return BMGF_Resource_Helper.communityUrlPrefix;
            }
            set;
        }
    }

    /**
    * @description Class containing Parent Item (Resource Item)
    */
    public class CarouselParentItem {
        @AuraEnabled
        public List<CarouselItem> carouselItems;
    }

    /**
    * @description Class containing Carousel Items (All Files tied to Resource record)
    */
    public class CarouselItem {
        @AuraEnabled
        public String caption;

        @AuraEnabled
        public String assetUrl;

        @AuraEnabled
        public String linkUrl;

        @AuraEnabled
        public Boolean isVideo;

        @AuraEnabled
        public Boolean isEmbeddedVideo;

        @AuraEnabled
        public Id id;

        @AuraEnabled
        public Boolean isExpired;
    }

    /**
    * @description retrieve list of Carousel Items
    * @param recordId                   Record Id if specifically pulling one Parent record
    * @param parentObjectName           Parent Object Name
    * @param childObjectName            Child Object Name
    * @param junctionObjectName         Junction Object Name if required
    * @param parentRelationshipField    Parent relationship field for Junction Object if specified
    * @param childRelationshipField     Child relationship field for Junction object if specified
    * @param imageField                 Image field if not a file.  Should be rich text field with image only.
    * @param parentSearchExpr           Soql Search Expression for the parent object (use recordid for Id search)
    * @param childSearchExpr            Soql Search Expression for the child object (resource containing object)
    * @param junctionSearchExpr         Soql Search Expression for the junction object
    * @param captionField               Caption field (object.field)
    * @param linkField                  Link field, when image is clicked which link to go (object.field)
    * @param orderBy                    Order By Field (object.field)
    * @param isGroupPage                Specify if this is on a Group Page
    * @return CarouselContainer
    */
    @AuraEnabled
    public static CarouselContainer getCarouselItems(String recordId, String parentObjectName, String childObjectName,
            String junctionObjectName, String parentRelationshipField, String childRelationshipField,
            String imageField, String parentSearchExpr, String childSearchExpr, String junctionSearchExpr,
            String captionField, String linkField, String orderBy, Boolean isGroupPage, String groupNameField, String isVideoField,
            String isEmbeddedField) {
        CarouselContainer cc = new CarouselContainer();
        try {
            cc.carouselParentItems = new List<CarouselParentItem>();
            String searchRecordId = '';
            if (isGroupPage && String.isNotEmpty(recordId)) {
                CollaborationGroup[] groupList = [Select Name, CollaborationType from CollaborationGroup where Id = :recordId];

                if (!groupList.isEmpty()) {
                    if (groupList[0].CollaborationType != 'Public') {
                        Integer memberCount = [Select Count() from CollaborationGroupMember where MemberId = :UserInfo.getUserId() and CollaborationGroupId = :groupList[0].Id];
                        if (memberCount == 0) {
                            return cc;
                        }
                    }

                    try {
                        searchRecordId = [
                            SELECT Id
                            FROM PS_Group__c
                            WHERE CollaborationGroup_Id__c = :recordId
                        ].Id;
                    } catch (Exception e) {
                        System.debug(e.getMessage());
                        throw new InvalidGroupException('Unable to find group');
                    }


//                    String groupName = groupList[0].Name;
//                    String groupParentRecSpec = 'Select Id from ' + parentObjectName + ' where ' + groupNameField + ' = :groupName';
//                    SObject[] sobjList = Database.query(groupParentRecSpec);
//                    if (!sobjList.isEmpty()) {
//                        searchRecordId = sobjList[0].Id;
//                    } else {
//                        throw new InvalidGroupException('Unable to find group');
//                    }
                }
            } else {
                searchRecordId = recordId;
            }
            String queryFields = linkField + ',' + imageField + ',' + captionField + ',' + isVideoField + ',' + isEmbeddedField + ', Is_Expired__c';
            System.debug('BAZ');
            System.debug(queryFields);
            List<BMGF_Resource_Helper.ResourceItem> resourceItems = BMGF_Resource_Helper.getResources(parentObjectName, parentSearchExpr,
                    junctionObjectName, junctionSearchExpr, parentRelationshipField, childRelationshipField, childObjectName, childSearchExpr,
                    queryFields, searchRecordId, orderBy);

            for (BMGF_Resource_Helper.ResourceItem resourceItem : resourceItems) {
                CarouselParentItem cpi = new CarouselParentItem();
                cpi.carouselItems = new List<CarouselItem>();

                System.debug('FOOBAZ');
                System.debug(resourceItem);

                Map<String, SObject> typeToObjectMap = new Map<String, SObject>();
                if (resourceItem.parentObject != null) {
                    typeToObjectMap.put(resourceItem.parentObject.getSObjectType().getDescribe().getName(), resourceItem.parentObject);
                }
                if (!resourceItem.childItems.isEmpty()) {
                    System.debug('resourceItem.childItems size' + resourceItem.childItems.size());
                    for (BMGF_Resource_Helper.ResourceChildItem rci : resourceItem.childItems) {
                        System.debug('FOO');
                        System.debug(rci);
                        typeToObjectMap.put(rci.childObject.getSObjectType().getDescribe().getName(), rci.childObject);
                        if (rci.junctionObject != null) typeToObjectMap.put(rci.junctionObject.getSObjectType().getDescribe().getName(), rci.junctionObject);
                        if (!String.isNotEmpty(isVideoField) || getFieldValueStripObject(childObjectName, isVideoField, rci.childObject) != 'true') {
                            if (String.isNotEmpty(imageField)) {
                                CarouselItem carouselItem = new CarouselItem();
                                String richTextField = getFieldValueStripObject(childObjectName, imageField, rci.childObject);
                                if (String.isNotEmpty(richTextField)) {
                                    carouselItem.assetUrl = richTextField.substringBetween('src="', '"').unescapeHtml4();
                                    System.debug('adding imageField carouselItem');
                                    carouselItem.caption = captionBuilder(typeToObjectMap, captionField);
                                    carouselItem.linkUrl = getLink(typeToObjectMap, linkField);
                                    carouselItem.id = rci.childObject.Id;
                                    carouselItem.isExpired = (Boolean) rci.childObject.get('Is_Expired__c');
                                    cpi.carouselItems.add(carouselItem);
                                }
                            } else {
                                if ( !rci.files.isEmpty() ) {
                                    ContentVersion resourceFile = rci.files[0];
                                    typeToObjectMap.put('ContentVersion', resourceFile);
                                    CarouselItem carouselItem = new CarouselItem();
                                    carouselItem.assetUrl = BMGF_Resource_Helper.communityUrl + BMGF_Resource_Helper.FILE_URL_PREFIX + resourceFile.Id;
                                    System.debug(carouselItem.assetUrl);
                                    carouselItem.caption = captionBuilder(typeToObjectMap, captionField);
                                    carouselItem.linkUrl = getLink(typeToObjectMap, linkField);
                                    carouselItem.id = rci.childObject.Id;
                                    carouselItem.isExpired = (Boolean) rci.childObject.get('Is_Expired__c');
                                    cpi.carouselItems.add(carouselItem);
                                } else {
                                    //resource without a file
                                    CarouselItem carouselItem = new CarouselItem();
//                                    carouselItem.assetUrl = BMGF_Resource_Helper.communityUrl + BMGF_Resource_Helper.FILE_URL_PREFIX + resourceFile.Id;
//                                    System.debug(carouselItem.assetUrl);
                                    carouselItem.caption = captionBuilder(typeToObjectMap, captionField);
                                    carouselItem.linkUrl = getLink(typeToObjectMap, linkField);
                                    carouselItem.id = rci.childObject.Id;
                                    carouselItem.isExpired = (Boolean) rci.childObject.get('Is_Expired__c');
                                    cpi.carouselItems.add(carouselItem);
                                }

                                //OLD VERSION
//                                for (ContentVersion resourceFile : rci.files) {
//                                    typeToObjectMap.put('ContentVersion', resourceFile);
//                                    CarouselItem carouselItem = new CarouselItem();
//                                    carouselItem.assetUrl = BMGF_Resource_Helper.communityUrl + BMGF_Resource_Helper.FILE_URL_PREFIX + resourceFile.Id;
//                                    System.debug(carouselItem.assetUrl);
//                                    carouselItem.caption = captionBuilder(typeToObjectMap, captionField);
//                                    carouselItem.linkUrl = getLink(typeToObjectMap, linkField);
//                                    carouselItem.id = rci.childObject.Id;
//                                    carouselItem.isExpired = (Boolean) rci.childObject.get('Is_Expired__c');
//                                    cpi.carouselItems.add(carouselItem);
//                                }
                            }
                        } else {
                            CarouselItem carouselItem = new CarouselItem();
                            carouselItem.assetUrl = getLink(typeToObjectMap, linkField);
                            carouselItem.isEmbeddedVideo = getFieldValueStripObject(childObjectName, isEmbeddedField, rci.childObject) == 'true';
                            carouselItem.isVideo = true;
                            carouselItem.caption = captionBuilder(typeToObjectMap, captionField);
                            carouselItem.id = rci.childObject.Id;
                            carouselItem.isExpired = (Boolean) rci.childObject.get('Is_Expired__c');
                            cpi.carouselItems.add(carouselItem);
                            System.debug('video found' + carouselItem);
                        }

                    }
                    if (!cpi.carouselItems.isEmpty()) {
                        cc.carouselParentItems.add(cpi);
                    }
                }
            }
        } catch (InvalidGroupException ige) {
            //group doesnt' exist in GP Pages, no need to raise error to user
        }
        return cc;
    }

    /**
    * @description building caption for carousel items, caption fields are object.field and matched to
    *               object by name
    * @param typeToObjectMap    Map of object Name to SObject
    * @param captionFields      Caption Fields in order
    * @return String with caption
    */
    public static String captionBuilder(Map<String, SObject> typeToObjectMap, String captionFields) {
        /*
         * messy fix to get around how the captions are implemented
         */
        String captionString = '';

        if ( 'PS_Group_Resource__c.Carousel_Caption__c,PS_Group_Resource__c.Carousel_Description__c' == captionFields ) {
            Set<String> captionFieldset = new Set<String>(captionFields.split(','));
            for (String captionField : captionFieldset) {
                if (captionField.contains('.')) {
                    String objectName = captionField.substringBefore('.');
                    String captionFieldstripped = captionField.toLowerCase().replace(objectName.toLowerCase() + '.', '').trim();
                    SObject sObj = typeToObjectMap.get(objectName);
                    if (sObj != null) {
                        if ('Carousel_Caption__c' == captionFieldstripped ) {
                            if ( null != sObj.get(captionFieldstripped) ) {
                                captionString += '<h1 class="carousel_caption">' + String.valueOf(sObj.get(captionFieldstripped)).trim() + '</h1>';
                            }
                        } else {
                            if ( null != sObj.get(captionFieldstripped) ) {
                                captionString += '<h2 class="carousel_description">' + String.valueOf(sObj.get(captionFieldstripped)).trim() + '</h2>';
                            }
                        }
                    }
                }
            }
        } else {
            //default behavior
            if (String.isNotEmpty(captionFields)) {
                System.debug('in captionBuilder');
                Set<String> captionFieldset = new Set<String>(captionFields.split(','));
                System.debug('captionFieldsetSize:' + captionFieldset.size());
                for (String captionField : captionFieldset) {
                    if (captionField.contains('.')) {
                        String objectName = captionField.substringBefore('.');
                        String captionFieldstripped = captionField.toLowerCase().replace(objectName.toLowerCase() + '.', '').trim();
                        SObject sObj = typeToObjectMap.get(objectName);
                        if (sObj != null) {
                            try {
                                System.debug(sObj);
                                String caption = String.valueOf(sObj.get(captionFieldstripped)).trim();
                                if (String.isNotEmpty(caption)) {
                                    captionString += String.isEmpty(captionString) ? caption : '<br/>' + caption;
                                }
                            } catch (Exception ex) {
                                // throw ex;
                            }
                        }
                    }
                }
            }
        }
        return captionString.unescapeHtml4();
    }

    /**
    * @description Retrieve link from objects. link is specified as object.field
    * @param typeToObjectMap    Map of object Name to SObject
    * @param linkField          Link Field
    * @return String with url combined with communityUrl if Id
    */
    public static String getLink(Map<String, SObject> typeToObjectMap, String linkField) {
        String linkUrl = '';
        String objectName = linkField.substringBefore('.');

        String linkFieldStripped = linkField.toLowerCase().replace(objectName.toLowerCase() + '.', '').trim();
        SObject sObj = typeToObjectMap.get(objectName);
        if (sObj != null) {
            try {
                System.debug(sObj);
                String fieldValue = String.valueOf(sObj.get(linkFieldStripped)).trim();
                linkUrl = linkFieldStripped.equalsIgnoreCase('Id') ? BMGF_Resource_Helper.communityUrl + '/' + fieldValue : fieldValue;
            } catch (Exception ex) {
                // throw ex;
            }

        }
        return linkUrl;
    }

    /**
    * @description Get Value from object after stripping object name. ex: Account.Name specified returning Gates Foundation
    * @param objectName    Map of object Name to SObject
    * @param fieldString   Name of Field with Object possibly specified as prefix
    * @param obj           Object to retrieve field value
    * @return String with field Value
    */
    private static String getFieldValueStripObject(String objectName, String fieldString, SObject obj) {
        if (String.isNotEmpty(fieldString)) {
            return (String) String.valueOf(obj.get(fieldString.trim().toLowerCase().replace(objectName.trim().toLowerCase() + '.', '')));
        } else {
            return '';
        }
    }

    @AuraEnabled
    public static String getRecords(List<Id> records) {
        return JSON.serialize(CarouselHelper.getRecords(records));
    }
}