
app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.compatibility_notes', {
            templateUrl: '/resources/partials/compatibility_notes.html',
            url: '/compatibility_notes',
            controller: 'cnotesController'
        }
    );
}]);

app.controller('cnotesController', function ($scope) {
    $scope.$watch('data', function (newValue) {
       // here we could have the cool part that connects to the server. Uncomment the next line to see some cool magic.
       // console.log(newValue);
    }, true);
});
