/**
* Author:       Ben Edwards (ben@benedwards.co.nz)
* Date:         20/04/2015
* Description:  Contoller for the PxPaymentResponse page
*               Handles succcess and failure responses from Payment Express and handles accordingly
*               Note: without sharing used to allow user to update their account record
*/
public without sharing class PxPaymentResponseController {
    
    // Page Constructor 
    public PxPaymentResponseController() { }
    

    /**
    * Author:       Ben Edwards (ben@benedwards.co.nz)
    * Date:         20/04/2015
    * Function:     Processes the response, updates records and redirects user
    **/
    public PageReference processResponseAndRedirect() {

        // Get the encryped result string from the URL. This was returned by PaymentExpress
        String encryptedResult = ApexPages.currentPage().getParameters().get('result');

        // Query for the account record for the logged in community user
        Account account = [
            Select  Id  
                    , Payment_Amount__c
                    , Payment_Date__c
                    , Payment_Information_Complete__c
                    , Payment_Processing_Error__c
            From    Account
            Where   Id IN (Select AccountId From User Where Id = :UserInfo.getUserId())
        ];

        try {

            // Make request for payment response information.
            PXPaymentHandler.PaymentResponse response = PXPaymentHandler.getPaymentResponseDetails(encryptedResult);

            // If successful payment
            if (response.success) {

                // Enter payment details against account
                account.Payment_Amount__c               = response.paymentAmount;
                account.Payment_Date__c                 = system.now();
                account.Payment_Processing_Error__c     = null;
                account.Payment_Information_Complete__c = true;

            }
            // If payment failed
            else {

                // Enter failure details against account
                account.Payment_Amount__c               = null;
                account.Payment_Date__c                 = null;
                account.Payment_Processing_Error__c     = response.errorMessage;
                account.Payment_Information_Complete__c = false;

            }

        }
        catch (Exception ex) {

            // Enter failure details against account
            account.Payment_Amount__c               = null;
            account.Payment_Date__c                 = null;
            account.Payment_Processing_Error__c     = ex.getMessage();
            account.Payment_Information_Complete__c = false;

        }

        // Update the Account
        update account;

        // Return user to the base site URL with URL parameter to open user to payment modal
        return new PageReference(Site.getBaseUrl() + '?showPaymentModal=1');
    }
    
}