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

    // Column Labels + Table sorting logic
    // TODO: Maybe refactor so column data fields are in the controller as well?

    // default table sorting options
    $scope.sortType = 'active';
    $scope.sortReverse = false;

    $scope.columnLabels = [{
        label: 'Active',
        dataLabel: 'active'
    }, {
        label: 'Filename',
        dataLabel: 'filename'
    }, {
        label: 'Mod',
        dataLabel: 'mod.name'
    }, {
        label: 'Mod Option Name',
        dataLabel: 'mod_option.name'
    }];

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

    // sort function
    $scope.sortBy = function(sortType) {
        $scope.sortReverse = (sortType !== null && $scope.sortType === sortType) ?
            !$scope.sortReverse : false;
        $scope.sortType = sortType;
    };
});