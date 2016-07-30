app.directive('modInstallOrderIssues', function() {
    return {
        restrict: 'E',
        replace: true,
        templateUrl: '/resources/partials/modList/modInstallOrderIssues.html',
        controller: 'modInstallOrderIssuesController',
        scope: false
    }
});

app.controller('modInstallOrderIssuesController', function($scope) {
    $scope.reAddNotes = function(modId) {
        $scope.notes.install_order.forEach(function(note) {
            if (note._destroy && note.mods[0].id == modId || note.mods[1].id == modId) {
                delete note._destroy;
            }
        });
    };

    $scope.removeNotes = function(modId) {
        $scope.notes.install_order.forEach(function(note) {
            if (note.mods[0].id == modId || note.mods[1].id == modId) {
                note._destroy = true;
            }
        });
    };

    $scope.buildUnresolvedInstallOrder = function() {
        $scope.notes.unresolved_install_order = [];
        $scope.notes.ignored_install_order = [];
        $scope.notes.install_order.forEach(function(note) {
            // skip destroyed or ignored notes
            if (note._destroy) {
                return;
            } else if (note.ignored) {
                $scope.notes.ignored_install_order.push(note);
                return;
            }
            var first_mod = $scope.findMod(note.mods[0].id, true);
            var second_mod = $scope.findMod(note.mods[1].id, true);
            // unresolved if the both mods are present and the first mod comes after the second mod
            if (first_mod && second_mod && first_mod.index > second_mod.index) {
                note.resolved = false;
                $scope.notes.unresolved_install_order.push(note);
            } else {
                note.resolved = true;
            }
        });
    };

    $scope.$on('resolveInstallOrderNote', function(event, options) {
        switch(options.action) {
            case "move":
                var moveOptions = {
                    moveId: options.note.mods[options.index].id,
                    destId: options.note.mods[+!options.index].id,
                    after: !!options.index
                };
                $scope.$broadcast('moveItem', moveOptions);
                break;
            case "ignore":
                options.note.ignored = !options.note.ignored;
                // TODO: Update $scope.mod_list.ignored_notes
                $scope.buildUnresolvedInstallOrder();
                break;
        }
    });

    // direct method trigger events
    $scope.$on('rebuildUnresolvedInstallOrder', $scope.buildUnresolvedInstallOrder);
});