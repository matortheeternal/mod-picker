
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mods', {
            templateUrl: '/resources/partials/mods.html',
            controller: 'modsController'
        }
    );
}]);

app.controller('modsController', function ($scope, $q, modService, sliderFactory, columnsFactory) {
    $scope.filters = {};
    $scope.sort = {};
    $scope.columns = columnsFactory.modColumns();
    $scope.actions = [
        {
            caption: "Add",
            title: "Add this mod to your mod list",
            execute: function() {
                alert("Not functional yet.");
            }
        }
    ];

    //TODO: should be handled differently
    // -> remove redundancy
    // -> probably don't set visibility in the controller but in the view

    $scope.extendedFilterVisibility = {
        nexusMods: false,
        modPicker: false
    };

    $scope.toggleExtendedFilterVisibility = function (filterId) {
        var extendedFilter = $scope.extendedFilterVisibility[filterId] = !$scope.extendedFilterVisibility[filterId];
        if(extendedFilter) {
            $scope.$broadcast('refreshSlider');
        }
    };

    /* data */
    // TODO: replace firstGet with $scope.mods
    var firstGet = false;
    $scope.getMods = function() {
        delete $scope.data;
        modService.retrieveMods($scope.filters, $scope.sort).then(function (data) {
            $scope.data = data;
            firstGet = true;
        });
    };

    $scope.getMods();

    // create a watch
    var getModsTimeout;
    $scope.$watch('[filters, sort]', function() {
        if($scope.filters && firstGet) {
            clearTimeout(getModsTimeout);
            getModsTimeout = setTimeout($scope.getMods, 700);
        }
    }, true);
});

