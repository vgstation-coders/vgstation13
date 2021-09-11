import { useBackend, useSharedState } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section, Tabs,  } from '../components';
import { Window } from '../layouts';

export const RoboticsControlConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const { can_hack, sequence_activated, sequence_timeleft, cyborgs = [] } = data;
  return (
	<Window
	  width={500}
	  height={460}>
	  <Window.Content scrollable>
		<Tabs>
		  <Tabs.Tab
			icon='exclamation-triangle'
			lineHeight='23px'
			selected={tab === 2}
			onClick={() => setTab(1)}>
			Emergency Self-Destruct
		  </Tabs.Tab>
		  <Tabs.Tab
			icon='list'
			lineHeight='23px'
			selected={tab === 1}
			onClick={() => setTab(2)}>
			Cyborgs ({cyborgs.length})
		  </Tabs.Tab>
		</Tabs>
		{tab === 1 && (
		  <SelfDestruct sequence_activated={sequence_activated} sequence_timeleft={sequence_timeleft} />
		)}
		{tab === 2 && (
		   <Cyborgs cyborgs={cyborgs} can_hack={can_hack} />
		)}
	  </Window.Content>
	</Window>
  );
};

const Cyborgs = (props, context) => {
  const { cyborgs, can_hack } = props;
  const { act, data } = useBackend(context);
  if (!cyborgs.length) {
	return (
	  <NoticeBox>
		No cyborg units detected within access parameters.
	  </NoticeBox>
	);
  }
  return cyborgs.map(cyborg => {
	return (
	  <Section
		key={cyborg.ref}
		title={cyborg.name}
		buttons={(
		  <>
			{can_hack && !cyborg.emagged && (
			  <Button
				icon='terminal'
				content='Hack'
				color='bad'
				onClick={() => act('hack', {
				  robot: cyborg.ref,
				})} />
			)}
			<Button.Confirm
			  icon={cyborg.locked_down ? 'unlock' : 'lock'}
			  color={cyborg.locked_down ? 'good' : 'default'}
			  content={cyborg.locked_down ? 'Release' : 'Lockdown'}
			  onClick={() => act('lock', {
				ref: cyborg.ref,
			  })} />
			<Button.Confirm
			  icon='bomb'
			  content='Detonate'
			  color='bad'
			  onClick={() => act('killbot', {
				ref: cyborg.ref,
			  })} />
		  </>
		)}>
		<LabeledList>
		  <LabeledList.Item label='Status'>
			<Box color={cyborg.status
			  ? 'bad'
			  : cyborg.locked_down
				? 'average'
				: 'good'}>
			  {cyborg.status
				? 'Not Responding'
				: cyborg.locked_down
				  ? 'Locked Down'
				  : 'Nominal'}
			</Box>
		  </LabeledList.Item>
		  <LabeledList.Item label='Cell Charge'>
			<Box color={cyborg.charge <= 30
			  ? 'bad'
			  : cyborg.charge <= 70
				? 'average'
				: 'good'}>
			  {typeof cyborg.charge === 'number'
				? cyborg.charge + '%'
				: 'Not Found'}
			</Box>
		  </LabeledList.Item>
		  <LabeledList.Item label='Model'>
			{cyborg.module}
		  </LabeledList.Item>
		  <LabeledList.Item label='Slaved To'>
			<Box color={cyborg.master ? 'default' : 'average'}>
			  {cyborg.master || 'None'}
			</Box>
		  </LabeledList.Item>
		</LabeledList>
	  </Section>
	);
  });
};

const SelfDestruct = (props, context) => {
 	const { sequence_activated, sequence_timeleft } = props;
 	const { act } = useBackend(context);
  let minutes = Math.floor(sequence_activated/600)
  let seconds = Math.floor((sequence_timeleft-minutes*600)/10)

	return (
		<NoticeBox
			info={sequence_activated ? false : true}
			danger={sequence_activated ? true : false}
			textalign='center'>

			<Box as='span'>Cyborg Emergency Killswitch</Box>
      {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}
			<Button.Confirm
        icon='skull-crossbones'
        content={sequence_activated ? 'Activate' : 'Halt'}
        color={sequence_activated ? 'bad' : 'good'}
        onClick={() => act('sequence')} 
      />
		</NoticeBox>
	)

};