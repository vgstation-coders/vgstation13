#!/usr/bin/env node
/**
 * Build script for /tg/station 13 codebase.
 *
 * This script uses Juke Build, read the docs here:
 * https://github.com/stylemistake/juke-build
 */

import fs from 'fs';
import Juke from './juke/index.js';
import { DreamDaemon, DreamMaker } from './lib/byond.js';
import { yarn } from './lib/yarn.js';

Juke.chdir('../..', import.meta.url);
Juke.setup({ file: import.meta.url }).then((code) => {
  // We're using the currently available quirk in Juke Build, which
  // prevents it from exiting on Windows, to wait on errors.
  if (code !== 0 && process.argv.includes('--wait-on-error')) {
    Juke.logger.error('Please inspect the error and close the window.');
    return;
  }
  process.exit(code);
});

const DME_NAME = 'vgstation13';

export const DefineParameter = new Juke.Parameter({
  type: 'string[]',
  alias: 'D',
});

export const PortParameter = new Juke.Parameter({
  type: 'string',
  alias: 'p',
});

export const CiParameter = new Juke.Parameter({ type: 'boolean' });

export const WarningParameter = new Juke.Parameter({
  type: 'string[]',
  alias: 'W',
});

export const DmMapsIncludeTarget = new Juke.Target({
  executes: async () => {
    const folders = [
      ...Juke.glob('_maps/RandomRuins/**/*.dmm'),
      ...Juke.glob('_maps/RandomZLevels/**/*.dmm'),
      ...Juke.glob('_maps/shuttles/**/*.dmm'),
      ...Juke.glob('_maps/templates/**/*.dmm'),
    ];
    const content = folders
      .map((file) => file.replace('_maps/', ''))
      .map((file) => `#include "${file}"`)
      .join('\n') + '\n';
    fs.writeFileSync('_maps/templates.dm', content);
  },
});

export const DmTarget = new Juke.Target({
  parameters: [DefineParameter],
  dependsOn: ({ get }) => [
    get(DefineParameter).includes('ALL_MAPS') && DmMapsIncludeTarget,
  ],
  inputs: [
    '__DEFINES/**',
    'code/**',
    'goon/**',
    'html/**',
    'icons/**',
    'interface/**',
    'maps/**',
    'sound/**',
    `${DME_NAME}.dme`,
  ],
  outputs: [
    `${DME_NAME}.dmb`,
    `${DME_NAME}.rsc`,
  ],
  executes: async ({ get }) => {
    await DreamMaker(`${DME_NAME}.dme`, {
      defines: ['CBT', ...get(DefineParameter)],
      warningsAsErrors: get(WarningParameter).includes('error'),
    });
  },
});

export const DmTestTarget = new Juke.Target({
  parameters: [DefineParameter],
  dependsOn: ({ get }) => [
    get(DefineParameter).includes('ALL_MAPS') && DmMapsIncludeTarget,
  ],
  executes: async ({ get }) => {
    fs.copyFileSync(`${DME_NAME}.dme`, `${DME_NAME}.test.dme`);
    await DreamMaker(`${DME_NAME}.test.dme`, {
      defines: ['CBT', 'CIBUILDING', ...get(DefineParameter)],
      warningsAsErrors: get(WarningParameter).includes('error'),
    });
    Juke.rm('data/logs/ci', { recursive: true });
    await DreamDaemon(
      `${DME_NAME}.test.dmb`,
      '-close', '-trusted', '-verbose',
      '-params', 'log-directory=ci'
    );
    Juke.rm('*.test.*');
    try {
      const cleanRun = fs.readFileSync('data/logs/ci/clean_run.lk', 'utf-8');
      console.log(cleanRun);
    }
    catch (err) {
      Juke.logger.error('Test run was not clean, exiting');
      throw new Juke.ExitCode(1);
    }
  },
});

export const YarnTarget = new Juke.Target({
  parameters: [CiParameter],
  inputs: [
    'vgui/.yarn/+(cache|releases|plugins|sdks)/**/*',
    'vgui/**/package.json',
    'vgui/yarn.lock',
  ],
  outputs: [
    'vgui/.yarn/install-target',
  ],
  executes: ({ get }) => yarn('install', get(CiParameter) && '--immutable'),
});

export const TgFontTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  inputs: [
    'vgui/.yarn/install-target',
    'vgui/packages/tgfont/**/*.+(js|cjs|svg)',
    'vgui/packages/tgfont/package.json',
  ],
  outputs: [
    'vgui/packages/tgfont/dist/tgfont.css',
    'vgui/packages/tgfont/dist/tgfont.eot',
    'vgui/packages/tgfont/dist/tgfont.woff2',
  ],
  executes: () => yarn('tgfont:build'),
});

export const vguiTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  inputs: [
    'vgui/.yarn/install-target',
    'vgui/webpack.config.js',
    'vgui/**/package.json',
    'vgui/packages/**/*.+(js|cjs|ts|tsx|scss)',
  ],
  outputs: [
    'vgui/public/vgui.bundle.css',
    'vgui/public/vgui.bundle.js',
    'vgui/public/vgui-panel.bundle.css',
    'vgui/public/vgui-panel.bundle.js',
  ],
  executes: () => yarn('vgui:build'),
});

export const vguiEslintTarget = new Juke.Target({
  parameters: [CiParameter],
  dependsOn: [YarnTarget],
  executes: ({ get }) => yarn('vgui:lint', !get(CiParameter) && '--fix'),
});

export const vguiSonarTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: () => yarn('vgui:sonar'),
});

export const vguiTscTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: () => yarn('vgui:tsc'),
});

export const vguiTestTarget = new Juke.Target({
  parameters: [CiParameter],
  dependsOn: [YarnTarget],
  executes: ({ get }) => yarn(`vgui:test-${get(CiParameter) ? 'ci' : 'simple'}`),
});

export const vguiLintTarget = new Juke.Target({
  dependsOn: [YarnTarget, vguiEslintTarget, vguiTscTarget],
});

export const vguiDevTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: ({ args }) => yarn('vgui:dev', ...args),
});

export const vguiAnalyzeTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: () => yarn('vgui:analyze'),
});

export const vguiBenchTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: () => yarn('vgui:bench'),
});

export const TestTarget = new Juke.Target({
  dependsOn: [DmTestTarget, vguiTestTarget],
});

export const LintTarget = new Juke.Target({
  dependsOn: [vguiLintTarget],
});

export const BuildTarget = new Juke.Target({
  dependsOn: [vguiTarget, DmTarget],
});

export const ServerTarget = new Juke.Target({
  dependsOn: [BuildTarget],
  executes: async ({ get }) => {
    const port = get(PortParameter) || '1337';
    await DreamDaemon(`${DME_NAME}.dmb`, port, '-trusted');
  },
});

export const AllTarget = new Juke.Target({
  dependsOn: [TestTarget, LintTarget, BuildTarget],
});

export const vguiCleanTarget = new Juke.Target({
  executes: async () => {
    Juke.rm('vgui/public/.tmp', { recursive: true });
    Juke.rm('vgui/public/*.map');
    Juke.rm('vgui/public/*.{chunk,bundle,hot-update}.*');
    Juke.rm('vgui/packages/tgfont/dist', { recursive: true });
    Juke.rm('vgui/.yarn/{cache,unplugged,webpack}', { recursive: true });
    Juke.rm('vgui/.yarn/build-state.yml');
    Juke.rm('vgui/.yarn/install-state.gz');
    Juke.rm('vgui/.yarn/install-target');
    Juke.rm('vgui/.pnp.*');
  },
});

export const CleanTarget = new Juke.Target({
  dependsOn: [vguiCleanTarget],
  executes: async () => {
    Juke.rm('*.{dmb,rsc}');
    Juke.rm('*.mdme*');
    Juke.rm('*.m.*');
    Juke.rm('_maps/templates.dm');
  },
});

/**
 * Removes more junk at the expense of much slower initial builds.
 */
export const CleanAllTarget = new Juke.Target({
  dependsOn: [CleanTarget],
  executes: async () => {
    Juke.logger.info('Cleaning up data/logs');
    Juke.rm('data/logs', { recursive: true });
    Juke.logger.info('Cleaning up global yarn cache');
    await yarn('cache', 'clean', '--all');
  },
});

/**
 * Prepends the defines to the .dme.
 * Does not clean them up, as this is intended for TGS which
 * clones new copies anyway.
 */
const prependDefines = (...defines) => {
  const dmeContents = fs.readFileSync(`${DME_NAME}.dme`);
  const textToWrite = defines.map(define => `#define ${define}\n`);
  fs.writeFileSync(`${DME_NAME}.dme`, `${textToWrite}\n${dmeContents}`);
};

export const TgsTarget = new Juke.Target({
  dependsOn: [vguiTarget],
  executes: async () => {
    Juke.logger.info('Prepending TGS define');
    prependDefines('TGS');
  },
});

const TGS_MODE = process.env.CBT_BUILD_MODE === 'TGS';

export default TGS_MODE ? TgsTarget : BuildTarget;
