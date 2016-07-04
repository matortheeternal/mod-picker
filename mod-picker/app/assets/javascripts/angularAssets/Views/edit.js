app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.edit', {
        templateUrl: '/resources/partials/showMod/edit.html',
        controller: 'editModController',
        url: '/mod/:modId/edit',
        resolve: {
            modObject: function(modService, $stateParams, $q) {
                var mod = $q.defer();
                modService.editMod($stateParams.modId).then(function(data) {
                    mod.resolve(data);
                }, function(response) {
                    var errorObj = {
                        text: 'Error editing mod.',
                        response: response,
                        stateName: "base.edit",
                        stateUrl: window.location.hash
                    };
                    mod.reject(errorObj);
                });
                return mod.promise;
            }
        }
    });
}]);

app.controller('editModController', function($scope, $state, currentUser, modObject, modService, tagService, categoryService, errorService, submitService, sitesFactory) {
    // get parent variables
    $scope.currentUser = currentUser;

    // loads the mod object onto the view
    $scope.loadModObject = function() {
        // parse dates to date objects
        modObject.released = new Date(Date.parse(modObject.released));
        if (modObject.updated) {
            modObject.updated = new Date(Date.parse(modObject.updated));
        }
        // convert required mods into correct format
        modObject.requirements = [];
        modObject.required_mods.forEach(function(requirement) {
            modObject.requirements.push({
                required_id: requirement.required_mod.id,
                name: requirement.required_mod.name
            })
        });
        // convert categories into correct format
        modObject.categories = [];
        if (modObject.primary_category_id) {
            modObject.categories.push(modObject.primary_category_id);
        }
        if (modObject.secondary_category_id) {
            modObject.categories.push(modObject.secondary_category_id);
        }
        // load sources into scope
        $scope.sources = [];
        if (modObject.nexus_infos) {
            $scope.sources.push({
                label: "Nexus Mods",
                url: sitesFactory.getModUrl("Nexus Mods", modObject.nexus_infos.id),
                scraped: true
            });
        }
        if (modObject.lover_infos) {
            $scope.sources.push({
                label: "Lover's Lab",
                url: sitesFactory.getModUrl("Lover's Lab", modObject.lover_infos.id),
                scraped: true
            });
        }
        if (modObject.workshop_infos) {
            $scope.sources.push({
                label: "Steam Workshop",
                url: sitesFactory.getModUrl("Steam Workshop", modObject.workshop_infos.id),
                scraped: true
            });
        }
        // load custom sources into scope
        $scope.customSources = modObject.custom_sources;
        // put mod on scope
        $scope.mod = modObject;
    };

    // initialize local variables
    $scope.loadModObject();
    $scope.sites = sitesFactory.sites();
    $scope.permissions = angular.copy(currentUser.permissions);
    $scope.newTags = [];
    $scope.image = {
        src: $scope.mod.image
    };
    // error handling
    $scope.errors = {};

    // display error messages
    $scope.$on('errorMessage', function(event, params) {
        if (params.label && params.response) {
            var errors = errorService.errorMessages(params.label, params.response);
            errors.forEach(function(error) {
                $scope.$broadcast('message', error);
            });
        } else {
            $scope.$broadcast('message', params);
        }
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    // display success message
    $scope.$on('successMessage', function(event, text) {
        var successMessage = {type: "success", text: text};
        $scope.$broadcast('message', successMessage);
        // stop event propagation - we handled it
        event.stopPropagation();
    });

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
        $scope.mod.analysis.plugins.forEach(function(plugin) {
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
        fileReader.onload = function (event) {
            var fixedJson = event.target.result.replace('"plugin_record_groups"', '"plugin_record_groups_attributes"').replace('"plugin_errors"', '"plugin_errors_attributes"').replace('"overrides"', '"overrides_attributes"');
            var analysis = JSON.parse(fixedJson);
            analysis.nestedAssets = assetUtils.convertDataStringToNestedObject(analysis.assets);
            $scope.mod.analysis = analysis;
            $scope.getRequirementsFromAnalysis();
            $scope.$apply();
        };
        fileReader.readAsText(file);
    };

    /* mod authors */
    $scope.addAuthor = function() {
        $scope.mod.mod_authors.push({
            role: "0",
            user: {}
        });
    };

    $scope.removeAuthor = function(author) {
        var index = $scope.mod.mod_authors.indexOf(author);
        $scope.mod.mod_authors.splice(index, 1);
    };

    /* requirements */
    $scope.addRequirement = function() {
        $scope.mod.requirements.push({});
    };

    $scope.removeRequirement = function(requirement) {
        var index = $scope.mod.requirements.indexOf(requirement);
        $scope.mod.requirements.splice(index, 1);
    };

    /* categories */
    categoryService.retrieveCategories().then(function(data) {
        $scope.categories = data;
    });

    categoryService.retrieveCategoryPriorities().then(function(data) {
        $scope.categoryPriorities = data;
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

    /* submission */
    // validate the mod
    $scope.modValid = function() {
        // main source validation
        var sourcesValid = true;
        var oldSources = false;
        $scope.sources.forEach(function(source) {
            sourcesValid = sourcesValid && (source.valid || source.old);
            oldSources = oldSources || source.old;
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
            sourcesValid = sourcesValid && ($scope.nexus || $scope.workshop || $scope.lab || oldSources);
        }

        // return true if any
        var categoriesValid = $scope.mod.categories && $scope.mod.categories.length &&
            $scope.mod.categories.length <= 2;
        return (sourcesValid && categoriesValid)
    };

    // save changes
    $scope.updateMod = function() {
        // return if mod is invalid
        if (!$scope.modValid()) {
            return;
        }

        // build sources object
        var sources = {
            nexus: $scope.nexus || $scope.sources.find(function(source) {
                return source.label === "Nexus Mods";
            }),
            workshop: $scope.workshop || $scope.sources.find(function(source) {
                return source.label === "Steam Workshop";
            }),
            lab: $scope.lab || $scope.sources.find(function(source) {
                return source.label === "Lover's Lab";
            })
        };

        $scope.submitting = true;
        $scope.submittingStatus = "Submitting Mod...";
        submitService.updateMod($scope.mod, $scope.image, sources, $scope.customSources).then(function() {
            $scope.submittingStatus = "Mod Submitted Successfully!";
            $scope.success = true;
        }, function(response) {
            $scope.submittingStatus = "There were errors submitting your mod.";
            $scope.errors = response.data;
        });
    };
});