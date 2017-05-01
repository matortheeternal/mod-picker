app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.categories-chart', {
        templateUrl: '/resources/partials/base/categoriesChart.html',
        controller: 'categoriesChartController',
        url: '/categories-chart'
    });
}]);

app.controller('categoriesChartController', function($scope, helpFactory, categoryService) {
    $scope.$emit('setPageTitle', 'Categories Flow Chart');
    helpFactory.setHelpContexts($scope, []);

    $scope.retrieveChart = function() {
        categoryService.retrieveCategoryChart().then(function(data) {
            $scope.chart = data.categories;
        }, function(response) {
            $scope.error = response;
        });
    };

    $scope.retrieveChart();
});
