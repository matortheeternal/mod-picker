app.directive('modCompatibilityIssues', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/modCompatibilityIssues.html',
        controller: 'modCompatibilityIssuesController',
        scope: false
    }
});

app.controller('modCompatibilityIssuesController', function($scope) {
    $scope.reAddNotes = function(modId) {
        $scope.notes.compatibility.forEach(function(note) {
            if (note._destroy && note.mods[0].id == modId || note.mods[1].id == modId) {
                delete note._destroy;
            }
        });
    };

    $scope.removeNotes = function(modId) {
        $scope.notes.compatibility.forEach(function(note) {
            if (note.mods[0].id == modId || note.mods[1].id == modId) {
                note._destroy = true;
            }
        });
    };

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
                // TODO: Update $scope.mod_list.ignored_notes
                $scope.buildUnresolvedCompatibility();
                break;
        }
    });

    // direct method trigger events
    $scope.$on('rebuildUnresolvedCompatibility', $scope.buildUnresolvedCompatibility);
});