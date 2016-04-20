app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/submit', {
            templateUrl: '/resources/partials/submitMod.html',
            controller: 'submitModController'
        }
    );
}]);

app.controller('submitModController', function ($scope, backend, submitService, archiveService) {
    // initialize variables
    $scope.mod = {};
    $scope.nexus = {};

    /* scraping */
    $scope.nexusScraped = false;
    //TODO: I guess this static might be better in some sort of service
    var nexusUrlPattern = /(http[s]:\/\/?)?www.nexusmods.com\/skyrim\/mods\/([0-9]+)(\/\?)?/i;

    $scope.urlInvalid = function () {
        return !$scope.nexusUrl || $scope.nexusUrl.match(nexusUrlPattern) == null
    };

    $scope.scrape = function () {
        var match = $scope.nexusUrl.match(nexusUrlPattern);
        if (!match) {
            return;
        }
        var id = match[2];
        $scope.scraping = true;
        submitService.scrapeNexus(3, id).then(function (data) {
            $scope.nexus = data;
            if (data.nexus_category == 39) {
                $scope.isUtility = true;
            }
        });
    };

    /* asset file tree */
    $scope.changeAssetTree = function(event) {
        var input = event.target;
        if (input.files && input.files[0]) {
            $scope.loadAssetTree(input.files[0]);
        }
    };

    $scope.browseAssetTree = function() {
        document.getElementById('archive-input').click();
    };

    $scope.loadAssetTree = function(file) {
        var fileReader = new FileReader();
        fileReader.onload = function (event) {
            $scope.assetTree = JSON.parse(event.target.result);
        };
        fileReader.readAsText(file);
    };

    /* plugin submission */
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

    /* mod submission */
    $scope.modInvalid = function () {
        return ($scope.nexus == null)
    };

    $scope.submit = function () {
        submitService.submitMod($scope.mod, $scope.nexus, $scope.assetMap, $scope.plugins);
    }
});
