app.directive('pluginLoadOrderIssues', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/pluginLoadOrderIssues.html',
        controller: 'pluginLoadOrderIssuesController',
        scope: false
    }
});

app.controller('pluginLoadOrderIssuesController', function($scope, listUtils) {
    /* BUILD VIEW MODEL */
    $scope.buildUnresolvedLoadOrder = function() {
        $scope.notes.unresolved_load_order = [];
        $scope.notes.ignored_load_order = [];
        $scope.notes.load_order.forEach(function(note) {
            // skip destroyed or ignored notes
            if (note._destroy) {
                return;
            } else if (note.ignored) {
                $scope.notes.ignored_load_order.push(note);
                return;
            }
            var first_plugin = $scope.findPlugin(note.plugins[0].id, true);
            var second_plugin = $scope.findPlugin(note.plugins[1].id, true);
            // unresolved if the both mods are present and the first mod comes after the second mod
            if (first_plugin && second_plugin && first_plugin.index > second_plugin.index) {
                note.resolved = false;
                $scope.notes.unresolved_load_order.push(note);
            } else {
                note.resolved = true;
            }
        });
    };

    /* UPDATE VIEW MODEL */
    $scope.recoverLoadOrderNotes = function(pluginId) {
        $scope.notes.load_order.forEach(function(note) {
            if (note._destroy && note.plugins[0].id == pluginId || note.plugins[1].id == pluginId) {
                delete note._destroy;
            }
        });
    };

    $scope.removeLoadOrderNotes = function(pluginId) {
        $scope.notes.load_order.forEach(function(note) {
            if (note.plugins[0].id == pluginId || note.plugins[1].id == pluginId) {
                note._destroy = true;
            }
        });
    };

    /* RESOLUTIONS ACTIONS */
    $scope.$on('resolveLoadOrderNote', function(event, options) {
        switch(options.action) {
            case "move":
                var moveOptions = {
                    moveId: options.note.plugins[options.index].id,
                    destId: options.note.plugins[+!options.index].id,
                    after: !!options.index
                };
                $scope.$broadcast('moveItem', moveOptions);
                break;
            case "ignore":
                options.note.ignored = !options.note.ignored;
                // TODO: Update $scope.mod_list.ignored_notes
                $scope.buildUnresolvedLoadOrder();
                break;
        }
    });

    // event triggers
    $scope.$on('initializeModules', function() {
        $scope.buildUnresolvedLoadOrder();
    });
    $scope.$on('reloadModules', function() {
        listUtils.recoverDestroyed($scope.notes.load_order);
        $scope.buildUnresolvedLoadOrder();
    });
    $scope.$on('saveChanges', function() {
        listUtils.removeDestroyed($scope.notes.load_order);
        $scope.buildUnresolvedLoadOrder();
    });
    $scope.$on('pluginRemoved', function(pluginId) {
        $scope.removeLoadOrderNotes(pluginId);
        $scope.buildUnresolvedLoadOrder();
    });
    $scope.$on('pluginRecovered', function(pluginId) {
        $scope.recoverLoadOrderNotes(pluginId);
        $scope.buildUnresolvedLoadOrder();
    });
    $scope.$on('pluginAdded', function(event, pluginData) {
        $scope.notes.load_order.unite(pluginData.load_order_notes);
        $scope.buildUnresolvedLoadOrder();
    });
    $scope.$on('pluginMoved', function() {
        $scope.buildUnresolvedLoadOrder();
    });
});