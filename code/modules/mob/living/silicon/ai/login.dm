/mob/living/silicon/ai/Login()	//ThisIsDumb(TM) TODO: tidy this up ¬_¬ ~Carn
	..()

	to_chat(src, "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>")
	to_chat(src, "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>")
	to_chat(src, "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>")
	to_chat(src, "To use something, simply click on it.")
	to_chat(src, {"Use say ":b to speak to your cyborgs through binary."})
	show_laws()
	if(ismalf(src))
		to_chat(src, "<b>These laws may be changed by other players, or by you being the traitor.</b>")

	for(var/obj/effect/rune/rune in global_runesets["blood_cult"].rune_list) //HOLY FUCK WHO THOUGHT LOOPING THROUGH THE WORLD WAS A GOOD IDEA
		client.images += rune.blood_image
	regenerate_icons()

	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/O in machines) //change status
			O.mode = 1
			O.emotion = "Neutral"
	view_core()
	client.CAN_MOVE_DIAGONALLY = TRUE
