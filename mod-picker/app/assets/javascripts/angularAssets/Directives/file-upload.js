app.directive('fileModel', ['$parse', function ($parse) {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            var model = $parse(attrs.fileModel);
            var modelSetter = model.assign;

            element.bind('change', function(){
                scope.$apply(function() {
                    if (model(scope)) {
                        modelSetter(scope, model(scope).concat([].slice.call(element[0].files)));
                    } else {
                        modelSetter(scope, [].slice.call(element[0].files));
                    }
                });
            });
        }
    };
}]);