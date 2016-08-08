//= require_self
//= require ./polyfills.js
//= require ./angularAssets/BackendAPI/backend.js
//= require ./angularAssets/BackendAPI/contributionService.js
//= require ./angularAssets/BackendAPI/reviewSectionService.js
//= require ./angularAssets/BackendAPI/userService.js
//= require ./angularAssets/BackendAPI/userSettingsService.js
//= require ./angularAssets/BackendAPI/userTitleService.js
//= require ./angularAssets/Directives/loader.js
//= require ./angularAssets/Directives/textArea.js
//= require ./angularAssets/Directives/contributions/comment.js
//= require ./angularAssets/Directives/contributions/comments.js
//= require ./angularAssets/Factories/spinnerFactory.js
//= require ./angularAssets/Services/pageUtils.js
//= require ./angularAssets/Services/ObjectUtils.js
//= require_tree ./angularAssets/Directives/help

var app = angular.module('helpCenter', [
    'ngAnimate', 'sticky', 'hc.marked', 'relativeDate'
]);

app.config(['$compileProvider', function($compileProvider) {
    $compileProvider.debugInfoEnabled(false);
}]);
