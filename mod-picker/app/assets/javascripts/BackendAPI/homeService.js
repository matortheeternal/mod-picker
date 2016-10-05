app.service('homeService', function(backend, $q, reviewSectionService, userTitleService, contributionService) {
    this.retrieveHome = function() {
        var landingData = $q.defer();
        var associateTitlesAndMarks = function(contributions, marks, agreementMarks) {
            userTitleService.associateTitles(contributions);
            if (agreementMarks) {
                contributionService.associateAgreementMarks(contributions, marks);
            } else {
                contributionService.associateHelpfulMarks(contributions, marks);
            }
        };
        backend.retrieve('/home', { game: window._current_game_id }).then(function(data) {
            var recent = data.recent;
            userTitleService.associateTitles(recent.mod_lists);
            reviewSectionService.associateReviewSections(recent.reviews);
            associateTitlesAndMarks(recent.reviews, recent.r_helpful_marks);
            associateTitlesAndMarks(recent.compatibility_notes, recent.c_helpful_marks);
            associateTitlesAndMarks(recent.install_order_notes, recent.i_helpful_marks);
            associateTitlesAndMarks(recent.load_order_notes, recent.l_helpful_marks);
            associateTitlesAndMarks(recent.corrections, recent.agreement_marks, true);
            landingData.resolve(data);
        });
        return landingData.promise;
    };
});
