({
 handleBeforeUnload: function(component, event) {
 event.preventDefault();
 event.returnValue = 'You have unsaved changes. Are you sure you want to leave?'; //Standard message

 }
})