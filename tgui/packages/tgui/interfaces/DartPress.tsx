// Copyright (c) 2021 /vg/station coders
// SPDX-License-Identifier: MIT

import { useState } from 'react';
import { Box, Button, Divider, Flex, LabeledList, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  output_darts: number,
  loaded_darts: number,
  dart_label: string,
  container_1: ReagentContainer,
  container_2: ReagentContainer,
  active_dart: ReagentContainer,
  output_max: number,
}

type ReagentContainer = {
  name: string,
  reagents: Reagent[],
}

type Reagent = {
  name: string,
  volume: number,
}


export const DartPress = (props) => {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useState();
  const {
    output_darts,
    output_max,
    loaded_darts,
    dart_label,
    container_1,
    container_2,
    active_dart,
  } = data;
  return (
    <Window
      width={600}
      height={460}>
      <Window.Content>
        <Stack fill vertical>
          <Stack fill>
            <Stack.Item grow><ReagentContainerSection container={container_1} container_num={1} /></Stack.Item>
            <Stack.Item grow><ReagentContainerSection container={active_dart} container_num={3} /></Stack.Item>
            <Stack.Item grow><ReagentContainerSection container={container_2} container_num={2} /></Stack.Item>
          </Stack>
          <Stack.Item>
            <Section fill>
              <Flex>
              <Flex.Item grow>
                <Button
              fluid
              textAlign="center"
              content="Press Dart"
              icon="angle-down"
              color="good"
              onClick={() => act('press')} />
              </Flex.Item>
              <Flex.Item><Divider vertical /></Flex.Item>
              <Flex.Item grow>
                <Button
              fluid
              textAlign="center"
              content="Cycle Next Dart"
              icon="arrows-spin"
              color="default"
              onClick={() => act('cycle')} />
              </Flex.Item>
              <Flex.Item><Divider vertical /></Flex.Item>
              <Flex.Item grow>
                 <Button
                fluid
                textAlign="center"
                content="Eject Dart"
                icon="eject"
                color="bad"
                onClick={() => act('eject', { choice: 3 })} />
              </Flex.Item>
              </Flex>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section fill>
              {output_darts === -1 ?
                (<><Button
                    icon="angle-down"
                    color="default"
                    onClick={() => act('insert', {
                      choice: 4,
                    })} /> No Output Box Loaded
                 </>
                )
                :
                (<ProgressBar value={output_darts} minValue={0} maxValue={output_max}>
                    Output: {output_darts} / output_max <Button icon="eject" color="good" onClick={() => act('eject', { choice: 4 })} />
                 </ProgressBar>)
              }
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};


const ReagentContainerSection = (props) => {
  const { container, container_num } = props;
  const { act, data } = useBackend<Data>();
  if (!container) {
    return (
      <Section
        title="No Container"
        buttons={(
          <Button
            icon="angle-down"
            color="default"
            onClick={() => act('insert', {
              choice: container_num,
            })} />
        )} />
    );
  }
  return (
    <Section
      title={container.name}
      buttons={(
        <Button
          icon="eject"
          color="good"
          onClick={() => act('eject', {
            choice: container_num,
          })} />
      )}>
      <Flex direction="column">
        <Flex.Item align="center"><Box
          as="img"
          src={`data:image/jpeg;base64,${container.containericon}`}
          height="64px"
          width="64px"
          style={{
            'image-rendering': 'pixelated',
          }}
        />
        </Flex.Item>
        <Flex.Item><Divider /></Flex.Item>
        <Flex.Item><ReagentList reagents={container.reagents} /></Flex.Item>
      </Flex>
    </Section>
  );
};


const ReagentList = (props) => {
  const { reagents = [] } = props;
  if (!reagents.length) {
    return (
      <>Empty</>
    );
  }
  return (
    <LabeledList>
      {reagents.map(reagent => {
        return (
        <LabeledList.Item key={reagents.name} label={reagent.name}>
          <Box>{reagent.volume}u</Box>
        </LabeledList.Item>
       );
      })
      }
    </LabeledList>
  );
};
