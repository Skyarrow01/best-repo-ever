import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import currentUserId from '@salesforce/user/Id';
import isGuestUser from '@salesforce/user/isGuest';

import createCase from '@salesforce/apex/CommunityCaseController.createCase';
import searchProducts from '@salesforce/apex/CommunityCaseController.searchProducts';


export default class ContactSupportForm extends LightningElement {
    label = 'First  LWC';
    userId = currentUserId;
    guest = isGuestUser;
    caseNumber = "";

    /* Params from Url */
    currentPageReference = null;

    userName = "";
    userPhone = "";
    userEmail = "";
  
    // Case fields to submit
    product = "";
    productGroup = "";
    subject = "";
    description = "";

    submitDisabled = false;
    hasProduct = false;
    hasProductGroup = false;
    hasValidationRun = false;
    matchingProductList = [];

     @wire(getRecord, { recordId: currentUserId, fields: ['User.Name', 'User.Email', 'User.Phone'] })
     userRecord;
 
     
     get myUserName() {
        console.log("Getting myUserName");
        if(this.userRecord.data && !this.userName ) {
            this.userName = this.userRecord.data.fields.Name.value;
        } 
        return this.userName;
    }

    get myEmail() {
        if(this.userRecord.data && !this.userEmail ) {
            this.userEmail = this.userRecord.data.fields.Email.value
        } 
        return this.userEmail;
    }
    get myPhone() {
        if(this.userRecord.data && !this.userPhone ) {
            this.userPhone = this.userRecord.data.fields.Phone.value
        } 
        return this.userPhone;
    }

    get myProduct() {
        if (this.product === null) return "";
        return this.product.trim();
    }

    set myProduct(value) {
       this.product = value.toUpperCase().trim();
    }

    get productGroupValid() {
        if (this.product || this.productGroup) return true;
        if (this.hasValidationRun) return false;
        return true;
    }

    get productValid() {
        if (this.hasProduct && this.validateItemCode(this.product)) {
            return true;
        }
        if (this.hasProduct && this.hasValidationRun) return false;
        return true;
    }

    validateItemCode(itemCode) {
        for (const p of this.matchingProductList) {
            if (p.Name === itemCode) {
                return true;
            }
        }
        return false;
    }

    get productGroups() {
        return [
            { label: "", value: "" },
            { label: 'Other / Presales', value: 'Presales' },
            { label: 'C-More', value: 'C-More' },
            { label: 'C-More Micro', value: 'C-More Micro' },
            { label: 'Click PLC Hardware', value: 'Click PLC Hardware' },
            { label: 'Click Programming', value: 'Click Programming' },
            { label: 'Connection Systems', value: 'Connection Systems' },
            { label: 'DL PLC Hardware', value: 'DL PLC Hardware' },
            { label: 'Do-More Hardware', value: 'Do-More' },
            { label: 'Do-More Programming', value: 'Do-More Software' },
            { label: 'Enclosures', value: 'Enclosures' },
            { label: 'GS1/2/3 Drives', value: 'GS1/2/3 Drives' },
            { label: 'GS20 Drives', value: 'GS20 Drives' },
            { label: 'Motors', value: 'Motors' },
            { label: 'PAC Hardware', value: 'PAC Hardware' },
            { label: 'PAC Programming', value: 'PAC Programming' },
            { label: 'Pneumatics', value: 'Pneumatics' },
            { label: 'Safety Equipment', value: 'Safety Equipment' },
            { label: 'Sensors/Switches', value: 'Sensors/Switches' },
            { label: 'Servo Motion', value: 'Servo Motion' },
            { label: 'Stepper Motion', value: 'Stepper Motion' },
            { label: 'Timers/Relays', value: 'Timers/Relays' }
        ];
    }

     @wire(CurrentPageReference)
     getStateParameters(currentPageReference) {
         console.log("Setting State values", currentPageReference.state); 
         this.currentPageReference = currentPageReference;
         if (currentPageReference) {
             this.setParametersBasedOnUrl(currentPageReference.state);
         }
     }
  
     setParametersBasedOnUrl(state) {
        this.userName = state.c__name || null;
        this.userEmail = state.c__email || null;
        this.userPhone = this.getMaskedPhone(state.c__phone) || null;
        this.myProduct = state.c__product || "";
        // So if product is preset, disable ProductGroup dropdown
        if (this.myProduct) { 
            this.hasProduct = true;
            this.getMatchingProducts(this.myProduct);
        }
     }

    showSuccessNotification(caseNumber) {
        const evt = new ShowToastEvent({
            title: "Success",
            message: "Your support case " + caseNumber + " has been created",
            variant: "success",
        });
        this.dispatchEvent(evt);
    }

    showErrorNotification(errorMsg) {
        const evt = new ShowToastEvent({
            title: "Error",
            message: errorMsg,
            variant: "error",
            mode: "sticky"
        });
        this.dispatchEvent(evt);
    }

    changeHandler(event) {
        console.log("Change Handler Fired!", event);
        // NOTE: This code assumes html template input field name attribute is == component field name
        this[event.target.name] = event.target.value;
    }

    changeProduct(event) {
        console.log("Change Produc Fired!", event);
        // For product we want to use setter to uppercase it
        this.myProduct = event.target.value;
        if (this.product) this.hasProduct = true;
        else this.hasProduct = false;
        if (this.product.length > 2) {
            this.getMatchingProducts(this.product); 
        }
    }

    changeProductGroup(event) {
        console.log("Change ProductGroup Fired!", event);
        this.productGroup = event.detail.value;
        if (this.productGroup) this.hasProductGroup = true;
        else this.hasProductGroup = false;
    }

    // Call Apex createCase method and handle the results
    handleCreateCase(event) {
        try {
        
        if (! this.isInputValid()) {
            console.log("Found INVALID input field(s)");
            return;
        }

        this.submitDisabled = true;
        this.caseNumber = "";
        let caseInfo = {name : this.userName.trim(),
            email : this.userEmail.trim(),
            phone : this.userPhone.replaceAll(/\D/g, ''),
            product : this.product,
            productGroup : this.productGroup,
            subject : this.subject.trim(),
            description : this.description.trim()
        }
        console.log("createCase payload =" + JSON.stringify(caseInfo) );

        // Call the Apex controller to create the case
        createCase(caseInfo)
            .then(caseNumber => {
                console.log("Created Case number " + caseNumber);
                this.submitDisabled = false;
                this.caseNumber = caseNumber;
                this.showSuccessNotification(caseNumber);
            })
            .catch(error => {
                console.log("Create Case error " + error);
                this.submitDisabled = false;

               // this.error = this.reduceErrors(error)[0];
                if (error.body.pageErrors && error.body.pageErrors.length) {
                    let thisError = error.body.pageErrors[0];
                    let myResults = "System Error: " + thisError.statusCode + " : " + thisError.message;
                     this.showErrorNotification(myResults);
                } else if (error.body.message) {
                    let msg = error.body.message;
                    let stackTrace = error.body.stackTrace;
                    let myResults = "System Error : " + msg + " <br> " + stackTrace; 
                    this.showErrorNotification(myResults);
                } else {
                    let myResults = "Error: " + error;
                    this.showErrorNotification(myResults);
                }
             });
        } catch (e) {
            console.log("Got an uncaught error: ", e)
            this.submitDisabled = false;
        }
    }

    getMatchingProducts(itemCode) {
        console.log("Get Matching Product");
        searchProducts({"itemCode" : itemCode} )
            .then( productlist => {
                console.log("Got products matching " + this.product + ": " + JSON.stringify(productlist));
                this.matchingProductList = productlist;
            }) 
            .catch(error => {
                console.log("Get match product error " + error);
                this.matchingProductList = [];
            });
    }

    getMaskedPhone(phone) {
        if (!phone) return null;

        const x = phone.replace(/\D+/g, '')
            .match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
        return !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
    }

    handlePhoneInputMask(event) {
        this[event.target.name] = this.getMaskedPhone(event.target.value);
    }

    // Validate all the input fields 
    isInputValid() {
        let isValid = true;
        this.hasValidationRun = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        if (! this.productGroupValid) isValid = false;
        if (! this.productValid) isValid = false;

        return isValid;
    }

    // This is just example of a life cycle method
    connectedCallback() {
        console.log("ContactSupportForm Connected!");
      //  this.setParametersBasedOnUrl(CurrentPageReference);
    }
}