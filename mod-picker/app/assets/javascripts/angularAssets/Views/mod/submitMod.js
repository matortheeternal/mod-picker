app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('base.submit', {
            templateUrl: '/resources/partials/mod/submitMod.html',
            controller: 'submitModController',
            url: '/mods/submit'
        }
    );
}]);

app.controller('submitModController', function ($scope, $rootScope, backend, modService, scrapeService, pluginService, categoryService, sitesFactory, assetUtils, objectUtils) {
    // access parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.categories = $rootScope.categories;
    $scope.categoryPriorities = $rootScope.categoryPriorities;
    $scope.permissions = angular.copy($rootScope.permissions);

    // initialize variables
    $scope.sites = sitesFactory.sites();
    $scope.mod = {
        game_id: window._current_game_id,
        requirements: []
    };
    $scope.sources = [{
        label: "Nexus Mods",
        url: ""
    }];
    $scope.customSources = [];

    // inherited functions
    $scope.searchMods = modService.searchMods;

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
            var primaryCategory = categoryService.getCategoryById($scope.categories, $scope.mod.categories[0]);
            $scope.categoryMessages.push({
                text: "Primary Category: " + primaryCategory.name,
                klass: "cat-success-message"
            });
            if ($scope.mod.categories.length > 1) {
                var secondaryCategory = categoryService.getCategoryById($scope.categories, $scope.mod.categories[1]);
                $scope.categoryMessages.push({
                    text: "Secondary Category: " + secondaryCategory.name,
                    klass: "cat-success-message"
                });
            }
        }
    };

    $scope.swapCategories = function() {
        $scope.mod.categories.reverse();
    };

    // clear messages when user changes the category
    $scope.$watch('mod.categories', function() {
        if ($scope.categoryMessages && $scope.categoryMessages.length) {
            if ($scope.categoryMessages[0].klass == "cat-error-message" ||
                $scope.categoryMessages[0].klass == "cat-success-message") {
                $scope.categoryMessages = [];
            }
        }
    }, true);

    /* mod submission */

    // submission isn't allowed until the user has provided at least one valid source
    // provided a mod analysis, and provided at least one category
    $scope.modValid = function () {
        // main source validation
        var sourcesValid = true;
        $scope.sources.forEach(function(source) {
            sourcesValid = sourcesValid && source.valid;
        });

        // custom source validation
        if ($scope.customSources.length) {
            $scope.customSources.forEach(function(source) {
                sourcesValid = sourcesValid && source.valid;
            });
            // if we are only submitting custom soruces, we need to verify
            // we have all general info
            if (!$scope.sources.length) {
                sourcesValid = sourcesValid && $scope.mod.name && $scope.mod.authors &&
                    $scope.mod.released;
            }
        }
        else {
            // if we don't have any custom sources we should verify we have
            // the scraped data for at least one official source
            sourcesValid = sourcesValid && ($scope.nexus || $scope.workshop || $scope.lab);
        }

        // return true if any
        var categoriesValid = $scope.mod.categories && $scope.mod.categories.length &&
            $scope.mod.categories.length <= 2;
        return (sourcesValid && categoriesValid && $scope.mod.analysis)
    };

    $scope.submit = function () {
        // return if mod is invalid
        if (!$scope.modValid()) {
            return;
        }

        var sources = {
            nexus: $scope.nexus,
            workshop: $scope.workshop,
            lab: $scope.lab
        };
        $scope.submitting = true;
        $scope.submittingStatus = "Submitting Mod...";
        modService.submitMod($scope.mod, sources, $scope.customSources).then(function() {
            $scope.submittingStatus = "Mod Submitted Successfully!";
            $scope.success = true;
        }, function(response) {
            $scope.submittingStatus = "There were errors submitting your mod.";
            $scope.errors = response.data;
        });
    };

    $scope.closeModal = function() {
        delete $scope.success;
        delete $scope.submitting;
        delete $scope.errors;
    };
});
