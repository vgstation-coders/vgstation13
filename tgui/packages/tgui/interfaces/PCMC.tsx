// Copyright (c) 2022 /vg/station coders
// SPDX-License-Identifier: MIT

import { Box, Button, Divider, Flex, Icon, Modal, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  itemtitle: string,
  emped: boolean,
  transmitting: boolean,
  autorefresh: boolean,
  location_text: string,
  detectedcrew: Crewmember[],
  detected: boolean, // Do we see the crew at all?
  injurymode: boolean,
  fullmode: boolean
}

type Crewmember = {
  name: string,
  assignment: string,
  vitals: number,
  damage: Damage,
  location_text: string,
  playerArea: string,
  see_x: string,
  see_y: string,
  see_z: string,
  count: number,
  sensor: number,
}

// This is pushing it but I don't really care
type Damage = {
  oxygen: number,
  toxin: number,
  burn: number,
  brute: number,
}

export const PCMC = (context) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window
	  title={data.itemtitle}
      width={800}
      height={400}
      resizable>
      {!!data.emped && (
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
        {!data.transmitting && (
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
			<Flex justify="space-between">
			  <Flex.Item>
				<Button
				icon="power-off"
				onClick={() => act("turn_off")}>
				Turn off
				</Button>
                <Button.Checkbox
                  checked={data.autorefresh}
                  onClick={() => act('toggle_refresh')}>
                  Auto-update
                </Button.Checkbox>
				{!!data.fullmode && (
                <Button.Checkbox
                  checked={data.injurymode}
                  onClick={() => act('toggle_injury')}>
                  Injuries/Deaths Only
                </Button.Checkbox>
				)}
     </Flex.Item>
              <Flex.Item bold>
			    {data.location_text}
              </Flex.Item>
			</Flex>
          </Section>
        )}
        {!data.emped && !!data.transmitting && (
			<Section title="Suit Sensor Signals">
			  <Table>
			    <Table.Row>
				  <Table.Cell bold>
				    Name
				  </Table.Cell>
				  <Table.Cell bold>
				    Occupation
				  </Table.Cell>
				  <Table.Cell bold>
				    Vitals
				  </Table.Cell>
				  <Table.Cell bold>
				    Status
				  </Table.Cell>
				  <Table.Cell bold>
				    Location
				  </Table.Cell>
       </Table.Row>
				<Table.Row>
				  <Table.Cell>
				    <Divider color="#4972A1" />
				  </Table.Cell>
				  <Table.Cell>
				    <Divider color="#4972A1" />
				  </Table.Cell>
				  <Table.Cell>
				    <Divider color="#4972A1" />
				  </Table.Cell>
				  <Table.Cell>
				    <Divider color="#4972A1" />
				  </Table.Cell>
				  <Table.Cell>
				    <Divider color="#4972A1" />
				  </Table.Cell>
				</Table.Row>
          {data.detectedcrew.map(crew => (
			      <Table.Row backgroundColor={crew.count % 2 ? "rgba(17,17,17,0.6)" : "rgba(33,33,33,0.6)"}>
				    <Table.Cell bold>
				      {crew.name}
				    </Table.Cell>
				    <Table.Cell>
				      {crew.assignment}
				    </Table.Cell>
				    <Table.Cell bold>
					    {crew.vitals == 0 && <Box>
				          Alive
                              </Box>}
					    {crew.vitals == 1 && <Box color="red">
				          Critical
                              </Box>}
					    {crew.vitals == 2 && <Box color="red">
				          DEAD
                              </Box>}
				    </Table.Cell>
				    {crew.sensor < 2 && (
					  <Table.Cell>
						  {crew.damage.brute}
						  {crew.damage.burn}
						  {crew.damage.toxin}
						  {crew.damage.oxygen}
					  </Table.Cell>
				    ) || (
					  <Table.Cell>
					    (
					    <Box as="span" bold color="#FF0000">
						  {crew.damage.brute}
					    </Box>
					    /
					    <Box as="span" bold color="#FFA500">
						  {crew.damage.burn}
					    </Box>
					    /
					    <Box as="span" bold color="#00FF00">
						  {crew.damage.toxin}
					    </Box>
					    /
					    <Box as="span" bold color="#3399CC">
						  {crew.damage.oxygen}
					    </Box>
					    )
       </Table.Cell>
					)}
				    <Table.Cell>
				      {crew.location_text}
				    </Table.Cell>
         </Table.Row>
			    ))}
			  </Table>
			  {!data.detected && (
			    <Flex align="center">
				  {data.injurymode && (
			        "No detected injuries amongst the crew."
				  ) || (
				    "No detected suit sensors."
				  )}
			    </Flex>
			  )}
			</Section>
        )}
      </Window.Content>
    </Window>
  );
};
