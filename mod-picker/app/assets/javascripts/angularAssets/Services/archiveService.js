app.service('archiveService', function () {
    zip.workerScriptsPath = './assets/zip/';

    this.getZipEntries = function(file, callback) {
        zip.createReader(new zip.BlobReader(file), function(zipReader) {
            zipReader.getEntries(callback);
        });
    };

    this.getRarEntries = function(file, callback) {
        RarArchive({type: RarArchive.OPEN_FILE, file: file}, function() {
            callback(this.entries);
        });
    };
});