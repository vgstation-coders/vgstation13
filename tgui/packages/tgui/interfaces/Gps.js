// Copyright (c) 2020 /vg/station coders
// SPDX-License-Identifier: MIT

import { useBackend } from '../backend';
import { Button, LabeledList, Section, Flex, Modal, Icon } from '../components';
import { Window } from '../layouts';
import { ButtonCheckbox } from '../components/Button';

export const Gps = (props, context) => {
  const { act, data } = useBackend(context);
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
            <ButtonCheckbox
              checked={autorefresh}
              onClick={() => act('toggle_refresh')}>
              Auto-update
            </ButtonCheckbox>
            <Button.Input
              content={"Set tag: "+gpstag}
              currentValue={gpstag}
              onCommit={(e, value) => act('set_tag', { 'new_tag': value })} />
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
