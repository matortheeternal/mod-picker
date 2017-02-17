app.directive('modLicenses', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/editMod/modLicenses.html',
        controller: 'modLicensesController',
        scope: false
    }
});

app.controller('modLicensesController', function($scope, $timeout) {
    $scope.addLicense = function() {
        $scope.mod.mod_licenses.push({
            license_id: $scope.licenses[0].id,
            target: 'materials'
        });
    };

    $scope.clearLicense = function(mod_license) {
        mod_license.license = null;
        mod_license.custom = null;
        mod_license.license_option_id = null;
    };

    $scope.licenseChange = function(mod_license) {
        $scope.clearLicense(mod_license);
        var license = $scope.licenses.find(function(license) {
            return license.id == mod_license.license_id;
        });
        if (!license) return;
        $timeout(function() {
            mod_license.license = license;
            mod_license.custom = license.license_type === 'custom';
            if (license.license_options.length && !mod_license.custom) {
                mod_license.license_option_id = license.license_options[0].id;
            }
        });
    };

    $scope.removeLicense = function(mod_license) {
        if (mod_license.id) {
            mod_license._destroy = true;
        } else {
            var index = $scope.mod.mod_licenses.indexOf(mod_license);
            $scope.mod.mod_licenses.splice(index, 1);
        }
    };
});