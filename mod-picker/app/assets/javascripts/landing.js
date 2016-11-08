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
