import { LightningElement, api } from 'lwc';

export default class ItemDetailsModal extends LightningElement {
    @api item;
    @api visible = false;

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}
