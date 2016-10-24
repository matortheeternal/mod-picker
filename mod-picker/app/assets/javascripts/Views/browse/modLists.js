app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modListFilters();
    var state = indexFactory.buildState('name', 'ASC', 'modLists', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('modListsController', function($scope, $rootScope, $stateParams, $state, modListService, helpFactory, columnsFactory, filtersFactory, actionsFactory, indexService, indexFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.currentGame = $rootScope.currentGame;
    $scope.permissions = angular.copy($rootScope.permissions);

    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.indexPage]);

    // columns for view
    $scope.columns = columnsFactory.modListColumns(true);
    $scope.columnGroups = columnsFactory.modListColumnGroups();

    // initialize filters
    $scope.filterPrototypes = filtersFactory.modListFilters();
    $scope.dateFilters = filtersFactory.modListDateFilters();
    $scope.statFilters = filtersFactory.modListStatisticFilters();
    $scope.filters = {
        game: $scope.currentGame.id,
        include_adult: $scope.currentUser && $scope.currentUser.settings.allow_adult_content
    };

    // build generic controller stuff
    $scope.route = 'mod_lists';
    $scope.retrieve = modListService.retrieveModLists;
    indexFactory.buildIndex($scope, $stateParams, $state);
});
