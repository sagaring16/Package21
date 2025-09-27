/*
    Purpose: Validates and submits the program for approval
    *********************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    10/09/2025   Umesh Chakranarayan      CreatedApexClass and made changes as per the defined method 
    ********************************************************************************************************************
*/
//CRF - Add global supressor
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class ProgramSubmissionHelper extends ExtensibleDynamicLayoutActionRedirect  { 
    private Program__c program;
    private Id recordId;
    private boolean isError;
    private Map<String,String> errorMessageMap = new Map<String,String>();

    global ProgramSubmissionHelper() {
        Set<String> errorCodes = new Set<String>{
            ProgramStaticUtility.PROGRAM_OBJECTIVES_REQUIRED_FOR_SUBMIT,
            ProgramStaticUtility.PROGRAM_AT_LEAST_ONE_PROGRAM_CONTACT_ERROR_MESSAGE,
            ProgramStaticUtility.PROGRAM_AT_LEAST_ONE_KPI_ERROR_MESSAGE,
            ProgramStaticUtility.PROGRAM_AT_LEAST_ONE_FOCUS_AREA_ERROR_MESSAGE,
            ProgramStaticUtility.PROGRAM_AT_LEAST_ONE_OBJECTIVE_ERROR_MESSAGE,
            'M01-GRNTR-31834','M01-GRNTR-67120'
        };
        if(errorMessageMap.size() == 0){
            errorMessageMap = ErrorMessageUtility.fetchMessages(errorCodes);    
        }
    }
    
    global virtual override Object beforeExecution() {
        recordId = lightningObject.currentRecordId; 
        program = [SELECT Id, Name, Objectives__c, FocusAreaRequired__c, KPIsRequired__c, IsGoalsRequired__c,IsProjectServiceAreaneeded__c, ProgramName__c,
                            (SELECT Id FROM ProgramKeyContacts__r),
                            (SELECT Id FROM KeyOutcomes__r),                                                
                            (SELECT Id FROM ServiceAreas__r),
                            (SELECT Id FROM RelatedGoalsObjectives__r)
                        FROM Program__c
                        WHERE Id =: recordId WITH USER_MODE];
        return null;
    }
    
    global virtual override Object validateBusinessRules() {
        validate(recordId);         
        return null;
    }

    global virtual override Object executeCoreLogic(){
        GNT.TaskCreationHandler.createApprovalProcessTasks(program.Id ,TaskStaticUtility.APPROVE_PROGRAM, program.Name,null,System.TODAY() + 7, null, true, null);
        GNT.ErrorMessageHelper.addMessage(ProgramStaticUtility.PROGRAM_PROGRAM_SUBMITTED_SUCCESS_MESSAGE);
        variables.pageReference = new pageReference(new AppUtils().getReturnURL(recordId));   
        return null; 
    }
    
    private void validate(Id recordId) {
        List<String> reviewErrors = ReviewStepValidationHelper.validateProgramTemplates(recordId, true, true, false);
        if (!reviewErrors.isEmpty()) {
            for (String error : reviewErrors) {
                lightningObject.messageList.add(new GNT.LightningPageMessage(String.valueOf(ApexPages.Severity.ERROR).toLowercase(), error));                 
            }
        }
        List<String> errorCodes = RolesAssignmentUtilityCtrl.performApprovalStepsValidation(recordId);
        if (!errorCodes.isEmpty()) {
            for (String error : errorCodes) {          
                lightningObject.messageList.add(new GNT.LightningPageMessage(String.valueOf(ApexPages.Severity.ERROR).toLowercase(), errorMessageMap.get(error)));                 
            }            
        }
        //Validate that Objectives is not blank.
        if (String.IsBlank(program.Objectives__c)) {
            lightningObject.messageList.add(new GNT.LightningPageMessage(String.valueOf(ApexPages.Severity.ERROR).toLowercase(), errorMessageMap.get(ProgramStaticUtility.PROGRAM_OBJECTIVES_REQUIRED_FOR_SUBMIT)));                 
        }
        //Validate program contacts
        if (program.ProgramKeyContacts__r != null && program.ProgramKeyContacts__r.isEmpty()) {
           lightningObject.messageList.add(new GNT.LightningPageMessage(String.valueOf(ApexPages.Severity.ERROR).toLowercase(), errorMessageMap.get(ProgramStaticUtility.PROGRAM_AT_LEAST_ONE_PROGRAM_CONTACT_ERROR_MESSAGE)));                 
        }
        //validate KPI
        if (ProgramStaticUtility.PICKLIST_VALUE_YES.equalsIgnoreCase(program.KPIsRequired__c)
            && program.KeyOutcomes__r != null && program.KeyOutcomes__r.isEmpty()) {
            lightningObject.messageList.add(new GNT.LightningPageMessage(String.valueOf(ApexPages.Severity.ERROR).toLowercase(), errorMessageMap.get(ProgramStaticUtility.PROGRAM_AT_LEAST_ONE_KPI_ERROR_MESSAGE)));                 
        }
        //validate Focus Area
        if (ProgramStaticUtility.PICKLIST_VALUE_YES.equalsIgnoreCase(program.FocusAreaRequired__c)
            && program.ServiceAreas__r != null && program.ServiceAreas__r.isEmpty()) {
            lightningObject.messageList.add(new GNT.LightningPageMessage(String.valueOf(ApexPages.Severity.ERROR).toLowercase(), errorMessageMap.get(ProgramStaticUtility.PROGRAM_AT_LEAST_ONE_FOCUS_AREA_ERROR_MESSAGE)));                 
        }
        //validate Objectives
        if (ProgramStaticUtility.PICKLIST_VALUE_YES.equalsIgnoreCase(program.IsGoalsRequired__c)
            && program.RelatedGoalsObjectives__r!= null && program.RelatedGoalsObjectives__r.isEmpty()) {
            lightningObject.messageList.add(new GNT.LightningPageMessage(String.valueOf(ApexPages.Severity.ERROR).toLowercase(), errorMessageMap.get(ProgramStaticUtility.PROGRAM_AT_LEAST_ONE_OBJECTIVE_ERROR_MESSAGE)));                 
        }       
    }
}