@isTest
private class TestHomeTopBannerCtrl {
    
    @isTest
    static void testTopBannerCard() {
        GNT.TriggerHelper.skiptrigger = true;GNT.TriggerHelper.skiptrigger = true;
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
                                
        GNT__PhaseConfig__c phase = AppUtils.getPhase(false);
        phase.GNT__CustomAppName__c = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        phase.Name = 'Planning';
        insert phase;
            
        GNT__ChartConfig__c ch = new GNT__ChartConfig__c(
            GNT__Title__c = 'Awarded Amount',
            GNT__UniqueName__c = 'AwardedAmount',
            GNT__PhaseConfig__c = phase.id,
            GNT__Active__c = true,
             GNT__SOQL__c = 'SELECT SUM(FundedAmount__c) Total FROM Program__C WHERE Status__c = \'Active\' AND CreatedDate = THIS_FISCAL_YEAR'
           // GNT__SeriesForDrilldownMapObsolete__c = '{"icon": "utility:moneybag","url": "/lightning/r/Report/00O75000000ZVzaEAG/view?queryScope=userFolders","textOnHover": "Click to view Total Amount Awarded"}'
        );
        
        Test.startTest();
        insert ch;
        Test.stopTest();
        
        try {
            List<Map<String,String>> result = HomeTopBannerCtrl.getCardDetails('AwardedAmount');
        } catch(Exception e) {}
    }
    @isTest
    static void testTopBannerCard_1() {
        GNT.TriggerHelper.skiptrigger = true;GNT.TriggerHelper.skiptrigger = true;
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
                                
        GNT__PhaseConfig__c phase = AppUtils.getPhase(false);
        phase.GNT__CustomAppName__c = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        phase.Name = 'Rec';
        insert phase;
            
        GNT__ChartConfig__c ch = new GNT__ChartConfig__c(
            GNT__Title__c = 'Funded Amount',
            GNT__UniqueName__c = 'AwardedAmount',
            GNT__PhaseConfig__c = phase.id,
            GNT__Active__c = true,
            GNT__SOQL__c = 'SELECT SUM(FundedAmount__c) Total FROM Program__C WHERE Status__c = \'Active\' AND CreatedDate = THIS_FISCAL_YEAR'
           // GNT__SeriesForDrilldownMapObsolete__c = '{"icon": "utility:moneybag","url": "/lightning/r/Report/00O75000000ZVzaEAG/view?queryScope=userFolders","textOnHover": "Click to view Total Amount Awarded"}'
        );
        
        Test.startTest();
        insert ch;
        Test.stopTest();
        
        try {
            List<Map<String,String>> result = HomeTopBannerCtrl.getCardDetails('AwardedAmount');
        } catch(Exception e) {}
    }
    
}
