app.service('pageUtils', function () {
    this.getPageInformation = function(data, pages, newPage) {
        pages.max = Math.ceil(data.max_entries / data.entries_per_page);
        pages.current = newPage || pages.current || 1;
    };
});