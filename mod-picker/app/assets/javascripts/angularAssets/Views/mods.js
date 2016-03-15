
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/mods', {
            templateUrl: '/resources/partials/mods.html',
            controller: 'modsController'
        }
    );
}]);

app.controller('modsController', function ($scope, $q, modService, sliderFactory) {
    useTwoColumns(true);
    $scope.loading = true;

    /* visibility of extended filters */
    $scope.nm_visible = false;
    $scope.nm_toggle = function () {
        $scope.nm_visible = !$scope.nm_visible;
        if ($scope.nm_visbile) {
            $scope.$broadcast('refreshSlider');
        }
    };

    $scope.mp_visible = false;
    $scope.mp_toggle = function () {
        $scope.mp_visible = !$scope.mp_visible;
        if ($scope.mp_visbile) {
            $scope.$broadcast('refreshSlider');
        }
    };

    /* data */
    modService.retrieveMods().then(function (data) {
        $scope.mods = data;
        $scope.loading = false;
    });
});



app.controller('categoryPickerTreeController', function ($scope, categoryService) {
    categoryService.retrieveNestedCategories().then(function (data) {
        var categoryFilter = $scope.categoryFilter = [];
        data.forEach(function (superCategory) {
            categoryFilter[superCategory.id] = {childs: []};
            categoryFilter[superCategory.id].value = false;
            superCategory.childs.forEach(function (subCategory) {
                categoryFilter[superCategory.id].childs[subCategory.id]= {value: false};
                subCategory.name = subCategory.name.split('- ')[1];
            });
        });
        $scope.categories = data;
    });

    $scope.updateSelection = function (primaryCategory, secondaryCategory) {
        if(!secondaryCategory) {
            $scope.categoryFilter[primaryCategory].indeterminate = false;
            $scope.categoryFilter[primaryCategory].childs.forEach(function (child) {
                child.value = $scope.categoryFilter[primaryCategory].value;
            });
        } else {
            //This logic is a bit hard to read. If you iterate through different possibilities you will understand.
            var partiallyChecked = false;
            var allChecked = true;
            $scope.categoryFilter[primaryCategory].childs.forEach(function (child) {

                //a child that is selected will mark the noneChecked false
                partiallyChecked = partiallyChecked || child.value;

                //a child that is not selected will mark the allChecked false
                allChecked = allChecked && child.value;
            });

            $scope.categoryFilter[primaryCategory].indeterminate = !allChecked && partiallyChecked;
            $scope.categoryFilter[primaryCategory].value = allChecked;
        }
    };

    $scope.clearSelection = function () {
        $scope.categoryFilter.forEach(function (superCategory) {
            superCategory.value = false;
            superCategory.indeterminate = false;
            superCategory.childs.forEach(function (child) {
                child.value = false;
            });
        });
    };

    $scope.inverseSelection = function () {
        $scope.categoryFilter.forEach(function (superCategory) {
            superCategory.value = !superCategory.value;
            superCategory.childs.forEach(function(child) {
                child.value = !child.value;
            });
        });
    };
});