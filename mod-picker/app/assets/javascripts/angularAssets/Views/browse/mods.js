app.run(function($futureState, indexService, filtersFactory) {
    // base params
    var params = {
        //column sort
        scol: 'name',
        sdir: 'asc'
    };
    indexService.setDefaultParamsFromFilters(params, filtersFactory.modFilters());

    // construct state
    var state = {
        stateName: 'base.mods',
        name: 'base.mods',
        templateUrl: '/resources/partials/browse/mods.html',
        controller: 'modsController',
        url: indexService.getUrl('mods', params),
        params: params,
        type: 'lazy'
    };

    // dynamically apply state
    $futureState.futureState(state);
});

app.controller('modsController', function($scope, $q, $stateParams, $state, modService, sliderFactory, columnsFactory, filtersFactory, currentUser, currentGame, indexService, smoothScroll) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.currentGame = currentGame;
    $scope.globalPermissions = angular.copy(currentUser.permissions);

    // initialize local variables
    $scope.availableColumnData = ["nexus"];
    $scope.actions = [{
        caption: "Add",
        title: "Add this mod to your mod list",
        execute: function() {
            alert("Not functional yet.");
        }
    }];
    $scope.expanded = {};
    $scope.pages = {};
    $scope.columns = columnsFactory.modColumns();
    $scope.columnGroups = columnsFactory.modColumnGroups();

    // load sort values from url parameters
    $scope.sort = {};
    indexService.setSortFromParams($scope.sort, $stateParams);

    // initialize filters
    $scope.filterPrototypes = filtersFactory.modFilters();
    $scope.dateFilters = filtersFactory.modDateFilters();
    $scope.modPickerFilters = filtersFactory.modPickerFilters();
    $scope.statFilters = filtersFactory.modStatisticFilters();
    $scope.filters = {
        game: $scope.currentGame.id,
        adult: $scope.currentUser && $scope.currentUser.settings.allow_adult_content
    };
    //load slider values from url parameters
    indexService.setFiltersFromParams($scope.filters, $scope.filterPrototypes, $stateParams);
    
    // scroll to top of the page
    smoothScroll(document.body, { duration: 500 });

    /* helper functions */
    // returns a new subset of the input filters with the unavailable filters removed
    $scope.availableFilters = function(filters) {
        return filters.filter(function(item) {
            return $scope.filterAvailable(item);
        });
    };

    // returns true if the filter is available
    $scope.filterAvailable = function(filter) {
        var result = true;
        Object.keys($scope.filters.sources).forEach(function(key) {
            if ($scope.filters.sources[key] && !filter.sites[key]) {
                result = false;
            }
        });
        return result;
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

    /* data fetching functions */
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

    // fetch mods again when filters or sort changes
    var getModsTimeout;
    $scope.$watch('[filters, sort]', function() {
        // handle column availability
        $scope.buildAvailableColumnData();
        $scope.hideUnavailableColumns();

        // hide statistic filters that no longer apply
        $scope.availableStatFilters = $scope.availableFilters($scope.statFilters);

        // get mods
        if ($scope.filters && firstGet) {
            clearTimeout(getModsTimeout);
            $scope.pages.current = 1;
            getModsTimeout = setTimeout($scope.getMods, 1000);
        }

        // set url parameters
        if ($scope.filters && firstGet) {
            var params = indexService.getParamsFromFilters($scope.filters, $scope.filterPrototypes);
            $state.transitionTo('base.mods', params, { notify: false });
        }
    }, true);
});
