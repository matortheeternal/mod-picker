app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.modListFilters();
    var state = indexFactory.buildState('name', 'asc', 'modLists', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('modListsController', function ($scope, $stateParams, $state, currentUser, currentGame, modListService, columnsFactory, filtersFactory, actionsFactory, indexService, indexFactory) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.currentGame = currentGame;
    $scope.permissions = angular.copy(currentUser.permissions);

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
    indexFactory.buildIndex($scope, $stateParams, $state, indexService);
});