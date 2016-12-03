app.service('assetUtils', function(fileUtils) {
    var service = this;

    var extMap = [{
        exts: [""],
        iconClass: "fa-folder-o"
    }, {
        exts: ["exe", "jar"],
        iconClass: "fa-list-alt"
    }, {
        exts: ["dll", "lib"],
        iconClass: ["fa-file-o", "fa-gear"]
    }, {
        exts: ["bsa", "ba2", "rar", "7z", "zip", "tar", "gz"],
        iconClass: "fa-file-archive-o"
    }, {
        exts: ["pex", "psc", "bat", "pas", "cpp", "inl", "h", "c", "cs", "rc", "fx", "fxh", "hlsl", "inc", "def", "py", "pyd", "pyo", "pyc", "sln", "css", "vcproj", "vcxproj", "vbe"],
        iconClass: "fa-file-code-o"
    }, {
        exts: ["swf", "bik"],
        iconClass: "fa-file-video-o"
    }, {
        exts: ["ini", "cfg", "txt", "rtf", "yaml", "json", "xml", "html", "htm", "log"],
        iconClass: "fa-file-text-o"
    }, {
        exts: ["doc", "docx"],
        iconClass: "fa-file-word-o"
    }, {
        exts: ["pdf"],
        iconClass: "fa-file-pdf-o"
    }, {
        exts: ["xlsx", "xls"],
        iconClass: "fa-file-excel-o"
    }, {
        exts: ["csv", "ods"],
        iconClass: "fa-table"
    }, {
        exts: ["fuz", "wav", "xwm", "mp3"],
        iconClass: "fa-file-sound-o"
    }, {
        exts: ["dds", "tga", "png", "jpg", "jpeg", "bmp", "gif", "ico", "svg", "gfx", "psd"],
        iconClass: "fa-image"
    }, {
        exts: ["tri", "hkx", "hkt", "nif", "bto", "btr", "btt", "lod"],
        iconClass: "fa-cube"
    }];

    this.getIsIconStack = function(ext) {
        return ["dll", "lib"].indexOf(ext) > -1;
    };

    this.getIconClass = function(ext) {
        for (var i = 0; i < extMap.length; i++) {
            var extMapping = extMap[i];
            if (extMapping.exts.indexOf(ext) > -1) {
                return extMapping.iconClass;
            }
        }
        return "fa-file-o"
    };

    this.newLevel = function(currentLevel, levelName) {
        var folderExt = fileUtils.getFileExtension(levelName).toLowerCase();
        currentLevel.unshift({
            name: levelName,
            iconClass: service.getIconClass(folderExt),
            iconStack: service.getIsIconStack(folderExt),
            children: []
        });
        return currentLevel[0].children;
    };

    this.generateLevels = function(splitPath, currentLevel) {
        splitPath.forEach(function(levelName) {
            var foundLevel = currentLevel.find(function(item) {
                return item.name.toLowerCase() === levelName.toLowerCase();
            });
            if (foundLevel) {
                if (!foundLevel.children) foundLevel.children = [];
                currentLevel = foundLevel.children;
            } else {
                currentLevel = service.newLevel(currentLevel, levelName);
            }
        });

        return currentLevel;
    };

    this.getNestedAssets = function(assetPaths) {
        var nestedAssets = [];
        assetPaths.forEach(function(assetPath) {
            var splitPath = assetPath.split('\\');
            var fileName = splitPath.pop();
            var fileExt = fileUtils.getFileExtension(fileName).toLowerCase();
            var currentLevel = nestedAssets;

            // traverse/generate levels as needed
            currentLevel = service.generateLevels(splitPath, currentLevel);

            // push the file onto the current level if it isn't already present
            var foundFile = currentLevel.find(function(item) {
                return item.name.toLowerCase() === fileName.toLowerCase();
            });
            if (!foundFile) {
                currentLevel.push({
                    name: fileName,
                    iconClass: service.getIconClass(fileExt),
                    iconStack: service.getIsIconStack(fileExt)
                });
            }
        });

        return nestedAssets;
    };

    this.sortNestedAssets = function(nestedAssets) {
        nestedAssets.sort(function(a, b) {
            if (!a.children == !b.children) {
                var nameA = a.name.toUpperCase();
                var nameB = b.name.toUpperCase();
                return (nameA < nameB) ? -1 : (nameA > nameB) ? 1 : 0;
            } else {
                return !a.children ? 1 : -1;
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
