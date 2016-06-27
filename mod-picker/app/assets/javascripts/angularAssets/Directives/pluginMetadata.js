app.directive('pluginMetadata', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/pluginMetadata.html',
        scope: {
            plugin: '=',
            showRecordGroups: '=?'
        }
    }
});