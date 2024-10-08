import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class StandardCaseViewComponent extends LightningElement {
    @api recordId; // Accept the Case record ID as input
    @track caseRecord; // Store case details
    @track emails = []; // Store email messages related to the case
    @track errorMessage = ''; // For displaying error messages

    // Fetch case details using the recordId without specifying individual fields
    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Full'] }) // Fetch entire case record with all fields
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
                this.emails = result.map(email => ({
                    ...email,
                    formattedLabel: 'From: ' + email.FromAddress,
                    body: email.HtmlBody
                }));

                if (this.emails.length === 0) {
                    this.emails = [{ formattedLabel: 'No emails found for this case.', body: '' }];
                }
            })
            .catch((error) => {
                this.errorMessage = 'Error fetching emails: ' + error.body.message;
            });
    }
}
