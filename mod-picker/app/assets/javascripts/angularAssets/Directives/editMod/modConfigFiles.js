app.directive('modConfigFiles', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/editMod/modConfigFiles.html',
        scope: false
    }
});

app.controller('modConfigFilesController', function($scope) {
    $scope.addConfigFile = function() {
        $scope.mod.config_files.push({
            filename: "Config.ini",
            install_path: "{{GamePath}}"
        });
    };

    $scope.removeConfigFile = function(config_file) {
        if (config_file.id) {
            config_file._destroy = true;
        } else {
            var index = $scope.mod.config_files.indexOf(config_file);
            $scope.mod.config_files.splice(index, 1);
        }
    };
});