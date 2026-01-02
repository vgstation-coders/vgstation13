// Copyright (c) 2022 /vg/station coders
// SPDX-License-Identifier: MIT

import { Box, Button, Divider, Dropdown, Flex, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  currentZLevel: number;
  zLevels: number[];
  holomapEnabled: boolean;
  holomapAvailable: boolean;
  autoUpdate: boolean;
  detectedCrew: Crewmember[];
  detected: boolean;
  currentTheme: string;
  availableThemes: string[];
};

type Crewmember = {
  name: string;
  job: string;
  vitals: number;
  damage: Damage | null;
  area: string;
  role: string;
  icon: string;
  see_x: number | null;
  see_y: number | null;
  count: number;
};

type Damage = {
  oxygen: number;
  toxin: number;
  fire: number;
  brute: number;
};

const getRoleColor = (role: string): string => {
  switch (role) {
    case 'cap':
      return '#1b67a5';
    case 'sec':
      return '#9d2929';
    case 'med':
      return '#337296';
    case 'sci':
      return '#a65ba6';
    case 'eng':
      return '#a68b29';
    case 'car':
      return '#7a5229';
    case 'silicon':
      return '#4c4c4c';
    case 'cent':
      return '#1b4a1b';
    default:
      return '#555555';
  }
};

const getVitalsText = (vitals: number): { text: string; color: string } => {
  switch (vitals) {
    case 0:
      return { text: 'Alive', color: 'good' };
    case 1:
      return { text: 'Critical', color: 'bad' };
    case 2:
      return { text: 'DEAD', color: 'bad' };
    default:
      return { text: 'Unknown', color: 'label' };
  }
};

export const CrewMonitor = () => {
  const { act, data } = useBackend<Data>();
  const {
    currentZLevel,
    zLevels,
    holomapEnabled,
    holomapAvailable,
    autoUpdate,
    detectedCrew,
    detected,
  } = data;

  return (
    <Window title="Crew Monitoring Computer" width={900} height={600}>
      <Window.Content scrollable>
        <Section title="Settings">
          <Flex justify="space-between" align="center">
            <Flex.Item>
              <Button.Checkbox
                checked={autoUpdate}
                onClick={() => act('toggle_update')}>
                Auto-update
              </Button.Checkbox>
              <Button
                icon={holomapEnabled ? 'map-marked-alt' : 'map'}
                selected={holomapEnabled}
                disabled={!holomapAvailable}
                tooltip={!holomapAvailable ? 'Holomap not available' : undefined}
                onClick={() => act('toggle_holomap')}>
                {holomapEnabled ? 'Hide Holomap' : 'Show Holomap'}
              </Button>
            </Flex.Item>
            <Flex.Item>
              <Box inline mr={1}>
                Z-Level:
              </Box>
              <Dropdown
                width="100px"
                options={zLevels.map((z) => String(z))}
                selected={String(currentZLevel)}
                onSelected={(value) => act('set_zlevel', { zlevel: Number(value) })}
              />
            </Flex.Item>
          </Flex>
        </Section>

        <Section title="Suit Sensor Signals">
          <Table>
            <Table.Row>
              <Table.Cell bold>Name</Table.Cell>
              <Table.Cell bold>Occupation</Table.Cell>
              <Table.Cell bold>Vitals</Table.Cell>
              <Table.Cell bold>Status</Table.Cell>
              <Table.Cell bold>Location</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <Box color="#4972A1">
                  <Divider />
                </Box>
              </Table.Cell>
              <Table.Cell>
                <Box color="#4972A1">
                  <Divider />
                </Box>
              </Table.Cell>
              <Table.Cell>
                <Box color="#4972A1">
                  <Divider />
                </Box>
              </Table.Cell>
              <Table.Cell>
                <Box color="#4972A1">
                  <Divider />
                </Box>
              </Table.Cell>
              <Table.Cell>
                <Box color="#4972A1">
                  <Divider />
                </Box>
              </Table.Cell>
            </Table.Row>
            {detectedCrew.map((crew) => {
              const vitalsInfo = getVitalsText(crew.vitals);
              const roleColor = getRoleColor(crew.role);
              return (
                <Table.Row
                  key={crew.count}
                  backgroundColor={
                    crew.count % 2 ? 'rgba(17,17,17,0.6)' : 'rgba(33,33,33,0.6)'
                  }>
                  <Table.Cell bold>
                    <Box
                      inline
                      style={{
                        borderLeft: `3px solid ${roleColor}`,
                        paddingLeft: '5px',
                      }}>
                      {crew.name}
                    </Box>
                  </Table.Cell>
                  <Table.Cell>{crew.job}</Table.Cell>
                  <Table.Cell bold>
                    <Box color={vitalsInfo.color}>{vitalsInfo.text}</Box>
                  </Table.Cell>
                  <Table.Cell>
                    {crew.damage ? (
                      <Box>
                        (
                        <Box as="span" bold color="#FF0000">
                          {crew.damage.brute}
                        </Box>
                        /
                        <Box as="span" bold color="#FFA500">
                          {crew.damage.fire}
                        </Box>
                        /
                        <Box as="span" bold color="#00FF00">
                          {crew.damage.toxin}
                        </Box>
                        /
                        <Box as="span" bold color="#3399CC">
                          {crew.damage.oxygen}
                        </Box>
                        )
                      </Box>
                    ) : (
                      <Box color="label">N/A</Box>
                    )}
                  </Table.Cell>
                  <Table.Cell>
                    {crew.area ? (
                      <Box>
                        {crew.area}
                        {crew.see_x !== null &&
                          crew.see_y !== null &&
                          ` (${crew.see_x}, ${crew.see_y})`}
                      </Box>
                    ) : (
                      <Box color="label">Unknown</Box>
                    )}
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
          {!detected && (
            <Flex align="center" justify="center" mt={2}>
              <Box color="label">No detected suit sensors on this Z-level.</Box>
            </Flex>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
