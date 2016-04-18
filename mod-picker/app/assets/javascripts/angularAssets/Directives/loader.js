/**
 * Created by r79 on 2/11/2016.
 */

app.directive('loader', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/loader.html',
        scope: {
            data: '=',
            contentClass: '@'
        },
        controller: 'loaderController',
        transclude: true,
        link: function(scope, element, attrs) {
            // TODO: use a factory for this
            var opts = {
                lines: 17, // The number of lines to draw
                length: 0, // The length of each line
                width: 12, // The line thickness
                radius: 50, // The radius of the inner circle
                scale: 1, // Scales overall size of the spinner
                corners: 0, // Corner roundness (0..1)
                color: '#000', // #rgb or #rrggbb or array of colors
                opacity: 0.05, // Opacity of the lines
                rotate: 0, // The rotation offset
                direction: 1, // 1: clockwise, -1: counterclockwise
                speed: 0.9, // Rounds per second
                trail: 70, // Afterglow percentage
                fps: 20, // Frames per second when using setTimeout() as a fallback for CSS
                zIndex: 2, // The z-index (defaults to 2000000000)
                className: 'spinner', // The CSS class to assign to the spinner
                top: '100px', // Top position relative to parent
                left: '50%', // Left position relative to parent
                shadow: false, // Whether to render a shadow
                hwaccel: false, // Whether to use hardware acceleration
                position: 'relative' // Element positioning
            };
            var target = element.children()[0];
            var spinner = new Spinner(opts).spin(target);
        }
    }
});

app.controller('loaderController', function ($scope) {
    $scope.showSpinner = false;
    $scope.$watch('data', function (newValue) {
        $scope.showSpinner = !newValue;
    });
});