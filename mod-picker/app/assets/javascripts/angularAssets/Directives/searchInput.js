app.directive('searchInput', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/searchInput.html',
        controller: 'searchInputController',
        scope: {
            resultId: '=',
            searchFunction: '=',
            searchText: '=?',
            placeholder: '=?',
            onChange: '=?',
            excludedId: '=?',
            disabled: '=?',
        }
    }
});

app.controller('searchInputController', function($scope, $timeout, modService, pluginService, userService) {
    // set some constants
    var pause = 700;
    var minLength = 2;
    $scope.defaultPlaceholders = {
        plugins: "Enter plugin name",
        users: "Enter username",
        mods: "Enter mod name",
        tools: "Enter tool name"
    };

    $scope.hoverRow = function(index) {
        $scope.currentIndex = index;
    };

    $scope.search = function(str) {
        // Begin the search
        str = str.toLowerCase();
        if (str.length >= $scope.minLength) {
            $scope.searchFunction(str).then(function(data) {
                $scope.searching = false;
                if ($scope.excludedId) {
                    data = data.filter(function(item) {
                        return item.id !== $scope.excludedId;
                    });
                }
                $scope.results = data;
                $scope.$applyAsync();
            });
        } else {
            $scope.searching = false;
            $scope.showDropdown = false;
            $scope.$applyAsync();
        }
    };

    $scope.selectResult = function(result) {
        $scope.resultId = result.id;
        if ($scope.searchType === 'plugins') {
            $scope.searchText = result.filename;
        } else if ($scope.searchType === 'users') {
            $scope.searchText = result.username;
        } else if ($scope.searchType === 'mods' || $scope.searchType === 'tools')  {
            $scope.searchText = result.name;
        }
        $scope.showDropdown = false;
        $scope.results = [];
        $scope.$applyAsync();
    };

    $scope.blurDropdown = function() {
        // we have to use a timeout for hiding the dropdown because
        // otherwise we would hide it before the click event on a result
        // went through
        $timeout(function() {
            $scope.showDropdown = false;
        }, 100);
    };

    $scope.keyDown = function ($event) {
        var key = $event.keyCode;

        // pressing enter applies dropdown selection
        if (key == 13) {
            if ($scope.currentIndex >= 0 && $scope.currentIndex < $scope.results.length) {
                $scope.selectResult($scope.results[$scope.currentIndex]);
            } else {
                return;
            }
            $event.preventDefault();
            $event.stopPropagation();
        }
        // pressing down moves down the dropdown list
        else if (key == 40) {
            if (($scope.currentIndex + 1) < $scope.results.length) {
                $scope.currentIndex++;
                $scope.$applyAsync();
                $event.preventDefault();
                $event.stopPropagation();
            }
        }
        // pressing up moves up the dropdown list
        else if (key == 38) {
            if ($scope.currentIndex >= 1) {
                $scope.currentIndex--;
                $scope.$applyAsync();
                $event.preventDefault();
                $event.stopPropagation();
            }
        }
    };

    $scope.keyUp = function($event) {
        var key = $event.keyCode;

        // keys that don't change the value of the input should be ignored
        if ([9, 13, 16, 17, 18, 20, 37, 38, 39, 40, 91].indexOf(key) > -1) {
            // do nothing
        }
        // pressing escape, backspace, or delete clears the dropdown
        else if ((key == 27) || (key == 46) || (key == 8)) {
            delete $scope.resultId;
            $scope.results = [];
            $scope.showDropdown = false;
            $scope.$applyAsync();
        }
        else {
            delete $scope.resultId;
            $scope.currentIndex = -1;
            $scope.results = [];

            // clear the search timer
            if ($scope.searchTimer) {
                clearTimeout($scope.searchTimer);
            }

            // search if we have more than minLength characters
            if ($scope.searchText.length >= minLength) {
                $scope.showDropdown = true;

                // search for matching tags
                $scope.searching = true;
                $scope.searchTimer = setTimeout(function () {
                    $scope.search($scope.searchText);
                }, pause);
            }
        }
    };

    $scope.$watch('resultId', function() {
        if ($scope.onChange) {
            $scope.onChange();
        }
    }, true);
});