// redirects for the old url format of /mod/:modId
app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.old-mod', {
        url: '/mod/:modId',
        redirectTo: 'base.mod'
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
    }).state('base.old-mod.Analysis', {
        url: '/analysis?options&{plugin:int}',
        redirectTo: 'base.mod.Analysis'
    });
}]);

app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.mod', {
        templateUrl: '/resources/partials/mod/mod.html',
        controller: 'modController',
        url: '/mods/:modId',
        resolve: {
            modObject: function($stateParams, $q, categories, modService, categoryService) {
                var mod = $q.defer();
                modService.retrieveMod($stateParams.modId).then(function(data) {
                    categoryService.resolveModCategories(categories, data.mod);
                    mod.resolve(data);
                }, function(response) {
                    var errorObj = {
                        text: 'Error retrieving mod.',
                        response: response,
                        stateName: "base.mod",
                        stateUrl: window.location.hash
                    };
                    mod.reject(errorObj);
                });
                return mod.promise;
            }
        }
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
    }).state('base.mod.Related Mods', {
        sticky: true,
        deepStateRedirect: true,
        reloadOnSearch: false,
        views: {
            'Related Mods': {
                templateUrl: '/resources/partials/mod/modRelatedMods.html',
                controller: 'modRelatedModsController'
            }
        },
        url: '/related-mods/{relatedModNoteId:int}?{page:int}&scol&sdir&{filter:bool}',
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

app.controller('modController', function($scope, $rootScope, $q, $stateParams, $state, $timeout, $window, modObject, modService, modListService, contributionService, categoryService, tagService, smoothScroll, helpFactory, tabsFactory, sortFactory, eventHandlerFactory) {
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

    //setting up the canManage permission
    var author = $scope.mod.mod_authors.find(function(author) {
        return author.user_id == $scope.currentUser.id;
    });
    var isAuthor = angular.isDefined(author);
    var isCurator = isAuthor && (author.role === 'curator');
    $scope.permissions.isAuthor = isAuthor;
    $scope.permissions.canManage = $scope.permissions.canManageMods || isAuthor;
    $scope.permissions.canReview = $scope.permissions.canContribute && (isCurator || !isAuthor);

    var redirectToFirstTab = function() {
        var tab = $scope.tabs[0];
        $state.go('base.mod.' + tab.name, tab.params, { location: 'replace' });
    };

    var tabIsPresent = function(tabName) {
        var tabIndex = $scope.tabs.findIndex(function(tab) {
            return tabName === tab.name;
        });
        return (tabIndex !== -1);
    };

    var currentTab = function() {
        var currentState = $state.current.name;
        var currentStateArray = currentState.split(".");
        return currentStateArray[currentStateArray.length - 1];
    };

    //redirect to the first tab if changing to a non-present tab
    $scope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState, fromParams) {
        //if changing to the mod state
        var toStateNameArray = toState.name.split(".");
        if (toStateNameArray[1] === "mod") {
            //if changing to a tab that isn't in tabs[]
            if (!tabIsPresent(currentTab())) {
                redirectToFirstTab();
            }
        }
    });

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
        $window.location.hash = 'mod/' + $scope.mod.id + '/edit';
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

    $scope.toggleInModList = function() {
        if ($scope.mod.in_mod_list) {
            // remove from mod list
            modListService.removeModListMod($scope.activeModList, $scope.mod).then(function() {
                $scope.$emit('successMessage', 'Mod removed from your mod list successfully.');
            }, function(response) {
                var params = {
                    label: 'Error removing mod from your mod list',
                    response: response
                };
                $scope.$emit('errorMessage', params);
            });
        } else {
            modListService.addModListMod($scope.activeModList, $scope.mod).then(function() {
                $scope.$emit('successMessage', 'Mod added to your mod list successfully.');
            }, function(response) {
                var params = {
                    label: 'Error adding mod to your mod list',
                    response: response
                };
                $scope.$emit('errorMessage', params);
            });
        }
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
