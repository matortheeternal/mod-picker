app.service('archiveService', function (fileUtils) {
    zip.workerScriptsPath = './assets/zip/';

    this.getZipEntries = function(file, callback) {
        zip.createReader(new zip.BlobReader(file), function(zipReader) {
            zipReader.getEntries(callback);
        });
    };

    this.getZipEntryFile = function(entry, callback) {
        var writer = new zip.BlobWriter();
        entry.getData(writer, function(blob) {
            callback(new File([blob], fileUtils.getBaseName(entry.filename)));
        });
    };

    this.getRarEntries = function(file, callback) {
        RarArchive({type: RarArchive.OPEN_FILE, file: file}, function() {
            callback(this.entries);
        });
    };

    this.getRarEntryFile = function(file, entry, callback) {
        RarArchive({type: RarArchive.OPEN_FILE, file: file}, function() {
            this.get(entry, function (error, blob) {
                if (blob) {
                    callback(new File([blob], entry.name));
                } else {
                    console.log('getRarEntryFile Error: ' + error);
                }
            });
        });
    };

    this.getBsaEntries = function(file, callback) {
        // TODO: BSA javascript implementation
        callback([]);
    };
});