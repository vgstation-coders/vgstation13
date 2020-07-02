/mob/living/silicon/robot/mommi/Login()
	..()
	if(can_see_static())
		add_static_overlays()
	to_chat(src, "<span class='big warning'>MoMMIs are not standard cyborgs, and have different laws.  Review your laws carefully.</span>")
	to_chat(src, "<b>For newer players, a simple FAQ is <a href=\"http://ss13.moe/wiki/index.php/MoMMI\">here</a>.  Further questions should be directed to adminhelps (F1).</b>")
	to_chat(src, "<span class='info'>For cuteness' sake, using the various emotes MoMMIs have such as *beep, *ping, *buzz or *aflap isn't considered interacting. Don't use that as an excuse to get involved though, always remain neutral.</span>")

/mob/living/silicon/robot/mommi/proc/can_see_static()
	return (keeper && !emagged && !syndicate && (config && config.mommi_static))

/mob/living/silicon/robot/mommi/proc/add_static_overlays()
	remove_static_overlays()
	for(var/mob/living/living in mob_list)
		if(istype(living, /mob/living/silicon))
			continue
		var/image/chosen
		if(static_choice in living.static_overlays)
			chosen = living.static_overlays[static_choice]
		else
			chosen = living.static_overlays[1]
		static_overlays.Add(chosen)
		if(client)
			client.images.Add(chosen)

/mob/living/silicon/robot/mommi/proc/remove_static_overlays()
	if(client)
		for(var/image/I in static_overlays)
			client.images.Remove(I)
	static_overlays.Cut()

/mob/living/silicon/robot/mommi/examination(atom/A as mob|obj|turf in view()) //It used to be oview(12), but I can't really say why
	if(ismob(A) && !issilicon(A) && can_see_static()) //can't examine what you can't catch!
		to_chat(usr, "Your vision module can't determine any of [A]'s features.")
		return
	..()

/mob/living/silicon/robot/mommi/verb/toggle_statics()
	set name = "Change Vision Filter"
	set desc = "Change the filter on the system used to remove organics from your viewscreen."
	set category = "Robot Commands"

	if(!can_see_static())
		return
	var/selected_style = input("Select a vision filter", "Vision Filter") as null|anything in static_choices
	if(selected_style in static_choices)
		static_choice = selected_style
		add_static_overlays()