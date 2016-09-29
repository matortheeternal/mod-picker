app.filter('bytes', function() {
    return function(number, precision) {
        if (typeof number === "string") number = parseInt(number);
        if (isNaN(parseFloat(number)) || !isFinite(number)) return '-';
        return number.toBytes(precision);
    }
});