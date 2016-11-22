app.service('licensesFactory', function() {
    var factory = this;

    this.unknown = -1;
    this.no = 0;
    this.yes = 1;
    this.with_permission = 2;

    this.licenses = {
        none: {
            name: "None",
            type: "copyright",
            wikipedia: "Copyright",
            clauses: 0,
            code: true,
            assets: true,
            terms: {
                credit: factory.with_permission,
                commercial: factory.with_permission,
                redistribution: factory.with_permission,
                modification: factory.with_permission,
                private_use: factory.with_permission,
                include: factory.no
            },
            description: "Without a license the materials are copyrighted by default.  People can view the materials, but they have no legal right to use them.  To use the materials they must contact the author directly and ask for permission.  That includes people using the mod in their game. Generally speaking you should never release a mod without an explicit license."
        },
        pd: {
            name: "Public Domain",
            acronym: "PD",
            type: "permissive",
            wikipedia: "Public_Domain",
            options: [{
                name: "Creative Commons CC0 1.0 Universal",
                acronym: "CC-0",
                tldr: "creative-commons-cc0-1.0-universal",
                link: "https://creativecommons.org/publicdomain/zero/1.0/"
            }, {
                name: "Unlicense",
                tldr: "unlicense",
                link: "http://unlicense.org/"
            }],
            clauses: 0,
            code: true,
            assets: true,
            terms: {
                credit: factory.yes,
                commercial: factory.yes,
                redistribution: factory.yes,
                modification: factory.yes,
                private_use: factory.yes,
                include: factory.no
            },
            description: "Releasing something into the public domain involves relinquishing all ownership/copyright over it.  If your materials are in the public domain that means anyone can use them for any purpose whatsoever, including commercial use."
        },
        wtfpl: {
            name: "Do What The F*ck You Want To Public License",
            acronym: "WTFPL",
            type: "permissive",
            wikipedia: "WTFPL",
            options: [{
                name: "Do What the F*ck You Want To Public License v2",
                tldr: "do-wtf-you-want-to-public-license-v2-(wtfpl-2.0)",
                link: "http://www.wtfpl.net/about/"
            }],
            clauses: 1,
            code: true,
            assets: true,
            terms: {
                credit: factory.yes,
                commercial: factory.yes,
                redistribution: factory.yes,
                modification: factory.yes,
                private_use: factory.yes,
                include: factory.no
            },
            description: "The WTFPL is almost a public domain grant. It is super-permissive. Basically, do whatever you want.  You still retain ownership."
        },
        gpl: {
            name: "GNU General Public License",
            acronyrm: "GPL",
            options: [{
                name: "GNU General Public License, version 1",
                acronym: "GPLv1",
                link: "https://www.gnu.org/licenses/old-licenses/gpl-1.0.en.html"
            }, {
                name: "GNU General Public License, version 2",
                acronym: "GPLv2",
                tldr: "gnu-general-public-license-v2",
                link: "https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html"
            }, {
                name: "GNU General Public License, version 3",
                acronym: "GPLv3",
                tldr: "gnu-general-public-license-v3-(gpl-3)",
                link: "https://www.gnu.org/licenses/gpl-3.0.en.html"
            }],
            type: "copyleft",
            wikipedia: "GNU_General_Public_License",
            clauses: 12,
            code: true,
            assets: false,
            terms: {
                credit: factory.yes,
                commercial: factory.yes,
                redistribution: factory.yes,
                modification: factory.yes,
                private_use: factory.yes,
                include: factory.yes
            },
            description: "While the GPL allows commercial use it's generally not viable to do so due to other clauses in the license."
        },
        lgpl: {
            name: "GNU Lesser General Public License",
            acronym: "LGPL",
            type: "mostly copyleft",
            wikipedia: "GNU_Lesser_General_Public_License",
            options: [{
                name: "GNU Lesser General Public License, version 2.1",
                acronym: "LGPLv2",
                tldr: "gnu-lesser-general-public-license-v2.1-(lgpl-2.1)",
                link: "https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html"
            }, {
                name: "GNU Lesser General Public License, version 3",
                acronym: "LGPLv3",
                tldr: "gnu-lesser-general-public-license-v3-(lgpl-3)",
                link: "https://www.gnu.org/licenses/lgpl-3.0.en.html"
            }],
            clauses: 16,
            code: true,
            assets: false,
            terms: {
                credit: factory.yes,
                commercial: factory.yes,
                redistribution: factory.yes,
                modification: factory.yes,
                private_use: factory.yes,
                include: factory.yes
            },
            description: "This license is mainly applied to libraries. You may copy, distribute and modify the software provided that modifications are described and licensed for free under LGPL. Derivatives works (including modifications or anything statically linked to the library) can only be redistributed under LGPL, but applications that use the library don't have to be."
        },
        mit: {
            name: "MIT License",
            acronym: "MIT",
            type: "permissive",
            options: [{
                name: "MIT License",
                tldr: "mit-license",
                link: "https://en.wikipedia.org/wiki/MIT_License"
            }],
            clauses: 2,
            code: true,
            assets: false,
            terms: {
                credit: factory.yes,
                commercial: factory.yes,
                redistribution: factory.yes,
                modification: factory.yes,
                private_use: factory.yes,
                include: factory.yes
            },
            description: "A short, permissive software license. Basically, you can do whatever you want as long as you include the original copyright and license notice in any copy of the software/source."
        },
        bsd: {
            name: "BSD License",
            acronym: "BSD",
            type: "permissive",
            options: [{
                name: "BSD License",
                tldr: "bsd-2-clause-license-(freebsd)",
                link: "https://www.freebsd.org/copyright/freebsd-license.html"
            }],
            clauses: 2,
            code: true,
            assets: false,
            terms: {
                credit: factory.yes,
                commercial: factory.yes,
                redistribution: factory.yes,
                modification: factory.yes,
                private_use: factory.yes,
                include: factory.yes
            },
            description: "The BSD 2-clause license allows you almost unlimited freedom with the software so long as you include the BSD copyright notice in it."
        },
        asl: {
            name: "Apache License",
            acronym: "ASL",
            options: [{
                name: "Apache License 1.0",
                acronym: "Apache-1.0",
                tldr: "apache-license-1.0-(apache-1.0)",
                link: "https://www.apache.org/licenses/LICENSE-1.0"
            }, {
                name: "Apache License 1.1",
                acronym: "Apache-1.1",
                tldr: "apache-license-1.1",
                link: "https://www.apache.org/licenses/LICENSE-1.1"
            }, {
                name: "Apache License 2.0",
                acronym: "Apache-2.0",
                tldr: "apache-license-2.0-(apache-2.0)",
                link: "https://www.apache.org/licenses/LICENSE-2.0"
            }],
            type: "permissive",
            wikipedia: "Apache_License",
            clauses: 9,
            code: true,
            assets: false,
            terms: {
                credit: factory.yes,
                commercial: factory.yes,
                redistribution: factory.yes,
                modification: factory.yes,
                private_use: factory.yes,
                include: factory.yes
            },
            description: "You can do what you like with the software, as long as you include the required notices."
        },
        epl: {
            name: "Eclipse Public License",
            acronym: "EPL",
            type: "permissive",
            wikipedia: "Eclipse_Public_License",
            options: [{
                name: "Eclipse Public License 1.0",
                tldr: "eclipse-public-license-1.0-(epl-1.0)",
                link: "https://www.eclipse.org/legal/epl-v10.html"
            }],
            clauses: 7,
            code: true,
            assets: false,
            terms: {
                credit: factory.yes,
                commercial: factory.yes,
                redistribution: factory.yes,
                modification: factory.yes,
                private_use: factory.yes,
                include: factory.yes
            },
            description: "This license, made and used by the Eclipse Foundation, is similar to GPL but allows you to link code under the license to proprietary applications. You may also license binaries under a proprietary license, as long as the source code is available under EPL."
        },
        mpl: {
            name: "Mozilla Public License",
            acronym: "MPL",
            options: [{
                name: "Mozilla Public License 1.0",
                acronym: "MPL-1.0",
                tldr: "mozilla-public-license-1.0-(mpl-1.0)",
                link: "https://www.mozilla.org/en-US/MPL/"
            }, {
                name: "Mozilla Public License 1.1",
                acronym: "MPL-1.1",
                tldr: "mozilla-public-license-1.1-(mpl-1.1)",
                link: "https://www.mozilla.org/en-US/MPL/1.1/"
            }, {
                name: "Mozilla Public License 2.0",
                acronym: "MPL-2.0",
                tldr: "mozilla-public-license-2.0-(mpl-2)",
                link: "https://www.mozilla.org/en-US/MPL/2.0/"
            }],
            type: "weak copyleft",
            wikipedia: "Mozilla_Public_License",
            clauses: 13,
            code: true,
            assets: false,
            terms: {
                credit: factory.yes,
                commercial: factory.yes,
                redistribution: factory.yes,
                modification: factory.yes,
                private_use: factory.yes,
                include: factory.yes
            },
            description: "A copyleft license, though not considered strong copyleft since the license only requires the source code of modified components to be disclosed. Incompatible with GNU GPL (though MPL-2.0 is compatible)."
        },
        ccby: {
            name: "Creative Commons Attribution",
            acronym: "CC BY",
            type: "copyright",
            options: [{
                name: "Creative Commons BY 4.0",
                tldr: "creative-commons-attribution-4.0-international-(cc-by-4)",
                link: "https://creativecommons.org/licenses/by/4.0/"
            }],
            clauses: 8,
            code: true,
            assets: true,
            terms: {
                credit: factory.yes,
                commercial: factory.yes,
                redistribution: factory.yes,
                modification: factory.yes,
                private_use: factory.yes,
                include: factory.no
            },
            description: "This creative commons license allows redistribution, derivative works, and commercial use."
        },
        ccbync: {
            name: "Creative Commons Attribution-NonCommercial",
            acronym: "CC BY-NC",
            type: "copyright",
            options: [{
                name: "Creative Commons BY-NC 4.0",
                tldr: "creative-commons-attribution-noncommercial-4.0-international-(cc-by-nc-4.0)",
                link: "https://creativecommons.org/licenses/by-nc/4.0/"
            }],
            clauses: 8,
            code: true,
            assets: true,
            terms: {
                credit: factory.yes,
                commercial: factory.no,
                redistribution: factory.yes,
                modification: factory.yes,
                private_use: factory.yes,
                include: factory.no
            },
            description: "This creative commons license allows redistribution and derivative works but restricts using the materials for commercial use."
        },
        ccbysa: {
            name: "Creative Commons Attribution-ShareAlike",
            acronym: "CC BY-SA",
            type: "copyright",
            options: [{
                name: "Creative Commons BY-SA 4.0",
                tldr: "creative-commons-attribution-sharealike-4.0-international-(cc-by-sa-4.0)",
                link: "https://creativecommons.org/licenses/by-sa/4.0/"
            }],
            clauses: 8,
            code: true,
            assets: true,
            terms: {
                credit: factory.yes,
                commercial: factory.yes,
                redistribution: factory.yes,
                modification: factory.yes,
                private_use: factory.yes,
                include: factory.yes
            },
            description: "This creative commons license allows redistribution, derivative works, and commercial use.  The license requires people who use your materials to use a similar license (share alike)."
        },
        ccbyncsa: {
            name: "Creative Commons Attribution-NonCommercial-ShareAlike",
            acronym: "CC BY-NC-SA",
            type: "copyright",
            options: [{
                name: "Creative Commons BY-NC-SA 4.0",
                tldr: "creative-commons-attribution-noncommercial-sharealike-4.0-international-(cc-by-nc-sa-4.0)",
                link: "https://creativecommons.org/licenses/by-nc-sa/4.0/"
            }],
            clauses: 8,
            code: true,
            assets: true,
            terms: {
                credit: factory.yes,
                commercial: factory.no,
                redistribution: factory.yes,
                modification: factory.yes,
                private_use: factory.yes,
                include: factory.yes
            },
            description: "This creative commons license allows redistribution and derivative works but restricts using the materials for commercial use.  The license requires derivative works to use a similar license (share alike)."
        },
        ccbynd: {
            name: "Creative Commons Attribution-NoDerivatives",
            acronym: "CC BY-ND",
            type: "copyright",
            options: [{
                name: "Creative Commons BY-ND 4.0",
                tldr: "creative-commons-attribution-noderivatives-4.0-international-(cc-by-nd-4.0)",
                link: "https://creativecommons.org/licenses/by-nd/4.0/",
            }],
            clauses: 8,
            code: true,
            assets: true,
            terms: {
                credit: factory.yes,
                commercial: factory.yes,
                redistribution: factory.yes,
                modification: factory.no,
                private_use: factory.yes,
                include: factory.no
            },
            description: "This creative commons license allows redistribution and commerical use but restricts the creation of derivative works."
        },
        ccbyncnd: {
            name: "Creative Commons Attribution-NonCommercial-NoDerivatives",
            acronym: "CC BY-NC-ND",
            type: "copyright",
            options: [{
                name: "Creative Commons BY-NC-ND 4.0",
                tldr: "creative-commons-attribution-noncommercial-noderivs-(cc-nc-nd)",
                link: "https://creativecommons.org/licenses/by-nc-nd/4.0/"
            }],
            clauses: 8,
            code: true,
            assets: true,
            terms: {
                credit: factory.yes,
                commercial: factory.no,
                redistribution: factory.yes,
                modification: factory.no,
                private_use: factory.yes,
                include: factory.no
            },
            description: "This is the most restrictive creative commons license.  The license allows redistribution, but restricts commercial use or derivative works."
        },
        custom: {
            name: "Custom License",
            type: "custom",
            options: [{
                name: "Binpress License Generator",
                link: "http://www.binpress.com/license/generator"
            }],
            code: true,
            assets: true,
            terms: {
                credit: factory.unknown,
                commercial: factory.unknown,
                redistribution: factory.unknown,
                modification: factory.unknown,
                private_use: factory.unknown,
                include: factory.unknown
            },
            description: "Make your own license.  The advantage of making your own license is you can define the terms yourself.  The disadvantage is it becomes a harder for users to determine your permissions at a glance, and creating a strong, legally binding license can be time-consuming or difficult.  It is very important to include a statement releasing liability if you make a custom license!"
        }
    };

    this.getLicenses = function() {
        var licenses = [];
        for (var license in factory.licenses) {
            if (factory.licenses.hasOwnProperty(license)) {
                licenses.push(factory.licenses[license]);
            }
        }
        var getClauses = function(license) {
            return license.hasOwnProperty('clauses') ? license.clauses : 99;
        };
        licenses.sort(function(a, b) {
            return getClauses(a) - getClauses(b);
        });
        return licenses;
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
            return [factory.licenses.custom];
        }
        var params = factory.responsesToLicenseParams(content, responses);
        var licenses = factory.getLicenses().filter(function(license) {
            return factory.licenseMatches(license, params);
        });
        if (licenses.length < 2) {
            licenses.push(factory.licenses.custom);
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