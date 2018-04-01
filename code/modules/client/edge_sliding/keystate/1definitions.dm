client
	var/manual_focus = 0
	proc
		KeyDown(KeyCode,shift)
		KeyUp(KeyCode,shift)
KeyState
	var/key_repeat = 0
	var/open = 1
	proc
		open()
			open = 1
			if(client)client.KeyFocus()
		close()
			open = 0
			if(client)client<<browse(null,null)