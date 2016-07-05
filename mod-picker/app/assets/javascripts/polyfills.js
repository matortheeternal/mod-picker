String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
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
            if (typeof obj[property] === 'undefined' || (obj[property].constructor === Array && !obj.length)) {
                delete obj[property];
            } else if (recurse && typeof obj[property] === 'object') {
                deleteNullProperties(obj[property], recurse - 1);
            }
        }
    }
}