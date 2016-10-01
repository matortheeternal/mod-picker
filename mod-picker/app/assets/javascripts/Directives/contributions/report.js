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

app.controller('reportController', function($scope, $sce, $interpolate, reportsFactory, contributionService) {
    // inherited scope values
    angular.inherit($scope, 'report');
    angular.inherit($scope, 'globalPermissions');
    

    var linkTemplate = reportsFactory.contentLink($scope.report);
    $scope.reportableUrl = $sce.trustAsHtml($interpolate(linkTemplate)($scope));

    $scope.hideTag = function(hidden) {
        contributionService.hide('tags', $scope.report.reportable.id, hidden).then(function (data) {
            // TODO: emit successful notification
            $scope.report.reportable.hidden = hidden;
        }, function(response) {
            var approveStr = hidden ? 'hiding' : 'unhiding';
            var params = {
                label: 'Error ' + approveStr + ' comment',
                response: response
            };
            $scope.$emit($scope.errorEvent, params);
        });
    };
});
