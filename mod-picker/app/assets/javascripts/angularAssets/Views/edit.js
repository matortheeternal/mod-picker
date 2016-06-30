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

app.controller('editModController', function($scope, $state, currentUser, modObject, modService, tagService, categoryService, errorService) {
    // get parent variables
    $scope.currentUser = currentUser;

    /* load the mod object onto the view */
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
    // put mod on scope
    $scope.mod = modObject;

    // initialize local variables
    $scope.permissions = angular.copy(currentUser.permissions);
    $scope.newTags = [];
    $scope.image = {
        src: $scope.mod.image
    };
    // error handling
    $scope.errors = {};

    // display error messages
    $scope.$on('errorMessage', function(event, params) {
        var errors = errorService.errorMessages(params.label, params.response);
        errors.forEach(function(error) {
            $scope.$broadcast('message', error);
        });
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

    /* mod image */
    $scope.browseImage = function() {
        document.getElementById('image-input').click();
    };

    $scope.resetImage = function() {
        $scope.image.file = null;
        $scope.image.src = $scope.mod.image;
        $scope.$apply();
    };

    $scope.changeImage = function(event) {
        var errorObj;
        if (event.target.files && event.target.files[0]) {
            var imageFile = event.target.files[0];

            // check file type
            var ext = fileUtils.getFileExtension(imageFile.name);
            if ((ext !== 'png') && (ext !== 'jpg')) {
                errorObj = {
                    type: "error",
                    message: "Unsupported file type.  Mod image must be a PNG or JPG file."
                };
                $scope.$broadcast("message", errorObj);
                $scope.resetAvatar();
                return;
            }

            // check filesize
            if (imageFile.size > 1048576) {
                errorObj = {
                    type: "error",
                    message: "Mod image is too big.  Maximum file size 1.0MB."
                };
                $scope.$broadcast("message", errorObj);
                $scope.resetAvatar();
                return;
            }

            // check dimensions
            var img = new Image();
            img.onload = function() {
                var imageTooBig = (img.width > 300) || (img.height > 300);
                if (imageTooBig) {
                    errorObj = {
                        type: "error",
                        message: "Mod image too large.  Maximum dimensions 300x300."
                    };
                    $scope.$broadcast("message", errorObj);
                    $scope.resetAvatar();
                } else {
                    $scope.avatar.file = imageFile;
                    $scope.avatar.src = img.src;
                    $scope.$apply();
                }
            };
            img.src = URL.createObjectURL(imageFile);
        } else if ($scope.mod) {
            $scope.resetImage();
        }
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

    //$scope.saveTags = function(updatedTags) {
    //    var action = $q.defer();
    //    tagService.updateModTags($scope.mod, updatedTags).then(function(data) {
    //        $scope.$emit('successMessage', 'Tags updated successfully.');
    //        action.resolve(data);
    //    }, function(response) {
    //        var params = {label: 'Error saving mod tags', response: response};
    //        $scope.$emit('errorMessage', params);
    //        action.reject(response);
    //    });
    //    return action.promise;
    //};
});