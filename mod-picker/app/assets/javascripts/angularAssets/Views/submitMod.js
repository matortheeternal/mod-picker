app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/submitMod', {
            templateUrl: '/resources/partials/submitMod.html',
            controller: 'submitModController'
        }
    );
}]);

app.controller('submitModController', function ($scope, backend, submitService) {
    useTwoColumns(false);
    $scope.nexusScraped = false;
    var nexusUrlPattern = /(http[s]:\/\/{0,1}){0,1}www.nexusmods.com\/skyrim\/mods\/([0-9]{1,9})(\/\?){0,1}/i;

    $scope.urlInvalid = function () {
        return nexusUrlPattern.exec($scope.nexusUrl) == null
    };

    $scope.scrape = function () {
        var match = nexusUrlPattern.exec($scope.nexusUrl);
        var id = match[2];
        $scope.scraping = true;
        submitService.scrapeNexus(3, id).then(function (data) {
            $scope.nexus = data;
            if (data.nexus_category == 39) {
                $scope.isUtility = true;
            }
        });
    };

    $scope.submit = function () {
        if ($scope.submitModForm.$valid) {
            var primaryCategoryId = $scope.primaryCategory.subCategoryId || $scope.primaryCategory.mainCategoryId;
            var secondaryCategoryId = $scope.secondaryCategory && ($scope.secondaryCategory.subCategoryId || $scope.secondaryCategory.mainCategoryId);
            alert('data that would be sent to the server now' +
                '\nUrl: ' + $scope.url +
                '\nName: ' + $scope.name +
                '\nPrimaryCategoryId: ' + primaryCategoryId +
                (secondaryCategoryId ? '\nSecondaryCategoryId: ' + secondaryCategoryId : ''));
            window.location = '#/mods';
        }
    }
});