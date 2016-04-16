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