//= require_self
//= require_tree ./angularAssets

var app = angular.module('modPicker', [
    'ngRoute', 'rzModule', 'ngAnimate'
]);

app.config(['$httpProvider', '$compileProvider', function ($httpProvider, $compileProvider) {
    $httpProvider.useApplyAsync(true);
    $compileProvider.debugInfoEnabled(false);
}]);

function useTwoColumns(b) {
    if (b) {
        document.body.className = "two-columns";
    } else {
        document.body.className = "";
    }
}
