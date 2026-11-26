// Copyright (c) 2026 /vg/station coders
// SPDX-License-Identifier: MIT

import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike, classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type LabeledValue = {
  label: string;
  value: string;
};

type RecordSummary = {
  ref: string;
  id: string;
  name: string;
};

type SoftwareEntry = {
  id: string;
  name: string;
  cost: number;
  installed: BooleanLike;
};

type MedicalData = {
  records?: RecordSummary[];
  active1?: LabeledValue[];
  active2?: LabeledValue[];
  comments?: string[];
  bioscan?: string;
  error?: string;
};

type MessengerData = {
  toff?: BooleanLike;
  silent?: BooleanLike;
  error?: string;
  pdas?: { ref: string; name: string }[];
  messages?: { key: string; text: string }[];
};

type AtmoData = {
  error?: string;
  pressure?: number;
  temperature?: number;
  gases?: { name: string; percent: number }[];
};

type ManifestEntry = {
  name: string;
  rank: string;
  active: string;
};

type ManifestData = {
  heads?: ManifestEntry[];
  sec?: ManifestEntry[];
  eng?: ManifestEntry[];
  med?: ManifestEntry[];
  sci?: ManifestEntry[];
  cgo?: ManifestEntry[];
  civ?: ManifestEntry[];
  bot?: ManifestEntry[];
  misc?: ManifestEntry[];
};

type Data = {
  name: string;
  carrier?: string | null;
  ram: number;
  screen: string;
  subscreen: number;
  temp?: string | null;
  software?: string[];
  available?: SoftwareEntry[];
  toggles: {
    translator?: BooleanLike;
    light?: BooleanLike;
    mesons?: BooleanLike;
    volume?: BooleanLike;
  };
  signal: {
    frequency: number;
    code: number;
  };
  uninstall?: {
    progress: number;
    target?: string | null;
  };
  charge?: number;
  directives?: {
    master?: string | null;
    dna?: string | null;
    law0?: string;
    laws?: string | null;
  };
  manifest?: ManifestData;
  medical?: MedicalData;
  security?: MedicalData;
  messenger?: MessengerData;
  atmo?: AtmoData;
  wirejack?: {
    target?: string | null;
    progress?: number;
  };
  chems?: { name: string; id: string }[];
  foods?: { name: string; path: string }[];
  holomap?: {
    mode?: string;
  };
};

const SCREEN_TITLES: Record<string, string> = {
  main: 'pAI OS',
  directives: 'Directives',
  buy: 'CentComm pAI Module CVS Network',
  uninstall: 'Uninstall software',
  'crew manifest': 'Crew Manifest',
  'digital messenger': 'Digital Messenger',
  'medical supplement': 'Medical Records',
  'security supplement': 'Security Records',
  'universal translator': 'Universal Translator',
  'atmosphere sensor': 'Atmospheric Sensor',
  wirejack: 'Wirejack',
  'chem synth': 'Chemical Synthesizer',
  'food synth': 'Nutrition Synthesizer',
  'remote signaller': 'Remote Signaller',
  'redundant threading': 'Redundant Threading',
  flashlight: 'Brightness Enhancer',
  'holomap viewer': 'Holomap Viewer',
  'volume enhancer': 'Volume Enhancer',
  'meson augmentation': 'Meson Firmware',
};

const ScreenButton = (props: {
  current: string;
  screen: string;
  label: string;
}) => {
  const { act } = useBackend();
  const active = props.current === props.screen;
  return (
    <Button
      fluid
      className={classes([
        'paios-nav__item',
        active && 'paios-nav__item--active',
      ])}
      onClick={() => act('screen', { screen: props.screen })}
    >
      <span className="paios-cursor">{active ? '❯' : ' '}</span>
      {props.label}
    </Button>
  );
};

const ActionButton = (props: {
  action: string;
  label: string;
  params?: Record<string, unknown>;
}) => {
  const { act } = useBackend();
  return (
    <Button
      fluid
      className="paios-nav__item"
      onClick={() => act(props.action, props.params)}
    >
      <span className="paios-cursor"> </span>
      {props.label}
    </Button>
  );
};

const NavCategory = (props: { label: string }) => (
  <Box className="paios-nav__category">{props.label}</Box>
);

const ToggleButton = (props: {
  toggle: string;
  enabled?: BooleanLike;
  enabledLabel?: string;
  disabledLabel?: string;
}) => {
  const { act } = useBackend();
  return (
    <Button
      color={props.enabled ? 'good' : 'bad'}
      onClick={() => act('toggle', { toggle: props.toggle })}
    >
      {props.enabled
        ? props.enabledLabel || 'Disable'
        : props.disabledLabel || 'Enable'}
    </Button>
  );
};

const ValueList = (props: { values?: LabeledValue[] }) => {
  if (!props.values?.length) {
    return <Box color="label">No data.</Box>;
  }
  return (
    <LabeledList>
      {props.values.map((value) => (
        <LabeledList.Item key={value.label} label={value.label}>
          {value.value || 'Unknown'}
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
};

export const PaiOS = () => {
  const { act, data } = useBackend<Data>();
  const screen = data.screen || 'main';
  const has = (id: string) => !!data.software?.includes(id);
  const toggles = data.toggles || ({} as Data['toggles']);
  const signal = data.signal || { frequency: 0, code: 0 };
  const ram = data.ram || 0;
  const uninstall = data.uninstall || { progress: -1 };
  const available = data.available || [];

  const renderContent = () => {
    switch (screen) {
      case 'main':
        return (
          <>
            <LabeledList>
              <LabeledList.Item label="Available RAM">{ram}</LabeledList.Item>
              <LabeledList.Item label="Installed modules">
                {data.software?.length || 0}
              </LabeledList.Item>
              <LabeledList.Item label="Status">Online</LabeledList.Item>
            </LabeledList>
            <Box mt={1}>
              Use the menu on the right to open a module or download additional
              software.
            </Box>
          </>
        );

      case 'directives': {
        const directives = data.directives || {};
        return (
          <>
            <LabeledList>
              <LabeledList.Item label="Master">
                {directives.master || 'Unbound'}
              </LabeledList.Item>
              <LabeledList.Item label="DNA">
                {directives.dna || 'Unknown'}
              </LabeledList.Item>
              <LabeledList.Item label="Prime Directive">
                {directives.law0 || 'None'}
              </LabeledList.Item>
              {!!directives.laws && (
                <LabeledList.Item label="Supplemental">
                  {directives.laws}
                </LabeledList.Item>
              )}
            </LabeledList>
            <Box mt={1}>
              <Button onClick={() => act('getdna')}>
                Request carrier DNA sample
              </Button>
            </Box>
          </>
        );
      }

      case 'buy':
        return (
          <>
            <Box mb={1}>Remaining Available Memory: {ram}</Box>
            <LabeledList>
              {available.map((entry) => (
                <LabeledList.Item
                  key={entry.id}
                  label={`${entry.name} (${entry.cost})`}
                >
                  {entry.installed ? (
                    'Installed'
                  ) : (
                    <Button
                      disabled={ram < entry.cost}
                      onClick={() => act('buy', { target: entry.id })}
                    >
                      Download
                    </Button>
                  )}
                </LabeledList.Item>
              ))}
            </LabeledList>
          </>
        );

      case 'uninstall': {
        const installed = (data.software || []).filter((id) =>
          available.some((entry) => entry.id === id),
        );
        return (
          <>
            {uninstall.progress >= 0 && (
              <ProgressBar value={uninstall.progress} maxValue={100} />
            )}
            {!!uninstall.target && (
              <Box mb={1}>Uninstalling {uninstall.target}...</Box>
            )}
            <LabeledList>
              {installed.map((id) => {
                const entry = available.find((item) => item.id === id);
                return (
                  <LabeledList.Item
                    key={id}
                    label={`${entry?.name || id} (${entry?.cost || 0})`}
                  >
                    <Button
                      disabled={uninstall.progress >= 0}
                      onClick={() => act('uninstall', { target: id })}
                    >
                      Uninstall
                    </Button>
                  </LabeledList.Item>
                );
              })}
            </LabeledList>
            {uninstall.progress >= 0 && (
              <Box mt={1}>
                <Button onClick={() => act('cancel_uninstall')}>Cancel</Button>
              </Box>
            )}
          </>
        );
      }

      case 'crew manifest': {
        const manifest = data.manifest || {};
        const labels: Record<string, string> = {
          heads: 'Heads',
          sec: 'Security',
          eng: 'Engineering',
          med: 'Medical',
          sci: 'Science',
          cgo: 'Cargo',
          civ: 'Civilian',
          bot: 'Silicons',
          misc: 'Misc',
        };
        const departments = Object.entries(manifest).filter(
          ([, entries]) => entries?.length,
        );
        if (!departments.length) {
          return <NoticeBox>No manifest available.</NoticeBox>;
        }
        return (
          <>
            {departments.map(([department, entries]) => (
              <Section
                key={department}
                title={labels[department] || department}
              >
                <LabeledList>
                  {(entries || []).map((entry) => (
                    <LabeledList.Item key={entry.name} label={entry.name}>
                      {entry.rank} ({entry.active})
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              </Section>
            ))}
          </>
        );
      }

      case 'medical supplement': {
        const medical = data.medical;
        if (!medical) {
          return null;
        }
        if (medical.error) {
          return <NoticeBox>{medical.error}</NoticeBox>;
        }
        if (data.subscreen === 0) {
          return (
            <>
              <Box mb={1}>
                <Button onClick={() => act('subscreen', { subscreen: 2 })}>
                  Host Bioscan
                </Button>
              </Box>
              <LabeledList>
                {(medical.records || []).map((record) => (
                  <LabeledList.Item
                    key={record.ref}
                    label={`${record.id}: ${record.name}`}
                  >
                    <Button
                      onClick={() =>
                        act('medical', { record: record.ref, sub: 1 })
                      }
                    >
                      View
                    </Button>
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </>
          );
        }
        if (data.subscreen === 1) {
          return (
            <>
              <ValueList values={medical.active1} />
              <ValueList values={medical.active2} />
              <Box mt={1}>
                <Button onClick={() => act('subscreen', { subscreen: 0 })}>
                  Back
                </Button>
              </Box>
            </>
          );
        }
        return (
          <>
            <Box style={{ whiteSpace: 'pre-wrap' }}>
              {medical.bioscan || 'Scan unavailable.'}
            </Box>
            <Box mt={1}>
              <Button onClick={() => act('subscreen', { subscreen: 0 })}>
                Return to Records
              </Button>
            </Box>
          </>
        );
      }

      case 'security supplement': {
        const security = data.security;
        if (!security) {
          return null;
        }
        if (security.error) {
          return <NoticeBox>{security.error}</NoticeBox>;
        }
        if (data.subscreen === 0) {
          return (
            <LabeledList>
              {(security.records || []).map((record) => (
                <LabeledList.Item
                  key={record.ref}
                  label={`${record.id}: ${record.name}`}
                >
                  <Button
                    onClick={() =>
                      act('security', { record: record.ref, sub: 1 })
                    }
                  >
                    View
                  </Button>
                </LabeledList.Item>
              ))}
            </LabeledList>
          );
        }
        return (
          <>
            <ValueList values={security.active1} />
            <ValueList values={security.active2} />
            {(security.comments || []).map((comment, index) => (
              <Box key={index} mt={0.5}>
                {comment}
              </Box>
            ))}
            <Box mt={1}>
              <Button onClick={() => act('subscreen', { subscreen: 0 })}>
                Back
              </Button>
            </Box>
          </>
        );
      }

      case 'digital messenger': {
        const messenger = data.messenger;
        if (!messenger) {
          return null;
        }
        if (messenger.error) {
          return <NoticeBox>{messenger.error}</NoticeBox>;
        }
        return (
          <>
            <LabeledList>
              <LabeledList.Item label="Signal/Receiver">
                <Button onClick={() => act('messenger', { toggler: 1 })}>
                  {messenger.toff ? 'Off' : 'On'}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Ringer">
                <Button onClick={() => act('messenger', { ringer: 1 })}>
                  {messenger.silent ? 'Off' : 'On'}
                </Button>
              </LabeledList.Item>
            </LabeledList>
            {!messenger.toff && (
              <Box mt={1}>
                <Section title="Viewable PDAs">
                  <LabeledList>
                    {(messenger.pdas || []).map((pda) => (
                      <LabeledList.Item key={pda.ref} label={pda.name}>
                        <Button
                          onClick={() => act('messenger', { target: pda.ref })}
                        >
                          Message
                        </Button>
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                </Section>
              </Box>
            )}
            <Box mt={1}>
              <Section title="Messages">
                {(messenger.messages || []).map((message) => (
                  <Box
                    key={message.key}
                    style={{ whiteSpace: 'pre-wrap' }}
                    mb={1}
                  >
                    {message.text}
                  </Box>
                ))}
              </Section>
            </Box>
          </>
        );
      }

      case 'universal translator':
        return (
          <>
            <Box>
              When enabled, this device automatically converts spoken and
              written language into a format any known recipient can understand.
            </Box>
            <Box mt={1}>
              The device is currently{' '}
              <b>{toggles.translator ? 'enabled' : 'disabled'}</b>.
            </Box>
            <ToggleButton
              toggle="translator"
              enabled={toggles.translator}
              enabledLabel="Disable"
              disabledLabel="Enable"
            />
          </>
        );

      case 'atmosphere sensor': {
        const atmo = data.atmo;
        if (!atmo) {
          return null;
        }
        if (atmo.error) {
          return <NoticeBox>{atmo.error}</NoticeBox>;
        }
        return (
          <>
            <LabeledList>
              <LabeledList.Item label="Pressure">
                {atmo.pressure} kPa
              </LabeledList.Item>
              <LabeledList.Item label="Temperature">
                {atmo.temperature} &deg;C
              </LabeledList.Item>
              {(atmo.gases || []).map((gas) => (
                <LabeledList.Item key={gas.name} label={gas.name}>
                  {gas.percent}%
                </LabeledList.Item>
              ))}
            </LabeledList>
            <Box mt={1}>
              <Button onClick={() => act('refresh')}>Refresh Reading</Button>
            </Box>
          </>
        );
      }

      case 'wirejack': {
        const wirejack = data.wirejack || {};
        return (
          <>
            <LabeledList>
              <LabeledList.Item label="Target Machine">
                {wirejack.target || 'None'}
              </LabeledList.Item>
              <LabeledList.Item label="Progress">
                {wirejack.progress || 0}% complete
              </LabeledList.Item>
            </LabeledList>
            {!!wirejack.target && (
              <Box mt={1}>
                <Button onClick={() => act('wirejack_cancel')}>Cancel</Button>
              </Box>
            )}
          </>
        );
      }

      case 'chem synth': {
        const charge = data.charge || 0;
        if (charge > 0) {
          return (
            <>
              <ProgressBar value={(charge * 100) / 15} maxValue={100} />
              <Box mt={1}>Charging... {charge}u ready.</Box>
            </>
          );
        }
        return (
          <LabeledList>
            {(data.chems || []).map((entry) => (
              <LabeledList.Item key={entry.id} label={entry.name}>
                <Button onClick={() => act('chem', { chem: entry.id })}>
                  Synthesize
                </Button>
              </LabeledList.Item>
            ))}
          </LabeledList>
        );
      }

      case 'food synth': {
        const charge = data.charge || 0;
        if (charge > 0) {
          return (
            <>
              <ProgressBar value={(charge * 100) / 15} maxValue={100} />
              <Box mt={1}>
                Charging... {Math.round((charge * 100) / 15)}% ready.
              </Box>
            </>
          );
        }
        return (
          <LabeledList>
            {(data.foods || []).map((entry) => (
              <LabeledList.Item key={entry.path} label={entry.name}>
                <Button onClick={() => act('food', { food: entry.path })}>
                  Synthesize
                </Button>
              </LabeledList.Item>
            ))}
          </LabeledList>
        );
      }

      case 'remote signaller':
        return (
          <>
            <LabeledList>
              <LabeledList.Item label="Frequency">
                {signal.frequency}
              </LabeledList.Item>
              <LabeledList.Item label="Code">{signal.code}</LabeledList.Item>
            </LabeledList>
            <Box mt={1}>
              <Button onClick={() => act('signal', { freq: -10 })}>-10</Button>
              <Button onClick={() => act('signal', { freq: -2 })}>-2</Button>
              <Button onClick={() => act('signal', { freq: 2 })}>+2</Button>
              <Button onClick={() => act('signal', { freq: 10 })}>+10</Button>
            </Box>
            <Box mt={1}>
              <Button onClick={() => act('signal', { code: -5 })}>-5</Button>
              <Button onClick={() => act('signal', { code: -1 })}>-1</Button>
              <Button onClick={() => act('signal', { code: 1 })}>+1</Button>
              <Button onClick={() => act('signal', { code: 5 })}>+5</Button>
            </Box>
            <Box mt={1}>
              <Button onClick={() => act('signal', { send: 1 })}>
                Send Signal
              </Button>
            </Box>
          </>
        );

      case 'redundant threading':
        return (
          <Box>
            Redundant threads are active. Redundant threading prevents critical
            failure of all systems due to exposure to electromagnetics, and
            provides additional protection for core directives and comms.
          </Box>
        );

      case 'flashlight':
        return (
          <>
            <Box>
              Backlight enhancement by increased local thermal generation.
            </Box>
            <Box mt={1}>
              Lighting is <b>{toggles.light ? 'enabled' : 'disabled'}</b>.
            </Box>
            <ToggleButton
              toggle="light"
              enabled={toggles.light}
              enabledLabel="Disable Light"
              disabledLabel="Enable Light"
            />
          </>
        );

      case 'holomap viewer':
        return (
          <>
            <Box>Creates a virtual map of the surrounding area.</Box>
            <Box mt={1}>
              <LabeledList>
                <LabeledList.Item label="Current mode">
                  {data.holomap?.mode || 'Internal Viewer'}
                </LabeledList.Item>
              </LabeledList>
            </Box>
            <Box mt={1}>
              <Button onClick={() => act('holomap', { switch_target: 1 })}>
                Switch Type
              </Button>
            </Box>
            <Box mt={1}>
              <Button onClick={() => act('holomap', { toggle: 1 })}>
                Toggle Holomap
              </Button>
            </Box>
          </>
        );

      case 'volume enhancer':
        return (
          <>
            <Box>Volume increase via targeted speaker overvoltage.</Box>
            <Box mt={1}>
              Volume enhancement is{' '}
              <b>{toggles.volume ? 'enabled' : 'disabled'}</b>.
            </Box>
            <ToggleButton
              toggle="volume"
              enabled={toggles.volume}
              enabledLabel="Disable Megaphone"
              disabledLabel="Enable Megaphone"
            />
          </>
        );

      case 'meson augmentation':
        return (
          <>
            <Box>
              Low-intensity p-ray emitter for high resolution area mapping.
            </Box>
            <Box mt={1}>
              Meson firmware is <b>{toggles.mesons ? 'enabled' : 'disabled'}</b>
              .
            </Box>
            <ToggleButton
              toggle="mesons"
              enabled={toggles.mesons}
              enabledLabel="Disable Mesons"
              disabledLabel="Enable Mesons"
            />
          </>
        );

      default:
        return <NoticeBox>Unknown module screen.</NoticeBox>;
    }
  };

  return (
    <Window
      title={`pAI OS - ${data.name}`}
      theme="retro_green"
      width={780}
      height={560}
    >
      <Window.Content className="paios">
        <Stack fill>
          <Stack.Item width="238px">
            <Section fill scrollable className="paios-nav" title="NT pAI-OS">
              <Box className="paios-statusline">
                <Box>
                  <span className="paios-prompt">❯</span> {data.name}
                </Box>
                <Box className="paios-meter">
                  <span>RAM</span>
                  <ProgressBar value={ram} maxValue={100} />
                  <span>{ram}/100</span>
                </Box>
                {!!data.carrier && (
                  <Box className="paios-meter">
                    <span>CARRIER</span>
                    <span className="paios-meter__value">{data.carrier}</span>
                  </Box>
                )}
              </Box>

              <NavCategory label="System" />
              <ActionButton action="refresh" label="Refresh" />
              <ScreenButton
                current={screen}
                screen="directives"
                label="Directives"
              />
              <ActionButton action="radio" label="Radio Configuration" />
              <ActionButton action="image" label="Screen Display" />

              <NavCategory label="Basic" />
              {has('crew manifest') && (
                <ScreenButton
                  current={screen}
                  screen="crew manifest"
                  label="Crew Manifest"
                />
              )}
              {has('digital messenger') && (
                <ScreenButton
                  current={screen}
                  screen="digital messenger"
                  label="Digital Messenger"
                />
              )}
              {has('newscaster') && (
                <ActionButton action="newscaster" label="Newscaster" />
              )}
              {has('remote signaller') && (
                <ScreenButton
                  current={screen}
                  screen="remote signaller"
                  label="Remote Signaller"
                />
              )}
              {has('atmosphere sensor') && (
                <ScreenButton
                  current={screen}
                  screen="atmosphere sensor"
                  label="Atmospheric Sensor"
                />
              )}
              {has('flashlight') && (
                <ScreenButton
                  current={screen}
                  screen="flashlight"
                  label="Brightness Enhancer"
                />
              )}
              {has('redundant threading') && (
                <ScreenButton
                  current={screen}
                  screen="redundant threading"
                  label="Redundant Threading"
                />
              )}
              {has('volume enhancer') && (
                <ScreenButton
                  current={screen}
                  screen="volume enhancer"
                  label="Volume Enhancer"
                />
              )}

              <NavCategory label="Standard" />
              {has('medical supplement') && (
                <ScreenButton
                  current={screen}
                  screen="medical supplement"
                  label="Medical Package"
                />
              )}
              {has('security supplement') && (
                <ScreenButton
                  current={screen}
                  screen="security supplement"
                  label="Security Package"
                />
              )}
              {has('wirejack') && (
                <ScreenButton
                  current={screen}
                  screen="wirejack"
                  label="Wirejack"
                />
              )}
              {has('universal translator') && (
                <ScreenButton
                  current={screen}
                  screen="universal translator"
                  label="Universal Translator"
                />
              )}
              {has('chem synth') && (
                <ScreenButton
                  current={screen}
                  screen="chem synth"
                  label="Chemical Synth"
                />
              )}
              {has('food synth') && (
                <ScreenButton
                  current={screen}
                  screen="food synth"
                  label="Nutrition Synth"
                />
              )}

              <NavCategory label="Navigation" />
              {has('pai positioning system') && (
                <ActionButton
                  action="open_device"
                  params={{ device: 'gps' }}
                  label="GPS Uplink"
                />
              )}
              {has('pai expedition tracker') && (
                <ActionButton
                  action="open_device"
                  params={{ device: 'xps' }}
                  label="Expedition Tracker"
                />
              )}
              {has('holomap viewer') && (
                <ScreenButton
                  current={screen}
                  screen="holomap viewer"
                  label="Holomap Viewer"
                />
              )}
              {has('meson augmentation') && (
                <ScreenButton
                  current={screen}
                  screen="meson augmentation"
                  label="Mesons Augmentation"
                />
              )}

              <NavCategory label="Software" />
              <Button
                fluid
                className="paios-nav__item"
                onClick={() => act('screen', { screen: 'buy' })}
              >
                <span className="paios-cursor"> </span>
                Download software
              </Button>
              <Button
                fluid
                className="paios-nav__item"
                onClick={() => act('screen', { screen: 'uninstall' })}
              >
                <span className="paios-cursor"> </span>
                Uninstall software
              </Button>

              <Box className="paios-footer">NANOTRASEN pAI-OS v2.1</Box>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              className="paios-panel"
              title={`❯ ${SCREEN_TITLES[screen] || 'pAI OS'}`}
            >
              {!!data.temp && <NoticeBox>{data.temp}</NoticeBox>}
              {renderContent()}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
