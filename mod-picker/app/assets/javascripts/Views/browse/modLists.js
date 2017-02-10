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
    $scope.allowAdult = $scope.currentUser.signed_in && $scope.currentUser.settings.allow_adult_content;

    // set page title
    $scope.$emit('setPageTitle', 'Browse Mod Lists');
    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.indexPage]);

    // columns for view
    $scope.columns = columnsFactory.modListColumns(true);
    $scope.columnGroups = columnsFactory.modListColumnGroups();

    // initialize filters
    $scope.filterPrototypes = filtersFactory.modListFilters();
    $scope.dateFilters = filtersFactory.modListDateFilters();
    $scope.statFilters = filtersFactory.modListStatisticFilters();
    $scope.filters = { game: $scope.currentGame.id };

    // build generic controller stuff
    $scope.route = 'mod_lists';
    $scope.retrieve = modListService.retrieveModLists;
    indexFactory.buildIndex($scope, $stateParams, $state);
});
