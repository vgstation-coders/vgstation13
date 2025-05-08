// Copyright (c) 2020 /vg/station coders
// SPDX-License-Identifier: MIT

import { Button, Flex, Icon, LabeledList, Modal, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Device = {
  tag: String,
  location_text: String,
}

type Data = {
  emped: Boolean,
  transmitting: Boolean,
  gpstag: String,
  autorefresh: String,
  location_text: String,
  devices: Device[],
}


export const Gps = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    emped,
    transmitting,
    gpstag,
    autorefresh,
    location_text,
    devices,
  } = data;
  return (
    <Window
      title="Global Positioning System"
      width={470}
      height={500}
      resizable>
      {!!emped && (
        <Modal>
          <Flex align="center">
            <Flex.Item mr={2}>
              <Icon name="exclamation-triangle" />
            </Flex.Item>
            <Flex.Item minWidth={15}>
              Bluespace module failure.<br />Attempting to recalibrate...
            </Flex.Item>
          </Flex>
        </Modal>
      )}
      <Window.Content scrollable>
        {!transmitting && (
          <Section
            title="Settings">
            <Button
              icon="power-off"
              onClick={() => act("turn_on")}>
              Turn on
            </Button>
          </Section>
        ) || (
          <Section title="Settings">
            <Button.Checkbox
              checked={autorefresh}
              onClick={() => act('toggle_refresh')}>
              Auto-update
            </Button.Checkbox>
            <Button.Input
              content={"Set tag: "+gpstag}
              currentValue={gpstag}
              onCommit={(e, value) => (act('set_tag', { 'new_tag': value }))} />
          </Section>
        )}
        {!emped && !!transmitting && (
          <Section title="Signals">
            <LabeledList>
              <LabeledList.Item
                label={gpstag}>
                {location_text}
              </LabeledList.Item>
              {devices.map(device => (
                <LabeledList.Item
                  key={device.tag}
                  label={device.tag}>
                  {device.location_text}
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
