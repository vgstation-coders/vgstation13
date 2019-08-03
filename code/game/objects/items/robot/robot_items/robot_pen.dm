//A special pen for service droids. Can be toggled to switch between normal writting mode, and paper rename mode
//Allows service droids to rename paper items.
/obj/item/weapon/pen/robopen
	desc = "A black ink printing attachment with a paper naming mode."
	name = "Printing Pen"
	var/mode = 1

/obj/item/weapon/pen/robopen/attack_self(mob/user as mob)
	playsound(src, 'sound/effects/pop.ogg', 50, 0)
	if (mode == 1)
		mode = 2
		to_chat(user, "Changed printing mode to 'Rename Paper'")
		return
	if (mode == 2)
		mode = 1
		to_chat(user, "Changed printing mode to 'Write Paper'")

// Copied over from paper's rename verb
// see code\\modules\\\paperwork\\\paper.dm line 62

/obj/item/weapon/pen/robopen/proc/RenamePaper(mob/user as mob,obj/paper as obj)
	if ( !user || !paper )
		return
	var/n_name = input(user, "What would you like to label the paper?", "Paper Labelling", null)  as text
	if ( !user || !paper )
		return

	n_name = copytext(n_name, 1, 32)
	if (Adjacent(user) && !user.stat)
		paper.name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(user)