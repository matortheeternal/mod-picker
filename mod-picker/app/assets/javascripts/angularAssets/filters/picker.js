app.filter('picker', function($filter) {
    return function() {
        var filterName = [].splice.call(arguments, 1, 1)[0];
        if (!filterName) {
            return arguments[0];
        }
        else {
            return $filter(filterName).apply(null, arguments);
        }
    };
});