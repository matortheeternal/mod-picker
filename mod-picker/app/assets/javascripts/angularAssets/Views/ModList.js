/**
 * Created by ThreeTen on 3/26/2016.
 */
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/modlist', {
            templateUrl: '/resources/directives/modlist_template.html',
            controller: 'modlistController'
        }
    );
}]);

app.controller('modlistController', function($scope) {
    useTwoColumns(false);
});