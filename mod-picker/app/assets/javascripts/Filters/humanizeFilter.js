app.filter('humanize', function() {
    return function(string, capitalize) {
        if (!string) return;
        result = string.replace(/\_/g, " ");
        return capitalize ? result.titleCase() : result;
    }
});