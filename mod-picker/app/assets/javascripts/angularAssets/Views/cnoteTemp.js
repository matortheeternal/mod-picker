//Just a Temp routeprovider to load in individual Notes

app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/cnote', {
            templateUrl: '/resources/partials/notes/noteDisplay.html',
            controller: 'cnoteController'
        }
    );
}]);

app.controller('cnoteController', function ($scope) {
    //useTwoColumns(true);
    $scope.$watch('data', function (newValue) {
       // here we could have the cool part that connects to the server. Uncomment the next line to see some cool magic.
       // console.log(newValue);
    }, true);
});