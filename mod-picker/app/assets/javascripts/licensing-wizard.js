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
    $scope.questions = questionsFactory.getQuestions();
});
