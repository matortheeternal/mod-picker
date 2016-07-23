app.service('homeService', function(backend, $q, reviewSectionService, userTitleService) {
    this.retrieveHome = function() {
        landingData = $q.defer();
        backend.retrieve('/home', { game: window._current_game_id }).then(function(data) {
            userTitleService.associateTitles(data.recent.reviews);
            reviewSectionService.associateReviewSections(data.recent.reviews);
            userTitleService.associateTitles(data.recent.mod_lists);
            userTitleService.associateTitles(data.recent.compatibility_notes);
            userTitleService.associateTitles(data.recent.install_order_notes);
            userTitleService.associateTitles(data.recent.load_order_notes);
            userTitleService.associateTitles(data.recent.corrections);
            landingData.resolve(data);
        });
        return landingData.promise;
    };
});
