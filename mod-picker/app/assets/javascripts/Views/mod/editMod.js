app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.edit-mod', {
        templateUrl: '/resources/partials/mod/editMod.html',
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
                        stateName: "base.edit-mod",
                        stateUrl: window.location.hash
                    };
                    mod.reject(errorObj);
                });
                return mod.promise;
            }
        }
    });
}]);

app.controller('editModController', function($scope, $rootScope, $state, modObject, modService, modValidationService, userService, tagService, categoryService, sitesFactory, eventHandlerFactory, objectUtils) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.categories = $rootScope.categories;
    $scope.categoryPriorities = $rootScope.categoryPriorities;
    $scope.permissions = angular.copy($rootScope.permissions);

    // inherited functions
    $scope.searchMods = modService.searchMods;
    $scope.searchUsers = userService.searchUsers;

    // loads the mod object onto the view
    $scope.loadModObject = function() {
        // load sources into scope
        $scope.sources = [];
        if (modObject.nexus_infos) {
            $scope.sources.push({
                label: "Nexus Mods",
                url: sitesFactory.getModUrl("Nexus Mods", modObject.nexus_infos.id),
                valid: true,
                old: true,
                scraped: true
            });
        }
        if (modObject.lover_infos) {
            $scope.sources.push({
                label: "Lover's Lab",
                url: sitesFactory.getModUrl("Lover's Lab", modObject.lover_infos.id),
                valid: true,
                old: true,
                scraped: true
            });
        }
        if (modObject.workshop_infos) {
            $scope.sources.push({
                label: "Steam Workshop",
                url: sitesFactory.getModUrl("Steam Workshop", modObject.workshop_infos.id),
                valid: true,
                old: true,
                scraped: true
            });
        }
        // load custom sources into scope
        $scope.customSources = [];
        modObject.custom_sources.forEach(function(source) {
            source.valid = true;
            $scope.customSources.push(source);
        });
        // parse dates to date objects
        modObject.released = new Date(Date.parse(modObject.released));
        if (modObject.updated) {
            modObject.updated = new Date(Date.parse(modObject.updated));
        }
        // convert required mods into correct format
        modObject.requirements = [];
        modObject.required_mods.forEach(function(requirement) {
            modObject.requirements.push({
                id: requirement.id,
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
        // prepare newTags array
        modObject.newTags = [];
        // put mod on scope
        $scope.originalMod = modObject;
        $scope.mod = angular.copy(modObject);
    };

    // initialize local variables
    $scope.loadModObject();
    $scope.sites = sitesFactory.sites();
    $scope.image = {
        src: $scope.mod.image
    };
    $scope.analysisValid = true;

    // shared function setup
    eventHandlerFactory.buildMessageHandlers($scope, true);

    // set up the canManageOptions permission
    var author = $scope.mod.mod_authors.find(function(author) {
        return author.user_id == $scope.currentUser.id;
    });
    var isAuthor = author && author.role == 'author';
    $scope.permissions.canManageOptions = $scope.permissions.canModerate || isAuthor;

    $scope.$watch('mod.categories', function() {
        // clear messages when user changes the category
        if ($scope.categoryMessages && $scope.categoryMessages.length) {
            if ($scope.categoryMessages[0].klass == "cat-error-message" ||
                $scope.categoryMessages[0].klass == "cat-success-message") {
                $scope.categoryMessages = [];
            }
        }
        // set primary_category_id and secondary_category_id
        $scope.mod.primary_category_id = $scope.mod.categories[0];
        $scope.mod.secondary_category_id = $scope.mod.categories[1];
    }, true);

    // validate the mod
    $scope.modValid = function() {
        $scope.sourcesValid = modValidationService.sourcesValid($scope);
        $scope.authorsValid = modValidationService.authorsValid($scope.mod.mod_authors);
        $scope.requirementsValid = modValidationService.requirementsValid($scope.mod.requirements);
        $scope.configsValid = modValidationService.configsValid($scope.mod.config_files);
        $scope.categoriesValid = modValidationService.categoriesValid($scope.mod);

        // return result of all validations
        return $scope.sourcesValid && $scope.authorsValid && $scope.requirementsValid && $scope.configsValid && $scope.categoriesValid;
    };

    $scope.buildSources = function() {
        return {
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
    };

    // save changes
    $scope.saveChanges = function() {
        // return if mod is invalid
        if (!$scope.modValid()) return;

        // get changed mod fields
        modValidationService.sanitizeSet($scope.mod.requirements);
        modValidationService.sanitizeSet($scope.mod.mod_authors);
        var sources = $scope.buildSources();
        var modDiff = objectUtils.getDifferentObjectValues($scope.originalMod, $scope.mod);
        modDiff.id = $scope.mod.id;
        var modData = modService.getModUpdateData(modDiff, sources, $scope.customSources);
        var modDataUnchanged = objectUtils.keysCount(modData.mod) == 1;
        var imageUnchanged = !$scope.image.file;

        // return if there is nothing to change
        if (modDataUnchanged && imageUnchanged) {
            var params = { type: 'warning', text: 'No changes to save.' };
            $scope.$emit('customMessage', params);
            return;
        }

        // prepare for submission
        $scope.imageSuccess = imageUnchanged;
        $scope.modSuccess = modDataUnchanged;
        $scope.startSubmission("Updating Mod...");

        // update the mod
        if (modData) $scope.updateMod(modData);
        if ($scope.image.file) $scope.submitImage();
    };

    $scope.submitImage = function() {
        modService.submitImage($scope.mod.id, $scope.image.file).then(function() {
            $scope.imageSuccess = true;
            $scope.displaySuccess();
        }, function(response) {
            $scope.submissionError("There were errors updating the mod image.", response);
        });
    };

    $scope.updateMod = function(modData) {
        modService.updateMod(modData).then(function() {
            $scope.modSuccess = true;
            $scope.displaySuccess();
            $scope.originalMod = angular.copy($scope.mod);
        }, function(response) {
            $scope.submissionError("There were errors updating the mod.", response);
        });
    };

    $scope.displaySuccess = function() {
        if ($scope.imageSuccess && $scope.modSuccess) {
            $scope.submissionSuccess("Mod updated successfully!", "#/mod/"+$scope.mod.id,
                "return to the mod page.");
        }
    };
});