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
    this.useCommercially = {
        key: "useCommercially",
        text: "Do you plan to use your {{target}} commercially?",
        options: factory.optionsYNMB
    };
    this.allowCommercialUse = {
        key: "allowCommercialUse",
        text: "Do you want to allow other people to use your {{target}} commercially?",
        options: factory.optionsYNDC
    };
    this.requireCredit = {
        key: "requireCredit",
        text: "Should users credit you if they use your {{target}}?",
        options: factory.optionsYNDC
    };
    this.redistributeWithoutPermission = {
        key: "redistributeWithoutPermission",
        text: "Do you want to allow users to redistribute your {{target}} without asking for permission?",
        options: factory.optionsYN
    };
    this.modifyWithoutPermission = {
        key: "modifyWithoutPermission",
        text: "Do you want to allow users to modify your {{target}} or use it in their own projects without asking for permission?",
        options: factory.optionsYN
    };
    this.useSamePermissions = {
        key: "useSamePermissions",
        text: "Do you want to require people who use your {{target}} to use the same permissions/license as your {{target}}?",
        options: factory.optionsYNDC
    };
    this.uniqueCircumstances = {
        conditional: function($scope) {
            var contextResponses = $scope.responses[$scope.currentContext];
            return contextResponses.modifyWithoutPermission == 0;
        },
        key: "uniqueCircumstances",
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
        return question.replace(/\{\{target\}\}/g, target);
    };

    this.mapTargettedQuestions = function(target, questions) {
        return questions.map(function(question) {
            return factory.target('code', factory[question]);
        });
    };

    // question sets
    this.getGeneralQuestions = function() {
        return [{
            key: "contains",
            text: "Does your mod contain asset/data files (such as plugins, textures, models, scripts, and sounds), code (such as utilities and DLLs), or both?",
            options: [
                { id: 0, text: "Just asset/data files" },
                { id: 1, text: "Just code" },
                { id: 2, text: "Code and asset/data files" }
            ]
        }, {
            key: "same",
            conditional: function($scope) {
                return $scope.responses.contains == 2;
            },
            text: "Do you want to use the same permissions for your code and asset/data files?",
            options: factory.optionsYN
        }];
    };

    // targetted question sets
    var targettedQuestions = ["useCommercially", "allowCommercialUse", "requireCredit", "redistributeWithoutPermission", "modifyWithoutPermission", "useSamePermissions", "uniqueCircumstances"];

    this.getCodeQuestions = function() {
        return factory.mapTargettedQuestions('code', targettedQuestions);
    };

    this.getAssetQuestions = function() {
        return factory.mapTargettedQuestions('assets', targettedQuestions);
    };

    this.getMaterialQuestions = function() {
        return factory.mapTargettedQuestions('materials', targettedQuestions);
    };
});