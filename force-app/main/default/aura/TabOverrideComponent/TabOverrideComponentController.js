({
    doInit : function(component, event, helper) {
        var objectApiName = component.get('v.sObjectName');
        
        if (objectApiName) {
            var redirectMap = {
                'Program__c': 'Planning',
                'Announcement__c': 'Announcement',
                'Application__c': 'Applications',
                'Grant__c': 'Grant',
                'SiteVisit__c': 'Monitoring',
                'Preapplication__c': 'Preapplication',
                'Closeout__c': 'Closeout',
                'UserRegistration__c': 'Home',
                'ServiceArea__c': 'Planning',
                'Account': 'Home',
                'FundingSource__c': 'Planning',
                'ProgressReports__c': 'Monitoring',
                'AmendmentRequest__c': 'Grants',
                'MasterKPI__c': 'Planning',
                'Review__c': 'Applications',
                'RiskAssessment__c': 'Monitoring',
                'Award__c': 'Awards',
                'FundingAccount__c': 'Planning',
                'ReviewStep__c': 'Applications',
                'StrategicPlan__c': 'Planning',
                'Contact': 'Home',
                'PaymentRequest__c': 'Monitoring',
                'TermCondition__c': 'Planning'
            };
            
            var pageName = redirectMap[objectApiName];
            
            if (pageName) {
                var redirectUrl = '/lightning/n/' + pageName;
                window.location.href = redirectUrl;
            } else {
                window.location.href = '/lightning/n/Home';
            }
        } else {
            window.location.href = '/lightning/n/Home';
        }
    }
})