app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.donate', {
        templateUrl: '/resources/partials/base/donate.html',
        controller: 'donateController',
        url: '/donate'
    });
}]);

app.controller('donateController', function($scope, helpFactory) {
    $scope.$emit('setPageTitle', 'Donate');
    helpFactory.setHelpContexts($scope, []);
});
