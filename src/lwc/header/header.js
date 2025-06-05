import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getAccountDetails from '@salesforce/apex/AccountController.getAccountDetails'

export default class ItemPurchaseTool extends LightningElement {
    accountId;

    account;
    error;

    @wire(CurrentPageReference)
    getPageRef(pageRef) {
        if (pageRef?.state.c__accountId) {
            this.accountId = pageRef.state.c__accountId;
        }

        getAccountDetails({accountId: this.accountId})
            .then(account => {this.account = account; this.error = undefined})
            .catch(error => {console.log(error); this.error = error;});
    }
}
