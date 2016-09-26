//= require_self
//= require ./polyfills.js
//= require BackendAPI/backend.js
//= require BackendAPI/contributionService.js
//= require BackendAPI/reviewSectionService.js
//= require BackendAPI/userService.js
//= require BackendAPI/userSettingsService.js
//= require BackendAPI/userTitleService.js
//= require Directives/layout/loader.js
//= require Directives/shared/textArea.js
//= require Directives/shared/sticky.js
//= require Directives/contributions/comment.js
//= require Directives/contributions/comments.js
//= require Factories/spinnerFactory.js
//= require Services/pageUtils.js
//= require Services/ObjectUtils.js
//= require_tree Directives/help

var app = angular.module('helpCenter', [
    'ngAnimate', 'hc.marked', 'relativeDate'
]);

app.config(['$compileProvider', function($compileProvider) {
    $compileProvider.debugInfoEnabled(false);
}]);
