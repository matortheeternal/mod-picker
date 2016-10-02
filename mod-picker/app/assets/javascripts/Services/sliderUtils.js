app.service('sliderUtils', function($filter) {

    function isPowerOfTen(val) {
        return (Math.log10(val) % 1) == 0;
    }

    this.generateSteps = function(initialSpacing, maxValue) {
        var array = [0];
        var c = 0;
        var spacing = initialSpacing;
        for (i = 1; c < maxValue; i++) {
            c += spacing;
            if (i % 10 == 0) {
                if (isPowerOfTen(c / 2)) {
                    spacing = (c * 1.5) / 10;
                } else {
                    spacing = c / 10;
                }
            }
            array.push(c);
        }

        // set last value to max value
        array[array.length - 1] = maxValue;
        return array;
    };

    this.generateByteSteps = function(maxBytes) {
        var array = ["0"];
        for (i = 64; (i <= maxBytes); i *= 2) {
            array.push($filter('bytes')(i))
        }
        return array;
    };

    this.generateDateSteps = function(minDate) {
        var c = new Date();
        var array = ["Now"];
        var minValue = minDate.getTime();

        // hours
        for (i = 0; (c.getTime() > minValue) && (i < 23); i++) {
            if (i == 0) {
                array.unshift("1 hour ago");
            } else {
                array.unshift((i + 1) + " hours ago");
            }
            c.setHours(c.getHours() - 1);
        }

        // days
        for (i = 0; (c.getTime() > minValue) && (i < 24); i++) {
            array.unshift(c.toLocaleDateString());
            c.setDate(c.getDate() - 1);
        }

        // weeks
        for (i = 0; (c.getTime() > minValue) && (i < 36); i++) {
            array.unshift(c.toLocaleDateString());
            c.setDate(c.getDate() - 7);
        }

        // months
        for (i = 0; (c.getTime() > minValue) && (i < 48); i++) {
            array.unshift(c.toLocaleDateString());
            c.setMonth(c.getMonth() - 1);
        }

        // quarters
        for (i = 0; (c.getTime() > minValue) && (i < 24); i++) {
            array.unshift(c.toLocaleDateString());
            c.setMonth(c.getMonth() - 3);
        }

        // half years
        for (i = 0; (c.getTime() > minValue) && (i < 24); i++) {
            array.unshift(c.toLocaleDateString());
            c.setMonth(c.getMonth() - 6);
        }

        // set first date to min date
        array[0] = minDate.toLocaleDateString();
        return array;
    };
});