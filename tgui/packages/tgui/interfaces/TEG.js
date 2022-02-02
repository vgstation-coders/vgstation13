/* eslint-disable react/jsx-closing-tag-location */
/* eslint-disable react/jsx-indent */
// Copyright (c) 2020 /vg/station coders
// SPDX-License-Identifier: MIT

import { useBackend } from '../backend';
import { Box, LabeledList, Section, ProgressBar, Flex } from '../components';
import { Window } from '../layouts';

export const TEG = (props, context) => {
  const { data } = useBackend(context);
  const {
    vertical,
    output,

    first_flow_cap,
    first_in_pressure,
    first_in_temp,
    first_out_pressure,
    first_out_temp,

    second_flow_cap,
    second_in_pressure,
    second_in_temp,
    second_out_pressure,
    second_out_temp,
  } = data;
  return (
    <Window
      title="thermoelectric generator"
      width={560}
      height={240}>
      <Window.Content>
        <Box style={{ display: "table", margin: "0 auto" }}>
          <Section>
            <LabeledList>
              <LabeledList.Item label="Total output">
                {output}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Box>
        <Flex>
          {first_flow_cap !== undefined
        && <Flex.Item>
          <Section title={vertical ? "Top circulator" : "Left circulator"}>
            <LabeledList>
              <LabeledList.Item
                key="first_flow_cap"
                label="Flow capacity">
                <ProgressBar
                  value={first_flow_cap}
                  minValue={0}
                  maxValue={100}
                  color="blue">
                  {first_flow_cap}%
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item
                key="first_in_pressure"
                label="Inlet pressure">
                {first_in_pressure} kPa
              </LabeledList.Item>
              <LabeledList.Item
                key="first_in_temp"
                label="Inlet temperature">
                {first_in_temp} K
              </LabeledList.Item>
              <LabeledList.Item
                key="first_out_pressure"
                label="Outlet pressure">
                {first_out_pressure} kPa
              </LabeledList.Item>
              <LabeledList.Item
                key="first_out_temp"
                label="Outlet temperature">
                {first_out_temp} K
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Flex.Item>}
          {second_flow_cap !== undefined
        && <Flex.Item>
          <Section title={vertical ? "Bottom circulator" : "Right circulator"}>
            <LabeledList>
              <LabeledList.Item
                key="second_flow_cap"
                label="Flow capacity">
                <ProgressBar
                  value={second_flow_cap}
                  minValue={0}
                  maxValue={100}
                  color="blue">
                  {second_flow_cap}%
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item
                key="second_in_pressure"
                label="Inlet pressure">
                {second_in_pressure} kPa
              </LabeledList.Item>
              <LabeledList.Item
                key="second_in_temp"
                label="Inlet temperature">
                {second_in_temp} K
              </LabeledList.Item>
              <LabeledList.Item
                key="second_out_pressure"
                label="Outlet pressure">
                {second_out_pressure} kPa
              </LabeledList.Item>
              <LabeledList.Item
                key="second_out_temp"
                label="Outlet temperature">
                {second_out_temp} K
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Flex.Item>}
        </Flex>
      </Window.Content>
    </Window>
  );
};
