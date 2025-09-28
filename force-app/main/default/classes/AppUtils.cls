global virtual with sharing class AppUtils {
        global static Map<String, String> getUrlParamLWC(String urlVar) {
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(urlVar);
        Map<String, Object> attributesMap = new Map<String, Object>();
        Map<String, Object> statemap = new Map<String, Object>();
        Map<String, String> paramValueMap = new Map<String, String>();
        String attributes = 'attributes';
        string state = 'state';

        if(jsonMap.containsKey(attributes)){
            attributesMap = (Map<String, Object>) jsonMap.get(attributes);               
        }
        for(String key : attributesMap.keySet()) {
            paramValueMap.put(key, (String) attributesMap.get(key));
        }
        if(jsonMap.containsKey(state)){
            statemap = (Map<String, Object>) jsonMap.get(state);               
        }
        for(String key : statemap.keySet()) {
            paramValueMap.put(key, (String) statemap.get(key));
        }
        

        return paramValueMap;
    }

    global static GNT__PhaseConfig__c getPhase(boolean create) {
        GNT__PhaseConfig__c phase = new GNT__PhaseConfig__c();
        phase.Name = 'TestPhase';
        phase.GNT__TabName__c='PLANNING';
        phase.GNT__CustomAppName__c = 'StateasGrantor';
        phase.GNT__URL__c = '/apex/planning';
        phase.GNT__GroupName__c='2';
        phase.GNT__Sequence__c=2;
        phase.GNT__Abbreviation__c ='PL';
        phase.GNT__SObject__c = 'Accouncement__c;Program__c;Package__c';
        phase.GNT__AccordionHeader__c = 'Planning';
        phase.GNT__EnableSearch__c = true;
        phase.GNT__SidebarSearchLabel__c = 'Search';
        phase.GNT__SidebarRecentlyViewedLabel__c = 'Recently Viewed';
        phase.GNT__SidebarExternalLinksLabel__c = 'External Links';
        phase.GNT__SearchResultPage__c ='/apex/planning';
        phase.GNT__SidebarComponentSequence__c = 'Search,Links,RecentlyViewed,SubMenu';
        phase.GNT__EnableExternalLinks__c = true;
        phase.GNT__FlexTableParameters__c = 'orgType=Organization';
        phase.GNT__Active__c= true;
        phase.GNT__PhaseType__c = 'Phase';
        phase.GNT__SelectedByDefault__c = true;

        if (create) {
            insert as user phase;
        }
        return phase;
    }

    global static String getReturnURL(Id recordId) {
        String returnUrl = '/lightning/r/' + recordId.getSObjectType().getDescribe().getName() + '/' + recordId + '/view';
        return returnUrl;
    }
    global static String getNameSpacePrefix(){
        return '';
    }
    global static String getNamespace() {
        List<ApexClass> classes = [
            SELECT NamespacePrefix 
            FROM ApexClass 
            WHERE Name = 'AppUtils'
            LIMIT 1
        ];
        
        if (!classes.isEmpty()) {
            return classes[0].NamespacePrefix;
        }
        return ''; 
    }
}