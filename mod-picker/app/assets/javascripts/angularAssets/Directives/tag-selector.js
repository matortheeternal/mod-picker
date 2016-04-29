app.directive('tagSelector', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tagSelector.html',
        controller: 'tagSelectorController',
        scope: {
        	tags: '=',
        	activeTags: '=',
            newTags: '=',
            maxTags: '=',
            showModsCount: '=?',
            showModListsCount: '=?',
            showAuthor: '=?',
            showRemove: '=?',
            showAdd: '=?'
        }
    }
});

app.controller('tagSelectorController', function ($scope) {
    $scope.rawNewTags = [];

    $scope.addTag = function() {
        if ($scope.rawNewTags.length + $scope.activeTags.length < $scope.maxTags) {
            $scope.rawNewTags.push({
                text: "Test", //TODO: replace with something else
                mods_count: 0,
                mod_lists_count: 0
            });
        }
    };
    $scope.focusText = function ($event) {
        $event.target.select();
    };
    $scope.removeTag = function($index) {
        $scope.rawNewTags.splice($index, 1);
        $scope.storeTags();
    };
    $scope.handleTagKey = function ($event, $index) {
        var key = $event.keyCode;
        var len = $event.target.value.length;
        // pressing enter adds a new tag
        if (key == 13)
            $scope.addTag();
        // pressing escape or delete deletes the tag
        // pressing backspace when the tag is empty also deletes the tag
        if (((key == 27) || (key == 46)) || ((key == 8) && (len == 0))) {
            $scope.removeTag($index);
            $event.preventDefault();
        }
    };
    $scope.storeTags = function() {
        $scope.newTags = [];
        for (var i = 0; i < $scope.rawNewTags.length; i++) {
            rawTag = $scope.rawNewTags[i];
            $scope.newTags.push(rawTag.text);
        }
    };
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