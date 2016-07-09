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

app.controller('usersController', function ($scope, $q, $stateParams, $state, userService, sliderFactory, columnsFactory, filtersFactory, currentUser, indexService) {
    // get parent variables
    $scope.currentUser = currentUser;
    $scope.globalPermissions = angular.copy(currentUser.permissions);

    // initialize local variables
    $scope.availableColumnData = [];
    $scope.actions = [];
    $scope.extendedFilterVisibility = {};
    $scope.pages = {};
    $scope.columns = columnsFactory.userColumns();
    $scope.columnGroups = columnsFactory.userColumnGroups();

    // load sort values from url parameters
    $scope.sort = {};
    indexService.setSortFromParams($scope.sort, $stateParams);

    // initialize filters
    $scope.filterPrototypes = filtersFactory.userFilters();
    $scope.dateFilters = filtersFactory.userDateFilters();
    $scope.statFilters = filtersFactory.userStatisticFilters();
    $scope.filters = {};
    //load filter values from url parameters
    indexService.setFiltersFromParams($scope.filters, $scope.filterPrototypes, $stateParams);

    /* filter helper functions */
    $scope.toggleExtendedFilterVisibility = function(filterId) {
        var extendedFilter = $scope.extendedFilterVisibility[filterId] = !$scope.extendedFilterVisibility[filterId];
        if (extendedFilter) {
            $scope.$broadcast('rerenderSliders');
        }
    };

    /* data fetching functions */
    var firstGet = false;
    $scope.getUsers = function(page) {
        delete $scope.users;
        var options = {
            filters: $scope.filters,
            sort: $scope.sort,
            page: page || 1
        };
        userService.retrieveUsers(options, $scope.pages).then(function(data) {
            $scope.users = data.users;
            firstGet = true;
        });
    };

    // fetch users when we load the page
    $scope.getUsers();

    // fetch users again when filters or sort changes
    var getUsersTimeout;
    $scope.$watch('[filters, sort]', function() {
        // get users
        if ($scope.filters && firstGet) {
            clearTimeout(getUsersTimeout);
            $scope.pages.current = 1;
            getUsersTimeout = setTimeout($scope.getUsers, 700);
        }

        // set url parameters
        if ($scope.filters && firstGet) {
            var params = indexService.getParamsFromFilters($scope.filters, $scope.filterPrototypes);
            $state.transitionTo('base.users', params, { notify: false });
        }
    }, true);
});
