
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mods', {
            templateUrl: '/resources/partials/mods.html',
            controller: 'modsController'
        }
    );
}]);

app.controller('modsController', function ($scope, $q, backend) {
    $scope.loading = true;
    var now = new Date();
    var start = new Date(2011,10,11);
    $scope.dateSlider = {
        options: {
            floor: start.getTime(),
            ceil: now.getTime(),
            step: 86400000,
            hideLimitLabels: true,
            translate: function(value, sliderId, label) {
                var d;
                switch (label) {
                    case 'model':
                        d = new Date(value);
                        return d.toLocaleDateString();
                    case 'high':
                        d = new Date(value);
                        return d.toLocaleDateString();
                    default:
                        d = new Date(value);
                        return d.toLocaleDateString();
                }
            }
        }
    };
    $scope.slUpdated = {
        minValue: start.getTime(),
        maxValue: now.getTime()
    };
    $scope.slReleased = {
        minValue: start.getTime(),
        maxValue: now.getTime()
    };
    backend.retrieveMods().then(function (data) {
        $scope.mods = data;
        $scope.loading = false;
    });
});