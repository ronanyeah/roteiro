const CopyWebpackPlugin = require("copy-webpack-plugin");
const { resolve } = require("path");
const webpack = require("webpack");
const { readFileSync } = require("fs");

const { DEBUG, NODE_ENV, API_URL } = process.env;

if (!API_URL) {
  throw Error("missing api endpoint");
}

const publicFolder = resolve("./public");

const production = NODE_ENV === "production";

module.exports = {
  mode: production ? "production" : "development",
  entry: "./client/index.js",
  output: {
    path: publicFolder,
    filename: "bundle.js"
  },
  devServer: {
    contentBase: publicFolder,
    https: {
      key: readFileSync("./https/key.txt"),
      cert: readFileSync("./https/cert.txt")
    },
    historyApiFallback: true
  },
  module: {
    rules: [
      {
        test: /\.scss$/,
        use: [
          {
            loader: "style-loader"
          },
          {
            loader: "css-loader"
          },
          {
            loader: "sass-loader",
            options: {
              data: '$fa-font-path: "/webfonts";'
            }
          }
        ]
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          ...(production ? [] : [{ loader: "elm-hot-webpack-loader" }]),
          {
            loader: "elm-webpack-loader",
            options: {
              cwd: __dirname,
              debug: DEBUG === "true",
              optimize: production
            }
          }
        ]
      }
    ]
  },
  plugins: [
    new webpack.DefinePlugin({
      API_URL: `"${API_URL}"`
    }),
    new webpack.NamedModulesPlugin(),
    new webpack.NoEmitOnErrorsPlugin(),
    new CopyWebpackPlugin(["static"])
  ]
};
