import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  Flex,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Destination = {
  ref: string;
  name: string;
  in_use: number;
  kind: 'shuttle' | 'all' | 'disk' | 'procedural';
  procgen_key?: string;
  category: string;
};

const CATEGORY_ORDER = ['Space', 'Planets', 'Parking', 'Restricted', 'Transit', 'Other'];

type FreemoveCoords = {
  x: number;
  y: number;
  z: number;
  rot: number;
};

type DiskData = {
  present: number;
  header: string;
  kind: 'standard' | 'freemove' | 'procedural' | 'none';
  destination_name: string | null;
  compatible: number;
  freemove: FreemoveCoords | null;
  procedural: { name: string; kind: 'planet' | 'encounter' } | null;
  procedural_error: number;
};

type AdminData = {
  visible: number;
  allow_selecting_all: number;
  allow_silicons: number;
};

type Progress = {
  phase: 'ready' | 'warmup' | 'transit' | 'cooldown' | 'lockdown' | 'unlinked' | 'no_shuttle';
  label: string;
  value: number;
  remaining_s: number | null;
};

type Data = {
  shuttle_name: string | null;
  no_shuttle: number;
  status: Progress['phase'];
  lockdown: { active: number; reason: string | null };
  in_transit: { active: number; dest_name: string | null };
  progress: Progress;
  destinations: Destination[];
  selected_ref: string | null;
  procgen_selected: string | null;
  disk: DiskData;
  admin: AdminData;
  theme: string;
  themes: string[];
  can_change_theme: number;
};

export const ShuttleControl = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    shuttle_name,
    no_shuttle,
    status,
    destinations,
    selected_ref,
    procgen_selected,
    progress,
    disk,
    admin,
    theme,
    themes,
    can_change_theme,
  } = data;

  return (
    <Window title={shuttle_name || 'Shuttle Control'} width={480} height={520} theme={theme}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <StatusBar progress={progress} />
          </Stack.Item>

          {!!no_shuttle && (
            <Stack.Item grow>
              <Section fill>
                <Box color="label" mb={1}>No shuttle linked.</Box>
                <Button onClick={() => act('link_shuttle')}>
                  Link to a Shuttle
                </Button>
                {!!admin.visible && (
                  <Button ml={1} onClick={() => act('link_shuttle_admin')}>
                    Admin Link
                  </Button>
                )}
              </Section>
            </Stack.Item>
          )}

          {!no_shuttle && status === 'lockdown' && (
            <Stack.Item grow>
              <Section fill title="Lockdown">
                <Box color="bad" bold mb={1}>This shuttle is locked down.</Box>
                {!!data.lockdown.reason && (
                  <Box color="label">{data.lockdown.reason}</Box>
                )}
              </Section>
            </Stack.Item>
          )}

          {!no_shuttle && status === 'unlinked' && (
            <Stack.Item grow>
              <Section fill>
                <Box color="bad" bold>
                  Unable to find {shuttle_name || 'shuttle'}.
                </Box>
                <Box color="label" mt={1}>
                  The linked shuttle has no associated area.
                </Box>
              </Section>
            </Stack.Item>
          )}

          {!no_shuttle && status !== 'lockdown' && status !== 'unlinked' && (
            <>
              <Stack.Item grow>
                <Section
                  fill
                  scrollable
                  title="Destinations"
                  buttons={
                    <>
                      {!!can_change_theme && themes && themes.length > 0 && (
                        <Box inline mr={0.5} style={{ verticalAlign: 'middle' }}>
                          <Dropdown
                            width="130px"
                            options={themes}
                            selected={theme}
                            onSelected={(value) => act('set_theme', { theme: value })}
                          />
                        </Box>
                      )}
                      <Button
                        icon="satellite-dish"
                        onClick={() => act('scan')}
                      >
                        Scan
                      </Button>
                    </>
                  }
                >
                  <DestinationGrid
                    destinations={destinations}
                    selectedRef={selected_ref}
                    procgenSelected={procgen_selected}
                    act={act}
                  />
                </Section>
              </Stack.Item>

              {!!disk.present && disk.kind === 'freemove' && (
                <Stack.Item>
                  <FreemoveSection disk={disk} act={act} />
                </Stack.Item>
              )}

              {!!disk.present && (
                <Stack.Item>
                  <Button
                    fluid
                    icon="eject"
                    onClick={() => act('eject_disk')}
                  >
                    Eject Disk: {disk.header}
                  </Button>
                </Stack.Item>
              )}

              {!!admin.visible && (
                <Stack.Item>
                  <Collapsible title="Admin Controls" color="bad">
                    <AdminPanel admin={admin} act={act} />
                  </Collapsible>
                </Stack.Item>
              )}

              <Stack.Item>
                <SendButton data={data} act={act} />
              </Stack.Item>
            </>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const StatusBar = (props: { progress: Progress }) => {
  const { progress } = props;
  const { phase, label, value, remaining_s } = progress;

  let barColor: string | undefined = 'good';
  if (phase === 'warmup') barColor = 'average';
  else if (phase === 'transit') barColor = 'average';
  else if (phase === 'cooldown') barColor = 'average';
  else if (phase === 'lockdown') barColor = 'bad';
  else if (phase === 'no_shuttle' || phase === 'unlinked') barColor = 'bad';
  else if (phase === 'ready') barColor = 'good';

  const showBar = phase === 'warmup' || phase === 'transit' || phase === 'cooldown';

  return (
    <Section>
      <Flex align="center" justify="space-between" mb={showBar ? 0.5 : 0}>
        <Flex.Item>
          <Box bold color={barColor}>{label}</Box>
        </Flex.Item>
        {remaining_s !== null && remaining_s > 0 && (
          <Flex.Item>
            <Box color="label">{remaining_s}s</Box>
          </Flex.Item>
        )}
      </Flex>
      {showBar && (
        <ProgressBar
          value={value}
          minValue={0}
          maxValue={1}
          color={barColor}
        />
      )}
    </Section>
  );
};

const DestinationGrid = (props: {
  destinations: Destination[];
  selectedRef: string | null;
  procgenSelected: string | null;
  act: (action: string, params?: object) => void;
}) => {
  const { destinations, selectedRef, procgenSelected, act } = props;
  if (!destinations.length) {
    return <Box color="label">No destinations available.</Box>;
  }

  const grouped: Record<string, Destination[]> = {};
  for (const d of destinations) {
    const cat = d.category || 'Other';
    if (!grouped[cat]) grouped[cat] = [];
    grouped[cat].push(d);
  }
  const knownOrder = CATEGORY_ORDER.filter((c) => grouped[c]);
  const extra = Object.keys(grouped)
    .filter((c) => !CATEGORY_ORDER.includes(c))
    .sort();
  const categories = [...knownOrder, ...extra];

  return (
    <>
      {categories.map((cat, idx) => (
        <Box key={cat} mt={idx === 0 ? 0 : 0.75}>
          <Box color="label" fontSize="0.85em" mb={0.25}>
            {cat}
          </Box>
          <Flex wrap="wrap">
            {grouped[cat].map((d) => {
              const isSelected =
                d.kind === 'procedural'
                  ? !!procgenSelected && procgenSelected === d.procgen_key
                  : selectedRef === d.ref;
              return (
                <Flex.Item key={d.ref + d.name} basis="50%" p={0.3}>
                  <Button
                    fluid
                    disabled={!!d.in_use}
                    selected={isSelected}
                    tooltip={d.in_use ? 'In use' : undefined}
                    onClick={() => {
                      if (d.kind === 'procedural') {
                        act('select_procedural');
                      } else {
                        act('select', { ref: d.ref });
                      }
                    }}
                  >
                    {d.name}
                    {!!d.in_use && (
                      <Box as="span" ml={1} color="bad" fontSize="0.8em">
                        IN USE
                      </Box>
                    )}
                    {d.kind === 'disk' && (
                      <Box as="span" ml={1} color="label" fontSize="0.8em">
                        DISK
                      </Box>
                    )}
                  </Button>
                </Flex.Item>
              );
            })}
          </Flex>
        </Box>
      ))}
    </>
  );
};

const FreemoveSection = (props: {
  disk: DiskData;
  act: (action: string, params?: object) => void;
}) => {
  const { disk, act } = props;
  const fm = disk.freemove || { x: 0, y: 0, z: 0, rot: 0 };
  return (
    <Section title="Course Plotting">
      <LabeledList>
        <LabeledList.Item label="X Offset">
          <NumberInput
            value={fm.x}
            step={1}
            minValue={-500}
            maxValue={500}
            onChange={(v) => act('set_coord', { axis: 'x', value: v })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Y Offset">
          <NumberInput
            value={fm.y}
            step={1}
            minValue={-500}
            maxValue={500}
            onChange={(v) => act('set_coord', { axis: 'y', value: v })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Z">
          <NumberInput
            value={fm.z}
            step={1}
            minValue={1}
            maxValue={20}
            onChange={(v) => act('set_coord', { axis: 'z', value: v })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Rotation">
          <NumberInput
            value={fm.rot}
            step={90}
            minValue={0}
            maxValue={270}
            onChange={(v) => act('set_coord', { axis: 'a', value: v })}
          />
        </LabeledList.Item>
      </LabeledList>
      <Box mt={1}>
        <Button icon="calculator" onClick={() => act('calculate_course')}>
          Calculate Course
        </Button>
      </Box>
    </Section>
  );
};

const SendButton = (props: {
  data: Data;
  act: (action: string, params?: object) => void;
}) => {
  const { data, act } = props;
  const { status, selected_ref, procgen_selected, progress, destinations } = data;

  let label = 'Select a Destination';
  let disabled = true;

  if (status === 'cooldown' || status === 'warmup' || status === 'transit') {
    label = progress.label;
    disabled = true;
  } else if (procgen_selected) {
    const procRow = destinations.find((d) => d.procgen_key === procgen_selected);
    label = `Send to ${procRow ? procRow.name : procgen_selected}`;
    disabled = false;
  } else if (selected_ref) {
    const match = destinations.find((d) => d.ref === selected_ref);
    if (match) {
      label = `Send to ${match.name}`;
      disabled = false;
    }
  }

  return (
    <Button
      fluid
      color={disabled ? undefined : 'good'}
      disabled={disabled}
      textAlign="center"
      onClick={() => act('send')}
    >
      <Box bold py={0.5}>{label}</Box>
    </Button>
  );
};

const AdminPanel = (props: {
  admin: AdminData;
  act: (action: string, params?: object) => void;
}) => {
  const { admin, act } = props;
  return (
    <Stack vertical>
      <Stack.Item>
        <Button fluid onClick={() => act('link_shuttle_admin')}>
          Link to Shuttle
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button fluid onClick={() => act('unlink_shuttle_admin')}>
          Unlink Shuttle
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button fluid onClick={() => act('toggle_lockdown')}>
          Toggle Lockdown
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button.Checkbox
          fluid
          checked={!!admin.allow_selecting_all}
          onClick={() => act('toggle_select_all')}
        >
          Select From All Ports
        </Button.Checkbox>
      </Stack.Item>
      <Stack.Item>
        <Button.Checkbox
          fluid
          checked={!!admin.allow_silicons}
          onClick={() => act('toggle_silicons')}
        >
          Allow Silicons
        </Button.Checkbox>
      </Stack.Item>
      <Stack.Item>
        <Button fluid color="bad" onClick={() => act('reset_shuttle')}>
          Reset Shuttle
        </Button>
      </Stack.Item>
    </Stack>
  );
};
