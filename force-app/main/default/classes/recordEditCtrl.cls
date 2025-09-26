/*   
**********************************************************************************************************************
Audit History
**********************************************************************************************************************
07/22/2023     Kunal Kumar             record Edit Controller 
10/06/2022     Nakul Kadam             Updated the hide expression evaluation logic to read the Sobject level JSON.
**********************************************************************************************************************
*/
public with sharing class recordEditCtrl {
    
     @AuraEnabled
    public static String getContext(Id recordId){
        String sOjectName = recordId.getSObjectType().getDescribe().getName();
        String encodingEdit = EncodingUtil.base64Encode(Blob.valueOf('edit')) ;
        return '/lightning/r/'+ sOjectName +'/'+ recordId +'/view?c__Mode='+ encodingEdit;
        
    }
    
}
    
  /*  @AuraEnabled
    public static String getURL(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        String encodingEdit = EncodingUtil.base64Encode(Blob.valueOf('edit')) ;
        String returnURL = '/lightning/r/'+sObjName+'/'+recordId+'/view?c__Mode='+encodingEdit;
        return returnURL;
    }
    
    @AuraEnabled
    public static String getContext(Id recordId){
        String sOjectName = recordId.getSObjectType().getDescribe().getName();
        Boolean result = hasRecordEditAccess(sOjectName, recordId);
        system.debug('****hasRecordEditAccess:::' + result);
        if(result){
            String encodingEdit = EncodingUtil.base64Encode(Blob.valueOf('edit')) ;
            return '/lightning/r/'+ sOjectName +'/'+ recordId +'/view?c__Mode='+ encodingEdit;
        }else{
            String encodingView = EncodingUtil.base64Encode(Blob.valueOf('view')) ;
            return '/lightning/r/'+ sOjectName +'/'+ recordId +'/view?c__Mode='+ encodingView;
        }
    }

    private static Boolean hasRecordEditAccess(String sOjectName, Id recordId){
        
        Map<String,Object> detailLayoutInitializerMap = new Map<String,Object>();
        String unMangedControllerName, templateName;
        List<Object> pageTemplateName = new List<Object>();
        
        List<GNT__SobjectConfig__c> sobjectConfig = [SELECT Id, GNT__DetailLayoutInitializer__c from GNT__SobjectConfig__c WHERE Name = :sOjectName WITH USER_MODE];        
        List<Object> detailLayoutInitializerList = new List<Object>();
        if(sobjectConfig.size() == 1 && sobjectConfig[0].GNT__DetailLayoutInitializer__c != null){
            try {   
                detailLayoutInitializerList = (List<Object>) JSON.deserializeUntyped(sobjectConfig[0].GNT__DetailLayoutInitializer__c);    
            } catch (Exception ex) {
                return false;
            }
        }else{           
            return false;           
        }

        for(Object obj : detailLayoutInitializerList){
            DetailLayoutInitializerMap = ( Map<String, Object>) obj;
            if(String.valueOf(DetailLayoutInitializerMap.get('type')) == 'ApexClass' && DetailLayoutInitializerMap.get('value') != null){
                unMangedControllerName = String.valueOf(DetailLayoutInitializerMap.get('value'));
                system.debug('kk debug global Edit 55 ' +unMangedControllerName);
            }
            if(pageTemplateName.size() == 0 && String.valueOf(DetailLayoutInitializerMap.get('type')) == 'PageTemplate' && DetailLayoutInitializerMap.get('value') != null){
                templateName = String.valueOf(DetailLayoutInitializerMap.get('value'));
                 system.debug('kk debug global Edit 58 ' +templateName);
            }
        } 

        if(String.isNotEmpty(unMangedControllerName) && String.isEmpty(templateName)){
            GNT.GenericCtrl controllerInstance = (GNT.GenericCtrl) Type.forName(unMangedControllerName).newInstance(); 
            controllerInstance.lightningObject.currentRecordId = recordId;
            controllerInstance.lightningObject.isLightning = true;         
            templateName = controllerInstance.init();
             system.debug('kk debug global Edit 67 ' +templateName);
        }
        
        if(String.isNotEmpty(templateName)){
            List<GNT__PageTemplate__c> formConfig = [SELECT Id,Name, GNT__ViewLayoutConfig__c 
                from GNT__PageTemplate__c WHERE Name = :templateName WITH USER_MODE];
            if(formConfig.size() == 1 && formConfig[0].GNT__ViewLayoutConfig__c != null){                
                Id pageLayoutId = formConfig[0].GNT__ViewLayoutConfig__c;
 system.debug('kk debug global Edit 76 ' +pageLayoutId);                
                List<GNT__PageLayoutActionConfig__c> pageLayoutActions = [SELECT GNT__HideExpressionJSON__c,
                    GNT__SobjectActionConfig__r.GNT__HideExpressionJSON__c, GNT__HideExpressionFields__c, 
                    GNT__SobjectActionConfig__r.GNT__HideExpressionFields__c from GNT__PageLayoutActionConfig__c 
                    Where GNT__PageLayoutConfig__c = :pageLayoutId 
                    AND GNT__Active__c = true AND GNT__StandardAction__c = 'Edit'];
                 system.debug('kk debug global Edit 81 ' +pageLayoutActions);
                if(pageLayoutActions.size() == 1){
                    Sobject record = loadRecordWithRequiredFields(pageLayoutActions[0], sOjectName, recordId);
                     system.debug('kk debug global Edit 84 ' +record);
                    if(pageLayoutActions[0].GNT__SobjectActionConfig__r.GNT__HideExpressionJSON__c != null){
                         system.debug('kk debug global Edit 86 ' +ExpressionJsonEvaluator.evaluateExpression(pageLayoutActions[0].GNT__SobjectActionConfig__r.GNT__HideExpressionJSON__c, record, 'Edit'));
                        return !ExpressionJsonEvaluator.evaluateExpression(pageLayoutActions[0].GNT__SobjectActionConfig__r.GNT__HideExpressionJSON__c, record, 'Edit');
                    }else if(pageLayoutActions[0].GNT__HideExpressionJSON__c != null){
                         system.debug('kk debug global Edit 89 ' +ExpressionJsonEvaluator.evaluateExpression(pageLayoutActions[0].GNT__HideExpressionJSON__c, record, 'Edit'));
                        return !ExpressionJsonEvaluator.evaluateExpression(pageLayoutActions[0].GNT__HideExpressionJSON__c, record, 'Edit');
                    }
                }
            }
        }
        return false;
    }

    private static sObject loadRecordWithRequiredFields(GNT__PageLayoutActionConfig__c action, String sobjectName, String recId){
        try {
            String fields = 'Id ';
            if(action.GNT__HideExpressionFields__c != null){
                fields += ',' + action.GNT__HideExpressionFields__c;
            }
            if(action.GNT__SobjectActionConfig__r.GNT__HideExpressionFields__c != null){
                fields += ',' + action.GNT__SobjectActionConfig__r.GNT__HideExpressionFields__c;
            }
            String query = 'SELECT '+ fields +' FROM '+ sobjectName + ' WHERE Id =: recId';
            List<Sobject> recordList = Database.query(String.escapeSingleQuotes(query),AccessLevel.USER_MODE);
            return recordList[0];
        }catch(Exception e){
            System.debug('Error while executing query on hide expression fields::'+e);
            return null;
        }        
    }
    
    /*@AuraEnabled
    public static String getContext(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        String currentPhase;
        if(sObjName=='Program__c'){
            currentPhase ='GrantorPlanning';
        }
        GNT__PhaseConfig__c phaseConfigRec = [SELECT GNT__SidebarComponentSequence__c, Name,GNT__BodyTable__c,GNT__BodyTable__r.name,
                                                        GNT__EnableMenu__c, GNT__EnableBIAnalytics__c, GNT__EnableCollab__c, 
                                                        GNT__EnableSidebarTaskMenu__c, GNT__EnableRecentlyViewed__c, GNT__EnableSearch__c,
                                                        GNT__EnableExternalLinks__c, GNT__Enable_Technical_Support__c,
                                                        GNT__AccordionHeader__c, GNT__SidebarBIAnalyticsMenuLabel__c, GNT__SidebarCollabMenuLabel__c, 
                                                        GNT__SidebarTaskMenuLabel__c, GNT__SidebarRecentlyViewedLabel__c, GNT__SidebarSearchLabel__c, 
                                                        GNT__SidebarExternalLinksLabel__c, GNT__SidebarTechnicalSupportLabel__c, GNT__SearchResultPage__c
                                                FROM GNT__PhaseConfig__c 
                                                WHERE Name =:currentPhase limit 1];
        
        GNT__DataTableAction__c dataTableAction =[Select id,Name, GNT__DataTableConfig__r.Name,GNT__HideExpressionFields__c, GNT__HideExpressionJSON__c from GNT__DataTableAction__c 
                                                  where GNT__DataTableConfig__c=:phaseConfigRec.GNT__BodyTable__c and name='Edit' limit 1];
        
        sObject record =[SELECT Id,name,Status__c,IsOwner__c,IsReviewer__c from Program__c where id =:recordId];
       String HideExpression = dataTableAction.GNT__HideExpressionJSON__c;
        
        Boolean result = ExpressionJsonEvaluator.evaluateExpression(HideExpression,record,'Edit');
        if(!result){
        String encodingEdit = EncodingUtil.base64Encode(Blob.valueOf('edit')) ;
        String returnURL = '/lightning/r/'+sObjName+'/'+recordId+'/view?c__Mode='+encodingEdit;
        return returnURL;
        }
        else{
            String encodingView = EncodingUtil.base64Encode(Blob.valueOf('view')) ;
            String returnURL = '/lightning/r/'+sObjName+'/'+recordId+'/view?c__Mode='+encodingView;
            return returnURL;
        }
  
}*/
//}