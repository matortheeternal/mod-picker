/**
 * Created by r79 on 2/11/2016.
 */

app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider
        .when('/admin', {
            templateUrl: '/resources/partials/admin.html'
        });
}]);

app.controller('searchInputController', function ($scope, $location) {

});