import { LightningElement, api, track, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import fetchPhaseItems from '@salesforce/apex/PhaseViewController.fetchPhaseConfig';
import phasesLevel from '@salesforce/resourceUrl/GovSBIRStaticResources';
import {
    loadStyle
} from 'lightning/platformResourceLoader';
import messageChannel2 from '@salesforce/messageChannel/GNT__sidebarToPhaseMessageChannel__c';
import { publish, subscribe, MessageContext, APPLICATION_SCOPE, unsubscribe } from 'lightning/messageService';
import currentPhaseNameChannel from '@salesforce/messageChannel/GNT__CurrentPhaseName__c';


export default class PhaseView extends NavigationMixin(LightningElement) {

    @api recordId;
    @track currentPhaseVal;
    payload = '';
    message;
    subscription = null;
    indication = 'UNSUBSCRIBED';
    @track showTable = false;
    stringParam = {};
    @wire(MessageContext)
    messageContext;
    currentPageReference;
    phaseNameTitle;
    listparam;
    titleAppName;
    appName;

    constructor() {
        super();
    }



    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        let pageRefURL = currentPageReference.state.c__attributes != null && currentPageReference.state.c__attributes != undefined ? JSON.parse(currentPageReference.state.c__attributes).URL : undefined;
        if (pageRefURL == undefined && pageRefURL == null && currentPageReference && currentPageReference.state.c__attributes) {
            this.currentPageReference = JSON.parse(currentPageReference.state.c__attributes);
            let tableNameType = {};
            tableNameType[atob(this.currentPageReference.tableName)] = atob(this.currentPageReference.tableType);
            this.StringtableNameType = tableNameType;
            setTimeout(() => {
                this.showTable = true;
            }, 300);

            this.stringParam = atob(this.currentPageReference.strParameter) == 'undefined' ? {} : atob(this.currentPageReference.strParameter);
            console.log('stringParam ' + this.stringParam);
        } else if (pageRefURL != null) {
            let urlPram = pageRefURL;
            this.processURL(urlPram);
        }
    }

    subscribeMsg() {
        this.subscription = subscribe(this.messageContext, messageChannel2, (message) => {
            if (message.data.flextable && message.data.Type) {
                this.showTable = false;
                let tableNameType = {};
                tableNameType[message.data.flextable] = message.data.Type;
                this.StringtableNameType = tableNameType;
                let phaseName = window.location.href.toString().split("/").pop().split("?")[0];
                if (phaseName == '') {
                    phaseName= 'RecipientHome';
                } else if(phaseName == 'Customer_Support'){
                    phaseName = 'Home';
                } else {
                    phaseName = phaseName;
                }
                let sessionKey = `tableState_${phaseName}`;
                sessionStorage.setItem(sessionKey, JSON.stringify(message.data));
                sessionStorage.setItem('lastPhaseKey', phaseName);
                setTimeout(() => {
                    this.showTable = true;
                }, 300);
            } else if (message.data.URL != null) {
                let urlPram = message.data.URL;
                let phaseName = window.location.href.toString().split("/").pop().split("?")[0];
                let sessionKey = `tableState_${phaseName}`;
                sessionStorage.setItem(sessionKey,JSON.stringify(message.data));
                sessionStorage.setItem('lastPhaseKey', phaseName);
                this.processURL(urlPram);
            }
        }, {
            scope: APPLICATION_SCOPE
        });
    }

    unsubscribeMsg() {
        unsubscribe(this.subscription);
        this.subscription = null;
        this.indication = 'UNSUBSCRIBED';
        this.payload = '';
    }


    connectedCallback() {
        this.subscribeMsg();
        localStorage.setItem('UnmanagedValue', 'Passed Unmanaged Value');
        console.log('phaseView ');
        loadStyle(this, phasesLevel+ '/StaticResources/CSS/phasesLevel.css').then(() => { });
        if (this.tabName == null || this.tabName == '') {
            var currentUrl = window.location.href;
            var phaseVal = currentUrl.toString().split("/").pop().split("?")[0];

            if (phaseVal == '') {
                this.currentPhaseVal = 'RecipientHome';
            } else if (phaseVal == 'Customer_Support') { //avoid hardcoded string so need to handle it properly, Changes made for bug:465534
                this.currentPhaseVal = 'GranteeHome';
            } else {
                this.currentPhaseVal = phaseVal;
            }

            // this.publishCurrentPhaseMsg();

            fetchPhaseItems({
                currentPhase: this.currentPhaseVal
            })
                .then(result => {
                    let lastPhaseKey = sessionStorage.getItem('lastPhaseKey');
                    if(lastPhaseKey!== null && lastPhaseKey !== this.currentPhaseVal){
                        sessionStorage.removeItem('lastPhaseKey');
                        const oldSessionKey = `tableState_${lastPhaseKey}`;
                        sessionStorage.removeItem(oldSessionKey);
                    }
                    const sessionKey = `tableState_${this.currentPhaseVal}`;
                    const storedData = sessionStorage.getItem(sessionKey);
                    var phaseConfigData = JSON.parse(result);
                    if (phaseConfigData?.accountOrORgId?.userIsSME) {
                        this.currentPhaseVal = 'SMEHome';
                    }
                    else {
							if (storedData) {
								const messageData = JSON.parse(storedData);
								if (messageData.flextable && messageData.Type) {
									this.showTable = false;
									let tableNameType = {};
									tableNameType[messageData.flextable] = messageData.Type;
									this.StringtableNameType = tableNameType;
									setTimeout(() => {
										this.showTable = true;
										sessionStorage.removeItem(sessionKey);
										sessionStorage.removeItem('lastPhaseKey');
									}, 300);
								}else{
									this.processURL(messageData.URL);
									setTimeout(() => {
									sessionStorage.removeItem(sessionKey);
									sessionStorage.removeItem('lastPhaseKey');
									}, 300);
								}
							}
                            else if (phaseConfigData?.phaseFlexTable[0]?.GNT__BodyTable__c) {
                                setTimeout(() => {
                                    this.showTable = true;
                                }, 100);
                                let tableNameType = {};
                                tableNameType[phaseConfigData.phaseFlexTable[0].GNT__BodyTable__r.Name] = 'FlexTable';
                                this.StringtableNameType = tableNameType;
                                console.log('tableNameType ' + tableNameType);
						    }
                    }
                    this.stringParam['accountId'] = phaseConfigData?.accountOrORgId?.userOrgId;
                    this.stringParam['userOrgId'] = phaseConfigData?.accountOrORgId?.userOrgId;
                    this.stringParam['OrgId'] = phaseConfigData?.accountOrORgId?.userOrgId;
                    this.stringParam['orgId'] = phaseConfigData?.accountOrORgId?.orgId;//Added by Gauri for the Qualified lead

                    /*if (phaseConfigData?.recordIdSet?.rcdsIdSet != null) {
                        this.listparam = {
                            recordsIdSet: phaseConfigData.recordIdSet.rcdsIdSet
                        };
                    }*/
                    if (phaseConfigData?.recordIdSet?.qualifiedAnnouncements != null) {
                        this.listparam = {
                            recordsIdSet: phaseConfigData.recordIdSet.qualifiedAnnouncements
                        };
                    }
                    if (phaseConfigData?.recordIdSet?.qualifiedLeads != null) {
                        this.listparam = {
                            recordsIdSet: phaseConfigData.recordIdSet.qualifiedLeads
                        };
                    }
                    this.titleAppName = phaseConfigData?.appNameLabel;
                    this.appName = phaseConfigData?.appNameDeveloperName;
                    this.phaseNameTitle = phaseConfigData?.phaseFlexTable[0]?.GNT__TabName__c;
                    document.title = this.phaseNameTitle + ' ~ ' + this.titleAppName;
                    this.publishCurrentPhaseMsg();

                })
                .catch(error => {
                    this.error = error;
                    console.log('error>>' + (JSON.stringify(this.error)));
                });


        }

    }
    async publishCurrentPhaseMsg() {
        await Promise.resolve(); // Wait one lifecycle.
        let message = { message: this.currentPhaseVal };
        console.log('this.currentPhaseVal ' + this.currentPhaseVal);
        publish(this.messageContext, currentPhaseNameChannel, message);
    }
    get objectEntries() {
        return Object.entries(this.StringtableNameType).map(([key, value]) => ({
            key,
            value
        }));
    }

    processURL(urlParam) {
        let tableNameTypeMap = {};
        const regex = /(ft\d*|fg\d*|phaseName)=(\w+)/g;
        let match;
        let key;
        let value;
        this.isURL = true;
        while ((match = regex.exec(urlParam)) !== null) {
            key = match[1];
            value = atob(match[2]);
            if (key.startsWith('ft')) {
                tableNameTypeMap[value] = 'FlexTable';
            } else if (key.startsWith('fg')) {
                tableNameTypeMap[value] = 'FlexGrid';
            }
            if (key.startsWith('phase')) {
                this.phaseName = value;
            }
        }
        this.StringtableNameType = tableNameTypeMap;
        this.showTable = false;
        setTimeout(() => {
            this.showTable = true;
        }, 600);

        this.stringParam['phaseName'] = this.phaseName;
        this.stringParam['appNameLabel'] = this.appName;

        setTimeout(() => {
            this.showTable = true;
        }, 600);

        console.log('this.stringParam' + this.stringParam);

    }

    renderedCallback() {

        if (this.titleAppName != undefined && this.phaseNameTitle != undefined) {
            document.title = this.phaseNameTitle + ' ~ ' + this.titleAppName;
        }

    }

}