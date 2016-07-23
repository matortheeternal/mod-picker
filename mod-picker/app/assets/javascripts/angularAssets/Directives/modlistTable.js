app.directive('modlistTable', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modlistTable.html',
        controller: 'modlistTableController',
        scope: {
            title: '@',
            modlists: '='
        }
    };
});

app.controller('modlistTableController', function($scope) {
    $scope.append = function(data) {
        var modlists = $scope.user.mod_lists;
        if (data.modlist) {
            modlists.push(data.modlist);
            if (data.modlist.is_collection) {
                $scope.collections.push(data.modlist);
            } else {
                $scope.modlists.push(data.modlist);
            }
            $scope.$apply();
        } else {
            $scope.errors.push({ message: "Didn't receive a cloned mod list from the server" });
        }
    };

    $scope.clone = function(modlist) {
        console.log('Clone Mod list: "' + modlist.name + '"');
        $scope.errors = [];
        userSettingsService.cloneModlist(modlist).then(function(data) {
            if (data.status === "ok") {
                $scope.append(data);
            } else {
                $scope.errors.push(data.status);
            }
        });
    };

    $scope.remove = function(modlist) {
        var modlists = $scope.user.mod_lists;
        var index = modlists.indexOf(modlist);
        modlists.splice(index, 1);
        if (modlist.is_collection) {
            index = $scope.collections.indexOf(modlist);
            $scope.collections.splice(index, 1);
        } else {
            index = $scope.modlists.indexOf(modlist);
            $scope.modlists.splice(index, 1);
        }
        $scope.$apply();
    };

    $scope.delete = function(modlist) {
        console.log('Delete Mod modlist: "' + modlist.name + '"');
        $scope.errors = [];
        userSettingsService.deleteModlist(modlist).then(function(data) {
            if (data.status === "ok") {
                $scope.remove(modlist);
            } else {
                $scope.errors.push({ message: "Delete Mod list: " + data.status });
            }
        });
    };
});
