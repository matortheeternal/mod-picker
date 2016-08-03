app.controller('modListAnalysisController', function($scope, modListService) {
    $scope.retrieveAnalysis = function() {
        modListService.retrieveModListAnalysis($scope.mod_list.id).then(function(data) {
            $scope.mod_list.analysis = data;
            $scope.analysisReady = true;
        }, function(response) {
            $scope.errors.analysis = response;
        });
    };

    // retrieve analysis when the state is first loaded
    $scope.retrieveAnalysis();
});