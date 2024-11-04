// This fullscreen overlay prevents clients with HW accel or directX disabled from seeing anything
// As it's only transparent with full rendering capabilities ON.
// If HW accel is OFF, BLEND_MULTIPLY is turned to BLEND_OVERLAY, manually.
// If HW accel is ON but DirectX and shaders are fucked, the colour matrix giving the full black whiteness fails to render
//   and it stays as pitch black, resulting in black multiplying into black.
/obj/abstract/screen/fullscreen/__secret__hwfuck
	plane = HUD_PLANE + 1
	icon = 'icons/secret/x.png'
	blend_mode = BLEND_DEFAULT
	mouse_opacity = 0
	color = list(
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		1, 1, 1, 1
	)
	var/client/my_client

/client
	var/obj/abstract/screen/fullscreen/__secret__hwfuck/HW

/obj/abstract/screen/fullscreen/__secret__hwfuck/New(var/client/C)
	my_client = C
	my_client.HW = src
	verbs.Cut()
	..()

/obj/abstract/screen/fullscreen/__secret__hwfuck/proc/check()
	if (winget(my_client, null, "hwmode") != "true")
		my_client.screen |= src
		if (my_client in shitlist)
			to_chat(my_client, "<span class='danger big'>You have been kicked for not enabling hardware acceleration in the game client's options menu.<br>Please enable hardware acceleration, then reconnect.</span>")
			sleep(1)
			var/log = "[key_name(my_client)] has been kicked for failing to activate hardware acceleration on their client."
			message_admins(log)
			log_game(log)
			del(my_client)
		else
			my_client << 'sound/effects/adminhelp.ogg'
			to_chat(my_client, "<span class='danger big'>Your client has hardware acceleration disabled in Dream Seeker's options menu. You will be kicked if you do not enable hardware acceleration.<br>To enable HW acceleration: left click the SS13 icon at the very top left of the game window -> client -> preferences..., tick the checkbox reading 'Use graphics hardware for displaying maps.'</span>")
			shitlist += my_client

	else
		my_client.screen -= src
		blend_mode = BLEND_MULTIPLY
		if (my_client in shitlist)
			shitlist -= my_client
/*
/world/New()
	..()

	// 2 MINUTES but the define isn't included here.
	spawn (1200)
		__secret__hwcheck_loop()
*/
var/list/shitlist = list()
/proc/__secret__hwcheck_loop()
	// List of clients that have been warned last iteration.
	while (TRUE)
		for (var/client/C in clients)
			C.HW?.check()
		// 1 MINUTES.
		sleep(600)
