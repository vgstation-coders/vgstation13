// Copyright (c) 2020 /vg/station coders
// SPDX-License-Identifier: MIT

import { useBackend } from '../backend';
import { Button, LabeledList, Section, NumberInput } from '../components';
import { Window } from '../layouts';

export const MSGS = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    pressure,
    temperature,
    gases,
    power,
    targetPressure,
  } = data;
  return (
    <Window
      title="Magnetically Suspended Gas Storage Unit"
      width={420}
      height={400}>
      <Window.Content>
        <Section
          title="Controls">
          <LabeledList>
            <LabeledList.Item
              key="power"
              label="Input">
              <Button
                icon="power-off"
                selected={power}
                onClick={() => act("toggle_power")} />
            </LabeledList.Item>
            <LabeledList.Item
              key="pressure"
              label="Target output pressure">
              <NumberInput
                value={parseFloat(targetPressure)}
                unit="kPa"
                minValue={0}
                maxValue={4500}
                step={100}
                onChange={(e, value) => act('set_pressure', { 'new_pressure': value })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Stats">
          <LabeledList>
            <LabeledList.Item
              key="pressure"
              label="Pressure">
              {pressure} kPa
            </LabeledList.Item>
            <LabeledList.Item
              key="temperature"
              label="Temperature">
              {temperature} K
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Gases">
          <LabeledList>
            {gases.map(gas => (
              <LabeledList.Item
                key={gas.name}
                label={gas.name}>
                {gas.percentage}%
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
