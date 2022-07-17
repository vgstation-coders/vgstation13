/mob/living/silicon/ai/Login()	//ThisIsDumb(TM) TODO: tidy this up ¬_¬ ~Carn
	..()

	for(var/obj/effect/rune/rune in runes)
		client.images += rune.blood_image
	regenerate_icons()
	clear_all_alerts()	//fuck alerts
	handle_regular_hud_updates()

	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/O in machines) //change status
			O.mode = 1
			O.emotion = "Neutral"
	view_core()
	if (mind && !stored_freqs)
		to_chat(src, "The various frequencies used by the crew to communicate have been stored in your mind. Use the verb <i>Notes</i> to access them.")
		spawn(1)
			mind.store_memory("Frequencies list: <br/><b>Command:</b> [COMM_FREQ] <br/> <b>Security:</b> [SEC_FREQ] <br/> <b>Medical:</b> [MED_FREQ] <br/> <b>Science:</b> [SCI_FREQ] <br/> <b>Engineering:</b> [ENG_FREQ] <br/> <b>Service:</b> [SER_FREQ] <b>Cargo:</b> [SUP_FREQ]<br/> <b>AI private:</b> [AIPRIV_FREQ]<br/>")
		stored_freqs = 1
	var/datum/role/malfAI/M = mind.GetRole(MALF)
	if(M)
		M.regenerate_hack_overlays()
		DisplayUI("Malf")
	client.CAN_MOVE_DIAGONALLY = TRUE
	client.screen += aistatic

/mob/living/silicon/ai/proc/show_intro_text()
	to_chat(src, "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>")
	to_chat(src, "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>")
	to_chat(src, "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>")
	to_chat(src, "To use something, simply click on it.")
	to_chat(src, {"Use say ":b to speak to your cyborgs through binary."})

