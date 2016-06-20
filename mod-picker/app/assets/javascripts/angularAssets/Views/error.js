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

app.controller('errorController', function($scope, errorObj) {
    $scope.error = errorObj;
    console.log(errorObj);
});