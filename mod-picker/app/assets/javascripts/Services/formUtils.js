app.service('formUtils', function($document) {
    var lastFocusedInput;

    this.focusText = function($event) {
        if ($event.target === lastFocusedInput) return;
        $event.target.select();
        lastFocusedInput = $event.target;
    };

    this.hideWhenDocumentClicked = function(viewBoolean) {
        return function(scope, element) {
            $document.on('click', function(e) {
                if (element == e.target || element[0].contains(e.target)) return;
                scope.$applyAsync(function() {
                    scope[viewBoolean] = false;
                });
            });
        };
    };

    this.unfocusModal = function(callback) {
        return function(e) {
            if (e.target.classList.contains("modal-container")) {
                callback(false);
            }
        }
    };
});