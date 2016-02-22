/**
 * Created by r79 on 2/11/2016.
 */

app.directive('categoryPicker', function () {
    return {
        retrict: 'E',
        templateUrl: '/resources/directives/categoryPicker.html',
        controller: 'categoryPickerController',
        scope: {
            model: '=',
            required: '='
        }
    }
});

app.controller('categoryPickerController', function ($scope, categoryService) {
    categoryService.retrievePrimaryCategory().then(function (data) {
        $scope.mainCategories = data;
    });

    $scope.$watch('model.mainCategoryId', function (mainCategoryId) {
        if(mainCategoryId) {
            categoryService.retrieveSecondaryCategory(mainCategoryId).then(function (data) {
                $scope.subCategories = data;
            })
        } else {
            $scope.subCategories = undefined;
            $scope.model.subCategoryId = '';
        }
    });
});