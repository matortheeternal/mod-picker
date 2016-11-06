app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modFilters();
    var state = indexFactory.buildState('id', 'DESC', 'mods', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('modsController', function($scope, $rootScope, $q, $stateParams, $state, modService, categoryService, modListService, indexService, helpFactory, sliderFactory, columnsFactory, detailsFactory, filtersFactory, actionsFactory, indexFactory, eventHandlerFactory) {
    // inherited variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.currentGame = $rootScope.currentGame;
    $scope.categories = $rootScope.categories;
    $scope.activeModList = $rootScope.activeModList;
    $scope.permissions = angular.copy($rootScope.permissions);
    $scope.allowAdult = $scope.currentUser && $scope.currentUser.settings.allow_adult_content;

    // set page title
    $scope.$emit('setPageTitle', 'Browse Mods');

    // columns for view
    $scope.columns = columnsFactory.modColumns();
    $scope.columnGroups = columnsFactory.modColumnGroups();

    // details for view
    $scope.details = detailsFactory.modDetails();
    $scope.detailGroups = detailsFactory.modDetailGroups();

    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.modsIndex]);

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

    // adds a mod to the user's mod list
    $scope.$on('addMod', function(event, mod) {
        modListService.addModListMod($scope.activeModList, mod).then(function() {
            $scope.$emit('successMessage', 'Added mod "'+mod.name+'" to your mod list successfully.');
        }, function(response) {
            var params = {
                label: 'Error adding mod "'+mod.name+'" to your mod list',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    });

    // removes a mod from the user's mod list
    $scope.$on('removeMod', function(event, mod) {
        modListService.removeModListMod($scope.activeModList, mod).then(function() {
            $scope.$emit('successMessage', 'Removed mod "'+mod.name+'" from your mod list successfully.');
        }, function(response) {
            var params = {
                label: 'Error removing mod "'+mod.name+'" from your mod list',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    });

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
    $scope.actions = actionsFactory.modIndexActions();

    // build available stat filters for view
    $scope.availableStatFilters = $scope.availableFilters($scope.statFilters);

    // manipulate data before displaying it on the view
    $scope.dataCallback = function() {
        $scope.mods.forEach(function(mod) {
            categoryService.resolveModCategories($scope.categories, mod);
        });
    };

    // handle special column/filter logic when filters change
    $scope.$watch('filters', function() {
        // handle column availability
        $scope.buildAvailableColumnData();
        $scope.hideUnavailableColumns();

        // hide statistic filters that no longer apply
        $scope.availableStatFilters = $scope.availableFilters($scope.statFilters);
    }, true);
});
