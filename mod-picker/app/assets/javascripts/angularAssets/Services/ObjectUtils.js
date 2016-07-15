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

    this.getDifferentValues = function(oldValue, newValue) {
        var oldType = typeof oldValue;
        var newType = typeof newValue;
        // type don't match, return new value
        if (oldType !== newType) {
            return newValue;
        }
        // switch on types
        switch(oldType) {
            // both types undefined - just break (return undefined)
            case "undefined":
                break;
            // special object handling
            case "object":
                // if the value used to be null, return new value
                if (!oldValue && newValue) {
                    return newValue;
                }
                // newValue is null, return undefined
                else if (!newValue) {
                    return;
                }
                // handle arrays
                else if (oldValue.constructor === Array || newValue.constructor === Array) {
                    if (oldValue.constructor === newValue.constructor) {
                        var arrayDiff = service.getDifferentArrayValues(oldValue, newValue);
                        // if we have array changes, return them, else return undefined
                        if (arrayDiff.length) {
                            return arrayDiff;
                        }
                    } else {
                        return newValue;
                    }
                }
                // else handle objects
                else {
                    return service.getDifferentObjectValues(oldValue, newValue);
                }
                break;
            default:
                // by default just do a direct value comparison
                if (oldValue !== newValue) {
                    return newValue;
                }
        }
    };

    this.getDifferentArrayValues = function(oldArray, newArray) {
        var result = [];
        var i, oldItem, newItem, diff;
        // handle array length mismatch
        if (oldArray.length < newArray.length) {
            for (i = oldArray.length; i < newArray.length; i++) {
                result.push(newArray[i]);
            }
        } else if (newArray.length < oldArray.length) {
            throw "ObjectUtils.getDifferentArrayItems cannot handle array item deletion!  Use a _destroy property instead."
        }
        // add non-equal items to the result array
        var shorterLength = Math.min(oldArray.length, newArray.length);
        for (i = 0; i < shorterLength; i++) {
            oldItem = oldArray[i];
            newItem = newArray[i];
            diff = service.getDifferentValues(oldItem, newItem);
            if (!diff || service.isEmptyObject(diff)) {
                continue;
            }
            result.push(diff);
        }
        // return the result array
        return result;
    };

    // first object is original, second is changed object
    this.getDifferentObjectValues = function(oldObj, newObj) {
        var result = {};
        var foundDifferences = false;
        var diff;
        for (var property in newObj) {
            if (newObj.hasOwnProperty(property) && property !== "$$hashKey") {
                diff = service.getDifferentValues(oldObj[property], newObj[property]);
                // if there are differences, we save them
                if (typeof diff !== 'undefined' &&
                   (typeof diff !== 'object' || !service.isEmptyObject(diff))) {
                    foundDifferences = true;
                    result[property] = diff;
                }
            }
        }
        // if we found differences and the source object has an id property
        // save the id property to the result object
        if (foundDifferences && newObj.hasOwnProperty('id')) {
            result.id = newObj.id;
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