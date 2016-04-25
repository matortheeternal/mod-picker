//= require_self
//= require ./polyfills.js
//= require_tree ./angularAssets

var app = angular.module('modPicker', [
    'ngRoute', 'rzModule', 'ngAnimate', 'sticky', 'puElasticInput'
]);

app.config(['$httpProvider', '$compileProvider', function ($httpProvider, $compileProvider) {
    $httpProvider.useApplyAsync(true);
    $compileProvider.debugInfoEnabled(false);
}]);
