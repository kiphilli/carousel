# carousel

Installation url
https://test.salesforce.com/packaging/installPackage.apexp?p0=04t3D000000FGpH

Post installation steps:
* create new record called Documents for the Resource CMS Documents custom setting
* Image optimization file is hosted at https://na50.salesforce.com/sfc/p/6A000000vBIJ/a/6A0000008TKV/RjkYxG2RW3yvVj25aKk3NkM0IVYswEBuWR51Pxk3VvY
* Video embed field is hosted at https://na50.salesforce.com/sfc/p/6A000000vBIJ/a/6A0000008TKa/N43PQpjHjWOM6l_lf5DUNVaFICk4tudFmRq1dRsVpTg

Config
Default:
* isGroupPage - set to true if used on CollaborationGroup page detail
* groupNameField - default value should be set to Group_Name__c
* captionField - default value should be set to PS_Group_Resource__c.Carousel_Caption__c,PS_Group_Resource__c.Carousel_Description__c

Video:
* isGroupPage - set to true if used on CollaborationGroup page detail
* groupNameField - default value should be set to Group_Name__c
* childSearchExpr - set to Type__c = 'Video Carousel'
* isVideoField - set to PS_Group_Resource__c.Video_Flag__c
* imageHeight - to to a pixel value e.g. 250px

Photo:
* isGroupPage - set to true if used on CollaborationGroup page detail
* groupNameField - default value should be set to Group_Name__c
* childSearchExpr - set to Type__c = 'Carousel Photo'

Resource:
* isGroupPage - set to true if used on CollaborationGroup page detail
* groupNameField - default value should be set to Group_Name__c
* childSearchExpr - set to Type__c = 'Resource'
* photoVideoUrlField - set to PS_Group_Resource__c.External_URL__c
* descriptionField - set to PS_Group_Resource__c.Description__c
*groupByFields - set to PS_Group_Resource__c.Resource_Grouping_Name__c
