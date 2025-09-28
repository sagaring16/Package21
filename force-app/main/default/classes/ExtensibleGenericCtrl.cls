/*
    Purpose: Extensible controller that inherits from GNT.GenericCtrl
    *********************************************************************************************************************
    Audit History
    *********************************************************************************************************************
    12/09/2025   Umesh Chakranarayan      Created extensible class with additional functionality
    *********************************************************************************************************************
*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class ExtensibleGenericCtrl extends GNT.GenericCtrl {
    Map<String, String> paramValueMap = new Map<String, String>();
    global Id recordId;
    /**
     * @description Implementation of init method from GNT.GenericCtrl
     * Uses extensible pattern with hooks for customization and proper exception handling
     * @return String result from initialization
     */
    global virtual override String init() {
        try {

            // Call parent initialization first
        String parentResult = super.init();
        recordId = lightningObject.currentRecordId;
        if (String.isNotBlank(lightningObject.currentPageUrl)) {
            //Accessing the url parameters
            paramValueMap = AppUtils.getUrlParamLWC(lightningObject.currentPageUrl);

            if (recordId == null) {
                recordId = paramValueMap.get('id');
            }
        }
            
            // Execute pre-setup configuration logic
            beforeExecution();

            // Perform validation before proceeding
            validation();
            setPageTemplate();            
            if(recordId == null){
                setDefaultValues();
            }
            // Setup extension points
          
            setKeyValueMap();
            setListParam();
                    
            // Return parent result
            return parentResult;
            
        } catch (TerminateInitializationException ex) {
            System.debug('Caught TerminateInitializationException: ' + ex.getMessage());
            return ex.getMessage();
        } catch (Exception e) {
            // Error handling hook
            handleInitializationError(e);
            throw e;
        }
    }
    
    /**
     * @description Validation extension point
     * Override to add custom validation logic that should execute before configuration setup
     * This method is called early in the init() process to validate prerequisites
     */
    global virtual void validation() {
        // Default implementation - can be overridden
        // Child classes should override to add specific validation logic
        // Example: validate parameters, check permissions, validate record state, etc.
        System.debug('ExtensibleGenericCtrl: Executing validation hook');
    }
    
    /**
     * @description Pre-setup configuration extension point
     * Override to add logic that needs to execute before the configuration setup methods
     * This method is called after validation but before SetPageTemplate, SetDefaultValues, etc.
     * Use this for data loading, parameter parsing, or preparation logic
     */
    global virtual void beforeExecution() {
        // Default implementation - can be overridden
        // Child classes should override to add logic that prepares data for configuration
        // Example: load records, parse URL parameters, set instance variables, etc.
        System.debug('ExtensibleGenericCtrl: Executing before setup configuration hook');
    }
    
    /**
     * @description Set page template extension point
     * Override to customize page template setup
     */
    global virtual void setPageTemplate() {
        // Default implementation - can be overridden
        // Child classes should override to set pageTemplateName or other template logic
    }
    
    /**
     * @description Set default values extension point
     * Override to customize default values setup
     */
    global virtual void setDefaultValues() {
        // Default implementation - can be overridden
        // Child classes should override to set listDefaultValues or related properties
    }
    
    /**
     * @description Set key-value map extension point
     * Override to customize key-value mappings setup
     */
    global virtual void setKeyValueMap() {
        // Default implementation - can be overridden
        // Child classes should override to set keyValueMap properties
    }
    
    /**
     * @description Set list parameters extension point
     * Override to customize list parameters setup
     */
    global virtual void setListParam() {
        // Default implementation - can be overridden
        // Child classes should override to set listValueMap or list parameters
    }
    
    /**
     * @description Error handling extension point
     * @param e The exception that occurred
     * Override to add custom error handling, logging, or recovery logic
     */
    global virtual void handleInitializationError(Exception e) {
        // Default implementation - can be overridden
        System.debug('Error in init for record ' + lightningObject.currentRecordId + ': ' + e.getMessage());
        System.debug('Error in init for record ' + lightningObject.currentRecordId + ': ' + e.getLineNumber());
        lightningObject.messageList.add(new GNT.LightningPageMessage(ApexPages.Severity.ERROR, e.getLineNumber() + ': ' + e.getMessage()));
        GNT.ErrorMessageHelper.AddMessage('GenericStaticUtility.SOMETHING_WENT_WRONG_ERROR_MESSAGE');
    }
    // private Map<String, String> getUrlParamLWC(String urlVar) {
    //     Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(urlVar);
    //     Map<String, Object> attributesMap = new Map<String, Object>();
    //     Map<String, Object> statemap = new Map<String, Object>();
    //     Map<String, String> paramValueMap = new Map<String, String>();
    //     String attributes = 'attributes';
    //     string state = 'state';

    //     if(jsonMap.containsKey(attributes)){
    //         attributesMap = (Map<String, Object>) jsonMap.get(attributes);               
    //     }
    //     for(String key : attributesMap.keySet()) {
    //         paramValueMap.put(key, (String) attributesMap.get(key));
    //     }
    //     if(jsonMap.containsKey(state)){
    //         statemap = (Map<String, Object>) jsonMap.get(state);               
    //     }
    //     for(String key : statemap.keySet()) {
    //         paramValueMap.put(key, (String) statemap.get(key));
    //     }
    //     return paramValueMap;
    // }
        
    
    /**
     * @description Custom exception for extensibility framework
     */
    global class ExtensibilityException extends Exception {}
    global class TerminateInitializationException extends Exception {}
}