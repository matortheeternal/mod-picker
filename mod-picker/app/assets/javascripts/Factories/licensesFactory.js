app.service('licensesFactory', function() {
    var factory = this;

    this.unknown = 0;
    this.no = 1;
    this.yes = 2;
    this.maybe = 3;

    this.setLicenses = function(licenses) {
        factory.licenses = licenses;
    };

    this.getLicenses = function() {
        var licenses = angular.copy(factory.licenses);
        var getClauses = function(license) {
            return license.hasOwnProperty('clauses') ? license.clauses : 99;
        };
        licenses.sort(function(a, b) {
            return getClauses(a) - getClauses(b);
        });
        return licenses;
    };

    this.customLicense = function() {
        return factory.licenses.find(function(license) {
            return license.license_type === "custom";
        });
    };

    this.responsesToLicenseParams = function(content, responses) {
        var contentResponses = responses[content];
        return {
            code: content === 'materials' || content === 'code',
            assets: content === 'materials' || content === 'assets',
            terms: {
                credit: contentResponses.credit,
                commercial: contentResponses.commercial,
                redistribution: contentResponses.redistribution,
                modification: contentResponses.modification,
                private_use: factory.yes,
                include: contentResponses.include
            }
        };
    };

    this.hasUniqueCircumstances = function(content, responses) {
        return responses[content].uniqueCircumstances || 0 > 0;
    };

    this.termMatches = function(licenseTerm, paramTerm) {
        return licenseTerm == paramTerm || licenseTerm == 2;
    };

    var terms = ["credit", "commercial", "redistribution", "modification", "private_use", "include"];

    this.contentMatches = function(license, params) {
        return !(params.code && !license.code) && !(params.assets && !license.assets);
    };

    this.userDoesntCare = function(params, term) {
        return params.terms[term] == 2;
    };

    this.licenseMatches = function(license, params) {
        var termsMatch = terms.reduce(function(match, term) {
            if (factory.userDoesntCare(params, term)) return match;
            return match && license.terms[term] == params.terms[term];
        }, true);
        return factory.contentMatches(license, params) && termsMatch;
    };

    this.licenseSimilar = function(license, params) {
        var termsSimilar = Math.abs(terms.reduce(function(match, term) {
            if (factory.userDoesntCare(params, term)) return match;
            return match + Math.abs(license.terms[term] - params.terms[term]);
        }, 0)) == 1;
        return factory.contentMatches(license, params) && termsSimilar;
    };

    this.getMatchingLicenses = function(content, responses) {
        if (factory.hasUniqueCircumstances(content, responses)) {
            return [factory.customLicense()];
        }
        var params = factory.responsesToLicenseParams(content, responses);
        var licenses = factory.getLicenses().filter(function(license) {
            return factory.licenseMatches(license, params);
        });
        if (licenses.length < 2) {
            licenses.push(factory.customLicense());
        }
        return licenses;
    };

    this.getSimilarLicenses = function(content, responses) {
        if (factory.hasUniqueCircumstances(content, responses)) {
            return [];
        }
        var params = factory.responsesToLicenseParams(content, responses);
        return factory.getLicenses().filter(function(license) {
            return factory.licenseSimilar(license, params);
        });
    };
});