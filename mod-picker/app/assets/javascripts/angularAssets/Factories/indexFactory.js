app.service('indexFactory', function(indexService, objectUtils) {
    this.buildIndex = function($scope, $stateParams, $state) {
        // initialize local variables
        $scope.availableColumnData = [];
        $scope.actions = [];
        $scope.expanded = {};
        $scope.pages = {};

        // load sort values from url parameters
        $scope.sort = {};
        indexService.setSortFromParams($scope.sort, $stateParams);

        //  load filter values from url parameters
        angular.default($scope, 'filters', {});
        indexService.setFiltersFromParams($scope.filters, $scope.filterPrototypes, $stateParams);

        /* data fetching functions */
        $scope.getData = function(page) {
            delete $scope[$scope.route];
            var options = {
                filters: angular.copy($scope.filters),
                sort: $scope.sort,
                page: page || 1
            };
            objectUtils.deleteEmptyProperties(options.filters, 0, true);
            var dataCallback = function(data) {
                $scope[$scope.route] = data[$scope.route];
                delete $scope.error;
                if ($scope.dataCallback) $scope.dataCallback();
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

        $scope.$watch('[filters, sort]', function() {
            // fetch data again when filters or sort changes
            var dataWait = $scope[$scope.route] ? 1000 : 0;
            clearTimeout($scope.getDataTimeout);
            $scope.pages.current = 1;
            $scope.getDataTimeout = setTimeout($scope.getData, dataWait);

            // set url parameters
            var params = indexService.getParams($scope.filters, $scope.sort, $scope.filterPrototypes);
            $state.transitionTo($state.current.name, params, { notify: false });
        }, true);
    };

    this.buildState = function(scol, sdir, label, filterPrototypes) {
        // convert label to dash format
        var dashLabel = label.underscore('-');

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
