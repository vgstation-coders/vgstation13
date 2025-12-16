// Copyright (c) 2024 /vg/station coders
// SPDX-License-Identifier: MIT

import {
  Box,
  Button,
  Collapsible,
  Divider,
  Flex,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ExtractorData = {
  ref: string;
  name: string;
  location: string;
  active: boolean;
  extracting: boolean;
  deployed: boolean;
  state: number;
  state_text: string;
  stability: number;
  stability_critical: boolean;
  gas_type: string;
  vent_reserves: number;
  vent_reserves_percent: number;
  extraction_rate: number;
};

type GasRate = {
  name: string;
  id: string;
  rate: number;
};

type Data = {
  linked: boolean;
  broken: boolean;
  miner_on: boolean;
  miner_power: number;
  miner_base_power: number;
  gas_rates: GasRate[];
  total_rate: number;
  extractors: ExtractorData[];
};

// State constants matching DM defines
const STATE_UNDEPLOYED = 0;
const STATE_DEPLOYING = 1;
const STATE_WARMUP = 2;
const STATE_EXTRACTING = 3;
const STATE_BROKEN = 4;

export const GasExtractorConsole = () => {
  const { act, data } = useBackend<Data>();
  const {
    linked,
    broken,
    miner_on,
    miner_power,
    miner_base_power,
    gas_rates = [],
    total_rate,
    extractors = [],
  } = data;

  return (
    <Window width={700} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          {/* Error States */}
          {broken ? (
            <Stack.Item>
              <NoticeBox danger>Console is non-functional</NoticeBox>
            </Stack.Item>
          ) : null}

          {!linked && !broken ? (
            <Stack.Item>
              <NoticeBox warning>
                Not linked to a surface gas receiver
              </NoticeBox>
            </Stack.Item>
          ) : null}

          {/* Miner Control Section */}
          {linked && !broken ? (
            <>
              <Stack.Item>
                <Section
                  title="Surface Gas Receiver Control"
                  buttons={
                    <Button
                      icon={miner_on ? 'power-off' : 'power-off'}
                      color={miner_on ? 'good' : 'bad'}
                      onClick={() => act('toggle_miner')}
                    >
                      {miner_on ? 'Online' : 'Offline'}
                    </Button>
                  }
                >
                  <LabeledList>
                    <LabeledList.Item label="Status">
                      <Box color={miner_on ? 'good' : 'bad'} bold>
                        {miner_on ? 'OPERATIONAL' : 'OFFLINE'}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Power Draw">
                      <Flex align="center">
                        <Flex.Item grow={1}>
                          <NumberInput
                            value={miner_power}
                            minValue={miner_base_power}
                            maxValue={50000}
                            step={100}
                            stepPixelSize={5}
                            width="120px"
                            onChange={(value) =>
                              act('set_power', { power: value })
                            }
                          />
                        </Flex.Item>
                        <Flex.Item ml={1}>
                          <Box>W</Box>
                        </Flex.Item>
                      </Flex>
                    </LabeledList.Item>
                    <LabeledList.Item label="Quick Adjust">
                      <Button
                        icon="minus"
                        color="bad"
                        onClick={() => act('adjust_power', { amount: -1000 })}
                      >
                        -1kW
                      </Button>
                      <Button
                        icon="minus"
                        onClick={() => act('adjust_power', { amount: -100 })}
                      >
                        -100W
                      </Button>
                      <Button
                        icon="plus"
                        onClick={() => act('adjust_power', { amount: 100 })}
                      >
                        +100W
                      </Button>
                      <Button
                        icon="plus"
                        color="good"
                        onClick={() => act('adjust_power', { amount: 1000 })}
                      >
                        +1kW
                      </Button>
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Stack.Item>

              {/* Gas Production Rates */}
              <Stack.Item>
                <Section title="Gas Production Rates">
                  {miner_on ? (
                    <LabeledList>
                      <LabeledList.Item label="Total Output">
                        <Box color="good" bold fontSize="14px">
                          {total_rate} mol/s
                        </Box>
                      </LabeledList.Item>
                      <LabeledList.Divider />
                      {gas_rates.length > 0 ? (
                        gas_rates.map((gas) => (
                          <LabeledList.Item key={gas.id} label={gas.name}>
                            {gas.rate} mol/s
                          </LabeledList.Item>
                        ))
                      ) : (
                        <LabeledList.Item label="Status">
                          <Box color="average">No active extractors</Box>
                        </LabeledList.Item>
                      )}
                    </LabeledList>
                  ) : (
                    <Box color="bad" textAlign="center" py={1}>
                      Receiver offline - No gas production
                    </Box>
                  )}
                </Section>
              </Stack.Item>

              {/* Extractor Status */}
              <Stack.Item>
                <Section
                  title={`Linked Extractors (${extractors.length})`}
                  fill
                >
                  {extractors.length > 0 ? (
                    <Stack vertical>
                      {extractors.map((extractor) => (
                        <Stack.Item key={extractor.ref}>
                          <ExtractorPanel extractor={extractor} act={act} />
                          <Divider />
                        </Stack.Item>
                      ))}
                    </Stack>
                  ) : (
                    <Box color="average" textAlign="center" py={1}>
                      No extractors linked to the receiver
                    </Box>
                  )}
                </Section>
              </Stack.Item>
            </>
          ) : null}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ExtractorPanel = (props: { extractor: ExtractorData; act: Function }) => {
  const { extractor, act } = props;

  const getStatusColor = () => {
    if (extractor.state === STATE_BROKEN) return 'bad';
    if (extractor.stability_critical) return 'bad';
    if (extractor.extracting) return 'good';
    if (extractor.state === STATE_WARMUP) return 'average';
    return 'label';
  };

  const getReservesColor = () => {
    if (extractor.vent_reserves_percent <= 25) return 'bad';
    if (extractor.vent_reserves_percent <= 50) return 'average';
    return 'good';
  };

  return (
    <Collapsible title={extractor.name}>
      <Section>
        <Stack>
          {/* Left column - Status */}
          <Stack.Item grow={1}>
            <LabeledList>
              <LabeledList.Item label="Location">
                {extractor.location}
              </LabeledList.Item>
              <LabeledList.Item label="State">
                <Box color={getStatusColor()} bold>
                  {extractor.state_text}
                </Box>
              </LabeledList.Item>
              {extractor.gas_type !== 'None' ? (
                <LabeledList.Item label="Gas Type">
                  {extractor.gas_type}
                </LabeledList.Item>
              ) : null}
              {extractor.extracting ? (
                <LabeledList.Item label="Extraction Rate">
                  {extractor.extraction_rate} mol/s
                </LabeledList.Item>
              ) : null}
            </LabeledList>
          </Stack.Item>

          {/* Right column - Reserves & Stability */}
          <Stack.Item grow={1}>
            <Stack vertical>
              {extractor.deployed && extractor.gas_type !== 'None' ? (
                <Stack.Item>
                  <Box mb={1}>
                    <Box fontSize="11px" color="label" mb={0.5}>
                      Vent Reserves
                    </Box>
                    <ProgressBar
                      value={extractor.vent_reserves_percent}
                      minValue={0}
                      maxValue={100}
                      color={getReservesColor()}
                      ranges={{
                        bad: [0, 25],
                        average: [25, 50],
                        good: [50, Infinity],
                      }}
                    >
                      {extractor.vent_reserves_percent}%
                    </ProgressBar>
                    {extractor.vent_reserves_percent <= 25 ? (
                      <Box color="bad" fontSize="10px" mt={0.5}>
                        ⚠ Critical - Stability degrading
                      </Box>
                    ) : null}
                  </Box>
                </Stack.Item>
              ) : null}

              <Stack.Item>
                <Box>
                  <Box fontSize="11px" color="label" mb={0.5}>
                    Structural Integrity
                  </Box>
                  <ProgressBar
                    value={extractor.stability}
                    minValue={0}
                    maxValue={100}
                    color={
                      extractor.stability <= 25
                        ? 'bad'
                        : extractor.stability <= 50
                          ? 'average'
                          : 'good'
                    }
                    ranges={{
                      bad: [0, 25],
                      average: [25, 50],
                      good: [50, Infinity],
                    }}
                  >
                    {extractor.stability}%
                  </ProgressBar>
                  {extractor.stability_critical ? (
                    <Box color="bad" bold fontSize="10px" mt={0.5}>
                      ⚠ CRITICAL - FAILURE IMMINENT
                    </Box>
                  ) : null}
                </Box>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>

        {/* Control Button */}
        <Box mt={1} textAlign="center">
          {!extractor.deployed ? (
            <Button
              icon="play"
              color="good"
              disabled={extractor.state !== STATE_UNDEPLOYED}
              onClick={() => act('toggle_extractor', { ref: extractor.ref })}
            >
              Deploy & Start
            </Button>
          ) : (
            <Button
              icon="stop"
              color="bad"
              disabled={
                extractor.state !== STATE_WARMUP &&
                extractor.state !== STATE_EXTRACTING
              }
              onClick={() => act('toggle_extractor', { ref: extractor.ref })}
            >
              Shutdown
            </Button>
          )}
        </Box>
      </Section>
    </Collapsible>
  );
};
