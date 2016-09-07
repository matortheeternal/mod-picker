app.directive('tagInput', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/tagInput.html',
        controller: 'tagInputController',
        scope: {
            tags: '=',
            tag: '=',
            canCreate: '=',
            applyTag: '=',
            removeTag: '=',
            addTag: '=',
            index: '=',
            last: '='
        }
    }
});

app.controller('tagInputController', function($scope, $timeout, formUtils) {
    // set some constants
    var pause = 200;
    var minLength = 1;

    // inherited functions
    $scope.focusText = formUtils.focusText;

    $scope.hoverRow = function(index) {
        $scope.currentIndex = index;
    };

    $scope.searchTags = function(str) {
        // Begin the search
        str = str.toLowerCase();
        if (str.length > 0) {
            var matches = [];

            for (var i = 0; i < $scope.tags.length; i++) {
                var tag = $scope.tags[i];
                var match = tag.text.toLowerCase().startsWith(str);

                if (match) {
                    matches[matches.length] = tag;
                }
            }

            $scope.searching = false;
            $scope.results = matches;
            $scope.$applyAsync();
        }
    };

    $scope.selectResult = function(result) {
        $scope.tag = result;
        $scope.applyTag($scope.index, result);
        $scope.showDropdown = false;
        $scope.results = [];
        $scope.$applyAsync();
    };

    $scope.blurTag = function() {
        // we have to use a timeout because otherwise we would test
        // the tag before the click event on a result went through
        $timeout(function() {
            var isValidTag = $scope.tags.findIndex(function(tag) {
                return tag.text === $scope.tag.text;
            }) > -1;
            if (!(isValidTag || $scope.canCreate) || $scope.tag.text == "") {
                $scope.removeTag($scope.index)
            }
            $scope.showDropdown = false;
        }, 100);
    };

    $scope.keyDown = function ($event) {
        var key = $event.keyCode;
        var len = $event.target.value.length;

        // pressing enter applies dropdown selection and adds a new tag
        if (key == 13) {
            var isValidTag = $scope.tags.indexOf($scope.tag) > -1;
            if ($scope.currentIndex >= 0 && $scope.currentIndex < $scope.results.length) {
                $scope.selectResult($scope.results[$scope.currentIndex]);
            } else if (isValidTag) {
                $scope.showDropdown = false;
                $scope.results = [];
            } else if ($scope.canCreate) {
                $scope.selectResult({
                    text: $scope.tag.text,
                    mods_count: 0,
                    mod_lists_count: 0
                });
            } else {
                return;
            }
            $scope.addTag();
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
        else if(key == 38) {
            if ($scope.currentIndex >= 1) {
                $scope.currentIndex--;
                $scope.$applyAsync();
                $event.preventDefault();
                $event.stopPropagation();
            }
        }
        // pressing escape or delete deletes the tag
        // pressing backspace when the tag is empty deletes the tag
        else if ((key == 27) || (key == 46) || ((key == 8) && (len == 0))) {
            $scope.results = [];
            $scope.showDropdown = false;
            $scope.$applyAsync();
            $scope.removeTag($scope.index);
            $event.preventDefault();
        }
    };

    $scope.keyUp = function ($event) {
        var key = $event.keyCode;
        var len = $event.target.value.length;

        // keys that don't change the value of the input should be ignored
        if ([9, 13, 16, 17, 18, 20, 37, 38, 39, 40, 91].indexOf(key) > -1) {
            // do nothing
        }
        // if field length is less than minimum, hide dropdwon
        else if (len < minLength) {
            $scope.results = [];
            $scope.showDropdown = false;
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
                $scope.searchTags($scope.tag.text);
            }, pause);
        }
    }
});

app.directive('autoSelect', function ($timeout) {
    return function (scope, element, attrs) {
        scope.$watch(attrs.autoSelect, function (newval) {
            if (newval) {
                $timeout(function () {
                    element[0].select();
                }, 0, false);
            }
        });
    };
});