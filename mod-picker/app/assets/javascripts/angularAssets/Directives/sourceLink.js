app.directive('sourceLink', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/sourceLink.html',
        scope: {
            source: '=',
            link: '@',
            label: '@'
        },
        controller: 'sourceLinkController'
    }
});

app.controller('sourceLinkController', function ($scope, sitesFactory) {
    $scope.site = sitesFactory.getSite($scope.label);
});