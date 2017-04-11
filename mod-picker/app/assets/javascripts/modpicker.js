//= require_self
//= require ./polyfills.js
//= require ./es6-polyfills.js
//= require_tree ./BackendAPI
//= require_tree ./Directives
//= require_tree ./Factories
//= require_tree ./Filters
//= require_tree ./Services
//= require_tree ./Views
//= stub_tree Directives/legal
//= stub_tree Directives/help
/*
 Mod Picker v1.4
 (c) 2017 Mod Picker, LLC. https://www.modpicker.com
*/

// fix urls in the old hash format
if (["/skyrim", "/skyrimse"].indexOf(window.location.pathname) > -1) {
    window.location.pathname += "/";
}

var app = angular.module('modPicker', [
    'ui.router', 'rzModule', 'ngAnimate', 'puElasticInput', 'hc.marked', 'smoothScroll', 'relativeDate', 'ct.ui.router.extras', 'dndLists', 'pasvaz.bindonce'
]);

app.config(['$httpProvider', '$compileProvider', '$locationProvider', function($httpProvider, $compileProvider, $locationProvider) {
    $httpProvider.useApplyAsync(true);
    $compileProvider.debugInfoEnabled(false);
    $locationProvider.html5Mode(true);
}]);

app.config(['$urlMatcherFactoryProvider', '$urlRouterProvider', function($urlMatcherFactoryProvider, $urlRouterProvider) {
    //this allows urls with and without trailing slashes to go to the same state
    $urlMatcherFactoryProvider.strictMode(false);
    //this will not display url parameters that are set to their defaults
    $urlMatcherFactoryProvider.defaultSquashPolicy(true);

    // redirect to /home if someone types in an incorrect url
    $urlRouterProvider.otherwise('/home');
}]);

// sanitize html in markdown
app.config(['markedProvider', function(markedProvider) {
    markedProvider.setOptions({ sanitize: true });
}]);

// allow states to be defined at runtime
app.config(['$futureStateProvider', function($futureStateProvider) {
    var lazyStateFactory = function($q, futureState) {
        return $q.when(futureState);
    };
    lazyStateFactory.$inject = ["$q", "futureState"];
    $futureStateProvider.stateFactory('lazy', lazyStateFactory);
}]);

app.run(['$rootScope', '$state', 'smoothScroll', function($rootScope, $state, smoothScroll) {
    var lastToState;

    $rootScope.$on('$stateChangeStart', function(evt, toState, params, fromState) {
        //this adds a redirectTo option into ui router, which makes default tabs much nicer
        if (toState.redirectTo) {
            evt.preventDefault();
            $state.go(toState.redirectTo, params, { location: 'replace' });
        }
        //don't scroll if the transition is from one sticky state to another
        if (!toState.sticky || !fromState.sticky) {
            // scroll to the top of the page
            if (toState != lastToState) {
                lastToState = toState;
                smoothScroll(document.body, {duration: 300});
            }
        }
    });

    // handle state change errors
    $rootScope.$on("$stateChangeError", function(event, toState, toParams, fromState, fromParams, error) {
        $state.get('base.error').error = error;
        $state.go('base.error');
    });
}]);
