app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.pluginFilters();
    var state = indexFactory.buildState('id', 'ASC', 'plugins', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('pluginsController', function($scope, $rootScope, $stateParams, $state, pluginService, helpFactory, columnsFactory, filtersFactory, actionsFactory, indexService, indexFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.currentGame = $rootScope.currentGame;
    $scope.categories = $rootScope.categories;
    $scope.permissions = angular.copy($rootScope.permissions);
    $scope.allowAdult = $scope.currentUser.signed_in && $scope.currentUser.settings.allow_adult_content;

    // set page title
    $scope.$emit('setPageTitle', 'Browse Plugins');
    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.indexPage]);

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
    indexFactory.buildIndex($scope, $stateParams, $state);
});
