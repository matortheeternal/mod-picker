/**
 * Created by Sirius on 3/25/2016.
 */

app.directive('textArea', function ($timeout) {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/shared/textArea.html',
        scope: {
            data: '=',
            onChange: '=?',
            field: '@',
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
                if (scope.onChange) {
                    $timeout(function() {
                        scope.onChange();
                    }, 50);
                }
            });

            scope.$watch('refresh', function(newVal) {
                // Skip undefined or false variables
                if (newVal) {
                    $timeout(function() {
                        mde.codemirror.refresh();
                    });
                }
            });
        }
    }
});
