//= require_self
//= require_tree ./angularAssets

var app = angular.module('modPicker', [
    'ngRoute', 'rzModule'
]);

app.config(['$httpProvider', '$compileProvider', function ($httpProvider, $compileProvider) {
    $httpProvider.useApplyAsync(true);
    $compileProvider.debugInfoEnabled(false);
}]);