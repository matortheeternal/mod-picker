//= skip
//= require_self
//= require ./polyfills.js
//= require_tree ./angularAssets

var app = angular.module('modPicker', [
    'ui.router', 'rzModule', 'ngAnimate', 'sticky', 'puElasticInput', 'hc.marked', 'smoothScroll'
]);

app.config(['$httpProvider', '$compileProvider', function ($httpProvider, $compileProvider) {
    $httpProvider.useApplyAsync(true);
    $compileProvider.debugInfoEnabled(false);
}]);

app.config(function ($urlRouterProvider) {
    $urlRouterProvider.otherwise('/');
});
