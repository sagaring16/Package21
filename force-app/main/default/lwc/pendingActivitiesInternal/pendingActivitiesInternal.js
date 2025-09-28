import homeBannerData from '@salesforce/apex/HomeTopBannerCtrl.getCardDetails';
import fetchChartId from '@salesforce/apex/HomeTopBannerCtrl.fetchChartId';
import { LightningElement, track, api } from 'lwc';
import phasesLevel from '@salesforce/resourceUrl/phasesLevel';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class PendingActivitiesInternal extends LightningElement {
    @api uniqueName;
    @api title;
    @track carddata = [];

    renderedCallback() {
        loadStyle(this, phasesLevel);
    }

    connectedCallback() {
        this.fetchBannerData();
    }

    fetchBannerData() {
        homeBannerData({ uniqueName: this.uniqueName })
            .then(result => {
                this.carddata = result.map(element => {
                    const parsedJson = JSON.parse(element.json);
                    const amount = element.count;
                    return {
                        title: element.title,
                        count: amount > 1000 ? this.formatNumber(amount) : amount,
                        json: {
                            ...parsedJson,
                            url: `${element.baseUrl}${parsedJson.url}`,
                            icon: parsedJson.icon,
                        },
                        report: parsedJson.report
                    };
                });
            })
            .catch(error => {
                console.error('Error fetching banner data: ', error);
            });
    }

    formatNumber(num, precision = 2) {
        const suffixMap = [
            { suffix: 'T', threshold: 1e12 },
            { suffix: 'B', threshold: 1e9 },
            { suffix: 'M', threshold: 1e6 },
            { suffix: 'K', threshold: 1e3 },
        ];

        const found = suffixMap.find(x => Math.abs(num) >= x.threshold);
        return found ? (num / found.threshold).toFixed(precision) + found.suffix : num;
    }

    fetchChart(event) {
        const baseUrl = event.currentTarget.dataset.id;
        const chartName = event.currentTarget.dataset.key;

        if (!chartName) {
            window.location.href = baseUrl;
        } else {
            fetchChartId({ reportName: chartName })
                .then(result => {
                    window.location.href = `${baseUrl}${result}/view`;
                })
                .catch(error => {
                    console.error('Error fetching chart ID: ', error);
                });
        }
    }
}