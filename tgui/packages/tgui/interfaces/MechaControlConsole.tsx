// Copyright (c) 2021 /vg/station coders
// SPDX-License-Identifier: MIT

import { useState } from 'react';
import { Box, Button, Divider, Flex, Input, LabeledList, Modal, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  mechas: Mecha[]
  mechaMessage: string,
  ref: string, // The \ref of the mech to whom we send a message!
}

type Mecha = {
  name: string,
  pilot: string,
  location: string,
  mechaimage: string, // base64 string icon
  status: string,
  charge: number,
  health: number,
  active: string,
  ref: string, // The \ref on the DM side
  log: string,
}

export const MechaControlConsole = (props) => {
  const { data } = useBackend<Data>();
  return (
    <Window
      width={600}
      height={460}>
      <Window.Content scrollable>
        <Mechas mechas={data.mechas} />
      </Window.Content>
    </Window>
  );
};

const Mechas = (props) => {
  const { act } = useBackend<Data>();
  const { mechas } = props;
  const [messageMechas, setMessageMechas] = useState('');
  const [messageText, setMessageText] = useState('');

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
              confirmContent="Confirm?"
              onClick={() => act('lockdown', {
                ref: mecha.ref,
              })} />
            <Button.Confirm
              icon="bomb"
              content="Overload Beacon"
              confirmContent="Confirm?"
              color="bad"
              onClick={() => act('shock', {
                ref: mecha.ref,
              })} />
          </>
        )}>
        {messageMechas.includes(mecha.ref)
        && (
          <Modal align="center">
            Send Message:
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
                // Empty out the Message mecha window
                setMessageText('');
                setMessageMechas('');
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
                'image-rendering': 'pixelated',
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
                  {mecha.health > 0
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
