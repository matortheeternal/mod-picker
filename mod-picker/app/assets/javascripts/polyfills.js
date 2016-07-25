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