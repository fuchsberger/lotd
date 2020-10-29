const path = require('path')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const TerserPlugin = require('terser-webpack-plugin')
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin')

module.exports = (env, options) => ({
  devtool: options.mode == 'development' ? 'source-map' : undefined,

  // stats: 'minimal',

  entry: './js/app.js',

  optimization: {
    minimizer: [
      new TerserPlugin({ test: /\.js(\?.*)?$/i, }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },

  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, '../priv/static/js'),
    publicPath: '/js/'
  },

  module: {
    rules: [
      {
        // handles javaScript
        test: /\.js$/,
        exclude: /node_modules/i,
        use: { loader: 'babel-loader' }
      },
      {
        test: /\.s[ac]ss$/i,
        use: [
          MiniCssExtractPlugin.loader,  // extract CSS into separate file
          'css-loader',                 // translates CSS into CommonJS
          {
            loader: 'sass-loader',      // compiles Sass to CSS
            options: { sassOptions: { includePaths: ['node_modules/bulma/sass/']}}
          }
        ]
      },
      {
        // handles icons font and logo
        test: /\.(png|woff2)$/i,
        loader: 'url-loader',
        options: { limit: 8192 } // 8 Kb
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: '../css/app.css' }),
    new CopyWebpackPlugin({ patterns: [{ from: 'static/', to: '../' }]})
  ]
})
