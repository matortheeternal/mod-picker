app.service('assetUtils', function (fileUtils) {
    this.convertDataStringToNestedObject = function(title, assets) {
        var nestedData = {
            childs: {}
        };

        function nestObject(nestingArray, currentLayer) {
            var current = nestingArray.shift();
            if(!current) {
                return;
            }
            if(!currentLayer.childs) {
                currentLayer.childs = {};
            }
            if(!currentLayer.childs[current]) {
                var ext = fileUtils.getFileExtension(current);
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
                    case "nif": iconClass = "fa-cube"; break;
                    case "dds": iconClass = "fa-image"; break;
                }
                currentLayer.childs[current] = {
                    title: current,
                    iconClass: iconClass
                }
            }
            return nestObject(nestingArray, currentLayer.childs[current]);
        }

        assets.forEach(function (asset) {
            var assetNesting = asset.split('\\');
            nestObject(assetNesting, nestedData);
        });

        return nestedData;
    };
});