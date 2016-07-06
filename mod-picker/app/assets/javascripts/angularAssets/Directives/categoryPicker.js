/**
 * Created by r79 on 2/11/2016.
 */

app.directive('categoryPicker', function () {
    return {
        restrict: 'E',
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
                //TODO: maybe put this logic into the cat service
                data.forEach(function (entry) {
                    entry.name = entry.name.split('- ')[1];
                });
                $scope.subCategories = data;
            })
        } else {
            $scope.subCategories = undefined;
            if($scope.model) {
                delete $scope.model.subCategoryId;
            }
        }
    });
});