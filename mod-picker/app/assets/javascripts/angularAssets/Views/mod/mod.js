app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.mod', {
        templateUrl: '/resources/partials/mod/mod.html',
        controller: 'modController',
        url: '/mod/:modId',
        redirectTo: 'base.mod.Reviews',
        resolve: {
            modObject: function(modService, $stateParams, $q) {
                var mod = $q.defer();
                modService.retrieveMod($stateParams.modId).then(function(data) {
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
        views: {
            'Reviews': {
                templateUrl: '/resources/partials/mod/reviews.html',
                controller: 'modReviewsController',
            }
        },
        url: '/reviews?{page:int}&scol&sdir',
        params: {
            page: 1,
            scol: 'reputation',
            sdir: 'desc'
        }
    }).state('base.mod.Compatibility', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Compatibility': {
                templateUrl: '/resources/partials/mod/compatibility.html',
                controller: 'modCompatibilityController',
            }
        },
        url: '/compatibility?{page:int}&scol&sdir&{filter:bool}',
        params: {
            page: 1,
            scol: 'reputation',
            sdir: 'desc',
            filter: true
        }
    }).state('base.mod.Install Order', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Install Order': {
                templateUrl: '/resources/partials/mod/installOrder.html',
                controller: 'modInstallOrderController',
            }
        },
        url: '/install-order?{page:int}&scol&sdir&{filter:bool}',
        params: {
            page: 1,
            scol: 'reputation',
            sdir: 'desc',
            filter: true
        }
    }).state('base.mod.Load Order', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Load Order': {
                templateUrl: '/resources/partials/mod/loadOrder.html',
                controller: 'modLoadOrderController',
            }
        },
        url: '/load-order?{page:int}&scol&sdir&{filter:bool}',
        params: {
            page: 1,
            scol: 'reputation',
            sdir: 'desc',
            filter: true
        }
    }).state('base.mod.Analysis', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Analysis': {
                templateUrl: '/resources/partials/mod/analysis.html',
                controller: 'modAnalysisController',
            }
        },
        url: '/analysis?{plugin:int}'
    });
}]);

app.controller('modController', function($scope, $q, $stateParams, $state, $timeout, currentUser, modObject, modService, contributionService, categoryService, tagService, smoothScroll, errorService, tabsFactory, sortFactory) {
    // get parent variables
    $scope.mod = modObject.mod;
    $scope.mod.star = modObject.star;
    $scope.currentUser = currentUser;
    // resolve mod categories
    categoryService.resolveModCategories($scope.mod);

    // initialize local variables
    $scope.tabs = tabsFactory.buildModTabs($scope.mod);
    $scope.tags = [];
    $scope.newTags = [];
    $scope.statusModal = {};
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
    $scope.permissions = angular.copy(currentUser.permissions);
    //setting up the canManage permission
    var author = $scope.mod.author_users.find(function(author) {
        return author.id == $scope.currentUser.id;
    });
    var isAuthor = author !== null;
    $scope.permissions.canManage = $scope.permissions.canModerate || isAuthor;

    //returns a reference to the tab with tabName (because sometimes tabs are removed)
    $scope.findTab = function(tabName) {
        var index = $scope.tabs.findIndex(function(tab) {
            return tab.name === tabName;
        });
        return $scope.tabs[index];
    };

    //removes the tab with tabName
    $scope.removeTab = function(tabName) {
        var index = $scope.tabs.findIndex(function(tab) {
            return tab.name === tabName;
        });
        $scope.tabs.splice(index, 1);
    };

    $scope.refreshTabParams = function(tab) {
        $state.go('base.mod.' + tab.name, tab.params, { notify: false });
    };

    $scope.redirectToFirstTab = function() {
        var tab = $scope.tabs[0];
        $state.go('base.mod.' + tab.name, tab.params, { location: 'replace' });
    };

    // only display analysis tab if mod doesn't have a primary category
    if (!$scope.mod.primary_category_id) {
        $scope.removeTab('Reviews');
        $scope.removeTab('Compatibility');
        $scope.removeTab('Install Order');
        $scope.removeTab('Load Order');
        if (!$state.is('base.mod.Analysis')) {
            $scope.redirectToFirstTab();
        }
    } else {
        // remove install order notes if mod is a utility
        if ($scope.mod.is_utility) {
            $scope.removeTab('Install Order');
            if ($state.is('base.mod.Install Order')) {
                $scope.redirectToFirstTab();
            }
        }
        // remove Load Order tab if mod has no plugins
        if ($scope.mod.plugins_count === 0) {
            $scope.removeTab('Load Order');
            if ($state.is('base.mod.Load Order')) {
    $scope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState, fromParams) {
        //only if the new state is still on this mod's page
        if (toParams.modId == fromParams.modId) {
            newTabIndex = $scope.tabs.findIndex(function(tab) {
                return toState.name.slice(9) === tab.name;
            });
            if (newTabIndex < 0) {
                $scope.redirectToFirstTab();
            }
        }
    });

    //set the class of the status box
    switch ($scope.mod.status) {
        case "good":
            $scope.statusClass = "green-box";
            break;
        case "outdated":
            $scope.statusClass = "yellow-box";
            break;
        case "unstable":
            $scope.statusClass = "red-box";
            break;
    }

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

    // change sort direction
    $scope.toggleSortDirection = function(tab) {
        tab.params.sdir = tab.params.sdir === 'asc' ? 'desc' : 'asc';
    };

    // update the markdown editor
    $scope.updateEditor = function(noScroll) {
        if (!noScroll) {
            $timeout(function() {
                var editorBox = document.getElementsByClassName("add-note-box")[0];
                smoothScroll(editorBox, {
                    offset: 20
                });
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
