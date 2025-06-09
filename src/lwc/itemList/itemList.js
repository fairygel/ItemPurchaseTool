import {LightningElement, track, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation'
import getItemsBySearch from '@salesforce/apex/ItemController.getItemsBySearch';
import getTypeOptions from '@salesforce/apex/FilterService.getTypeOptions';
import getFamilyOptions from '@salesforce/apex/FilterService.getFamilyOptions';
import addItemToCart from '@salesforce/apex/CartController.addItemToCart';
import getCartItems from '@salesforce/apex/CartController.getCartItems';

export default class ItemList extends LightningElement {
    @track items;
    @track error;
    @track searchKey = '';

    // applied filters
    @track familyFilters = [];
    @track typeFilters = [];

    // all available options for filters
    @track familyOptions = [];
    @track typeOptions = [];

    @track selectedItem = null;

    @track isDetailsOpen = false;

    @track cartQuantities = {};

    @track accountId;

    @wire(CurrentPageReference)
    getPageRef(pageRef) {
        if (pageRef?.state.c__accountId) {
            this.accountId = pageRef.state.c__accountId;
        }
    }

    handleShowDetails(event) {
        const itemId = event.currentTarget.dataset.id;
        this.selectedItem = this.items.find(i => i.Id === itemId);
        this.isDetailsOpen = true;
    }

    handleCloseModal() {
        this.isDetailsOpen = false;
        this.selectedItem = null;
    }

    connectedCallback() {
        this.loadPicklistValues();
        this.loadItems();
        this.loadCartQuantities();
    }

    loadCartQuantities() {
        if (!this.accountId) return;

        getCartItems({ accountId: this.accountId })
            .then((cartItems) => {
                const quantities = {};
                cartItems.forEach((item) => {
                    quantities[item.Item__c] = item.Quantity__c;
                });
                this.cartQuantities = quantities;

                if (this.items) {
                    this.items = this.items.map(
                        item => ({
                            ...item,
                            quantityInCart: this.cartQuantities[item.Id] || 0
                        })
                    );
                }
            })
            .catch((err) => {
                console.error(err);
            })
    }

    handleChangeQuantity(event) {
        const shouldSubtract = event.currentTarget.dataset.shouldsubtract === 'true';
        const itemId = event.currentTarget.dataset.id;

        addItemToCart({ accountId: this.accountId, itemId: itemId, shouldSubtract: shouldSubtract })
            .then(quantity => {
                this.cartQuantities = {
                    ...this.cartQuantities,
                    [itemId]: quantity
                };

                this.items = this.items.map(item => {
                    if (item.Id === itemId) {
                        return { ...item, quantityInCart: quantity};
                    }
                    return item;
                })
            })
            .catch(error => {
                console.error(error);
                this.error = error;
            });
    }

    loadPicklistValues() {
        getTypeOptions()
            .then(typeOptions => {
                this.typeOptions = typeOptions;
            })
            .catch(error => {
                this.error = error.body.message;
            })
        getFamilyOptions()
            .then(familyOptions => {
                this.familyOptions = familyOptions;
            })
            .catch(error => {
                this.error = error.body.message;
            })
    }

    loadItems() {
        getItemsBySearch({
            searchKey: this.searchKey,
            familyFilters: this.familyFilters,
            typeFilters: this.typeFilters
        })
            .then(result => {
                this.items = result.map(item => {
                    return {
                        ...item,
                        quantityInCart: this.cartQuantities[item.Id] || 0
                    }
                })
                this.error = undefined;
            })
            .catch(error => {
                this.items = undefined;
                this.error = error.body.message;
            });
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value;
        this.loadItems();
    }

    handleFamilyChange(event) {
        const value = event.target.value;
        if (event.target.checked) {
            this.familyFilters = [...this.familyFilters, value];
        } else {
            this.familyFilters = this.familyFilters.filter(f => f !== value);
        }
        this.loadItems();
    }

    handleTypeChange(event) {
        const value = event.target.value;
        if (event.target.checked) {
            this.typeFilters = [...this.typeFilters, value];
        } else {
            this.typeFilters = this.typeFilters.filter(t => t !== value);
        }
        this.loadItems();
    }
}
