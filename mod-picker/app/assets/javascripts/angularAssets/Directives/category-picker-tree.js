
app.directive('categoryPickerTree', function () {
    return {
        retrict: 'E',
        templateUrl: '/resources/directives/categoryPickerTree.html',
        controller: 'categoryPickerTreeController',
        scope: {
            model: '=',
            required: '='
        }
    }
});

app.controller('categoryPickerTreeController', function ($scope, categoryService) {
    categoryService.retrieveNestedCategories().then(function (data) {
        data.forEach(function (superCategory) {
            superCategory.childs.forEach(function (subCategory) {
                subCategory.name = subCategory.name.split('- ')[1];
            });
        });
        $scope.categories = data;
    });
});