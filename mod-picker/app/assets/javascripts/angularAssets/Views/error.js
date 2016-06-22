app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.error', {
        url: '/error',
        templateUrl: '/resources/partials/base/error.html',
        controller: 'errorController',
        resolve: {
            errorObj: function () {
                return this.self.error;
            }
        }
    })
}]);

app.controller('errorController', function($scope, $state, errorObj, quoteService) {
    // set error values to scope
    if (errorObj) {
        $scope.message = errorObj.text;
        $scope.response = errorObj.response;
        $scope.stateUrl = errorObj.stateUrl;
        $scope.stateName = errorObj.stateName;
        $scope.status = errorObj.response.status;
        switch($scope.status) {
            case 401: case 403: case 550:
                $scope.statusType = "unauthorized";
                break;
            case 404: case 410:
                $scope.statusType = "not found";
                break;
            case 503:
                $scope.statusType = "unavailable";
                break;
            case 500: default:
                $scope.statusType = "error"
        }
    }
    // if we don't have an error to display, redirect to base state
    else {
        $state.go('base');
        return;
    }

    // get a quote for the error
    $scope.quote = quoteService.getErrorQuote($scope.response.status);

    // special cheese handling
    if ($scope.quote.text.startsWith("Cheese!")) {
        $scope.quote.class = "sheogorath-cheese-quote";
    }
});