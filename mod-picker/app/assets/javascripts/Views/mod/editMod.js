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

app.controller('editModController', function($scope, $rootScope, $state, modObject, modService, userService, tagService, categoryService, sitesFactory, eventHandlerFactory, objectUtils) {
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

    // shared function setup
    eventHandlerFactory.buildMessageHandlers($scope);

    // set up the canManageOptions permission
    var author = $scope.mod.mod_authors.find(function(author) {
        return author.user_id == $scope.currentUser.id;
    });
    var isAuthor = author && author.role == 'author';
    var isContributor = author && author.role == 'contributor';
    $scope.permissions.canManageOptions = $scope.permissions.canModerate || isAuthor ||
        !$scope.mod.disallow_contributors && isContributor;

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
        // main source validation
        var sourcesValid = true;
        var oldSources = false;
        $scope.sources.forEach(function(source) {
            sourcesValid = sourcesValid && source.valid;
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

        // Validate authors
        var authorsValid = true;
        $scope.mod.mod_authors.forEach(function(modAuthor) {
            authorsValid = authorsValid && modAuthor.user.id;
        });

        // Validate requirements
        var requirementsValid = true;
        $scope.mod.requirements.forEach(function(requirement) {
            requirementsValid = requirementsValid && requirement.required_id;
        });

        // Validate config files
        var configsValid = true;
        $scope.mod.config_files.forEach(function(configFile) {
            configsValid = configsValid && configFile.filename.length && configFile.install_path.length && configFile.text_body.length;
        });

        // validate categories
        var categoriesValid = $scope.mod.categories.length <= 2 && $scope.mod.is_official || $scope.mod.categories.length;

        // return result of all validations
        return (sourcesValid && categoriesValid)
    };

    // save changes
    $scope.updateMod = function() {
        // return if mod is invalid
        if (!$scope.modValid()) return;

        // get changed mod fields
        var modDiff = objectUtils.getDifferentObjectValues($scope.originalMod, $scope.mod);

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
        $scope.submittingStatus = "Updating Mod...";
        modDiff.id = $scope.mod.id;
        modService.updateMod(modDiff, sources, $scope.customSources).then(function() {
            if (!angular.isDefined($scope.success)) {
                $scope.success = true;
                if (!$scope.image.file) {
                    $scope.submittingStatus = "Mod Updated Successfully!";
                }
            } else if ($scope.success) {
                $scope.submittingStatus = "Mod Updated Successfully!";
            }
        }, function(response) {
            $scope.success = false;
            $scope.submittingStatus = "There were errors updating the mod.";
            // TODO: Emit errors properly
            $scope.errors = response.data;
        });
        if ($scope.image.file) {
            modService.submitImage($scope.mod.id, $scope.image.file).then(function () {
                if (!angular.isDefined($scope.success)) {
                    $scope.success = true;
                } else if ($scope.success) {
                    $scope.submittingStatus = "Mod Updated Successfully!";
                }
            }, function(response) {
                $scope.success = false;
                $scope.submittingStatus = "There were errors updating the mod.";
                // TODO: Emit errors properly
                $scope.errors = response.data;
            });
        }
    };

    $scope.closeModal = function() {
        delete $scope.success;
        delete $scope.submitting;
        delete $scope.errors;
    };
});