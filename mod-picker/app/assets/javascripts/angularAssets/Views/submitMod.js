app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('submit', {
            templateUrl: '/resources/partials/submitMod.html',
            controller: 'submitModController',
            url: '/submit'
        }
    );
}]);

app.controller('submitModController', function ($scope, backend, submitService, categoryService, sitesFactory) {
    // initialize variables
    $scope.sites = sitesFactory.sites();
    $scope.mod = {};
    $scope.mod.sources = [{
        label: "Nexus Mods",
        url: ""
    }];

    /* sources */
    $scope.addSource = function() {
        if ($scope.mod.sources.length == $scope.sites.length)
            return;
        $scope.mod.sources.push({
            label: "Nexus Mods",
            url: ""
        });
    };

    $scope.removeSource = function(source) {
        var index = $scope.mod.sources.indexOf(source);
        $scope.mod.sources.splice(index, 1);
    };

    function getSite(source) {
        return $scope.sites.find(function(item) {
            return item.label === source.label
        });
    }

    $scope.validateSource = function(source) {
        var site = getSite(source);
        var sourceIndex = $scope.mod.sources.indexOf(source);
        var sourceUsed = $scope.mod.sources.find(function(item, index) {
            return index != sourceIndex && item.label === source.label
        });
        var match = source.url.match(site.expr);
        source.valid = !sourceUsed && match != null;
    };

    $scope.scrapeSource = function(source) {
        // exit if the source is invalid
        var site = getSite(source);
        var match = source.url.match(site.expr);
        if (!match) {
            return;
        }

        var gameId = window._current_game_id;
        var modId = match[2];
        source.scraped = true;
        switch(source.label) {
            case "Nexus Mods":
                $scope.nexus = {};
                $scope.nexus.scraping = true;
                submitService.scrapeNexus(gameId, modId).then(function (data) {
                    $scope.nexus = data;
                });
                break;
            case "Lover's Lab":
                $scope.lab = {};
                $scope.lab.scraping = true;
                submitService.scrapeLab(gameId, modId).then(function (data) {
                    $scope.lab = data;
                });
                break;
            case "Steam Workshop":
                $scope.workshop = {};
                $scope.workshop.scraping = true;
                submitService.scrapeWorkshop(gameId, modId).then(function (data) {
                    $scope.workshop = data;
                });
                break;
        }
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

    /* analysis */
    $scope.changeAnalysisFile = function(event) {
        var input = event.target;
        if (input.files && input.files[0]) {
            $scope.loadAnalysisFile(input.files[0]);
        }
    };

    $scope.browseAnalysisFile = function() {
        document.getElementById('analysis-input').click();
    };

    $scope.loadAnalysisFile = function(file) {
        var fileReader = new FileReader();
        fileReader.onload = function (event) {
            $scope.analysis = JSON.parse(event.target.result);
            $scope.$apply();
        };
        fileReader.readAsText(file);
    };

    /* mod submission */
    $scope.modInvalid = function () {
        // submission isn't allowed until the user has scraped a nexus page,
        // provided a mod analysis, and provided at least one category
        var sourcesValid;
        $scope.mod.sources.forEach(function(source) {
            sourcesValid = sourcesValid && source.valid;
        });
        return (!sourcesValid || $scope.analysis == null || $scope.mod.categories == null ||
            $scope.mod.categories.length == 0 || $scope.mod.categories.length > 2)
    };

    $scope.submit = function () {
        submitService.submitMod($scope.mod, $scope.analysis);
    }
});