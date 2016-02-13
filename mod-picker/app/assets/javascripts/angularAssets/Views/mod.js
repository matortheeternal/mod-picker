/**
 * Created by r79 on 2/11/2016.
 */
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mod/:modId', {
            templateUrl: '/resources/partials/mod.html',
            controller: 'modController'
        }
    );
}]);

app.controller('modController', function ($scope, $q, $routeParams, backend) {
    $scope.loading = true;
    backend.retrieveMod($routeParams.modId).then(function (data) {
        $scope.mod = data;
        $scope.version = data.mod_versions[0].id;
        $scope.loading = false;
    });

    $scope.$watch('version', function (newVal, oldVal) {
        console.log(newVal + ' ' + oldVal);
    })
});