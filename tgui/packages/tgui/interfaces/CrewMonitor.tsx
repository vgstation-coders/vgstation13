// Copyright (c) 2025 /vg/station coders
// SPDX-License-Identifier: MIT

import { useState } from 'react';
import { Box, Button, Divider, Dropdown, Flex, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ZLevel = {
  id: number;
  name: string;
  hasHolomap: boolean;
};

type Data = {
  currentZLevel: number;
  zLevels: ZLevel[];
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
  see_z: number | null;
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

// Role priority for sorting (lower = higher priority)
const getRolePriority = (role: string): number => {
  switch (role) {
    case 'cap': return 0;
    case 'sec': return 1;
    case 'med': return 2;
    case 'sci': return 3;
    case 'eng': return 4;
    case 'car': return 5;
    case 'silicon': return 6;
    case 'cent': return 7;
    default: return 8;
  }
};

// Get total damage for health sorting
const getTotalDamage = (crew: Crewmember): number => {
  if (!crew.damage) return 0;
  return crew.damage.brute + crew.damage.fire + crew.damage.toxin + crew.damage.oxygen;
};

type SortOption = 'name' | 'job' | 'health';
type SortDirection = 'asc' | 'desc';

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

  // Sorting state
  const [sortBy, setSortBy] = useState<SortOption>('name');
  const [sortDirection, setSortDirection] = useState<SortDirection>('asc');

  // Handle sort toggle
  const handleSort = (field: SortOption) => {
    if (sortBy === field) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(field);
      setSortDirection('asc');
    }
  };

  // Get sort icon
  const getSortIcon = (field: SortOption) => {
    if (sortBy !== field) return 'sort';
    return sortDirection === 'asc' ? 'sort-up' : 'sort-down';
  };

  // Sort crew
  const processedCrew = [...detectedCrew]
    .sort((a, b) => {
      let comparison = 0;
      switch (sortBy) {
        case 'name':
          comparison = a.name.localeCompare(b.name);
          break;
        case 'job':
          comparison = getRolePriority(a.role) - getRolePriority(b.role);
          if (comparison === 0) {
            comparison = a.job.localeCompare(b.job);
          }
          break;
        case 'health':
          // Sort by vitals first (dead last), then by damage
          if (a.vitals !== b.vitals) {
            comparison = a.vitals - b.vitals;
          } else {
            comparison = getTotalDamage(b) - getTotalDamage(a); // Higher damage first
          }
          break;
      }
      return sortDirection === 'asc' ? comparison : -comparison;
    });

  // Build z-level options with "All" as first option, using IDs
  const zLevelOptions = ['All', ...zLevels.map((z) => String(z.id))];
  const selectedZLevel = currentZLevel === 0 ? 'All' : String(currentZLevel);

  // Check if current z-level has holomap available
  // "All" mode (0) does not support holomap display - must select a specific level
  const currentZLevelHasHolomap = currentZLevel === 0
    ? false
    : (zLevels.find((z) => z.id === currentZLevel)?.hasHolomap || false);

  const holomapDisabled = !holomapAvailable || !currentZLevelHasHolomap;
  const holomapTooltip = !holomapAvailable
    ? 'Holomap not available'
    : (currentZLevel === 0 ? 'Select a specific level to view holomap' : (!currentZLevelHasHolomap ? 'No holomap data for this level' : undefined));

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
                disabled={holomapDisabled}
                tooltip={holomapTooltip}
                onClick={() => act('toggle_holomap')}>
                {holomapEnabled ? 'Hide Holomap' : 'Show Holomap'}
              </Button>
            </Flex.Item>
            <Flex.Item>
              <Box inline mr={1}>
                Level:
              </Box>
              <Dropdown
                width="100px"
                options={zLevelOptions}
                selected={selectedZLevel}
                onSelected={(value) => {
                  act('set_zlevel', { zlevel: value === 'All' ? 0 : Number(value) });
                }}
              />
            </Flex.Item>
          </Flex>
        </Section>

        <Section title={`Suit Sensor Signals (${processedCrew.length})`}>
          <Table>
            <Table.Row>
              <Table.Cell bold>
                <Button
                  fluid
                  color="transparent"
                  icon={getSortIcon('name')}
                  onClick={() => handleSort('name')}>
                  Name
                </Button>
              </Table.Cell>
              <Table.Cell bold>
                <Button
                  fluid
                  color="transparent"
                  icon={getSortIcon('job')}
                  onClick={() => handleSort('job')}>
                  Occupation
                </Button>
              </Table.Cell>
              <Table.Cell bold>
                <Button
                  fluid
                  color="transparent"
                  icon={getSortIcon('health')}
                  onClick={() => handleSort('health')}>
                  Vitals
                </Button>
              </Table.Cell>
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
            {processedCrew.map((crew, index) => {
              const vitalsInfo = getVitalsText(crew.vitals);
              const roleColor = getRoleColor(crew.role);
              return (
                <Table.Row
                  key={crew.count}
                  backgroundColor={
                    index % 2 ? 'rgba(17,17,17,0.6)' : 'rgba(33,33,33,0.6)'
                  }>
                  <Table.Cell bold>
                    <Box
                      inline
                      color={roleColor}
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
                          crew.see_z !== null &&
                          ` (${crew.see_x}, ${crew.see_y}, ${crew.see_z})`}
                      </Box>
                    ) : (
                      <Box color="label">Unknown</Box>
                    )}
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
          {processedCrew.length === 0 && (
            <Flex align="center" justify="center" mt={2}>
              <Box color="label">
                No detected suit sensors.
              </Box>
            </Flex>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
