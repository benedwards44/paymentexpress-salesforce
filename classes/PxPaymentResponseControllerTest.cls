/**
* Author:       Ben Edwards (ben@benedwards.co.nz)
* Date:         20/04/2015
* Description:  Test Class for PxPaymentResponseController. 
*               Simulates callout response and validates different response types
*/
@isTest
public class PxPaymentResponseControllerTest {
    
    // Test the processResponseAndRedirect() method
    static testMethod void testProcessResponseAndRedirectSuccess() {

        // Create custom setting authentication values
        PxPaymentHandlerTest.createPxPaymentAuthDefaults();

        // Create community user
        User communityUser = TestData.createCommunityUser(null);
        insert communityUser;

        // Create Person Account and Community User
        system.runAs(communityUser){

            Test.startTest();

            // Create mock response from static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('PxPaymentResponseSuccessMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/xml');

            // Set mock class for test method
            Test.setMock(HttpCalloutMock.class, mock);

            // Initiate controller for testing
            PxPaymentResponseController responseController = new PxPaymentResponseController();

            // Initiate page and set parameters
            PageReference responsePage = Page.PxPaymentResponse;
            responsePage.getParameters().put('result', 'abc123');
            Test.setCurrentPage(responsePage);

            // Process the redirect
            responseController.processResponseAndRedirect();

            Test.stopTest();

        }

        // Assert account updated
        system.assert(
            [Select Payment_Information_Complete__c From Account][0].Payment_Information_Complete__c,
            'Payment information should be checked as complete'
        );

    }

    // Test the processResponseAndRedirect() method
    static testMethod void testProcessResponseAndRedirectFailure() {

        // Create custom setting authentication values
        PxPaymentHandlerTest.createPxPaymentAuthDefaults();

        // Create community user
        User communityUser = TestData.createCommunityUser(null);
        insert communityUser;

        // Create Person Account and Community User
        system.runAs(communityUser){

            Test.startTest();

            // Create mock response from static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('PxPaymentResponseFailureMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/xml');

            // Set mock class for test method
            Test.setMock(HttpCalloutMock.class, mock);

            // Initiate controller for testing
            PxPaymentResponseController responseController = new PxPaymentResponseController();

            // Initiate page and set parameters
            PageReference responsePage = Page.PxPaymentResponse;
            responsePage.getParameters().put('result', 'abc123');
            Test.setCurrentPage(responsePage);

            // Process the redirect
            responseController.processResponseAndRedirect();

            Test.stopTest();

        }

        // Assert account updated
        system.assert(
            ![Select Payment_Information_Complete__c From Account][0].Payment_Information_Complete__c,
            'Payment information should not be checked as complete'
        );

    }

    // Test the processResponseAndRedirect() method and throw exception
    static testMethod void testProcessResponseAndRedirectException() {

        // Create community user
        User communityUser = TestData.createCommunityUser(null);
        insert communityUser;

        // Create Person Account and Community User
        system.runAs(communityUser){

            // Initiate controller for testing
            PxPaymentResponseController responseController = new PxPaymentResponseController();

            // Initiate page and set parameters
            PageReference responsePage = Page.PxPaymentResponse;
            responsePage.getParameters().put('result', 'abc123');
            Test.setCurrentPage(responsePage);

            // Process the redirect
            responseController.processResponseAndRedirect();

        }

    }

}