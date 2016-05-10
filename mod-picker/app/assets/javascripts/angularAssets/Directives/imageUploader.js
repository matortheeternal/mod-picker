

app.directive('imageUploader', function () {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/imageUploader.html',
        controller: 'imageUploaderController',
        scope: {
            imageSrc: '=',
            imageSmall: '=',
            imageMedium: '=',
            imageBig: '=',
            errors: '='
        }
    }
});

app.controller('imageUploaderController', function ($scope, sliderOptionsFactory, $timeout) {
    var originalSrc = $scope.imageSrc;
    $scope.clickAvatarBrowse = function() {
        document.getElementById('avatar-input').click();
    };

    $scope.changeAvatar = function(event) {
        if (event.target.files && event.target.files[0]) {
            var avatarFile = event.target.files[0];

            // check dimensions
            var img = new Image();
            img.onload = function() {
                var number = 0;
                scaleImage(img, 250, 250, function(blob) {
                    $scope.imageBig = new File([blob], "bigAvatar");
                    number++;
                    apply(number);
                });
                scaleImage(img, 100, 100, function(blob) {
                    $scope.imageMedium = new File([blob], "mediumAvatar");
                    number++;
                    apply(number);
                });
                scaleImage(img, 50, 50, function(blob) {
                    $scope.imageSmall = new File([blob], "smallAvatar");
                    number++;
                    apply(number);
                });

                $scope.imageSrc = img.src;
                $scope.$apply();
            };
            img.src = URL.createObjectURL(avatarFile);
        } else if ($scope.user) {
            $scope.resetAvatar();
        }
    };

    var apply = function(number) {
        if(number>2) {
            $scope.$apply();
        }
    };

    $scope.resetAvatar = function() {
        $scope.image = null;
        $scope.imageSrc = originalSrc;
        $scope.$apply();
    };

    //a blob of the scaled img
    var scaleImage = function(img, maxWidth, maxHeight, callback) {
        var canvas = document.createElement('canvas');
        canvas.width = img.width;
        canvas.height = img.height;
        canvas.getContext('2d').drawImage(img, 0, 0, canvas.width, canvas.height);

        //halves the width of the img as many times as it can before applying the expensive algorithm
        while (canvas.width >= (2 * maxWidth)) {
            canvas = getHalfScaleCanvas(canvas);
        }

        //halves the height of the img as many times as it can before applying the expensive algorithm
        while (canvas.height >= (2 * maxHeight)) {
            canvas = getHalfScaleCanvas(canvas);
        }

        //scales the img to maxWidth
        if (canvas.width > maxWidth) {
            var widthScale = maxWidth / canvas.width;
            canvas = scaleCanvasWithAlgorithm(canvas, widthScale);
        }

        //scales the img to maxHeight
        if (canvas.height > maxHeight) {
            var heightScale = maxheight / canvas.height;
            canvas = scaleCanvasWithAlgorithm(canvas, heightScale);
        }

        canvas.toBlob(callback);
    };

    //scale the canvas by .5
    var getHalfScaleCanvas = function(canvas) {
        var halfCanvas = document.createElement('canvas');
        halfCanvas.width = canvas.width / 2;
        halfCanvas.height = canvas.height / 2;

        halfCanvas.getContext('2d').drawImage(canvas, 0, 0, halfCanvas.width, halfCanvas.height);

        return halfCanvas;
    };

    //scale the canvas by [scale] using bilinearInterpolation
    var scaleCanvasWithAlgorithm = function(canvas, scale) {
        var scaledCanvas = document.createElement('canvas');

        scaledCanvas.width = canvas.width * scale;
        scaledCanvas.height = canvas.height * scale;

        var srcImgData = canvas.getContext('2d').getImageData(0, 0, canvas.width, canvas.height);
        var destImgData = scaledCanvas.getContext('2d').createImageData(scaledCanvas.width, scaledCanvas.height);

        applyBilinearInterpolation(srcImgData, destImgData, scale);

        scaledCanvas.getContext('2d').putImageData(destImgData, 0, 0);

        return scaledCanvas;
    };

    var applyBilinearInterpolation = function(srcCanvasData, destCanvasData, scale) {
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
