String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
};

String.prototype.titleCase = function() {
    return this.replace(/[^-'\s]+/g, function(word) {
        return word.replace(/^./, function(first) {
            return first.toUpperCase();
        });
    });
};

String.prototype.toDashFormat = function() {
    return this.replace(/[A-Z]/g, function(uppercaseLetter) {
        return "-" + uppercaseLetter.toLowerCase();
    })
};

String.prototype.wordCount = function() {
    return this.length ? this.match(/(\S+)/g).length : 0;
};

String.prototype.surround = function(str) {
    return str + this + str;
};

String.prototype.reduceText = function(numWords) {
    var lines = this.split('\n');
    var result = '';
    while (result.wordCount() < numWords && lines.length) {
        result += lines.shift() + '\n';
    }
    return result.trim();
};

// convert integer to a bytes string
Number.prototype.toBytes = function(precision) {
    if (typeof precision === 'undefined') precision = 1;
    var units = ['bytes', 'kB', 'MB', 'GB', 'TB', 'PB'],
        number = Math.floor(Math.log(this) / Math.log(1024));
    return (this / Math.pow(1024, Math.floor(number))).toFixed(precision) +  ' ' + units[number];
};

// parse input bytes string into an integer
Number.prototype.parseBytes = function(bytesString) {
    var sp = bytesString.split(' ');
    if (!sp || sp.length < 2) return 0;
    var units = ['bytes', 'kB', 'MB', 'GB', 'TB', 'PB'];
    var power = units.indexOf(sp[1]);
    if (power == -1) {
        return 0;
    } else {
        return Math.floor(Number.parseFloat(sp[0]) * Math.pow(1024, power));
    }
};

// concatenates array1 with array2 and assigns the result to a1
// does nothing if either array1 or array2 are undefined
Array.prototype.unite = function(array1, array2) {
    if (array1 && array2) {
        for (var i = 0; i < array2.length; i++) {
            array1.push(array2[i]);
        }
    }
};

// gets a random item from the array
Array.prototype.random = function () {
    return this[Math.floor((Math.random() * this.length))];
};

// angular polyfills
angular.inherit = function(scope, attribute) {
    if (angular.isUndefined(scope[attribute])) {
        scope[attribute] = scope.$parent[attribute];
    }
};