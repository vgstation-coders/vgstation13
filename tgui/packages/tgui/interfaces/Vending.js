import { useBackend } from '../backend';
import { Button, Table, Section, Box, Stack, Flex, NumberInput, Input, Tabs } from '../components';
import { Window } from '../layouts';

export const Vending = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    currently_vending,
    machine_name,
    has_premium,
    categories,
    edit_mode,
    ad
  } = data;

  let tabIndex = 1;
  let cat_array = [];
  for (let cat in categories) {
    cat_array.push(categories[cat])
  }

  return (
    <Window>
        <Window.Content>
          <Stack vertical fill>
            { (!edit_mode) && (!has_premium) && (!ad) ? (null) : (
              <Stack.Item><Flex nowrap align="center">
                { edit_mode ? (
                  <Flex.Item grow><Section>
                    <Input fluid value={machine_name}
                      onChange={(_e, value) => act("set_name", {"name" : value})} />
                  </Section></Flex.Item>
                ) : (
                  <Flex.Item grow><Section>
                    <Box bold as="marquee">{ad}</Box>
                  </Section></Flex.Item>
                )}

                { has_premium ? (<Flex.Item mx={2}><Button onClick={() =>
                  act('eject_coin')
                } disabled={!data.coin}>Eject Coin</Button></Flex.Item>) : (null)}
              </Flex></Stack.Item>
            )}

            <Stack.Item grow>
              { currently_vending != null ?
                (<Confirmation name={currently_vending.name} price={currently_vending.price} />) :
                (<ProductView categories={cat_array} />)}
            </Stack.Item>
          </Stack>
        </Window.Content>
    </Window>
  );
};

const Confirmation = (props, context) => {
  const { act } = useBackend(context);
  const { name, price } = props;

  return (
    <Section
      fill
      textAlign="center"
      title="Purchase">
        <Box>You have selected {name} ({price} credits).</Box>
        <Box>Please ensure your ID is in your ID holder or hand.</Box>
        <Box mt={2}>
          <Button mx={1} onClick={() => act("confirm")}>Buy</Button>
          <Button mx={1} onClick={() => act("cancel")}>Cancel</Button>
        </Box>
    </Section>
  );
}

const ProductView = (props, context) => {
  const { categories } = props;

  return (
    <Section
      fill scrollable
      title="Products">
        {!categories.length ?
          (<Box>No products loaded!</Box>) :
          (<Table>
            {categories.map(category =>
              <Section title={(category.name || '').replace(/^\w/, c => c.toUpperCase()) || null}>
                {category.items.map(item => <ItemRow item={item} />)}
              </Section>)}
          </Table>)}
    </Section>
  );
};

const ItemRow = (props, context) => {
  const CAT_NORMAL = 1;
  const CAT_HIDDEN = 2;
  const CAT_COIN   = 3;
  const CAT_VOUCH  = 4;
  const MAX_ITEM_PRICE = 1000000000;

  const { act, data } = useBackend(context);

  const {
    vend_ready, contraband, edit_mode, silicon, bypass, coin
  } = data;

  const {
    name, amount, price, category, icon, ref
  } = props.item;

  let hidden = ((category == CAT_COIN  ) && !coin)
            || ((category == CAT_HIDDEN) && !contraband)
            || ((category == CAT_VOUCH));
  if (hidden) return;

  let textPrice = category == CAT_COIN ? "coin" :
                  (!price ? "free" : price + ' credits');
  let disabled = (!vend_ready) || (silicon && (!bypass) && price != 0) || amount < 1;

  return (
    <Table.Row>
      <Table.Cell collapsing><img src={`data:image/jpeg;base64,${icon}`} style={{
        'vertical-align': 'middle',
        'horizontal-align': 'middle',
        'width': '32px',
        'margin': '0px',
        'padding': '0px',
      }} /></Table.Cell>

      <Table.Cell>{name.replace(/^\w/, c => c.toUpperCase())}</Table.Cell>

      <Table.Cell pr={0.4} collapsing textAlign="right">{amount} in stock</Table.Cell>

      { edit_mode ? (
        <Box pb={0.4} minWidth={4}>
          <Table.Cell pl={1} minWidth={4} collapsing>
            <NumberInput fluid minValue={0} maxValue={MAX_ITEM_PRICE}
              value={price || 0} onChange={(_e, value) =>
                act("set_price", {'item' : ref, 'price' : value})} />
          </Table.Cell>

          <Table.Cell collapsing>
            <Button onClick={() => act('delete_product', {'item' : ref})}
              fluid disabled={amount > 0}>Delete</Button>
          </Table.Cell>
        </Box>
      ) : (
        <Table.Cell pb={0.4} collapsing textAlign={ category != CAT_NORMAL ? "center" : "right" }>
          <Button onClick={() => {
            if (!price || bypass)
              act('dispense', {'item' : ref});
            else
              act('try_vend', {'item' : ref});
          }} fluid disabled={disabled}>{textPrice}</Button>
        </Table.Cell>
      )}
    </Table.Row>
  );
};
