app.directive('codeEditor', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/codeEditor.html',
        scope: {
            data: '=',
            mode: '=?'
        },
        link: function(scope, element, attrs) {
            // get text area element and turn it into a codemirror editor
            var textarea = element.children()[0];
            var cm = CodeMirror.fromTextArea(textarea, {
                lineWrapping: true,
                lineNumbers: true,
                mode: scope.mode
            });
            var doc = cm.getDoc();
            doc.setValue(scope.data);

            // two-way data binding to and from editor
            scope.$watch('data', function(newVal){
                if ((typeof newVal === "string") && (newVal !== doc.getValue())) {
                    doc.setValue(newVal);
                }
            });

            // two-way data binding of code mode
            scope.$watch('mode', function(newVal) {
                if ((typeof newVal === "string") && (newVal !== cm.getOption('mode'))) {
                    cm.setOption('mode', newVal);
                }
            });
        }
    }
});
