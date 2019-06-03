declare module "@salesforce/apex/LookupComponentController.getSObjectNames" {
  export default function getSObjectNames(param: {sObjectAPINames: any}): Promise<any>;
}
declare module "@salesforce/apex/LookupComponentController.getRecentRecords" {
  export default function getRecentRecords(param: {objectName: any, returnFields: any}): Promise<any>;
}
declare module "@salesforce/apex/LookupComponentController.getSearchedRecords" {
  export default function getSearchedRecords(param: {objectName: any, searchScope: any, returnFields: any, searchString: any}): Promise<any>;
}
