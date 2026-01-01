import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Icon,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  zLevels: ZLevel[];
};

type ZLevel = {
  index: number;
  name: string;
  ref: string;
  vLevelCount: number;
  vLevels: VLevel[];
};

type VLevel = {
  id: number;
  name: string;
  ref: string;
  active: boolean;
  sizeX: number;
  sizeY: number;
  players: number;
  processingMobs: number;
  pausedMobs: number;
  planetRef?: string;
  planetName?: string;
  shuttleRef?: string;
  shuttleName?: string;
};

export const LevelManager = () => {
  const { act, data } = useBackend<Data>();
  const { zLevels = [] } = data;

  const totalVLevels = zLevels.reduce((sum, z) => sum + z.vLevelCount, 0);

  return (
    <Window title="Level Manager" width={550} height={500}>
      <Window.Content scrollable>
        <Section
          title={`${zLevels.length} Z-Level${zLevels.length !== 1 ? 's' : ''} | ${totalVLevels} Virtual Z-Level${totalVLevels !== 1 ? 's' : ''}`}
          buttons={
            <>
              <Button
                icon="plus"
                content="New Z-Level"
                onClick={() => act('create_zlevel')}
              />
              <Button
                icon="plus"
                content="New vLevel"
                onClick={() => act('create_vlevel')}
              />
            </>
          }
        >
          <Stack vertical fill>
            {zLevels.map((zLevel) => (
              <Stack.Item key={zLevel.index}>
                <ZLevelEntry zLevel={zLevel} />
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const ZLevelEntry = (props: { zLevel: ZLevel }) => {
  const { act } = useBackend<Data>();
  const { zLevel } = props;
  const [open, setOpen] = useState(false);

  return (
    <Collapsible
      open={open}
      title={
        <Box inline>
          <Box inline bold>
            Z-Level {zLevel.index}: {zLevel.name}
          </Box>
          <Box inline color="label" ml={1}>
            ({zLevel.vLevelCount} vLevel{zLevel.vLevelCount !== 1 ? 's' : ''})
          </Box>
        </Box>
      }
      buttons={
        <Button
          icon="search"
          tooltip="View Variables"
          onClick={() => act('vv_zlevel', { ref: zLevel.ref })}
        />
      }
      onToggle={() => setOpen(!open)}
    >
      {zLevel.vLevels.length === 0 ? (
        <Box color="average" italic p={1}>
          No virtual z-levels on this z-level.
        </Box>
      ) : (
        <Stack vertical>
          {zLevel.vLevels.map((vLevel) => (
            <Stack.Item key={vLevel.id}>
              <VLevelEntry vLevel={vLevel} />
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Collapsible>
  );
};

const VLevelEntry = (props: { vLevel: VLevel }) => {
  const { act } = useBackend<Data>();
  const { vLevel } = props;

  const isBaseLevel = vLevel.id <= 6;

  return (
    <Section
      title={
        <Box inline>
          <Icon
            name={vLevel.active ? 'play' : 'pause'}
            color={vLevel.active ? 'good' : 'average'}
            mr={1}
          />
          vZ-{vLevel.id}: {vLevel.name}
        </Box>
      }
      buttons={
        <>
          <Button
            icon={vLevel.active ? 'pause' : 'play'}
            color={vLevel.active ? 'average' : 'good'}
            tooltip={
              isBaseLevel
                ? 'Base levels cannot be paused'
                : vLevel.active
                  ? 'Pause'
                  : 'Activate'
            }
            disabled={isBaseLevel}
            onClick={() => act('toggle_pause', { ref: vLevel.ref })}
          />
          <Button
            icon="arrow-right"
            tooltip="Jump To"
            onClick={() => act('jump', { ref: vLevel.ref })}
          />
          {vLevel.planetRef && (
            <Button
              icon="globe"
              tooltip={`View Planet: ${vLevel.planetName}`}
              onClick={() => act('vv_planet', { ref: vLevel.ref })}
            />
          )}
          {vLevel.shuttleRef && (
            <Button
              icon="space-shuttle"
              tooltip={`View Shuttle: ${vLevel.shuttleName}`}
              onClick={() => act('vv_shuttle', { ref: vLevel.ref })}
            />
          )}
          <Button
            icon="search"
            tooltip="View Variables"
            onClick={() => act('vv_vlevel', { ref: vLevel.ref })}
          />
        </>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Status">
          <Box inline color={vLevel.active ? 'good' : 'average'} bold>
            {vLevel.active ? 'Active' : 'Paused'}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Dimensions">
          {vLevel.sizeX} x {vLevel.sizeY}
        </LabeledList.Item>
        <LabeledList.Item label="Players">
          <Box inline color={vLevel.players > 0 ? 'good' : 'label'}>
            {vLevel.players}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Processing Mobs">
          <Box inline color={vLevel.processingMobs > 0 ? 'default' : 'label'}>
            {vLevel.processingMobs}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Paused Mobs">
          <Box inline color={vLevel.pausedMobs > 0 ? 'average' : 'label'}>
            {vLevel.pausedMobs}
          </Box>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
