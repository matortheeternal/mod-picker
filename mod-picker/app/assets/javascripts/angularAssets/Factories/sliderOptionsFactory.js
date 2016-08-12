// Note: I need to write this comment now that I see this code again after some time.
// It's kinda strange. This stuff looks kinda ugly and not like something I would write. Although, I can only fully
// agree with the me of the past that this code is completely valid and completely correct. There is no better way
// of coding this. I kinda hope we can all forget about this part of the code and never need to touch it.

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
        if(typeof extend === 'function') {
            extend(options);
        }

        return options;
    };

    this.BaseRangeSlider = function (max, extend) {
        return this.BaseSlider(function (options) {
            options.max = parseInt(max);
            if(typeof extend === 'function') {
                extend(options);
            }
        });
    };

    this.CeilSlider = function (ceil, extend) {
        return this.BaseRangeSlider(ceil, function(options) {
            options.options.floor = 0;
            options.options.ceil = parseInt(ceil);
            if(typeof extend === 'function') {
                extend(options);
            }
        });
    };

    this.BaseStepsSlider = function(steps) {
        return this.BaseRangeSlider(steps.length-1, function (options) {
            options.options.stepsArray = steps;
        });
    };

    this.DateSlider = function(start) {
        return this.BaseStepsSlider(sliderFactory.generateDateSteps(start));
    };

    this.BytesSlider = function(max) {
        return this.BaseStepsSlider(sliderFactory.generateByteSteps(max));
    };

    this.StepSlider = function (max) {
        return this.BaseStepsSlider(sliderFactory.generateSteps(1, parseInt(max)));
    };

    //TODO: make those Dates a provider.value
    this.UserDateSlider = function () {
        return this.DateSlider(new Date(2016,0,1));
    };

    this.ModDateSlider = function () {
        return this.DateSlider(new Date(2011,10,11));
    };
});