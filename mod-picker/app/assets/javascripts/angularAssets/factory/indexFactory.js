app.service('indexFactory', function(indexService) {
    this.buildIndex = function($scope, $stateParams, $state, localIndexService) {
        // initialize local variables
        $scope.availableColumnData = [];
        $scope.actions = [];
        $scope.expanded = {};
        $scope.pages = {};

        // load sort values from url parameters
        $scope.sort = {};
        localIndexService.setSortFromParams($scope.sort, $stateParams);

        //  load filter values from url parameters
        $scope.filters = {};
        localIndexService.setFiltersFromParams($scope.filters, $scope.filterPrototypes, $stateParams);

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
            var errorCallback = function(response) {
                $scope.error = response;
            };
            if ($scope.contributions) {
                $scope.retrieve($scope.route, options, $scope.pages).then(dataCallback, errorCallback);
            } else {
                $scope.retrieve(options, $scope.pages).then(dataCallback, errorCallback);
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
                $scope.getDataTimeout = setTimeout($scope.getData, 1000);
            }

            // set url parameters
            if ($scope.filters && $scope.firstGet) {
                var params = localIndexService.getParamsFromFilters($scope.filters, $scope.filterPrototypes);
                var stateName = 'base.' + $scope.route.replace(/\_/g, "-");
                $state.transitionTo(stateName, params, { notify: false });
            }
        }, true);
    };

    this.buildState = function(scol, sdir, label, filterPrototypes) {
        // convert label to dash format
        var dashLabel = label.toDashFormat();

        // base params
        var params = {
            //column sort
            scol: scol,
            sdir: sdir
        };
        indexService.setDefaultParamsFromFilters(params, filterPrototypes);

        // construct and return the state
        return {
            stateName: 'base.' + dashLabel,
            name: 'base.' + dashLabel,
            templateUrl: '/resources/partials/browse/' + label + '.html',
            controller: label + 'Controller',
            url: indexService.getUrl(dashLabel, params),
            params: params,
            type: 'lazy'
        };
    };
});
