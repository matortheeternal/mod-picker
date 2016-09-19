app.directive('report', function() {
    return {
        restrict: 'E',
        scope: {
            showFull: '=?',
            reportable: '=reportable'
        },
        link: function(scope, element, attrs) {
            scope.getTemplateUrl = function() {
                return '/resources/directives/reportables/' + scope.report.reportable_type + '.html';
            }
        },
        template: '<div ng-include="getTemplateUrl()"></div>',
        controller: 'reportController',
    };
});

app.controller('reportController', function($scope) {
    angular.inherit($scope, 'report');
});