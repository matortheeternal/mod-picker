app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.donate', {
        templateUrl: '/resources/partials/base/donate.html',
        controller: 'donateController',
        url: '/donate'
    });
}]);

app.controller('donateController', function($scope, $rootScope) {
    // TODO: Some logic in here maybe?
});
