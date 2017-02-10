app.directive('loader', function(spinnerFactory) {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/layout/loader.html',
        scope: {
            data: '=',
            spinnerClass: '@',
            contentClass: '@'
        },
        controller: 'loaderController',
        transclude: true,
        link: function(scope, element, attrs) {
            var opts = spinnerFactory.getOpts(scope.spinnerClass);
            var target = element.children()[0].firstElementChild;
            scope.spinner = new Spinner(opts).spin(target);
        }
    }
});

app.controller('loaderController', function($scope) {
    $scope.showSpinner = false;
    $scope.$watch('data', function(newValue) {
        $scope.showSpinner = !newValue;
    });
});