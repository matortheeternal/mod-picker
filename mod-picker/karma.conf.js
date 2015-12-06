module.exports = (config) => {
  config.set({

    // base path, that will be used to resolve files and exclude
    basePath: "",


    // frameworks to use
    frameworks: ["jasmine"],

    reporters: ["spec"],

    port: 9876,

    logLevel: config.LOG_INFO,

    autoWatch: true,

    browsers: ["PhantomJS"],

    files: [
      // all files ending in "_test"
      "app/src/**/_tests/*Spec.js",
      // each file acts as entry point for the webpack configuration
    ],

    preprocessors: {
      // add webpack as preprocessor
      "app/src/**/_tests/*Spec.js": ["babel"]
    },

    plugins: [
      require("karma-jasmine"),
      require("karma-spec-reporter"),
      require("karma-phantomjs-launcher"),
      require("karma-babel-preprocessor")
    ]

  });
};
