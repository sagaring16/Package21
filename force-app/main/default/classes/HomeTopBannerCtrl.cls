/*
    21/5/2025           Mangesh G.           Update for #Security
*/
public with sharing class HomeTopBannerCtrl {
    
  private static SiteDetail getSiteDetail() {   //CRF: See SubRecipientCtrl for feedback around below code. 
        Site mySite = [SELECT Id FROM Site WHERE Name = 'GovGrants_3_0_Recipient_Portal' WITH SYSTEM_MODE];
        return [SELECT SecureURL FROM SiteDetail WHERE DurableId = :mySite.Id WITH SYSTEM_MODE];
    }
    
    @AuraEnabled()
    public static String fetchChartId(String reportName){
        system.debug('report name is'+reportName);
        List<Report> reportList = [SELECT Id from Report where DeveloperName =:reportName];
        System.debug('reportList'+reportList);
        return reportList[0].Id;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getCardDetails(String uniqueName){
        List<Map<String,String>> detailList = New List<Map<String,String>>();
        List<String> recordUniqueName = uniqueName.split(';');
        List<GNT__ChartConfig__c> chartConfigList = [SELECT Id,GNT__Title__c, GNT__UniqueName__c, GNT__SOQL__c, 
                                                     GNT__SeriesForDrilldownMapObsolete__c, GNT__PhaseConfig__r.Name 
                                                     FROM GNT__ChartConfig__c WHERE  GNT__Active__c = true
           
                                                    AND GNT__UniqueName__c IN : recordUniqueName WITH USER_MODE];
                                                    
      //Commented below code due to Subrecipient Home top banner carts not vissible: sakshi                                              
      /*  User usr = [ 
            SELECT 
                Id, GNT__OrganizationId__c 
            FROM User 
            WHERE Id = :UserInfo.getUserId() WITH SYSTEM_MODE
        ];
        String OrganizationId = usr.GNT__OrganizationId__c;
            OrganizationId = OrganizationId.substring(0, OrganizationId.length() - 3);
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');*/
         set<Id> setId = new set<Id>();
        for(user u:[Select Id, AccountId From User Where Id = :UserInfo.getUserId()]){
            setId.add(u.AccountId);
        }
        
        for(GNT__ChartConfig__c chartData:chartConfigList){
            Map<String,String> chartMap = New Map<String,String>();
            chartMap.put('title',chartData.GNT__Title__c);
            chartMap.put('json',String.valueOf(chartData.GNT__SeriesForDrilldownMapObsolete__c));
            String chartDetailQuery = chartData.GNT__SOQL__c;
            if(!String.isBlank(chartDetailQuery)){
            //Commented below code due to Subrecipient Home top banner carts not vissible: sakshi
               /* if(chartDetailQuery.contains('{!orgId}')){
                    chartDetailQuery = chartDetailQuery.replace('{!orgId}', OrganizationId);                  
                }*/
                if((Decimal)(Database.query(chartDetailQuery)[0].get('Total')) != null){
                    chartMap.put('count',String.valueOf((Decimal)(Database.query(chartDetailQuery)[0].get('Total'))));
                }else{
                    chartMap.put('count','0');
                }
            }
            if(chartData.GNT__PhaseConfig__r.Name == 'RecipientHome'){
                SiteDetail mySiteDetail = getSiteDetail();   
                String url = mySiteDetail.SecureURL+'/s/';
                chartMap.put('baseUrl',url);
            } else{
                chartMap.put('baseUrl',(String)URL.getOrgDomainUrl().toExternalForm()); 
            }
            detailList.add(chartMap);
        }
        return detailList;
    } 
}