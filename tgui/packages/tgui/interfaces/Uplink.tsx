import { filter, sort } from 'common/collections';
import { useState } from 'react';
import { Box, Button, Flex, Icon, Input, NoticeBox, Section, Table, Tabs } from 'tgui-core/components';
import { round, toFixed } from 'tgui-core/math';
import { createSearch, decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const MAX_SEARCH_RESULTS = 25;

// -- Not sure if those are already in TG but eeeh --
export const formatMoneyWithDiscount = (value, base_value?, precision = 0) => {
  if (!base_value)
  { return formatMoney(value, precision); }
  value = formatMoney(value, precision);
  base_value = formatMoney(base_value, precision);
  return (value === base_value ? value : value + ' (was '+ base_value +')');
};

export const formatMoney = (value, precision = 0) => {
  if (!Number.isFinite(value)) {
    return value;
  }
  // Round the number and make it fixed precision
  let fixed = round(value, precision);
  if (precision > 0) {
    fixed = toFixed(value, precision);
  }
  fixed = String(fixed);
  // Place thousand separators
  const length = fixed.length;
  let indexOfPoint = fixed.indexOf('.');
  if (indexOfPoint === -1) {
    indexOfPoint = length;
  }
  let result = '';
  for (let i = 0; i < length; i++) {
    if (i > 0 && i < indexOfPoint && (indexOfPoint - i) % 3 === 0) {
      // Thin space
      result += '\u2009';
    }
    result += fixed.charAt(i);
  }
  return result;
};

type Data = {
  telecrystals: number,
  lockable: number, // Should be boolean-like but
  compactMode: number,
  selectedCategory: Category,

  // Static
  categories: Category[],
}

type Category = {
  name: string,
  items: UplinkItem[],
}

type UplinkItem = {
  name: string,
  cost: number,
  base_cost: number,
  desc: string,
  discounted: number, // boolean-like
  refundable: number, // boolean-like
}

export const Uplink = (props) => {
  const { data } = useBackend<Data>();
  const { telecrystals } = data;
  return (
    <Window
      width={620}
      height={600}
      theme="syndicate">
      <Window.Content scrollable>
        <GenericUplink
          currencyAmount={telecrystals}
          currencySymbol="TC" />
      </Window.Content>
    </Window>
  );
};


/**
 * Filters religions, applies search terms.
 */
export const filterItems = (items: UplinkItem[], searchText = ''): UplinkItem[] => {
  if (searchText) {
      const testSearch = createSearch(
        searchText,
        (item: UplinkItem) =>
        [item.name,
        (item.desc || [])].join(' ')
      );
    items = filter(items, testSearch);
    items = sort(items);
    return items;
  }
  return items;
};

export const GenericUplink = (props) => {

  const {
    currencyAmount = 0,
    currencySymbol = 'cr',
  } = props;

  const { act, data } = useBackend<Data>();

  const {
    compactMode,
    lockable,
    categories = [],
  } = data;

  const [
    searchText,
    setSearchText,
  ] = useState('');
  const [
    selectedCategory,
    setSelectedCategory,
  ] = useState(categories[0]?.name);

  let items: UplinkItem[];
  let allItems: UplinkItem[] = data.categories.flatMap(category => category.items);

  if (searchText.length > 0) {
    items = filterItems(allItems, searchText);
  }
  else {
    items = categories.find(category => category.name === selectedCategory)?.items || [];
  }

  return (
    <Section
      title={(
        <Box
          inline
          color={currencyAmount > 0 ? 'good' : 'bad'}>
          {formatMoneyWithDiscount(currencyAmount)} {currencySymbol}
        </Box>
      )}
      buttons={(
        <>
          Search
          <Input
            autoFocus
            value={searchText}
            onInput={(e, value) => setSearchText(value)}
            mx={1} />
          <Button
            icon={compactMode ? 'list' : 'info'}
            content={compactMode ? 'Compact' : 'Detailed'}
            onClick={() => act('compact_toggle')} />
          <Button.Input
            content={<Box><Icon name="coins" /> Withdraw</Box>}
            onCommit={(e, value) => act('get_tc', { 'amount': value })} />

          {!!lockable && (
            <Button
              icon="lock"
              content="Lock"
              onClick={() => act('lock')} />
          )}
        </>
      )}>
      <Flex>
        {searchText.length === 0 && (
          <Box pr={2}>
            <Flex.Item>
              <Tabs vertical>
                {categories.map(category => (
                  <Tabs.Tab
                    key={category.name}
                    selected={category.name === selectedCategory}
                    onClick={() => setSelectedCategory(category.name)}>
                    {category.name} ({category.items?.length || 0})
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Flex.Item>
          </Box>
        )}
        <Flex.Item grow={1} basis={0}>
          {items.length === 0 && (
            <NoticeBox>
              {searchText.length === 0
                ? 'No items in this category.'
                : 'No results found.'}
            </NoticeBox>
          )}
          <ItemList
            compactMode={searchText.length > 0 || compactMode}
            currencyAmount={currencyAmount}
            currencySymbol={currencySymbol}
            items={items} />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const ItemList = (props, context) => {
  const {
    compactMode,
    currencyAmount,
    currencySymbol,
  } = props;
  const { act, data } = useBackend<Data>();
  const [
    hoveredItem,
    setHoveredItem,
  ] = useState({});
  const hoveredCost = hoveredItem && hoveredItem.cost || 0;
  // Append extra hover data to items
  const items = props.items.map(item => {
    const notSameItem = hoveredItem && hoveredItem.name !== item.name;
    const notEnoughHovered = currencyAmount - hoveredCost < item.cost;
    const disabledDueToHovered = notSameItem && notEnoughHovered;
    const disabled = currencyAmount < item.cost || disabledDueToHovered;
    return {
      ...item,
      disabled,
    };
  });
  if (compactMode) {
    return (
      <Table>
        {items.map(item => (
          <Table.Row
            key={item.name}
            className="candystripe">
            <Table.Cell bold>
              {decodeHtmlEntities(item.name)}
            </Table.Cell>
            <Table.Cell collapsing textAlign="right">
              <Button
                fluid
                content={formatMoneyWithDiscount(item.cost, item.base_cost) + ' ' + currencySymbol}
                disabled={item.disabled}
                tooltip={item.desc}
                tooltipPosition="left"
                onmouseover={() => setHoveredItem(item)}
                onmouseout={() => setHoveredItem({})}
                onClick={() => act('buy', {
                  name: item.name,
                })} />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    );
  }
  return items.map(item => (
    <Section
      key={item.name}
      title={item.name}
      level={2}
      buttons={(
        <Button
          content={formatMoneyWithDiscount(item.cost, item.base_cost) + ' ' + currencySymbol}
          disabled={item.disabled}
          onmouseover={() => setHoveredItem(item)}
          onmouseout={() => setHoveredItem({})}
          onClick={() => act('buy', {
            name: item.name,
          })} />
      )}>
      {decodeHtmlEntities(item.desc)}
    </Section>
  ));
};
