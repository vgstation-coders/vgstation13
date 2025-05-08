// Copyright (c) 2020 /vg/station coders
// SPDX-License-Identifier: MIT

import { useState } from 'react';
import { Box, Button, Flex, Input, NoticeBox, Section, Tabs } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { createSearch, decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const MAX_SEARCH_RESULTS = 25;

type Item = {
  name: string,
  cost: number,
  desc: string,
  stock: number,
  path: string,
}

type Category = {
  name: string,
  items: Item[],
}

type Data = {
  categories: Category[]
}

export const Merch = (props, context) => {
  return (
    <Window
      width={822}
      height={580}
      theme="neutral">
      <Window.Content scrollable>
        <MerchUplink />
      </Window.Content>
    </Window>
  );
};

export const MerchUplink = (props) => {
  const {
    currencySymbol = 'credits',
  } = props;
  const { act, data } = useBackend<Data>();
  const {
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
  const testSearch = createSearch(searchText, (item: Item) => {
    return item.name + item.desc;
  });
  const items = searchText.length > 0
    // Flatten all categories and apply search to it
    && categories
      .flatMap(category => category.items || [])
      .filter(testSearch)
      .filter((item, i) => i < MAX_SEARCH_RESULTS)
    // Select a category and show all items in it
    || categories
      .find(category => category.name === selectedCategory)
      ?.items
    // If none of that results in a list, return an empty list
    || [];
  return (
    <Section
      title={"Merch"}
      buttons={(
        <>
          Search
          <Input
            autoFocus
            value={searchText}
            onInput={(e, value) => setSearchText(value)}
            mx={1} />
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
            currencySymbol={currencySymbol}
            items={items} />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const ItemList = (props) => {
  const {
    currencySymbol,
  } = props;
  const { act } = useBackend();
  return props.items.map(item => (
    <Section
      key={item.name}
      title={item.name}
      level={2}
      buttons={(
        <Box>
          {item.stock !== -1 ? `In stock: ${item.stock} ` : ""}
          <Button
            content={item.cost + ' ' + currencySymbol}
            disabled={item.stock === 0}
            onClick={() => act('buy', {
              name: item.name,
            })} />
        </Box>
      )}>
      <span
        className={classes([
          'merch32x32',
          item.path,
        ])}
        style={{
          'vertical-align': 'middle',
          'horizontal-align': 'middle',
        }} />
      {decodeHtmlEntities(item.desc)}
    </Section>
  ));
};
