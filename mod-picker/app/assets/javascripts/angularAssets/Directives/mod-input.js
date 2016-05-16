app.directive('modInput', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/modInput.html',
        controller: 'modInputController',
        scope: {
            resultId: '=',
            excludedId: '=?',
            searchPlugins: '=?'
        }
    }
});

app.controller('modInputController', function($scope, $timeout, modService, pluginService) {
    // set some constants
    var pause = 400;

    $scope.hoverRow = function(index) {
        $scope.currentIndex = index;
    };

    $scope.searchMods = function(str) {
        // Begin the search
        str = str.toLowerCase();
        if (str.length > 3) {
            var searchCallback = function(data) {
                $scope.searching = false;
                $scope.results = data;
                $scope.$applyAsync();
            };
            if ($scope.searchPlugins) {
                pluginService.searchPlugins(str).then(searchCallback);
            } else {
                modService.searchMods(str).then(searchCallback);
            }
        }
    };

    $scope.selectResult = function(result) {
        $scope.resultId = result.id;
        $scope.searchText = result.name;
        $scope.showDropdown = false;
        $scope.results = [];
        $scope.$applyAsync();
    };

    $scope.blurMod = function() {
        // we have to use a timeout for hiding the dropdown because
        // otherwise we would hide it before the click event on a result
        // went through
        $timeout(function() {
            $scope.showDropdown = false;
        }, 100);
    };

    $scope.handleTagKey = function ($event) {
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
        // pressing escape clears the dropdown
        else if (key == 27) {
            $scope.results = [];
            $scope.showDropdown = false;
            $scope.$applyAsync();
            $event.preventDefault();
        }
        else {
            $scope.showDropdown = true;
            $scope.currentIndex = -1;
            $scope.results = [];

            // restart search timer
            if ($scope.searchTimer) {
                clearTimeout($scope.searchTimer);
            }

            // search for matching tags
            $scope.searching = true;
            $scope.searchTimer = setTimeout(function () {
                $scope.searchMods($scope.searchText);
            }, pause);
        }
    };
});