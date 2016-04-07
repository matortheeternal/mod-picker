app.service('archiveService', function () {
    zip.workerScriptsPath = './assets/zip/';

    this.getEntries = function(file, onEnd) {
        zip.createReader(new zip.BlobReader(file), function(zipReader) {
            zipReader.getEntries(onEnd);
        });
    };

    this.pathToTree = function(tree, path) {
        var splitPath = path.split('/');
        var currentNode = tree;
        splitPath.forEach(function(node) {
            currentNode[node] = {};
            currentNode = currentNode[node];
        });
    };
});