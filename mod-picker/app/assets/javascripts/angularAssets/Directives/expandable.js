/**
 * Created by r79 on 2/11/2016.
 */

app.directive('expandable', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/expandable.html',
        controller: 'expandableController',
        scope: {
            expanded: '=',
            disableStyle: '<?disableStyle',
            disableFullTitleToggle: '<?disableFullTitleToggle'
        },
        transclude: {
            title: '?expandedTitle',
            expandedIcon: '?expandedIcon',
            collapsedIcon: '?collapsedIcon',
            content: 'content'
        }
    }
});

app.controller('expandableController', function ($scope) {
    $scope.toggle = function (fullTitle) {
        if($scope.disableFullTitleToggle ? !fullTitle : fullTitle) {
            $scope.expanded = !$scope.expanded;
        }
    }
});