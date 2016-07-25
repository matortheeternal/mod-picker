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

// concatenates array1 with array2 and assigns the result to a1
// does nothing if either array1 or array2 are undefined
Array.prototype.unite = function(array1, array2) {
    if (array1 && array2) {
        //noinspection JSUnusedAssignment
        array1 = Array.prototype.concat(array1, array2);
    }
};