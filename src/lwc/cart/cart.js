import {LightningElement, api, track} from 'lwc';
import getCartItems from '@salesforce/apex/CartController.getCartItems';

export default class Cart extends LightningElement {
    @api accountId;
    @api visible = false;

    @track
    cartItems = [];

    @track
    cartTotal = 0;

    isLoading = false;
    error;

    @api
    open() {
        this.visible = true;
        this.loadCartItems();
    }

    loadCartItems() {
        if (!this.accountId) {
            this.error = "No account chosen.";
            return;
        }
        this.isLoading = true;

        getCartItems({ accountId: this.accountId })
            .then((result) => {
                this.cartItems = result;
                this.isLoading = false;

                if (result.length > 0) {
                    this.cartTotal = result[0].Cart__r.TotalAmount__c;
                } else {
                    this.cartTotal = 0;
                }
            })
            .catch((err) => {
                this.error = err;
                this.isLoading = false;
                this.cartItems = [];
                console.log(err);
            })
    }

    handleClose() {
        this.visible = false;
        this.dispatchEvent(new CustomEvent('close'));
    }
}