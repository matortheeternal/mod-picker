app.controller('modListConfigController', function($scope, $q, modListService, configFilesService) {
    $scope.toggleManageConfigsModal = function(visible) {
        $scope.$emit('toggleModal', visible);
        $scope.showManageConfigsModal = visible;
    };

    $scope.buildConfigModel = function() {
        $scope.model.configs = configFilesService.groupConfigFiles($scope.mod_list.config_files);
    };

    $scope.retrieveConfig = function() {
        modListService.retrieveModListConfigFiles($scope.mod_list.id).then(function(data) {
            $scope.mod_list.config_files = data.config_files;
            $scope.mod_list.custom_config_files = data.custom_config_files;
            $scope.configs_store = data.config_files_store;
            $scope.originalModList.config_files = angular.copy($scope.mod_list.config_files);
            $scope.originalModList.custom_config_files = angular.copy($scope.mod_list.custom_config_files);
            $scope.buildConfigModel();
            $scope.configReady = true;
        }, function(response) {
            $scope.errors.config = response;
        });
    };

    // retrieve config when the state is first loaded
    $scope.retrieveConfig();
});