app.service('indexFactory', function() {
    this.buildIndex = function($scope, $stateParams, $state, indexService) {
        // initialize local variables
        $scope.availableColumnData = [];
        $scope.actions = [];
        $scope.extendedFilterVisibility = {};
        $scope.pages = {};

        // load sort values from url parameters
        $scope.sort = {};
        indexService.setSortFromParams($scope.sort, $stateParams);

        //  load filter values from url parameters
        $scope.filters = {};
        indexService.setFiltersFromParams($scope.filters, $scope.filterPrototypes, $stateParams);

        /* filter helper functions */
        $scope.toggleExtendedFilterVisibility = function(filterId) {
            var extendedFilter = $scope.extendedFilterVisibility[filterId] = !$scope.extendedFilterVisibility[filterId];
            if (extendedFilter) {
                $scope.$broadcast('rerenderSliders');
            }
        };

        /* data fetching functions */
        $scope.firstGet = false;
        $scope.getData = function(page) {
            delete $scope[$scope.route];
            var options = {
                filters: $scope.filters,
                sort: $scope.sort,
                page: page || 1
            };
            var dataCallback = function(data) {
                $scope[$scope.route] = data[$scope.route];
                $scope.firstGet = true;
            };
            if ($scope.contributions) {
                $scope.retrieve($scope.route, options, $scope.pages).then(dataCallback);
            } else {
                $scope.retrieve(options, $scope.pages).then(dataCallback);
            }
        };

        // fetch contributions when we load the page
        $scope.getData();

        // fetch contributions again when filters or sort changes
        $scope.$watch('[filters, sort]', function() {
            // get users
            if ($scope.filters && $scope.firstGet) {
                clearTimeout($scope.getDataTimeout);
                $scope.pages.current = 1;
                $scope.getDataTimeout = setTimeout($scope.getData, 700);
            }

            // set url parameters
            if ($scope.filters && $scope.firstGet) {
                var params = indexService.getParamsFromFilters($scope.filters, $scope.filterPrototypes);
                $state.transitionTo('base.' + $scope.route, params, { notify: false });
            }
        }, true);
    };
});
