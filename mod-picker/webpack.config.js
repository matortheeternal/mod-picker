const path = require("path");

module.exports = {
  entry: path.join(__dirname, "app", "src", "js", "entry.js"),
  output: {
    path: path.join(__dirname, "app", "assets", "javascripts"),
    filename: "bundle.js"
  },
  module: {
    loaders: [{
      test: /\.scss$/,
      loader: "style!css!sass"
    }, {
      test: /\.js$/,
      exclude: /(node_modules)/,
      loader: "babel-loader"
    }, {
      test: /\.js$/,
      exclude: /node_modules/,
      loader: "eslint-loader"
    }]
  }
};
