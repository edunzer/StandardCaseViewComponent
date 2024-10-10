@isTest
public class CaseEmailViewControllerTest {
    @testSetup
    static void setupTestData() {
        // Create a test Case
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert testCase;
    
        // Create test EmailMessages linked to the Case
        EmailMessage email1 = new EmailMessage(
            ParentId = testCase.Id,
            FromAddress = 'test1@example.com',
            ToAddress = 'testreceiver@example.com',
            Subject = 'Test Email 1',
            HtmlBody = 'This is the body of test email 1.'
        );
        insert email1;
    
        EmailMessage email2 = new EmailMessage(
            ParentId = testCase.Id,
            FromAddress = 'test2@example.com',
            ToAddress = 'testreceiver@example.com',
            Subject = 'Test Email 2',
            HtmlBody = 'This is the body of test email 2.'
        );
        insert email2;
    }

    @isTest
    static void testGetCaseEmails() {
        // Retrieve the test Case
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Call the method and assert the results
        Test.startTest();
        List<EmailMessage> emails = CaseEmailViewController.getCaseEmails(testCase.Id);
        Test.stopTest();

        // Verify that the emails are returned correctly
        System.assertEquals(2, emails.size(), 'Expected two email messages to be returned.');
        System.assert(emails[0].CreatedDate >= emails[1].CreatedDate, 'Emails are not returned in the correct order.');
    }

    @isTest
    static void testGetCaseEmailsNoEmails() {
        // Create a new test Case with no emails
        Case noEmailCase = new Case(
            Subject = 'Test Case with No Emails',
            Status = 'New'
        );
        insert noEmailCase;

        // Call the method with a Case that has no emails
        Test.startTest();
        List<EmailMessage> emails = CaseEmailViewController.getCaseEmails(noEmailCase.Id);
        Test.stopTest();

        // Verify that no emails are returned
        System.assertEquals(0, emails.size(), 'Expected no email messages to be returned.');
    }

    @isTest
    static void testGetCaseEmailsInvalidCaseId() {
        // Use a properly formatted but non-existent Case ID to simulate error handling
        Id fakeCaseId = '500000000000000000'; // An ID that follows the format but does not exist in the org

        Test.startTest();
        try {
            List<EmailMessage> emails = CaseEmailViewController.getCaseEmails(fakeCaseId);
            System.assert(false, 'Expected a CaseEmailViewController.CaseEmailException due to non-existent Case ID.');
        } catch (CaseEmailViewController.CaseEmailException e) {
            // Verify the exception message
            System.assert(e.getMessage().contains('The provided Case ID is invalid or does not exist.'), 'Unexpected exception message: ' + e.getMessage());
        } catch (Exception e) {
            System.assert(false, 'Expected a CaseEmailViewController.CaseEmailException but got a different exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testGetCaseEmailsExceptionHandling() {
        // Use a valid but non-existent Case ID
        Id nonExistentId = '001000000000000AAA'; // Valid Account ID format that does not correspond to a Case
    
        Test.startTest();
        try {
            List<EmailMessage> emails = CaseEmailViewController.getCaseEmails(nonExistentId);
            System.assert(false, 'Expected a CaseEmailViewController.CaseEmailException due to non-existent Case ID.');
        } catch (CaseEmailViewController.CaseEmailException e) {
            // Verify the exception message
            System.assert(e.getMessage().contains('The provided Case ID is invalid or does not exist.'), 'Unexpected exception message: ' + e.getMessage());
        } catch (Exception e) {
            System.assert(false, 'Expected a CaseEmailViewController.CaseEmailException but got a different exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
}