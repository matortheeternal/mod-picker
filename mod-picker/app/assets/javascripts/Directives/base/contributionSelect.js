app.directive('contributionSelect', function(formUtils) {
    return {
        priority: 100,
        restrict: 'E',
        templateUrl: '/resources/directives/base/contributionSelect.html',
        scope: false,
        link: formUtils.hideWhenDocumentClicked('showContributions'),
        controller: 'contributionSelectController'
    }
});

app.controller('contributionSelectController', function($scope) {
    $scope.toggleContributions = function() {
        $scope.showContributions = !$scope.showContributions;
    };

    $scope.$on('$stateChangeStart', function() {
        $scope.showContributions = false;
    });
});