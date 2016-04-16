app.directive('tagSelector', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/tagSelector.html',
        controller: 'tagSelectorController',
        scope: {
        	tags: '=',
        	activeTags: '=',
            newTags: '=',
            maxTags: '=?',
            showModsCount: '=?',
            showModListsCount: '=?',
            showAuthor: '=?',
            showRemove: '=?',
            showAdd: '=?'
        }
    }
});

app.controller('tagSelectorController', function ($scope) {
    $scope.addTag = function() {
        $scope.newTags.push({
            text: "Test",
            mods_count: 0
        });
    };
    $scope.focusText = function ($event) {
        $event.target.select();
    };
    $scope.handleKey = function ($event, $index) {
        var key = $event.keyCode;
        var len = $event.target.value.length;
        // pressing enter adds a new tag
        if (key == 13)
            $scope.addTag();
        // pressing escape or delete deletes the tag
        // pressing backspace when the tag is empty also deletes the tag
        if (((key == 27) || (key == 46)) || ((key == 8) && (len == 0))) {
            $scope.newTags.splice($index, 1);
        }
    };
});

app.directive('toFocus', function ($timeout) {
    return function (scope, elem, attrs) {
        scope.$watch(attrs.toFocus, function (newval) {
            if (newval) {
                $timeout(function () {
                    elem[0].focus();
                    elem[0].select();
                }, 0, false);
            }
        });
    };
});