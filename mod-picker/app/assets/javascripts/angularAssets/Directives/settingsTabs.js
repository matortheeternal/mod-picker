/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('settingsTabs', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/settingsTabs.html',
        controller: 'settingsTabsController',
        scope: {
        	current: '@'
        }
    }
});

app.controller('settingsTabsController', function ($scope) {
	$scope.tabs = [
		{
			name: "Profile",
			call: "profile",
		},
		{
			name: "Account",
			call: "account",
		},
		{
			name: "Reputation",
			call: "reputation",
		},
		{
			name: "Mod Lists",
			call: "modLists",
		},
		{
			name: "Authored Mods",
			call: "authoredMods",
		},
		{
			name: "Installation",
			call: "installation",
		},
	];
});
