client
	var/manual_focus = 0

client/proc/KeyDown(KeyCode,shift)
client/proc/KeyUp(KeyCode,shift)

KeyState
	var/key_repeat = 0
	var/open = 1

KeyState/proc/open()
	open = 1
	if(client)client.KeyFocus()

KeyState/proc/close()
	open = 0
	if(client)client<<browse(null,null)