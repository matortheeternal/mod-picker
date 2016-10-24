app.directive('managePluginsModal', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modList/managePluginsModal.html',
        controller: 'managePluginsModalController',
        scope: false
    };
});

app.controller('managePluginsModalController', function($scope, columnsFactory, objectUtils) {
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

    $scope.findInstallOrderMod = function(modId) {
        if (!$scope.model.mods) {
            return $scope.install_order.find(function(item) {
                return item.mod_id == modId;
            });
        } else {
            return $scope.findMod(modId, true);
        }
    };

    $scope.buildPluginsStore = function() {
        $scope.plugins_store.forEach(function(plugin) {
            var mod = $scope.findInstallOrderMod(plugin.mod.id);
            plugin.mod_index = (mod && mod.index) || -1;
        });
    };

    // initialize variables

    $scope.columns = columnsFactory.modListPluginStoreColumns();
    var sortedColumn;

    $scope.sort = {
        column: '',
        direction: 'ASC'
    }

    // helper functions to get links to plugin/mods
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

    // load sort into view
    $scope.loadSort = function() {
        $scope.columns.forEach(function(column) {
            if ($scope.getSortData(column) === $scope.sort.column) {
                var sortKey = $scope.sort.direction === "ASC" ? "up" : "down";
                column[sortKey] = true;
                sortedColumn = column;
            }
        });
    };

    // get the sort data key for a column
    $scope.getSortData = function(column) {
        return column.sortData || (typeof column.data === "string" ? column.data : objectUtils.csv(column.data));
    };

    // sorts by column
    $scope.sortColumn = function(column) {
        // return if we don't have a sort object or the column isn't sortable
        if (!$scope.sort || column.unsortable) return;

        if (sortedColumn && sortedColumn !== column) {
            sortedColumn.up = false;
            sortedColumn.down = false;
        }
        sortedColumn = column;
        $scope.toggleSort(column);

        // send data to backend
        if (column.up || column.down) {
            $scope.sort.column = $scope.getSortData(column);
            $scope.sort.direction = column.up ? "ASC" : "DESC";
        } else {
            delete $scope.sort.column;
            delete $scope.sort.direction;
        }
    };

    // this function will toggle sorting for an input column between
    // up, down, and no sorting
    $scope.toggleSort = function(column) {
        var firstKey = column.invertSort ? "up" : "down";
        var secondKey = column.invertSort ? "down" : "up";
        var b1 = column[firstKey], b2 = column[secondKey];
        column[secondKey] = b1;
        column[firstKey] = !b1 && !b2;
    };

    // load sort into view
    if ($scope.columns && $scope.sort && $scope.sort.column) {
        $scope.loadSort();
    }

    // add mod indices to plugins_store
    $scope.buildPluginsStore();
});