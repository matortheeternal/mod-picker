/**
 * Created by r79 on 2/11/2016.
 */
app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/submitMod', {
            templateUrl: '/resources/partials/submitMod.html',
            controller: 'submitModController'
        }
    );
}]);

app.controller('submitModController', function ($scope, backend) {
    useTwoColumns(false);
    $scope.submit = function () {
        if ($scope.submitModForm.$valid) {
            var primaryCategoryId = $scope.primaryCategory.subCategoryId || $scope.primaryCategory.mainCategoryId;
            var secondaryCategoryId = $scope.secondaryCategory && ($scope.secondaryCategory.subCategoryId || $scope.secondaryCategory.mainCategoryId);
            alert('data that would be sent to the server now' +
                '\nUrl: ' + $scope.url +
                '\nName: ' + $scope.name +
                '\nPrimaryCategoryId: ' + primaryCategoryId +
                (secondaryCategoryId ? '\nSecondaryCategoryId: ' + secondaryCategoryId : ''));
            window.location = '#/browse';
        }
    }
});