// Bridge-console replacement for the shuttle control's HTML interface.
// Backend: code/game/machinery/computer/shuttle_computers.dm

import { useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  LabeledList,
  Modal,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Destination = {
  ref: string;
  name: string;
  occupied: number;
  selected: number;
};

type DiskFreeMove = {
  kind: 'freemove';
  header: string;
  custom_x: number;
  custom_y: number;
  custom_z: number;
  custom_rot: number;
  dest_name?: string;
};

type DiskProcedural = {
  kind: 'procedural';
  header: string;
  compatible: number;
  target_label?: string;
  target_kind?: 'planet' | 'encounter';
  selected: number;
};

type DiskFixed = {
  kind: 'fixed';
  header: string;
  compatible: number;
  dest_ref?: string;
  dest_name?: string;
  dest_occupied?: number;
  selected?: number;
};

type DiskInfo = DiskFreeMove | DiskProcedural | DiskFixed;

type DockRequest = {
  is_initiator: number;
  other_name: string;
  mode: 'in_place' | 'rendezvous';
  secs_left: number;
  timeout_seconds: number;
};

type ShuttleRef = {
  name: string;
  ref: string;
  needs_password?: number;
};

type PortRef = {
  name: string;
  ref: string;
};

type Phase =
  | 'idle'
  | 'warmup'
  | 'transit'
  | 'cooldown'
  | 'awaiting_dock'
  | 'bs_warmup'
  | 'bs_jump'
  | 'lockdown';

type Data = {
  is_admin: number;
  is_silicon: number;
  allow_selecting_all: number;
  allow_silicons: number;
  console_name: string;

  has_shuttle: number;
  shuttle_name?: string;
  lockdown?: number;
  lockdown_reason?: string | null;
  moving?: number;
  has_linked_area?: number;
  destination_areaname?: string | null;
  current_areaname?: string | null;
  cooldown_seconds_left?: number;

  phase?: Phase;
  phase_seconds_left?: number;
  phase_seconds_total?: number;

  selected_ref?: string | null;
  procgen_target?: string | null;

  destinations?: Destination[];
  disk?: DiskInfo | null;

  dock_request?: DockRequest | null;
  dockable_now?: number;
  dock_targets?: ShuttleRef[];

  available_shuttles?: ShuttleRef[];
  admin_available_shuttles?: ShuttleRef[] | null;
  internal_ports?: PortRef[];
};

const PHASE_LABELS: Record<Phase, string> = {
  idle: 'IDLE',
  warmup: 'WARMUP',
  transit: 'IN TRANSIT',
  cooldown: 'COOLDOWN',
  awaiting_dock: 'AWAITING DOCK',
  bs_warmup: 'BLUESPACE WARMUP',
  bs_jump: 'BLUESPACE JUMP',
  lockdown: 'LOCKED DOWN',
};

const PHASE_COLORS: Record<Phase, string> = {
  idle: 'good',
  warmup: 'average',
  transit: 'average',
  cooldown: 'average',
  awaiting_dock: 'average',
  bs_warmup: 'bad',
  bs_jump: 'bad',
  lockdown: 'bad',
};

type ModalKind =
  | null
  | 'link_shuttle'
  | 'admin_link_shuttle'
  | 'link_port'
  | 'dock_request'
  | 'reject_reason'
  | 'lockdown_reason'
  | { kind: 'password'; ref: string; name: string };

export const ShuttleControl = (_props) => {
  const { data } = useBackend<Data>();
  const [activeModal, setActiveModal] = useState<ModalKind>(null);

  return (
    <Window width={620} height={520}>
      <Window.Content scrollable>
        <StatusBanner />
        {data.has_shuttle ? (
          <ShuttleBody activeModal={activeModal} setActiveModal={setActiveModal} />
        ) : (
          <NoShuttle setActiveModal={setActiveModal} />
        )}
        {!!data.is_admin && (
          <AdminPanel setActiveModal={setActiveModal} />
        )}
        <ModalLayer activeModal={activeModal} setActiveModal={setActiveModal} />
      </Window.Content>
    </Window>
  );
};

// -----------------------------------------------------------------------
// Status banner
// -----------------------------------------------------------------------

const StatusBanner = (_props) => {
  const { data } = useBackend<Data>();
  if (!data.has_shuttle) {
    return (
      <Section>
        <Flex align="center" justify="space-between">
          <Flex.Item bold fontSize="16px">{data.console_name}</Flex.Item>
          <Flex.Item color="bad">No shuttle linked</Flex.Item>
        </Flex>
      </Section>
    );
  }

  const phase: Phase = !data.has_linked_area
    ? 'lockdown' // treat missing hull as lockdown for the badge
    : (data.phase || 'idle');
  const label = !data.has_linked_area ? 'NO HULL' : PHASE_LABELS[phase];
  const color = PHASE_COLORS[phase];
  const showTrip
    = (phase === 'warmup' || phase === 'transit')
    && (data.phase_seconds_total || 0) > 0;
  const showCooldown = phase === 'cooldown' && (data.phase_seconds_total || 0) > 0;
  const showBsTimer = (phase === 'bs_warmup' || phase === 'bs_jump')
    && (data.phase_seconds_left || 0) > 0;
  const total = data.phase_seconds_total || 1;
  const left = data.phase_seconds_left || 0;
  const elapsed = Math.max(total - left, 0);

  return (
    <Section>
      <Flex align="center" justify="space-between">
        <Flex.Item bold fontSize="18px">
          {data.shuttle_name?.toUpperCase()}
        </Flex.Item>
        <Flex.Item>
          <Box
            inline
            backgroundColor={color}
            color="black"
            px={1}
            mr={1}
            style={{
              borderRadius: '2px',
              fontWeight: 'bold',
              letterSpacing: '1px',
            }}>
            {label}
          </Box>
          <Box inline color="label">Location:</Box>{' '}
          <Box inline bold>
            {data.current_areaname || (
              <Box inline color="bad">unknown</Box>
            )}
          </Box>
        </Flex.Item>
      </Flex>
      {phase === 'lockdown' && !!data.lockdown_reason && (
        <NoticeBox danger mt={1}>
          {data.lockdown_reason}
        </NoticeBox>
      )}
      {showTrip && (
        <Box mt={1}>
          <ProgressBar
            value={elapsed}
            minValue={0}
            maxValue={total}
            color={phase === 'warmup' ? 'average' : 'good'}>
            {data.destination_areaname
              ? `${data.destination_areaname} (${elapsed}s / ${total}s)`
              : `${elapsed}s / ${total}s`}
          </ProgressBar>
        </Box>
      )}
      {showCooldown && (
        <Box mt={1}>
          <ProgressBar
            value={elapsed}
            minValue={0}
            maxValue={total}
            color="average">
            Cooldown ({left}s)
          </ProgressBar>
        </Box>
      )}
      {showBsTimer && (
        <Box mt={1}>
          <ProgressBar
            value={elapsed}
            minValue={0}
            maxValue={total}
            color="bad">
            {phase === 'bs_jump' ? 'Jump' : 'Warmup'} ({left}s)
          </ProgressBar>
        </Box>
      )}
    </Section>
  );
};

// -----------------------------------------------------------------------
// No shuttle linked
// -----------------------------------------------------------------------

const NoShuttle = ({ setActiveModal }) => {
  return (
    <Section title="Console">
      <Button
        icon="link"
        content="Link to a shuttle"
        onClick={() => setActiveModal('link_shuttle')}
      />
    </Section>
  );
};

// -----------------------------------------------------------------------
// Main body when shuttle is linked
// -----------------------------------------------------------------------

const ShuttleBody = ({ activeModal, setActiveModal }) => {
  const { data } = useBackend<Data>();
  if (data.lockdown || !data.has_linked_area) {
    // Lockdown banner is in the status section already; nothing else to show.
    return null;
  }
  return (
    <>
      <DestinationsPanel setActiveModal={setActiveModal} />
      <DiskPanel />
      <DockRequestPanel setActiveModal={setActiveModal} />
    </>
  );
};

// -----------------------------------------------------------------------
// Destinations
// -----------------------------------------------------------------------

const DestinationsPanel = ({ setActiveModal }) => {
  const { act, data } = useBackend<Data>();
  const destinations = data.destinations || [];
  const moving = !!data.moving;
  const cd = data.cooldown_seconds_left || 0;
  const hasTarget = !!(data.selected_ref || data.procgen_target);
  const sendDisabled = moving || cd > 0 || !hasTarget;

  let sendLabel = 'Send';
  if (data.procgen_target) {
    sendLabel = `Send to ${data.procgen_target} surface`;
  } else if (data.selected_ref && destinations.length) {
    const sel = destinations.find((d) => d.ref === data.selected_ref);
    if (sel) sendLabel = `Send to ${sel.name}`;
    else if (data.disk?.kind === 'fixed' && data.disk.dest_ref === data.selected_ref) {
      sendLabel = `Send to ${data.disk.dest_name}`;
    }
  }

  return (
    <Section
      title="Destinations"
      buttons={
        <Button
          icon="search"
          content="Scan ports"
          onClick={() => setActiveModal('link_port')}
        />
      }>
      {destinations.length === 0 && !data.disk && (
        <NoticeBox>No destinations available.</NoticeBox>
      )}
      <Stack vertical>
        {destinations.map((d) => (
          <Stack.Item key={d.ref}>
            <DestinationRow
              dest={d}
              onSelect={() => act('select_port', { ref: d.ref })}
            />
          </Stack.Item>
        ))}
        {data.disk?.kind === 'fixed' && data.disk.dest_ref && (
          <Stack.Item>
            <DiskDestinationRow disk={data.disk} />
          </Stack.Item>
        )}
        {data.disk?.kind === 'procedural'
          && !!data.disk.compatible
          && data.disk.target_label && (
          <Stack.Item>
            <ProceduralRow disk={data.disk} />
          </Stack.Item>
        )}
      </Stack>
      <Box mt={1} textAlign="center">
        <Button
          fluid
          color={sendDisabled ? undefined : 'good'}
          icon="paper-plane"
          content={sendLabel}
          disabled={sendDisabled}
          onClick={() => act('move')}
        />
      </Box>
    </Section>
  );
};

const DestinationRow = ({ dest, onSelect }) => {
  if (dest.occupied) {
    return (
      <Box color="label">
        <Icon name="ban" /> {dest.name}{' '}
        <Box inline italic color="bad">(occupied)</Box>
      </Box>
    );
  }
  return (
    <Button
      fluid
      selected={!!dest.selected}
      icon={dest.selected ? 'crosshairs' : 'circle'}
      content={dest.name}
      onClick={onSelect}
    />
  );
};

const DiskDestinationRow = ({ disk }) => {
  const { act } = useBackend<Data>();
  if (!disk.compatible) {
    return (
      <Box color="bad">
        <Icon name="exclamation-triangle" /> Disk{' '}
        <Box inline bold>{disk.header}</Box>: encryption mismatch
      </Box>
    );
  }
  if (disk.dest_occupied) {
    return (
      <Box color="label">
        <Icon name="hdd" /> Disk: {disk.dest_name}{' '}
        <Box inline italic color="bad">(occupied)</Box>
      </Box>
    );
  }
  return (
    <Button
      fluid
      selected={!!disk.selected}
      icon="hdd"
      content={`Disk: ${disk.dest_name}`}
      onClick={() => disk.dest_ref && act('select_port', { ref: disk.dest_ref })}
    />
  );
};

const ProceduralRow = ({ disk }) => {
  const { act } = useBackend<Data>();
  return (
    <Button
      fluid
      selected={!!disk.selected}
      icon={disk.target_kind === 'planet' ? 'globe' : 'star'}
      content={`Disk: ${disk.target_label}`}
      onClick={() => act('select_procedural')}
    />
  );
};

// -----------------------------------------------------------------------
// Disk panel
// -----------------------------------------------------------------------

const DiskPanel = (_props) => {
  const { act, data } = useBackend<Data>();
  const disk = data.disk;

  return (
    <Section
      title="Disk"
      buttons={
        disk ? (
          <Button.Confirm
            icon="eject"
            content="Eject"
            confirmContent="Eject?"
            onClick={() => act('eject_disk')}
          />
        ) : (
          <Button
            icon="hdd"
            content="Insert"
            onClick={() => act('eject_disk')}
          />
        )
      }>
      {!disk && (
        <Box color="label">No disk.</Box>
      )}
      {disk?.kind === 'fixed' && (
        <LabeledList>
          <LabeledList.Item label="Header">{disk.header}</LabeledList.Item>
          {!!disk.dest_name && (
            <LabeledList.Item label="Destination">
              {disk.compatible ? disk.dest_name : (
                <Box color="bad">Encryption mismatch</Box>
              )}
            </LabeledList.Item>
          )}
        </LabeledList>
      )}
      {disk?.kind === 'procedural' && (
        <LabeledList>
          <LabeledList.Item label="Header">{disk.header}</LabeledList.Item>
          {!!disk.target_label && (
            <LabeledList.Item label={disk.target_kind === 'planet' ? 'Landing site' : 'Encounter'}>
              {disk.compatible ? disk.target_label : (
                <Box color="bad">Unable to read coordinates</Box>
              )}
            </LabeledList.Item>
          )}
        </LabeledList>
      )}
      {disk?.kind === 'freemove' && <FreeMovePanel disk={disk} />}
    </Section>
  );
};

const FreeMovePanel = ({ disk }) => {
  const { act } = useBackend<Data>();
  return (
    <>
      <LabeledList>
        <LabeledList.Item label="X drift">
          <NumberInput
            value={disk.custom_x}
            minValue={-9999}
            maxValue={9999}
            step={1}
            stepPixelSize={4}
            width="6em"
            onChange={(value) => act('set_custom_coord', { axis: 'x', value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Y drift">
          <NumberInput
            value={disk.custom_y}
            minValue={-9999}
            maxValue={9999}
            step={1}
            stepPixelSize={4}
            width="6em"
            onChange={(value) => act('set_custom_coord', { axis: 'y', value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Z destination">
          <NumberInput
            value={disk.custom_z}
            minValue={-99}
            maxValue={99}
            step={1}
            stepPixelSize={6}
            width="6em"
            onChange={(value) => act('set_custom_coord', { axis: 'z', value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Rotation (deg)">
          <NumberInput
            value={disk.custom_rot}
            minValue={0}
            maxValue={359}
            step={1}
            stepPixelSize={2}
            width="6em"
            onChange={(value) => act('set_custom_coord', { axis: 'rot', value })}
          />
        </LabeledList.Item>
      </LabeledList>
      <Box mt={1}>
        <Button
          icon="calculator"
          content="Calculate course"
          onClick={() => act('process_custom_coord')}
        />
        {!!disk.dest_name && (
          <Box inline ml={1} color="label">
            Last calc: <Box inline bold>{disk.dest_name}</Box>
          </Box>
        )}
      </Box>
    </>
  );
};

// -----------------------------------------------------------------------
// Dock-request panel
// -----------------------------------------------------------------------

const DockRequestPanel = ({ setActiveModal }) => {
  const { act, data } = useBackend<Data>();
  const req = data.dock_request;

  if (req) {
    if (req.is_initiator) {
      return (
        <Section title="Outbound dock request">
          <Flex align="center">
            <Flex.Item grow={1}>
              <Box>
                Waiting on <Box inline bold>{req.other_name}</Box>
              </Box>
              <Box mt={0.5}>
                <ProgressBar
                  value={req.secs_left}
                  minValue={0}
                  maxValue={req.timeout_seconds}
                  color={req.secs_left < 10 ? 'bad' : 'average'}>
                  {req.secs_left}s
                </ProgressBar>
              </Box>
            </Flex.Item>
            <Flex.Item ml={1}>
              <Button.Confirm
                icon="ban"
                color="bad"
                content="Cancel"
                confirmContent="Cancel?"
                onClick={() => act('dock_request_cancel')}
              />
            </Flex.Item>
          </Flex>
        </Section>
      );
    }
    // Target side
    const modeLabel = req.mode === 'rendezvous' ? 'rendezvous' : 'in-place';
    return (
      <Section title="Incoming dock request">
        <Box>
          <Box inline bold>{req.other_name}</Box> ({modeLabel})
        </Box>
        <Flex align="center" mt={1}>
          <Flex.Item grow={1}>
            <ProgressBar
              value={req.secs_left}
              minValue={0}
              maxValue={req.timeout_seconds}
              color={req.secs_left < 10 ? 'bad' : 'good'}>
              {req.secs_left}s
            </ProgressBar>
          </Flex.Item>
          <Flex.Item ml={1}>
            <Button
              icon="check"
              color="good"
              content="Accept"
              onClick={() => act('dock_request_accept')}
            />
            <Button
              icon="times"
              color="bad"
              content="Reject"
              onClick={() => setActiveModal('reject_reason')}
            />
          </Flex.Item>
        </Flex>
      </Section>
    );
  }

  // Idle: no request open.
  const targets = data.dock_targets || [];
  const dockableNow = !!data.dockable_now;
  return (
    <Section title="Dock request">
      <Button
        icon="handshake"
        content="Request docking"
        disabled={!dockableNow || targets.length === 0}
        onClick={() => setActiveModal('dock_request')}
      />
    </Section>
  );
};

// -----------------------------------------------------------------------
// Admin panel
// -----------------------------------------------------------------------

const AdminPanel = ({ setActiveModal }) => {
  const { act, data } = useBackend<Data>();
  const [open, setOpen] = useState(false);
  return (
    <Section
      title={
        <Box color="bad">
          <Icon name="user-shield" /> Admin tools
        </Box>
      }
      buttons={
        <Button
          icon={open ? 'chevron-up' : 'chevron-down'}
          content={open ? 'Hide' : 'Show'}
          onClick={() => setOpen(!open)}
        />
      }>
      {open && (
        <Stack vertical>
          <Stack.Item>
            <Button
              icon="link"
              content="Link any shuttle"
              onClick={() => setActiveModal('admin_link_shuttle')}
            />
            {!!data.has_shuttle && (
              <Button.Confirm
                ml={1}
                icon="unlink"
                content="Unlink"
                confirmContent="Unlink?"
                onClick={() => act('admin_unlink_shuttle')}
              />
            )}
          </Stack.Item>
          {!!data.has_shuttle && (
            <Stack.Item>
              <Button
                icon={data.lockdown ? 'lock-open' : 'lock'}
                color={data.lockdown ? 'good' : 'bad'}
                content={data.lockdown ? 'Lift lockdown' : 'Lock down'}
                onClick={() => {
                  if (data.lockdown) {
                    act('admin_toggle_lockdown');
                  } else {
                    setActiveModal('lockdown_reason');
                  }
                }}
              />
              <Button
                ml={1}
                icon={data.allow_selecting_all ? 'filter' : 'globe'}
                content={
                  data.allow_selecting_all
                    ? 'Restrict to shuttle ports'
                    : 'Allow any port'
                }
                onClick={() => act('admin_toggle_select_all')}
              />
              <Button
                ml={1}
                icon={data.allow_silicons ? 'robot' : 'ban'}
                content={
                  data.allow_silicons ? 'Forbid silicons' : 'Allow silicons'
                }
                onClick={() => act('admin_toggle_silicon_use')}
              />
              <Button.Confirm
                ml={1}
                icon="undo"
                content="Reset destinations"
                confirmContent="Reset?"
                onClick={() => act('admin_reset')}
              />
            </Stack.Item>
          )}
        </Stack>
      )}
    </Section>
  );
};

// -----------------------------------------------------------------------
// Modals
// -----------------------------------------------------------------------

const ModalLayer = ({ activeModal, setActiveModal }) => {
  const { act, data } = useBackend<Data>();
  const close = () => setActiveModal(null);

  if (!activeModal) return null;

  if (typeof activeModal === 'object' && activeModal.kind === 'password') {
    return (
      <PasswordModal
        targetName={activeModal.name}
        onCancel={close}
        onSubmit={(password) => {
          act('link_to_shuttle', { ref: activeModal.ref, password });
          close();
        }}
      />
    );
  }

  switch (activeModal) {
    case 'link_shuttle':
      return (
        <ShuttlePickerModal
          title="Link to a shuttle"
          shuttles={data.available_shuttles || []}
          onCancel={close}
          onSelect={(s) => {
            if (s.needs_password) {
              setActiveModal({ kind: 'password', ref: s.ref, name: s.name });
            } else {
              act('link_to_shuttle', { ref: s.ref });
              close();
            }
          }}
        />
      );
    case 'admin_link_shuttle':
      return (
        <ShuttlePickerModal
          title="Admin: link to a shuttle"
          shuttles={data.admin_available_shuttles || []}
          onCancel={close}
          onSelect={(s) => {
            act('admin_link_to_shuttle', { ref: s.ref });
            close();
          }}
        />
      );
    case 'link_port':
      return (
        <PortPickerModal
          ports={data.internal_ports || []}
          onCancel={close}
          onSelect={(p) => {
            act('link_to_port', { ref: p.ref });
            close();
          }}
        />
      );
    case 'dock_request':
      return (
        <ShuttlePickerModal
          title="Request docking"
          shuttles={data.dock_targets || []}
          onCancel={close}
          onSelect={(s) => {
            act('dock_request_open', { ref: s.ref });
            close();
          }}
        />
      );
    case 'reject_reason':
      return (
        <TextEntryModal
          title="Reject docking request"
          prompt="Reason for rejection (optional):"
          confirmLabel="Reject"
          onCancel={close}
          onSubmit={(reason) => {
            act('dock_request_reject', { reason });
            close();
          }}
        />
      );
    case 'lockdown_reason':
      return (
        <TextEntryModal
          title="Lock down shuttle"
          prompt={`Reason for locking down ${data.shuttle_name} (optional):`}
          confirmLabel="Lock down"
          onCancel={close}
          onSubmit={(reason) => {
            act('admin_toggle_lockdown', { reason });
            close();
          }}
        />
      );
    default:
      return null;
  }
};

const ShuttlePickerModal = ({ title, shuttles, onCancel, onSelect }) => {
  return (
    <Modal>
      <Section
        title={title}
        buttons={<Button icon="times" content="Cancel" onClick={onCancel} />}>
        {shuttles.length === 0 ? (
          <NoticeBox>No shuttles available.</NoticeBox>
        ) : (
          <Stack vertical>
            {shuttles.map((s: ShuttleRef) => (
              <Stack.Item key={s.ref}>
                <Button
                  fluid
                  icon={s.needs_password ? 'key' : 'rocket'}
                  content={
                    s.needs_password ? `${s.name} (password required)` : s.name
                  }
                  onClick={() => onSelect(s)}
                />
              </Stack.Item>
            ))}
          </Stack>
        )}
      </Section>
    </Modal>
  );
};

const PortPickerModal = ({ ports, onCancel, onSelect }) => {
  return (
    <Modal>
      <Section
        title="Select internal port"
        buttons={<Button icon="times" content="Cancel" onClick={onCancel} />}>
        {ports.length === 0 ? (
          <NoticeBox>No internal docking ports detected.</NoticeBox>
        ) : (
          <Stack vertical>
            {ports.map((p: PortRef) => (
              <Stack.Item key={p.ref}>
                <Button
                  fluid
                  icon="anchor"
                  content={p.name}
                  onClick={() => onSelect(p)}
                />
              </Stack.Item>
            ))}
          </Stack>
        )}
      </Section>
    </Modal>
  );
};

const PasswordModal = ({ targetName, onCancel, onSubmit }) => {
  const [value, setValue] = useState('');
  return (
    <Modal>
      <Section
        title={`Password for ${targetName}`}
        buttons={<Button icon="times" content="Cancel" onClick={onCancel} />}>
        <Box mb={1}>Enter the interface password:</Box>
        <Input
          autoFocus
          value={value}
          placeholder="00000"
          onChange={(v) => setValue(v)}
          onEnter={() => onSubmit(value)}
        />
        <Box mt={1}>
          <Button
            icon="check"
            color="good"
            content="Submit"
            onClick={() => onSubmit(value)}
          />
        </Box>
      </Section>
    </Modal>
  );
};

const TextEntryModal = ({ title, prompt, confirmLabel, onCancel, onSubmit }) => {
  const [value, setValue] = useState('');
  return (
    <Modal>
      <Section
        title={title}
        buttons={<Button icon="times" content="Cancel" onClick={onCancel} />}>
        <Box mb={1}>{prompt}</Box>
        <Input
          autoFocus
          value={value}
          width="22em"
          onChange={(v) => setValue(v)}
          onEnter={() => onSubmit(value)}
        />
        <Box mt={1}>
          <Button
            icon="check"
            content={confirmLabel}
            onClick={() => onSubmit(value)}
          />
        </Box>
      </Section>
    </Modal>
  );
};
