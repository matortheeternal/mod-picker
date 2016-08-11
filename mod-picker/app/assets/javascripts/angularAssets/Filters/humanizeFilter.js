app.filter('humanize', function() {
    return function(string, capitalize) {
        result = string.replace(/\_/g, " ");
        return capitalize ? result.titleCase() : result;
    }
});