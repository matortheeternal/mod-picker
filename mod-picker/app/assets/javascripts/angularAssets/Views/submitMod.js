app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('submit', {
            templateUrl: '/resources/partials/submitMod.html',
            controller: 'submitModController',
            url: '/submit'
        }
    );
}]);

app.controller('submitModController', function ($scope, backend, submitService, categoryService, sitesFactory, assetUtils) {
    // initialize variables
    $scope.sites = sitesFactory.sites();
    $scope.mod = { game_id: window._current_game_id };
    $scope.requirements = [];
    $scope.sources = [{
        label: "Nexus Mods",
        url: ""
    }];

    /* sources */
    $scope.addSource = function() {
        if ($scope.sources.length == $scope.sites.length)
            return;
        $scope.sources.push({
            label: "Nexus Mods",
            url: ""
        });
    };

    $scope.removeSource = function(source) {
        var index = $scope.sources.indexOf(source);
        $scope.sources.splice(index, 1);
    };

    $scope.validateSource = function(source) {
        var site = sitesFactory.getSite($scope.sites, source.label);
        var sourceIndex = $scope.sources.indexOf(source);
        var sourceUsed = $scope.sources.find(function(item, index) {
            return index != sourceIndex && item.label === source.label
        });
        var match = source.url.match(site.modUrlFormat);
        source.valid = !sourceUsed && match != null;
    };

    $scope.scrapeSource = function(source) {
        // exit if the source is invalid
        var site = sitesFactory.getSite($scope.sites, source.label);
        var match = source.url.match(site.modUrlFormat);
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
                submitService.scrapeLab(modId).then(function (data) {
                    $scope.lab = data;
                });
                break;
            case "Steam Workshop":
                $scope.workshop = {};
                $scope.workshop.scraping = true;
                submitService.scrapeWorkshop(modId).then(function (data) {
                    $scope.workshop = data;
                });
                break;
        }
    };

    /* requirements */
    $scope.addRequirement = function() {
        $scope.requirements.push({});
    };

    $scope.removeRequirement = function(requirement) {
        var index = $scope.requirements.indexOf(requirement);
        $scope.requirements.splice(index, 1);
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
        var recessiveCategory = categoryService.getCategoryById($scope.categories, recessiveId);
        var dominantCategory = categoryService.getCategoryById($scope.categories, dominantId);
        var categoryPriority = $scope.getCategoryPriority(recessiveId, dominantId);
        var messageText = dominantCategory.name + " > " + recessiveCategory.name + "\n" + categoryPriority.description;
        $scope.categoryMessages.push({
            text: messageText,
            klass: "priority-message"
        });
    };

    $scope.getSuperCategories = function() {
        var superCategories = [];
        $scope.mod.categories.forEach(function (id) {
            var superCategory = categoryService.getCategoryById($scope.categories, id).parent_id;
            if (superCategory && superCategories.indexOf(superCategory) == -1) {
                superCategories.push(superCategory);
            }
        });
        return superCategories;
    };

    $scope.checkCategories = function() {
        $scope.categoryMessages = [];
        var selectedCategories = Array.prototype.concat($scope.getSuperCategories(), $scope.mod.categories);
        selectedCategories.forEach(function(recessiveId) {
            dominantIds = $scope.getDominantIds(recessiveId);
            dominantIds.forEach(function(dominantId) {
                var index = selectedCategories.indexOf(dominantId);
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
            var fixedJson = event.target.result.replace('"plugin_record_groups"', '"plugin_record_groups_attributes"').replace('"plugin_errors"', '"plugin_errors_attributes"').replace('"overrides"', '"overrides_attributes"');
            $scope.analysis = JSON.parse(fixedJson);
            $scope.analysis.nestedAssets = assetUtils.convertDataStringToNestedObject($scope.analysis.assets);
            $scope.$apply();
        };
        fileReader.readAsText(file);
    };

    /* mod submission */
    $scope.modInvalid = function () {
        // submission isn't allowed until the user has scraped a nexus page,
        // provided a mod analysis, and provided at least one category
        var sourcesValid = true;
        $scope.sources.forEach(function(source) {
            sourcesValid = sourcesValid && source.valid;
        });
        return (!sourcesValid || $scope.analysis == null || $scope.mod.categories == null ||
            $scope.mod.categories.length == 0 || $scope.mod.categories.length > 2)
    };

    $scope.submit = function () {
        var sources = {
            nexus: $scope.nexus,
            workshop: $scope.workshop,
            lab: $scope.lab
        };
        submitService.submitMod($scope.mod, $scope.analysis, sources, $scope.requirements);
    }
});