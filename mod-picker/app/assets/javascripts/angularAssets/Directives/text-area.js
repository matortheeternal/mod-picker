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
            var data;
            var textarea = element.find("textarea")[0];
            var mde = new SimpleMDE({ element: textarea });

            mde.codemirror.on("change", function(){
                data = mde.value();
                scope.data = data;
            });
        }
    }
});

app.controller('textAreaController', function ($scope) {
});
