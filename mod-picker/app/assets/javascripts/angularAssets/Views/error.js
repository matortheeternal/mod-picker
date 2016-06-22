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
    }
    // if we don't have an error to display, redirect to base state
    else {
        $state.go('base');
        return;
    }

    $scope.quote = quoteService.getErrorQuote($scope.response.status);
});