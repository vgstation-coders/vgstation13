import { map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { pureComponentHooks } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Chart, ColorBox, Flex, Icon, LabeledList, ProgressBar, Section, Table } from '../components';
import { Window } from '../layouts';

export const PowerMonitor = () => {
  return (
    <Window
      width={550}
      height={700}>
      <Window.Content scrollable>
        <PowerMonitorContent />
      </Window.Content>
    </Window>
  );
};

export const PowerMonitorContent = (props, context) => {
  const { data } = useBackend(context);
  const { act } = useBackend(context);
  const { history } = data;
  const [
    sortByField,
    setSortByField,
  ] = useLocalState(context, 'sortByField', null);
  const { supply, demand } = data;
  const supplyNum = history.supply[history.supply.length - 1] || 0;
  const demandNum = history.demand[history.demand.length - 1] || 0;
  const supplyData = history.supply.map((value, i) => [i, value]);
  const demandData = history.demand.map((value, i) => [i, value]);
  const maxValue = Math.max(
    ...history.supply,
    ...history.demand);
    // Process area data
  const areas = flow([
    map((area, key) => ({
      ...area,
      id: key,
      details: false,
    })),
    sortByField === 'name' && sortBy(area => area.name),
    sortByField === 'charge' && sortBy(area => -area.charge),
    sortByField === 'draw' && sortBy(area => -area.demand),
  ])(data.areas);
  const priorityText = ["Critical", "Highest", "Very High", "High", "Normal", "Low", "Very Low", "Lowest", "Minimal"];
  const [areaDetailExpanded, setAreaDetailExpanded] = useLocalState(context, 'areaDetailExpanded', new Set());
  return (
    <>
      <Flex mx={-0.5} mb={1}>
        <Flex.Item mx={0.5} width="200px">
          <Section>
            <LabeledList>
              <LabeledList.Item label="Supply">
                <ProgressBar
                  value={supplyNum}
                  minValue={0}
                  maxValue={demandNum}
                  color="teal">
                  {supply}
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Draw">
                <ProgressBar
                  value={demandNum}
                  minValue={0}
                  maxValue={supplyNum}
                  color="pink">
                  {demand}
                </ProgressBar>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Flex.Item>
        <Flex.Item mx={0.5} grow={2}>
          <Box position="relative" height="100%">
            <Chart.Line
              fillPositionedParent
              data={supplyData}
              rangeX={[0, supplyData.length - 1]}
              rangeY={[0, maxValue]}
              strokeColor="rgba(0, 181, 173, 1)"
              fillColor="rgba(0, 181, 173, 0.25)" />
            <Chart.Line
              fillPositionedParent
              data={demandData}
              rangeX={[0, demandData.length - 1]}
              rangeY={[0, maxValue]}
              strokeColor="rgba(224, 57, 151, 1)"
              fillColor="rgba(224, 57, 151, 0.25)" />
          </Box>
        </Flex.Item>
      </Flex>
      <Section>
        <Box mb={1}>
          <Box inline mr={2} color="label">
            Sort by:
          </Box>
          <Button.Checkbox
            checked={sortByField === 'name'}
            content="Name"
            onClick={() => setSortByField(
              sortByField !== 'name' && 'name'
            )} />
          <Button.Checkbox
            checked={sortByField === 'charge'}
            content="Charge"
            onClick={() => setSortByField(
              sortByField !== 'charge' && 'charge'
            )} />
          <Button.Checkbox
            checked={sortByField === 'draw'}
            content="Draw"
            onClick={() => setSortByField(
              sortByField !== 'draw' && 'draw'
            )} />
        </Box>
        <Table>
          <Table.Row header>
            <Table.Cell>
              Area
            </Table.Cell>
            <Table.Cell collapsing textAlign="center">
              Priority
            </Table.Cell>
            <Table.Cell collapsing>
              Charge
            </Table.Cell>
            <Table.Cell textAlign="right">
              Draw
            </Table.Cell>
            <Table.Cell collapsing title="Equipment">
              Eqp
            </Table.Cell>
            <Table.Cell collapsing title="Lighting">
              Lgt
            </Table.Cell>
            <Table.Cell collapsing title="Environment">
              Env
            </Table.Cell>
          </Table.Row>
          {areas.map((area, i) => (
            <>
              <tr
                key={area.id}
                className="Table__row candystripe">
                <td>
                  {/* Area name + machine list dropdown */}
                  <Button
                    icon={(areaDetailExpanded.has(area.id) === true ? "minus" : "plus") + "-square-o"}
                    color="transparent"
                    textColor="#ffffff"
                    title={(areaDetailExpanded.has(area.id) === true ? "Hide" : "Show") + " details"}
                    onClick={() => {
                      if (areaDetailExpanded.has(area.id) === true) {
                        areaDetailExpanded.delete(area.id);
                        setAreaDetailExpanded(areaDetailExpanded);
                      } else {
                        setAreaDetailExpanded(
                          areaDetailExpanded.add(area.id));
                      }
                    }}
                  >
                    {area.name}
                  </Button>
                </td>

                <td>{
                  /* Purposely left blank
                     areas have no priority, only machines do
                  */
                }
                </td>

                <td className="Table__cell text-right text-nowrap">
                  {/* Area battery info */}
                  { area.charge !== undefined && (
                    <BatteryStatusIndicator
                      charging={area.charging}
                      charge={area.charge}
                    />
                  )}
                </td>

                <td className="Table__cell text-right text-nowrap">
                  {/* Area power demand info */}
                  {area.f_demand}
                </td>

                <td className="Table__cell text-center text-nowrap">
                  { area.eqp !== undefined && (
                    <ApcStatusIndicator status={area.eqp} tooltipName="Equipment" />
                  )}
                </td>

                <td className="Table__cell text-center text-nowrap">
                  { area.lgt !== undefined && (
                    <ApcStatusIndicator status={area.lgt} tooltipName="Lights" />
                  )}
                </td>

                <td className="Table__cell text-center text-nowrap">
                  { area.env !== undefined && (
                    <ApcStatusIndicator status={area.env} tooltipName="Enviroment" />
                  )}
                </td>

              </tr>
              { areaDetailExpanded.has(area.id) === true
                && map((machine, key) =>
                  (
                    <tr className="Table__row candystripe">
                      <td>
                        {/* Machine name */}
                        &nbsp; {key === Object.keys(area.machines).pop() ? '└' : '├'} {machine.name}
                      </td>
                      <td className="Table__cell text-center text-nowrap">
                        {/* Machine priority display/dropdown */}
                        { data.engineer_access === 1
                            && !machine.priority_locked && (
                          <Button
                              icon="minus"
                              compact
                              mx="2px"
                              disabled={!!machine.priority_locked
                              || machine.priority >= 10}
                              onClick={() => act('priority', {
                              'value': (machine.priority + 1),
                              'ref': machine.ref,
                              'id': key,
                            })}
                          />
                        )}
                        <Box
                          inline
                          width="6rem"
                        >
                          {(machine.priority >= 2
                              && machine.priority < (2 + priorityText.length)
                          )
                            ? priorityText[machine.priority -2]
                            : "$^%!#%¿&"}
                        </Box>
                        { data.engineer_access === 1
                            && !machine.priority_locked && (
                          <Button
                              icon="plus"
                              compact
                              mx="2px"
                              disabled={machine.priority <= 2}
                              onClick={() => act('priority', {
                              'value': (machine.priority - 1),
                              'ref': machine.ref,
                              'id': key,
                            })}
                          />
                        )}
                      </td>

                      <td className="Table__cell text-right text-nowrap">
                        {/* Machine battery info */}
                        {!!machine.isbattery && (
                          <BatteryStatusIndicator
                            charging={machine.charging}
                            charge={machine.charge}
                          />
                        )}
                      </td>

                      <td className="Table__cell text-right text-nowrap">
                        {/* Machine power demand info */}
                        {machine.f_demand}
                      </td>

                      <td /><td /><td />

                    </tr>
                  ))(area.machines)}
            </>
          ))}
        </Table>
      </Section>
    </>
  );
};

export const BatteryStatusIndicator = props => {
  const { charging, charge } = props;
  // TODO figure out icons for no change vs discharge vs charging
  return (
    <>
      <Icon
        name={(
          charging === 1 && 'bolt'
          || charge >= 100 && 'battery-full'
          || charge > 50 && 'battery-half'
          || charge > 0 && 'battery-quarter'
          || 'battery-empty'
        )}
        color={(
          charging === 1 && 'yellow'
          || charge >= 100 && 'green'
          || charge > 50 && 'yellow'
          || 'red'
        )}
      />
      <Box
        inline
        width="36px"
        textAlign="right"
      >
        {toFixed(charge) + '%'}
      </Box>
    </>
  );
};

BatteryStatusIndicator.defaultHooks = pureComponentHooks;

const ApcStatusIndicator = props => {
  const { tooltipName } = props;
  const { status } = props;
  const power = Boolean(status & 2);
  const mode = Boolean(status & 1);
  const tooltipText = tooltipName + ' ' + (power ? 'On' : 'Off')
    + ` [${mode ? 'auto' : 'manual'}]`;
  return (
    <ColorBox
      color={power ? 'good' : 'bad'}
      content={mode ? undefined : 'M'}
      title={tooltipText}
    />
  );
};

ApcStatusIndicator.defaultHooks = pureComponentHooks;
