// Copyright (c) 2021 /vg/station coders
// SPDX-License-Identifier: MIT

import { useBackend } from '../backend';
import { Button, NoticeBox, Collapsible } from '../components';
import { Window } from '../layouts';

export const MalfModules= (props, context) => {
  const { data } = useBackend(context);
  const { 
    modules = [],
  } = data;
  return (
    <Window
      width={460}
      height={360}>
      <Window.Content scrollable>
        <Modules modules={modules} />
      </Window.Content>
    </Window>
  );
};

const Modules = (props, context) => {
  const { modules } = props;
  const { act } = useBackend(context);
  if (!modules.length) {
    return (
      <NoticeBox>
        No modules available for purchase.
      </NoticeBox>
    );
  }
  return modules.map(module => {
    return ( 
      <Collapsible key={module.ref} title={module.name} color={module.bought ? 'good' : ''} buttons={( 
        <Button selected={module.bought} onClick={() => act('purchase', { ref: module.ref })}>
          {module.cost} PP
        </Button>
      )}>
        {module.desc}
      </Collapsible>   
    );
  });
};
