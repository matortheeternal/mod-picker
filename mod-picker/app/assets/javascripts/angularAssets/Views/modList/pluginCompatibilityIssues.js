app.directive('pluginCompatibilityIssues', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/pluginCompatibilityIssues.html',
        controller: 'pluginCompatibilityIssuesController',
        scope: false
    }
});

app.controller('pluginCompatibilityIssuesController', function($scope, listUtils) {
    $scope.showUnresolvedPluginCompatibility = true;

    /* BUILD VIEW MODEL */
    $scope.buildUnresolvedPluginCompatibility = function() {
        $scope.notes.unresolved_plugin_compatibility = [];
        $scope.notes.ignored_plugin_compatibility = [];
        $scope.notes.plugin_compatibility.forEach(function(note) {
            // skip destroyed or ignored notes
            if (note._destroy) {
                return;
            } else if (note.ignored) {
                $scope.notes.ignored_plugin_compatibility.push(note);
                return;
            }
            switch (note.status) {
                case 'compatibility plugin':
                    // unresolved if the compatibility plugin is not present and both mods are present
                    if (!$scope.findPlugin(note.compatibility_plugin_id, true) &&
                        $scope.findMod(note.mods[0].id, true) && $scope.findMod(note.mods[1].id, true)) {
                        note.resolved = false;
                        $scope.notes.unresolved_plugin_compatibility.push(note);
                    } else {
                        note.resolved = true;
                    }
                    break;
                case 'make custom patch':
                    // unresolved if the custom plugin is not present and both mods are present
                    if (!$scope.findCustomPlugin(note.id, true) &&
                        $scope.findMod(note.mods[0].id, true) && $scope.findMod(note.mods[1].id, true)) {
                        note.resolved = false;
                        $scope.notes.unresolved_plugin_compatibility.push(note);
                    } else {
                        note.resolved = true;
                    }
                    break;
            }
        });
    };

    /* UPDATE VIEW MODEL */
    $scope.recoverCompatibilityNotes = function(modId) {
        $scope.notes.plugin_compatibility.forEach(function(note) {
            if (note._destroy && note.mods[0].id == modId || note.mods[1].id == modId) {
                delete note._destroy;
            }
        });
    };

    $scope.removeCompatibilityNotes = function(modId) {
        $scope.notes.plugin_compatibility.forEach(function(note) {
            if (note.mods[0].id == modId || note.mods[1].id == modId) {
                note._destroy = true;
            }
        });
    };

    /* RESOLUTION ACTIONS */
    $scope.$on('resolveCompatibilityNote', function(event, options) {
        switch(options.action) {
            case "add plugin":
                $scope.addPlugin(options.note.compatibility_plugin.id);
                break;
            case "add custom plugin":
                $scope.addCustomPlugin(options.note.id);
                break;
            case "ignore":
                options.note.ignored = !options.note.ignored;
                $scope.ignoreNote('CompatibilityNote', options.note);
                $scope.buildUnresolvedPluginCompatibility();
                break;
        }
    });

    // event triggers
    $scope.$on('initializeModules', $scope.buildUnresolvedPluginCompatibility);
    $scope.$on('reloadModules', function() {
        listUtils.recoverDestroyed($scope.notes.plugin_compatibility);
        $scope.buildUnresolvedPluginCompatibility();
    });
    $scope.$on('saveChanges', function() {
        listUtils.removeDestroyed($scope.notes.plugin_compatibility);
        $scope.buildUnresolvedPluginCompatibility();
    });
    $scope.$on('pluginRemoved', $scope.buildUnresolvedPluginCompatibility);
    $scope.$on('pluginRecovered', $scope.buildUnresolvedPluginCompatibility);
    $scope.$on('pluginAdded', $scope.buildUnresolvedPluginCompatibility);
    $scope.$on('customPluginAdded', $scope.buildUnresolvedPluginCompatibility);
    $scope.$on('modRemoved', function(event, modId) {
        $scope.removeCompatibilityNotes(modId);
        $scope.buildUnresolvedPluginCompatibility();
    });
    $scope.$on('modRecovered', function(event, modId) {
        $scope.recoverCompatibilityNotes(modId);
        $scope.buildUnresolvedPluginCompatibility();
    });
    $scope.$on('modAdded', function(event, modData) {
        $scope.notes.plugin_compatibility.unite(modData.plugin_compatibility_notes);
        $scope.buildUnresolvedPluginCompatibility();
    });
});