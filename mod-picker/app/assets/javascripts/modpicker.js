//= require_self
//= require ./polyfills.js
//= require_tree ./BackendAPI
//= require_tree ./Directives
//= require_tree ./Factories
//= require_tree ./Filters
//= require_tree ./Services
//= require_tree ./Views
//= stub_tree Directives/help

var app = angular.module('modPicker', [
    'ui.router', 'rzModule', 'ngAnimate', 'puElasticInput', 'hc.marked', 'smoothScroll', 'relativeDate', 'ct.ui.router.extras', 'dndLists', 'pasvaz.bindonce'
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

//redirect to /home if someone types in an incorrect url
app.config(function($urlRouterProvider) {
    $urlRouterProvider.otherwise('/home');
});

//this allows states to be defined at runtime by 
app.config(function($futureStateProvider) {
    var lazyStateFactory = function($q, futureState) {
        return $q.when(futureState);
    };
    lazyStateFactory.$inject = ["$q", "futureState"];
    $futureStateProvider.stateFactory('lazy', lazyStateFactory);
});

app.run(['$rootScope', '$state', 'smoothScroll', function($rootScope, $state, smoothScroll) {
    $rootScope.$on('$stateChangeStart', function(evt, toState, params, fromState) {
        //this adds a redirectTo option into ui router, which makes default tabs much nicer
        if (toState.redirectTo) {
            evt.preventDefault();
            $state.go(toState.redirectTo, params, { location: 'replace' });
        }
        //don't scroll if the transition is from one sticky state to another
        if (!toState.sticky || !fromState.sticky) {
            // scroll to the top of the page
            smoothScroll(document.body, {duration: 300});
        }
        // set page title to loading
        $rootScope.$emit('setPageTitle', 'Loading...');
    });

    // handle state change errors
    $rootScope.$on("$stateChangeError", function(event, toState, toParams, fromState, fromParams, error) {
        $state.get('base.error').error = error;
        $state.go('base.error');
    });
}]);
