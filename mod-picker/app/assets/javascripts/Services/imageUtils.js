app.service('imageUtils', function() {
    var service = this;

    this.makeImageSize = function(imageFile, size, imageObj, apply) {
        var maxWidth = size.width || size.size;
        var maxHeight = size.height || size.size;
        var img = new Image();
        img.src = URL.createObjectURL(imageFile);
        img.onload = function() {
            service.scaleImage(img, maxWidth, maxHeight, function(ext) {
                return function(blob) {
                    var filename = size.label + '.' + ext;
                    imageObj.sizes.push({
                        label: size.label,
                        file: new File([blob], filename),
                        src: URL.createObjectURL(blob)
                    });
                    imageObj.sizes.sort(function(a, b) {
                        return (a.height || a.size) - (b.height || b.size);
                    });
                    apply();
                };
            });
        };
    };

    // returns a blob of the scaled img through callback
    this.scaleImage = function(img, maxWidth, maxHeight, callback) {
        var canvas = document.createElement('canvas');
        canvas.width = img.width;
        canvas.height = img.height;
        canvas.getContext('2d').drawImage(img, 0, 0, canvas.width, canvas.height);
        var hasTransparency = service.hasTransparentPixels(canvas);

        //halves the width of the img as many times as it can before applying the expensive algorithm
        while (canvas.width >= (2 * maxWidth)) {
            canvas = service.getHalfScaleCanvas(canvas);
        }

        //halves the height of the img as many times as it can before applying the expensive algorithm
        while (canvas.height >= (2 * maxHeight)) {
            canvas = service.getHalfScaleCanvas(canvas);
        }

        //scales the img to maxWidth
        if (canvas.width > maxWidth) {
            var widthScale = maxWidth / canvas.width;
            canvas = service.scaleCanvasWithAlgorithm(canvas, widthScale);
        }

        //scales the img to maxHeight
        if (canvas.height > maxHeight) {
            var heightScale = maxHeight / canvas.height;
            canvas = service.scaleCanvasWithAlgorithm(canvas, heightScale);
        }

        // return jpg at 90% quality unless the canvas had transparency
        if (hasTransparency) {
            canvas.toBlob(callback('png'));
        } else {
            canvas.toBlob(callback('jpg'), 'image/jpeg', 0.9);
        }
    };

    // returns true if the canvas has transparent pixels
    this.hasTransparentPixels = function(canvas) {
        var imgData = canvas.getContext('2d').getImageData(0, 0, canvas.width, canvas.height).data;
        for (var i = 0, n = imgData.length; i < n; i+= 4) {
            if (imgData[i + 3] < 255) return true;
        }
    };

    // scales the canvas by .5
    this.getHalfScaleCanvas = function(canvas) {
        var halfCanvas = document.createElement('canvas');
        halfCanvas.width = canvas.width / 2;
        halfCanvas.height = canvas.height / 2;

        halfCanvas.getContext('2d').drawImage(canvas, 0, 0, halfCanvas.width, halfCanvas.height);

        return halfCanvas;
    };

    //scale the canvas by [scale] using bilinearInterpolation
    this.scaleCanvasWithAlgorithm = function(canvas, scale) {
        var scaledCanvas = document.createElement('canvas');

        scaledCanvas.width = canvas.width * scale;
        scaledCanvas.height = canvas.height * scale;

        var srcImgData = canvas.getContext('2d').getImageData(0, 0, canvas.width, canvas.height);
        var destImgData = scaledCanvas.getContext('2d').createImageData(scaledCanvas.width, scaledCanvas.height);

        service.applyBilinearInterpolation(srcImgData, destImgData, scale);

        scaledCanvas.getContext('2d').putImageData(destImgData, 0, 0);

        return scaledCanvas;
    };

    this.applyBilinearInterpolation = function(srcCanvasData, destCanvasData, scale) {
        function inner(f00, f10, f01, f11, x, y) {
            var un_x = 1.0 - x;
            var un_y = 1.0 - y;
            return (f00 * un_x * un_y + f10 * x * un_y + f01 * un_x * y + f11 * x * y);
        }
        var i, j;
        var iyv, iy0, iy1, ixv, ix0, ix1;
        var idxD, idxS00, idxS10, idxS01, idxS11;
        var dx, dy;
        var r, g, b, a;
        for (i = 0; i < destCanvasData.height; ++i) {
            iyv = i / scale;
            iy0 = Math.floor(iyv);
            // Math.ceil can go over bounds
            iy1 = (Math.ceil(iyv) > (srcCanvasData.height - 1) ? (srcCanvasData.height - 1) : Math.ceil(iyv));
            for (j = 0; j < destCanvasData.width; ++j) {
                ixv = j / scale;
                ix0 = Math.floor(ixv);
                // Math.ceil can go over bounds
                ix1 = (Math.ceil(ixv) > (srcCanvasData.width - 1) ? (srcCanvasData.width - 1) : Math.ceil(ixv));
                idxD = (j + destCanvasData.width * i) * 4;
                // matrix to vector indices
                idxS00 = (ix0 + srcCanvasData.width * iy0) * 4;
                idxS10 = (ix1 + srcCanvasData.width * iy0) * 4;
                idxS01 = (ix0 + srcCanvasData.width * iy1) * 4;
                idxS11 = (ix1 + srcCanvasData.width * iy1) * 4;
                // overall coordinates to unit square
                dx = ixv - ix0;
                dy = iyv - iy0;
                // I let the r, g, b, a on purpose for debugging
                r = inner(srcCanvasData.data[idxS00], srcCanvasData.data[idxS10], srcCanvasData.data[idxS01], srcCanvasData.data[idxS11], dx, dy);
                destCanvasData.data[idxD] = r;

                g = inner(srcCanvasData.data[idxS00 + 1], srcCanvasData.data[idxS10 + 1], srcCanvasData.data[idxS01 + 1], srcCanvasData.data[idxS11 + 1], dx, dy);
                destCanvasData.data[idxD + 1] = g;

                b = inner(srcCanvasData.data[idxS00 + 2], srcCanvasData.data[idxS10 + 2], srcCanvasData.data[idxS01 + 2], srcCanvasData.data[idxS11 + 2], dx, dy);
                destCanvasData.data[idxD + 2] = b;

                a = inner(srcCanvasData.data[idxS00 + 3], srcCanvasData.data[idxS10 + 3], srcCanvasData.data[idxS01 + 3], srcCanvasData.data[idxS11 + 3], dx, dy);
                destCanvasData.data[idxD + 3] = a;
            }
        }
    };
});
