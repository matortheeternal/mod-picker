app.service('colorsFactory', function() {
    var service = this;

    this.getColors = function() {
        return [
            "red", "orange", "yellow", "green", "blue", "purple", "white", "gray", "brown", "black"
        ]
    };

    this.randomColor = function() {
        service.getColors().random();
    };
});
