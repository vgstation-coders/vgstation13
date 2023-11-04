import { Stack } from 'vgui/components';
import { createRenderer } from 'vgui/renderer';

const render = createRenderer();

export const Default = () => {
  const node = (
    <Stack align="baseline">
      <Stack.Item>
        Text {Math.random()}
      </Stack.Item>
      <Stack.Item grow={1} basis={0}>
        Text {Math.random()}
      </Stack.Item>
    </Stack>
  );
  render(node);
};
