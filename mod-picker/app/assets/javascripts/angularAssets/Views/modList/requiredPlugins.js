app.directive('requiredPlugins', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/requiredPlugins.html',
        controller: 'requiredPluginsController',
        scope: false
    }
});

app.controller('requiredPluginsController', function($scope, requirementUtils) {
    $scope.showMissingPlugins = true;

    /* BUILD VIEW MODEL */
    $scope.buildMissingPlugins = function() {
        $scope.required.missing_plugins = [];
        $scope.required.plugins.forEach(function(requirement) {
            // skip destroyed requirements
            if (!requirement.plugins.length) {
                return;
            }
            var requiredPluginPresent = $scope.findPlugin(requirement.master_plugin.id, true);
            if (!requiredPluginPresent) {
                if (requirementUtils.findOne($scope.findPlugin, requirement.plugins)) {
                    $scope.required.missing_plugins.push(requirement);
                }
            }
        });
    };

    /* HELPER FUNCTIONS */
    $scope.getRequirerList = function(requirement, startIndex) {
        return requirement.plugins.slice(startIndex).map(function(plugin) {
            return plugin.filename;
        }).join(', ');
    };

    /* RESOLUTION ACTIONS */
    $scope.removeRequirers = function(requirement) {
        requirement.plugins.forEach(function(plugin) {
            $scope.removePlugin($scope.findPlugin(plugin.id, true));
        });
    };

    /* EVENT TRIGGERS */
    $scope.$on('initializeModules', function() {
        requirementUtils.compactRequirements($scope.required.plugins, 'plugin', 'master_plugin');
        $scope.buildMissingPlugins();
    });
    $scope.$on('reloadModules', function() {
        requirementUtils.recoverDestroyedRequirements($scope.required.plugins, 'plugin');
        $scope.buildMissingPlugins();
    });
    $scope.$on('saveChanges', function() {
        requirementUtils.removeDestroyedRequirements($scope.required.plugins, 'plugin');
        $scope.buildMissingPlugins();
    });
    $scope.$on('pluginRemoved', function(event, pluginId) {
        if (pluginId) {
            requirementUtils.removeRequirements(pluginId, $scope.required.plugins, 'plugin');
        }
        $scope.buildMissingPlugins();
    });
    $scope.$on('pluginRecovered', function(event, pluginId) {
        if (pluginId) {
            requirementUtils.recoverRequirements(pluginId, $scope.required.plugins, 'plugin');
        }
        $scope.buildMissingPlugins();
    });
    $scope.$on('pluginAdded', function(event, pluginData) {
        var requirements = pluginData.required_plugins;
        requirementUtils.addRequirements(requirements, $scope.required.plugins, 'plugin', 'master_plugin');
        $scope.buildMissingPlugins();
    });
});