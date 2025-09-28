({
	toggleSection : function(component, event, helper) {
	
		let buttonstate = !component.get('v.buttonstate');
		// We have option of localStorage vs sessionStorage
        //localStorage.setItem(window.location.pathname,buttonstate);
		var userId = $A.get("$SObjectType.CurrentUser.Id");
		sessionStorage.setItem(userId,buttonstate);
        component.set('v.buttonstate', buttonstate);
		console.log('kk buttonstate ',component.get('v.buttonstate'));
		component.set('v.isSidebarCollapsed', !component.get('v.isSidebarCollapsed'));
		
	},
	init : function(component, event, helper) {
		//sessionStorage.clear();
		//localStorage.clear();
		// if(localStorage.getItem(window.location.pathname))
        //     component.set('v.buttonstate', localStorage.getItem(window.location.pathname)==='true');
		var userId = $A.get("$SObjectType.CurrentUser.Id");
			if(sessionStorage.getItem(userId))
            component.set('v.buttonstate', sessionStorage.getItem(userId)==='true');
			component.set('v.isSidebarCollapsed', !component.get('v.buttonstate'));

			// let identifier = window.location.pathname.split('/');
			//var userId = $A.get("$SObjectType.CurrentUser.Id");
		
    }

	
})