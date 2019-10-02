const path = require('path');

module.exports = {
  entry: './lib/lockbox.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'lockbox-min.js',
    library: 'LockBox'
  }
};
