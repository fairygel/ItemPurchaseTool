import { LightningElement, track } from 'lwc';
import getItemsBySearch from '@salesforce/apex/ItemController.getItemsBySearch';
import getPicklistValues from '@salesforce/apex/ItemController.getPicklistValues';

export default class ItemList extends LightningElement {
    @track items;
    @track error;
    @track searchKey = '';

    @track familyFilters = [];
    @track typeFilters = [];

    @track familyOptions = [];
    @track typeOptions = [];

    connectedCallback() {
        this.loadPicklistValues();
        this.loadItems();
    }

    loadPicklistValues() {
        getPicklistValues()
            .then(result => {
                this.familyOptions = result.Family;
                this.typeOptions = result.Type;
            })
            .catch(error => {
                this.error = error.body.message;
            });
    }

    loadItems() {
        getItemsBySearch({
            searchKey: this.searchKey,
            familyFilters: this.familyFilters,
            typeFilters: this.typeFilters
        })
            .then(result => {
                this.items = result;
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
