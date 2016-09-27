app.service('sliderFactory', function (sliderUtils) {
    var factory = this;

    this.extendSlider = function(extend, config) {
        if (typeof extend === 'function') {
            extend(config);
        }
    };

    this.BaseSlider = function(extend) {
        var config = {
            options: {
                hideLimitLabels: true,
                noSwitching: true
            }
        };
        factory.extendSlider(extend, config);

        return config;
    };

    this.BaseRangeSlider = function (max, extend) {
        return this.BaseSlider(function(config) {
            config.max = max;
            factory.extendSlider(extend, config);
        });
    };

    this.CeilSlider = function (min, max, extend) {
        return this.BaseRangeSlider(max, function(config) {
            config.min = min || 0;
            config.options.floor = min || 0;
            config.options.ceil = max;
            factory.extendSlider(extend, config);
        });
    };

    this.BaseStepsSlider = function(steps) {
        return this.BaseRangeSlider(steps.length - 1, function(config) {
            config.options.stepsArray = steps;
        });
    };

    this.StepSlider = function(max) {
        return this.BaseStepsSlider(sliderUtils.generateSteps(1, max));
    };

    // Dynamically called by buildSlider
    this.DateSlider = function(start) {
        return this.BaseStepsSlider(sliderUtils.generateDateSteps(start));
    };

    // Dynamically called by buildSlider
    this.BytesSlider = function(max) {
        return this.BaseStepsSlider(sliderUtils.generateByteSteps(max));
    };

    this.buildSlider = function(filter) {
        if (filter.subtype) {
            var sliderType = filter.subtype + "Slider";
            return factory[sliderType](filter.start || filter.max);
        } else if (filter.max > 500) {
            return factory.StepSlider(filter.max);
        } else {
            return factory.CeilSlider(filter.min, filter.max);
        }
    };
});