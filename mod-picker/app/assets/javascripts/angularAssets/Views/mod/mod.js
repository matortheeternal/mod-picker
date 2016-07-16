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
        templateUrl: '/resources/partials/mod/reviews.html',
        controller: 'modReviewsController',
        url: '/reviews?{page:int}&scol&sdir',
        params: {
            page: 1,
            scol: 'reputation',
            sdir: 'desc'
        }
    }).state('base.mod.Compatibility', {
        templateUrl: '/resources/partials/mod/compatibility.html',
        controller: 'modCompatibilityController',
        url: '/compatibility?{page:int}&scol&sdir',
        params: {
            page: 1,
            scol: 'reputation',
            sdir: 'desc'
        }
    }).state('base.mod.Install Order', {
        templateUrl: '/resources/partials/mod/installOrder.html',
        controller: 'modInstallOrderController',
        url: '/install-order?{page:int}&scol&sdir',
        params: {
            page: 1,
            scol: 'reputation',
            sdir: 'desc'
        }
    }).state('base.mod.Load Order', {
        templateUrl: '/resources/partials/mod/loadOrder.html',
        controller: 'modLoadOrderController',
        url: '/load-order?{page:int}&scol&sdir',
        params: {
            page: 1,
            scol: 'reputation',
            sdir: 'desc'
        }
    }).state('base.mod.Analysis', {
        templateUrl: '/resources/partials/mod/analysis.html',
        controller: 'modAnalysisController',
        url: '/analysis?{plugin:int}',
        params: {
            plugin: 0
        }
    });
}]);

app.controller('modController', function($scope, $q, $stateParams, $timeout, currentUser, modObject, modService, contributionService, categoryService, tagService, smoothScroll, errorService, sortFactory, tabsFactory) {
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
    var isAuthor = angular.isDefined(author);
    $scope.permissions.canManage = $scope.permissions.canModerate || isAuthor;

    //returns a reference to the tab with tabName (because sometimes tabs are removed)
    $scope.findTab = function(tabName) {
        var index = $scope.tabs.findIndex(function(tab) {
            return tab.name === tabName;
        });
        return $scope.tabs[index];
    };

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
        var successMessage = {type: "success", text: text};
        $scope.$broadcast('message', successMessage);
        // stop event propagation - we handled it
        event.stopPropagation();
    });

    // change sort direction
    $scope.toggleSortDirection = function(sort) {
        sort.direction = sort.direction === 'asc' ? 'desc' : 'asc';
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
            var params = {label: 'Error starring mod', response: response};
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
            var params = {label: 'Error saving mod tags', response: response};
            $scope.$emit('errorMessage', params);
            action.reject(response);
        });
        return action.promise;
    };
});