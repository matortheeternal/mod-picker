
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mods', {
            templateUrl: '/resources/partials/mods.html',
            controller: 'modsController'
        }
    );
}]);

app.controller('modsController', function ($scope, $q, modService, sliderFactory, columnsFactory) {
    $scope.filters = {};
    $scope.sort = {};
    $scope.pages = {};
    $scope.columns = columnsFactory.modColumns();
    $scope.actions = [
        {
            caption: "Add",
            title: "Add this mod to your mod list",
            execute: function() {
                alert("Not functional yet.");
            }
        }
    ];

    //TODO: should be handled differently
    // -> remove redundancy
    // -> probably don't set visibility in the controller but in the view

    /* visibility of extended filters */
    $scope.nmVisible = false;
    $scope.nmToggle = function () {
        $scope.nmVisible = !$scope.nmVisible;
        if ($scope.nmVisbile) {
            $scope.$broadcast('refreshSlider');
        }
    };

    $scope.mpVisible = false;
    $scope.mpToggle = function () {
        $scope.mpVisible = !$scope.mpVisible;
        if ($scope.mpVisbile) {
            $scope.$broadcast('refreshSlider');
        }
    };

    /* data */
    // TODO: replace firstGet with $scope.mods
    var firstGet = false;
    $scope.getMods = function(page) {
        delete $scope.data;
        modService.retrieveMods($scope.filters, $scope.sort, page).then(function (data) {
            $scope.pages = data.pageInformation;
            $scope.data = data.mods;
            firstGet = true;
        });
    };

    $scope.getMods();

    // create a watch
    var getModsTimeout;
    $scope.$watch('[filters, sort]', function() {
        if($scope.filters && firstGet) {
            clearTimeout(getModsTimeout);
            $scope.pages.current = 1;
            getModsTimeout = setTimeout($scope.getMods, 700);
        }
    }, true);
});

