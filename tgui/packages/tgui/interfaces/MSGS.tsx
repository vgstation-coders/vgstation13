// Copyright (c) 2020 /vg/station coders
// SPDX-License-Identifier: MIT

import { useState } from 'react';
import { Button, LabeledList, NumberInput, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  pressure: number,
  temperature: number,
  power: boolean,
  targetPressure: number,
  gases: Gas[],
}

type Gas = {
  name: string,
  percentage: number,
}

export const MSGS = (props) => {
  const { act, data } = useBackend<Data>();

  const [localPressure, setLocalPressure] = useState(data.targetPressure);

  return (
    <Window
      title="Magnetically Suspended Gas Storage Unit"
      width={420}
      height={460}>
      <Window.Content>
        <Section
          title="Controls">
          <LabeledList>
            <LabeledList.Item
              key="power"
              label="Input">
              <Button
                icon="power-off"
                selected={data.power}
                onClick={() => act("toggle_power")} />
            </LabeledList.Item>
            <LabeledList.Item
              key="pressure"
              label="Target output pressure">
              <NumberInput
                animated
                value={localPressure}
                stepPixelSize={5}
                unit="kPa"
                minValue={0}
                maxValue={4500}
                step={100}
                onChange={(value) => {
                  setLocalPressure(value);
                  act('set_pressure', { 'new_pressure': localPressure });
                }}
                ondrag={(value) => {
                  setLocalPressure(value);
                  act('set_pressure', { 'new_pressure': localPressure });
                }} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Stats">
          <LabeledList>
            <LabeledList.Item
              key="pressure"
              label="Pressure">
              {data.pressure} kPa
            </LabeledList.Item>
            <LabeledList.Item
              key="temperature"
              label="Temperature">
              {data.temperature} K
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Gases">
          <LabeledList>
            {data.gases.map(gas => (
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
