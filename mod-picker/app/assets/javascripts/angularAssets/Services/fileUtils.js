app.service('fileUtils', function() {
    this.getFileExtension = function(filename) {
        var ary = filename.split('.');
        return ary.length == 1 ? "" : ary.pop();
    };

    this.getBaseName = function(path) {
        return path.split(/[\\/]/).pop();
    };
});