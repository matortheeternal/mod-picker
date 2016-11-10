app.directive('modOption', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/editMod/modOption.html',
        scope: {
            option: '=',
            oldOptions: '='
        },
        controller: 'modOptionController'
    }
});

app.controller('modOptionController', function($scope, formUtils, assetUtils) {
    $scope.focusText = formUtils.focusText;

    $scope.removeModOption = function() {
        if ($scope.option.id) {
            $scope.option._destroy = true;
        } else {
            $scope.$emit('removeModOption', $scope.option);
        }
    };

    $scope.findOldOption = function(optionId) {
        return $scope.oldOptions.find(function(oldOption) {
            return oldOption.id == optionId;
        });
    };

    $scope.oldOptionChanged = function() {
        var option = $scope.option;
        if (option.hasOwnProperty('id') && option.id !== null) {
            $scope.oldOption = $scope.findOldOption(option.id);
            option.display_name = angular.copy($scope.oldOption.display_name);
            $scope.loadExistingPlugins();
        } else {
            delete $scope.oldOption;
            option.id = undefined;
            option.display_name = angular.copy(option.name);
            option.plugins && option.plugins.forEach(function(plugin) {
                if (plugin.hasOwnProperty('id')) delete plugin.id;
            });
        }
        $scope.$emit('destroyUnusedOldOptions');
    };

    $scope.oldPluginChanged = function(plugin) {
        if (plugin.id == null) delete plugin.id;
        $scope.destroyUnusedOldPlugins();
    };

    $scope.destroyUnusedOldPlugins = function() {
        if (!$scope.oldOption) return;
        var oldPlugins = $scope.oldOption.plugins;
        oldPlugins.forEach(function(oldPlugin) {
            var plugin = $scope.option.plugins.find(function(plugin) {
                return plugin.id == oldPlugin.id;
            });
            if (!plugin) {
                oldPlugin._destroy = true;
            } else if (oldPlugin.hasOwnProperty('_destroy')) {
                delete oldPlugin._destroy;
            }
        });
    };

    $scope.pluginMatches = function(a, b) {
        var filenamesMatch = a.filename === b.filename;
        var crcsMatch = a.crc_hash === b.crc_hash;
        var mastersMatch = a.master_plugins === b.master_plugins;
        var filesizesMatch = a.file_size === b.file_size;
        var matchSum = filenamesMatch + mastersMatch + filesizesMatch;
        return crcsMatch || matchSum > 2;
    };

    $scope.loadExistingPlugin = function(plugin) {
        var oldPlugins = $scope.oldOption.plugins;
        var oldPlugin = oldPlugins.find(function(oldPlugin) {
            return $scope.pluginMatches(plugin, oldPlugin);
        });
        if (oldPlugin) {
            plugin.id = oldPlugin.id;
        }
    };

    $scope.loadExistingPlugins = function() {
        if (!$scope.option.plugins || !$scope.oldOption.plugins) return;
        $scope.option.plugins.forEach($scope.loadExistingPlugin);
    };

    // load old option into scope
    if ($scope.option.id && $scope.oldOptions) {
        $scope.oldOption = $scope.findOldOption($scope.option.id);
        $scope.loadExistingPlugins();
    }
});