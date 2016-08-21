app.filter('bytes', function() {
    return function(number, precision) {
        if (isNaN(parseFloat(number)) || !isFinite(number)) return '-';
        return number.toBytes(precision);
    }
});