import Juke from '../juke/index.js';

let yarnPath;

export const yarn = (...args) => {
  if (!yarnPath) {
    yarnPath = Juke.glob('./vgui/.yarn/releases/*.cjs')[0]
      .replace('/vgui/', '/');
  }
  return Juke.exec('node', [
    yarnPath,
    ...args.filter((arg) => typeof arg === 'string'),
  ], {
    cwd: './vgui',
  });
};
