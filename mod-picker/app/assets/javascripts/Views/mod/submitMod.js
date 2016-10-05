app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.submit-mod', {
            templateUrl: '/resources/partials/mod/submitMod.html',
            controller: 'submitModController',
            url: '/mods/submit',
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
                            stateUrl: window.location.hash
                        };
                        mod.reject(errorObj);
                    });
                    return mod.promise;
                }
            }
        }
    );
}]);

app.controller('submitModController', function($scope, $rootScope, backend, modService, scrapeService, pluginService, categoryService, sitesFactory, eventHandlerFactory) {
    // access parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.categories = $rootScope.categories;
    $scope.categoryPriorities = $rootScope.categoryPriorities;
    $scope.permissions = angular.copy($rootScope.permissions);

    // initialize variables
    $scope.sites = sitesFactory.sites();
    $scope.mod = {
        game_id: window._current_game_id,
        requirements: []
    };
    $scope.sources = [{
        label: "Nexus Mods",
        url: ""
    }];
    $scope.customSources = [];

    // shared function setup
    eventHandlerFactory.buildMessageHandlers($scope, true);
    $scope.searchMods = modService.searchMods;

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
    $scope.modValid = function() {
        // main source validation
        var sourcesValid = true;
        $scope.sources.forEach(function(source) {
            sourcesValid = sourcesValid && source.valid;
        });

        // custom source validation
        if ($scope.customSources.length) {
            $scope.customSources.forEach(function(source) {
                sourcesValid = sourcesValid && source.valid;
            });
            // if we are only submitting custom soruces, we need to verify
            // we have all general info
            if (!$scope.sources.length) {
                sourcesValid = sourcesValid && $scope.mod.name && $scope.mod.authors && $scope.mod.released;
            }
        }
        else {
            // if we don't have any custom sources we should verify we have
            // the scraped data for at least one official source
            sourcesValid = sourcesValid && ($scope.nexus || $scope.workshop || $scope.lab);
        }

        // categories are valid if there are 1-2 categories selected
        var categoriesValid = $scope.mod.categories && $scope.mod.categories.length &&
            $scope.mod.categories.length <= 2;
        return (sourcesValid && categoriesValid && $scope.mod.analysis)
    };

    $scope.submit = function() {
        // return if mod is invalid
        if (!$scope.modValid()) {
            return;
        }

        var sources = {
            nexus: $scope.nexus,
            workshop: $scope.workshop,
            lab: $scope.lab
        };
        $scope.startSubmission("Submitting Mod...");

        modService.submitMod($scope.mod, sources, $scope.customSources).then(function() {
            $scope.submissionSuccess("Mod submitted successfully!", "#/mods", "return to the mods index.");
        }, function(response) {
            $scope.submissionError("There were errors submitting your mod.", response);
        });
    };
});
