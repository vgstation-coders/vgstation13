import { createSearch, decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox, Icon } from '../components';
import { Window } from '../layouts';

const MAX_SEARCH_RESULTS = 25;

export const Merch = (props, context) => {
  return (
    <Window
      width={800}
      height={475}>
      <Window.Content scrollable>
        <MerchUplink />
      </Window.Content>
    </Window>
  );
};

export const MerchUplink = (props, context) => {
  const {
    currencySymbol = 'cr',
  } = props;
  const { data } = useBackend(context);
  const {
    categories = [],
  } = data;
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');
  const [
    selectedCategory,
    setSelectedCategory,
  ] = useLocalState(context, 'category', categories[0]?.name);
  const testSearch = createSearch(searchText, item => {
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

const ItemList = (props, context) => {
  const {
    currencySymbol,
  } = props;
  const { act } = useBackend(context);
  return props.items.map(item => (
    <Section
      key={item.name}
      title={item.name}
      level={2}
      buttons={(
        <Button
          content={item.cost + ' ' + currencySymbol}
          onClick={() => act('buy', {
            name: item.name,
          })} />
      )}>
      {decodeHtmlEntities(item.desc)}
    </Section>
  ));
};
