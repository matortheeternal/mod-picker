/**
 * Created by r79 on 2/11/2016.
 */

//CAREFUL: The scope of the transclude is the one of this directive, not the usual one (the one of its parent)
app.directive('expandable', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/expandable.html',
        controller: 'expandableController',
        scope: {
            expanded: '='
        },
        link: function (scope, element, attrs, ctrl, transclude) {
            transclude(scope, function(clone) {
                element.append(clone);
            });
        },
        transclude: {
            above: '?above',
            content: 'content',
            below: '?below'
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