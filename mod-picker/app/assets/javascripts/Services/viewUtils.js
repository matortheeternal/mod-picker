app.service('viewUtils', function() {
    var service = this;
    var fontSizes = [16, 15, 14, 13, 12, 11];

    this.fitContributionTitle = function(element) {
        var contentTitle = element[0].getElementsByClassName("content-title")[0];
        var linkRoot = contentTitle.getElementsByClassName("link-elements")[0];
        var linkElements = linkRoot.getElementsByTagName("a");
        var targetWidth = contentTitle.offsetWidth - 155;
        if (linkRoot.offsetWidth > targetWidth) {
            service.reduceFontSize(linkRoot, targetWidth, linkElements, 0);
        }
    };

    this.reduceFontSize = function(linkRoot, targetWidth, linkElements, i) {
        service.setElementFontSizes(linkElements, fontSizes[i]);
        setTimeout(function() {
            i++;
            if (linkRoot.offsetWidth > targetWidth && i < fontSizes.length) {
                service.reduceFontSize(linkRoot, targetWidth, linkElements, i);
            }
        }, 10);
    };

    this.setElementFontSizes = function(elements, fontSize) {
        for (var i = 0; i < elements.length; i++) {
            elements[i].style.fontSize = fontSize + "px";
        }
    };
});