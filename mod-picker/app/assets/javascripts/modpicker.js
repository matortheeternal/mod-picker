//= require_self
//= require_tree ./angularAssets

var app = angular.module('modPicker', [
    'ngRoute', 'rzModule', 'ngAnimate'
]);

app.config(['$httpProvider', '$compileProvider', function ($httpProvider, $compileProvider) {
    $httpProvider.useApplyAsync(true);
    $compileProvider.debugInfoEnabled(false);
}]);

app.filter('bytes', function() {
    return function(bytes, precision) {
        if (isNaN(parseFloat(bytes)) || !isFinite(bytes)) return '-';
        if (typeof precision === 'undefined') precision = 1;
        var units = ['bytes', 'kB', 'MB', 'GB', 'TB', 'PB'],
            number = Math.floor(Math.log(bytes) / Math.log(1024));
        return (bytes / Math.pow(1024, Math.floor(number))).toFixed(precision) +  ' ' + units[number];
    }
});

//TODO: this definitely needs to be solved differently, even though I don't know how yet
function useTwoColumns(b) {
    if (b) {
        document.body.className = "two-columns";
    } else {
        document.body.className = "";
    }
}

function getFileExtension(filename) {
    return filename.split('.').pop();
}

function getBaseName(path) {
    return path.split(/[\\/]/).pop();
}