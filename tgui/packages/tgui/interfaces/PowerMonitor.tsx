import { sortBy } from 'common/collections';
import { useState } from 'react';
import { Box, Button, Chart, ColorBox, Flex, Icon, LabeledList, ProgressBar, Section, Table } from 'tgui-core/components';
import { flow } from 'tgui-core/fp';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
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

type Data = {
  engineer_access: number,
  attached: boolean,
  history: DataPoints,
  supply: string,
  demand: string,
  areas: {[key: string]: Area[]},
}

type DataPoints = {
  supply: number[],
  demand: number[],
}

type Area = {
  id: string, // \ref[] byond-side
  name: string,
  eqp: number,
  lgt: number,
  env: number,
  machines: {[key: string]: ApcStatus},
}

type ApcStatus = {
  priority_locked: boolean,
  priority: number,
  demand: number,
  isbattery: number,
  ref: string,
  charging: boolean,
  charge: number,
  f_demand: string,
}

export function powerRank(str: string): number {
  const unit = String(str.split(' ')[1]).toLowerCase();
  return ['w', 'kw', 'mw', 'gw'].indexOf(unit);
}


export const PowerMonitorContent = (props, context) => {
  const { data } = useBackend<Data>();
  const { act } = useBackend<Data>();
  const { history } = data;
  const [
    sortByField,
    setSortByField,
  ] = useState<string | null>(null);
  const { supply, demand } = data;
  const supplyNum = history.supply[history.supply.length - 1] || 0;
  const demandNum = history.demand[history.demand.length - 1] || 0;
  const supplyData = history.supply.map((value, i) => [i, value]);
  const demandData = history.demand.map((value, i) => [i, value]);
  const maxValue = Math.max(
    ...history.supply,
    ...history.demand);

    const areas = flow([
      // Transform the assoc map given to us by BYOND into a plain array
      entries => entries.map(([key, area]) => ({
        ...area,
        id: key,
        details: false,
      })),
      // Sort that array if need be
      areas => {
        if (sortByField === 'name') {
          return sortBy(areas, area => area.name);
        }
        if (sortByField === 'charge') {
          return sortBy(areas, area => -(area.charge ?? 0));
        }
        if (sortByField === 'draw') {
          return sortBy(areas, area => -(area.demand ?? 0));
        }
        return areas;
      },
    ])(Object.entries(data.areas));

  const priorityText = ["Critical", "Highest", "Very High", "High", "Normal", "Low", "Very Low", "Lowest", "Minimal"];
  const [areaDetailExpanded, setAreaDetailExpanded] = useState(new Set());

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
                && Object.entries(area.machines).map(([key, machine]) =>
                  (
                <tr className="Table__row candystripe" key={key}>
                <td>
                  {/* Machine name */}
                  &nbsp; {key === Object.keys(area.machines).pop() ? '└' : '├'} {machine.name}
                </td>
                <td className="Table__cell text-center text-nowrap">
                  {/* Machine priority display/dropdown */}
                  {data.engineer_access === 1 && !machine.priority_locked && (
                    <Button
                      icon="minus"
                      compact
                      mx="2px"
                      disabled={!!machine.priority_locked || machine.priority >= 10}
                      onClick={() => act('priority', {
                        value: machine.priority + 1,
                        ref: machine.ref,
                        id: key,
                      })}
                    />
                  )}
                  <Box inline width="6rem">
                    {(machine.priority >= 2 && machine.priority < (2 + priorityText.length))
                      ? priorityText[machine.priority - 2]
                      : "$^%!#%¿&"}
                  </Box>
                  {data.engineer_access === 1 && !machine.priority_locked && (
                    <Button
                      icon="plus"
                      compact
                      mx="2px"
                      disabled={machine.priority <= 2}
                      onClick={() => act('priority', {
                        value: machine.priority - 1,
                        ref: machine.ref,
                        id: key,
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
            ))
          }
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
