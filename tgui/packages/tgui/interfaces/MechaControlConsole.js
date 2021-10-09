// Copyright (c) 2021 /vg/station coders
// SPDX-License-Identifier: MIT

import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section, Flex, Divider, Input, Modal } from '../components';
import { Window } from '../layouts';

export const MechaControlConsole = (props, context) => {
  const { data } = useBackend(context);
  const { mechas = [] } = data;
  return (
    <Window
      width={600}
      height={460}>
      <Window.Content scrollable>
        <Mechas mechas={mechas} />
      </Window.Content>
    </Window>
  );
};

const Mechas = (props, context) => {
  const { mechas } = props;
  const [messageMechas, setMessageMechas] = useLocalState(context, 'messageMechas', []);
  const [messageText, setMessageText] = useLocalState(context, 'messageText', '');

  const { act } = useBackend(context);
  if (!mechas.length) {
    return (
      <NoticeBox>
        No exosuit tracking beacons detected.
      </NoticeBox>
    );
  }
  return mechas.map(mecha => {
    return (
      <Section
        key={mecha.ref}
        title={mecha.name}
        buttons={(
          <>
            <Button
              icon="envelope"
              content="Message"
              onClick={() => {
                return setMessageMechas(messageMechas.concat(mecha.ref));
              }} />
            <Button.Confirm
              icon={mecha.status ? 'unlock' : 'lock'}
              color={mecha.status ? 'good' : 'default'}
              content={mecha.status ? 'Release' : 'Lockdown'}
              onClick={() => act('lockdown', {
                ref: mecha.ref,
              })} />
            <Button.Confirm
              icon="bomb"
              content="Overload Beacon"
              color="bad"
              onClick={() => act('shock', {
                ref: mecha.ref,
              })} />
          </>
        )}>
        {messageMechas.includes(mecha.ref)
        && (
          <Modal align="center">
            Send Message
            <Input
              value={messageText}
              placeholder="Enter Message"
              onInput={(e, value) => setMessageText(value)}
              onChange={(e, value) => {
                if (messageText) {
                  act('message', {
                    mechamessage: messageText,
                    ref: mecha.ref,
                  });
                }
                setMessageText('');
                setMessageMechas(messageMechas.filter(
                  m => { return m !== mecha.ref; }));
              }} />
          </Modal>)}
        <Flex align="center" justify="space-evenly">
          <Flex.Item>
            <Box
              as="img"
              src={`data:image/jpeg;base64,${mecha.mechaimage}`}
              height="80px"
              width="80px"
              mx="5px"
              style={{
                '-ms-interpolation-mode': 'nearest-neighbor',
              }}

            />
          </Flex.Item>
          <Flex.Item align="stretch"><Divider vertical hidden={false} /></Flex.Item>
          <Flex.Item>
            <LabeledList>
              <LabeledList.Item label="Integrity">
                <Box color={mecha.health <= 30
                  ? 'bad'
                  : mecha.health <= 70
                    ? 'average'
                    : 'good'}>
                  {typeof mecha.health === 'number'
                    ? mecha.health + '%'
                    : 'Not Functional'}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Cell Charge">
                <Box color={mecha.charge <= 30
                  ? 'bad'
                  : mecha.charge <= 70
                    ? 'average'
                    : 'good'}>
                  {typeof mecha.charge === 'number'
                    ? mecha.charge + '%'
                    : 'Not Found'}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Pilot">
                {mecha.pilot}
              </LabeledList.Item>
              <LabeledList.Item label="Location">
                {mecha.location}
              </LabeledList.Item>
              <LabeledList.Item label="Active Module">
                {mecha.active}
              </LabeledList.Item>
              <LabeledList.Item label="Status">
                <Box color={mecha.status ? 'average' : 'default'}>
                  {mecha.status ? 'Locked Down' : 'Functional'}
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Flex.Item>
        </Flex>
      </Section>
    );
  });
};
