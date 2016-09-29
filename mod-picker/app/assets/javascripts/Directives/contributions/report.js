app.directive('report', function() {
    return {
        restrict: 'E',
        scope: {
            showFull: '=?',
            reportable: '=reportable'
        },
        link: function(scope, element, attrs) {
            scope.getTemplateUrl = function() {
                return '/resources/directives/reportables/' + scope.report.reportable_type.toLowerCase() + '.html';
            }
        },
        templateUrl: '/resources/directives/contributions/report.html',
        controller: 'reportController',
    };
});

app.controller('reportController', function($scope, $sce, $interpolate, reportsFactory) {
    angular.inherit($scope, 'report');

    $scope.getReportableUrl = $sce.trustAsHtml($interpolate(reportsFactory.contentLink($scope.report))($scope));
});