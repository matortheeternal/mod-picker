//huge thanks at the random stackoverflow bro: http://stackoverflow.com/a/22144570

// see this file as a polyfill for a function that angular does not provide (boooooh!)

app.directive('ngIndeterminate', function($compile) {
    return {
        restrict: 'A',
        link: function(scope, element, attributes) {
            scope.$watch(attributes['ngIndeterminate'], function (value) {
                element.prop('indeterminate', !!value);
            });
        }
    };
});