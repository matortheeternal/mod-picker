app.service('assetUtils', function () {
    this.convertDataStringToNestedObject = function(title, assets) {
        var nestedData = {
            title: title,
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
                currentLayer.childs[current] = {
                    title: current
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