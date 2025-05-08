// Copyright (c) 2021 /vg/station coders
// SPDX-License-Identifier: MIT

import { filter, sort } from 'common/collections';
import { useState } from 'react';
import { Box, Button, Dropdown, Flex, Input, LabeledList, NoticeBox, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  religions: Religion[];
  bibleStyles: BibleStyle[];
};

type BibleStyle = {
  name: string;
  iconName: string;
};

type Religion = {
  name: string;
  keywords: string[];
  deityName: string;
  bibleName: string;
  bibleStyle: string;
  bibleStyleIcon: string;
  maleAdept: string;
  femaleAdept: string;
  convertMethod: string;
  possibleBibleNames: string[];
  possibleDeityName: string[];
  preferredIncense: string;
  notes: string;
};

/**
 * Filters religions, applies search terms.
 */
export const selectReligions = (religions: Religion[], searchText = ''): Religion[] => {
  if (searchText) {
      const testSearch = createSearch(
        searchText,
        (religion: Religion) =>
        [religion.name,
        (religion.keywords || [])].join(' ')
      );
    religions = filter(religions, testSearch);
    religions = sort(religions);
    return religions;
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

export const ChooseReligion = (props) => {
  const { act, data } = useBackend<Data>();
  const [useCustomReligion, setUseCustomReligion] = useState("useCustomReligion", false);
  const [searchText, setSearchText] = useState("");
  const [selectedReligion, setSelectedReligion] = useState<Religion | null>(null);
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
                {useCustomReligion ? "Use the defined religion list instead" : "Create a custom religion"}
              </Button>
            </Flex.Item>
          <Flex.Item grow>
          {useCustomReligion ? "" :
          <DefinedReligionSelector
              searchText={searchText}
              setSearchText={setSearchText}
              selectedReligion={selectedReligion}
              setSelectedReligion={setSelectedReligion}
            />
          }
          </Flex.Item>
          </Flex>
        </Stack.Item>
        <Stack.Item width="100%">
          <Box>
            {useCustomReligion ? <CustomReligion /> : <DefinedReligionData religion={selectedReligion} />}
          </Box>
        </Stack.Item>
      </Stack>
    </Window>
  );
};

export const DefinedReligionSelector = ({
  searchText,
  setSearchText,
  selectedReligion,
  setSelectedReligion,
}) => {
  const { data } = useBackend<Data>();
  const religions = selectReligions(data.religions, searchText);

  return (
    <Stack fill>
      <Stack.Item grow>
        <Input
          autoFocus
          expensive
          fluid
          mt={1}
          placeholder="Search for a religion"
          onInput={(e, value) => setSearchText(value)}
          value={searchText}
        />
        <Section fill scrollable>
          {religions.map((religion) => (
            <div
              key={religion.name}
              title={religion.name}
              className={classes([
                'Button',
                'Button--fluid',
                'Button--color--transparent',
                'Button--ellipsis',
                selectedReligion?.name === religion.name
                  ? 'Button--selected'
                  : 'candystripe',
              ])}
              onClick={() => setSelectedReligion(religion)}
            >
              {religion.name}
            </div>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const DefinedReligionData = ({ religion }) => {
  const { act, data } = useBackend<Data>();
  const [
    selectedBible,
    setSelectedBible,
  ] = useState("");
  const [
    selectedDeity,
    setSelectedDeity,
  ] = useState("");
  if (!religion) {
    return <NoticeBox>Select a religion to see details.</NoticeBox>;
  }

  return (
    <Section title="Selected religion">
      {religion && (
        <LabeledList>
          <LabeledList.Item key="Name" label="Name">
            {religion.name}
          </LabeledList.Item>
          <LabeledList.Item key="Deity name" label="Deity name">
            {religion.possibleDeityNames?.length ? (
              <Dropdown
                width="200px"
                options={religion.possibleDeityNames}
                selected={religion.possibleDeityNames.includes(selectedDeity) ?
                  selectedDeity :
                  religion.possibleDeityNames
                }
                onSelected={value => setSelectedDeity(value)}
                onCommit={value => setSelectedDeity(value)}
                />
            ) : religion.deityName}
          </LabeledList.Item>
          <LabeledList.Item key="Sacred text" label="Sacred text">
            {religion.possibleBibleNames.length ? (
              <Dropdown
                width="200px"
                options={religion.possibleBibleNames}
                selected={religion.possibleBibleNames.includes(selectedBible) ?
                  selectedBible :
                  religion.possibleBibleNames
                }
                onSelected={value => setSelectedBible(value)}
                onCommit={value => setSelectedBible(value)} />
            ) : religion.bibleName}
            <span
              className={classes([
                'bible32x32',
                religion.bibleStyleIcon,
              ])}
              style={{
                'vertical-align': 'middle',
                'display': 'inline-block',
              }} />
          </LabeledList.Item>
          <LabeledList.Item key="Male adept" label="Male adept">
            {religion.maleAdept}
          </LabeledList.Item>
          <LabeledList.Item key="Female adept" label="Female adept">
            {religion.femaleAdept}
          </LabeledList.Item>
          <LabeledList.Item key="Conversion ritual" label="Conversion ritual">
            {capitalize(religion.convertMethod)}
          </LabeledList.Item>
          <LabeledList.Item key="Preferred incense" label="Preferred incense">
            {capitalize(religion.preferredIncense)}
          </LabeledList.Item>
          <LabeledList.Item key="Notes" label="Notes">
            {religion.notes}
          </LabeledList.Item>
        </LabeledList>
      )}
      <Button
        lineHeight={2}
        mt={1}
        onClick={() => {
          act("choose", {
            religionName: religion.name,
            deityName: selectedDeity || religion.deityName,
            bibleName: selectedBible || religion.bibleName,
          }); }}>
        OK
      </Button>
    </Section>);
};

export const CustomReligion = () => {
  const { act, data } = useBackend<Data>();
  const bibleStyles = data.bibleStyles;
  const [iconMenuOpen, setIconMenuOpen] = useState(false);
  const [
    chosenData,
    setChosenData,
  ] = useState("chosenData", {
    name: "Christianity",
    deityName: "God",
    bibleName: "The Bible",
    bibleStyle: "Bible",
  });
  return (
    <Section title="Create custom Religion">
        <LabeledList>
          <LabeledList.Item key="Name" label="Name">
          <Input
          autoFocus
          expensive
          fluid
          mt={1}
          placeholder="Christianity"
          onCommit={(_, value) => !isBlank(value)
            && setChosenData({ ...chosenData, name: value })}
          onInput={(_, value) => !isBlank(value)
            && setChosenData({ ...chosenData, name: value })}
          value={chosenData.name}
        />
          </LabeledList.Item>
          <LabeledList.Item key="Deity name" label="Deity name">
          <Input
          fluid
          mt={1}
          placeholder="Space Jesus"
          onCommit={(_, value) => !isBlank(value)
            && setChosenData({ ...chosenData, deityName: value })}
          onInput={(_, value) => !isBlank(value)
            && setChosenData({ ...chosenData, deityName: value })}
          value={chosenData.deityName}
        />
          </LabeledList.Item>
          <LabeledList.Item key="Sacred text" label="Sacred text">
          <Input
          fluid
          mt={1}
          placeholder="Holy Bible"
          onCommit={(_, value) => !isBlank(value)
            && setChosenData({ ...chosenData, bibleName: value })}
          onInput={(_, value) => !isBlank(value)
            && setChosenData({ ...chosenData, bibleName: value })}
          value={chosenData.bibleName}
        />
            <LabeledList.Item key="Bible style" label="Bible style">
              {iconMenuOpen ?
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
              </Box> : ""}
                <Button
                  onClick={() => setIconMenuOpen(iconMenuOpen => !iconMenuOpen)}>
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
            </LabeledList.Item>
          </LabeledList.Item>
          <LabeledList.Item key="Male adept" label="Male adept">
            Chaplain
          </LabeledList.Item>
          <LabeledList.Item key="Female adept" label="Female adept">
            Chaplain
          </LabeledList.Item>
          <LabeledList.Item key="Conversion ritual" label="Conversion ritual">
           Splashing them with holy water, holding a bible in hand.
          </LabeledList.Item>
          <LabeledList.Item key="Preferred incense" label="Preferred incense">
           Harbells
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
