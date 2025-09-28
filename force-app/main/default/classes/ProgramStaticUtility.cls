/*
    Purpose: Add Program__c Hardcoded variables here.
    *****************************************************************************************************************************************************
    Audit History
    *****************************************************************************************************************************************************
    09/19/2018          Bhushan Deshpande        Created.
    09/25/2018          Bhushan Deshpande        Added Status Active.
    10/09/2018          Pranjali Naik            Added Yes/No Picklist values and 2 error messages.
    07/15/2020          Varsharani Anapat        Added Error message FEDERAL_PROGRAM_NAME_ALREADY_EXISTS.
    12/05/2025            Sagar Ingle            Updated for #Security  
    *****************************************************************************************************************************************************
*/
public with sharing class ProgramStaticUtility {

    //Record Types
    public static final String PROGRAM_RECORD_TYPE = 'RecordType';
    public static final String PROGRAM_RECORD_TYPE_INTERNAL = 'InternalProgram';
    public static final String PROGRAM_RECORD_TYPE_NGO = 'NGOProgram';
    public static final String PROGRAM_RECORD_TYPE_EXTERNAL = 'External';
    public static final String PROGRAM_RECORD_TYPE_EXTERNALPROGRAM = 'ExternalProgram';

    private static final Map<String,Schema.RecordTypeInfo> programRecordTypeMap = Schema.SObjectType.Program__c.getRecordTypeInfosByDeveloperName();
    public static Id getProgramRecordTypeId(String recordTypeName){
        return programRecordTypeMap.get(recordTypeName).getRecordTypeId();
    }

    //Status__c picklist values
    public static final String PROGRAM_STATUS_CREATED = 'Created';
    public static final String PROGRAM_STATUS_APPROVED = 'Approved';
    public static final String PROGRAM_STATUS_ACTIVE = 'Active';
    public static final String PROGRAM_STATUS_CHANGE_REQUESTED = 'Change Requested';
    public static final String PROGRAM_STATUS_BEING_AMENDED = 'Being Amended'; 
    public static final String PROGRAM_STATUS_SUBMITTED_FOR_REVIEW = 'Submitted for Review';
    public static final String PROGRAM_STATUS_REVIEWED = 'Reviewed';

    //Yes/No Picklist Values
    public static final String PICKLIST_VALUE_YES ='Yes';
    public static final String PICKLIST_VALUE_NO ='No';

    //Error Messages
    public static final String PROGRAM_AT_LEAST_ONE_FOCUS_AREA_ERROR_MESSAGE ='P01-GRNTR-19178';
    public static final String PROGRAM_AT_LEAST_ONE_PROGRAM_CONTACT_ERROR_MESSAGE ='GEN-GRNTE-75625';
    public static final String PROGRAM_PROGRAM_APPROVER_REQUIRED_ERROR_MESSAGE ='M01-GRNTR-99971';
    public static final String PROGRAM_EXECUTIVE_APPROVER_REQUIRED_ERROR_MESSAGE ='P01-GRNTR-35786'; 
    public static final String PROGRAM_DUPLICATE_ABBREVIATION_ERROR_MESSAGE ='GEN-GRNTR-76501';
    public static final String PROGRAM_AT_LEAST_ONE_KPI_ERROR_MESSAGE = 'P01-GRNTR-96529';
    public static final String PROGRAM_AT_LEAST_ONE_OBJECTIVE_ERROR_MESSAGE = 'P01-GRNTR-37408';
    public static final String PROGRAM_OBJECTIVES_REQUIRED_FOR_SUBMIT = 'P01-GRNTR-61432';

    //Success Messages
    public static final String PROGRAM_PROGRAM_SUBMITTED_SUCCESS_MESSAGE ='M01-GRNTR-12057';
    public static final String PROGRAM_PROGRAM_ACTIVATED_SUCCESS_MESSAGE ='M01-GRNTR-83576';

    //Email Templates.
    public static final String PROGRAM_EMAIL_TEMPLATE_SENT_TO_OWNER = 'Program Sent To Owner';

    //Task Actions
    public static final String INTERNAL_PROGRAM_TASK_ACTION_SUBMIT_FOR_APPROVAL = 'Approve Program';
    public static final String INTERNAL_PROGRAM_TASK_ACTION_ACTIVATE = 'Activate Internal Program';
    public static final String NGO_PROGRAM_PROGRAM_TASK_ACTION_ACTIVATE = 'Activate NGO Program';

    //Program Settings
    public static final String REMOVE_FOCUS_AREAS_IF_FOCUSAREA_REQUIRED_IS_NO = 'GEN-GRNTR-18952';
    public static final String REMOVE_KPIS_IF_KPI_REQUIRED_IS_NO = 'GEN-GRNTR-92989' ;
    public static final String REMOVE_OBJECTIVES_IF_OBJECTIVES_REQUIRED_IS_NO = 'GEN-GRNTR-20340';
    public static final String FEDERAL_PROGRAM_NAME_ALREADY_EXISTS = 'GEN-GRNTR-18312';

    //Report type
    public static final String REPORTTYPE_PROGRESS_REPORT = 'Progress Report';

    //App Name
    public static final String APP_NAME_GRANTOR = 'StateasGrantor';
    public static final String APP_NAME_GRANTEE = 'StateasGrantee';

}