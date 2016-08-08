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

String.prototype.reduceText = function(numWords) {
    var lines = this.split('\n');
    var result = '';
    while (result.wordCount() < numWords && lines.length) {
        result += lines.shift() + '\n';
    }
    return result.trim();
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