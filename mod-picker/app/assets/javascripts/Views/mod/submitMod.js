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

app.controller('submitModController', function($scope, $rootScope, backend, modService, modValidationService, scrapeService, pluginService, categoryService, sitesFactory, eventHandlerFactory) {
    // access parent variables
    $scope.currentUser = $rootScope.currentUser;
    $scope.categories = $rootScope.categories;
    $scope.categoryPriorities = $rootScope.categoryPriorities;
    $scope.permissions = angular.copy($rootScope.permissions);

    // initialize variables
    $scope.sites = sitesFactory.sites();
    $scope.mod = {
        game_id: window._current_game_id,
        sources: [{
            label: "Nexus Mods",
            url: ""
        }],
        custom_sources: [],
        requirements: []
    };

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
        $scope.sourcesValid = modValidationService.sourcesValid($scope.mod);
        $scope.categoriesValid = modValidationService.categoriesValid($scope.mod);
        $scope.requirementsValid = modValidationService.requirementsValid($scope.mod.requirements);
        $scope.analysisValid = !!$scope.mod.analysis;
        return $scope.sourcesValid && $scope.categoriesValid && $scope.analysisValid;
    };

    $scope.submit = function() {
        // return if mod is invalid
        if (!$scope.modValid()) {
            return;
        }

        $scope.startSubmission("Submitting Mod...");
        modService.submitMod($scope.mod).then(function() {
            $scope.submissionSuccess("Mod submitted successfully!", "#/mods", "return to the mods index.");
        }, function(response) {
            $scope.submissionError("There were errors submitting your mod.", response);
        });
    };
});
