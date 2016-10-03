app.directive('manageConfigsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/manageConfigsModal.html',
        controller: 'manageConfigsModalController',
        scope: false
    };
});

app.controller('manageConfigsModalController', function($scope) {
    // re-initialize configs store active booleans to false
    $scope.configs_store.forEach(function(config) {
        config.active = false;
    });

    // update configs store active booleans based on configs that are in the mod list
    $scope.mod_list.config_files.forEach(function(modListConfig) {
        if (modListConfig._destroy) return;
        var foundConfig = $scope.configs_store.find(function(config) {
            return config.id == modListConfig.config_file.id;
        });
        if (foundConfig) {
            foundConfig.active = true;
        }
    });
});
