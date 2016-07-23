app.directive('modsTable', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modsTable.html',
        controller: 'modsTableController',
        scope: {
            title: '@',
            mods: '='
        }
    };
});

app.controller('modsTableController', function($scope) {
    //TODO: needs to be implemented
    $scope.modHide = function(mod) {};
});
