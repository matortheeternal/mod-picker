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
                        stateUrl: window.location.href
                    };
                    mod.reject(errorObj);
                });
                return mod.promise;
            }
        }
    });
}]);

app.controller('editModController', function($scope, $rootScope, $state, modObject, modService, modLoaderService, modValidationService, userService, tagService, categoryService, helpFactory, sitesFactory, eventHandlerFactory, objectUtils) {
    // get parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.categories = $rootScope.categories;
    $scope.categoryPriorities = $rootScope.categoryPriorities;
    $scope.permissions = angular.copy($rootScope.permissions);

    // inherited functions
    $scope.searchMods = modService.searchMods;
    $scope.searchUsers = userService.searchUsers;

    // initialize local variables
    $scope.mod = angular.copy(modObject);
    modLoaderService.loadMod($scope.mod);
    $scope.originalMod = angular.copy($scope.mod);
    $scope.sites = sitesFactory.sites();
    $scope.image = {
        sizes: [
            { label: "big", src: $scope.mod.images.big }
        ]
    };
    $scope.imageSizes = [
        { label: "big",     size: 300 },
        { label: 'medium',  size: 210 },
        { label: 'small',   size: 100 }
    ];
    $scope.analysisValid = true;

    // set page title
    $scope.$emit('setPageTitle', 'Edit Mod');

    // shared function setup
    eventHandlerFactory.buildMessageHandlers($scope, true);

    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.editMod]);

    // set up the canManageOptions permission
    var author = $scope.mod.mod_authors.find(function(author) {
        return author.user_id == $scope.currentUser.id;
    });
    var isAuthor = author && author.role == 'author';
    $scope.canManageOptions = $scope.permissions.canModerate || isAuthor;
    $scope.canChangeStatus = (isAuthor && $scope.mod.status == "good") || $scope.permissions.isAdmin;

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
        $scope.sourcesValid = modValidationService.sourcesValid($scope.mod);
        $scope.authorsValid = modValidationService.authorsValid($scope.mod.mod_authors);
        $scope.requirementsValid = modValidationService.requirementsValid($scope.mod.requirements);
        $scope.configsValid = modValidationService.configsValid($scope.mod.config_files);
        $scope.categoriesValid = modValidationService.categoriesValid($scope.mod);

        // return result of all validations
        return $scope.sourcesValid && $scope.authorsValid && $scope.requirementsValid && $scope.configsValid && $scope.categoriesValid;
    };

    $scope.buildSource = function(scrapeLabel, infoLabel) {
        if (!infoLabel) infoLabel = scrapeLabel;
        if ($scope[scrapeLabel]) {
            $scope.mod[infoLabel + '_info_id'] = $scope[scrapeLabel].id;
        }
    };

    $scope.buildSources = function() {
        $scope.buildSource('nexus');
        $scope.buildSource('workshop');
        $scope.buildSource('lab', 'lover');
    };

    // save changes
    $scope.saveChanges = function() {
        // return if mod is invalid
        if (!$scope.modValid()) return;

        // get changed mod fields
        modValidationService.sanitizeSet($scope.mod.requirements);
        modValidationService.sanitizeSet($scope.mod.mod_authors);
        $scope.buildSources();
        var modDiff = modService.getDifferentModValues($scope.originalMod, $scope.mod);
        var modUnchanged = objectUtils.isEmptyObject(modDiff.mod);
        var imageUnchanged = !$scope.image.changed;

        // return if there is nothing to change
        if (modUnchanged && imageUnchanged) {
            var params = { type: 'warning', text: 'No changes to save.' };
            $scope.$emit('customMessage', params);
            return;
        }

        // prepare for submission
        $scope.imageSuccess = imageUnchanged;
        $scope.modSuccess = modUnchanged;
        $scope.startSubmission("Updating Mod...");

        // update the mod
        if (!modUnchanged) {
            $scope.updateMod(modDiff);
        }
        if (!imageUnchanged) {
            $scope.submitImage();
        }
    };

    $scope.submitImage = function() {
        modService.submitImage($scope.mod.id, $scope.image.sizes).then(function() {
            $scope.imageSuccess = true;
            $scope.displaySuccess();
        }, function(response) {
            $scope.submissionError("There were errors updating the mod image.", response);
        });
    };

    $scope.updateMod = function(modData) {
        modService.updateMod($scope.mod.id, modData).then(function() {
            $scope.modSuccess = true;
            $scope.displaySuccess();
            $scope.originalMod = angular.copy($scope.mod);
        }, function(response) {
            $scope.submissionError("There were errors updating the mod.", response);
        });
    };

    $scope.displaySuccess = function() {
        if ($scope.imageSuccess && $scope.modSuccess) {
            $scope.submissionSuccess("Mod updated successfully!", [
                { 
                    link: "mod/" + $scope.mod.id,
                    linkLabel: "return to the mod page."
                },
                {
                    link: "mods",
                    linkLabel: "return to the mods index page." 
                }
            ]);
        }
    };
});