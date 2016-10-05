app.service('formUtils', function() {
    this.focusText = function($event) {
        $event.target.select();
    };
});