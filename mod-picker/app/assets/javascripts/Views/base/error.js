app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.error', {
        url: '/error',
        templateUrl: '/resources/partials/base/error.html',
        controller: 'errorController',
        resolve: {
            errorObj: function() {
                return this.self.error;
            }
        }
    })
}]);

app.controller('errorController', function($scope, $state, helpFactory, errorObj, quoteService) {
    // set error values to scope
    if (errorObj) {
        $scope.message = errorObj.text;
        $scope.response = errorObj.response;
        $scope.stateUrl = errorObj.stateUrl;
        $scope.stateName = errorObj.stateName;
        $scope.status = errorObj.response && errorObj.response.status;
        switch($scope.status) {
            case 401: case 403: case 550:
                $scope.statusType = "unauthorized";
                break;
            case 404: case 410:
                $scope.statusType = "not_found";
                break;
            case 429: case 503:
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

    // set page title
    $scope.$emit('setPageTitle', 'Error '+$scope.status);
    helpFactory.setHelpContexts($scope, []);

    // get a quote for the error
    $scope.quote = quoteService.getErrorQuote($scope.status);
    $scope.defaultExplanations = {
        unauthorized: "You are not authorized to access this resource.",
        not_found: "We were unable to display the page you were looking for.",
        unavailable: "The resource is unavailable.  The server is either down or overburdened."
    };

    // special cheese handling
    if ($scope.quote.text.startsWith("Cheese!")) {
        $scope.quote.class = "sheogorath-cheese-quote";
    }
});