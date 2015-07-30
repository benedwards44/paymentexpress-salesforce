/**
* Author:       Ben Edwards (ben@benedwards.co.nz)
* Date:         20/04/2015
* Description:  Test Class for PXPaymentHandler. 
*               Simulates callout and validates different responses
*/
@isTest
public class PxPaymentHandlerTest {

    // Test successfully callout of getPaymentRedirectUrlSuccess()
    static testMethod void testGetPaymentRedirectUrlSuccess() {

        // Create custom setting authentication values
        createPxPaymentAuthDefaults();

        Test.startTest();

        // Create mock response from static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PxPaymentRedirectMock');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');

        // Set mock class for test method
        Test.setMock(HttpCalloutMock.class, mock);

        // Test current URL
        String currentUrl = 'https://msg-syndicatexchange.cs5.force.com/investors';

        // Make fake callout
        PXPaymentHandler.PaymentResponse response = PXPaymentHandler.getPaymentRedirectUrl(currentUrl);

        Test.stopTest();

        // Assert results
        system.assert(
            response.success,
            'Response should have success flagged'
        );

        system.assert(
            response.redirectUrl != null,
            'Redirect URL shouldn\'t be null'
        );

    }

    // Test failing callout of getPaymentRedirectUrlSuccess()
    static testMethod void testGetPaymentRedirectUrlError() {

        // Create custom setting authentication values
        createPxPaymentAuthDefaults();

        Test.startTest();

        // Create mock response from static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PxPaymentRedirectMock');
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/xml');

        // Set mock class for test method
        Test.setMock(HttpCalloutMock.class, mock);

        // Test current URL
        String currentUrl = 'https://msg-syndicatexchange.cs5.force.com/investors';

        // Make fake callout
        PXPaymentHandler.PaymentResponse response = PXPaymentHandler.getPaymentRedirectUrl(currentUrl);

        Test.stopTest();

        // Assert results
        system.assert(
            !response.success,
            'Response should not have success flagged'
        );

        system.assert(
            response.redirectUrl == null,
            'Redirect URL should be null'
        );
    }

    // Test successfull callout of getPaymentResponseDetails() method
    static testMethod void testGetPaymentResponseDetailsSuccess() {

        // Create custom setting authentication values
        createPxPaymentAuthDefaults();

        Test.startTest();

        // Create mock response from static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PxPaymentResponseSuccessMock');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');

        // Set mock class for test method
        Test.setMock(HttpCalloutMock.class, mock);

        // Test current URL
        String encryptedResponse = 'abc123';

        // Make fake callout
        PXPaymentHandler.PaymentResponse response = PXPaymentHandler.getPaymentResponseDetails(encryptedResponse);

        Test.stopTest();

        // Assert results
        system.assert(
            response.success,
            'Response should have success flagged'
        );

    }

    // Test failing callout of getPaymentResponseDetails() method
    static testMethod void testGetPaymentResponseDetailsFailure() {

        // Create custom setting authentication values
        createPxPaymentAuthDefaults();

        Test.startTest();

        // Create mock response from static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PxPaymentResponseFailureMock');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');

        // Set mock class for test method
        Test.setMock(HttpCalloutMock.class, mock);

        // Test current URL
        String encryptedResponse = 'abc123';

        // Make fake callout
        PXPaymentHandler.PaymentResponse response = PXPaymentHandler.getPaymentResponseDetails(encryptedResponse);

        Test.stopTest();

        // Assert results
        system.assert(
            !response.success,
            'Response should not have success flagged'
        );

    }

    // Test failing callout of getPaymentResponseDetails() method
    static testMethod void testGetPaymentResponseDetailsFailure404() {

        // Create custom setting authentication values
        createPxPaymentAuthDefaults();

        Test.startTest();

        // Create mock response from static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('PxPaymentResponseFailureMock');
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/xml');

        // Set mock class for test method
        Test.setMock(HttpCalloutMock.class, mock);

        // Test current URL
        String encryptedResponse = 'abc123';

        // Make fake callout
        PXPaymentHandler.PaymentResponse response = PXPaymentHandler.getPaymentResponseDetails(encryptedResponse);

        Test.stopTest();

        // Assert results
        system.assert(
            !response.success,
            'Response should not have success flagged'
        );

    }


    // Create test custom setting for PX Payment Authentication
    public static void createPxPaymentAuthDefaults() {

        PX_Authentication__c pxAuth = new PX_Authentication__c(
            SetupOwnerId = System.Userinfo.getOrganizationId()
        );
        pxAuth.Payment_Amount__c = 100;
        pxAuth.PxPayKey__c = 'KEY';
        pxAuth.PxPayUserId__c = 'UserId';
        pxAuth.PxPayUrl__c = 'https://sec.paymentexpress.com/pxaccess/pxpay.aspx';
        insert pxAuth;

    }


}