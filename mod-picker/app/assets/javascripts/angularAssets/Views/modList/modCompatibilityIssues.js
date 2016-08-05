app.directive('modCompatibilityIssues', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/modCompatibilityIssues.html',
        controller: 'modCompatibilityIssuesController',
        scope: false
    }
});

app.controller('modCompatibilityIssuesController', function($scope, listUtils) {
    $scope.showUnresolvedCompatibility = true;

    /* BUILD VIEW MODEL */
    $scope.buildUnresolvedCompatibility = function() {
        $scope.notes.unresolved_compatibility = [];
        $scope.notes.ignored_compatibility = [];
        $scope.notes.compatibility.forEach(function(note) {
            // skip destroyed or ignored notes
            if (note._destroy) {
                return;
            } else if (note.ignored) {
                $scope.notes.ignored_compatibility.push(note);
                return;
            }
            switch (note.status) {
                case 'incompatible':
                case 'partially compatible':
                    // unresolved if both mods are present
                    if ($scope.findMod(note.mods[0].id, true) && $scope.findMod(note.mods[1].id, true)) {
                        note.resolved = false;
                        $scope.notes.unresolved_compatibility.push(note);
                    } else {
                        note.resolved = true;
                    }
                    break;
                case 'compatibility mod':
                    // unresolved if the compatibility mod is not present and both mods are present
                    if (!$scope.findMod(note.compatibility_mod_id, true) &&
                        $scope.findMod(note.mods[0].id, true) && $scope.findMod(note.mods[1].id, true)) {
                        note.resolved = false;
                        $scope.notes.unresolved_compatibility.push(note);
                    } else {
                        note.resolved = true;
                    }
                    break;
            }
        });
    };

    /* UPDATE VIEW MODEL */
    $scope.recoverCompatibilityNotes = function(modId) {
        $scope.notes.compatibility.forEach(function(note) {
            if (note._destroy && note.mods[0].id == modId || note.mods[1].id == modId) {
                delete note._destroy;
            }
        });
    };

    $scope.removeCompatibilityNotes = function(modId) {
        $scope.notes.compatibility.forEach(function(note) {
            if (note.mods[0].id == modId || note.mods[1].id == modId) {
                note._destroy = true;
            }
        });
    };

    /* RESOLUTION ACTIONS */
    $scope.$on('resolveCompatibilityNote', function(event, options) {
        switch(options.action) {
            case "remove":
                var foundMod = $scope.findMod(options.note.mods[options.index].id);
                foundMod && $scope.removeMod(foundMod);
                break;
            case "add mod":
                $scope.addMod(options.note.compatibility_mod.id);
                break;
            case "ignore":
                options.note.ignored = !options.note.ignored;
                $scope.ignoreNote('CompatibilityNote', options.note);
                $scope.buildUnresolvedCompatibility();
                break;
        }
    });

    // event triggers
    $scope.$on('initializeModules', $scope.buildUnresolvedCompatibility);
    $scope.$on('reloadModules', function() {
        listUtils.recoverDestroyed($scope.notes.compatibility);
        $scope.buildUnresolvedCompatibility();
    });
    $scope.$on('saveChanges', function() {
        listUtils.removeDestroyed($scope.notes.compatibility);
        $scope.buildUnresolvedCompatibility();
    });
    $scope.$on('modRemoved', function(event, modId) {
        if (modId) $scope.removeCompatibilityNotes(modId);
        $scope.buildUnresolvedCompatibility();
    });
    $scope.$on('modRecovered', function(event, modId) {
        if (modId) $scope.recoverCompatibilityNotes(modId);
        $scope.buildUnresolvedCompatibility();
    });
    $scope.$on('modAdded', function(event, modData) {
        $scope.notes.compatibility.unite(modData.mod_compatibility_notes);
        $scope.buildUnresolvedCompatibility();
    });
});