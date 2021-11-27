import { LightningElement, wire } from 'lwc';
import getAccountRecords from "@salesforce/apex/ContactHelper.getAllAccounts";
import { ShowToastEvent } from "lightning/platformShowToastEvent"
import { createRecord } from 'lightning/uiRecordApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import getAccessibleFields from "@salesforce/apex/ContactHelper.getContactAccessibleFields";

export default class ContactComponent extends LightningElement {
    accounts = [];
    accountId;
    selectedContactFields = [];
    contactFieldsOptions = [];
    currentFieldName;
    listOfRecords = [];
    counter = 0;

    accountIdForSave;

    get index() {
        return this.counter++;
    }

    get requiredOptions() {
        return ["LastName"];
    }

    @wire(getAccessibleFields)
    objectInfo({ error, data }) {
        if (data) {//ПРОВЕРИТЬ ПРАВА НА СОЗДАНИЕ КОНТАКТОВ
            this.contactFieldsOptions = JSON.parse(data).map(field => {
                return { value : field, 
                         label : field };
                });
        } else if (error) {
            console.log(error);
        }
    }
//display: inline-block
    connectedCallback() {
        getAccountRecords().then(result => {
            if (result) {
                this.accounts = JSON.parse(result).map(acc => {
                    return { value : acc.Id, 
                             label : acc.Name };
                });
            }
        }).catch(error => {
            console.log(error);
        });
    }


    handleFieldsSelect(event) {
        this.selectedContactFields = event.detail.value
    }

    handleAccountPick(event) {
        this.accountId = event.detail.value;
        this.accountIdForSave = event.detail.value;
    }

    get cardTitle() {
        const accName = this.accounts.find(x => {
            if (x.value === this.accountId) {
                return x.label;
            }
        });
        return "Create Contact for " + accName.label;
    }

    handleSubmit(event) {
        event.preventDefault();
        //сохраняем
        let fields = event.detail.fields;
        fields['AccountId'] = this.accountId;
        this.listOfRecords.push(fields);

        console.log('listOfRecords ' + JSON.stringify(this.listOfRecords));
        //reset
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        this.accountIdForSave = this.accountId;
        console.log('accountIdForSave ' + this.accountIdForSave + ' ,accountId' + this.accountId);
    }

    createContact(event) {
        this.listOfRecords.forEach(field => {
            const recordInput = { apiName: CONTACT_OBJECT.objectApiName, fields : field};
            createRecord(recordInput).then(contact => {
                console.log('response: ' + contact.id);
            })
            .catch(error => {
                console.log("Error: " + JSON.stringify(error));
            });
        })
    }
    
}