app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.submit-mod', {
            templateUrl: '/resources/partials/editMod/submit.html',
            controller: 'submitModController',
            url: '/mods/submit',
            redirectTo: 'base.submit-mod.General',
            resolve: {
                mod: function($q, modService) {
                    var mod = $q.defer();
                    modService.newMod().then(function(data) {
                        mod.resolve(data);
                    }, function(response) {
                        var errorObj = {
                            text: 'Error submitting new mod.',
                            response: response,
                            stateName: "base.submit-mod",
                            stateUrl: window.location.href
                        };
                        mod.reject(errorObj);
                    });
                    return mod.promise;
                }
            }
        }
    ).state('base.submit-mod.General', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'General': {
                templateUrl: '/resources/partials/editMod/modGeneral.html'
            }
        },
        url: '/general'
    }).state('base.submit-mod.Analysis', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Analysis': {
                templateUrl: '/resources/partials/editMod/modAnalysis.html'
            }
        },
        url: '/analysis'
    }).state('base.submit-mod.Classification', {
        sticky: true,
        deepStateRedirect: true,
        views: {
            'Classification': {
                templateUrl: '/resources/partials/editMod/modClassification.html'
            }
        },
        url: '/classification'
    });
}]);

app.controller('submitModController', function($scope, $rootScope, backend, modService, modValidationService, scrapeService, pluginService, categoryService, helpFactory, sitesFactory, tabsFactory, eventHandlerFactory) {
    // access parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.categories = $rootScope.categories;
    $scope.categoryPriorities = $rootScope.categoryPriorities;
    $scope.permissions = angular.copy($rootScope.permissions);

    // initialize variables
    $scope.sites = sitesFactory.sites();
    $scope.tabs = tabsFactory.buildEditModTabs(false);
    $scope.mod = {
        game_id: window._current_game_id,
        sources: [{
            label: "Nexus Mods",
            url: ""
        }],
        custom_sources: [],
        requirements: []
    };
    $scope.defaultSrc = '/mods/Default-big.png';
    $scope.imageSizes = [
        { label: "big", size: 300 },
        { label: "medium", size: 210 },
        { label: "small", size: 100 }
    ];
    $scope.image = {
        sizes: [
            { label: "big", src: '/mods/Default-big.png' }
        ]
    };
    $scope.canManageOptions = true;

    // set page title
    $scope.$emit('setPageTitle', 'Submit Mod');

    // shared function setup
    eventHandlerFactory.buildMessageHandlers($scope, true);
    $scope.searchMods = modService.searchMods;

    // set help context
    helpFactory.setHelpContexts($scope, [helpFactory.submitMod]);

    // clear messages when user changes the category
    $scope.$watch('mod.categories', function() {
        if ($scope.categoryMessages && $scope.categoryMessages.length) {
            if ($scope.categoryMessages[0].klass == "cat-error-message" ||
                $scope.categoryMessages[0].klass == "cat-success-message") {
                $scope.categoryMessages = [];
            }
        }
    }, true);

    // submission isn't allowed until the user has provided at least one valid source,
    // a mod analysis, and at least one category
    $scope.checkIfValid = function() {
        $scope.sourcesValid = modValidationService.sourcesValid($scope.mod);
        $scope.categoriesValid = modValidationService.categoriesValid($scope.mod);
        $scope.requirementsValid = modValidationService.requirementsValid($scope.mod.requirements);
        $scope.analysisValid = !!$scope.mod.analysis;
        $scope.valid = $scope.sourcesValid && $scope.categoriesValid && $scope.analysisValid;
    };

    $scope.submitImage = function(modId) {
        var successLinks = [
            {
                link: "mods/" + modId,
                linkLabel: "view the new mod."
            },
            {
                link: "mods",
                linkLabel: "return to the mods index page."
            }
        ];

        if ($scope.image.changed) {
            $scope.submittingStatus = "Submitting Mod Image...";
            modService.submitImage(modId, $scope.image.sizes).then(function() {
                $scope.submissionSuccess("Mod submitted successfully!", successLinks);
            }, function(response) {
                console.log('Image failed to submit: '+response);
                $scope.submissionSuccess("Mod submitted successfully, but image failed to submit.", successLinks);
            });
        } else {
            $scope.submissionSuccess("Mod submitted successfully!", successLinks);
        }
    };

    $scope.submit = function() {
        // return if mod is invalid
        if (!$scope.modValid()) {
            return;
        }

        $scope.startSubmission("Submitting Mod...");
        modService.submitMod($scope.mod).then(function(data) {
            $scope.submitImage(data.id);
        }, function(response) {
            $scope.submissionError("There were errors submitting your mod.", response);
        });
    };

    $scope.$watch('mod', $scope.checkIfValid, true);
});
