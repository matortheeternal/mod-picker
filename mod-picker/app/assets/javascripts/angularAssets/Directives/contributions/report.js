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

app.controller('reportController', function($scope) {
    angular.inherit($scope, 'report');

    // list of reportables where the template will override the outer container 
    // in order to add extra misc information into the outer base report container
    var overrideTemplates = ['Tag'];

    $scope.overrideTemplate = false;

    // checks if reportable_type is within overrideTemplates and toggles overrideTemplate option
    if(overrideTemplates.indexOf($scope.report.reportable_type) > -1) {
        $scope.overrideTemplate = true;
    }
});