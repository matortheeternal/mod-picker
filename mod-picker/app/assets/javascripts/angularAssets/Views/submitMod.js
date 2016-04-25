app.config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('submit', {
            templateUrl: '/resources/partials/submitMod.html',
            controller: 'submitModController',
            url: '/submit'
        }
    );
}]);

app.controller('submitModController', function ($scope, backend, submitService, archiveService, fileUtils) {
    /* scraping */
    $scope.nexusScraped = false;
    $scope.archive = {};
    //TODO: I guess this static might be better in some sort of service
    var nexusUrlPattern = /(http[s]:\/\/?)?www.nexusmods.com\/skyrim\/mods\/([0-9]+)(\/\?)?/i;

    $scope.urlInvalid = function () {
        //TODO: ugh... never use execs, validate this url somehow differently
        return nexusUrlPattern.exec($scope.nexusUrl) == null
    };

    $scope.scrape = function () {
        var match = nexusUrlPattern.exec($scope.nexusUrl);
        var id = match[2];
        $scope.scraping = true;
        submitService.scrapeNexus(3, id).then(function (data) {
            $scope.nexus = data;
            if (data.nexus_category == 39) {
                $scope.isUtility = true;
            }
        });
    };

    /* tag selection */
    $scope.mod_tags = [];

    /* asset file analysis */
    $scope.changeArchive = function(event) {
        var input = event.target;
        if (input.files && input.files[0]) {
            $scope.archive.file = input.files[0];
            $scope.analyzeArchive();
            $scope.$apply();
        }
    };

    $scope.analyzeBSA = function(bsaFile) {
        console.log('Analyzing BSA: "' + bsaFile.name + '"');
        archiveService.getBsaEntries(bsaFile, function(entries) {
            entries.forEach(function (entry) {
                console.log(entry.path);
                $scope.archive.tree.push(entry.path);
            });
        });
    };

    $scope.analyzeArchive = function() {
        $scope.archive.analyzing = true;
        $scope.archive.ext = fileUtils.getFileExtension($scope.archive.file.name);
        if ($scope.archive.ext === 'rar') {
            console.log('Analyzing RAR archive: "' + $scope.archive.file.name + '"');
            archiveService.getRarEntries($scope.archive.file, function(entries) {
                $scope.archive.tree = [];
                entries.forEach(function (entry) {
                    var fixedPath = entry.path.split('\\').join('/');
                    console.log(fixedPath);
                    $scope.archive.tree.push(fixedPath);
                    if (fileUtils.getFileExtension(fixedPath) === 'bsa') {
                        archiveService.getRarEntryFile($scope.archive.file, entry, $scope.analyzeBSA);
                    }
                });
                $scope.$apply();
            });
        } else if ($scope.archive.ext === 'zip') {
            console.log('Analyzing ZIP archive: "' + $scope.archive.file.name + '"');
            archiveService.getZipEntries($scope.archive.file, function(entries) {
                $scope.archive.tree = [];
                entries.forEach(function (entry) {
                    console.log(entry.filename);
                    $scope.archive.tree.push(entry.filename);
                    if (fileUtils.getFileExtension(entry.filename) === 'bsa') {
                        archiveService.getZipEntryFile(entry, $scope.analyzeBSA);
                    }
                });
                $scope.$apply();
            });
        } else {
            console.log('Archive is unsupported file type ".' + $scope.archive.ext + '", please select a .zip or .rar archive file.');
        }
    };

    $scope.browseArchive = function() {
        document.getElementById('archive-input').click();
    };

    /* plugin submission */
    $scope.changePlugins = function(event) {
        var files = [].slice.call(event.target.files);
        if ($scope.plugins) {
            $scope.plugins = $scope.plugins.concat(files);
        } else {
            $scope.plugins = files;
        }
        $scope.$apply();
    };

    $scope.removePlugin = function(filename) {
        for (var i = 0; i < $scope.plugins.length; i++) {
            plugin = $scope.plugins[i];
            if (plugin.name == filename) {
                $scope.plugins.splice(i, 1);
                break;
            }
        }
        if ($scope.plugins.length == 0) {
            $scope.plugins = null;
        }
    };

    $scope.addPlugins = function() {
        document.getElementById('plugins-input').click();
    };

    $scope.clearPlugins = function() {
        $scope.plugins = null;
    };

    /* mod submission */
    $scope.modInvalid = function () {
        return ($scope.nexus == null)
    };

    $scope.submit = function () {
        submitService.submit($scope.nexus, $scope.isUtility, $scope.hasAdultContent, $scope.plugins);
    }
});
