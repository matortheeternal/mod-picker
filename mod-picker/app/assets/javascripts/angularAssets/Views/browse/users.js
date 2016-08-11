app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.userFilters();
    var state = indexFactory.buildState('username', 'asc', 'users', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('usersController', function ($scope, $stateParams, $state, currentUser, userService, columnsFactory, filtersFactory, indexService, indexFactory) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.globalPermissions = angular.copy(currentUser.permissions);

    // columns for view
    $scope.columns = columnsFactory.userColumns();
    $scope.columnGroups = columnsFactory.userColumnGroups();

    // initialize filters
    $scope.filterPrototypes = filtersFactory.userFilters();
    $scope.dateFilters = filtersFactory.userDateFilters();
    $scope.statFilters = filtersFactory.userStatisticFilters();

    // build generic controller stuff
    $scope.route = 'users';
    $scope.retrieve = userService.retrieveUsers;
    indexFactory.buildIndex($scope, $stateParams, $state, indexService);
});
