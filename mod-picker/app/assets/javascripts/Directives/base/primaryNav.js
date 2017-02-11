app.directive('primaryNav', function() {
    return {
        priority: 100,
        restrict: 'E',
        templateUrl: '/resources/directives/base/primaryNav.html',
        scope: false,
        controller: 'primaryNavController'
    }
});

app.controller('primaryNavController', function($scope, $rootScope, $timeout, $state, modListService) {
    // toggle navbar dropdowns
    $scope.toggleDropdown = function($event, key) {
        var showKey = 'show' + key + 'Dropdown';
        $scope[showKey] = !$scope[showKey];
        if (!$scope[showKey]) {
            $event.currentTarget.blur();
        }
    };
    $scope.blurDropdown = function(key) {
        var showKey = 'show' + key + 'Dropdown';
        $timeout(function() {
            $scope[showKey] = false;
        }, 250);
    };

    // user selected to start a new mod list
    $scope.newModList = function() {
        var mod_list = {
            game_id: window._current_game_id,
            name: $rootScope.currentUser.username + "'s Mod List",
            // TODO: Should have a default description set on the backend
            description: "A brand new mod list!"
        };

        modListService.newModList(mod_list, true).then(function(data) {
            $rootScope.activeModList = data.mod_list;
            $state.go('base.mod-list', { modListId: data.mod_list.id });
        }, function(response) {
            $state.get('base.error').error = {
                text: 'Error creating new mod list.',
                response: response,
                stateName: 'base',
                stateUrl: window.location.href
            };
            $state.go('base.error');
        });
    };
});