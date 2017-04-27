app.controller('editModAnalysisController', function($scope, modService, modLoaderService) {
    $scope.retrieveAnalysis = function() {
        // retrieve the analysis for editing
        modService.editAnalysis($scope.mod.id).then(function(modOptions) {
            modLoaderService.loadAssets(modOptions);
            $scope.mod.mod_options = modOptions;
            $scope.originalMod.mod_options = angular.copy(modOptions);
        }, function(response) {
            $scope.errors.analysis = response;
        });
    };

    //retrieve the data when the state is first loaded
    $scope.retrieveAnalysis();
});