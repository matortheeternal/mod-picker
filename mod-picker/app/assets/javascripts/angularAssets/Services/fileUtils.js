app.service('fileUtils', function() {
    this.getFileExtension = function(filename) {
        return filename.split('.').pop();
    };

    this.getBaseName = function(path) {
        return path.split(/[\\/]/).pop();
    };
});