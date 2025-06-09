import {api, LightningElement, track} from 'lwc';
import createItem from '@salesforce/apex/ItemController.createItem';
import getTypeOptions from '@salesforce/apex/FilterService.getTypeOptions';
import getFamilyOptions from '@salesforce/apex/FilterService.getFamilyOptions';
import searchPhotoUrl from '@salesforce/apex/UnsplashService.searchPhotoUrl';

export default class CreateItemForm extends LightningElement {
    @api visible = false;

    @track item = {
        name: '',
        description: '',
        price: 0,
        type: '',
        family: '',
        image: ''
    };

    @track error;
    @track success = false;

    typeOptions = [];
    familyOptions = [];

    debounceTimer; // cooldown for searchPhotoUrl

    connectedCallback() {
        getTypeOptions().then(data => {
            this.typeOptions = data.map(val => ({label: val, value: val}));
        });
        getFamilyOptions().then(data => {
            this.familyOptions = data.map(val => ({label: val, value: val}));
        });
    }

    handleNameChange(event) {
        this.item.name = event.target.value;

        if (this.debounceTimer) {
            clearTimeout(this.debounceTimer);
        }

        // no input for 1 second? parse
        this.debounceTimer = setTimeout(() => {
            if (this.item.name && this.item.name.length > 2) {
                searchPhotoUrl({query: this.item.name})
                    .then(url => {
                        if (url) {
                            this.item.image = url;
                        }
                    })
                    .catch(error => {
                        console.log(error);
                    })
            }
        }, 1000)
    }

    handleDescriptionChange(event) {
        this.item.description = event.target.value;
    }

    handlePriceChange(event) {
        this.item.price = event.target.value;
    }

    handleTypeChange(event) {
        this.item.type = event.target.value;
    }

    handleFamilyChange(event) {
        this.item.family = event.target.value;
    }

    handleImageChange(event) {
        this.item.image = event.target.value;
    }

    handleCreate() {
        this.error = undefined;
        this.success = false;

        createItem({
            name: this.item.name,
            description: this.item.description,
            price: parseFloat(this.item.price) || 0,
            type: this.item.type,
            family: this.item.family,
            image: this.item.image
        })
            .then(() => {
                this.success = true;
            })
            .catch(err => {
                console.error('Create item error:', err);
                this.error = err?.body?.message || err.message || 'Unknown error';
            });
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}
