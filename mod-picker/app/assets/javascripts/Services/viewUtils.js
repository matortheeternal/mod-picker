app.service('viewUtils', function() {
    var service = this;
    var fontSizes = [16, 15, 14, 13, 12, 11];

    this.fitContributionTitle = function(element) {
        var contentTitle = element[0].getElementsByClassName("content-title")[0];
        var root = contentTitle.getElementsByClassName("root")[0];
        var sizableElements = root.getElementsByTagName("a");
        var targetWidth = contentTitle.offsetWidth - 60;
        if (root.offsetWidth > targetWidth) {
            service.reduceFontSize(root, targetWidth, sizableElements, 0);
        }
    };

    this.reduceFontSize = function(root, targetWidth, elements, i) {
        service.setElementFontSizes(elements, fontSizes[i]);
        setTimeout(function() {
            i++;
            if (root.offsetWidth > targetWidth && i < fontSizes.length) {
                service.reduceFontSize(root, targetWidth, elements, i);
            }
        }, 10);
    };

    this.setElementFontSizes = function(elements, fontSize) {
        for (var i = 0; i < elements.length; i++) {
            elements[i].style.fontSize = fontSize + "px";
        }
    };

    this.sortItemsByPropertyLength = function(items, key) {
        return items.sort(function(a, b) {
            return b[key].length - a[key].length;
        });
    };

    this.createColumns = function(n) {
        var columns = [];
        for (var i = 0; i < n; i++) {
            columns.push({ height: 0, items: [] });
        }
        return columns;
    };

    this.splitIntoColumns = function(items, maxColumns, key, baseHeight, itemHeight) {
        var columns = service.createColumns(Math.min(items.length, maxColumns));

        // distribute items between columns
        service.sortItemsByPropertyLength(items, key).forEach(function(item) {
            var targetColumn = columns.reduce(function(min, current) {
                return (min.height > current.height) ? current : min;
            }, columns[0]);
            targetColumn.items.push(item);
            targetColumn.height += baseHeight + item[key].length * itemHeight;
        });

        return columns;
    };
});