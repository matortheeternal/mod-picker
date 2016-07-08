//= require_self
//= require ./polyfills.js
//= require_tree ./angularAssets

var app = angular.module('modPicker', [
    'ui.router', 'rzModule', 'ngAnimate', 'sticky', 'puElasticInput', 'hc.marked', 'smoothScroll', 'relativeDate', 'ct.ui.router.extras'
]);

app.config(['$httpProvider', '$compileProvider', function($httpProvider, $compileProvider) {
    $httpProvider.useApplyAsync(true);
    $compileProvider.debugInfoEnabled(false);
}]);

app.config(function($urlMatcherFactoryProvider) {
    //this allows urls with and without trailing slashes to go to the same state
    $urlMatcherFactoryProvider.strictMode(false);
    //this will not display url parameters that are set to their defaults
    $urlMatcherFactoryProvider.defaultSquashPolicy(true);
});

app.config(function($urlRouterProvider) {
    $urlRouterProvider.otherwise('/home');
});

//this adds a redirectTo option into ui router, which makes default tabs much nicer
app.run(['$rootScope', '$state', function($rootScope, $state) {

    $rootScope.$on('$stateChangeStart', function(evt, to, params) {
        if (to.redirectTo) {
            evt.preventDefault();
            $state.go(to.redirectTo, params, { location: 'replace' });
        }
    });
}]);
