import {LightningElement, track, wire} from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getAccountDetails from '@salesforce/apex/AccountController.getAccountDetails'
import isUserManager from '@salesforce/apex/UserController.isUserManager'

export default class ItemPurchaseTool extends NavigationMixin(LightningElement) {
    isManager = false;
    isManagerError;

    accountId;
    account;
    accountError;

    isCartVisible = false;
    isCreateItemOpened = false;
    @track isOrdersOpened = false;

    @wire(isUserManager)
    wiredIsManager ({error, data}) {
        if (data !== undefined) {
            this.isManager = data;
        } else if (error) {
            console.log(error);
            this.isManagerError = error;
        }
    }

    @wire(CurrentPageReference)
    getPageRef(pageRef) {
        if (pageRef?.state.c__accountId) {
            this.accountId = pageRef.state.c__accountId;
        }

        getAccountDetails({accountId: this.accountId})
            .then(account => {this.account = account; this.accountError = undefined})
            .catch(error => {console.log(error); this.accountError = error;});
    }

    // navigate to accounts list
    handleNavigate() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'list'
            },
            state: {
                filterName: 'AllAccounts'
            }
        });
    }

    handleCartOpen() {
        this.isCartVisible = true;
        this.template.querySelector('c-cart').open();
    }

    handleCloseCart() {
        this.isCartVisible = false;
    }

    openOrders() {
        this.isOrdersOpened = true;
        this.template.querySelector('c-purchases').open();
    }

    handleCloseOrders() {
        this.isOrdersOpened = false;
    }

    handleShowCreateForm() {
        this.isCreateItemOpened = true;
    }

    handleCloseCreateForm() {
        this.isCreateItemOpened = false;
    }
}
