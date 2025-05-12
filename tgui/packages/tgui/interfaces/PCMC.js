// Copyright (c) 2022 /vg/station coders
// SPDX-License-Identifier: MIT

import { useBackend } from '../backend';
import { Button, Divider, Section, Flex, Modal, Icon, Table, Box } from '../components';
import { Window } from '../layouts';
import { ButtonCheckbox } from '../components/Button';

export const PCMC = (props, context) => {
  const { act, data } = useBackend(context);
  const {
	itemtitle,
    emped,
    transmitting,
    autorefresh,
    location_text,
    detectedcrew,
	detected,
	injurymode,
	fullmode,
  } = data;
  return (
    <Window
	  title={itemtitle}
      width={800}
      height={400}
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
			<Flex justify="space-between">
			  <Flex.Item>
				<Button
				icon="power-off"
				onClick={() => act("turn_off")}>
				Turn off
				</Button>
                <ButtonCheckbox
                  checked={autorefresh}
                  onClick={() => act('toggle_refresh')}>
                  Auto-update
                </ButtonCheckbox>
				{!!fullmode && (
                <ButtonCheckbox
                  checked={injurymode}
                  onClick={() => act('toggle_injury')}>
                  Injuries/Deaths Only
                </ButtonCheckbox>
				)}
              </Flex.Item>
              <Flex.Item bold>
			    {location_text}
              </Flex.Item>
			</Flex>
          </Section>
        )}
        {!emped && !!transmitting && (
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
				    <Divider color="#4972A1">
				    </Divider>
				  </Table.Cell>
				  <Table.Cell>
				    <Divider color="#4972A1">
				    </Divider>
				  </Table.Cell>
				  <Table.Cell>
				    <Divider color="#4972A1">
				    </Divider>
				  </Table.Cell>
				  <Table.Cell>
				    <Divider color="#4972A1">
				    </Divider>
				  </Table.Cell>
				  <Table.Cell>
				    <Divider color="#4972A1">
				    </Divider>
				  </Table.Cell>
				</Table.Row>
                {detectedcrew.map(crew => (
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
			  {!detected && (
			    <Fragment align="center">
				  {injurymode && (
			        "No detected injuries amongst the crew."
				  ) || (
				    "No detected suit sensors."
				  )}
			    </Fragment>
			  )}
			</Section>
        )}
      </Window.Content>
    </Window>
  );
};