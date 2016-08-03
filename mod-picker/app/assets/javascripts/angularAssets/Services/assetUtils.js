app.service('assetUtils', function (fileUtils) {
    this.convertDataStringToNestedObject = function(assets) {
        var nestedData = {
            childs: {}
        };

        // TODO: don't use recursive function here, as a simple loop would work as good if not better
        function nestObject(nestingArray, currentLayer) {
            var current = nestingArray.shift();
            if(!current) {
                return;
            }
            if(!currentLayer.childs) {
                currentLayer.childs = {};
            }
            if(!currentLayer.childs[current]) {
                var ext = fileUtils.getFileExtension(current).toLowerCase();
                var iconClass = "fa-file-o";
                switch(ext) {
                    case "": iconClass = "fa-folder-o"; break;
                    case "esp": iconClass = "fa-globe"; break;
                    case "esm": iconClass = "fa-globe"; break;
                    case "bsa": iconClass = "fa-file-archive-o"; break;
                    case "ba2": iconClass = "fa-file-archive-o"; break;
                    case "pex": iconClass = "fa-file-code-o"; break;
                    case "psc": iconClass = "fa-file-code-o"; break;
                    case "ini": iconClass = "fa-file-text-o"; break;
                    case "txt": iconClass = "fa-file-text-o"; break;
                    case "xml": iconClass = "fa-file-text-o"; break;
                    case "fuz": iconClass = "fa-file-sound-o"; break;
                    case "tri": iconClass = "fa-location-arrow"; break;
                    case "nif": iconClass = "fa-cube"; break;
                    case "dds": iconClass = "fa-image"; break;
                }
                currentLayer.childs[current] = {
                    title: current,
                    iconClass: iconClass
                };
            }
            return nestObject(nestingArray, currentLayer.childs[current]);
        }

        assets.forEach(function (asset) {
            var assetNesting = asset.split('\\');
            nestObject(assetNesting, nestedData);
        });

        return nestedData;
    };

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
