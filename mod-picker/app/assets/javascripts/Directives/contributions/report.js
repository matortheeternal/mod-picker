app.directive('report', function() {
    return {
        restrict: 'E',
        scope: {
            showFull: '=?',
            reportable: '=reportable'
        },
        link: function(scope) {
            scope.getTemplateUrl = function() {
                return '/resources/directives/reportables/' + scope.report.reportable_type + '.html';
            }
        },
        templateUrl: '/resources/directives/contributions/report.html',
        controller: 'reportController'
    };
});

app.controller('reportController', function($scope, $sce, $interpolate, reportService, reportsFactory) {
    angular.inherit($scope, 'report');

    var linkTemplate = reportsFactory.contentLink($scope.report);
    $scope.reportableUrl = $sce.trustAsHtml($interpolate(linkTemplate)($scope));

    $scope.toggleResolved = function() {
        var newResolvedValue = !$scope.report.resolved;
        reportService.resolveReport($scope.report.id, newResolvedValue).then(function() {
            $scope.report.resolved = newResolvedValue;
            var resolvedText = newResolvedValue ? 'resolved' : 'unresolved';
            $scope.$emit('successMessage', 'Report marked as '+resolvedText);
        }, function(response) {
            var params = { label: 'Error resolving report', response: response };
            $scope.$emit('errorMessage', params);
        });
    };
});
