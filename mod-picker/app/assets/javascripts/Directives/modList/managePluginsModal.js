app.directive('managePluginsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/managePluginsModal.html',
        controller: 'managePluginsModalController',
        scope: false
    };
});

app.controller('managePluginsModalController', function($scope, columnsFactory, actionsFactory) {
    // re-initialize plugins store active booleans to false
    $scope.plugins_store.forEach(function(plugin) {
        plugin.active = false;
    });

    // labels for modal table
    $scope.columnLabels = [
        {
            label: 'Filename'
        },
        {
            label: 'Mod'
        },
        {
            label: 'Mod Option Name'
        }
    ];

    $scope.getPluginLink = function(item) {
        if (item.mod && item.id) {
            return "#/mod/" + item.mod.id + "/analysis?plugin=" + item.id;
        }
    };

    $scope.getModLink = function(item) {
        if (item.mod) {
            return "#/mod/" + item.mod.id;
        }
    }

    // update plugins store active booleans based on plugins that are in the mod list
    $scope.mod_list.plugins.forEach(function(modListPlugin) {
        if (modListPlugin._destroy) return;

        var foundPlugin = $scope.plugins_store.find(function(plugin) {
            return plugin.id == modListPlugin.plugin.id;
        });
        if (foundPlugin) {
            foundPlugin.active = true;
        }
    });
});
