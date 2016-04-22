app.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/submit', {
            templateUrl: '/resources/partials/submitMod.html',
            controller: 'submitModController'
        }
    );
}]);

app.controller('submitModController', function ($scope, backend, submitService, categoryService) {
    // initialize variables
    $scope.mod = {};

    /* scraping */
    $scope.nexusScraped = false;
    //TODO: I guess this static might be better in some sort of service
    var nexusUrlPattern = /(http[s]:\/\/?)?www.nexusmods.com\/skyrim\/mods\/([0-9]+)(\/\?)?/i;

    $scope.cantScrape = function () {
        return $scope.scraping || !$scope.nexusUrl || $scope.nexusUrl.match(nexusUrlPattern) == null
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

    /* categories */
    categoryService.retrieveCategoryPriorities().then(function(data) {
        $scope.categoryPriorities = data;
    });

    categoryService.retrieveCategories().then(function (data) {
        $scope.categories = data;
    });

    $scope.getDominantIds = function(recessiveId) {
        var dominantIds = [];
        for (var i = 0; i < $scope.categoryPriorities.length; i++) {
            var priority = $scope.categoryPriorities[i];
            if (priority.recessive_id == recessiveId) {
                dominantIds.push(priority.dominant_id);
            }
        }
        return dominantIds;
    };

    $scope.getCategoryPriority = function(recessiveId, dominantId) {
        for (var i = 0; i < $scope.categoryPriorities.length; i++) {
            var priority = $scope.categoryPriorities[i];
            if (priority.recessive_id == recessiveId &&
                priority.dominant_id == dominantId)
                return priority;
        }
    };

    $scope.createPriorityMessage = function(recessiveId, dominantId) {
        recessiveCategory = categoryService.getCategoryById($scope.categories, recessiveId);
        dominantCategory = categoryService.getCategoryById($scope.categories, dominantId);
        categoryPriority = $scope.getCategoryPriority(recessiveId, dominantId);
        messageText = dominantCategory.name + " > " + recessiveCategory.name + "\n" + categoryPriority.description;
        $scope.categoryMessages.push({
            text: messageText,
            klass: "priority-message"
        });
    };

    $scope.checkCategories = function() {
        $scope.categoryMessages = [];
        $scope.mod.categories.forEach(function(recessiveId) {
            dominantIds = $scope.getDominantIds(recessiveId);
            dominantIds.forEach(function(dominantId) {
                var index = $scope.mod.categories.indexOf(dominantId);
                if (index > -1) {
                    $scope.createPriorityMessage(recessiveId, dominantId);
                }
            });
        });
        if ($scope.mod.categories.length > 2) {
            $scope.categoryMessages.push({
                text: "You have too many categories selected. \nThe maximum number of categories allowed is 2.",
                klass: "cat-error-message"
            });
        } else if ($scope.mod.categories.length == 0) {
            $scope.categoryMessages.push({
                text: "You must select at least one category.",
                klass: "cat-error-message"
            });
        } else if ($scope.categoryMessages.length == 0) {
            $scope.categoryMessages.push({
                text: "Categories look good!",
                klass: "cat-success-message"
            });
        }
    };

    // clear messages when user changes the category
    $scope.$watch('mod.categories', function() {
        if ($scope.categoryMessages && $scope.categoryMessages.length == 1) {
            if ($scope.categoryMessages[0].klass == "cat-error-message" ||
                $scope.categoryMessages[0].klass == "cat-success-message") {
                $scope.categoryMessages = [];
            }
        }
    }, true);

    /* asset file tree */
    $scope.changeAssetTree = function(event) {
        var input = event.target;
        if (input.files && input.files[0]) {
            $scope.loadAssetTree(input.files[0]);
        }
    };

    $scope.browseAssetTree = function() {
        document.getElementById('assets-input').click();
    };

    $scope.loadAssetTree = function(file) {
        var fileReader = new FileReader();
        fileReader.onload = function (event) {
            $scope.assets = JSON.parse(event.target.result).assets;
            $scope.$apply();
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
        // submission isn't allowed until the user has scraped a nexus page,
        // provided an asset tree, and provided at least one category
        return ($scope.nexus == null || $scope.assets == null ||
            $scope.mod.categories == null || $scope.mod.categories.length == 0)
    };

    $scope.submit = function () {
        submitService.submitMod($scope.mod, $scope.nexus, $scope.assets, $scope.plugins);
    }
});