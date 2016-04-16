/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('textArea', function ($timeout) {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/textArea.html',
        controller: 'textAreaController',
        scope: {
            data: '=',
            refresh: '=ngRefresh'
        },
        link: function(scope, element, attrs) {
            // get text area element and turn it into a markdown editor
            var textarea = element.children()[0];
            var mde = new SimpleMDE({ element: textarea, spellChecker: false });

            // two-way data binding to and from mde
            scope.$watch('data', function(newVal){
                if ((typeof newVal === "string") && (newVal !== mde.value())) {
                    mde.value(newVal);
                }
            });
            mde.codemirror.on("change", function(){
                scope.data = mde.value();
                scope.$applyAsync();
            });

            scope.$watch('refresh', function(newVal, oldVal) {
                // Skip the initial watch firing
                if (newVal !== oldVal) {
                    $timeout(function() {
                        mde.codemirror.refresh();
                    });
                }
            });
        }
    }
});

app.controller('textAreaController', function ($scope) {
});
