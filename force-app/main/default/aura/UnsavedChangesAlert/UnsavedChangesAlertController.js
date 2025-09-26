({
 doInit: function (component, event, helper) {
 window.addEventListener("beforeunload", function (e) {
 const hasChanges =
 component.get("v.isEditModeForLayout") ||
 component.get("v.isEditModeForGrid");
 if (hasChanges) {
 const confirmationMessage = "Changes you made may not be saved.";
 e.returnValue = confirmationMessage;
 return confirmationMessage;
 }
 });

 },
 onInit: function(component, event, helper) {
 window.addEventListener("beforeunload", helper.handleBeforeUnload.bind(this,
component));
 },

 onDestroy: function(component, event, helper) {
 window.removeEventListener("beforeunload", helper.handleBeforeUnload.bind(this,
component));
 },
 handleMessage: function(cmp, event, helper) {
 var data = event.getParam("data");
 var lmsSource = event.getParam("source");
 if(lmsSource=='fromLayoutAction'){
 var unsavedChangesCmp = cmp.find("unsaved");
 var layoutId = data.pageLayoutId;
 var layoutStates = cmp.get("v.layoutStates") || {};
 var unsavedIds = cmp.get("v.unsavedLayoutIds") || [];
 const addUnsaved = () => {
 if (!unsavedIds.includes(layoutId)) {
 unsavedIds.push(layoutId);
 }
 };
 const removeUnsaved = () => {
 unsavedIds = unsavedIds.filter(id => id !== layoutId);
 delete layoutStates[layoutId]; // remove layout state object
 };
 if (data.message === "unsaved") {
 cmp.set("v.isEditModeForLayout", true);
 cmp.set("v.pageLayoutId", data.pageLayoutId);
 addUnsaved();
 unsavedChangesCmp.setUnsavedChanges(true, {
 label: "",
 description: "Please save before leaving.",
 severity: "warning"
 });
 }else if(data.message === "saveError"){
 var unsavedChangesCmp = cmp.find("unsaved");
 }else if(data.message === "saveNoError"){
 cmp.set("v.isEditModeForLayout", false);
 let isLayoutEditing = cmp.get("v.isEditModeForLayout");
 let isGridEditing = cmp.get("v.isEditModeForGrid");
 const isApprovalEditMode = cmp.get("v.isEditModeForApproval");
 cmp.set("v.isEditModeForGrid",false);
 cmp.set("v.isEditModeForLayout",false);
 var unsavedChangesCmp = cmp.find("unsaved");
 removeUnsaved();
 if(!isApprovalEditMode && unsavedIds.length === 0){
 unsavedChangesCmp.setUnsavedChanges(false);
 }

 }else if(data.message ==="gridSaveEnable"){
 cmp.set("v.isEditModeForGrid", true);
 const payload = {
 data: {
 source:'from Aura Component',
 isSave : true,
 pageLayoutId :cmp.get("v.pageLayoutId"),
 isModal : data.isModal
 }
 };
 cmp.find("flexLayoutMessageChannel").publish(payload);
 unsavedChangesCmp.setUnsavedChanges(true, {
 label: "",
 description: "Please save before leaving.",
 severity: "warning"
 });
 if (data.isModal === true) {
 let modalEditingMap = cmp.get("v.modalEditingMap") || {};
 modalEditingMap[data.tableId] = true;
 cmp.set("v.modalEditingMap", modalEditingMap);
 } else{
 var editingMap = cmp.get("v.editingMap");
 if (typeof editingMap !== 'object' || editingMap === null) {
 editingMap = {};
 }
 editingMap[data.tableId] = true;
 cmp.set("v.editingMap", editingMap);
 }
 }else if(data.message === "gridSaveDisable"){
 cmp.set("v.isEditModeForGrid", false);
 const payload = {
 data: {
 source:'from Aura Component',
 isSave : false,
 pageLayoutId :cmp.get("v.pageLayoutId"),
 isModal : data.isModal
 }
 };
console.log("payload ", payload);
 cmp.find("flexLayoutMessageChannel").publish(payload);
 let isLayoutEditing = cmp.get("v.isEditModeForLayout");
 let isGridEditing = cmp.get("v.isEditModeForGrid");
 const isApprovalEditMode = cmp.get("v.isEditModeForApproval");
 if (data.isModal === true) {
 let modalEditingMap = cmp.get("v.modalEditingMap") || {};
 if (data.isUndoEditAll) {
 Object.keys(modalEditingMap).forEach(key => {
 if (key.startsWith(data.tableId)) {
 modalEditingMap[key] = false;
 }
 });
 } else {
 modalEditingMap[data.tableId] = false;
 }
 cmp.set("v.modalEditingMap", modalEditingMap);
 const anyUnsaved = Object.values(modalEditingMap).some(val => val === true);
 if (!isLayoutEditing && !isGridEditing && !isApprovalEditMode && !anyUnsaved)
{
 cmp.find("unsaved").setUnsavedChanges(false);
 }
 }
 else{
 var editingMap = cmp.get("v.editingMap") || {};
 if(data.isUndoEditAll && data.isUndoEditAll=== true){
 Object.keys(editingMap).forEach(key => {
 if (key.startsWith(data.tableId)) {
 editingMap[key] = false;
 }
 });
 } else{
 editingMap[data.tableId] = false; // or false
 }
cmp.set("v.editingMap", editingMap);
 const anyUnsaved = Object.values(editingMap).some(val => val === true);
 if(isLayoutEditing === false && isGridEditing === false && anyUnsaved === false
&& !isApprovalEditMode ){
 var unsavedChangesCmp = cmp.find("unsaved");
 unsavedChangesCmp.setUnsavedChanges(false);
 }
 }
 }else if(data.message ==="modalEditEnble"){
 unsavedChangesCmp.setUnsavedChanges(true, {
 label: "You have unsaved changes! ",
 description: "Please save before leaving.",
 severity: "warning"
 });
 }else if(data.message === "ApprovalDecision"){
 cmp.set("v.isEditModeForApproval",true);
 unsavedChangesCmp.setUnsavedChanges(true, {
 label: "You have unsaved changes! ",
 description: "Please save before leaving.",
 severity: "warning"
 });

 }else if(data.message === "ApprovalDecisionDisable"){
 cmp.set("v.isEditModeForApproval",false);
 unsavedChangesCmp.setUnsavedChanges(false);
 }
else if (data.message === "formodal") {
 cmp.set("v.isEditModeForModal", data.value);

 if (data.value) {
 unsavedChangesCmp.setUnsavedChanges(true, {
 label: "You have unsaved changes!",
 description: "Please save before leaving.",
 severity: "warning"
 });
 } else {
 var meditingMap = {};
 cmp.set("v.modalEditingMap", meditingMap);
 const isLayoutEditMode = cmp.get("v.isEditModeForLayout");
 const isApprovalEditMode = cmp.get("v.isEditModeForApproval");
 if (!isLayoutEditMode && !isApprovalEditMode ) {
 cmp.set("v.isEditModeForModal", false);
 unsavedChangesCmp.setUnsavedChanges(false);
 }
 }
 }else if(data.message === "fromGridCmpForModal"){
 cmp.set("v.isEditModeForModal", data.value);
 if (data.value) {
 unsavedChangesCmp.setUnsavedChanges(true, {
 label: "You have unsaved changes!",
 description: "Please save before leaving.",
 severity: "warning"
 });
 } else {

 const isLayoutEditMode = cmp.get("v.isEditModeForLayout");
 const isApprovalEditMode = cmp.get("v.isEditModeForApproval");
 if (!isLayoutEditMode && !isApprovalEditMode ) {
 cmp.set("v.isEditModeForModal", false);
 unsavedChangesCmp.setUnsavedChanges(false);
 }
 }
 }else if(data.message === "checkUnsaveState"){
var meditingMap = {};
cmp.set("v.modalEditingMap", meditingMap);
unsavedChangesCmp.setUnsavedChanges(false);
}
 cmp.set("v.unsavedLayoutIds", unsavedIds);
 cmp.set("v.layoutStates", layoutStates);
 }
 },
 handleSave: function(cmp, event, helper) {
 let actionConfig ={};
 actionConfig['actionType'] = 'Save';
 actionConfig['pageLayoutId'] = cmp.get("v.pageLayoutId");
 var payload = {
 source: "from Aura Component",
 data:actionConfig
 };
 cmp.find("flexLayoutMessageChannel").publish(payload);

 },
 handleDiscard: function(cmp, event, helper) {

 const payload1 = {
 data: {
 source:'from Aura Component',
 isCancel : true,
 pageLayoutId :cmp.get("v.pageLayoutId")
 }
 }
 cmp.find("flexLayoutMessageChannel").publish(payload1);
 var unsavedChangesCmp = cmp.find("unsaved");
 unsavedChangesCmp.setUnsavedChanges(false);
 cmp.set("v.isEditModeForGrid",false);
 cmp.set("v.isEditModeForLayout",false);
 }
})