app.run(function($futureState, indexService) {
    // TODO: construct state here
    $futureState.futureState(indexService.state);
});

app.controller('modsController', function($scope, $q, $stateParams, $state, modService, sliderFactory, columnsFactory, filtersFactory, currentUser, currentGame, indexService) {
    $scope.$stateParams = $stateParams;
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.currentGame = currentGame;
    $scope.globalPermissions = angular.copy(currentUser.permissions);

    // initialize local variables
    $scope.filterPrototypes = filtersFactory.modFilters();
    $scope.filters = {
        sources: {
            nexus: $stateParams.nm,
            lab: $stateParams.ll,
            workshop: $stateParams.sw,
            other: $stateParams.ot
        },
        game: $scope.currentGame.id,
        adult: $scope.currentUser && $scope.currentUser.settings.allow_adult_content
    };
    //load name and author from url parameters
    indexService.setFilterFromParam($scope.filters, 'search', $stateParams.n);
    indexService.setFilterFromParam($scope.filters, 'author', $stateParams.a);
    //load slider values from url parameters
    indexService.setSliderFiltersFromParams($scope.filters, $scope.filterPrototypes, $stateParams);
    //load tags and categories from url parameters
    indexService.setListFilterFromParam($scope.filters, 'tags', $stateParams.t);
    indexService.setListFilterFromParam($scope.filters, 'categories', $stateParams.c);

    $scope.availableColumnData = ["nexus"];
    $scope.sort = {};
    $scope.pages = {};
    $scope.columns = columnsFactory.modColumns();
    $scope.columnGroups = columnsFactory.modColumnGroups();
    $scope.actions = [{
        caption: "Add",
        title: "Add this mod to your mod list",
        execute: function() {
            alert("Not functional yet.");
        }
    }];

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

    $scope.toggleExtendedFilterVisibility = function(filterId) {
        var extendedFilter = $scope.extendedFilterVisibility[filterId] = !$scope.extendedFilterVisibility[filterId];
        if (extendedFilter) {
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
        var options = {
            filters: $scope.filters,
            sort: $scope.sort,
            page: page || 1
        };
        modService.retrieveMods(options, $scope.pages).then(function(data) {
            $scope.mods = data.mods;
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
        if ($scope.filters && firstGet) {
            clearTimeout(getModsTimeout);
            $scope.pages.current = 1;
            getModsTimeout = setTimeout($scope.getMods, 700);
        }

        // set url parameters
        if ($scope.filters && firstGet) {
            var params = indexService.getParamsFromFilters($scope.filters, $scope.filterPrototypes);
            $state.transitionTo('base.mods', params, { notify: false });
        }
    }, true);
});
