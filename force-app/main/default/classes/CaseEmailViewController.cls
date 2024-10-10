public with sharing class CaseEmailViewController {
    @AuraEnabled(cacheable=true)
    public static List<EmailMessage> getCaseEmails(Id caseId) {
        if (caseId == null || !isValidCaseId(caseId)) {
            throw new CaseEmailException('The provided Case ID is invalid or does not exist.');
        }

        try {
            List<EmailMessage> emails = [
                SELECT Id, FromAddress, HtmlBody, TextBody, Subject, CreatedDate
                FROM EmailMessage
                WHERE ParentId = :caseId
                ORDER BY CreatedDate DESC
                LIMIT 50
            ];
            return emails;
        } catch (Exception e) {
            throw new CaseEmailException('An error occurred while fetching emails: ' + e.getMessage());
        }
    }

    // Helper method to check if the provided Case ID is valid and exists
    private static Boolean isValidCaseId(Id caseId) {
        return [SELECT COUNT() FROM Case WHERE Id = :caseId] > 0;
    }

    // Custom Exception Class
    public class CaseEmailException extends Exception {}
}