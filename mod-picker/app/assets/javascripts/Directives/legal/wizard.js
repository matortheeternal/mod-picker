app.directive('wizard', function() {
    return {
        restrict: 'E',
        templateUrl: '/resources/directives/shared/wizard.html',
        scope: false,
        controller: 'wizardController'
    }
});

app.controller('wizardController', function($scope, licenseService, licensesFactory, questionsFactory) {
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

    $scope.retrieveLicenses = function() {
        licenseService.retrieveLicenses().then(function(data) {
            licensesFactory.setLicenses(data);
            $scope.licenses = licensesFactory.getLicenses();
        }, function(response) {
            $scope.error = response;
        });
    };
    $scope.retrieveLicenses();

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
        $scope.similarLicenses = [];
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