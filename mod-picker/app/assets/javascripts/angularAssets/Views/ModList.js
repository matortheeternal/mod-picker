/**
 * Created by ThreeTen on 3/26/2016.
 */
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/modlist', {
            templateUrl: '/resources/partials/modlist_template.html'
        }
    );
}]);