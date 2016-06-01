
app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('mods', {
            templateUrl: '/resources/partials/mods.html',
            controller: 'modsController',
            url: '/mods'
        }
    );
}]);

app.controller('modsController', function ($scope, $q, modService, sliderFactory, columnsFactory, filtersFactory) {
    $scope.filters = {
        sources: {
            nexus: true,
            lab: false,
            workshop: false,
            other: false
        }
    };
    $scope.sort = {};
    $scope.pages = {};
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

    // load filter prototypes
    $scope.dateFilters = filtersFactory.modDateFilters();
    $scope.modPickerFilters = filtersFactory.modPickerFilters();
    $scope.statFilters = filtersFactory.modStatisticFilters();

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
            $scope.$broadcast('rerenderSliders');
        }
    };

    $scope.filterAvailable = function(filter) {
        var result = true;
        Object.keys($scope.filters.sources).forEach(function(key) {
            if ($scope.filters.sources[key] && !filter.sites[key]) {
                result = false;
            }
        });
        return result;
    };

    /* data */
    // TODO: replace firstGet with $scope.mods
    var firstGet = false;
    $scope.getMods = function(page) {
        delete $scope.data;
        modService.retrieveMods($scope.filters, $scope.sort, page).then(function (data) {
            $scope.pages = data.pageInformation;
            $scope.data = data.mods;
            firstGet = true;
        });
    };

    $scope.getMods();

    // create a watch
    var getModsTimeout;
    $scope.$watch('[filters, sort]', function() {
        if($scope.filters && firstGet) {
            clearTimeout(getModsTimeout);
            $scope.pages.current = 1;
            getModsTimeout = setTimeout($scope.getMods, 700);
        }
    }, true);
});
