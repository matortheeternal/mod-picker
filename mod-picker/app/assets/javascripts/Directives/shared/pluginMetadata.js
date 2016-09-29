app.directive('pluginMetadata', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/pluginMetadata.html',
        scope: {
            plugin: '=',
            showRecordGroups: '=?'
        }
    }
});