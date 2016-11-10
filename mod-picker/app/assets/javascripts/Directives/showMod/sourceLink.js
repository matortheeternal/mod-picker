app.directive('sourceLink', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/showMod/sourceLink.html',
        scope: {
            source: '=',
            link: '@',
            label: '@'
        },
        controller: 'sourceLinkController'
    }
});

app.controller('sourceLinkController', function($scope, sitesFactory) {
    $scope.site = sitesFactory.getSite($scope.label);
});