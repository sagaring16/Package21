/**
 * @description Extensible wrapper for GNT.DynamicLayoutActionRedirect
 * Provides extensibility hooks while maintaining framework inheritance
 * Implements abstract whenClicked method with extensible pattern
 * Global access allows unmanaged subscriber code to extend managed package classes
 * @Author: Nakul Kadam
 */
global abstract class ExtensibleDynamicLayoutActionRedirect extends GNT.DynamicLayoutActionRedirect {      
    global Variables variables;   
    /**
     * @description Constructor
     */
    global ExtensibleDynamicLayoutActionRedirect() {
        super();
    }
    /**
     * @description Implementation of abstract whenClicked method from GNT.DynamicLayoutActionRedirect
     * Uses extensible pattern with hooks for customization
     * @return PageReference for navigation
     */
    global override PageReference whenClicked() {        
        try {
            variables = new Variables();          
            // Pre-execution hook
            beforeExecution(); 
            // Validation hook
            validateBusinessRules();
            // private method to intrupt the execution in case of validation errors
            performValidationDecision();
            // Core execution (must be implemented by child class)
            executeCoreLogic();
            // Post-execution hook
            afterExecution();
            return variables.pageReference;
        }catch (TerminateExecutionException ex) {
            System.debug('Caught TerminateExecutionException: ' + ex.getMessage());
            return null;
        }catch (Exception e) {
            // Error handling hook
            handleExecutionError(e);
            throw e;
        }
    }  
    /**
     * @description Pre-execution extension point
     * Override to add custom preparation, or setup logic
     * @return optional
     */
    global virtual Object beforeExecution() {
        // Default implementation - can be overridden
        return null;
    }   
    /**
     * @description Pre-execution validation extension point
     * Override to add custom validation, preparation, or setup logic
     * @return optional
     */
    global virtual Object validateBusinessRules() {
        // Default implementation - can be overridden
        return null;
    } 
    /**
     * @description Core business logic - must be implemented by child classes
     * @return PageReference for navigation
     * @return optional
     */
    global virtual Object executeCoreLogic() {
        throw new ExtensibilityException('executeCoreLogic() must be implemented by child class');
    }
    /**
     * @description Post-execution extension point
     * Override to add custom post-processing, notifications, or cleanup
     * @return optional
     */
    global virtual Object afterExecution() {
        // Default implementation - can be overridden
        return null;
    }
    /**
     * @description Error handling extension point
     * @param e The exception that occurred
     * Override to add custom error handling, logging, or recovery logic
     */
    global virtual void handleExecutionError(Exception e) {
        // Default implementation - can be overridden
        System.debug('Error in whenClicked for record ' + lightningObject.currentRecordId + ': ' + e.getMessage());
        System.debug('Error in whenClicked for record ' + lightningObject.currentRecordId + ': ' + e.getlinenumber());      
        String error = 'Something went wrong. Please contact your system administrator.' + '\nError Details: ' + e.getLineNumber() + ': ' + e.getMessage() ;
        lightningObject.messageList.add(new GNT.LightningPageMessage(ApexPages.Severity.ERROR, error ));                
        //GNT.ErrorMessageHelper.AddMessage(GenericStaticUtility.SOMETHING_WENT_WRONG_ERROR_MESSAGE);
    }
    /**
     * @description Custom exception for extensibility framework
     */
    global class ExtensibilityException extends Exception {}
    global class TerminateExecutionException extends Exception {}
    global class Variables{
        global PageReference pageReference = null;
        // we will add more variables if needed.
    } 
    /*
        This method sets the validationPassed flag to true/false
    */
    private void performValidationDecision(){
        if(lightningObject.messageList.size() > 0){
            throw new TerminateExecutionException();
        }
    }
}