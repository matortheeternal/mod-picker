app.directive('textArea', function($timeout) {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/textArea.html',
        scope: {
            data: '=',
            onChange: '=?',
            charCount: '=?',
            minCharCount: '@?',
            maxCharCount: '@?',
            field: '@',
            refresh: '=ngRefresh'
        },
        link: function(scope, element, attrs) {
            var user = scope.$root.currentUser;
            var enableSpellCheck = user && user.settings && user.settings.enable_spellcheck;
            var characterStatusElement;
            var changeTimeout;

            // character status helpers
            var getCharacterStatusClass = function(charCount) {
                var a = ['characters'];
                if (charCount < scope.minCharCount) a.push('too-few');
                if (charCount > scope.maxCharCount) a.push('too-many');
                return a.join(' ');
            };
            var getCharacterStatusText = function(charCount) {
                if (charCount * 1.5 >= scope.maxCharCount) {
                    return (charCount || '?') + ' / ' + scope.maxCharCount;
                } else {
                    return (charCount || '?') + ' / ' + scope.minCharCount;
                }
            };
            var getCharacterStatusTitle = function(charCount) {
                if (charCount < scope.minCharCount)
                    return "Your text is too short. The minimum \nlength required is " + scope.minCharCount + " characters.";
                if (charCount > scope.maxCharCount)
                    return "Your text is too long. The maximum \nlength allowed is " + scope.maxCharCount + " characters.";
            };
            var updateCharacterStatus = function(charCount) {
                characterStatusElement.className = getCharacterStatusClass(charCount);
                characterStatusElement.innerText = getCharacterStatusText(charCount);
                characterStatusElement.title = getCharacterStatusTitle(charCount) || '';
            };
            var setCharacterStatusElement = function(element) {
                characterStatusElement = element;
                updateCharacterStatus(scope.charCount);
            };

            // get text area element and turn it into a markdown editor
            var mdeStatusArray = ["autosave", "lines", "words"];
            if (scope.minCharCount) mdeStatusArray.push({
                className: "characters",
                defaultValue: function(el) {
                    setCharacterStatusElement(el);
                }
            });
            var textarea = element.children()[0];
            var mde = new SimpleMDE({
                element: textarea,
                autosave: true,
                spellChecker: enableSpellCheck,
                status: mdeStatusArray
            });

            // watch charCount so we can update the character status element
            if (scope.minCharCount) {
                scope.$watch('charCount', function(newVal) {
                    if (!characterStatusElement) return;
                    updateCharacterStatus(newVal);
                });
            }

            // two-way data binding to and from mde
            scope.$watch('data', function(newVal){
                if ((typeof newVal === "string") && (newVal !== mde.value())) {
                    mde.value(newVal);
                }
            });
            var mdeChanged = function() {
                scope.data = mde.value();
                scope.$applyAsync();
                if (scope.onChange) {
                    $timeout(function() {
                        scope.onChange();
                    }, 50);
                }
            };
            mde.codemirror.on("change", function() {
                clearTimeout(changeTimeout);
                setTimeout(mdeChanged, 100);
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
