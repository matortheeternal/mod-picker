app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.mod', {
        templateUrl: '/resources/partials/mod/mod.html',
        controller: 'modController',
        url: '/mod/:modId',
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
            sdir: 'desc',
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
            sdir: 'desc',
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
            sdir: 'desc',
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
            sdir: 'desc',
            filter: true,
            loadOrderNoteId: null
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
        url: '/analysis?{plugin:int}'
    });
}]);

app.controller('modController', function($scope, $rootScope, $q, $stateParams, $state, $timeout, modObject, modService, modListService, contributionService, categoryService, tagService, smoothScroll, errorService, tabsFactory, sortFactory) {
    // get parent variables
    $scope.mod = modObject.mod;
    $scope.mod.star = modObject.star;
    $scope.currentUser = $rootScope.currentUser;
    $scope.activeModList = $rootScope.activeModList;
    if ($scope.activeModList) {
        $scope.mod.in_mod_list = $scope.activeModList.mod_list_mod_ids.find(function(modId) {
            return modId == $scope.mod.id;
        });
    }

    // initialize local variables
    $scope.tabs = tabsFactory.buildModTabs($scope.mod);
    $scope.tags = [];
    $scope.newTags = [];
    $scope.statusModal = {};
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
        load_order_notes: {}
    };
    $scope.sort = {
        reviews: {},
        compatibility_notes: {},
        install_order_notes: {},
        load_order_notes: {}
    };
    $scope.sortOptions = {
        reviews: sortFactory.reviewSortOptions(),
        compatibility_notes: sortFactory.compatibilityNoteSortOptions(),
        install_order_notes: sortFactory.installOrderNoteSortOptions(),
        load_order_notes: sortFactory.loadOrderNoteSortOptions()
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
    $scope.retrieving = {};
    // error handling
    $scope.errors = {};

    //a copy is created so the original permissions are never changed
    $scope.permissions = angular.copy($rootScope.permissions);
    //setting up the canManage permission
    var author = $scope.mod.author_users.find(function(author) {
        return author.id == $scope.currentUser.id;
    });
    var isAuthor = angular.isDefined(author);
    $scope.permissions.canManage = $scope.permissions.canModerate || isAuthor;

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
        toStateNameArray = toState.name.split(".");
        if (toStateNameArray[1] === "mod") {
            //if changing to a tab that isn't in tabs[]
            if (!tabIsPresent(currentTab())) {
                redirectToFirstTab();
            }
        }
    });

    // display error messages
    $scope.$on('errorMessage', function(event, params) {
        var errors = errorService.errorMessages(params.label, params.response, $scope.mod.id);
        errors.forEach(function(error) {
            $scope.$broadcast('message', error);
        });
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    // display success message
    $scope.$on('successMessage', function(event, text) {
        var successMessage = { type: "success", text: text };
        $scope.$broadcast('message', successMessage);
        // stop event propagation - we handled it
        event.stopPropagation();
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

    // HEADER RELATED LOGIC
    $scope.starMod = function() {
        modService.starMod($scope.mod.id, $scope.mod.star).then(function() {
            $scope.mod.star = !$scope.mod.star;
        }, function(response) {
            var params = { label: 'Error starring mod', response: response };
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

    $scope.toggleStatusModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.statusModal.visible = visible;
        if (visible && !$scope.mod.corrections && !$scope.retrieving.appeals) {
            $scope.retrieveAppeals();
        }
    };

    $scope.getAppealStatus = function() {
        var openAppeals = $scope.mod.corrections.filter(function(correction) {
            return !correction.hidden && (correction.status == "open");
        });
        $scope.appealStatus = $scope.permissions.canAppeal && openAppeals.length < 2;
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
