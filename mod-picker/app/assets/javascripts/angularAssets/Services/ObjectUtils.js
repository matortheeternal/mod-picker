app.service('objectUtils', function () {
    var service = this;

    this.shallowCopy = function(original) {
        // First create an empty object with
        // same prototype of our original source
        var clone = Object.create(Object.getPrototypeOf(original));

        var i, keys = Object.getOwnPropertyNames(original);

        for (i = 0; i < keys.length; i++) {
            // copy each property into the clone
            Object.defineProperty(clone, keys[i],
                Object.getOwnPropertyDescriptor(original, keys[i])
            );
        }

        return clone;
    };

    this.deepValue = function(obj, path){
        for (var i = 0, path = path.split('.'), len = path.length; i < len; i++) {
            if (path[i] in obj) {
                obj = obj[path[i]];
            } else {
                return null;
            }
        }
        return obj;
    };

    this.setDeepValue = function(obj, path, value) {
        for (var i = 0, path = path.split('.'), len = path.length; i < len; i++) {
            if (i == len - 1) {
                obj[path[i]] = value;
            } else if (path[i] in obj) {
                obj = obj[path[i]];
            } else {
                obj[path[i]] = {};
                obj = obj[path[i]];
            }
        }
    };

    this.getDifferentProperties = function(obj, otherObj) {
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
    };

    this.isEmptyObject = function(obj) {
        for (var property in obj) {
            if (obj.hasOwnProperty(property)) {
                return false;
            }
        }
        return true;
    };

    this.deleteEmptyProperties = function(obj, recurse) {
        for (var property in obj) {
            if (obj.hasOwnProperty(property)) {
                var v = obj[property];
                var vt = typeof v;
                if (vt === 'undefined' || (v.constructor === Array && !v.length)) {
                    delete obj[property];
                } else if (recurse && vt === 'object') {
                    service.deleteEmptyProperties(v, recurse - 1);
                }
            }
        }
    };

    this.getShortTypeString = function(obj) {
        switch (typeof obj) {
            case 'number':
                return (obj % 1 === 0) ? 'int' : 'float';
            case 'boolean':
                return 'bool';
            default:
                return 'string';
        }
    };
});