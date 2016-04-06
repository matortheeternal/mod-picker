app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/submit', {
            templateUrl: '/resources/partials/submitMod.html',
            controller: 'submitModController'
        }
    );
}]);

app.controller('submitModController', function ($scope, backend, submitService) {
    useTwoColumns(false);
    $scope.nexusScraped = false;
    var nexusUrlPattern = /(http[s]:\/\/?)?www.nexusmods.com\/skyrim\/mods\/([0-9]+)(\/\?)?/i;

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

    $scope.changePlugins = function(event) {
        var files = [].slice.call(event.target.files);
        if ($scope.plugins) {
            $scope.plugins = $scope.plugins.concat(files);
        } else {
            $scope.plugins = files;
        }
        $scope.$apply();
    };

    $scope.removePlugin = function(filename) {
        for (var i = 0; i < $scope.plugins.length; i++) {
            plugin = $scope.plugins[i];
            if (plugin.name == filename) {
                $scope.plugins.splice(i, 1);
                break;
            }
        }
        if ($scope.plugins.length == 0) {
            $scope.plugins = null;
        }
    };

    $scope.addPlugins = function() {
        document.getElementById('plugins-input').click();
    };

    $scope.clearPlugins = function() {
        $scope.plugins = null;
    };

    $scope.modInvalid = function () {
        return ($scope.nexus == null)
    };

    $scope.submit = function () {
        submitService.submit($scope.nexus, $scope.isUtility, $scope.hasAdultContent, $scope.plugins);
    }
});