
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

    $scope.reset = function () {
        $scope.categoryFilter.forEach(function (superCategory) {
            superCategory.value = false;
            superCategory.indeterminate = false;
            superCategory.childs.forEach(function (child) {
                child.value = false;
            });
        });
    };

    $scope.inverse = function () {
        $scope.categoryFilter.forEach(function (superCategory) {
            superCategory.value = !superCategory.value;
            superCategory.childs.forEach(function(child) {
                child.value = !child.value;
            });
        });
    };
});