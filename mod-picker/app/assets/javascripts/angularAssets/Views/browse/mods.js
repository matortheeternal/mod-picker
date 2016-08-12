app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modFilters();
    var state = indexFactory.buildState('name', 'asc', 'mods', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('modsController', function($scope, $q, $stateParams, $state, currentUser, currentGame, modService, sliderFactory, columnsFactory, filtersFactory, actionsFactory, indexService, indexFactory) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.currentGame = currentGame;
    $scope.globalPermissions = angular.copy(currentUser.permissions);

    // columns for view
    $scope.columns = columnsFactory.modColumns();
    $scope.columnGroups = columnsFactory.modColumnGroups();

    /* helper functions */
    // returns true if the input filter is available
    $scope.filterAvailable = function(filter) {
        var result = true;
        Object.keys($scope.filters.sources).forEach(function(key) {
            if ($scope.filters.sources[key] && !filter.sites[key]) {
                result = false;
            }
        });
        return result;
    };

    $scope.toggleModListFilter = function() {
        if ($scope.filters.exclude) {
            // it's being disabled
            delete $scope.filters.exclude;
        } else {
            // it's being enabled
            var activeModList = $scope.currentUser.active_mod_list;
            if (activeModList) {
                $scope.filters.exclude = activeModList.incompatible_mods;
            }
        }
    };

    // returns a new subset of the input filters with the unavailable filters removed
    $scope.availableFilters = function(filters) {
        return filters.filter(function(item) {
            return $scope.filterAvailable(item);
        });
    };

    // build availableColumnData string array
    $scope.buildAvailableColumnData = function() {
        $scope.availableColumnData = [];
        for (var property in $scope.filters.sources) {
            if ($scope.filters.sources.hasOwnProperty(property) && $scope.filters.sources[property]) {
                $scope.availableColumnData.push(property);
            }
        }
    };

    // hide columns that are no longer available
    $scope.hideUnavailableColumns = function() {
        $scope.columns.forEach(function(column) {
            if (column.visibility && typeof column.data === 'object') {
                column.visibility = Object.keys(column.data).some(function(key) {
                    return $scope.availableColumnData.indexOf(key) > -1;
                });
            }
        });
    };

    // filters for view
    $scope.filterPrototypes = filtersFactory.modFilters();
    $scope.dateFilters = filtersFactory.modDateFilters();
    $scope.modPickerFilters = filtersFactory.modPickerFilters();
    $scope.statFilters = filtersFactory.modStatisticFilters();
    $scope.filters = {
        game: $scope.currentGame.id,
        include_adult: $scope.currentUser && $scope.currentUser.settings.allow_adult_content
    };

    // build generic controller stuff
    $scope.route = 'mods';
    $scope.retrieve = modService.retrieveMods;
    indexFactory.buildIndex($scope, $stateParams, $state, indexService);

    // override some data from the generic controller
    $scope.buildAvailableColumnData();
    $scope.actions = actionsFactory.modIndexActions();

    // build available stat filters for view
    $scope.availableStatFilters = $scope.availableFilters($scope.statFilters);

    // handle special column/filter logic when filters change
    $scope.$watch('filters', function() {
        // handle column availability
        $scope.buildAvailableColumnData();
        $scope.hideUnavailableColumns();

        // hide statistic filters that no longer apply
        $scope.availableStatFilters = $scope.availableFilters($scope.statFilters);
    }, true);
});
