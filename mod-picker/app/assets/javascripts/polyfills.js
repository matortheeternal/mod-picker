String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
};

String.prototype.uncapitalize = function() {
    return this.charAt(0).toLowerCase() + this.slice(1);
};

String.prototype.titleCase = function() {
    return this.replace(/[^-'\s]+/g, function(word) {
        return word.replace(/^./, function(first) {
            return first.toUpperCase();
        });
    });
};

String.prototype.toCamelCase = function() {
    return this.uncapitalize().replace(/(\s|\-|\_|\.)+(.)/g, function(match) {
        return match.slice(-1).toUpperCase();
    });
};

String.prototype.startsWith = function(needle) {
    return (this.indexOf(needle) == 0);
};

String.prototype.toPascalCase = function() {
    return this.toCamelCase().capitalize();
};

String.prototype.underscore = function(separator) {
    if (!separator) separator = "_";
    return this.toCamelCase().replace(/[A-Z]/g, function(match) {
        return separator + match.toLowerCase();
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

String.prototype.wordwrap = function(width, brk, cut) {
    brk = brk || '\n';
    width = width || 60;
    var regex = '.{1,' +width+ '}(\\s|$)' + (cut ? '|.{' +width+ '}|.+$' : '|\\S+?(\\s|$)');

    return this.match(new RegExp(regex, 'g')).map(function(str) {
        return str.trim()
    }).join(brk);
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

// concatenates this with array and assigns the result to this
// does nothing if either this or array are undefined
Array.prototype.unite = function(array) {
    if (this && array) {
        for (var i = 0; i < array.length; i++) {
            this.push(array[i]);
        }
    }
};

// gets a random item from the array
Array.prototype.random = function() {
    return this[Math.floor((Math.random() * this.length))];
};

Array.prototype.contains = function(needle) {
    return (this.indexOf(needle) > -1);
};

// angular polyfills
angular.inherit = function(scope, attribute) {
    if (angular.isUndefined(scope[attribute])) {
        scope[attribute] = scope.$parent[attribute];
    }
};

angular.default = function(scope, attribute, value) {
    if (angular.isUndefined(scope[attribute])) {
        scope[attribute] = value;
    }
};