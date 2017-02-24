//= require angular.min.1.5.1.js
//= require angular-animate.min.js
//= require_self
//= require ./polyfills.js
//= require Directives/shared/sticky.js
//= require Services/ObjectUtils.js
/*
 Mod Picker Landing Page v1.4
 (c) 2017 Mod Picker, LLC. https://www.modpicker.com
*/

var app = angular.module('landing', [
    'ngAnimate'
]);

app.config(['$compileProvider', function($compileProvider) {
    $compileProvider.debugInfoEnabled(false);
}]);

app.controller('landingController', function($scope) {
    $scope.games = [
        {
            available: true,
            display_name: "Skyrim",
            name: "skyrim",
            explanation: "The Elder Scrolls V: Skyrim"
        },
        {
            available: true,
            display_name: "Skyrim SE",
            name: "skyrimse",
            explanation: "Skyrim: Special Edition"
        },
        {
            available: false,
            display_name: "Fallout 4",
            name: "fallout4",
            explanation: "Coming Soon"
        }
    ];
});