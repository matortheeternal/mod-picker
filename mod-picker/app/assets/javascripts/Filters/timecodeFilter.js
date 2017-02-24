app.filter('timecode', function() {
    return function(number) {
        if (typeof number === "string") number = parseInt(number);
        var pad = function(num, size) {
            var s = num + "";
            while (s.length < size) s = "0" + s;
            return s;
        };
        var minutes = Math.floor(number / 60);
        var seconds = number % 60;
        return pad(minutes, 2) + ":" + pad(seconds, 2);
    }
});