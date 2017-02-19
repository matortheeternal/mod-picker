app.directive('license', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/license.html',
        scope: {
            license: '=?'
        },
        controller: 'licenseController'
    }
});

app.controller('licenseController', function($scope) {
    angular.inherit($scope, 'license');
    $scope.typeIcons = {
        copyright: "fa-copyright",
        permissive: "fa-universal-access",
        copyleft: "fa-copyright fa-rotate-180",
        "weak copyleft": "fa-copyright fa-rotate-180 weak",
        "mostly copyleft": "fa-copyright fa-rotate-180 mostly",
        custom: "fa-file-text-o"
    };
    $scope.termHints = {
        credit: "Attribution (crediting you)",
        commercial: "Commercial use",
        redistribution: "Redistribution",
        modification: "Distribution of modified copies",
        private_use: "Private use",
        include: "Using the same or a similar license"
    };
    $scope.termValueHints = {
        required: {
            "-1": "up to you",
            0: "not required",
            1: "required",
            2: "up to you"
        },
        allowed: {
            "-1": "up to you",
            0: "not allowed",
            1: "allowed",
            2: "allowed on a case-by-case basis"
        }
    };
    $scope.termIcons = {
        credit: "fa-external-link",
        commercial: "fa-money",
        redistribution: "fa-retweet", // "fa-share-square-o", "fa-share"
        modification: "fa-edit",
        private_use: "fa-user",
        include: "fa-lock"
    };
    $scope.termOverlays = {
        "-1": "fa-question",
        0: "fa-ban",
        1: "",
        2: "fa-question"
    };
    $scope.termType = {
        credit: 'required',
        commercial: 'allowed',
        redistribution: 'allowed',
        modification: 'allowed',
        private_use: 'allowed',
        include: 'required'
    };
});