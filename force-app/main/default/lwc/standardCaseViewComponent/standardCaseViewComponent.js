import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getCaseEmails from '@salesforce/apex/CaseEmailViewController.getCaseEmails';

// Field API names
import CASE_NUMBER_FIELD from '@salesforce/schema/Case.CaseNumber';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import RECORD_TYPE_ID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import OWNER_ID_FIELD from '@salesforce/schema/Case.OwnerId';
import CONTACT_NAME_FIELD from '@salesforce/schema/Case.Contact.Name';
import CONTACT_EMAIL_FIELD from '@salesforce/schema/Case.ContactEmail';
import SUPPLIED_EMAIL_FIELD from '@salesforce/schema/Case.SuppliedEmail';
import STATUS_FIELD from '@salesforce/schema/Case.Status';  // <-- Add the Status field

// Get Owner and RecordType fields dynamically
const FIELDS = [
    CASE_NUMBER_FIELD,
    SUBJECT_FIELD,
    RECORD_TYPE_ID_FIELD,
    OWNER_ID_FIELD,
    CONTACT_NAME_FIELD,
    CONTACT_EMAIL_FIELD,
    SUPPLIED_EMAIL_FIELD,
    STATUS_FIELD  // <-- Add Status field to the list of fields
];

export default class StandardCaseViewComponent extends LightningElement {
    @api recordId; // Accept the Case record ID as input
    @track caseRecord; // Store case details
    @track emails = []; // Store email messages related to the case
    @track errorMessage = ''; // For displaying error messages

    // Define path stages for the path component
    @track pathStages = [
        { label: 'New', value: 'New' },
        { label: 'Being Reviewed', value: 'Being Reviewed' },
        { label: 'On Hold', value: 'On Hold' },
        { label: 'Closed', value: 'Closed' }
    ];

    // Fetch case details using the recordId and specify the fields we want
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS, optionalFields: ['Case.Owner.Name', 'Case.RecordType.Name'] })
    wiredCase({ error, data }) {
        if (data) {
            this.caseRecord = data;
            this.errorMessage = '';
            this.fetchEmails(); // Fetch emails when case is successfully loaded
        } else if (error) {
            this.errorMessage = 'Error loading case details.';
            this.caseRecord = null;
        }
    }

    // Fetch email messages related to the case
    fetchEmails() {
        getCaseEmails({ caseId: this.recordId })
            .then((result) => {
                this.emails = result.map((email) => ({
                    ...email,
                    formattedLabel: 'From: ' + email.FromAddress,
                    truncatedBody: this.extractLatestEmailContent(email.HtmlBody),
                    fullBody: email.HtmlBody
                }));

                if (this.emails.length === 0) {
                    this.emails = [{ formattedLabel: 'No emails found for this case.', truncatedBody: '' }];
                }
            })
            .catch((error) => {
                this.errorMessage = 'Error fetching emails: ' + (error.body ? error.body.message : 'An unknown error occurred.');
            });
    }

    // Extract only the latest email content
    extractLatestEmailContent(emailBody) {
        const regex = /(\r?\n|\r)?(?:From:|On .*? wrote:|Sent:|--- Original Message ---|____ Forwarded message ____)/i;
        const newContentArray = emailBody ? emailBody.split(regex) : [''];
        return newContentArray[0].trim();
    }

    // Getter for the current step in the path component based on the case status
    get currentStep() {
        return getFieldValue(this.caseRecord, STATUS_FIELD) || 'New'; // Updated to use STATUS_FIELD
    }

    // Getters for the fields
    get caseNumber() {
        return getFieldValue(this.caseRecord, CASE_NUMBER_FIELD);
    }

    get subject() {
        return getFieldValue(this.caseRecord, SUBJECT_FIELD); // Updated to use SUBJECT_FIELD
    }  

    get recordTypeName() {
        return getFieldValue(this.caseRecord, 'Case.RecordType.Name');
    }

    get ownerName() {
        return getFieldValue(this.caseRecord, 'Case.Owner.Name');
    }

    get contactName() {
        return getFieldValue(this.caseRecord, CONTACT_NAME_FIELD);
    }

    get contactEmail() {
        return getFieldValue(this.caseRecord, CONTACT_EMAIL_FIELD);
    }

    get suppliedEmail() {
        return getFieldValue(this.caseRecord, SUPPLIED_EMAIL_FIELD);
    }
}
