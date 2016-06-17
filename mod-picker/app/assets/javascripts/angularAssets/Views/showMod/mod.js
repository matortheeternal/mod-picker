app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.mod', {
        templateUrl: '/resources/partials/showMod/mod.html',
        controller: 'modController',
        url: '/mod/:modId',
        redirectTo: 'base.mod.Reviews',
        resolve: {
            modObject: function(modService, $stateParams) {
                return modService.retrieveMod($stateParams.modId);
            },
            modId: function($stateParams) {
                return $stateParams.modId;
            }
        }
    }).state('base.mod.Reviews', {
        templateUrl: '/resources/partials/showMod/reviews.html',
        controller: 'modReviewsController',
        url: '/reviews',
        params: {
            retrieve: true,
            page: 1
        }
    }).state('base.mod.Compatibility', {
        templateUrl: '/resources/partials/showMod/compatibility.html',
        controller: 'modCompatibilityController',
        url: '/compatibility',
        params: {
            sort: {
                column: 'reputation',
                direction: 'desc'
            },
            retrieve: true,
            filters: {
                mod_list: true
            },
            page: 1
        },
        resolve: {
            compatibilityNotes: function($stateParams, $state, modId, modService, modObject) {
                //hardcoded redirect to the analysis tab when it's the base game
                if (!modObject.mod.primary_category_id) {
                    $state.go('base.mod.Analysis', {
                        modId: modId
                    });
                }

                //only resolve if the retrieve param is true
                if ($stateParams.retrieve) {
                    var options = {
                        sort: $stateParams.sort,
                        filters: $stateParams.filters,
                        page: $stateParams.page
                    };
                    this.self.data = { pages: {} };
                    return modService.retrieveModContributions(modId, 'compatibility_notes', options, this.self.data.pages);
                }
            }
        }
    }).state('base.mod.Install Order', {
        templateUrl: '/resources/partials/showMod/installOrder.html',
        controller: 'modInstallOrderController',
        url: '/install-order',
        params: {
            sort: {
                column: 'reputation',
                direction: 'desc'
            },
            retrieve: true,
            filters: {
                mod_list: true
            },
            page: 1
        },
        resolve: {
            installOrderNotes: function($stateParams, $state, modId, modService, modObject) {
                //hardcoded redirect to the analysis tab when it's the base game
                if (!modObject.mod.primary_category_id) {
                    $state.go('base.mod.Analysis', {
                        modId: modId
                    });
                }

                //only resolve if the retrieve param is true
                if ($stateParams.retrieve) {
                    var options = {
                        sort: $stateParams.sort,
                        filters: $stateParams.filters,
                        page: $stateParams.page
                    };
                    this.self.data = { pages: {} };
                    return modService.retrieveModContributions(modId, 'install_order_notes', options, this.self.data.pages);
                }
            }
        }
    }).state('base.mod.Load Order', {
        templateUrl: '/resources/partials/showMod/loadOrder.html',
        controller: 'modLoadOrderController',
        url: '/load-order',
        params: {
            sort: {
                column: 'reputation',
                direction: 'desc'
            },
            retrieve: true,
            filters: {
                mod_list: true
            },
            page: 1
        },
        resolve: {
            loadOrderNotes: function($stateParams, $state, modId, modService, modObject) {
                //hardcoded redirect to the analysis tab when it's the base game
                if (!modObject.mod.primary_category_id) {
                    $state.go('base.mod.Analysis', {
                        modId: modId
                    });
                }
                //hardcoded redirect to the reviews tab when there aren't any
                if (modObject.mod.plugins_count === 0) {
                    $state.go('base.mod.Reviews', {
                        modId: modId
                    });
                }

                //only resolve if the retrieve param is true
                if ($stateParams.retrieve) {
                    var options = {
                        sort: $stateParams.sort,
                        filters: $stateParams.filters,
                        page: $stateParams.page
                    };
                    this.self.data = { pages: {} };
                    return modService.retrieveModContributions(modId, 'load_order_notes', options, this.self.data.pages);
                }
            }
        }
    }).state('base.mod.Analysis', {
        templateUrl: '/resources/partials/showMod/analysis.html',
        controller: 'modAnalysisController',
        url: '/analysis',
        params: {
            retrieve: true
        },
        resolve: {
            analysis: function($stateParams, modObject, modService) {
                //only resolve if the retrieve param is true
                if ($stateParams.retrieve) {
                    return modService.retrieveModAnalysis(modObject.mod.id);
                }
            }
        }
    });
}]);

app.controller('modController', function($scope, $q, $stateParams, $timeout, currentUser, modObject, modService, pluginService, categoryService, gameService, recordGroupService, userTitleService, assetUtils, reviewSectionService, userService, contributionService, contributionFactory, errorsFactory, tagService, smoothScroll) {
    // get parent variables
    $scope.mod = modObject.mod;
    $scope.mod.star = modObject.star;
    $scope.currentUser = currentUser;

    // initialize local variables
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
        reviews: {
            column: 'reputation',
            direction: 'desc'
        },
        compatibility_notes: {
            column: 'reputation',
            direction: 'desc'
        },
        install_order_notes: {
            column: 'reputation',
            direction: 'desc'
        },
        load_order_notes: {
            column: 'reputation',
            direction: 'desc'
        }
    };
    $scope.retrieving = {};

    //a copy is created so the original permissions are never changed
    $scope.permissions = angular.copy(currentUser.permissions);
    //setting up the canManage permission
    var author = $scope.mod.author_users.find(function(author) {
        return author.id == $scope.currentUser.id;
    });
    var isAuthor = author !== null;
    $scope.permissions.canManage = $scope.permissions.canModerate || isAuthor;

    //tabs array
    $scope.tabs = [{
        name: 'Reviews'
    }, {
        name: 'Compatibility',
        params: {
            sort: {
                column: 'reputation',
                direction: 'desc'
            }
        }
    }, {
        name: 'Install Order',
        params: {
            sort: {
                column: 'reputation',
                direction: 'desc'
            }
        }
    }, {
        name: 'Load Order',
        params: {
            sort: {
                column: 'reputation',
                direction: 'desc'
            }
        }
    }, {
        name: 'Analysis',
        params: {}
    }];

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
        delete $scope.tabs[index];
    };

    // only display analysis tab if mod doesn't have a primary category
    if (!$scope.mod.primary_category_id) {
        $scope.removeTab('Reviews');
        $scope.removeTab('Compatibility');
        $scope.removeTab('Install Order');
        $scope.removeTab('Load Order');
    }
    // remove Load Order tab if mod has no plugins
    else if ($scope.mod.plugins_count === 0) {
        $scope.removeTab('Load Order');
    }

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
        });
    };

    // HEADER RELATED LOGIC
    $scope.starMod = function() {
        modService.starMod($scope.mod.id, $scope.mod.star).then(function() {
            $scope.mod.star = !$scope.mod.star;
        }, function(response) {
            // TODO: Push error to view
        });
    };

    $scope.toggleStatusModal = function(visible) {
        $scope.statusModal.visible = visible;
        if (!$scope.mod.corrections && !$scope.retrieving.corrections) {
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
        tagService.updateModTags($scope.mod, updatedTags).then(function() {
            $scope.submitMessage = "Tags submitted successfully.";
            $scope.showSuccess = true;
            action.resolve(data);
        }, function(response) {
            // TODO: Push error to view
            action.reject(response);
        });
        return action.promise;
    };
});