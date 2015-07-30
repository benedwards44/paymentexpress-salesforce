/**
* Author:       Ben Edwards (ben@benedwards.co.nz)
* Date:         20/04/2015
* Description:  Handler class for the Payment Express integration.
*               Documention can be found at:
*               http://www.paymentexpress.com/Downloads/DPSECOM_PXPay_2_0_IntegrationGuide.pdf
**/
public class PxPaymentHandler {
    
    /**
    * Author:       Ben Edwards (ben@benedwards.co.nz)
    * Date:         20/04/2015
    * Function:     Generate XML for PX Post request
    **/
    public static String generateRequestXml(String currentUrl) {

        // Use PXPaymentGenerateRequest VF page to build XML
        PageReference xmlPage = Page.PXPaymentGenerateRequestXML;

        // Add current Site URL and response page as parameters
        xmlPage.getParameters().put('successUrl', currentUrl + '/PxPaymentResponse');

        // Add payment request parameter to generate correct XML
        xmlPage.getParameters().put('generateRequest', '1');

        // Add additional parameters here which can be passed to the XML page
        // Eg. xmlPage.getParameters().put('paymentAmount', 100.00);

        // getContent() not supported for test methods
        if (!Test.IsRunningTest()){
            // Return XML String used for POSTing to PX Pay
            return xmlPage.getContent().toString();
        }
        else {
            return '<Test></Test>';
        }
    }

    /**
    * Author:       Ben Edwards (ben@benedwards.co.nz)
    * Date:         20/04/2015
    * Function:     Generate XML for PX Post response request
    **/
    public static String generateResponseXml(String encrptedResult) {

        // Use PXPaymentGenerateRequest VF page to build XML
        PageReference xmlPage = Page.PXPaymentGenerateRequestXML;

        // Add process response parameter to generate correct XML
        xmlPage.getParameters().put('processResponse', '1');

        // Add the encrypted result string to the page
        xmlPage.getParameters().put('result', encrptedResult);

        // getContent() not supported for test methods
        if (!Test.IsRunningTest()){
            // Return XML String used for POSTing to PX Pay
            return xmlPage.getContent().toString();
        }
        else {
            return '<Test></Test>';
        }
    }

    /**
    * Author:       Ben Edwards (ben@benedwards.co.nz)
    * Date:         20/04/2015
    * Function:     Determine the redirect URL to capture payment details
    **/
    public static PaymentResponse getPaymentRedirectUrl(String currentUrl) {

        // Instantiate a new http object
        Http h = new Http();

        // Create HttpRequest
        HttpRequest req = new HttpRequest();
        req.setEndpoint(PX_Authentication__c.getOrgDefaults().PxPayUrl__c);
        req.setMethod('POST');
        req.setBody(generateRequestXml(currentUrl));

        // Make callout
        HttpResponse res = h.send(req);

        // Response object to return
        PaymentResponse response = new PaymentResponse();

        // If successful response
        if (res.getStatusCode() == 200){

            response.success = true;

            // Parse XML response into DOM element
            Dom.Document doc = res.getBodyDocument();

            // Root element for the response
            Dom.XMLNode request = doc.getRootElement();

            // Take the text from the URI element
            response.redirectUrl = request.getChildElement('URI', null).getText();

        }

        // Otherwise, return error
        else {

            response.success = false;

            // Error message could be parsed, but returning full body instead
            // There is no documentation from PaymentExpress about how an error response would look
            response.errorMessage = res.getBody();
        }

        // Return response
        return response;
    }

    /**
    * Author:       Ben Edwards (ben@benedwards.co.nz)
    * Date:         20/04/2015
    * Function:     Determine the redirect URL to capture payment details
    **/
    public static PaymentResponse getPaymentResponseDetails(String encrptedResult) {

        // Instantiate a new http object
        Http h = new Http();

        // Create HttpRequest
        HttpRequest req = new HttpRequest();
        req.setEndpoint(PX_Authentication__c.getOrgDefaults().PxPayUrl__c);
        req.setMethod('POST');
        req.setBody(generateResponseXml(encrptedResult));

        // Make callout
        HttpResponse res = h.send(req);

        // Response object to return
        PaymentResponse response = new PaymentResponse();

        // If successful response
        if (res.getStatusCode() == 200){

            system.debug('### ' + res.getBody());

            // Parse XML response into DOM element
            Dom.Document doc = res.getBodyDocument();

            // Root element for the response
            Dom.XMLNode request = doc.getRootElement();

            // Capture success or failure
            response.success = request.getChildElement('Success', null).getText() == '1';

            // If success, add payment details to PaymentResponse object
            if (response.success) {

                response.paymentAmount = Decimal.valueOf(request.getChildElement('AmountSettlement', null).getText());

            }   
            // If failure, populate failure details to PaymentResponse object
            else {

                response.errorMessage = 'Payment processing error: ' + request.getChildElement('ResponseText', null).getText();
                response.errorMessage += '\n\nPlease try again, or contact Syndex for support.';
            }

        } 
        else {

            response.success = false;

            // Error message could be parsed, but returning full body instead
            // There is no documentation from PaymentExpress about how an error response would look
            response.errorMessage = res.getBody();
        }

        return response;
    }

    // Wrapper class for success/error and error handling
    public class PaymentResponse {
        public Boolean  success;
        public String   redirectUrl;
        public String   errorMessage;
        public Decimal  paymentAmount;
    }


}