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
    $scope.getRequirerList = requirementUtils.getPluginRequirerList;

    /* BUILD VIEW MODEL */
    $scope.buildMissingPlugins = function() {
        $scope.required.missing_plugins = [];
        $scope.required.plugins.forEach(function(requirement) {
            // skip destroyed requirements
            if (!requirement.plugins.length) {
                return;
            }
            var requiredPluginPresent = $scope.findPlugin(requirement.master_plugin.filename, true, true);
            if (!requiredPluginPresent) {
                if (requirementUtils.findOne($scope.findPlugin, requirement.plugins)) {
                    $scope.required.missing_plugins.push(requirement);
                }
            }
        });
    };

    /* RESOLUTION ACTIONS */
    $scope.removeRequirers = function(requirement) {
        requirement.plugins.forEach(function(plugin) {
            $scope.removePlugin($scope.findPlugin(plugin.id, true));
        });
    };

    $scope.resolveAllRequirements = function() {
        $scope.required.missing_plugins.forEach(function(requirement) {
            $scope.addPlugin(requirement.master_plugin.id)
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
    $scope.$on('pluginRemoved', function(event, plugin) {
        if (plugin) requirementUtils.removeRequirements(plugin.id, $scope.required.plugins, 'plugin');
        $scope.buildMissingPlugins();
    });
    $scope.$on('pluginRecovered', function(event, pluginId) {
        if (pluginId) requirementUtils.recoverRequirements(pluginId, $scope.required.plugins, 'plugin');
        $scope.buildMissingPlugins();
    });
    $scope.$on('pluginAdded', function(event, pluginData) {
        var requirements = pluginData.required_plugins;
        requirementUtils.addRequirements(requirements, $scope.required.plugins, 'plugin', 'master_plugin');
        $scope.buildMissingPlugins();
    });
});