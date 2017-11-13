const webpack = require("webpack");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const { resolve } = require("path");

if (!process.env.GRAPHQL_ENDPOINT) throw "Missing GraphQL endpoint!";

const publicFolder = resolve("./public");

module.exports = {
  entry: "./src/index.js",
  output: {
    path: publicFolder,
    filename: "bundle.js"
  },
  devServer: {
    contentBase: publicFolder
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
              debug: process.env.NODE_ENV === "development",
              warn: process.env.NODE_ENV === "development"
            }
          }
        ]
      }
    ]
  },
  plugins: [
    new webpack.DefinePlugin({
      GRAPHQL_ENDPOINT: `"${process.env.GRAPHQL_ENDPOINT}"`
    }),
    new webpack.NamedModulesPlugin(),
    new webpack.NoEmitOnErrorsPlugin(),
    new HtmlWebpackPlugin({
      template: "./src/index.html"
    })
  ]
};
