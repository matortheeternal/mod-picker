/**
 * Created by r79 on 2/11/2016.
 */

app.directive('loader', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/loader.html',
        scope: {
            condition: '=',
            size: '='
        },
        controller: 'loaderController'
    }
});

app.controller('loaderController', function ($scope) {
    var diameter = $scope.size || 100;
    document.getElementById('loader').style.width = diameter + 'px';
    var cl = new CanvasLoader('loader');
    cl.setColor('#c0a060'); // default is '#000000'
    cl.setDiameter(diameter); // default is 40
    cl.setDensity(64); // default is 40
    cl.setRange(0.8); // default is 1.3
    cl.setFPS(60); // default is 24

    if ($scope.condition) {
        cl.show();
    }

    $scope.$watch('condition', function (newValue) {
        if (newValue) {
            cl.show();
        } else {
            cl.hide();
        }
    });
});