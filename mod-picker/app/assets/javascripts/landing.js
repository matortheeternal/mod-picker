//= require_self
//= require ./polyfills.js
//= require Directives/shared/sticky.js
//= require Services/ObjectUtils.js

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
            available: false,
            display_name: "Skyrim SE",
            name: "skyrimse",
            explanation: "Coming Soon"
        },
        {
            available: false,
            display_name: "Fallout 4",
            name: "fallout4",
            explanation: "Coming Soon"
        }
    ];
});