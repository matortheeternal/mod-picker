/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('textArea', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/textArea.html',
        controller: 'textAreaController',
        scope: {
            data: '='
        },
        link: function(scope, element, attrs) {
            // get text area element and turn it into a markdown editor
            var textarea = element.find("textarea")[0];
            var mde = new SimpleMDE({ element: textarea });

            // two-way data binding to and from mde
            scope.$watch('data', function(value){
                if (mde.value() !== value) {
                    mde.value(value);
                    scope.$apply();
                }
            });
            mde.codemirror.on("change", function(){
                scope.data = mde.value();
                scope.$apply();
            });
        }
    }
});

app.controller('textAreaController', function ($scope) {
});
