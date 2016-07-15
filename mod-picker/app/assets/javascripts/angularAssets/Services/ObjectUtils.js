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

    this.getDifferentValues = function(v1, v2) {
        var t1 = typeof v1;
        var t2 = typeof v2;
        // type don't match, return new value
        if (t1 !== t2) {
            return v2;
        }
        // switch on types
        switch(t1) {
            // both types undefined - just break (return undefined)
            case "undefined":
                break;
            // special object handling
            case "object":
                // if the value used to be null, return new value
                if (!v1 && v2) {
                    return v2;
                }
                // v1 is null, return
                else if (!v1) {
                    return;
                }
                // handle arrays
                else if (v1.constructor === Array || v2.constructor === Array) {
                    if (v1.constructor === v2.constructor) {
                        var arrayDiff = service.getDifferentArrayValues(v1, v2);
                        // if we have array changes, return them, else return undefined
                        if (arrayDiff.length) {
                            return arrayDiff;
                        }
                    } else {
                        return v2;
                    }
                }
                // else handle objects
                else {
                    return service.getDifferentObjectValues(v1, v2);
                }
                break;
            default:
                // by default just do a direct value comparison
                if (v1 !== v2) {
                    return v2;
                }
        }
    };

    this.getDifferentArrayValues = function(firstArray, secondArray) {
        var result = [];
        var i, firstItem, secondItem, diff;
        // handle array length mismatch
        if (firstArray.length < secondArray.length) {
            for (i = firstArray.length; i < secondArray.length; i++) {
                result.push(secondArray[i]);
            }
        } else if (secondArray.length < firstArray.length) {
            throw "ObjectUtils.getDifferentArrayItems cannot handle array item deletion!  Use a _destroy property instead."
        }
        // add non-equal items to the result array
        var shorterLength = Math.min(firstArray.length, secondArray.length);
        for (i = 0; i < shorterLength; i++) {
            firstItem = firstArray[i];
            secondItem = secondArray[i];
            diff = service.getDifferentValues(firstItem, secondItem);
            if (!diff || service.isEmptyObject(diff)) {
                continue;
            }
            result.push(diff);
        }
        // return the result array
        return result;
    };

    // first object is original, second is changed object
    this.getDifferentObjectValues = function(obj, otherObj) {
        var result = {};
        var foundDifferences = false;
        var diff;
        for (var property in otherObj) {
            if (otherObj.hasOwnProperty(property) && property !== "$$hashKey") {
                diff = service.getDifferentValues(obj[property], otherObj[property]);
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
        if (foundDifferences && otherObj.hasOwnProperty('id')) {
            result.id = otherObj.id;
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