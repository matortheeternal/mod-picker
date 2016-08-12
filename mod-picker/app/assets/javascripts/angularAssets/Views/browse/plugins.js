app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.pluginFilters();
    var state = indexFactory.buildState('id', 'asc', 'plugins', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('pluginsController', function ($scope, $stateParams, $state, currentUser, currentGame, pluginService, columnsFactory, filtersFactory, actionsFactory, indexService, indexFactory) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.currentGame = currentGame;
    $scope.permissions = angular.copy(currentUser.permissions);

    // columns for view
    $scope.columns = columnsFactory.pluginColumns(true);
    $scope.columnGroups = columnsFactory.pluginColumnGroups();

    // initialize filters
    $scope.filterPrototypes = filtersFactory.pluginFilters();
    $scope.statFilters = filtersFactory.pluginStatisticFilters();
    $scope.filters = {
        game: $scope.currentGame.id
    };

    // build generic controller stuff
    $scope.route = 'plugins';
    $scope.retrieve = pluginService.retrievePlugins;
    indexFactory.buildIndex($scope, $stateParams, $state, indexService);
});
