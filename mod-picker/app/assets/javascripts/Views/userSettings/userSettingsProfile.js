app.controller('userSettingsProfileController', function($scope, titleQuote) {
    $scope.titleQuote = titleQuote;
    $scope.avatar = {
        src: $scope.user.avatar || '/users/' + $scope.user.title + '.png'
    };

    $scope.browseAvatar = function() {
        document.getElementById('avatar-input').click();
    };

    $scope.resetAvatar = function() {
        $scope.avatar.file = null;
        $scope.avatar.src = $scope.user.avatar || '/users/' + $scope.user.title + '.png';
        $scope.$apply();
    };

    $scope.changeAvatar = function(event) {
        $scope.errors = [];
        if (event.target.files && event.target.files[0]) {
            var avatarFile = event.target.files[0];

            // check file type
            var ext = fileUtils.getFileExtension(avatarFile.name);
            if ((ext !== 'png') && (ext !== 'jpg')) {
                $scope.$emit('customMessage', {type: 'error', message: 'Unsupported file type.  Avatar image must be a PNG or JPG file.'});
                $scope.resetAvatar();
                return;
            }

            // check filesize
            if (avatarFile.size > 1048576) {
                $scope.$emit('customMessage', {type: 'error', message: 'Avatar image is too big.  Maximum file size 1.0MB.'});
                $scope.resetAvatar();
                return;
            }

            // check dimensions
            var img = new Image();
            img.onload = function() {
                //alert("Image loaded!");
                var imageTooBig = (img.width > 250) || (img.height > 250);
                if (imageTooBig) {
                    $scope.$emit('customMessage', {type: 'error', message: 'Avatar image too large.  Maximum dimensions 250x250.'});
                    $scope.resetAvatar();
                } else {
                    $scope.avatar.file = avatarFile;
                    $scope.avatar.src = img.src;
                    $scope.$apply();
                }
            };

            // update img src with a generated blob url
            img.src = URL.createObjectURL(avatarFile);
        } else if ($scope.user) {
            $scope.resetAvatar();
        }
    };
});