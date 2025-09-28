/**
    **********************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    15/10/2023        Umesh Chakranarayan           Udpate after package 4 for Keyvalue and init
    **********************************************************************************************************************
*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class KeyContactEditCtrl  extends ExtensibleGenericCtrl {
    private Id recordId {get; set;}
    private String flexTableName {get; set;}
    private List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues;
    
    // Private variables for internal use only
    private String organizationId;
    private Set<String> accIds = new Set<String>();
    private List<String> accountIdList = new List<String>();
    
    // Object variables - keeping only what's used
    private Program__c programObj;
    private Id grantorRecordTypeId;
    
    // URL parameter variables
    private Id programId;
    private Map<String,String> paramValueMap = new Map<String,String>();

    @SuppressWarnings('PMD.EmptyStatementBlock')
    global KeyContactEditCtrl(){
        super();
    }

    global virtual override void beforeExecution() {
        recordId = lightningObject.currentRecordId;
        if(String.isNotBlank(lightningObject.currentPageUrl)){                           
            paramValueMap = AppUtils.getUrlParamLWC(lightningObject.currentPageUrl);                
            programId = paramValueMap.get('programId');
            if(recordId == null){
                recordId = paramValueMap.get('id'); 
            }
        }  
         if(programId != null) {
            programObj = [SELECT Id, Account__c,Account__r.ParentId, Status__c FROM Program__c WHERE Id =: programId WITH USER_MODE];          
            accIds.add(programObj.Account__c);
            accIds.add(programObj.Account__r.ParentId);
            accIds.remove(null);
           // added by umesh for UT
            accountIdList.add(programObj.Account__c);
            accountIdList.add(programObj.Account__r.ParentId);
            organizationId = programObj.Account__c;
        }  
    }
    global virtual override void setPageTemplate() {
        lightningObject.flexTableName = 'AssociateProgramContacts';
    }
    global virtual override void setDefaultValues() {
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        grantorRecordTypeId = Schema.SObjectType.KeyContacts__c.getRecordTypeInfosByName().get('Grantor').getRecordTypeId();
        // Set default values for grantor users
        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper ('RecordTypeId', grantorRecordTypeId, true);
        listDefaultValues.add(dv1);
        lightningObject.listDefaultValuesLightning = listDefaultValues;
    }
    global virtual override void setKeyValueMap() {
        lightningObject.keyValueMap = getKeyValueMap();
    }
    global virtual override void setListParam() {
        lightningObject.listValueMap = getListParams();
    }
   
    private string getListParams(){
        Map<String,set<String>> listParams = new Map<String,set<String>>();
        set<String> selectedContacts = new set<String>();
         if(programId != null){ 
             for(KeyContacts__c progCt:  [SELECT Id,Contact__c FROM KeyContacts__c WHERE Program__c= :programId WITH USER_MODE] ){
                selectedContacts.add(progCt.Contact__c);
            }
        }
        listParams.put('accountIds',accIds);
        listParams.put('selectedContacts',selectedContacts);
        return JSON.serialize(listParams);
    }

    private string getKeyValueMap() {
        Map<String, Object> keyValueMap = new Map<String, Object>();
        keyValueMap.put('agencyId', organizationId);
        keyValueMap.put('keycontactid',recordId); // Added form View Ctrl 
        keyValueMap.put('programId',programId);
        return JSON.serialize(keyValueMap);
    }
} 

/*
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class KeyContactEditCtrl extends GNT.GenericCtrl {
    public Id recordId {get; set;}
    public String pageTemplateName {get; set;}
    public String flexTableName {get; set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get; set;}
    public string organizationId;
    public Set<String> recordsIdSet = new Set<String>();
    public Boolean showTable{get;set;}
    public Set<String> accIds = new Set<String>();
    public List<String> accountIdList= new List<String>();
    public Set<String> contactIdSet = new Set<String>(); // Umesh Converted this id in to String of set
    
    private Application__c applicationObj;
    private PreApplication__c preAppObj;
    private ProgressReports__c progressrpt;
    private Announcement__c annoucementobj;
    private Program__c programObj;
    private Award__c award;
    private AmendmentRequest__c amdRequest;
    private SiteVisit__c siteVisit;
    private Set<Id> userIdSet {get; set;}
    private String contactGroupCode {get; set;}
    private Id grantorRecordTypeId{get;set;}
    private Id granteeRecordTypeId{get;set;}
    private String module;
    private Id applicationId; 
    private Id progressreportId;
    private Id annoucementId; 
    private Id programId;
    private Id preApplicationId;
    private Id siteVisitId; 
    private Id awardId;
    private Id amendId; 
    private Id formId;
    private String appName;
    private Map<String,String> paramValueMap = new Map<String,String>();
    private RecordType recordType;     
    private String templateName;

    @SuppressWarnings('PMD.EmptyStatementBlock')
    global KeyContactEditCtrl(){}

    public override String init(){ 
        recordId = lightningObject.currentRecordId;
        if(String.isNotBlank(lightningObject.currentPageUrl)){                           
            paramValueMap = AppUtils.getUrlParamLWC(lightningObject.currentPageUrl);                
            applicationId = paramValueMap.get('applicationid');
            progressreportId = paramValueMap.get('progressreportId');
            annoucementId = paramValueMap.get('annoucementId');
            programId = paramValueMap.get('programId');
            preApplicationId = paramValueMap.get('preapplicationid');
            siteVisitId = paramValueMap.get('siteVisitId');
            awardId = paramValueMap.get('awardId');
            amendId = paramValueMap.get('amendId');
            formId = paramValueMap.get('formId');
            module = paramValueMap.get('reqType');
            templateName = paramValueMap.get('template');
            organizationId = paramValueMap.get('orgId');
            if(recordId == null){
                recordId = paramValueMap.get('id'); 
            }
        } 
        appName = GenericStaticUtility.getUserPreferenceField(GenericStaticUtility.USER_PREFERENCE_FIELD_ACTIVE_APP_NAME);
        showTable = false;
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if (applicationId != null) {
            applicationObj = [SELECT Id, FederalAwardingAgency__c, Status__c, ExternalOrganization__c FROM Application__c WHERE Id = : applicationId WITH USER_MODE];
            organizationId = applicationObj.ExternalOrganization__c;
            getContactIds();
        }else if(annoucementId != null) {
            annoucementobj = [SELECT Id, Organization__c, Status__c FROM Announcement__c WHERE Id =: annoucementId WITH USER_MODE];
            organizationId = annoucementobj.Organization__c;
            flexTableName = KeyContactsStaticUtility.ASSOCIATE_ANNOUNCEMENT_CONTACTS;
            showTable= true;
        }else if(programId != null) {
            programObj = [SELECT Id, Account__c,Account__r.ParentId, Status__c FROM Program__c WHERE Id =: programId WITH USER_MODE];          
            accIds.add(programObj.Account__c);
            accIds.add(programObj.Account__r.ParentId);
            accIds.remove(null);
           // added by umesh for UT
            accountIdList.add(programObj.Account__c);
            accountIdList.add(programObj.Account__r.ParentId);
            organizationId = programObj.Account__c;
            flexTableName = KeyContactsStaticUtility.ASSOCIATE_PROGRAM_CONTACTS;
            showTable= true;
        }else if(preApplicationId != null){
            preAppObj = [SELECT Id, FederalAwardingAgency__c, Status__c, ExternalOrganization__c FROM PreApplication__c WHERE Id = : preapplicationid WITH USER_MODE LIMIT 1];
            organizationId = preAppObj.ExternalOrganization__c;
        }else if(progressreportId  != null && GenericStaticUtility.APP_NAME_GRANTEE.endsWithIgnoreCase(appName)){
            progressrpt = [SELECT Id,Award__r.Grant__r.InternalOrganization__c FROM ProgressReports__c WHERE Id =: progressreportId WITH USER_MODE];
            organizationId = progressrpt.Award__r.Grant__r.InternalOrganization__c;
            flexTableName = KeyContactsStaticUtility.GRANTEE_PROGRESS_REP_CONTACTS;
            showTable= true;
        }else if (siteVisitId != null) {
            siteVisit = [SELECT Id, Award__r.Grant__r.ExternalOrganization__c, Status__c, Award__r.Grant__r.InternalOrganization__c FROM SiteVisit__c WHERE Id = : siteVisitId WITH USER_MODE LIMIT 1];
            organizationId = siteVisit.Award__r.Grant__r.InternalOrganization__c;
        }else if(awardId !=null){ //Added by Varsharani
        System.debug('appName-->'+appName);
            if (GenericStaticUtility.APP_NAME_GRANTOR.endsWithIgnoreCase(appName)) {
                award= [SELECT id,name,Grant__r.ExternalOrganization__c FROM Award__c WHERE id = :awardId WITH USER_MODE];
                organizationId=award.Grant__r.ExternalOrganization__c ;// InternalOrganization__c 
                flexTableName = KeyContactsStaticUtility.ASSOCIATE_SUBAWARD_CONTACTS;
                showTable= true;
            }else{
                Id userId = userinfo.getUserId();
                String loggUserAccId;
                User logUser = [SELECT Name, Organization__c,AccountId FROM User WHERE Id =: userId WITH SYSTEM_MODE];
                loggUserAccId = logUser.Organization__c;
                organizationId=loggUserAccId ;
                flexTableName = KeyContactsStaticUtility.ASSOCIATE_SUBAWARD_CONTACTS;          
                showTable= true;   
            }         
        }else if(amendId !=null){
            amdRequest= [SELECT Id,name,Grant__r.InternalOrganization__c FROM AmendmentRequest__c WHERE Id=:amendId WITH USER_MODE];
            organizationId=amdRequest.Grant__r.InternalOrganization__c;
            flexTableName = KeyContactsStaticUtility.ASSOCIATE_AMENDTMENT_CONTACTS;
            showTable= true;            
        }
        grantorRecordTypeId = Schema.SObjectType.KeyContacts__c.getRecordTypeInfosByName().get(KeyContactsStaticUtility.KEY_CONTACTS_RECORD_TYPE_GRANTOR).getRecordTypeId();
        granteeRecordTypeId = Schema.SObjectType.KeyContacts__c.getRecordTypeInfosByName().get(KeyContactsStaticUtility.KEY_CONTACTS_RECORD_TYPE_GRANTEE).getRecordTypeId();
        userIdSet = getOrganizationUserIds();
        recordsIdSet = (Set<String>)JSON.deserialize(JSON.serialize(userIdSet), Set<String>.class);
        if (GenericStaticUtility.APP_NAME_GRANTOR.endsWithIgnoreCase(appName)) {
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper ('RecordTypeId', grantorRecordTypeId, true);
            listDefaultValues.add(dv1);
            pageTemplateName = KeyContactsStaticUtility.GRANTOR_KEY_CONTACT;
            if (siteVisitId != null){
                processSiteVisitModuleGrantor(siteVisitId);
            }          
            if(awardId !=null){ //Added by Varsharani
                processGrantSubawardGrantorModule(awardId);
            }
            if(amendId !=null){
                processAmendmnetModule(amendId);
            }
        }else if (GenericStaticUtility.APP_NAME_GRANTEE.endsWithIgnoreCase(appName) && KeyContactsStaticUtility.GRANTEE_SITE_VISIT.equalsIgnoreCase(module) ) {
            processSiteVisModule();
        }else if (GenericStaticUtility.APP_NAME_GRANTEE.endsWithIgnoreCase(appName)) {
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper ('RecordTypeId', granteeRecordTypeId, true);
            listDefaultValues.add(dv1);
            pageTemplateName = KeyContactsStaticUtility.GRANTEE_KEY_CONTACT;
            if(applicationId != null) {
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('Application__c', applicationId, true);
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper('TypeOfPhase__c', 'Application', true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv2);
            }
            if(preApplicationId != null) {
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('PreApplication__c', preApplicationId, true);
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper('TypeOfPhase__c', 'PreApplication', true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv2);
            }
            if(progressreportId != null) {
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('ProgressReport__c', progressreportId, true);
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper('TypeOfPhase__c', 'ProgressReport', true);
                listDefaultValues.add(dv);
                listDefaultValues.add(dv2);
            }
            if(formId != null && templateName != null && applicationId != null) {
                GNT__PageTemplate__c pageTemp = [SELECT GNT__SObjectName__c FROM GNT__PageTemplate__c WHERE Name = : templateName WITH USER_MODE];
                GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(pageTemp.GNT__SObjectName__c, formId, true);
                listDefaultValues.add(dv3);
                if (templateName == GNT.KeyValueStoreHelper.getTextValue('Key Contacts', true)) {
                    pageTemplateName = KeyContactsStaticUtility.GRANTEE_KEY_CONTACT;
                } else if (templateName == GNT.KeyValueStoreHelper.getTextValue('RR Key Person Expanded', true) || templateName == GNT.KeyValueStoreHelper.getTextValue('RR Key Person', true)) {
                    pageTemplateName = KeyContactsStaticUtility.RR_KEY_PERSON_EXPANDED;
                } else if (templateName.startsWith(GNT.KeyValueStoreHelper.getTextValue('NASA Senior Key Person', true))) {
                    pageTemplateName = KeyContactsStaticUtility.NASA_KEY_PERSON;
                } else if (templateName == GNT.KeyValueStoreHelper.getTextValue('NSF Key Person', true)) {
                    pageTemplateName = KeyContactsStaticUtility.NSF_KEY_PERSON_EXPANDED;
                } else if (templateName == GNT.KeyValueStoreHelper.getTextValue('RR Personal Data', true)) {
                    pageTemplateName = KeyContactsStaticUtility.RR_PERSONAL_DATA;
                }
            }
        }      
        lightningObject.listDefaultValuesLightning = listDefaultValues;
        if(showTable){
            lightningObject.flexTableName = flexTableName;
        }else{
            lightningObject.pageTemplateName = pageTemplateName;   
        }
        lightningObject.listValueMap = getListParams();
        lightningObject.keyValueMap = getKeyValueMap();
        return null;
    }

    public string getListParams(){
        Map<String,set<String>> listParams = new Map<String,set<String>>();
        set<String> selectedContacts = new set<String>();
        if(annoucementId != null){ 
            for(KeyContacts__c annCt: [SELECT Id,Contact__c FROM  KeyContacts__c WHERE Announcement__c= :annoucementId WITH USER_MODE] ){
                selectedContacts.add(annCt.Contact__c);
            }
        }else if(programId != null){ 
            for(KeyContacts__c progCt:  [SELECT Id,Contact__c FROM KeyContacts__c WHERE Program__c= :programId WITH USER_MODE] ){
                selectedContacts.add(progCt.Contact__c);
            }
        }else if(progressreportId != null){ 
            for(KeyContacts__c progCt:  [SELECT Id,Contact__c FROM KeyContacts__c WHERE ProgressReport__c = :progressreportId WITH USER_MODE] ){
                selectedContacts.add(progCt.Contact__c);
            }
        }else if(awardId !=null){ // Added by Varsharani     
            for(KeyContacts__c awardContact: [SELECT Id,Contact__c FROM KeyContacts__c WHERE Award__c= :awardId WITH USER_MODE]){
                selectedContacts.add(awardContact.Contact__c);
            }
        }else if(amendId !=null){
            for(KeyContacts__c amendContact:  [SELECT Id,Contact__c FROM KeyContacts__c WHERE AmendmentRequest__c =:amendId WITH USER_MODE]){
                selectedContacts.add(amendContact.Contact__c);
            }
        }
        listParams.put('accountIds',accIds); // added form kay value map 
        listParams.put('agencyUsers', recordsIdSet); // added form kay value map 
        listParams.put('selectedContacts',selectedContacts);
        listParams.put('contactIdSet', contactIdSet ); // added form keyvaluemap
        return JSON.serialize(listParams);
    }

    private void processSiteVisModule() {
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        pageTemplateName = KeyContactsStaticUtility.GRANTEE_SITE_VISIT_CONTACT_DETAIL;
        if (siteVisitId != null) {
            RecordType recordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = : KeyContactsStaticUtility.KEY_CONTACTS_RECORD_TYPE_GRANTEE and sObjectType = : 'KeyContacts__c' WITH USER_MODE];
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('SiteVisit__c', siteVisitId, true);
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId', recordType.Id, true);
            GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper('TypeOfPhase__c', 'Site Visit', true);
            listDefaultValues.add(dv);
            listDefaultValues.add(dv1);
            listDefaultValues.add(dv2);
        }
    }

    private void processSiteVisitModuleGrantor(Id siteVisitId) {
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('SiteVisit__c', siteVisitId, true);
        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper('TypeOfPhase__c', 'Site Visit', true);
        listDefaultValues.add(dv);
        listDefaultValues.add(dv2);
    }
    //Added by Varsharani 
    private void processGrantSubawardGrantorModule(Id awardId) {
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('Award__c', awardId, true);
        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper('TypeOfPhase__c', 'Awards', true);
        listDefaultValues.add(dv);
        listDefaultValues.add(dv2);
    }
    //Added by Varsharani 
    private void processAmendmnetModule(Id amendId){
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('AmendmentRequest__c', amendId, true);
        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper('TypeOfPhase__c', 'Amendment Request', true);
        listDefaultValues.add(dv);
        listDefaultValues.add(dv2);       
    }

    public Set<Id> getOrganizationUserIds() {
        Set<Id> userIdSet = new Set<Id>();
        List<Account> acc = [SELECT Id, GroupCode__c FROM Account WHERE Id =: organizationId WITH USER_MODE];
        if(acc.size() > 0) {
            contactGroupCode = acc[0].GroupCode__c;
        }
        return userIdSet;
    }   
    //Added by Arbaz Mansoori. Purpose to get contact from Application on the Key Contacts Form
    public Set<String> getContactIds() { 
        List<KeyContacts__c> keyContactId = new List<KeyContacts__c>();        
        for(KeyContacts__c key : [SELECT Id, Contact__c FROM KeyContacts__c WHERE  Application__c= :applicationId WITH USER_MODE]){
            contactIdSet.add(key.Contact__c);
        }
        return contactIdSet;
    }

    public string getKeyValueMap() {
        Map<String, Object> keyValueMap = new Map<String, Object>();
        keyValueMap.put('agencyId', organizationId);
        keyValueMap.put('keycontactid',recordId); // Added form View Ctrl 
        keyValueMap.put('programId',programId);
        return JSON.serialize(keyValueMap);
    }
}*/