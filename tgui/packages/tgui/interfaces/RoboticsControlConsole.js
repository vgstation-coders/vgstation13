// Copyright (c) 2021 /vg/station coders
// SPDX-License-Identifier: MIT

import { useBackend, useSharedState } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section, Tabs, Flex, Divider } from '../components';
import { Window } from '../layouts';

export const RoboticsControlConsole = (props, context) => {
  const { data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const { 
    can_hack, 
    sequence_activated, 
    sequence_timeleft, 
    cyborgs = [], 
  } = data;
  return (
    <Window
      width={500}
      height={460}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            icon="exclamation-triangle"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}>
            Emergency Self-Destruct
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}>
            Cyborgs ({cyborgs.length})
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && (
          <SelfDestruct 
            sequence_activated={sequence_activated} 
            sequence_timeleft={sequence_timeleft}
          />
        )}
        {tab === 2 && (
          <Cyborgs cyborgs={cyborgs} can_hack={can_hack} />
        )}
      </Window.Content>
    </Window>
  );
};

const Cyborgs = (props, context) => {
  const { cyborgs, can_hack } = props;
  const { act } = useBackend(context);
  if (!cyborgs.length) {
    return (
      <NoticeBox>
        No cyborg units detected within access parameters.
      </NoticeBox>
    );
  }
  return cyborgs.map(cyborg => {
    return ( 
      <Section
        key={cyborg.ref}
        title={cyborg.name}
        buttons={(
          <>
            {can_hack && !cyborg.emagged ? (
              <Button
                icon="terminal"
                content="Hack"
                color="bad"
                onClick={() => act('hack', {
                  ref: cyborg.ref,
                })} />
            ) : ''}
            <Button.Confirm
              icon={cyborg.locked_down ? 'unlock' : 'lock'}
              color={cyborg.locked_down ? 'good' : 'default'}
              content={cyborg.locked_down ? 'Release' : 'Lockdown'}
              onClick={() => act('lockdown', {
                ref: cyborg.ref,
              })} />
            <Button.Confirm
              icon="bomb"
              content="Detonate"
              color="bad"
              onClick={() => act('killbot', {
                ref: cyborg.ref,
              })} />
          </>
        )}>
        <Flex>
          <Flex.Item>
            <Box
              as="img"
              src={`data:image/jpeg;base64,${cyborg.borgimage}`}
              height="64px"
              width="64px"
              style={{
                '-ms-interpolation-mode': 'nearest-neighbor',
              }}
            />
          </Flex.Item>
          <Flex.Item><Divider vertical /></Flex.Item>
          <Flex.Item>
            <LabeledList>
              <LabeledList.Item label="Status">
                <Box color={cyborg.status
                  ? 'bad'
                  : cyborg.locked_down
                    ? 'average'
                    : 'good'}>
                  {cyborg.status
                    ? 'Not Responding'
                    : cyborg.locked_down
                      ? 'Locked Down'
                      : 'Nominal'}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Cell Charge">
                <Box color={cyborg.charge <= 30
                  ? 'bad'
                  : cyborg.charge <= 70
                    ? 'average'
                    : 'good'}>
                  {typeof cyborg.charge === 'number'
                    ? cyborg.charge + '%'
                    : 'Not Found'}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Model">
                {cyborg.module}
              </LabeledList.Item>
              <LabeledList.Item label="Slaved To">
                <Box color={cyborg.master ? 'default' : 'average'}>
                  {cyborg.master || 'None'}
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Flex.Item>
        </Flex>
      </Section>
    );
  });
};

const SelfDestruct = (props, context) => {
  const { sequence_activated, sequence_timeleft } = props;
  const { act } = useBackend(context);
  let minutes = Math.floor(sequence_timeleft/60);
  let seconds = Math.floor(sequence_timeleft-minutes*60);

  return (
    <NoticeBox
      info={sequence_activated ? false : true}
      danger={sequence_activated ? true : false}
      textAlign="center">
      
      Cyborg Emergency Killswitch<br /><br />
      {
        sequence_activated
          ? String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0')
          : ''
      }
      <br />
      <Button.Confirm
        icon="skull-crossbones"
        content={sequence_activated ? 'Halt' : 'Activate'}
        color={sequence_activated ? 'bad' : 'good'}
        onClick={() => act('sequence')} 
      />
      <br />
    </NoticeBox>
  );

};
