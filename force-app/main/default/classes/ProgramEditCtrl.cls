global virtual with sharing class ProgramEditCtrl extends ExtensibleGenericCtrl {
    //Properties
    global ID recordId { get; set; }
    global List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues { get; set; }
    global String pageTemplateName { get; set; }

    private Account accnt = New Account();
    private Set<Id> accIdSet = new Set<Id>();
    private String recordtype;
    private List<Program__c> programList;
    private Map<String, String> paramValueMap = new Map<String, String>();
    
    // Additional variables that were local in original init() method
    private User ownerUser;
    private String accountRecordType = '';
    private Id recordTypeId;

    global ProgramEditCtrl() {}

    /**
     * @description Pre-execution hook - handles parameter parsing and data loading
     * Contains all the data loading logic from original init() method
     */
    global virtual override void beforeExecution() {
        // Parse URL parameters
        parseUrlParameters();
        List<User> programOwner = [SELECT Id,GNT__OrganizationId__c
                                   FROM USER WHERE Id = :UserInfo.getUserId() WITH SYSTEM_MODE ];    
        // Initialize collections and variables
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if(!programOwner.isEmpty() && programOwner!=null && programOwner.size()>0 ){
            accnt = [
                SELECT Id
                FROM Account
                WHERE Id = :(ID) programOwner[0].GNT__OrganizationId__c
            ];
        }

        // Load user and organization data
                
        // Get app name for template logic
    }

    /**
     * @description Set page template extension point
     * Determines the appropriate page template based on record type and app context
     */
    global virtual override void setPageTemplate() {
        if (recordId != null) {
            ProgramList = [
                SELECT
                    id,
                    name,
                    recordtype.name,
                    PrimaryFunderType__c,
                    FederalProgramCFDA__c,
                    Account__c                   
                FROM Program__c
                WHERE id = :recordId
            ];
            pageTemplateName = 'Grantor State Program';
        } else {
            pageTemplateName = 'Grantor State Program Create';
        }
        
        // Set Lightning object property
        lightningObject.pageTemplateName = pageTemplateName;
    }

    /**
     * @description Set default values extension point
     * Populates default values for the form based on context
     */
    global virtual override void setDefaultValues() {
        if (accnt.id != null ) {                                    //&& accountRecordType == accnt.RecordTypeName__c && String.isNotBlank(accountRecordType) 
            GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper('Account__c', accnt.id, true);
            listDefaultValues.add(dv4);
            dv4 = new GNT.DynamicLayoutDefaultValueHelper('DNT__PrimaryFundingOrganization__c', accnt.id, true);
            listDefaultValues.add(dv4);
        }
        
        // Set Lightning object property
        lightningObject.listDefaultValuesLightning = listDefaultValues;
    }

    /**
     * @description Set key-value map extension point
     * Configures key-value mappings for the form
     */
    global virtual override void setKeyValueMap() {
        Map<String, Object> keyValueMap = new Map<String, Object>();
        keyValueMap.put('programid', recordId);
        lightningObject.keyValueMap = JSON.serialize(keyValueMap);
    }

    /**
     * @description Set list parameters extension point
     * Configures list parameters for the form
     */
    global virtual override void setListParam() {
        Map<String, Set<Id>> listParams = new Map<String, Set<Id>>();
        Set<Id> userIds = getHierachyUserIds();
        listParams.put('userIds', userIds);        
        // Set Lightning object property
        lightningObject.listValueMap = JSON.serialize(listParams);
    }

    // ========== PRIVATE HELPER METHODS ==========
    
    /**
     * @description Parses URL parameters and sets context variables
     * Contains the URL parameter parsing logic from original init()
     */
    private void parseUrlParameters() {
        recordId = lightningObject.currentRecordId;
        if (String.isNotBlank(lightningObject.currentPageUrl)) {
            //Accessing the url parameters
            paramValueMap = AppUtils.getUrlParamLWC(lightningObject.currentPageUrl);
            recordtype = paramValueMap.get('RecordType');
            if (recordId == null) {
                recordId = paramValueMap.get('id');
            }
        }
    }
    
    global static set<Id> getHierachyUserIds(){
        User logUser = [SELECT Id,GNT__OrganizationId__c FROM User WHERE Id = : UserInfo.getUserId() WITH SYSTEM_MODE LIMIT 1];
        Set<Id> accIdSet = new Set<Id>();
        if(logUser!=null && logUser.GNT__OrganizationId__c!=null){
            for(Account acc : [
                SELECT Id,ParentId,Parent.ParentId,Parent.Parent.ParentId 
                FROM Account 
                WHERE  Id =:logUser.GNT__OrganizationId__c
                WITH USER_MODE
            ]){
                accIdSet.add(acc.Id);
                if(acc.ParentId!=null){
                    accIdSet.add(acc.ParentId);
                }
                if(acc.Parent.ParentId!=null){
                    accIdSet.add(acc.Parent.ParentId);
                }
                if(acc.Parent.Parent.ParentId!=null){
                    accIdSet.add(acc.Parent.Parent.ParentId);
                }
            }
    	}
		Map<Id,User> userIdsMap = new Map<Id,User>([SELECT id FROM User WHERE GNT__OrganizationId__c IN:accIdSet WITH SYSTEM_MODE ]);
		return userIdsMap.keySet();
	}
    global Map<String, String> getUrlParamLWC(String urlVar) {
        return AppUtils.getUrlParamLWC(urlVar);
    }
}