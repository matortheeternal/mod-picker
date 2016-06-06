
app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('mods', {
            templateUrl: '/resources/partials/mods.html',
            controller: 'modsController',
            url: '/mods'
        }
    );
}]);

app.controller('modsController', function ($scope, $q, modService, sliderFactory, columnsFactory, filtersFactory, pageUtils) {
    // get parent variables
    $scope.currentUser = $scope.$parent.currentUser;
    $scope.currentGame = $scope.$parent.currentGame;
    $scope.globalPermissions = $scope.$parent.permissions;

    // initialize local variables
    $scope.filters = {
        sources: {
            nexus: true,
            lab: false,
            workshop: false,
            other: false
        },
        game: $scope.currentGame.id
    };
    $scope.availableColumnData = ["nexus"];
    $scope.sort = {};
    $scope.pages = {};
    $scope.columns = columnsFactory.modColumns();
    $scope.columnGroups = columnsFactory.modColumnGroups();
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

    $scope.availableFilters = function(filters) {
        return filters.filter(function(item) {
            return $scope.filterAvailable(item);
        });
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
        delete $scope.mods;
        var options =  {
            filters: $scope.filters,
            sort: $scope.sort,
            page: page || 1
        };
        modService.retrieveMods(options).then(function (data) {
            $scope.mods = data.mods;
            pageUtils.getPageInformation(data, $scope.pages, page);
            firstGet = true;
        });
    };

    // fetch mods when we load the page
    $scope.getMods();
    // laod available stat filters
    $scope.availableStatFilters = $scope.availableFilters($scope.statFilters);

    // create a watch
    var getModsTimeout;
    $scope.$watch('[filters, sort]', function() {
        // build availableColumnData string array
        $scope.availableColumnData = [];
        for (var property in $scope.filters.sources) {
            if ($scope.filters.sources.hasOwnProperty(property) && $scope.filters.sources[property]) {
                $scope.availableColumnData.push(property);
            }
        }

        // make columns that are no longer available no longer visible
        $scope.columns.forEach(function(column) {
            if (column.visibility && typeof column.data === 'object') {
                column.visibility = Object.keys(column.data).some(function(key) {
                    return $scope.availableColumnData.indexOf(key) > -1;
                });
            }
        });

        // hide statistic filters that no longer apply
        $scope.availableStatFilters = $scope.availableFilters($scope.statFilters);

        // get mods
        if($scope.filters && firstGet) {
            clearTimeout(getModsTimeout);
            $scope.pages.current = 1;
            getModsTimeout = setTimeout($scope.getMods, 700);
        }
    }, true);
});
