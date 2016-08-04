app.service('assetUtils', function (fileUtils) {
    var service = this;

    this.getIconClass = function(ext) {
        switch(ext) {
            case "": return "fa-folder-o";
            case "esp": return "fa-globe";
            case "esm": return "fa-globe";
            case "bsa": return "fa-file-archive-o";
            case "ba2": return "fa-file-archive-o";
            case "pex": return "fa-file-code-o";
            case "psc": return "fa-file-code-o";
            case "ini": return "fa-file-text-o";
            case "txt": return "fa-file-text-o";
            case "xml": return "fa-file-text-o";
            case "fuz": return "fa-file-sound-o";
            case "tri": return "fa-location-arrow";
            case "nif": return "fa-cube";
            case "dds": return "fa-image";
            default: return "fa-file-o"
        }
    };

    this.getNestedAssets = function(assetPaths) {
        var nestedAssets = [];
        assetPaths.forEach(function(assetPath) {
            var paths = assetPath.split('\\');
            var fileName = paths.pop();
            var fileExt = fileUtils.getFileExtension(fileName).toLowerCase();
            var currentLevel = nestedAssets;

            // traverse/generate levels as needed
            paths.forEach(function(folderName) {
                var folderExt = fileUtils.getFileExtension(folderName).toLowerCase();
                var foundFolder = currentLevel.find(function(item) {
                    return item.name.toLowerCase() === folderName.toLowerCase();
                });
                if (foundFolder) {
                    if (!foundFolder.children) foundFolder.children = [];
                    currentLevel = foundFolder.children;
                } else {
                    currentLevel.unshift({
                        name: folderName,
                        iconClass: service.getIconClass(folderExt),
                        children: []
                    });
                    currentLevel = currentLevel[0].children;
                }
            });

            // push the file onto the current level if it isn't already present
            var foundFile = currentLevel.find(function(item) {
                return item.name.toLowerCase() === fileName.toLowerCase();
            });
            if (!foundFile) {
                currentLevel.push({
                    name: fileName,
                    iconClass: service.getIconClass(fileExt)
                });
            }
        });

        return nestedAssets;
    };

    // TODO: sort levels by filename

    this.compactConflictingAssets = function(conflictingAssets) {
        var prevAsset = {};
        for (var i = conflictingAssets.length - 1; i >= 0; i--) {
            var asset = conflictingAssets[i];
            if (asset.asset_file_id == prevAsset.asset_file_id) {
                prevAsset.mod_ids.push(asset.mod_id);
                conflictingAssets.splice(i, 1);
            } else {
                asset.mod_ids = [asset.mod_id];
                prevAsset = asset;
            }
        }
    };
});
