const webpack = require("webpack");
const { resolve } = require("path");

module.exports = {
  entry: "./index.js",
  output: {
    path: resolve("./public/"),
    filename: "bundle.js"
  },
  devServer: {
    contentBase: "./public"
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          { loader: "elm-hot-loader" },
          {
            loader: "elm-webpack-loader",
            options: {
              cwd: __dirname,
              debug: true,
              warn: true
            }
          }
        ]
      }
    ]
  },
  plugins: [
    new webpack.NamedModulesPlugin(),
    new webpack.NoEmitOnErrorsPlugin()
  ]
};
