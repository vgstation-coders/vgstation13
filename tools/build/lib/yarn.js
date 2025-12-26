import Juke from '../juke/index.js';
import fs from 'fs';
import path from 'path';

let yarnPath;

export const yarn = (...args) => {
  if (!yarnPath) {
    yarnPath = Juke.glob('./tgui/.yarn/releases/*.cjs')[0]
      .replace('/tgui/', '/');
  }
  return Juke.exec('node', [
    yarnPath,
    ...args.filter((arg) => typeof arg === 'string'),
  ], {
    cwd: './tgui',
  });
};

// migration from pnp to node_modules. delete old pnp caches
// this is to save developers having to run yarn commands themselves during the migration period.
// eventually (never) this can be safely removed once no one's local contains the pnp shit of ages past

const tguiDir = path.resolve('./tgui');
const pnpFile = path.join(tguiDir, '.pnp.cjs');
const yarnrcFile = path.join(tguiDir, '.yarnrc.yml');

if (fs.existsSync(pnpFile) && fs.existsSync(yarnrcFile)) {
  const yarnrc = fs.readFileSync(yarnrcFile, 'utf-8');
  if (yarnrc.includes('nodeLinker: node_modules')) {
    fs.rmSync(pnpFile, { force: true });
    fs.rmSync(path.join(tguiDir, '.pnp.loader.mjs'), { force: true });
    fs.rmSync(path.join(tguiDir, '.yarn/unplugged'), { force: true, recursive: true }); // may be locked by zombie node process
    fs.rmSync(path.join(tguiDir, '.yarn/install-state.gz'), { force: true });
    fs.rmSync(path.join(tguiDir, '.yarn/install-target'), { force: true });
  }
}
