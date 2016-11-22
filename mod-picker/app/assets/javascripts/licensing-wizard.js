//= require angular.min.1.5.1.js
//= require angular-animate.min.js
//= require angular-elastic-input.min.js
//= require_self
//= require ./Factories/licensesFactory.js
//= require ./Factories/questionsFactory.js
//= require ./polyfills.js
/*
 Mod Picker Licensing Wizard v1.0
 (c) 2016 Mod Picker, LLC. https://www.modpicker.com
*/

var app = angular.module('licensingWizard', [
    'ngAnimate', 'puElasticInput'
]);

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
            2: "allowed with permission"
        }
    };
    $scope.termRequiredHints = {
    };
    $scope.termIcons = {
        credit: "fa-external-link",
        commercial: "fa-money",
        redistribution: "fa-share-square-o", // "fa-envelope-o", "fa-share", "fa-share-alt"
        modification: "fa-edit",
        private_use: "fa-user",
        include: "fa-lock"
    };
    $scope.termOverlays = {
        "-1": "fa-question",
        0: "fa-ban",
        1: "",
        2: "fa-ban soft"
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

app.directive('wizard', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/wizard.html',
        scope: false,
        controller: 'wizardController'
    }
});

app.controller('wizardController', function($scope, licensesFactory, questionsFactory) {
    $scope.licenses = licensesFactory.getLicenses();
    $scope.questions = questionsFactory.getGeneralQuestions();
    $scope.similarLicensesLimit = 2;
    $scope.matchingLicensesLimit = 2;
    $scope.sections = [{
        name: "General",
        questions: $scope.questions
    }];
    $scope.questions[0].active = true;
    $scope.currentQuestionIndex = 0;
    $scope.currentTab = 0;
    $scope.showQuestionColumn = true;
    $scope.responses = {};

    $scope.switchTab = function(index) {
        $scope.currentTab = index;
    };

    $scope.getLicenses = function(content) {
        $scope.matchingLicenses = Array.prototype.concat(
            $scope.matchingLicenses,
            licensesFactory.getMatchingLicenses(content, $scope.responses)
        );
        $scope.similarLicenses = Array.prototype.concat(
            $scope.similarLicenses,
            licensesFactory.getSimilarLicenses(content, $scope.responses)
        );
    };

    $scope.loadResults = function() {
        $scope.leaveQuestion(true);
        $scope.showResults = true;
        $scope.matchingLicenses = [];
        $scope.similarLicenses =[];
        if ($scope.responses.contains < 2 || $scope.responses.same) {
            $scope.getLicenses(contents[$scope.responses.contains]);
        } else {
            $scope.getLicenses("assets");
            $scope.getLicenses("code");
        }
    };

    $scope.resetWizard = function() {
        $scope.responses = {};
        $scope.sections[0].questions = questionsFactory.getGeneralQuestions();
        $scope.clearContentQuestions();
    };

    $scope.getQuestionIndex = function(section, index) {
        return $scope.questions.indexOf(section.questions[index]);
    };

    $scope.gotoQuestion = function(section, index) {
        $scope.showResults = false;
        var targetQuestion = section.questions[index];
        if (targetQuestion.skipped) return;
        $scope.leaveQuestion(true);
        $scope.currentQuestionIndex = $scope.getQuestionIndex(section, index);
        $scope.enterQuestion(true);
    };

    $scope.gotoFirstUnansweredQuestion = function() {
        var index;
        var section = $scope.sections.find(function(section) {
            return section.questions.find(function(question, qIndex) {
                index = qIndex;
                return question.answered;
            });
        });
        if (index) $scope.gotoQuestion(section, index);
    };

    $scope.leaveQuestion = function(skip) {
        var currentQuestion = $scope.questions[$scope.currentQuestionIndex];
        if (!currentQuestion) return;
        if (!skip && currentQuestion.executeAfter) {
            currentQuestion.executeAfter($scope);
        }
        currentQuestion.active = false;
    };

    $scope.enterQuestion = function(next) {
        var currentQuestion = $scope.questions[$scope.currentQuestionIndex];
        if (!currentQuestion) return;
        currentQuestion.active = true;
        currentQuestion.skipped = false;
        if (currentQuestion.conditional && !currentQuestion.conditional($scope)) {
            currentQuestion.skipped = true;
            next ? $scope.nextQuestion(true) : $scope.previousQuestion(true);
        }
    };

    $scope.previousQuestion = function(skip) {
        if ($scope.currentQuestionIndex == 0) return;
        $scope.leaveQuestion(skip);
        $scope.currentQuestionIndex -= 1;
        $scope.enterQuestion();
    };

    $scope.onLastQuestion = function() {
        return $scope.currentQuestionIndex == $scope.questions.length - 1;
    };

    $scope.nextQuestion = function(skip) {
        $scope.leaveQuestion(skip);
        $scope.currentQuestionIndex += 1;
        $scope.enterQuestion(true);
        if ($scope.allQuestionsAnswered()) {
            $scope.loadResults();
        } else if ($scope.onLastQuestion()) {
            $scope.gotoFirstUnansweredQuestion();
        }
    };

    var contentSectionName = {
        assets: "Asset Licensing",
        code: "Code Licensing",
        materials: "Material Licensing"
    };
    $scope.addContentSection = function(content) {
        var newSection = {
            name: contentSectionName[content],
            questions: questionsFactory.getContentQuestions(content)
        };
        $scope.sections.push(newSection);
    };

    $scope.clearContentQuestions = function() {
        $scope.sections.splice(1);
    };

    $scope.rebuildQuestions = function() {
        $scope.questions = [];
        $scope.sections.forEach(function(section) {
            $scope.questions = $scope.questions.concat(section.questions);
        });
    };

    var contents = ["assets", "code", "materials"];
    $scope.loadContentQuestions = function() {
        $scope.clearContentQuestions();
        if ($scope.responses.contains < 2 || $scope.responses.same) {
            $scope.addContentSection(contents[$scope.responses.contains]);
        } else {
            $scope.addContentSection("assets");
            $scope.addContentSection("code");
        }
        $scope.rebuildQuestions();
    };

    $scope.setResponse = function(subkey, key, id) {
        if (subkey) {
            if (!$scope.responses.hasOwnProperty(subkey)) {
                $scope.responses[subkey] = {};
            }
            $scope.responses[subkey][key] = id;
        } else {
            $scope.responses[key] = id;
        }
    };

    $scope.allQuestionsAnswered = function() {
        return $scope.questions.reduce(function(answered, question) {
            return answered && question.answered || question.skipped;
        }, true);
    };

    $scope.selectOption = function(question, option) {
        question.options.forEach(function(option) { option.selected = false; });
        question.answered = true;
        option.selected = true;
        $scope.setResponse(question.subkey, question.key, option.id);
        $scope.nextQuestion();
    };

    $scope.toggleShowSimilar = function() {
        $scope.similarLicensesLimit = $scope.similarLicensesLimit == 2 ? 10 : 2;
    };

    $scope.toggleShowMatching = function() {
        $scope.matchingLicensesLimit = $scope.matchingLicensesLimit == 2 ? 10 : 2;
    };
});
