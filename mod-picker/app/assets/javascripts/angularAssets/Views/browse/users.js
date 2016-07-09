app.run(function($futureState, indexService, filtersFactory) {
    // base params
    var params = {
        //column sort
        scol: 'username',
        sdir: 'asc'
    };
    indexService.setDefaultParamsFromFilters(params, filtersFactory.userFilters());

    // construct state
    var state = {
        stateName: 'base.users',
        name: 'base.users',
        templateUrl: '/resources/partials/browse/users.html',
        controller: 'usersController',
        url: indexService.getUrl('users', params),
        params: params,
        type: 'lazy'
    };

    // dynamically apply state
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
