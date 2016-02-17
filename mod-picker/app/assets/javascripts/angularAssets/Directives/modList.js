/**
 * Created by r79 on 2/11/2016.
 */

app.directive('modList', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList.html',
        controller: 'modListController',
        scope: {
            data: '='
        }
    }
});

app.controller('modListController', function ($scope) {
    $scope.navigate = function (mod) {
        window.location = '#/mod/' + mod.id;
    }
});