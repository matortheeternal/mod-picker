app.factory("sortFactory", function() {
    var factory = this;

    // helper function to build a sort option prototype from a label
    this.buildSortOption = function(label) {
        return {
            label: label,
            value: label.toLowerCase().replace(/ /g, "_")
        };
    };

    /* shared sort option prototypes */
    this.helpfulnessSort = {
        label: "Helpfulness",
        value: "reputation"
    };
    this.submittedSort = {
        label: "Date Submitted",
        value: "submitted"
    };
    this.editedSort = {
        label: "Date Edited",
        value: "edited"
    };
    this.correctionsSort = factory.buildSortOption("Corrections Count");
    this.commentsSort = factory.buildSortOption("Comments Count");

    // TODO: Nested sort options (not yet supported)
    /* Submitter reputation
     * Submitter username?
     * Helpful count?
     * Not helpful count?
     * Mod name?
     */

    /* comments index sort options */
    this.commentSortOptions = function() {
        return [
            factory.submittedSort,
            factory.editedSort
        ];
    };

    /* corrections index sort options */
    this.correctionSortOptions = function() {
        return [
            factory.buildSortOption("Agree Count"),
            factory.buildSortOption("Disagree Count"),
            // TODO: Agree percentage or Agreement (flat)?
            factory.submittedSort,
            factory.editedSort,
            factory.commentsSort
        ];
    };

    /* reviews index sort options */
    this.reviewSortOptions = function() {
        return [
            factory.helpfulnessSort,
            factory.buildSortOption("Overall Rating"),
            // TODO: Not ratings count?
            factory.submittedSort,
            factory.editedSort
        ];
    };

    /* compatibility notes index sort options */
    this.compatibilityNoteSortOptions = function() {
        return [
            factory.helpfulnessSort,
            {
                label: "Type",
                value: "status"
            },
            factory.submittedSort,
            factory.editedSort,
            factory.correctionsSort
        ];
    };

    /* install order notes index sort options */
    this.installOrderNoteSortOptions = function() {
        return [
            factory.helpfulnessSort,
            factory.submittedSort,
            factory.editedSort,
            factory.correctionsSort
        ];
    };

    /* load order notes index sort options */
    this.loadOrderNoteSortOptions = function() {
        return [
            factory.helpfulnessSort,
            factory.submittedSort,
            factory.editedSort,
            factory.correctionsSort
        ];
    };

    return factory;
});
