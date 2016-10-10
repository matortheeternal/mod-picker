app.service('viewUtils', function() {
    var service = this;
    var fontSizes = [16, 15, 14, 13, 12, 11];

    this.fitContributionTitle = function(element) {
        var contentTitle = element[0].getElementsByClassName("content-title")[0];
        var root = contentTitle.getElementsByClassName("root")[0];
        var sizableElements = root.getElementsByTagName("a");
        var targetWidth = contentTitle.offsetWidth - 175;
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
});