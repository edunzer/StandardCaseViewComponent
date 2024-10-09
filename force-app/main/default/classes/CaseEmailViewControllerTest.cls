@isTest
public class CaseEmailViewControllerTest {
    @testSetup
    static void setupTestData() {
        // Create a test Account and Contact
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = testAccount.Id);
        insert testContact;

        // Create a test Case linked to the Contact
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            ContactId = testContact.Id,
            AccountId = testAccount.Id
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
        System.assertEquals('test1@example.com', emails[0].FromAddress, 'Unexpected FromAddress in the first email.');
        System.assertEquals('test2@example.com', emails[1].FromAddress, 'Unexpected FromAddress in the second email.');
    }
}