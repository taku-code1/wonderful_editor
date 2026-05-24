const { VueLoaderPlugin } = require('vue-loader')

module.exports = {
  test: /\.vue$/,
  use: [{
    loader: 'vue-loader'
  }]
}
