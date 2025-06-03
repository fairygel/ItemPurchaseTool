import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getAccountDetails from '@salesforce/apex/AccountController.getAccountDetails'

export default class ItemPurchaseTool extends LightningElement {
    accountId;
    account;

    @wire(CurrentPageReference)
    getPageRef(pageRef) {
        if (pageRef?.state.c__accountId) {
            this.accountId = pageRef.state.c__accountId;
        }

        getAccountDetails({accountId: this.accountId})
            .then(account => {this.account = account})
            .catch(error => console.log(error));
    }
}
