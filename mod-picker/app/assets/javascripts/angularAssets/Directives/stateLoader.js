app.directive('stateLoader', function (spinnerFactory) {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/stateLoader.html',
        scope: {
            spinnerClass: '@',
            contentClass: '@'
        },
        controller: 'stateLoaderController',
        transclude: true,
        link: function(scope, element, attrs) {
            var opts = spinnerFactory.getOpts(scope.spinnerClass);
            var target = element.children()[0].firstElementChild;
            var spinner = new Spinner(opts).spin(target);
        }
    }
});

app.controller('stateLoaderController', function ($scope, $rootScope) {
    $rootScope.$on("$stateChangeStart", function() {
        $scope.showSpinner = true;
    });

    $rootScope.$on("$stateChangeSuccess", function() {
        $scope.showSpinner = false;
    });

});
