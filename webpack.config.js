const CopyWebpackPlugin = require("copy-webpack-plugin");
const { resolve } = require("path");
const webpack = require("webpack");
const { readFileSync } = require("fs");

const { GRAPHQL_ENDPOINT, DEBUG, NODE_ENV } = process.env;

if (!GRAPHQL_ENDPOINT) throw Error("missing api endpoint");

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
    proxy: {
      "/api": {
        target: GRAPHQL_ENDPOINT,
        pathRewrite: { "^/api": "" }
      }
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
          ...(production ? [] : [{ loader: "elm-hot-loader" }]),
          {
            loader: "elm-webpack-loader",
            options: {
              cwd: __dirname,
              debug: DEBUG === "true",
              warn: NODE_ENV === "development"
            }
          }
        ]
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            presets: ["@babel/preset-env"]
          }
        }
      }
    ]
  },
  plugins: [
    new webpack.NamedModulesPlugin(),
    new webpack.NoEmitOnErrorsPlugin(),
    new CopyWebpackPlugin([
      "static",
      {
        from: "./node_modules/@fortawesome/fontawesome-free/webfonts",
        to: "webfonts"
      }
    ])
  ]
};
