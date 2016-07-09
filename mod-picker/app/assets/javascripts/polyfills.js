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

function getDifferentProperties(obj, otherObj) {
    var result = {};
    for (var property in obj) {
        if (obj.hasOwnProperty(property)) {
            // if we pass absolute equality we skip the property
            var p1 = obj[property];
            var p2 = otherObj[property];
            if (p1 === p2) {
                continue;
            } else if (!!p1 && !!p2) {
                if (p1.toString() === p2.toString()) {
                    continue;
                }
            }
            result[property] = obj[property];
        }
    }
    return result;
}

function deleteEmptyProperties(obj, recurse) {
    for (var property in obj) {
        if (obj.hasOwnProperty(property)) {
            var v = obj[property];
            var vt = typeof v;
            if (vt === 'undefined' || (v.constructor === Array && !v.length)) {
                delete obj[property];
            } else if (recurse && vt === 'object') {
                deleteEmptyProperties(v, recurse - 1);
            }
        }
    }
}

function getShortTypeString(obj) {
    switch (typeof obj) {
        case 'number':
            return (obj % 1 === 0) ? 'int' : 'float';
        case 'boolean':
            return 'bool';
        default:
            return 'string';
    }
}
