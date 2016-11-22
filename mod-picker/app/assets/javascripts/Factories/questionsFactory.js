app.service("questionsFactory", function() {
    var factory = this;

    // individual options
    this.optionNo = { id: 0, text: "No" };
    this.optionYes = { id: 1, text: "Yes" };
    this.optionDontCare = { id: 2, text: "I don't care" };
    this.optionMaybe = { id: 2, text: "Maybe" };

    // options groups
    this.optionsYN = [factory.optionYes, factory.optionNo];
    this.optionsYNDC = [factory.optionYes, factory.optionNo, factory.optionDontCare];
    this.optionsYNMB = [factory.optionYes, factory.optionNo, factory.optionMaybe];

    // targetted questions
    this.allowCommercialUse = {
        key: "commercial",
        label: "Commercial use",
        text: "Do you want to allow other people to use your {{target}} commercially?",
        options: factory.optionsYNDC
    };
    this.requireCredit = {
        key: "credit",
        label: "Attribution",
        text: "Should users credit you if they use your {{target}}?",
        options: factory.optionsYNDC
    };
    this.redistributeWithoutPermission = {
        key: "redistribution",
        label: "Redistribution",
        text: "Do you want to allow users to redistribute your {{target}} without asking for permission?",
        options: factory.optionsYN
    };
    this.modifyWithoutPermission = {
        key: "modification",
        label: "Modification",
        text: "Do you want to allow users to modify your {{target}} or use it in their own projects without asking for permission?",
        options: factory.optionsYN
    };
    this.useSamePermissions = {
        key: "include",
        label: "Share Alike",
        text: "Do you want to require people who use your {{target}} to use the same permissions/license as your {{target}}?",
        options: factory.optionsYNDC
    };
    this.uniqueCircumstances = {
        conditional: function($scope) {
            var contextResponses = $scope.responses[this.subkey];
            return contextResponses && contextResponses.modification == 0;
        },
        key: "uniqueCircumstances",
        label: "Unique Circumstances",
        text: "Are there any unique circumstances in which you would like to allow people to use your {{target}} without asking for permission?",
        options: [
            { id: 0, text: "None." },
            { id: 1, text: "For translation" },
            { id: 2, text: "I would like to allow my work to be re-used by members of the community if I am no longer active in the community and can no longer be reached by any publicly available methods of contact." },
            { id: 3, text: "Other" }
        ]
    };

    // helper functions
    this.target = function(target, question) {
        question.text = question.text.replace(/\{\{target\}\}/g, target);
        question.subkey = target;
        return question;
    };

    this.mapTargettedQuestions = function(target, questions) {
        return questions.map(function(question) {
            return factory.target(target, angular.copy(factory[question]));
        });
    };

    // question sets
    this.getGeneralQuestions = function() {
        return angular.copy([{
            key: "contains",
            label: "Select mod content",
            text: "Does your mod contain asset/data files (plugins, meshes, textures, scripts, sounds, etc.), external code (tools, DLLs, etc.), or both?",
            options: [
                { id: 0, text: "Just asset/data files" },
                { id: 1, text: "Just external code" },
                { id: 2, text: "External code and asset/data files" }
            ],
            executeAfter: function($scope) {
                if ($scope.responses.contains == 2) return;
                $scope.loadContentQuestions();
            }
        }, {
            key: "same",
            label: "Use same permissions",
            conditional: function($scope) {
                return $scope.responses.contains == 2;
            },
            text: "Do you want to use the same permissions for your code and asset/data files?",
            options: factory.optionsYN,
            executeAfter: function($scope) {
                $scope.loadContentQuestions();
            }
        }]);
    };

    // targetted question sets
    var targettedQuestions = ["allowCommercialUse", "requireCredit", "redistributeWithoutPermission", "modifyWithoutPermission", "useSamePermissions", "uniqueCircumstances"];

    this.getContentQuestions = function(content) {
        return factory.mapTargettedQuestions(content, targettedQuestions);
    };
});