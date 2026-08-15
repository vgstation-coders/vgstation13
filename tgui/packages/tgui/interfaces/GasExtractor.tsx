// Copyright (c) 2024 /vg/station coders
// SPDX-License-Identifier: MIT

import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  // Machine state
  anchored: boolean;
  broken: boolean;
  linked: boolean;

  // Extractor state
  state: number;
  state_text: string;
  deployed: boolean;
  can_deploy: boolean;
  deploy_error: string | null;

  // Warmup
  warmup_progress: number;

  // Extraction info
  extracting: boolean;
  extraction_rate: number;
  gas_type: string | null;

  // Vent reserves
  vent_reserves: number;
  vent_reserves_percent: number;
  damage_threshold: number;

  // Stability
  stability: number;
  max_stability: number;
  stability_critical: boolean;
};

// State constants matching the DM defines
const STATE_UNDEPLOYED = 0;
const STATE_DEPLOYING = 1;
const STATE_WARMUP = 2;
const STATE_EXTRACTING = 3;

export const GasExtractor = () => {
  const { act, data } = useBackend<Data>();
  const {
    anchored,
    broken,
    linked,
    state,
    state_text,
    deployed,
    can_deploy,
    deploy_error,
    warmup_progress,
    extracting,
    extraction_rate,
    gas_type,
    vent_reserves,
    vent_reserves_percent,
    damage_threshold,
    stability,
    max_stability,
    stability_critical,
  } = data;

  // Determine status color based on state
  const getStatusColor = () => {
    if (broken) return 'bad';
    if (stability_critical) return 'bad';
    if (extracting) return 'good';
    if (state === STATE_WARMUP) return 'average';
    return 'label';
  };

  // Get progress bar color for reserves based on damage threshold
  const getReservesColor = () => {
    if (vent_reserves_percent <= damage_threshold) return 'bad';
    if (vent_reserves_percent <= damage_threshold * 1.5) return 'average';
    return 'good';
  };

  return (
    <Window width={400} height={380}>
      <Window.Content>
        <Stack fill vertical>
          {/* Error States */}
          {broken ? (
            <Stack.Item>
              <NoticeBox danger>
                CRITICAL FAILURE - Unit is non-functional
              </NoticeBox>
            </Stack.Item>
          ) : null}

          {!anchored && !broken ? (
            <Stack.Item>
              <NoticeBox>
                Unit must be anchored with a wrench before operation
              </NoticeBox>
            </Stack.Item>
          ) : null}

          {!linked && anchored && !broken ? (
            <Stack.Item>
              <NoticeBox warning>
                Not linked to a station gas receiver
              </NoticeBox>
            </Stack.Item>
          ) : null}

          {/* Status Section */}
          <Stack.Item>
            <Section title="Status">
              <LabeledList>
                <LabeledList.Item label="State">
                  <Box color={getStatusColor()} bold>
                    {state_text}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Station Link">
                  <Box color={linked ? 'good' : 'bad'}>
                    {linked ? 'Connected' : 'Not Connected'}
                  </Box>
                </LabeledList.Item>
                {gas_type ? (
                  <LabeledList.Item label="Gas Type">
                    {gas_type}
                  </LabeledList.Item>
                ) : null}
                {extracting ? (
                  <LabeledList.Item label="Extraction Rate">
                    {extraction_rate.toFixed(2)} mol/s
                  </LabeledList.Item>
                ) : null}
              </LabeledList>
            </Section>
          </Stack.Item>

          {/* Warmup Progress */}
          {state === STATE_WARMUP ? (
            <Stack.Item>
              <Section title="Warmup Progress">
                <ProgressBar
                  value={warmup_progress}
                  minValue={0}
                  maxValue={100}
                  color="average"
                >
                  {warmup_progress.toFixed(0)}%
                </ProgressBar>
              </Section>
            </Stack.Item>
          ) : null}

          {/* Vent Reserves - only show when we have a vent */}
          {deployed && gas_type ? (
            <Stack.Item>
              <Section title="Vent Reserves">
                <Stack vertical>
                  <Stack.Item>
                    <ProgressBar
                      value={vent_reserves_percent}
                      minValue={0}
                      maxValue={100}
                      color={getReservesColor()}
                    >
                      {vent_reserves_percent.toFixed(1)}% remaining
                    </ProgressBar>
                  </Stack.Item>
                  <Stack.Item>
                    <Box color="label" fontSize="11px" mt={1}>
                      <Box
                        as="span"
                        color={vent_reserves_percent <= damage_threshold ? 'bad' : 'label'}
                      >
                        ⚠ Damage threshold: {damage_threshold}%
                      </Box>
                      {vent_reserves_percent <= damage_threshold ? (
                        <Box color="bad" bold mt={1}>
                          BELOW THRESHOLD - Stability degrading!
                        </Box>
                      ) : null}
                    </Box>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          ) : null}

          {/* Stability Section */}
          <Stack.Item>
            <Section title="Structural Integrity">
              <Stack vertical>
                <Stack.Item>
                  <ProgressBar
                    value={stability}
                    minValue={0}
                    maxValue={max_stability}
                    color={stability <= 25 ? 'bad' : stability <= 50 ? 'average' : 'good'}
                  >
                    {stability}%
                  </ProgressBar>
                </Stack.Item>
                {stability_critical ? (
                  <Stack.Item>
                    <Box color="bad" bold textAlign="center" mt={1}>
                      ⚠ CRITICAL - STRUCTURAL FAILURE IMMINENT ⚠
                    </Box>
                  </Stack.Item>
                ) : null}
              </Stack>
            </Section>
          </Stack.Item>

          {/* Control Section */}
          <Stack.Item>
            <Section title="Controls">
              <Stack justify="center">
                {!deployed ? (
                  <Stack.Item>
                    <Button
                      icon="play"
                      color="good"
                      disabled={!can_deploy || broken}
                      tooltip={deploy_error}
                      onClick={() => act('deploy')}
                    >
                      Deploy Extractor
                    </Button>
                  </Stack.Item>
                ) : (
                  <Stack.Item>
                    <Button
                      icon="stop"
                      color="bad"
                      disabled={broken}
                      onClick={() => act('undeploy')}
                    >
                      Shutdown Extractor
                    </Button>
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
