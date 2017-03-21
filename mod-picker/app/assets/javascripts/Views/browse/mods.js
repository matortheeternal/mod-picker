app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modFilters();
    var state = indexFactory.buildState('submitted', 'DESC', 'mods', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('modsController', function($scope, $rootScope, $q, $stateParams, $state, modService, categoryService, modListService, indexService, helpFactory, sliderFactory, columnsFactory, detailsFactory, sortFactory, filtersFactory, actionsFactory, indexFactory, modsIndexFactory, eventHandlerFactory) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.currentGame = $rootScope.currentGame;
    $scope.categories = $rootScope.categories;
    $scope.activeModList = $rootScope.activeModList;
    $scope.permissions = angular.copy($rootScope.permissions);
    $scope.allowAdult = $scope.currentUser.signed_in && $scope.currentUser.settings.allow_adult_content;

    // set page title
    $scope.$emit('setPageTitle', 'Browse Mods');

    // columns for view
    $scope.columns = columnsFactory.modColumns();
    $scope.columnGroups = columnsFactory.modColumnGroups();

    // details for view
    $scope.details = detailsFactory.modDetails();
    $scope.detailGroups = detailsFactory.modDetailGroups();

    // sort options for view
    $scope.baseSortOptions = sortFactory.modSortOptions();

    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.modsIndex]);

    // mod list mod addition/removal handlers
    modsIndexFactory.buildModAddRemoveHandlers($scope);

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
        if ($scope.filters.compatibility) {
            // it's being disabled
            delete $scope.filters.compatibility;
        } else {
            // it's being enabled
            if ($scope.activeModList) {
                $scope.filters.compatibility = $scope.activeModList.id;
            }
        }
    };

    $scope.showDetailsModal = function() {
        $scope.$broadcast('configureDetails');
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

    $scope.activeSourceKeys = function(obj) {
        return Object.keys(obj).filter(function(key) {
            return $scope.filters.sources[key];
        });
    };

    $scope.getSortOptionValue = function(sortOptionValue) {
        return $scope.activeSourceKeys(sortOptionValue).map(function(key) {
            return sortOptionValue[key];
        }).join(',');
    };

    // build sortOptions based on sources
    $scope.buildSortOptions = function() {
        $scope.sortOptions = $scope.baseSortOptions.filter(function(sortOption) {
            if (typeof sortOption.value === 'object') {
                return $scope.activeSourceKeys(sortOption.value).length > 0;
            } else {
                return true;
            }
        }).map(function(sortOption) {
            if (typeof sortOption.value === 'object') {
                return {
                    label: sortOption.label,
                    value: $scope.getSortOptionValue(sortOption.value)
                }
            } else {
                return sortOption;
            }
        });
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
        categories: []
    };

    // build generic controller stuff
    $scope.route = 'mods';
    $scope.retrieve = modService.retrieveMods;
    indexFactory.buildIndex($scope, $stateParams, $state);
    eventHandlerFactory.buildMessageHandlers($scope);

    // override some data from the generic controller
    $scope.buildAvailableColumnData();
    $scope.buildSortOptions();
    $scope.actions = actionsFactory.modIndexActions();

    // build available stat filters for view
    $scope.availableStatFilters = $scope.availableFilters($scope.statFilters);

    // manipulate data before displaying it on the view
    $scope.dataCallback = function() {
        $scope.mods.forEach(function(mod) {
            categoryService.resolveModCategories($scope.categories, mod);
        });
    };

    $scope.termChange = function(term) {
        if ($scope.filters.terms[term] === '') {
            delete $scope.filters.terms[term];
        }
    };

    // handle special column/filter logic when filters change
    $scope.$watch('filters', function() {
        $scope.$broadcast('reloadTags');
    }, true);

    $scope.$watch('filters.sources', function() {
        $scope.buildAvailableColumnData();
        $scope.hideUnavailableColumns();
        $scope.buildSortOptions();
        $scope.availableStatFilters = $scope.availableFilters($scope.statFilters);
    }, true);
});
