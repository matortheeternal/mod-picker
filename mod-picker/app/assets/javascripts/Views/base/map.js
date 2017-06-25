app.config(['$stateProvider', function($stateProvider) {
    $stateProvider.state('base.map', {
        templateUrl: '/resources/partials/base/map.html',
        controller: 'mapController',
        url: '/map'
    });
}]);

app.controller('mapController', function($scope, helpFactory, worldspacesService) {
    $scope.$emit('setPageTitle', 'Map');
    helpFactory.setHelpContexts($scope, []);

    $scope.getWorldspaceWidth = function() {
        var max = $scope.currentWorldspace.cells.reduce(function(max, cell) {
            return Math.max(max, cell.x);
        });
        var min = $scope.currentWorldspace.cells.reduce(function(min, cell) {
            return Math.min(min, cell.x);
        });
        var width = Math.abs(min) + max;
        if (min < 0) return width + 1;
        return width;
    };

    $scope.selectWorldspace = function() {
        $scope.currentCells = null;
        $scope.$applyAsync(function() {
            var width = $scope.getWorldspaceWidth();
            $scope.mapStyle = {
                'max-width': width * 40 + 'px'
            };
            $scope.currentCells = $scope.currentWorldspace.cells;
        });
    };

    $scope.selectPlugin = function() {
        $scope.pluginWorldspaces = $scope.worldspaces.filter(function(worldspace) {
            return worldspace.plugin.id == $scope.currentPlugin.id;
        });
        $scope.currentWorldspace = $scope.pluginWorldspaces[0];
        $scope.selectWorldspace();
    };

    $scope.loadPlugins = function() {
        $scope.plugins = [];
        $scope.worldspaces.forEach(function(worldspace) {
            if ($scope.plugins.indexOf(worldspace.plugin) == -1) {
                $scope.plugins.push(worldspace.plugin);
            }
        });
        $scope.currentPlugin = $scope.plugins[0];
        $scope.selectPlugin();
    };

    $scope.handlePersistentCell = function(worldspace) {
        var originCells = worldspace.cells.filter(function(cell) {
            return (cell.x == 0) && (cell.y == 0);
        });
        if (originCells.length == 2) {
            originCells[0].persistentCell = originCells[1];
            var index = worldspace.cells.indexOf(originCells[1]);
            worldspace.cells.splice(index, 1);
        } else {
            console.log("No persistent worldspace cell found for " + worldspace.name);
        }
    };

    $scope.sortCells = function() {
        $scope.worldspaces.forEach(function(worldspace) {
            var height = worldspace.cells.reduce(function(max, cell) {
                return Math.max(max, cell.y);
            });
            worldspace.cells.sort(function(a, b) {
                return (a.x * height + a.y) - (b.x * height + b.y);
            });
            $scope.handlePersistentCell(worldspace);
        });
    };

    $scope.retrieveWorldspaces = function() {
        worldspacesService.retrieveWorldspaces().then(function(data) {
            $scope.worldspaces = data;
            $scope.sortCells();
            $scope.loadPlugins();
        }, function(response) {
            $scope.errors = response;
        })
    };

    $scope.retrieveWorldspaces();
});
