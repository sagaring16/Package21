/*  Purpose: Fetches all the error messages.
    **********************************************************
    Audit History
    **********************************************************
    07/09/2018     Nakul            Created  
    14/5/2025     Snehal Harihar    Update for #Security
    **********************************************************
*/

global with sharing class ErrorMessageUtility{      //ON VA org acces modifier is chnages to public so should we change on GGDev2 also
    
    private static Map<String, String> errorMessageMap = new Map<String, String>();
    
    global static Map<String, String> fetchMessages(Set<String> errorCodes){
        Set<String> errorCodesTemp = new Set<String>();
        // Check if we have already queried the messages related to the input errorcodes.
        for(String errorCode : errorCodes){
            if(errorMessageMap.get(errorCode) != null){
                errorCodesTemp.add(errorCode);
            }
        }
        if(errorCodesTemp.size() == errorCodes.size()){
            return errorMessageMap;
        }

        //Query and populate the errorMessageMap
        List<GNT__ErrorMessageConfig__c> errorMessages = [SELECT id,GNT__Message__c,GNT__Message_Type__c, GNT__ErrorCode__c
                                                            FROM GNT__ErrorMessageConfig__c 
                                                            WHERE GNT__ErrorCode__c 
                                                            IN :errorCodes 
                                                            WITH USER_MODE];
        for(GNT__ErrorMessageConfig__c errMsg : errorMessages){
            errorMessageMap.put(errMsg.GNT__ErrorCode__c, errMsg.GNT__Message__c);
        }
        return errorMessageMap;
    }
}