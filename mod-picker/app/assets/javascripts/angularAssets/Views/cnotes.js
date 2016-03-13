
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/compatibility_notes', {
            templateUrl: '/resources/partials/compatibility_notes.html',
            controller: 'cnotesController'
        }
    );
}]);

app.controller('cnotesController', function ($scope) {
    useTwoColumns(true);
    $scope.$watch('data', function (newValue) {
       // here we could have the cool part that connects to the server. Uncomment the next line to see some cool magic.
       // console.log(newValue);
    }, true);
});