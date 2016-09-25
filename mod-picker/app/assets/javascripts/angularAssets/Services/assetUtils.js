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

    this.sortNestedAssets = function(nestedAssets) {
        nestedAssets.sort(function(a, b) {
            if (a.children || !b.children) {
                if (a.name < b.name) return -1;
                if (a.name > b.name) return 1;
                return 0;
            } else {
                return 1;
            }
        });
        // recurse into children
        nestedAssets.forEach(function(asset) {
            if (asset.children) service.sortNestedAssets(asset.children);
        });
    };

    this.compactConflictingAssets = function(conflictingAssets) {
        var prevAsset = {};
        var mod;

        // compact conflicting assets with a backwards loop
        for (var i = conflictingAssets.length - 1; i >= 0; i--) {
            var asset = conflictingAssets[i];
            if (asset.asset_file_id == prevAsset.asset_file_id) {
                mod = asset.mod;
                mod.subpath = asset.subpath;
                prevAsset.mods.push(mod);
                conflictingAssets.splice(i, 1);
            } else {
                mod = angular.copy(asset.mod);
                mod.subpath = angular.copy(asset.subpath);
                asset.mods = [mod];
                delete asset.mod;
                delete asset.subpath;
                prevAsset = asset;
            }
        }

        // sort mods in conflicting assets
        conflictingAssets.forEach(function(asset) {
            asset.mods && asset.mods.sort(function(a, b) { return a.index - b.index })
        });

        // mark winning mods
        conflictingAssets.forEach(function(asset) {
            var looseAssetMod;
            for (var i = 0; i < asset.mods.length; i++) {
                var mod = asset.mods[i];
                if (!mod.subpath || !mod.subpath.endsWith('.bsa\\')) looseAssetMod = mod;
            }
            if (looseAssetMod) {
                looseAssetMod.wins = true;
            } else {
                asset.mods[asset.mods.length - 1].wins = true;
            }
        })
    };
});
