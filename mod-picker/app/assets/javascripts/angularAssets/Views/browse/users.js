app.run(function($futureState, indexFactory, filtersFactory) {
    // dynamically construct and apply state
    var filterPrototypes = filtersFactory.userFilters();
    var state = indexFactory.buildState('username', 'ASC', 'users', filterPrototypes);
    $futureState.futureState(state);
});

app.controller('usersController', function ($scope, $rootScope, $stateParams, $state, userService, columnsFactory, filtersFactory, indexService, indexFactory) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.globalPermissions = angular.copy($rootScope.permissions);

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
    indexFactory.buildIndex($scope, $stateParams, $state);
});
