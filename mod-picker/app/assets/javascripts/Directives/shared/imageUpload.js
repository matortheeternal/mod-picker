app.directive('imageUpload', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/imageUpload.html',
        scope: {
            image: '=',
            canChange: '=',
            defaultSize: '@',
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
    angular.default($scope, 'defaultSize', 'medium');
    angular.default($scope, 'showExplanation', true);

    $scope.browseImage = function() {
        var fileInput = $element[0].children[1].children[0];
        fileInput.click();
    };

    $scope.resetImage = function() {
        $scope.image.sizes = [{
            label: $scope.defaultSize,
            src: $scope.defaultSrc
        }];
        $scope.image.changed = false;
        $scope.$applyAsync();
    };

    $scope.makeImageSizes = function(imageFile) {
        $scope.image.sizes = [];
        $scope.image.changed = true;
        $scope.sizes.forEach(function(size) {
            imageUtils.makeImageSize(imageFile, size, $scope.image, $scope.$applyAsync);
        });
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

    $scope.changeImage = function(event) {
        if (event.target.files && event.target.files[0]) {
            var imageFile = event.target.files[0];
            if (!$scope.checkImageFileType(imageFile)) return;
            $scope.makeImageSizes(imageFile);
        }
    };
});

