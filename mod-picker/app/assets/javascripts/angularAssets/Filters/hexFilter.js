app.filter('hex', function() {
    return function(number, padding) {
        // set up default padding
        padding = typeof padding !== 'undefined' ? padding : 2;
        // convert number to hex
        var hex = Number(number).toString(16).toUpperCase();
        // add 0 padding as necessary
        while (hex.length < padding) {
            hex = "0" + hex;
        }

        return hex;
    }
});