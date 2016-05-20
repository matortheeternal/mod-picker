app.directive('fileChange', ['$parse', function () {
    return {
        restrict: 'A',
        //TODO: I feel like this should work without a link attribute
        link: function(scope, element, attrs) {
            //TODO: and definitely without an evil eval
            var onChangeHandler = scope.$eval(attrs.fileChange);
            element.bind('change', onChangeHandler);
        }
    };
}]);