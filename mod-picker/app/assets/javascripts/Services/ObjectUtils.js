app.service('objectUtils', function() {
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
            if (obj && (path[i] in obj)) {
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

    this.getDifferentArrayObjectValues = function(newItem, oldArray, result) {
        // new items that have an id should exist in the oldArray
        // find and compare them against their corresponding item in oldArray
        if (newItem.hasOwnProperty('id')) {
            var oldItem = oldArray.find(function(item) {
                return item.id == newItem.id;
            });
            var diff = oldItem && service.getDifferentValues(oldItem, newItem);
            if (!diff || service.isEmptyObject(diff)) return;
            result.push(diff);
        } else {
            result.push(newItem);
        }
    };

    this.getDifferentArrayValues = function(oldArray, newArray) {
        var result = [];
        var i, newItem;
        for (i = 0; i < newArray.length; i++) {
            newItem = newArray[i];
            if (typeof newItem === 'object') {
                service.getDifferentArrayObjectValues(newItem, oldArray, result);
            } else {
                var oldItem = oldArray.find(function(item) {
                    return item === newItem;
                });
                if (!oldItem) {
                    result.push(newItem);
                }
            }
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
                if (typeof diff !== 'undefined' && (typeof diff !== 'object' ||
                    diff == null || !service.isEmptyObject(diff))) {
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

    this.remapProperties = function(json, map) {
        for (var property in map) {
            if (map.hasOwnProperty(property)) {
                var oldVal = property.surround('"');
                var newVal = map[property].surround('"');
                json = json.replace(new RegExp(oldVal, 'g'), newVal);
            }
        }
        return json;
    };

    this.deleteEmptyProperties = function(obj, recurse, deleteEmptyStrings) {
        for (var property in obj) {
            if (obj.hasOwnProperty(property)) {
                var v = obj[property];
                var vt = typeof v;
                if (v === null) continue;
                if (vt === 'undefined' || (v.constructor === Array && !v.length) || (deleteEmptyStrings && v === "")) {
                    delete obj[property];
                } else if (recurse && vt === 'object') {
                    service.deleteEmptyProperties(v, recurse - 1, deleteEmptyStrings);
                }
            }
        }
    };

    this.keysCount = function(obj) {
        var count = 0;
        for (var key in obj) {
            if (obj.hasOwnProperty(key)) count++;
        }
        return count;
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

    this.isEmptyArray = function(arr) {
        var empty = true;
        arr && arr.forEach(function(item) {
            empty = empty && !!item._destroy;
        });
        return empty;
    };

    this.cleanAttributes = function(obj, base) {
        obj = angular.copy(obj);
        for (var prop in obj) {
            if (!obj.hasOwnProperty(prop)) continue;
            if (base.hasOwnProperty(prop)) {
                // recursion if obj and base properties are both objects
                if (typeof obj[prop] === 'object') {
                    if (typeof base[prop] === 'object') {
                        service.cleanAttributes(obj[prop], base[prop]);
                    } else if (obj[prop] !== null) {
                        // delete property if it's a non-null object and the base property isn't
                        delete obj[prop];
                    }
                }
            } else {
                // delete property if base doesn't have it
                delete obj[prop];
            }
        }
        return obj;
    };

    this.csv = function(obj, separator) {
        var a = [];
        for (var prop in obj) {
            if (obj.hasOwnProperty(prop)) {
                a.push(obj[prop]);
            }
        }
        return a.join(separator || ',');
    }
});