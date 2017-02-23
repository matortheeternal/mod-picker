//= require angular.min.1.5.1.js
//= require angular-animate.min.js
//= require angular-elastic-input.min.js
//= require_self
//= require ./BackendAPI/backend.js
//= require ./BackendAPI/licenseService.js
//= require_tree ./Directives/legal
//= require ./Services/ObjectUtils.js
//= require ./Factories/licensesFactory.js
//= require ./Factories/questionsFactory.js
//= require ./polyfills.js
/*
 Mod Picker Licensing Wizard v1.4
 (c) 2017 Mod Picker, LLC. https://www.modpicker.com
*/

var app = angular.module('licensingWizard', [
    'ngAnimate', 'puElasticInput'
]);
