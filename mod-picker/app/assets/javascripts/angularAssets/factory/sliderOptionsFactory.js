
// don't get confused that I use .service here. The difference between .service and .factory are only the rules of exposing.
// This stuff actually creates the "Objects" that are declared.
// Too complicated? Agreed. But it makes totally sense when you use it.
app.service('sliderOptionsFactory', function (sliderFactory) {
    this.BaseSlider = function (extend) {
        var options = {
            options: {
                hideLimitLabels: true,
                noSwitching: true
            }
        };
        extend(options);

        return options;
    };

    this.BaseRangeSlider = function (maxValue, extend) {
        return this.BaseSlider(function (options) {
            options.maxValue = maxValue;
            extend(options);
        });
    };

    this.CeilSlider = function (ceil, extend) {
        return this.BaseRangeSlider(ceil, function(options) {
            options.options.floor = 0;
            options.options.ceil = ceil;
            extend(options);
        });
    };

    this.BaseStepsSlider = function(steps) {
        return this.BaseRangeSlider(steps.length, function (options) {
            options.options.stepsArray = steps;
        })
    };

    this.DateSlider = function(start) {
        return this.BaseStepsSlider(sliderFactory.generateDateSteps(start))
    };

    this.StepSlider = function (from, to) {
        return this.BaseStepsSlider(sliderFactory.generateSteps(from, to))
    };

    //TODO: make those Dates a provider.value
    this.UserGeneratedListDateSlider = function () {
        return this.DateSlider(new Date(2016,0,1));
    };

    this.ModListDateSlider = function () {
        return this.DateSlider(new Date(2011,10,11));
    };


});