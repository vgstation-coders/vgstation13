// Copyright (c) 2021 /vg/station coders
// SPDX-License-Identifier: MIT

/* eslint-disable max-len */
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';
import { Dropdown, Popper, LabeledList, Box, Button, Flex, Input, Section, Stack } from '../components';
import { classes } from 'common/react';
import { createSearch } from 'common/string';

/**
 * Filters religions, applies search terms.
 */
export const selectReligions = (religions, searchText = '') => {
  if (searchText) {
    const testSearch = createSearch(searchText, religion => religion.name + religion.keywords?.join("") + religion.deityNames?.join(""));
    return religions.filter(testSearch);
  }
  return religions;
};

const isBlank = function (str) {
  return (!str || /^\s*$/.test(str));
};

const capitalize = (str) => {
  if (typeof str !== 'string') return '';
  return str.charAt(0).toUpperCase() + str.slice(1);
};

export const CustomReligion = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    chosenData,
    setChosenData,
  ] = useLocalState(context, "chosenData", {
    name: "Christianity",
    deityName: "God",
    bibleName: "The Bible",
    bibleStyle: "Bible",
  });
  const [iconMenuOpen, setIconMenuOpen] = useLocalState(context, "iconMenuOpen", false);
  const bibleStyles = data.bibleStyles;
  return (
    <Section title="Custom religion">
      <LabeledList>
        <LabeledList.Item key="Name" label="Name">
          <Button.Input
            defaultValue={chosenData.name}
            currentValue={chosenData.name}
            content={chosenData.name}
            onCommit={(_, value) => !isBlank(value)
              && setChosenData({ ...chosenData, name: value })} />
        </LabeledList.Item>
        <LabeledList.Item key="Deity name" label="Deity name">
          <Button.Input
            defaultValue={chosenData.deityName}
            currentValue={chosenData.deityName}
            content={chosenData.deityName}
            onCommit={(_, value) => !isBlank(value)
              && setChosenData({ ...chosenData, deityName: value })} />
        </LabeledList.Item>
        <LabeledList.Item key="Bible style" label="Bible style">
          <Popper popperContent={iconMenuOpen && (
            <Box width="200px" height={`${32*4}px`} backgroundColor="grey" padding="5px">
              <Stack vertical fill>
                <Stack.Item overflowX="hidden" overflowY="hidden">
                  <Flex wrap>
                    {bibleStyles.map(style => {
                      return (
                        <Flex.Item
                          key={style.name}
                          basis="39px">
                          <Button
                            tooltip={style.name}
                            tooltipPosition="right"
                            onClick={() => { setChosenData({
                              ...chosenData, bibleStyle: style.name,
                            }); setIconMenuOpen(false); }}>
                            <span
                              className={classes([
                                'bible32x32',
                                style.iconName,
                              ])}
                              style={{
                                'vertical-align': 'middle',
                                'horizontal-align': 'middle',
                              }} />
                          </Button>
                        </Flex.Item>);
                    })}
                  </Flex>
                </Stack.Item>
              </Stack>
            </Box>
          )} options={{
            placement: "right",
          }}>
            <Button
              onClick={() => setIconMenuOpen(!iconMenuOpen)}>
              <span
                className={classes([
                  'bible32x32',
                  bibleStyles.find(entry => entry.name === chosenData.bibleStyle)?.iconName || bibleStyles[0].iconName,
                ])}
                style={{
                  'vertical-align': 'middle',
                  'horizontal-align': 'middle',
                }} />
            </Button>
          </Popper>
        </LabeledList.Item>
        <LabeledList.Item key="Bible name" label="Bible name">
          <Button.Input
            defaultValue={chosenData.bibleName}
            currentValue={chosenData.bibleName}
            content={chosenData.bibleName}
            onCommit={(_, value) => !isBlank(value)
              && setChosenData({ ...chosenData, bibleName: value })} />
        </LabeledList.Item>
        <LabeledList.Item key="Job title" label="Job title">
          Chaplain
        </LabeledList.Item>
        <LabeledList.Item key="Conversion ritual" label="Conversion ritual">
          Splashing them with holy water, holding a bible in hand.
        </LabeledList.Item>
        <LabeledList.Item key="Preferred incense" label="Preferred incense">
          Harebells
        </LabeledList.Item>
        <LabeledList.Item key="Notes" label="Notes">
          This custom religion will have no special gear or other effect.
        </LabeledList.Item>
      </LabeledList>
      <Button
        lineHeight={2}
        mt={1}
        onClick={() => {
          act("choose", {
            custom: true,
            ...chosenData.name && { name: chosenData.name },
            ...chosenData.deityName && { deityName: chosenData.deityName },
            ...chosenData.bibleName && { bibleName: chosenData.bibleName },
            ...chosenData.bibleStyle && { bibleStyle: chosenData.bibleStyle },
          });
        }}>
        OK
      </Button>
    </Section>
  );
};

export const DefinedReligion = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    selectedReligion,
    setSelectedReligion,
  ] = useLocalState(context, "selectedReligion", data.religions.find(religion => religion.name === "Christianity"));
  const [
    selectedBible,
    setSelectedBible,
  ] = useLocalState(context, "selectedBible");
  const [
    selectedDeity,
    setSelectedDeity,
  ] = useLocalState(context, "selectedDeity");
  return (
    <Section title="Selected religion">
      {selectedReligion && (
        <LabeledList>
          <LabeledList.Item key="Name" label="Name">
            {selectedReligion.name}
          </LabeledList.Item>
          <LabeledList.Item key="Deity name" label="Deity name">
            {selectedReligion.possibleDeityNames?.length ? (
              <Dropdown
                width="200px"
                options={selectedReligion.possibleDeityNames}
                selected={selectedDeity || selectedReligion.deityName}
                onSelected={value => setSelectedDeity(value)} />
            ) : selectedReligion.deityName}
          </LabeledList.Item>
          <LabeledList.Item key="Sacred text" label="Sacred text">
            {selectedReligion.possibleBibleNames.length ? (
              <Dropdown
                width="200px"
                options={selectedReligion.possibleBibleNames}
                selected={selectedBible || selectedReligion.bibleName}
                onSelected={value => setSelectedBible(value)} />
            ) : selectedReligion.bibleName}
            <span
              className={classes([
                'bible32x32',
                selectedReligion.bibleStyleIcon,
              ])}
              style={{
                'vertical-align': 'middle',
                'horizontal-align': 'middle',
              }} />
          </LabeledList.Item>
          <LabeledList.Item key="Male adept" label="Male adept">
            {selectedReligion.maleAdept}
          </LabeledList.Item>
          <LabeledList.Item key="Female adept" label="Female adept">
            {selectedReligion.femaleAdept}
          </LabeledList.Item>
          <LabeledList.Item key="Conversion ritual" label="Conversion ritual">
            {capitalize(selectedReligion.convertMethod)}
          </LabeledList.Item>
          <LabeledList.Item key="Preferred incense" label="Preferred incense">
            {capitalize(selectedReligion.preferredIncense)}
          </LabeledList.Item>
          <LabeledList.Item key="Notes" label="Notes">
            {selectedReligion.notes}
          </LabeledList.Item>
        </LabeledList>
      )}
      <Button
        lineHeight={2}
        mt={1}
        onClick={() => {
          act("choose", {
            religionName: selectedReligion.name,
            deityName: selectedDeity || selectedReligion.deityName,
            bibleName: selectedBible || selectedReligion.bibleName,
          }); }}>
        OK
      </Button>
    </Section>);
};

export const ChooseReligion = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');
  const religions = selectReligions(data.religions, searchText);
  const [
    selectedReligion,
    setSelectedReligion,
  ] = useLocalState(context, "selectedReligion", religions.find(religion => religion.name === "Christianity"));
  const [
    useCustomReligion,
    setUseCustomReligion,
  ] = useLocalState(context, "useCustomReligion", false);
  return (
    <Window
      title="Choose a religion"
      width={800}
      height={340}>
      <Stack fill m={1}>
        <Stack.Item height="100%" width="50%">
          <Flex height="100%" width="100%"
            direction={"column"}>
            <Flex.Item>
              <Button
                selected={useCustomReligion}
                onClick={() => setUseCustomReligion(!useCustomReligion)}
                textAlign="center" width="100%">
                Create a custom religion
              </Button>
            </Flex.Item>
            <Flex.Item>
              {!useCustomReligion && (
                <Input
                  autoFocus
                  fluid
                  mt={1}
                  placeholder="Search for a religion or deity"
                  onInput={(_, value) => setSearchText(value)} />
              )}
            </Flex.Item>
            <Flex.Item height="100%">
              {!useCustomReligion &&(
                <Section
                  fill scrollable>
                  {religions.map(religion => (
                  // We're not using the component here because performance
                  // would be absolutely abysmal (50+ ms for each re-render).
                    <div
                      key={religion.name}
                      title={religion.name}
                      className={classes([
                        'Button',
                        'Button--fluid',
                        'Button--color--transparent',
                        'Button--ellipsis',
                        selectedReligion
                && religion.name === selectedReligion.name
                && 'Button--selected',
                      ])}
                      onClick={() => { setSelectedReligion(religion); }}>
                      {religion.name}
                    </div>
                  ))}
                </Section>)}
            </Flex.Item>
          </Flex>
        </Stack.Item>
        <Stack.Item width="100%">
          <Box>
            {useCustomReligion ? <CustomReligion /> : <DefinedReligion />}
          </Box>
        </Stack.Item>
      </Stack>
    </Window>
  );
};
