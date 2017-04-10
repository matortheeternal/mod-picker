// redirects for the old url format of /mod/:modId
app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.old-mod', {
        url: '/mod/:modId',
        redirectTo: 'base.mod'
    }).state('base.old-mod.Details', {
        url: '/details',
        redirectTo: 'base.mod.Details'
    }).state('base.old-mod.Reviews', {
        url: '/reviews/{reviewId:int}?{page:int}&scol&sdir',
        redirectTo: 'base.mod.Reviews'
    }).state('base.old-mod.Compatibility', {
        url: '/compatibility/{compatibilityNoteId:int}?{page:int}&scol&sdir&{filter:bool}',
        redirectTo: 'base.mod.Compatibility'
    }).state('base.old-mod.Install Order', {
        url: '/install-order/{installOrderNoteId:int}?{page:int}&scol&sdir&{filter:bool}',
        redirectTo: 'base.mod.Install Order'
    }).state('base.old-mod.Load Order', {
        url: '/load-order/{loadOrderNoteId:int}?{page:int}&scol&sdir&{filter:bool}',
        redirectTo: 'base.mod.Load Order'
    }).state('base.old-mod.Related', {
        url: '/related',
        redirectTo: 'base.mod.Related'
    }).state('base.old-mod.Analysis', {
        url: '/analysis?options&{plugin:int}',
        redirectTo: 'base.mod.Analysis'
    });
}]);

app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.mod', {
        templateUrl: '/resources/partials/mod/mod.html',
        controller: 'modController',
        url: '/mods/{modId:int}',
        resolve: {
            modObject: function($stateParams, $q, categories, licenses, modService, categoryService, licenseService) {
                var mod = $q.defer();
                modService.retrieveMod($stateParams.modId).then(function(data) {
                    licenseService.resolveModLicenses(licenses, data.mod);
                    categoryService.resolveModCategories(categories, data.mod);
                    mod.resolve(data);
                }, function(response) {
                    var errorObj = {
                        text: 'Error retrieving mod.',
                        response: response,
                        stateName: "base.mod",
                        stateUrl: window.location.href
                    };
                    mod.reject(errorObj);
                });
                return mod.promise;
            }
        }
    }).state('base.mod.Details', {
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Details': {
                templateUrl: '/resources/partials/mod/modDetails.html'
            }
        },
        url: '/details'
    }).state('base.mod.Reviews', {
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Reviews': {
                templateUrl: '/resources/partials/mod/modReviews.html',
                controller: 'modReviewsController'
            }
        },
        url: '/reviews/{reviewId:int}?{page:int}&scol&sdir',
        params: {
            page: 1,
            scol: 'reputation',
            sdir: 'DESC',
            reviewId: null
        }
    }).state('base.mod.Compatibility', {
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Compatibility': {
                templateUrl: '/resources/partials/mod/modCompatibility.html',
                controller: 'modCompatibilityController'
            }
        },
        url: '/compatibility/{compatibilityNoteId:int}?{page:int}&scol&sdir&{filter:bool}',
        params: {
            page: 1,
            scol: 'reputation',
            sdir: 'DESC',
            filter: true,
            compatibilityNoteId: null
        }
    }).state('base.mod.Install Order', {
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Install Order': {
                templateUrl: '/resources/partials/mod/modInstallOrder.html',
                controller: 'modInstallOrderController'
            }
        },
        url: '/install-order/{installOrderNoteId:int}?{page:int}&scol&sdir&{filter:bool}',
        params: {
            page: 1,
            scol: 'reputation',
            sdir: 'DESC',
            filter: true,
            installOrderNoteId: null
        }
    }).state('base.mod.Load Order', {
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Load Order': {
                templateUrl: '/resources/partials/mod/modLoadOrder.html',
                controller: 'modLoadOrderController'
            }
        },
        url: '/load-order/{loadOrderNoteId:int}?{page:int}&scol&sdir&{filter:bool}',
        params: {
            page: 1,
            scol: 'reputation',
            sdir: 'DESC',
            filter: true,
            loadOrderNoteId: null
        }
    }).state('base.mod.Related', {
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Related': {
                templateUrl: '/resources/partials/mod/modRelatedMods.html',
                controller: 'modRelatedModsController'
            }
        },
        url: '/related/{relatedModNoteId:int}?{page:int}&scol&sdir&{filter:bool}',
        params: {
            page: 1,
            scol: 'reputation',
            sdir: 'DESC',
            filter: true,
            relatedModNoteId: null
        }
    }).state('base.mod.Analysis', {
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Analysis': {
                templateUrl: '/resources/partials/mod/modAnalysis.html',
                controller: 'modAnalysisController'
            }
        },
        url: '/analysis?options&{plugin:int}'
    });
}]);

app.controller('modController', function($scope, $rootScope, $q, $stateParams, $state, $timeout, $window, modObject, modService, modListService, contributionService, categoryService, tagService, smoothScroll, helpFactory, tabsFactory, sortFactory, eventHandlerFactory, tabUtils) {
    // get parent variables
    $scope.mod = modObject.mod;
    $scope.mod.star = modObject.star;
    $scope.mod.in_mod_list = modObject.in_mod_list;
    $scope.mod.incompatible = modObject.incompatible;

    // inherited variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.activeModList = $rootScope.activeModList;
    $scope.permissions = angular.copy($rootScope.permissions);

    // initialize local variables
    $scope.tabs = tabsFactory.buildModTabs($scope.mod);
    $scope.tags = [];
    $scope.newTags = [];
    $scope.statusClasses = {
        unstable: 'red-box',
        outdated: 'yellow-box',
        good: 'green-box'
    };
    $scope.pages = {
        appeal_comments: {},
        reviews: {},
        compatibility_notes: {},
        install_order_notes: {},
        load_order_notes: {},
        related_mod_notes: {}
    };
    $scope.sort = {
        reviews: {},
        compatibility_notes: {},
        install_order_notes: {},
        load_order_notes: {},
        related_mod_notes: {}
    };
    $scope.sortOptions = {
        reviews: sortFactory.reviewSortOptions(),
        compatibility_notes: sortFactory.compatibilityNoteSortOptions(),
        install_order_notes: sortFactory.installOrderNoteSortOptions(),
        load_order_notes: sortFactory.loadOrderNoteSortOptions(),
        related_mod_notes: sortFactory.relatedModNoteSortOptions()
    };
    $scope.filters = {
        compatibility_notes: {
            mod_list: true
        },
        install_order_notes: {
            mod_list: true
        },
        load_order_notes: {
            mod_list: true
        }
    };
    $scope.report = {
        reportable_id: $scope.mod.id,
        reportable_type: 'Mod'
    };
    $scope.modelObj = {
        name: "Mod",
        label: "Mod",
        route: "mods"
    };
    $scope.target = $scope.mod;
    $scope.retrieving = {};
    $scope.errors = {};

    // set page title
    $scope.$emit('setPageTitle', $scope.mod.name);

    // shared function setup
    eventHandlerFactory.buildMessageHandlers($scope);
    tabUtils.buildTabHelpers($scope, $state, 'mod', true);

    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.mod]);

    // display a message if the mod is incompatible with the user's active mod list
    if ($scope.mod.incompatible) {
        $timeout(function() {
            $scope.$broadcast('message', {
                type: 'error',
                text: 'This mod is incompatible with your active mod list.',
                decay: 600000 // 10 minutes
            });
        }, 200);
    }

    // display a message if the mod author set a notice
    if ($scope.mod.notice) {
        $timeout(function() {
            $scope.$broadcast('message', {
                type: $scope.mod.notice_type,
                text: $scope.mod.notice,
                decay: 600000 // 10 minutes
            });
        }, 250);
    }

    //setting up the canManage permission
    var author = $scope.mod.mod_authors.find(function(author) {
        return author.user_id == $scope.currentUser.id;
    });
    var isAuthor = angular.isDefined(author);
    var isCurator = isAuthor && (author.role === 'curator');
    $scope.permissions.isAuthor = isAuthor;
    $scope.permissions.canManage = $scope.permissions.canManageMods || isAuthor;
    $scope.permissions.canReview = $scope.permissions.canContribute && (isCurator || !isAuthor);

    // update the markdown editor
    $scope.updateEditor = function(noScroll) {
        if (!noScroll) {
            $timeout(function() {
                var elements = document.getElementsByClassName("add-note-box");
                for (var i = 0; i < elements.length; i++) {
                    var editorBox = elements[i];
                    if (!editorBox.classList.contains('ng-hide')) {
                        smoothScroll(editorBox, {
                            offset: 20
                        });
                        break;
                    }
                }
            });
        }
        $scope.updateMDE = ($scope.updateMDE || 0) + 1;
    };

    $scope.retrieveAppeals = function() {
        $scope.retrieving.appeals = true;
        contributionService.retrieveCorrections('mods', $stateParams.modId).then(function(data) {
            $scope.retrieving.appeals = false;
            $scope.mod.corrections = data;
            $scope.getAppealStatus();
        }, function(response) {
            $scope.errors.appeals = response;
        });
    };

    // HEADER
    $scope.approveMod = function() {
        modService.approveMod($scope.mod.id, true).then(function() {
            $scope.mod.approved = true;
            $scope.$emit('successMessage', 'Mod approved successfully');
        }, function(response) {
            var params = { label: 'Error approving mod', response: response };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.toggleAuthorsModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showAuthorsModal = visible;
    };

    $scope.toggleStatusModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showStatusModal = visible;
        if (visible && !$scope.mod.corrections && !$scope.retrieving.appeals) {
            $scope.retrieveAppeals();
        }
    };

    $scope.toggleReportModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showReportModal = visible;
    };

    $scope.editMod = function() {
        $state.go('base.edit-mod', { modId: $scope.mod.id });
    };

    $scope.starMod = function() {
        modService.starMod($scope.mod.id, $scope.mod.star).then(function() {
            $scope.mod.star = !$scope.mod.star;
        }, function(response) {
            var params = { label: 'Error starring mod', response: response };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.unHideMod = function() {
        modService.hideMod($scope.mod.id, false).then(function() {
            $scope.mod.hidden = false;
            $scope.$emit('successMessage', 'Mod unhidden successfully.');
        }, function(response) {
            var params = { label: 'Error unhiding mod', response: response };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.toggleModOptionsModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showModOptionsModal = visible;
    };

    $scope.setupModOptionsModal = function() {
        $scope.activeMod = $scope.mod;
        $scope.activeModOptions = null;
        modService.retrieveModOptions($scope.mod.id).then(function(modOptions) {
            modOptions.forEach(function(modOption) {
                modOption.enabled = modOption.default;
            });
            $scope.activeModOptions = modOptions;
        }, function(response) {
            $scope.modOptionsError = response;
        });
    };

    $scope.modOptionsModalAdd = function() {
        var modOptionIds = $scope.activeModOptions.filter(function(modOption) {
            return modOption.enabled;
        }).map(function(modOption) {
            return modOption.id;
        });
        $scope.addMod(modOptionIds);
        $scope.toggleModOptionsModal(false);
    };

    $scope.removeFromModList = function() {
        modListService.removeModListMod($scope.activeModList, $scope.mod).then(function() {
            $scope.$emit('successMessage', 'Mod removed from your mod list successfully.');
        }, function(response) {
            var params = {
                label: 'Error removing mod from your mod list',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.addToModList = function() {
        if ($scope.mod.mod_options_count > 1) {
            $scope.setupModOptionsModal();
            $scope.toggleModOptionsModal(true);
        } else {
            $scope.addMod();
        }
    };

    $scope.addMod = function(modOptionIds) {
        modListService.addModListMod($scope.activeModList, $scope.mod, modOptionIds).then(function() {
            $scope.$emit('successMessage', 'Mod added to your mod list successfully.');
        }, function(response) {
            var params = {
                label: 'Error adding mod to your mod list',
                response: response
            };
            $scope.$emit('errorMessage', params);
        });
    };

    $scope.toggleInModList = function() {
        $scope.mod.in_mod_list ? $scope.removeFromModList() : $scope.addToModList();
    };

    $scope.getAppealStatus = function() {
        var openAppeals = $scope.mod.corrections.filter(function(correction) {
            return !correction.hidden && (correction.status == "open");
        });
        $scope.appealStatus = $scope.permissions.canAppeal && openAppeals.length < 2;
    };

    // LEFT COLUMN
    $scope.toggleRequirementsModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showRequirementsModal = visible;
    };

    $scope.saveTags = function(updatedTags) {
        var action = $q.defer();
        tagService.updateModTags($scope.mod, updatedTags).then(function(data) {
            $scope.$emit('successMessage', 'Tags updated successfully.');
            action.resolve(data);
        }, function(response) {
            var params = { label: 'Error saving mod tags', response: response };
            $scope.$emit('errorMessage', params);
            action.reject(response);
        });
        return action.promise;
    };
});
