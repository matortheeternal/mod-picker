app.filter('picker', function($filter) {
    return function() {
        var filterName = [].splice.call(arguments, 1, 1)[0];
        if (!filterName) {
            return arguments[0];
        }
        else {
            var filterArgs = filterName.split(":");
            filterName = filterArgs.splice(0, 1);
            filterArgs.unshift(arguments[0]);
            return $filter(filterName).apply(null, filterArgs);
        }
    };
});