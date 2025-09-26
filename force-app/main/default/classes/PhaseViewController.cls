/*
********************************************************************************************************************
Audit History
********************************************************************************************************************
01/23/2024       Kunal Kumar               Added getKeyValueMap() method to pass keyvaluemap for sidebar related to Reciepient Announcement.
10/10/2023       Ravindra Sutar            Added getLoggedInUserId() method to pass LoggedIn user id Phaseview Component.
10/12/2023       Nakul Kadam               Reviewed.
05/01/2024       Nakul Kadam               Reviewed.
08/02/2024       Gauri Gire                Added getFoaLeadListparam() method to pass keyvaluemap for sidebar related to GranteeOpportunity.
18/02/2025       Gauri Gire                Made Changes for the bug 491497
13/05/2025       Gauri Gire                Updated for #Security 
********************************************************************************************************************
*/

public with sharing class PhaseViewController {   
    
    private class PhaseConfigWrapper{
        private List<Object> phaseFlexTable{get;set;}
        private Map<String, Object> accountOrORgId{get;set;}
        private Map<String, Object> recordIdSet{get;set;}
        private String appNameLabel{get;set;} //Grantor
        private String appNameDeveloperName{get;set;}   //StateAsGrantor    
    }
    
    @AuraEnabled(cacheable=true)  
    public static String fetchPhaseConfig(string currentPhase) { 
        PhaseConfigWrapper phaseWrapper = new PhaseConfigWrapper();
        phaseWrapper.phaseFlexTable = fetchPhaseFlexTable(currentPhase);
        phaseWrapper.accountOrORgId = getLoggedInUserInfo();
        String orgId = (String) phaseWrapper.accountOrORgId.get('orgId');
        phaseWrapper.recordIdSet = (currentPhase == 'RecipientAnnouncements') ? getKeyValueMap(orgId) :
                           // (currentPhase == 'GranteeOpportunities') ? getFoaLeadListparam(orgId) :
                            null;
        Map<String, String>  appNameMap = new Map<String, String>();
        appNameMap = getAppNameTitle();  
        if(appNameMap != null){              
            phaseWrapper.appNameLabel = appNameMap.get('appNameLabel');
            phaseWrapper.appNameDeveloperName = appNameMap.get('appNameDeveloperName');
        }
        return JSON.serialize(phaseWrapper);
    }
     
    public static List<GNT__PhaseConfig__c> fetchPhaseFlexTable(string currentPhase) { 
        List<GNT__PhaseConfig__c> phaseConfigRec = [SELECT GNT__BodyTable__c,GNT__BodyTable__r.Name,GNT__TabName__c   
                                                    FROM GNT__PhaseConfig__c 
                                                    WHERE Name =:currentPhase WITH USER_MODE LIMIT 1]; 
        return phaseConfigRec;
    }
    
    public static Map<String, Object> getLoggedInUserInfo(){   
        Map<String, Object> orgIdAndProfile = new Map<String, Object>();
        String userOrgId;
        User u = [SELECT id, GNT__OrganizationId__c, Contact.AccountId,Profile.Name FROM User WHERE Id = :UserInfo.getUserId() WITH SYSTEM_MODE];
        userOrgId = (u.Contact != null)?(u.Contact.AccountId != null? u.Contact.AccountId:u.GNT__OrganizationId__c) :u.GNT__OrganizationId__c;
        //orgIdAndProfile.put('uesrDeptCode', u.DepartmentCode__c);
        orgIdAndProfile.put('orgId', u.GNT__OrganizationId__c);
        orgIdAndProfile.put('userOrgId',userOrgId);
        orgIdAndProfile.put('userIsSME',(u.Profile.Name=='SME') ? true:false);
        return orgIdAndProfile;
        
    }
    
    public static Map<String,Object> getKeyValueMap(String orgId){ 
        Set<Id> recordsIdSet;
        Map<String,Object> keyValueMap = new Map<String,Object>();
        Set<String> oppStatuses = new Set<String>{
            'AnnouncementStaticUtility.OPP_CONVERTED_TO_APP',
            'AnnouncementStaticUtility.OPP_CONVERTED_TO_PREAPP',
            'AnnouncementStaticUtility.OPP_QUALIFIED'
        };
    //    List<SoleSourceAwardRecipient__c> solesourceList = [SELECT Id,Name,FundingOpportunity__c FROM SoleSourceAwardRecipient__c WHERE Account__r.Id = :orgId WITH USER_MODE];
    //     Set<Id> annIds = new Set<Id>();
    //     for (SoleSourceAwardRecipient__c ss : solesourceList) {
    //         annIds.add(ss.FundingOpportunity__c);
    //     }
        // List<OpportunityQualification__c> qualifiedOpportunities = [SELECT Id,AnnouncementId__c, Name, FundingOpportunity__c FROM OpportunityQualification__c WHERE OpportunityStatus__c IN :oppStatuses AND Account__r.Id = :orgId WITH USER_MODE];
        // Set<Id> qualifiedAnnIds = new Set<Id>();
        // if (!qualifiedOpportunities.isEmpty()) {
        //     for (OpportunityQualification__c qualiedOps : qualifiedOpportunities) {
        //         qualifiedAnnIds.add(qualiedOps.FundingOpportunity__c);
        //     }
        //} 
        // if (qualifiedAnnIds.size() == 0) {
        //     //qualifiedAnnIds.add('a2sD00000000000000');//000000000000000
        //     Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        //     Schema.SObjectType objType = globalDescribe.get('OpportunityQualification__c');
        //     if (objType != null) {
        //         String prefix = objType.getDescribe().getKeyPrefix();
        //         qualifiedAnnIds.add(prefix + '000000000000000');
        //         system.debug('qualifiedAnnIds>>'+qualifiedAnnIds);
        //     }
        // }
    
       // keyValueMap.put('qualifiedAnnouncements', qualifiedAnnIds);
        //Map<Id, announcement__c> fundingOppMap = new Map<Id, announcement__c> ([Select Id from announcement__c where Status__c IN ('Published', 'Closed', 'Archived') and RecordType.Name = 'Grantor' and (announcementType__c = 'Competitive' OR Id IN :annIds) and ID not in :qualifiedAnnIds]);
        //recordsIdSet = fundingOppMap.keyset();
        //keyValueMap.put('rcdsIdSet',recordsIdSet); 
        return keyValueMap;
    }
    
    // Added by Gauri for GranteeOpportunity. Temporary solution for phase generic component.
    /*private static Map<String,Object> getFoaLeadListparam(String orgId){
        List<Id> addedRecords =new List<Id>();
        Map<String,Object> listParams = new Map<String,Object>();
        Set<Id> recordsIdSet;
        for(QualifiedLead__c lead: [SELECT Id,Name,Agency__c,Lead__c
                            FROM QualifiedLead__c
                            WHERE Agency__c = :orgId WITH USER_MODE]){
            addedRecords.add(lead.Lead__c);
        }
        if(addedRecords.size() == 0){
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            Schema.SObjectType objType = globalDescribe.get('QualifiedLead__c');
            if (objType != null) {
                String prefix = objType.getDescribe().getKeyPrefix();
                addedRecords.add(prefix + '000000000000000');
                system.debug('addedRecords>>'+addedRecords);
            }
        }//prefix from schema method
        //Map<Id,FOALead__c>  leadmap = new Map<Id,FOALead__c> ([SELECT Id, Name FROM FOALead__c WHERE Id NOT IN :addedRecords]);
        //recordsIdSet = leadmap.keySet();
        //listParams.put('rcdsIdSet',recordsIdSet); 
        listParams.put('qualifiedLeads', addedRecords);      
        return listParams;
    }
    */
    
    public static Map<String, String> getAppNameTitle(){ 
        System.debug('AppppName ++');
        Map<String, String> appNameMap = new Map<String, String>();
        List<UserAppInfo> userAppInfo = [SELECT Id,AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1]; 
        if(!userAppInfo.isEmpty()) {
            List<AppDefinition> appDefinition= [SELECT DeveloperName, DurableId,Label FROM AppDefinition WHERE DurableId = :userAppInfo[0].AppDefinitionId LIMIT 1]; 
            if(!appDefinition.isEmpty()){
               // return appDefinition[0].Label;
                appNameMap.put('appNameLabel', appDefinition[0].Label);
                appNameMap.put('appNameDeveloperName', appDefinition[0].DeveloperName);
                //system.debug('appDefinition[0].DeveloperName>>>>'+appDefinition[0].DeveloperName);
                //return appDefinition[0].DeveloperName;
                return appNameMap;
            }
        }
         appNameMap.put('appNameLabel', 'Recipient');
         appNameMap.put('appNameDeveloperName', 'Recipient');
        return appNameMap;  //Grantee
    }
}