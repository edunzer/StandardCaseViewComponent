public with sharing class CaseEmailViewController {
    @AuraEnabled(cacheable=true)
    public static List<EmailMessage> getCaseEmails(Id caseId) {
        try {
            List<EmailMessage> emails = [
                SELECT Id, FromAddress, HtmlBody, TextBody, Subject, CreatedDate
                FROM EmailMessage
                WHERE ParentId = :caseId
                ORDER BY CreatedDate DESC
            ];
            return emails;
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred while fetching emails: ' + e.getMessage());
        }
    }
}