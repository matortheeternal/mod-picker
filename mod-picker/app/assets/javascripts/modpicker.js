//= require_self
//= require_tree ./angularAssets

var app = angular.module('modPicker', [
    'ngRoute', 'rzModule', 'ngAnimate', 'sticky', 'puElasticInput'
]);

app.config(['$httpProvider', '$compileProvider', function ($httpProvider, $compileProvider) {
    $httpProvider.useApplyAsync(true);
    $compileProvider.debugInfoEnabled(false);
}]);


//TODO: remove all this stuff from this pristine beautiful js file!
app.filter('bytes', function() {
    return function(bytes, precision) {
        if (isNaN(parseFloat(bytes)) || !isFinite(bytes)) return '-';
        if (typeof precision === 'undefined') precision = 1;
        var units = ['bytes', 'kB', 'MB', 'GB', 'TB', 'PB'],
            number = Math.floor(Math.log(bytes) / Math.log(1024));
        return (bytes / Math.pow(1024, Math.floor(number))).toFixed(precision) +  ' ' + units[number];
    }
});

function getFileExtension(filename) {
    return filename.split('.').pop();
}

function getBaseName(path) {
    return path.split(/[\\/]/).pop();
}

String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
};

function shallowCopy(original) {
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
}

function deepValue(obj, path){
    for (var i = 0, path = path.split('.'), len = path.length; i < len; i++) {
        obj = obj[path[i]];
    }
    return obj;
}