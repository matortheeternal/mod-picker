app.directive('pluginLoadOrderIssues', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/pluginLoadOrderIssues.html',
        controller: 'pluginLoadOrderIssuesController',
        scope: false
    }
});

app.controller('pluginLoadOrderIssuesController', function($scope) {
    $scope.reAddNotes = function(pluginId) {
        $scope.notes.load_order.forEach(function(note) {
            if (note._destroy && note.plugins[0].id == pluginId || note.plugins[1].id == pluginId) {
                delete note._destroy;
            }
        });
    };

    $scope.removeNotes = function(pluginId) {
        $scope.notes.load_order.forEach(function(note) {
            if (note.plugins[0].id == pluginId || note.plugins[1].id == pluginId) {
                note._destroy = true;
            }
        });
    };

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
                // TODO: Update $scope.plugin_list.ignored_notes
                $scope.$broadcast('rebuildUnresolvedLoadOrder');
                break;
        }
    });

    // direct method trigger events
    $scope.$on('rebuildUnresolvedLoadOrder', $scope.buildUnresolvedLoadOrder);
});