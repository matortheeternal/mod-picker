app.directive('imageUpload', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/imageUpload.html',
        scope: {
            image: '=',
            canChange: '=',
            defaultSrc: '=',
            label: '@',
            imageClass: '@',
            maxWidth: '@',
            maxHeight: '@',
            showExplanation: '=?',
            maxFileSize: '=?'
        },
        controller: 'imageUploadController'
    }
});

app.controller('imageUploadController', function($scope, $element, $filter, fileUtils) {
    // set default value
    angular.default($scope, 'maxFileSize', 262144);
    angular.default($scope, 'showExplanation', true);

    $scope.browseImage = function() {
        var fileInput = $element[0].children[1].children[0];
        fileInput.click();
    };

    $scope.resetImage = function() {
        $scope.image.file = null;
        $scope.image.changed = false;
        $scope.image.src = $scope.defaultSrc;
        $scope.$applyAsync();
    };

    $scope.changeImage = function(event) {
        var errorObj;
        var capLabel = $scope.label.capitalize();
        if (event.target.files && event.target.files[0]) {
            var imageFile = event.target.files[0];

            // check file type
            var ext = fileUtils.getFileExtension(imageFile.name);
            if ((ext !== 'png') && (ext !== 'jpg')) {
                errorObj = {
                    type: "error",
                    text: "Unsupported file type.  "+capLabel+" must be a PNG or JPG file."
                };
                $scope.$emit("customMessage", errorObj);
                $scope.resetImage();
                return;
            }

            // check filesize
            if (imageFile.size > $scope.maxFileSize) {
                var maxFileSizeStr = $filter('bytes')($scope.maxFileSize);
                errorObj = {
                    type: "error",
                    text: capLabel+" file is too big.  Maximum file size "+maxFileSizeStr+"."
                };
                $scope.$emit("customMessage", errorObj);
                $scope.resetImage();
                return;
            }

            // check dimensions
            var img = new Image();
            img.onload = function() {
                var imageTooBig = (img.width > $scope.maxWidth) || (img.height > $scope.maxHeight);
                if (imageTooBig) {
                    errorObj = {
                        type: "error",
                        text: capLabel+" is too large.  Maximum dimensions "+$scope.maxWidth+"x"+$scope.maxHeight+"."
                    };
                    $scope.$emit("customMessage", errorObj);
                    $scope.resetImage();
                } else {
                    $scope.image.file = imageFile;
                    $scope.image.changed = true;
                    $scope.image.src = img.src;
                    $scope.$applyAsync();
                }
            };
            img.src = URL.createObjectURL(imageFile);
        }
    };
});

