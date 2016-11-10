app.directive('imageUpload', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/imageUpload.html',
        scope: {
            image: '=',
            canChange: '=',
            defaultSrc: '=',
            sizes: '=',
            label: '@',
            imageClass: '@',
            showExplanation: '=?'
        },
        controller: 'imageUploadController'
    }
});

app.controller('imageUploadController', function($scope, $element, $filter, $timeout, fileUtils, imageUtils) {
    // set default value
    angular.default($scope, 'maxFileSize', 262144);
    angular.default($scope, 'showExplanation', true);

    $scope.browseImage = function() {
        var fileInput = $element[0].children[1].children[0];
        fileInput.click();
    };

    $scope.resetImage = function() {
        $scope.image.file = null;
        $scope.image.files = {};
        $scope.image.changed = false;
        $scope.image.src = $scope.defaultSrc;
        $scope.$applyAsync();
    };

    $scope.makeImageSizes = function(img, imageFile) {
        $scope.image.files = {};
        $scope.sizes.forEach(function(size) {
            imageUtils.makeImageSize(imageFile, size, $scope.image);
        });
    };

    $scope.applyBaseImage = function() {
        var baseImageFile = $scope.image.files[$scope.sizes[0]];
        $scope.image.file = baseImageFile;
        $scope.image.changed = true;
        $scope.image.src = URL.createObjectURL(baseImageFile);
        $scope.$applyAsync();
    };

    $scope.loadImage = function(img, imageFile) {
        img.onload = function() {
            $scope.makeImageSizes(img, imageFile);
            $timeout($scope.applyBaseImage);
        };
    };

    $scope.checkImageFileType = function(imageFile) {
        var ext = fileUtils.getFileExtension(imageFile.name);
        if ((ext !== 'png') && (ext !== 'jpg')) {
            var capLabel = $scope.label.capitalize();
            var errorObj = {
                type: "error",
                text: "Unsupported file type.  "+capLabel+" must be a PNG or JPG file."
            };
            $scope.$emit("customMessage", errorObj);
            $scope.resetImage();
            return false;
        }

        return true;
    };

    $scope.checkImageFileSize = function(imageFile) {
        if (imageFile.size > $scope.maxFileSize) {
            var capLabel = $scope.label.capitalize();
            var maxFileSizeStr = $filter('bytes')($scope.maxFileSize);
            var errorObj = {
                type: "error",
                text: capLabel+" file is too big.  Maximum file size "+maxFileSizeStr+"."
            };
            $scope.$emit("customMessage", errorObj);
            $scope.resetImage();
            return false;
        }

        return true;
    };

    $scope.changeImage = function(event) {
        if (event.target.files && event.target.files[0]) {
            var imageFile = event.target.files[0];
            if (!$scope.checkImageFileType(imageFile)) return;
            if (!$scope.checkImageFileSize(imageFile)) return;

            // build and load image blob
            var img = new Image();
            $scope.loadImage(img, imageFile);
        }
    };
});

