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

app.controller('reportController', function($scope, $sce, $interpolate, reportsFactory) {
    angular.inherit($scope, 'report');

    var linkTemplate = reportsFactory.contentLink($scope.report);
    $scope.reportableUrl = $sce.trustAsHtml($interpolate(linkTemplate)($scope));
});
