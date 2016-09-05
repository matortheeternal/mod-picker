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
        var site = sitesFactory.getSite(source.label);
        var sourceIndex = $scope.sources.indexOf(source);
        var sourceUsed = $scope.sources.find(function(item, index) {
            return index != sourceIndex && item.label === source.label
        });
        var match = source.url.match(site.modUrlFormat);
        source.valid = !sourceUsed && match != null;
    };

    $scope.loadGeneralStats = function(stats, override) {
        if ($scope.mod.name && !override) {
            return;
        }

        // load the stats
        $scope.mod.name = stats.mod_name;
        $scope.mod.authors = stats.authors || stats.uploaded_by;
        $scope.mod.released = new Date(Date.parse(stats.released));
        $scope.mod.updated = new Date(Date.parse(stats.updated));
    };

    $scope.scrapeSource = function(source) {
        // exit if the source is invalid
        var site = sitesFactory.getSite(source.label);
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
                scrapeService.scrapeNexus(gameId, modId).then(function (data) {
                    $scope.nexus = data;
                    $scope.loadGeneralStats(data, true);
                });
                break;
            case "Lover's Lab":
                $scope.lab = {};
                $scope.lab.scraping = true;
                scrapeService.scrapeLab(modId).then(function (data) {
                    $scope.lab = data;
                    $scope.loadGeneralStats(data);
                });
                break;
            case "Steam Workshop":
                $scope.workshop = {};
                $scope.workshop.scraping = true;
                scrapeService.scrapeWorkshop(modId).then(function (data) {
                    $scope.workshop = data;
                    $scope.loadGeneralStats(data);
                });
                break;
        }
    };

    /* custom sources */
    $scope.addCustomSource = function() {
        $scope.customSources.push({
            label: "Custom",
            url: ""
        });
    };

    $scope.removeCustomSource = function(source) {
        var index = $scope.customSources.indexOf(source);
        $scope.customSources.splice(index, 1);
    };

    $scope.validateCustomSource = function(source) {
        source.valid = (source.label.length > 4) && (source.url.length > 12);
    };

    /* requirements */
    $scope.addRequirement = function() {
        $scope.mod.requirements.push({});
    };

    $scope.addRequirementFromPlugin = function(filename) {
        pluginService.searchPlugins(filename).then(function(plugins) {
            var plugin = plugins.find(function(plugin) {
                return plugin.filename === filename;
            });
            if (plugin) {
                var match = $scope.mod.requirements.find(function(requirement) {
                    return requirement.required_id == plugin.mod_id;
                });
                if (!match) {
                    $scope.mod.requirements.push({required_id: plugin.mod_id, name: plugin.mod.name});
                }
            }
        });
    };

    $scope.removeRequirement = function(requirement) {
        var index = $scope.mod.requirements.indexOf(requirement);
        $scope.mod.requirements.splice(index, 1);
    };

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

    $scope.getRequirementsFromAnalysis = function() {
        // build list of masters
        var masters = [];
        var defaultPlugins = [];
        $scope.mod.analysis.mod_options.forEach(function(option) {
            if (option.default) defaultPlugins = defaultPlugins.concat(option.plugins);
        });
        defaultPlugins.forEach(function(plugin) {
            plugin.master_plugins.forEach(function(master) {
                if (masters.indexOf(master.filename) == -1) {
                    masters.push(master.filename);
                }
            });
        });
        // load requirements from masters
        masters.forEach(function(filename) {
            $scope.addRequirementFromPlugin(filename);
        });
    };

    $scope.loadAnalysisFile = function(file) {
        var fileReader = new FileReader();
        var jsonMap = {
            plugin_record_groups: 'plugin_record_groups_attributes',
            plugin_errors: 'plugin_errors_attributes',
            overrides: 'overrides_attributes'
        };
        fileReader.onload = function (event) {
            var fixedJson = objectUtils.remapProperties(event.target.result, jsonMap);
            var analysis = JSON.parse(fixedJson);
            analysis.mod_options.forEach(function(option) {
                option.nestedAssets = assetUtils.getNestedAssets(option.assets);
            });
            $scope.mod.analysis = analysis;
            $scope.getRequirementsFromAnalysis();
            $scope.$apply();
        };
        fileReader.readAsText(file);
    };

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
