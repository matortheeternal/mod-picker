app.service('licenseService', function(backend) {
    var service = this;

    this.retrieveLicenses = function() {
        return backend.retrieve('/licenses', {cache: true});
    };

    this.getLicenseById = function(licenses, id) {
        return licenses.find(function(license) {
          return license.id === id;
        });
    };

    this.getLicenseOption = function(license, id) {
        return license.license_options.find(function(licenseOption) {
            return licenseOption.id === id;
        });
    };

    this.associateModLicense = function(licenses, mod_license) {
        if (!mod_license.license_id) return;
        mod_license.license = service.getLicenseById(licenses, mod_license.license_id);
        if (!mod_license.license_option_id) return;
        mod_license.license_option = service.getLicenseOption(mod_license.license, mod_license.license_option_id);
    };

    this.resolveModLicense = function(licenses, mod) {
        if (!mod.mod_license) return;
        service.associateModLicense(licenses, mod.mod_license);
    };
});
