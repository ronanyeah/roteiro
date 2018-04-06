const CopyWebpackPlugin = require("copy-webpack-plugin");
const { resolve } = require("path");
const webpack = require("webpack");

const { GRAPHQL_ENDPOINT, DEBUG, NODE_ENV } = process.env;

if (!GRAPHQL_ENDPOINT) throw Error("missing api endpoint");

const publicFolder = resolve("./public");

module.exports = {
  mode: NODE_ENV === "production" ? "production" : "development",
  entry: "./src/index.js",
  output: {
    path: publicFolder,
    filename: "bundle.js"
  },
  devServer: {
    contentBase: publicFolder,
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
            loader: "sass-loader"
          }
        ]
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          { loader: "elm-hot-loader" },
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
        from: "./node_modules/@fortawesome/fontawesome-free-webfonts/webfonts",
        to: "webfonts"
      }
    ])
  ]
};
