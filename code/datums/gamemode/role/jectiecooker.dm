/datum/role/jectie_cooker
	id = JECTIE_COOKER
	name = JECTIE_COOKER
	logo_icon = 'icons/obj/food.dmi'
	logo_state = "jectie_green"
	greets = list(GREET_DEFAULT, GREET_CUSTOM)
	default_admin_voice = "Head Chef"
	admin_voice_style = "djradio"
	is_antag = FALSE

/datum/role/jectie_cooker/Greet(greeting, custom)
	if(!greeting)
		return

	var/icon/logo = icon(logo_icon, logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [custom]")

/datum/role/jectie_cooker/AdminPanelEntry(var/show_logo = FALSE,var/datum/admins/A)
	var/icon/logo = icon(logo_icon, logo_state)
	var/mob/M = antag.current
	var/text
	if (!M) // Body destroyed
		text = "[antag.name]/[antag.key] (BODY DESTROYED)"
	else
		text = {"[show_logo ? "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> " : "" ]
[name] <a href='?_src_=holder;adminplayeropts=\ref[M]'>[key_name(M)]</a>[M.client ? "" : " <i> - (logged out)</i>"][M.stat == DEAD ? " <b><font color=red> - (DEAD)</font></b>" : ""]
 - <a href='?src=\ref[usr];priv_msg=\ref[M]'>(priv msg)</a>
 - <a href='?_src_=holder;traitor=\ref[M]'>(role panel)</a>"}
	return text
