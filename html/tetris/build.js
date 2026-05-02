const esbuild = require('esbuild');
const stdLibBrowser = require('node-stdlib-browser');
const path = require('path');

stdLibBrowser['json3'] = path.resolve(
  __dirname,
  'node_modules/json3/lib/json3.min.js'
);

esbuild.build({
  entryPoints: ['./tetris/src/main.js'],
  bundle: true,
  outfile: 'bundle.js',
  platform: 'browser',
  define: {
    global: 'window',
    'process.env.NODE_DEBUG': '""', // stub out just NODE_DEBUG
  },
  plugins: [],
  inject: [require.resolve('node-stdlib-browser/helpers/esbuild/shim')],
  resolveExtensions: ['.js'],
  alias: stdLibBrowser,
}).catch(() => process.exit(1));