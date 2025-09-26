import { LightningElement, api,wire } from "lwc";
import getContext from '@salesforce/apex/recordEditCtrl.getContext';
import messageChannel from '@salesforce/messageChannel/GNT__flexLayoutMessageChannel__c';
import { publish, MessageContext } from "lightning/messageService";
import userId from "@salesforce/user/Id";


export default class RecordEdit extends LightningElement {

    @api recordId;
    @wire(MessageContext)
    messageContext;
    connectedCallback() {
        getContext({
            recordId: this.recordId
        })
        .then(result => {
            if (result != null && result != undefined) {
                const payload = {
                source: "RecordEditLwc",
                data: {
                    recordId: this.recordId,
                    userId: userId
                }
                };
                publish(this.messageContext, messageChannel, payload);
                window.open(result, "_self");
            }
        })
        .catch(error => {
        this.error = error;
        });
    }
}