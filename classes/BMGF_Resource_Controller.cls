/**
* Controller to handle resource list for lightning components BMGF_Resources, BMGF_Videos
*
* @author  robert.truitt@Slalom.com
* @version 1.0
* @since   2/22/2017
*/

public with sharing class BMGF_Resource_Controller {
    /**
    * @description List of image formats for font awesome selector/could be used for other things in future
    */
    private static Set<String> imageFormats = new Set<String>{
            'JPG', 'PNG', 'BMP', 'TIFF', 'TIF', 'SVG', 'GIF'
    };

    /**
    * @description List of video formats for font awesome selector/could be used for other things in future
    */
    private static Set<String> videoFormats = new Set<String>{
            '0.264', '3G2', '3GP', '3GP2', '3GPP', '3GPP2', '3MM', '3P2', '60D', '0.787', '0.89', 'AAF', 'AEC',
            'AEP', 'AEPX', 'AET', 'AETX', 'AJP', 'ALE', 'AM', 'AMC', 'AMV', 'AMX', 'ANIM', 'ANX', 'AQT', 'ARCUT',
            'ARF', 'ASF', 'ASX', 'AVB', 'AVC', 'AVCHD', 'AVD', 'AVI', 'AVM', 'AVP', 'AVS', 'AVS', 'AVV', 'AWLIVE',
            'AXM', 'AXV', 'BDM', 'BDMV', 'BDT2', 'BDT3', 'BIK', 'BIN', 'BIX', 'BMC', 'BMK', 'BNP', 'BOX', 'BS4',
            'BSF', 'BU', 'BVR', 'BYU', 'CAMPROJ', 'CAMREC', 'CAMV', 'CED', 'CEL', 'CINE', 'CIP', 'CLK', 'CLPI',
            'CMMP', 'CMMTPL', 'CMPROJ', 'CMREC', 'CMV', 'CPI', 'CPVC', 'CST', 'CVC', 'CX3', 'D2V', 'D3V', 'DASH',
            'DAT', 'DAV', 'DB2', 'DCE', 'DCK', 'DCR', 'DCR', 'DDAT', 'DIF', 'DIR', 'DIVX', 'DLX', 'DMB', 'DMSD',
            'DMSD3D', 'DMSM', 'DMSM3D', 'DMSS', 'DMX', 'DNC', 'DPA', 'DPG', 'DREAM', 'DSY', 'DV', 'DV-AVI', 'DV4',
            'DVDMEDIA', 'DVR', 'DVR-MS', 'DVX', 'DXR', 'DZM', 'DZP', 'DZT', 'EDL', 'EVO', 'EVO', 'EXO', 'EYE',
            'EYETV', 'EZT', 'F4F', 'F4P', 'F4V', 'FBR', 'FBR', 'FBZ', 'FCARCH', 'FCP', 'FCPROJECT', 'FFD', 'FFM',
            'FLC', 'FLH', 'FLI', 'FLIC', 'FLV', 'FLX', 'FPDX', 'FTC', 'G2M', 'G64', 'GCS', 'GFP', 'GIFV', 'GL',
            'GOM', 'GRASP', 'GTS', 'GVI', 'GVP', 'GXF', 'H264', 'HDMOV', 'HDV', 'HKM', 'IFO', 'IMOVIELIBRARY',
            'IMOVIEMOBILE', 'IMOVIEPROJ', 'IMOVIEPROJECT', 'INP', 'INT', 'IRCP', 'IRF', 'ISM', 'ISMC', 'ISMCLIP',
            'ISMV', 'IVA', 'IVF', 'IVR', 'IVS', 'IZZ', 'IZZY', 'JMV', 'JSS', 'JTS', 'JTV', 'K3G', 'KDENLIVE', 'KMV',
            'KTN', 'LREC', 'LRV', 'LSF', 'LSX', 'LVIX', 'M15', 'M1PG', 'M1V', 'M21', 'M21', 'M2A', 'M2P', 'M2T',
            'M2TS', 'M2V', 'M4E', 'M4U', 'M4V', 'M75', 'MANI', 'META', 'MGV', 'MJ2', 'MJP', 'MJPEG', 'MJPG', 'MK3D',
            'MKV', 'MMV', 'MNV', 'MOB', 'MOD', 'MODD', 'MOFF', 'MOI', 'MOOV', 'MOV', 'MOVIE', 'MP21', 'MP21',
            'MP2V', 'MP4', 'MP4.INFOVID', 'MP4V', 'MPE', 'MPEG', 'MPEG1', 'MPEG2', 'MPEG4', 'MPF', 'MPG', 'MPG2',
            'MPG4', 'MPGINDEX', 'MPL', 'MPL', 'MPLS', 'MPROJ', 'MPSUB', 'MPV', 'MPV2', 'MQV', 'MSDVD', 'MSE', 'MSH',
            'MSWMM', 'MT2S', 'MTS', 'MTV', 'MVB', 'MVC', 'MVD', 'MVE', 'MVEX', 'MVP', 'MVP', 'MVY', 'MXF', 'MXV',
            'MYS', 'N3R', 'NCOR', 'NFV', 'NSV', 'NTP', 'NUT', 'NUV', 'NVC', 'OGM', 'OGV', 'OGX', 'ORV', 'OSP',
            'OTRKEY', 'PAC', 'PAR', 'PDS', 'PGI', 'PHOTOSHOW', 'PIV', 'PJS', 'PLAYLIST', 'PLPROJ', 'PMF', 'PMV',
            'PNS', 'PPJ', 'PREL', 'PRO', 'PRO4DVD', 'PRO5DVD', 'PROQC', 'PRPROJ', 'PRTL', 'PSB', 'PSH', 'PSSD',
            'PVA', 'PVR', 'PXV', 'QT', 'QTCH', 'QTINDEX', 'QTL', 'QTM', 'QTZ', 'R3D', 'RCD', 'RCPROJECT', 'RCREC',
            'RCUT', 'RDB', 'REC', 'RM', 'RMD', 'RMD', 'RMP', 'RMS', 'RMV', 'RMVB', 'ROQ', 'RP', 'RSX', 'RTS', 'RTS',
            'RUM', 'RV', 'RVID', 'RVL', 'SAN', 'SBK', 'SBT', 'SBZ', 'SCC', 'SCM', 'SCM', 'SCN', 'SCREENFLOW', 'SDV',
            'SEC', 'SEC', 'SEDPRJ', 'SEQ', 'SFD', 'SFERA', 'SFVIDCAP', 'SIV', 'SMI', 'SMI', 'SMIL', 'SMK', 'SML',
            'SMV', 'SNAGPROJ', 'SPL', 'SQZ', 'SRT', 'SSF', 'SSM', 'STL', 'STR', 'STX', 'SVI', 'SWF', 'SWI', 'SWT',
            'TDA3MT', 'TDT', 'TDX', 'THEATER', 'THP', 'TID', 'TIVO', 'TIX', 'TOD', 'TP', 'TP0', 'TPD', 'TPR',
            'TREC', 'TRP', 'TS', 'TSP', 'TTXT', 'TVLAYER', 'TVRECORDING', 'TVS', 'TVSHOW', 'USF', 'USM', 'V264',
            'VBC', 'VC1', 'VCPF', 'VCR', 'VCV', 'VDO', 'VDR', 'VDX', 'VEG', 'VEM', 'VEP', 'VF', 'VFT', 'VFW', 'VFZ',
            'VGZ', 'VID', 'VIDEO', 'VIEWLET', 'VIV', 'VIVO', 'VIX', 'VLAB', 'VMLF', 'VMLT', 'VOB', 'VP3', 'VP6',
            'VP7', 'VPJ', 'VR', 'VRO', 'VS4', 'VSE', 'VSP', 'VTT', 'W32', 'WCP', 'WEBM', 'WFSP', 'WGI', 'WLMP',
            'WM', 'WMD', 'WMMP', 'WMV', 'WMX', 'WOT', 'WP3', 'WPL', 'WSVE', 'WTV', 'WVE', 'WVX', 'WXP', 'XEJ',
            'XEL', 'XESC', 'XFL', 'XLMV', 'XML', 'XMV', 'XVID', 'Y4M', 'YOG', 'YUV', 'ZEG', 'ZM1', 'ZM2', 'ZM3', 'ZMV'
    };

    /**
    * @description Exception class for group record not existing in GP_Pages object
    */
    public class InvalidGroupException extends Exception {
    }

    /**
    * @description Class representing a single resource, sorted by groupnames if specified
    */
    public class ResourceRecord implements Comparable {
        public ResourceRecord() {
            groupByValues = new List<String>();
            isNewGroup = false;
            newGroupIndex = 0;
        }
        @AuraEnabled
        public List<String> groupByValues;
        @AuraEnabled
        public ContentVersion file;
        @AuraEnabled
        public String fileUrl;
        @AuraEnabled
        public Boolean isNewGroup;
        @AuraEnabled
        public Integer newGroupIndex;
        @AuraEnabled
        public String newGroupValue;
        @AuraEnabled
        public String fileDescription;
        @AuraEnabled
        public String fontAwesomeIcon;
        @AuraEnabled
        public Boolean isPhoto;
        @AuraEnabled
        public String orderByValue;
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public Boolean display;
        @AuraEnabled
        public String excludedProfiles;

        /**
        * @description Sort resource record by specified group by values
        * @param compareTo   ResourceRecord object to compare this to
        * @return 1, 0, -1  for greater equal or lower
        */
        public Integer compareTo(Object compareTo) {
            ResourceRecord compareToRsr = (ResourceRecord) compareTo;
            for (Integer i = 0; i < groupByValues.size(); i++) {
                System.debug('inside Comparable compareTo: CurObject Value:' + groupByValues[i] + ' compare to value:' + compareToRsr.groupByValues[i]);
                if (groupByValues[i] == compareToRsr.groupByValues[i]) {
                    continue;
                } else if (groupByValues[i] > compareToRsr.groupByValues[i]) {
                    return 1;
                } else if (groupByValues[i] < compareToRsr.groupByValues[i]) {
                    return -1;
                }
            }
            if (orderByValue > compareToRsr.orderByValue) {
                return 1;
            } else if (orderByValue < compareToRsr.orderByValue) {
                return -1;
            }

            return 0;
        }
    }

    /**
    * @description For specifying where group changes occur.  This marks a new grouping of resources
    * @param resourceRecords  List or records to process
    */
    private static void markGroupChange(List<ResourceRecord> resourceRecords) {
        for (Integer i = 0; i < resourceRecords.size() - 1; i++) {
            for (Integer j = 0; j < resourceRecords[i].groupByValues.size(); j++) {
                if (resourceRecords[i].groupByValues[j] != resourceRecords[i + 1].groupByValues[j]) {
                    resourceRecords[i + 1].isNewGroup = true;
                    resourceRecords[i + 1].newGroupValue = resourceRecords[i + 1].groupByValues[j];
                    resourceRecords[i + 1].newGroupIndex = j;
                    break;
                }
            }
        }
        //set first record as new group
        if (!resourceRecords.isEmpty())
            resourceRecords[0].isNewGroup = true;
    }

    /**
    * @description retrieve list of Resource Records(Items)
    * @param recordId                   Record Id if specfically pulling one Parent record
    * @param parentObjectName           Parent Object Name
    * @param childObjectName            Child Object Name
    * @param junctionObjectName         Junction Object Name if required
    * @param parentRelationshipField    Parent relatinship field for Junction Object if specified
    * @param childRelationshipField     Child relationship field for Junction object if specified
    * @param parentSearchExpr           Soql Search Expression for the parent object (use recordid for Id search)
    * @param childSearchExpr            Soql Search Expression for the child object (resource containing object)
    * @param photoVideoUrlField         Photo or Video resource url field
    * @param descriptionField           Description field (object.field)
    * @param groupByFields              Fields to group resources by. Sorted in order of input
    * @param orderBy                    Order By Field (obect.field)
    * @param isGroupPage                Specify if this is on a Group Page
    * @return List of sorted resource records marked by group change
    */
    @AuraEnabled
    public static List<ResourceRecord> getResources(String recordId, String parentObjectName, String childObjectName,
            String junctionObjectName, String parentRelationshipField, String childRelationshipField,
            String parentSearchExpr, String childSearchExpr, String junctionSearchExpr, String photoVideoUrlField, String descriptionField,
            String groupByFields, String orderBy, Boolean isGroupPage, String groupNameField) {
        List<ResourceRecord> rsrList = new List<ResourceRecord>();
        String searchRecordId = '';


        try {
            if (isGroupPage && String.isNotEmpty(recordId)) {
                CollaborationGroup[] groupList = [Select Name, CollaborationType, (Select Id from GroupMembers where MemberId = :UserInfo.getUserId()) from CollaborationGroup where Id = :recordId];

                if (!groupList.isEmpty()) {
                    CollaborationGroup cg = groupList[0];

                    if (cg.CollaborationType != 'Public' && cg.GroupMembers.isEmpty()) {
                        return null;
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

//                    String groupParentRecSpec = 'Select Id from ' + parentObjectName + ' where ' + groupNameField + ' = \'' + cg.Name + '\'';
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

            String queryFields = photoVideoUrlField + ',' + descriptionField + ',' + groupByFields + ', Excluded_Profiles__c';
            List<BMGF_Resource_Helper.ResourceItem> resourceItems = BMGF_Resource_Helper.getResources(parentObjectName, parentSearchExpr,
                    junctionObjectName, junctionSearchExpr, parentRelationshipField, childRelationshipField, childObjectName, childSearchExpr,
                    queryFields, searchRecordId, orderBy);

            rsrList = buildResourcesToSortList(resourceItems, groupByFields, descriptionField, photoVideoUrlField, orderBy);
            rsrList.sort();
            markGroupChange(rsrList);
        } catch (InvalidGroupException ige) {
            //Group record does not exist. No need to raise error to user.
        }
        return rsrList;
    }

    /**
    * @description Takes records returned from resource helper and populates a list of Resource Record to sort
    * @param resourceItems          List of resource Items
    * @param groupByFields          Fields to group by
    * @param descriptionField       description field/resource name
    * @param photoVideoUrlField     photo or video external url field
    * @return List of ResourceRecord
    */
    private static List<ResourceRecord> buildResourcesToSortList(List<BMGF_Resource_Helper.ResourceItem> resourceItems,
            String groupByFields, String descriptionField, String photoVideoUrlField, String orderByField) {
        List<ResourceRecord> rsrList = new List<ResourceRecord>();

        Set<String> groupFields = new Set<String>();
        if (String.isNotEmpty(groupByFields)) {
            groupFields = new Set<String>(groupByFields.split(','));
        }

        for (BMGF_Resource_Helper.ResourceItem resourceItem : resourceItems) {
            if (resourceItem.childItems != null && !resourceItem.childItems.isEmpty()) {
                for (BMGF_Resource_Helper.ResourceChildItem rci : resourceItem.childItems) {

                    Map<String, SObject> objectMap = new Map<String, SObject>();
                    objectMap.put(resourceItem.parentObject.getSObjectType().getDescribe().getName(), resourceItem.parentObject);
                    if (rci.childObject != null) objectMap.put(rci.childObject.getSObjectType().getDescribe().getName(), rci.childObject);
                    if (rci.junctionObject != null) objectMap.put(rci.junctionObject.getSObjectType().getDescribe().getName(), rci.junctionObject);


                    if (rci.files != null && !rci.files.isEmpty()) {
                        String parentObjName = resourceItem.parentObject.getSObjectType().getDescribe().getName();
                        String childObjName = rci.childObject != null ? rci.childObject.getSObjectType().getDescribe().getName() : '';
                        String juncObjName = rci.junctionObject != null ? rci.junctionObject.getSObjectType().getDescribe().getName() : '';
                        for (ContentVersion file : rci.files) {
                            objectMap.put('ContentVersion', file);
                            List<String> groupValues = new List<String>();
                            ResourceRecord rsr = new ResourceRecord();
                            rsr.file = file;
                            for (String groupField : groupFields) {
                                groupValues.add(findFieldValue(groupField, objectMap));
                            }
                            rsr.fileUrl = BMGF_Resource_Helper.communityUrl + BMGF_Resource_Helper.FILE_URL_PREFIX + file.Id;
                            if (String.isNotEmpty(file.FileType)) {
                                rsr.fontAwesomeIcon = fontAwesomeSelector(file.FileType);
                                rsr.isPhoto = imageFormats.contains(file.FileType.toUpperCase());
                            }
                            rsr.groupByValues = groupValues;
                            rsr.fileDescription = findFieldValue(descriptionField, objectMap);
                            rsr.orderByValue = findFieldValue(orderByField, objectMap);
                            rsr.id = rci.childObject.Id;
                            rsr.display = true;
                            rsr.excludedProfiles = findFieldValue('PS_Group_Resource__c.Excluded_Profiles__c', objectMap);
                            if (rsr.fileUrl != null)
                                rsrList.add(rsr);
                        }
                    } else {
//                    if (String.isNotEmpty(photoVideoUrlField)) {

                        //clear contentversion from objectmap if it exists
                        objectMap.remove('ContentVersion');

                        List<String> groupValues = new List<String>();
                        ResourceRecord rsr = new ResourceRecord();
                        rsr.fileUrl = findFieldValue(photoVideoUrlField, objectMap);


                        if (String.isNotEmpty(rsr.fileUrl)) {
                            if (imageFormats.contains(rsr.fileUrl.substringAfterLast('.').toUpperCase())) {
                                rsr.isPhoto = true;
                                rsr.fontAwesomeIcon = 'fa-file-image-o';
                            } else {
                                rsr.fontAwesomeIcon = 'fa-link';
                            }
                            rsr.fileDescription = findFieldValue(descriptionField, objectMap);
                            rsr.orderByValue = findFieldValue(orderByField, objectMap);
                            rsr.id = rci.childObject.Id;
                            for (String groupField : groupFields) {
                                groupValues.add(findFieldValue(groupField, objectMap));
                            }
                            rsr.groupByValues = groupValues;
                            rsr.display = String.isNotEmpty(photoVideoUrlField);
                            rsr.excludedProfiles = findFieldValue('PS_Group_Resource__c.Excluded_Profiles__c', objectMap);
                            rsrList.add(rsr);
                        } else {
                            rsr.excludedProfiles = findFieldValue('PS_Group_Resource__c.Excluded_Profiles__c', objectMap);
                            rsr.display = false;
                            rsr.fontAwesomeIcon = '';
                            rsr.fileDescription = findFieldValue(descriptionField, objectMap);
                            rsr.orderByValue = findFieldValue(orderByField, objectMap);
                            rsr.id = rci.childObject.Id;
                            for (String groupField : groupFields) {
                                groupValues.add(findFieldValue(groupField, objectMap));
                            }
                            rsr.groupByValues = groupValues;
                            rsrList.add(rsr);
                        }
                    }
                }
            }
            System.debug('resourceSortList' + rsrList);
        }
        return rsrList;
    }

    /**
    * @description find field and it's value from an object map (parent/child/junc/files)
    * @param objectFieldLocation    Field full path  object.field
    * @param objectMap              Map of objects (parent/child/junc/files)
    * @return field value if found
    */
    private static String findFieldValue(String objectFieldLocation, Map<String, SObject> objectMap) {
        String fieldValue = '';
        String objectName = objectFieldLocation.substringBefore('.').trim();
        String fieldName = objectFieldLocation.substringAfter('.').trim();
        try {
            if (objectMap.get(objectName) != null) {
                fieldValue = (String) objectMap.get(objectName).get(fieldName);
            }
        } catch (Exception ex) {
            fieldValue = '';
        }
        return fieldValue;

    }

    /**
    * @description figures out which font awesome icon to show
    * @param fileType    file extension
    * @return font awesome class name
    */
    private static String fontAwesomeSelector(String fileType) {

        String fontAwesomeIconClass = '';
        if (fileType.toUpperCase().contains('DOC') || fileType.toUpperCase().contains('WORD')) {
            fontAwesomeIconClass = 'fa-file-word-o';
        }
        if (fileType.toUpperCase().contains('XLS') || fileType.toUpperCase().contains('EXCEL')) {
            fontAwesomeIconClass = 'fa-file-excel-o';
        }
        if (fileType.toUpperCase().contains('PDF')) {
            fontAwesomeIconClass = 'fa-file-pdf-o';
        }
        //salesforce uses POWER_POINT_X instead of PPT*
        if (fileType.toUpperCase().contains('PPT') || fileType.toUpperCase().contains('POWER_POINT')) {
            fontAwesomeIconClass = 'fa-file-powerpoint-o';
        }
        if (imageFormats.contains(fileType.toUpperCase())) {
            fontAwesomeIconClass = 'fa-file-image-o';
        }

        if (videoFormats.contains(fileType.toUpperCase())) {
            fontAwesomeIconClass = 'fa-file-movie-o';
        }

        return fontAwesomeIconClass;
    }

    @AuraEnabled
    public static String getRecords(List<Id> records) {
        return JSON.serialize(CarouselHelper.getRecords(records));
    }

    @AuraEnabled
    public static String getUserProfile() {
        return [
            SELECT Name
            FROM Profile
            WHERE Id = :UserInfo.getProfileId()
        ].Name;
    }
}