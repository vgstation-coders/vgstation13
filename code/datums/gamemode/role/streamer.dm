/datum/role/streamer
	id = STREAMER
	name = STREAMER
	logo_state = "streamer-logo"
	greets = list(GREET_DEFAULT, GREET_CUSTOM)

	var/list/followers = list()
	var/list/subscribers = list()
	var/team
	var/conversions = 0
	var/hits = 0
	var/obj/machinery/camera/arena/spesstv/camera

/datum/role/streamer/Greet(greeting, custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [custom]")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are now online!<br/></span>")
			to_chat(antag.current, "Entertain your audience to obtain followers and subscribers!")
	antag.current << sound('sound/machines/lawsync.ogg')

/datum/role/streamer/OnPostSetup(var/laterole = FALSE)
	. = ..()
	update_streamer_hud()
	ForgeObjectives()

/datum/role/streamer/RemoveFromRole(var/datum/mind/M)
	if(antag.current.client && antag.current.hud_used)
		if(antag.current.hud_used.streamer_display)
			antag.current.client.screen -= list(antag.current.hud_used.streamer_display)
	..()

/datum/role/streamer/AdminPanelEntry(var/show_logo = FALSE,var/datum/admins/A)
	var/icon/logo = icon('icons/logos.dmi', logo_state)
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

/datum/role/streamer/ForgeObjectives()
	AppendObjective(/datum/objective/reach_followers)
	AppendObjective(/datum/objective/reach_subscribers)

/datum/role/streamer/GetScoreboard()
	switch(team)
		if(ESPORTS_CULTISTS)
			. += "Conversions: <b>[conversions]</b><br>"
		if(ESPORTS_SECURITY)
			. += "Hits: <b>[hits]</b><br>"
	. += "Followers: <b>[length(followers)]</b><br>"
	. += "Subscribers: <b>[length(subscribers)]</b><br>"
	. += ..()

/datum/role/streamer/update_antag_hud()
	update_streamer_hud()

/datum/role/streamer/proc/update_streamer_hud()
	var/mob/M = antag.current
	if(!M || M.gcDestroyed || !M.client || !M.hud_used)
		return
	var/obj/abstract/screen/streamer_display = M.hud_used.streamer_display
	if(!streamer_display)
		M.hud_used.streamer_hud()
		streamer_display = M.hud_used.streamer_display
	streamer_display.maptext_width = (WORLD_ICON_SIZE*2)+20
	streamer_display.maptext_height = WORLD_ICON_SIZE*2
	var/list/text = list("<div align='left' valign='top' style='position:relative; top:0px; left:6px'>")
	if(IS_WEEKEND)
		text += "Double XP <font color='#33FF33'>enabled</span>!</font><br>"
	switch(team)
		if(ESPORTS_CULTISTS)
			text += "Conversions: <font color='#FF1133'>[conversions]</font>"
		if(ESPORTS_SECURITY)
			text += "Hits: <font color='#FF1133'>[hits]</font>"
	text += "<br>Followers: <font color='#33FF33'>[length(followers)]</font>"
	text += "<br>Subscribers:<font color='#FFFF00'>[length(subscribers)]</font></div>"
	streamer_display.maptext = jointext(text, null)

/datum/role/streamer/proc/try_add_follower(datum/mind/new_follower)
	if(new_follower == antag)
		to_chat(new_follower.current, "<span class='warning'>Following yourself is against Spess.TV's End User License Agreement.</span>")
		return
	if(followers.Find(new_follower))
		to_chat(new_follower.current, "<span class='warning'>You are already following [antag.name].</span>")
		return
	followers += new_follower
	update_antag_hud()
	new_follower.current.visible_message("<span class='big notice'>[new_follower.current] is now following [antag.name]!</span>")

/datum/role/streamer/proc/try_add_subscription(datum/mind/new_subscriber, obj/machinery/computer/security/telescreen/entertainment/spesstv/tv)
	if(new_subscriber == antag)
		to_chat(new_subscriber.current, "<span class='warning'>Subscribing to yourself is against Spess.TV's End User License Agreement.</span>")
		return
	if(subscribers.Find(new_subscriber))
		to_chat(new_subscriber.current, "<span class='warning'>You're already subscribed to [antag.name]!</span>")
		return
	tv.reconnect_database()
	if(tv.charge_flow(tv.linked_db, new_subscriber.current.get_id_card(), new_subscriber.current, 250, station_account, "Spess.TV subscription to [antag.name]") == CARD_CAPTURE_SUCCESS)
		tv.visible_message("<span class='big notice'>[new_subscriber.current] just subscribed to [antag.name]!</span>")
		playsound(tv, pick('sound/effects/noisemaker1.ogg', 'sound/effects/noisemaker2.ogg', 'sound/effects/noisemaker3.ogg'), 100, TRUE)
		playsound(antag.current, pick('sound/effects/noisemaker1.ogg', 'sound/effects/noisemaker2.ogg', 'sound/effects/noisemaker3.ogg'), 100, TRUE)
	else
		playsound(tv, 'sound/machines/alert.ogg', 50, TRUE)
		tv.visible_message("[bicon(tv)]<span class='warning'>Something went wrong processing [new_subscriber.current]'s payment.</span>")
		return
	subscribers += new_subscriber
	update_antag_hud()
	switch(team)
		if(ESPORTS_CULTISTS)
			new /obj/item/weapon/storage/cult/sponsored(get_turf(antag.current))
			for(var/i in 1 to 3)
				new /obj/item/weapon/reagent_containers/food/drinks/soda_cans/geometer(get_turf(new_subscriber.current))
		if(ESPORTS_SECURITY)
			new /obj/item/weapon/storage/lockbox/security_sponsored(get_turf(antag.current))
			for(var/i in 1 to 4)
				new /obj/item/weapon/reagent_containers/food/snacks/donitos(get_turf(new_subscriber.current))

/datum/role/streamer/proc/toggle_streaming()
	camera.deactivate()
	antag.current.visible_message("<span class='big notice'>[antag.current] is now [camera.status ? "streaming!" : "offline."]</span>")

/datum/role/streamer/proc/set_camera(obj/machinery/camera/arena/spesstv/new_camera)
	ASSERT(istype(new_camera))
	camera = new_camera
	camera.streamer = src
	camera.name_camera()
