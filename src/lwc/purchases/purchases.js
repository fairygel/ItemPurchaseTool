import {api, LightningElement, track} from 'lwc';
import getPurchasesByAccount from '@salesforce/apex/PurchaseController.getPurchases';

export default class Purchases extends LightningElement {
    @api accountId;
    @api visible = false;

    @track purchases = [];
    @track isLoading = false;
    @track error;

    @api
    open() {
        this.visible = true;
        this.loadPurchases();
    }

    loadPurchases() {
        if (!this.accountId) {
            this.error = 'AccountId is missing';
            return;
        }

        this.isLoading = true;

        getPurchasesByAccount({ accountId: this.accountId })
            .then(data => {
                this.purchases = data;
                this.error = undefined;
            })
            .catch(err => {
                console.error(err);
                this.error = err?.body?.message || 'Error loading purchases';
                this.purchases = [];
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleClose() {
        this.visible = false;
        this.dispatchEvent(new CustomEvent('close'));
    }
}