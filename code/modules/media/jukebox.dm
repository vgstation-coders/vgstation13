/*******************************
 * Largely a rewrite of the Jukebox from D2K5
 *
 * By N3X15
 *******************************/

var/global/global_playlists = list()
/proc/load_juke_playlists()
	set waitfor = 0//tentative fix so the proc stops hanging if it takes too long
	if(!config.media_base_url)
		return
	for(var/playlist_id in list("lilslugger", "bar", "jazzswing", "bomberman", "depresso", "echoes", "electronica", "emagged", "endgame", "filk", "funk", "folk", "idm", "malfdelta", "medbay", "metal", "muzakjazz", "nukesquad", "rap", "rock", "shoegaze", "security", "shuttle", "thunderdome", "upbeathypedancejam", "vidya", "SCOTLANDFOREVER", "halloween", "christmas"))
		var/url="[config.media_base_url]/index.php?playlist=[playlist_id]"
		log_debug("Begin updating playlist: [playlist_id]...")

		//  Media Server 2 requires a secret key in order to tell the jukebox
		// where the music files are. It's set in config with MEDIA_SECRET_KEY
		// and MUST be the same as the media server's.
		//
		//  Do NOT log this, it's like a password.
		if(config.media_secret_key!="")
			url += "&key=[config.media_secret_key]"

		var/response = world.Export(url)
		var/list/playlist=list()
		if(response)
			log_debug("Received response from media server for [playlist_id], with a length of [length(response)]")
			var/json = file2text(response["CONTENT"])
			//i don't think this works as a string search
			//if("/>" in json)
			if(findtext(json, "/>"))
				continue
			var/songdata = json_decode(json)
			log_debug("Successfully decoded media server's response for [playlist_id]")
			for(var/list/record in songdata)
				playlist += new /datum/song_info(record)
			log_debug("Successfully added song data to playlist for [playlist_id]")
			if(playlist.len==0)
				continue
			global_playlists["[playlist_id]"] = playlist.Copy()
			log_debug("Finished adding [playlist_id] to global playlists")
		else
			log_debug("Received no response from media server for [playlist_id]")

/obj/machinery/media/jukebox/proc/retrieve_playlist(var/playlistid = playlist_id)
	if(!config.media_base_url)
		return
	playlist_id = playlistid
	if(global_playlists["[playlistid]"])
		var/list/temp = global_playlists["[playlistid]"]
		playlist = temp.Copy()

	else
		var/url="[config.media_base_url]/index.php?playlist=[playlist_id]"
		//testing("[src] - Updating playlist from [url]...")

		//  Media Server 2 requires a secret key in order to tell the jukebox
		// where the music files are. It's set in config with MEDIA_SECRET_KEY
		// and MUST be the same as the media server's.
		//
		//  Do NOT log this, it's like a password.
		if(config.media_secret_key!="")
			url += "&key=[config.media_secret_key]"

		var/response = world.Export(url)
		playlist=list()
		if(response)
			var/json = file2text(response["CONTENT"])
			if("/>" in json)
				visible_message("<span class='warning'>[bicon(src)] \The [src] buzzes, unable to update its playlist.</span>","<em>You hear a buzz.</em>")
				stat &= BROKEN
				update_icon()
				return 0
			var/json_reader/reader = new()
			reader.tokens = reader.ScanJson(json)
			reader.i = 1
			var/songdata = reader.read_value()
			for(var/list/record in songdata)
				if (("track" in record) && record["track"])
					//sorted playlist
					if (playlist == list())
						var/length = 0
						for(var/list/entry in songdata)
							length++
						var/M[length]
						playlist = M//turns "playlist" into an empty list of size of the actual playlist
					var/track = text2num(record["track"])
					playlist.Insert(track, new /datum/song_info(record))
				else
					//unsorted playlist
					playlist += new /datum/song_info(record)

			if(playlist.len==0)
				visible_message("<span class='warning'>[bicon(src)] \The [src] buzzes, unable to update its playlist.</span>","<em>You hear a buzz.</em>")
				stat &= BROKEN
				update_icon()
				return 0
			visible_message("<span class='notice'>[bicon(src)] \The [src] beeps, and the menu on its front fills with [playlist.len] items.</span>","<em>You hear a beep.</em>")
		else
			testing("[src] failed to update playlist: Response null.")
			stat &= BROKEN
			update_icon()
			return 0
		global_playlists["[playlistid]"] = playlist.Copy()
	if(autoplay)
		playing=1
		autoplay=0
	return 1
// Represents a record returned.
/datum/song_info
	var/title  = ""
	var/artist = ""
	var/album  = ""

	var/url    = ""
	var/length = 0 // decaseconds
	var/crossfade_time = 0 // decaseconds, if the song ends up with a decresendo/fadeout so we can crossfade into the next one.

	var/emagged = 0

/datum/song_info/New(var/list/json)
	title  = json["title"]
	artist = json["artist"]
	album  = json["album"]

	url    = json["url"]

	length = text2num(json["length"])
	crossfade_time = text2num(json["crossfade_time"])
	if (isnull(crossfade_time))
		crossfade_time = 0

/datum/song_info/proc/display()
	var/str="\"[title]\""
	if(artist!="")
		str += ", by [artist]"
	if(album!="")
		str += ", from '[album]'"
	return str

/datum/song_info/proc/displaytitle()
	if(artist==""&&title=="")
		return "\[NO TAGS\]"
	var/str=""
	if(artist!="")
		str += artist+" - "
	if(title!="")
		str += "\"[title]\""
	else
		str += "Untitled"
	// Only show album if we have to.
	if(album!="" && artist == "")
		str += " ([album])"
	return str


var/global/list/loopModeNames=list(
	JUKEMODE_SHUFFLE     = "Shuffle",
	JUKEMODE_REPEAT_SONG = "Single",
	JUKEMODE_PLAY_ONCE   = "Once"
)
/obj/machinery/media/jukebox
	name = "Jukebox"
	desc = "A bastion of goodwill, peace, and hope."
	icon = 'icons/obj/jukebox.dmi'
	icon_state = "jukebox2"
	density = 1

	anchored = 1
	luminosity = 3

	use_auto_lights = 1
	light_power_on = 1
	light_range_on = 1
	light_color = "#FFEE77"

	custom_aghost_alerts=1 // We handle our own logging.

	playing=0

	var/loop_mode = JUKEMODE_SHUFFLE
	var/list/allowed_modes = null

	// Server-side playlist IDs this jukebox can play.
	var/list/playlists=list() // ID = Label

	// Playlist to load at startup.
	var/playlist_id = ""

	var/list/playlist
	var/current_song  = 0 // 0, or whatever song is currently playing.
	var/next_song     = 0 // 0, or a song someone has purchased.  Played after current song completes.
	var/selected_song = 0 // 0 or the song someone has selected for purchase
	var/autoplay      = 0 // Start playing after spawn?
	var/last_reload   = 0 // Reload cooldown.
	var/last_song     = 0 // ID of previous song (used in shuffle to prevent double-plays)

	var/screen = JUKEBOX_SCREEN_MAIN

	var/credits_held   = 0 // Cash currently held
	var/credits_needed = 0 // Credits needed to complete purchase.
	var/change_cost    = 10 // Current cost to change songs.
	var/list/change_access  = list() // Access required to change songs
	var/department // Department that gets the money

	var/state_base = "jukebox2"

	var/datum/wires/jukebox/wires = null
	var/pick_allowed = 1 //Allows you to pick songs
	var/access_unlocked = 0 //Allows you to access settings

	machine_flags = WRENCHMOVE | FIXED2WORK | EMAGGABLE | MULTITOOL_MENU | SCREWTOGGLE | SHUTTLEWRENCH
	mech_flags = MECH_SCAN_FAIL
	emag_cost = 0 // because fun/unlimited uses.

	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/oneuse/emag
	)

/obj/machinery/media/jukebox/New(loc)
	..(loc)
	allowed_modes = loopModeNames.Copy()
	wires = new(src)
	if(department)
		linked_account = department_accounts[department]
	else
		linked_account = station_account
	var/MM = text2num(time2text(world.timeofday, "MM"))
	if(MM == 10 && !("halloween" in playlists)) //Checking for jukeboxes with it already
		playlists["halloween"] = "Halloween"
	if(MM == 12 && !("christmas" in playlists)) //Checking for jukeboxes with it already
		playlists["christmas"] = "Christmas Jingles"
	update_icon()

/obj/machinery/media/jukebox/Destroy()
	if(wires)
		QDEL_NULL(wires)
	..()

/obj/machinery/media/jukebox/attack_paw(var/mob/user)
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	attack_hand(user)

/obj/machinery/media/jukebox/examine(mob/user)
	..()
	if (current_song_info)
		if (!current_song_info.emagged)
			to_chat(user, "<span class='info'>It is playing [current_song_info.display()].</span>")
		else
			to_chat(user, "<span class='info'>What is that hellish noise?</span>")
	else
		to_chat(user, "<span class='info'>It is currently silent.</span>")

/obj/machinery/media/jukebox/power_change()
	if (emagged)
		light_color = "#AA0000"
	else
		light_color = initial(light_color)
	..()
	if(emagged && !(stat & (FORCEDISABLE|NOPOWER|BROKEN)) && !any_power_cut())
		playing = 1
		if(current_song)
			update_music()
	update_icon()

/obj/machinery/media/jukebox/proc/any_power_cut()
	var/total = wires.IsIndexCut(JUKE_POWER_ONE) || wires.IsIndexCut(JUKE_POWER_TWO) || wires.IsIndexCut(JUKE_POWER_THREE)
	return total

/obj/machinery/media/jukebox/update_icon()
	overlays = 0
	if(stat & (FORCEDISABLE|NOPOWER|BROKEN) || !anchored || any_power_cut())
		if(stat & BROKEN)
			icon_state = "[state_base]-broken"
		else
			icon_state = "[state_base]-nopower"
		stop_playing()
		kill_moody_light_all()
		return
	update_moody_light_index("main",'icons/lighting/moody_lights.dmi', "overlay_juke")
	icon_state = state_base
	if(playing)
		if(emagged)
			overlays += image(icon = icon, icon_state = "[state_base]-emagged")
		else
			overlays += image(icon = icon, icon_state = "[state_base]-running")

/obj/machinery/media/jukebox/proc/check_reload()
	return world.time > last_reload + JUKEBOX_RELOAD_COOLDOWN

/obj/machinery/media/jukebox/attack_hand(var/mob/user)
	if(stat & (FORCEDISABLE|NOPOWER) || any_power_cut())
		to_chat(usr, "<span class='warning'>You don't see anything to mess with.</span>")
		return
	if(stat & BROKEN && playlist!=null)
		user.visible_message("<span class='danger'>[user.name] smacks the side of \the [src.name].</span>","<span class='warning'>You hammer the side of \the [src.name].</span>")
		stat &= ~BROKEN
		playlist=null
		playing=emagged
		update_icon()
		return
	if(panel_open)
		wires.Interact(user)
	var/t = "<div class=\"navbar\">"
	t += "<a href=\"?src=\ref[src];screen=[JUKEBOX_SCREEN_MAIN]\">Main</a>"
	if(allowed(user)|| access_unlocked)
		t += " | <a href=\"?src=\ref[src];screen=[JUKEBOX_SCREEN_SETTINGS]\">Settings</a>"
	t += "</div>"
	switch(screen)
		if(JUKEBOX_SCREEN_MAIN)
			t += ScreenMain(user)
		if(JUKEBOX_SCREEN_PAYMENT)
			t += ScreenPayment(user)
		if(JUKEBOX_SCREEN_SETTINGS)
			t += ScreenSettings(user)

	user.set_machine(src)
	var/datum/browser/popup = new (user,"jukebox",name,420,700)
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/media/jukebox/proc/ScreenMain(var/mob/user)
	var/t = list()
	t += "<h1>Jukebox Interface</h1>"
	t += "<b>Power:</b> <a href='?src=\ref[src];power=1'>[playing?"On":"Off"]</a><br />"
	t += "<b>Play Mode:</b> <a href='?src=\ref[src];mode=1'>[allowed_modes[loop_mode]]</a><br />"
	if(isAdminGhost(user))
		t += "<a href='?src=\ref[src];add_custom=1'>Add new song</a><br>"

	if(playlist == null)
		t += "\[DOWNLOADING PLAYLIST, PLEASE WAIT\]"
	else
		if(req_access.len == 0 || allowed(user) || access_unlocked)
			if(check_reload())
				t += "<b>Playlist:</b> "
				for(var/plid in playlists)
					t += "<a href='?src=\ref[src];playlist=[plid]'>[playlists[plid]]</a>"
			else
				t += "<i>Please wait before changing playlists.</i>"
		else
			t += "<i>You cannot change the playlist.</i>"
		t += "<br />"
		if(current_song)
			if(!playlist.len)
				playlist=null
				process()
				if(!playlist || !playlist.len)
					return
			else if(current_song > playlist.len)
				current_song = playlist.len
			var/datum/song_info/song=playlist[current_song]
			t += "<b>Playlist:<b> [playlists[playlist_id]]<br />"
			t += "<b>Current song:</b> [song.artist] - [song.title]<br />"
		if(next_song)
			var/datum/song_info/song=playlist[next_song]
			t += "<b>Up next:</b> [song.artist] - [song.title]<br />"
		t += "<table class='prettytable'><tr><th colspan='2'>Artist - Title</th><th>Album</th></tr>"
		var/i
		var/can_change=!next_song
		if(change_access.len > 0) // Permissions
			if(can_access(user.GetAccess(),req_access=change_access))
				can_change = 1

		for(i = 1,i <= playlist.len,i++)
			var/datum/song_info/song=playlist[i]
			t += "<tr><th>#[i]</th><td>"
			if(can_change)
				t += "<A href='?src=\ref[src];song=[i]' class='nobg'>"
			t += song.displaytitle()
			if(can_change)
				t += "</A>"
			t += "</td><td>[song.album]</td></tr>"
		t += "</table>"
	t = jointext(t,"")
	return t

/obj/machinery/media/jukebox/proc/ScreenPayment(var/mob/user)
	var/t = "<h1>Pay for Song</h1>"
	var/datum/song_info/song=playlist[selected_song]
	t += {"
	<center>
		<p>You've selected <b>[song.displaytitle()]</b>.</p>
		<p><b>Swipe ID card</b> or <b>insert cash</b> to play this song next! ($[num2septext(change_cost)])</p>
		\[ <a href='?src=\ref[src];cancelbuy=1'>Cancel</a> \]
	</center>"}
	return t

/obj/machinery/media/jukebox/proc/ScreenSettings(var/mob/user)
	if(!linked_account)
		linked_account = station_account
	var/dat

	dat += {"<h1>Settings</h1>
		<form action="?src=\ref[src]" method="get">
		<input type="hidden" name="src" value="\ref[src]" />
		<fieldset>
			<legend>Banking</legend>
			<div>
				<b>Payable Account:</b> <input type="textbox" name="payableto" value="[linked_account.account_number]" />
			</div>
		</fieldset>
		<fieldset>
			<legend>Pricing</legend>
			<div>
				<b>Change Song:</b> $<input type="textbox" name="set_change_cost" value="[change_cost]" />
			</div>
		</fieldset>
		<fieldset>
			<legend>Access</legend>
			<p>Permissions required to change song:</p>
			<div>
				<input type="radio" name="lock" id="lock_none" value=""[change_access == list() ? " checked='selected'":""] /> <label for="lock_none">None</label>
			</div>
			<div>
				<input type="radio" name="lock" id="lock_bar" value="[access_bar]"[change_access == list(access_bar) ? " checked='selected'":""] /> <label for="lock_bar">Bar</label>
			</div>
			<div>
				<input type="radio" name="lock" id="lock_head" value="[access_heads]"[change_access == list(access_heads) ? " checked='selected'":""] /> <label for="lock_head">Any Head</label>
			</div>
			<div>
				<input type="radio" name="lock" id="lock_cap" value="[access_captain]"[change_access == list(access_captain) ? " checked='selected'":""] /> <label for="lock_cap">Captain</label>
			</div>
		</fieldset>
		<input type="submit" name="act" value="Save Settings" /></form>"}

	dat += "<BR><b>Media</b><BR>"
	for(var/element in playlists)
		dat += "[playlists[element]] <a href='?src=\ref[src];eject=[element]'>Eject</a><BR>"
	dat += "<a href='?src=\ref[src];insert=1'>Insert Vinyl</a><BR>"
	return dat

/obj/machinery/media/jukebox/proc/generate_name()
	var/area/this_area = get_area(src)
	return "[this_area.name] [name]"

/obj/machinery/media/jukebox/scan_card(var/obj/item/weapon/card/C)
	var/remaining_credits_needed = credits_needed - credits_held
	var/pos_name = generate_name()
	var/charge_response = charge_flow(linked_db, C, usr, remaining_credits_needed, linked_account, "Song Selection", pos_name, 0)
	switch(charge_response)
		if(CARD_CAPTURE_SUCCESS)
			visible_message("<span class='notice'>The machine beeps happily.</span>","You hear a beep.")
			if(credits_held)
				linked_account.charge(-credits_held, null, "Cash Deposit", pos_name, 0, linked_account.owner_name)
				credits_held=0
			credits_needed=0
			successful_purchase()
			return
		if(CARD_CAPTURE_FAILURE_NOT_ENOUGH_FUNDS)
			visible_message("<span class='warning'>The machine buzzes, and flashes \"NOT ENOUGH FUNDS\" on the screen.</span>","You hear a buzz.")
		if(CARD_CAPTURE_ACCOUNT_DISABLED)
			visible_message("<span class='warning'>The machine buzzes, and flashes \"ACCOUNT DISABLED\" on the screen.</span>","You hear a buzz.")
		if(CARD_CAPTURE_ACCOUNT_DISABLED_MERCHANT)
			visible_message("<span class='warning'>The machine buzzes, and flashes \"MERCHANT ACCOUNT DISABLED\" on the screen.</span>","You hear a buzz.")
		if(CARD_CAPTURE_FAILURE_BAD_ACCOUNT_PIN_COMBO)
			visible_message("<span class='warning'>The machine buzzes, and flashes \"BAD ACCOUNT/PIN COMBO\" on the screen.</span>","You hear a buzz.")
		if(CARD_CAPTURE_FAILURE_SECURITY_LEVEL)
			visible_message("<span class='warning'>The machine buzzes, and flashes \"SECURITY EXCEPTION\" on the screen.</span>","You hear a buzz.")
		if(CARD_CAPTURE_FAILURE_USER_CANCELED)
			visible_message("<span class='warning'>The machine buzzes, and flashes \"ORDER CANCELED\" on the screen.</span>","You hear a buzz.")
		if(CARD_CAPTURE_FAILURE_NO_DESTINATION)
			visible_message("<span class='warning'>The machine buzzes, and flashes \"NO LINKED ACCOUNT\" on the screen.</span>","You hear a buzz.")
		if(CARD_CAPTURE_FAILURE_NO_CONNECTION)
			visible_message("<span class='warning'>The machine buzzes, and flashes \"DATABASE UNAVAILABLE\" on the screen.</span>","You hear a buzz.")
		else
			visible_message("<span class='warning'>The machine buzzes, and flashes \"CARD CAPTURE ERROR\" on the screen.</span>","You hear a buzz.")

/obj/machinery/media/jukebox/proc/dispense_change(var/amount = 0)
	if(!amount)
		amount = credits_held
		credits_held = 0
	if(amount > 0)
		var/obj/item/weapon/storage/box/B = new(loc)
		dispense_cash(amount,B)
		B.name="change"
		B.desc="A box of change."

/obj/machinery/media/jukebox/attackby(obj/item/W, mob/user)
	. = ..()
	if(ismultitool(W)) //The parent has a multi-tool call that prevents opening the wire panel using a multi-tool. This fixes it.
		if(panel_open)
			wires.Interact(user)
			return
	if(.)
		return .
	if(iswiretool(W))
		if(panel_open)
			wires.Interact(user)
		return
	if(istype(W,/obj/item/weapon/card))
		if(!selected_song || screen!=JUKEBOX_SCREEN_PAYMENT)
			visible_message("<span class='notice'>The machine buzzes.</span>","<span class='warning'>You hear a buzz.</span>")
			return
		var/obj/item/weapon/card/I = W
		connect_account(user, I)
		attack_hand(user)
	else if(istype(W,/obj/item/weapon/spacecash))
		if(!selected_song || screen!=JUKEBOX_SCREEN_PAYMENT)
			visible_message("<span class='notice'>The machine buzzes.</span>","<span class='warning'>You hear a buzz.</span>")
			return
		if(!linked_account)
			visible_message("<span class='warning'>The machine buzzes, and flashes \"NO LINKED ACCOUNT\" on the screen.</span>","You hear a buzz.")
			return
		var/obj/item/weapon/spacecash/C=W
		credits_held += C.get_total()
		qdel(C)
		if(credits_held >= credits_needed)
			visible_message("<span class='notice'>The machine beeps happily.</span>","You hear a beep.")
			linked_account.charge(-credits_needed, null, "Song selection at [generate_name()].", dest_name = linked_account.owner_name)
			credits_held -= credits_needed
			credits_needed=0
			screen=JUKEBOX_SCREEN_MAIN
			dispense_change()
			successful_purchase()
		else
			say("Your total is now $[num2septext(credits_needed-credits_held)].  Please insert more credit chips or swipe your ID.")
		attack_hand(user)


/obj/machinery/media/jukebox/emag_act(mob/user)
	if(!emagged)
		if(user)
			user.visible_message("<span class='warning'>[user.name] slides something into the [src.name]'s card-reader.</span>","<span class='warning'>You short out the [src.name].</span>")
		wires.CutWireIndex(JUKE_CONFIG)
		short()
	return

/obj/machinery/media/jukebox/emag_ai(mob/living/silicon/ai/A)
	to_chat(A, "<span class='warning'>You short out the [src].</span>")
	wires.CutWireIndex(JUKE_CONFIG)
	short()


/obj/machinery/media/jukebox/proc/short()
	emagged = !emagged
	current_song = 0
	playing = 1
	if(!wires.IsIndexCut(JUKE_SHUFFLE))
		loop_mode = JUKEMODE_SHUFFLE
	if(emagged)
		playlist_id = "emagged"
	else
		playlist_id = playlists[1] //Set to whatever our first is. Usually bar.
	last_reload=world.time
	playlist=null
	power_change()
	update_music()

/obj/machinery/media/jukebox/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	playing = emagged
	update_music()
	update_icon()

	// Needed, or jukeboxes will fail to unhook from previous areas.
	if(!anchored)
		disconnect_media_source()
	else
		update_media_source()

/obj/machinery/media/jukebox/proc/successful_purchase()
		next_song = selected_song
		selected_song = 0
		screen = JUKEBOX_SCREEN_MAIN

/obj/machinery/media/jukebox/proc/rad_pulse() //Called by pulsing the transmit wire
	emitted_harvestable_radiation(get_turf(src), 20, range = 5)	//Standing by a juke applies a dose of 17 rads to humans so we'll round based on that. 1/5th the power of a freshly born stage 1 singularity.
	for(var/mob/living/carbon/M in view(src,3))
		var/rads = 50 * sqrt( 1 / (get_dist(M, src) + 1) ) //It's like a transmitter, but 1/3 as powerful.
		M.apply_radiation(round(rads/2),RAD_EXTERNAL) //Distance/rads: 1 = 18, 2 = 14, 3 = 12

/obj/machinery/media/jukebox/Topic(href, href_list)
	if(wires.interference)
		return
	if(isobserver(usr) && !isAdminGhost(usr))
		to_chat(usr, "<span class='warning'>You can't push buttons when your fingers go right through them, dummy.</span>")
		return
	if(..())
		return 1
	if(emagged && !isAdminGhost(usr))
		to_chat(usr, "<span class='warning'>You touch the bluescreened menu. Nothing happens. You feel dumber.</span>")
		return

	if (href_list["power"])
		playing=!playing
		update_music()
		update_icon()

	if("screen" in href_list)
		if(isobserver(usr) && !canGhostWrite(usr,src,""))
			to_chat(usr, "<span class='warning'>You can't do that.</span>")
			return
		screen=text2num(href_list["screen"])

	if("act" in href_list)
		switch(href_list["act"])
			if("Save Settings")
				if(isobserver(usr) && !canGhostWrite(usr,src,"saved settings for"))
					to_chat(usr, "<span class='warning'>You can't do that.</span>")
					return
				var/datum/money_account/new_linked_account = get_money_account(text2num(href_list["payableto"]),z)
				if(!new_linked_account)
					to_chat(usr, "<span class='warning'>Unable to link new account. Aborting.</span>")
					return

				change_cost = max(0,text2num(href_list["set_change_cost"]))
				linked_account = new_linked_account
				if(("lock" in href_list) && href_list["lock"] != "")
					change_access = list(text2num(href_list["lock"]))
				else
					change_access = list()

				screen=POS_SCREEN_SETTINGS

	if(href_list["add_custom"])
		if(isAdminGhost(usr))
			var/choice = input(usr, "Enter the song's URL, length (in seconds!), title, artist and album in that exact order, separated by a semicolon. Artist and album may be omitted. Example: http://music.com/song.mp3;192;Song Name;Artist;Album. If adding more than one song, each song has to be on its own line.", "Custom Jukebox") as null|message
			if(!choice)
				return

			log_admin("[key_name(usr)] is adding some songs to the jukebox [formatJumpTo(src)]:")
			log_admin("[choice]")

			var/success = 0
			var/error = 0

			for(var/line in splittext(choice, "\n"))
				var/list/L = params2list(line)
				if(L.len >= 3)
					var/list/params = list()
					params["url"]   = L[1]
					params["length"]= text2num(L[2])*10 //The song_info datum stores this value in deciseconds
					params["title"] = L[3]
					params["artist"]= ""
					params["album"] = ""

					if(L.len >= 4)
						params["artist"]= L[4]
					if(L.len >= 5)
						params["album"] = L[5]

					//Initialize playlist if needed
					if(!playlist)
						playlist = list()
					playlist.Add(new /datum/song_info(params))
					success++
				else
					error++

			to_chat(usr, "Added [success] songs successfully. Encountered [error] errors.")
			message_admins("[key_name(usr)] has added [success] songs to the jukebox [formatJumpTo(src)]")
		else
			to_chat(usr, "Only admin ghosts can do this.")

	if (href_list["playlist"])
		if(isobserver(usr) && !canGhostWrite(usr,src,""))
			to_chat(usr, "<span class='warning'>You can't do that.</span>")
			return
		if(!check_reload())
			to_chat(usr, "<span class='warning'>You must wait 60 seconds between playlist reloads.</span>")
			return
		playlist_id=href_list["playlist"]
		if(isAdminGhost(usr))
			message_admins("[key_name_admin(usr)] changed [src] playlist to [playlist_id] at [formatJumpTo(src)]")
		last_reload=world.time
		playlist=null
		current_song = 0
		next_song = 0
		selected_song = 0
		update_music()
		update_icon()

	if (href_list["insert"])
		if(isobserver(usr) && !canGhostWrite(usr,src,""))
			to_chat(usr, "<span class='warning'>You can't do that.</span>")
			return
		var/obj/item/weapon/vinyl/V = usr.get_active_hand()
		if(istype(V))
			insert(V)

	if (href_list["eject"])
		if(isobserver(usr) && !canGhostWrite(usr,src,""))
			to_chat(usr, "<span class='warning'>You can't do that.</span>")
			return
		eject(href_list["eject"])

	if (href_list["song"])
		if(wires.IsIndexCut(JUKE_CAPITAL))
			to_chat(usr, "<span class='warning'>You select a song, but [src] is unresponsive...</span>")
			return
		if(isobserver(usr) && !canGhostWrite(usr,src,""))
			to_chat(usr, "<span class='warning'>You can't do that.</span>")
			return
		selected_song=clamp(text2num(href_list["song"]),1,playlist.len)
		if(isAdminGhost(usr))
			var/datum/song_info/song=playlist[selected_song]
			log_adminghost("[key_name_admin(usr)] changed [src] next song to #[selected_song] ([song.display()]) at [formatJumpTo(src)]")
		if(!change_cost || isAdminGhost(usr))
			next_song = selected_song
			selected_song = 0
			if(!current_song)
				update_music()
				update_icon()
		else
			to_chat(usr, "<span class='warning'>Swipe card or insert $[num2septext(change_cost)] to set this song.</span>")
			screen = JUKEBOX_SCREEN_PAYMENT
			credits_needed=change_cost

	if (href_list["cancelbuy"])
		selected_song=0
		dispense_change()
		screen = JUKEBOX_SCREEN_MAIN

	if (href_list["mode"])
		loop_mode = (loop_mode % JUKEMODE_COUNT) + 1

	return attack_hand(usr)

/obj/machinery/media/jukebox/process()
	if(!playlist)
		if(!retrieve_playlist())
			return
	if(playing)
		var/datum/song_info/song
		var/datum/song_info/next_song_datum
		var/fadeout_time = 0
		if(current_song && playlist.len)
			song = playlist[current_song]
		if(next_song && playlist.len)
			next_song_datum = playlist[next_song]
			fadeout_time = next_song_datum.crossfade_time
		if(!current_song || (song && world.time >= media_start_time + song.length - fadeout_time))
			if(next_song)
				current_song = next_song
				next_song = 0
			else
				switch(loop_mode)
					if(JUKEMODE_SHUFFLE)
						while(1)
							current_song=rand(1,playlist.len)
							if(current_song!=last_song || playlist.len<4)
								break
					//if(JUKEMODE_REPEAT_SONG)
					//current_song is what's currently playing, no action needed
					if(JUKEMODE_PLAY_ONCE)
						playing=0
						update_icon()
						return
			//If there's no music set after the above, sanity.
			if(!current_song)
				current_song = 1
			update_music()

/obj/machinery/media/jukebox/proc/eject(var/playlist_name)
	if(playlists.Find(playlist_name))
		new /obj/item/weapon/vinyl(get_turf(src), playlist_name, playlists[playlist_name])
		playlists.Remove(playlist_name)
		if(playlist == playlist_name)
			stop_playing()
			playlist = playlists[1]
	else
		visible_message("<span class='warning'>[bicon(src)] \The [src] buzzes, unable to eject the vinyl.</span>")

/obj/machinery/media/jukebox/proc/insert(var/obj/O)
	var/obj/item/weapon/vinyl/V = O
	if(!istype(V))
		return
	if(playlists.Find(V.unformatted))
		visible_message("<span class='warning'>[bicon(src)] \The [src] buzzes, rejecting the vinyl.</span>")
	else
		playlists[V.unformatted] = V.formatted
		qdel(V)

/obj/machinery/media/jukebox/update_music()
	if(!playlist)
		process()
		if(!playlist || !playlist.len)
			return
	if(current_song > playlist.len)
		current_song = 0
	if(current_song && playing)
		current_song_info = playlist[current_song]
		current_song_info.emagged = emagged
		media_url = current_song_info.url
		last_song = current_song
		media_start_time = world.time
		media_finish_time = world.time + current_song_info.length
		visible_message("<span class='notice'>[bicon(src)] \The [src] begins to play [current_song_info.display()].</span>","<em>You hear music.</em>")
		//visible_message("<span class='notice'>[bicon(src)] \The [src] warbles: [song.length/10]s @ [song.url]</notice>")
	else
		media_url=""
		media_start_time = 0
		current_song_info = null
	..()

/obj/machinery/media/jukebox/proc/stop_playing()
	//current_song=0
	playing=0
	update_music()

/obj/machinery/media/jukebox/npc_tamper_act(mob/living/L)
	if(!panel_open)
		togglePanelOpen(null, L)
	if(wires)
		wires.npc_tamper(L)

/obj/machinery/media/jukebox/kick_act(mob/living/H)
	..()
	if(stat & (FORCEDISABLE|NOPOWER) || any_power_cut())
		return
	playing=!playing
	update_music()
	update_icon()

/obj/machinery/media/jukebox/attack_construct(var/mob/user)
	if (!Adjacent(user))
		return 0
	if(istype(user,/mob/living/simple_animal/construct/armoured))
		playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
		shake(1, 3)
		if(stat & (FORCEDISABLE|NOPOWER) || any_power_cut())
			return
		playing=!playing
		update_music()
		update_icon()
		return 1
	return 0

/obj/machinery/media/jukebox/bar
	department = "Civilian"
	req_access = list(access_bar)

	playlist_id="bar"
	// Must be defined on your server.
	playlists=list(
		"lilslugger" = "Battle of Lil Slugger",
		"bar"  = "Bar Mix",
		"jazzswing" = "Jazz & Swing",
		"depresso" ="Depresso",
		"electronica" = "Electronica",
		"funk" = "Funk",
		"folk" = "Folk",
		"medbay" = "Medbay",
		"metal" = "Heavy Metal",
		"rap" = "Rap",
		"rock" = "Rock",
		"shoegaze" = "Shoegaze",
		"security" = "Security",
		"vidya" = "Video Games",
		"upbeathypedancejam" = "Dance"
	)


// Relaxing elevator music~
/obj/machinery/media/jukebox/dj

	playlist_id="muzakjazz"
	autoplay = 1
	change_cost = 0

	id_tag="DJ Satellite" // For autolink

	// Must be defined on your server.
	playlists=list(
		"bar"  = "Bar Mix",
		"jazzswing" = "Jazz & Swing",
		"depresso" ="Depresso",
		"electronica" = "Electronica",
		"filk" = "Filk",
		"funk" = "Funk",
		"folk" = "Folk",
		"idm" = "90's IDM",
		"medbay" = "Medbay",
		"metal" = "Heavy Metal",
		"muzakjazz" = "Muzak",
		"rap" = "Rap",
		"rock" = "Rock",
		"shoegaze" = "Shoegaze",
		"security" = "Security",
		"upbeathypedancejam" = "Dance",
		"vidya" = "Video Games",
		"thunderdome" = "Thunderdome"
	)

// So I don't have to do all this shit manually every time someone sacrifices pun-pun.
// Also for debugging.
/obj/machinery/media/jukebox/superjuke
	name = "Super Juke"
	desc = "The ultimate jukebox. Your brain begins to liquify from simply looking at it."

	state_base = "superjuke"
	icon_state = "superjuke"

	change_cost = 0

	light_power_on = 2
	light_color = "#3366FF"

	playlist_id="bar"
	// Must be defined on your server.
	playlists=list(
		"lilslugger" = "Battle of Lil' Slugger",
		"bar"  = "Bar Mix",
		"jazzswing" = "Jazz & Swing",
		"depresso" ="Depresso",
		"electronica" = "Electronica",
		"filk" = "Filk",
		"funk" = "Funk",
		"folk" = "Folk",
		"idm" = "90's IDM",
		"medbay" = "Medbay",
		"metal" = "Heavy Metal",
		"muzakjazz" = "Muzak",
		"rap" = "Rap",
		"rock" = "Rock",
		"shoegaze" = "Shoegaze",
		"shuttle" = "Shuttle",
		"security" = "Security",
		"upbeathypedancejam" = "Dance",
		"vidya" = "Video Games",
		"thunderdome" = "Thunderdome",
		"emagged" ="Syndicate Mix",
		"shuttle"= "Shuttle",
		"halloween" = "Halloween",
		"christmas" = "Christmas Jingles",
		"endgame" = "Apocalypse",
		"nukesquad" = "Syndicate Assault",
		"malfdelta"= "Silicon Assault",
		"bomberman" = "Bomberman",
		"SCOTLANDFOREVER"= "Highlander",
		"echoes" = "Echoes"
	)

/obj/machinery/media/jukebox/superjuke/New()
	..()
	power_change() //enabling lights when admin spawned

/obj/machinery/media/jukebox/superjuke/update_icon()
	..()
	if(!(stat & (FORCEDISABLE|NOPOWER|BROKEN)) && anchored && !any_power_cut())
		update_moody_light_index("glow",'icons/lighting/moody_lights.dmi', "overlay_juke_glow")

/obj/machinery/media/jukebox/superjuke/attackby(obj/item/W, mob/user)
	// NO FUN ALLOWED.  Emag list is included, anyway.
	if(isEmag(W))
		to_chat(user, "<span class='warning'>Your [W] refuses to touch \the [src]!</span>")
		return
	..()

/obj/machinery/media/jukebox/superjuke/shuttle
	playlist_id="shuttle"
	id_tag="Shuttle" // For autolink


/obj/machinery/media/jukebox/superjuke/thematic
	playlist_id="endgame"
	use_power = 0

/obj/machinery/media/jukebox/superjuke/thematic/update_music()
	if(current_song && playing)
		current_song_info = playlist[current_song]
		current_song_info.emagged = emagged
		media_url = current_song_info.url
		last_song = current_song
		media_start_time = world.time
		media_finish_time = world.time + current_song_info.length
		visible_message("<span class='notice'>[bicon(src)] \The [src] begins to play [current_song_info.display()].</span>","<em>You hear music.</em>")
		//visible_message("<span class='notice'>[bicon(src)] \The [src] warbles: [song.length/10]s @ [song.url]</notice>")
	else
		media_url=""
		media_start_time = 0
		current_song_info = null

	// Send update to clients.
	for(var/mob/M in mob_list)
		if(M && M.client)
			M.force_music(media_url,media_start_time,volume)

/obj/machinery/media/jukebox/superjuke/adminbus
	name = "adminbus-mounted Jukebox"
	desc = "It really doesn't get any better."
	icon = 'icons/obj/bus.dmi'
	icon_state = ""
	light_color = LIGHT_COLOR_BLUE
	luminosity = 0
	plane = ABOVE_HUMAN_PLANE
	layer = ABOVE_OBJ_LAYER
	pixel_x = -WORLD_ICON_SIZE
	pixel_y = -WORLD_ICON_SIZE

	var/datum/browser/popup = null
	req_access = list()
	playlist_id="endgame"

/obj/machinery/media/jukebox/superjuke/adminbus/attack_hand(var/mob/user)
	var/t = "<div class=\"navbar\">"
	t += "<a href=\"?src=\ref[src];screen=[JUKEBOX_SCREEN_MAIN]\">Main</a>"
	t += "</div>"
	t += ScreenMain(user)

	user.set_machine(src)
	popup = new (user,"jukebox",name,420,700)
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

	if(icon_state != "jukebox")
		deploy()

/obj/machinery/media/jukebox/superjuke/adminbus/proc/deploy()
	update_media_source()
	icon_state = "jukebox"
	set_light(4)
	flick("deploying",src)

/obj/machinery/media/jukebox/superjuke/adminbus/proc/repack()
	if(playing)
		for(var/mob/M in range (src,1))
			to_chat(M, "<span class='notice'>The jukebox turns itself off to protect itself from any cahot induced damage.</span>")
	if(popup)
		popup.close()
	playing = 0
	set_light(0)
	icon_state = ""
	flick("repacking",src)
	update_music()
	disconnect_media_source()
	update_icon()

/obj/machinery/media/jukebox/superjuke/adminbus/update_icon()
	overlays.len = 0
	if(playing)
		overlays += image(icon = icon, icon_state = "beats")

/obj/machinery/media/jukebox/superjuke/adminbus/ex_act(severity)
	return

/obj/machinery/media/jukebox/superjuke/adminbus/cultify()
	return

/obj/machinery/media/jukebox/superjuke/adminbus/singularity_act()
	return 0

/obj/machinery/media/jukebox/superjuke/adminbus/singularity_pull()
	return 0

/obj/machinery/media/jukebox/holyjuke
	name = "Holyjuke"
	desc = "The Pastor's jukebox. You feel a weight being lifted simply by basking in its presence."

	state_base = "holyjuke"
	icon_state = "holyjuke"

	light_power_on = 2
	light_color = "#EFEFAA"

	change_cost = 0

	playlist_id="holy"
	// Must be defined on your server.
	playlists=list(
		"holy" = "Pastor's Paradise"
	)

/obj/machinery/media/jukebox/holyjuke/update_icon()
	..()
	if(!(stat & (FORCEDISABLE|NOPOWER|BROKEN)) && anchored && !any_power_cut())
		update_moody_light_index("glow",'icons/lighting/moody_lights.dmi', "overlay_juke_glow")

/obj/machinery/media/jukebox/holyjuke/attackby(obj/item/W, mob/user)
	// EMAG DOES NOTHING
	if(isEmag(W))
		to_chat(user, "<span class='warning'>A guiltiness fills your heart as a higher power pushes away \the [W]!</span>")
		return
	..()

/obj/item/weapon/vinyl
	name = "nanovinyl"
	desc = "In reality, the bulk of the disc serves only decorative purposes and the many songs are recorded on a very small microchip near the center."
	icon = 'icons/obj/jukebox.dmi'
	icon_state = "vinyl"
	flags = FPRINT
	siemens_coefficient = 1
	sharpness = 1
	force = 7
	throwforce = 7
	throw_speed = 7
	throw_range = 7
	w_class = W_CLASS_SMALL
	attack_verb = list("plays out", "records", "frisbees") //Fuck it, we'll do it live. Fucking thing sucks!
	var/unformatted
	var/formatted
	var/mask = "#FF0000"//red

/obj/item/weapon/vinyl/New(loc,U,F)
	..(loc)
	if(U)
		unformatted = U
	if(F)
		formatted = F
	name = "nanovinyl - [formatted]"
	for (var/vinyl_type in subtypesof(/obj/item/weapon/vinyl))
		var/obj/item/weapon/vinyl/V = vinyl_type
		if (initial(V.unformatted) == U)
			mask = initial(V.mask)
			break

	var/image/label = image(icon, src, "vinyl-mask")
	label.icon += mask
	overlays += label

//Premades
/obj/item/weapon/vinyl/bar
	name = "nanovinyl - bar"
	unformatted = "bar"
	formatted = "Bar"
	mask = "#800000"//maroon
/obj/item/weapon/vinyl/bomberman
	name = "nanovinyl - bomberman"
	unformatted = "bomberman"
	formatted = "Bomberman"
	mask = "#00FFFF"//cyan
/obj/item/weapon/vinyl/depresso
	name = "nanovinyl - depresso"
	unformatted = "depresso"
	formatted = "Depresso"
	mask = "#000000"//black
/obj/item/weapon/vinyl/echoes
	name = "nanovinyl - echoes"
	unformatted = "echoes"
	formatted = "Echoes"
/obj/item/weapon/vinyl/electronica
	name = "nanovinyl - electronic"
	unformatted = "electronica"
	formatted = "Electronic"
	mask = "#FFFFFF"//white
/obj/item/weapon/vinyl/emagged
	name = "nanovinyl - syndicate"
	unformatted = "emagged"
	formatted = "Syndicate Mix"
/obj/item/weapon/vinyl/endgame
	name = "nanovinyl - apocalypse"
	unformatted = "endgame"
	formatted = "Apocalypse"
/obj/item/weapon/vinyl/filk
	name = "nanovinyl - filk"
	unformatted = "filk"
	formatted = "Filk"
/obj/item/weapon/vinyl/funk
	name = "nanovinyl - funk"
	unformatted = "funk"
	formatted = "Funk"
/obj/item/weapon/vinyl/folk
	name = "nanovinyl - folk"
	unformatted = "folk"
	formatted = "Folk"
/obj/item/weapon/vinyl/idm
	name = "nanovinyl - 90's IDM"
	unformatted = "idm"
	formatted = "90's IDM"
/obj/item/weapon/vinyl/jazz
	name = "nanovinyl - jazz & swing"
	unformatted = "jazzswing"
	formatted = "Jazz & Swing"
/obj/item/weapon/vinyl/malf
	name = "nanovinyl - silicon assault"
	unformatted = "malfdelta"
	formatted = "Silicon Assault"
/obj/item/weapon/vinyl/medbay
	name = "nanovinyl - medbay"
	unformatted = "medbay"
	formatted = "Medbay"
/obj/item/weapon/vinyl/metal
	name = "nanovinyl - heavy metal"
	unformatted = "metal"
	formatted = "Heavy Metal"
/obj/item/weapon/vinyl/muzakjazz
	name = "nanovinyl - jazzy muzak"
	unformatted = "muzakjazz"
	formatted = "Muzak"
/obj/item/weapon/vinyl/syndie_assault
	name = "nanovinyl - syndicate assault"
	unformatted = "nukesquad"
	formatted = "Syndicate Assault"
/obj/item/weapon/vinyl/rap
	name = "nanovinyl - rap"
	unformatted = "rap"
	formatted = "Rap"
/obj/item/weapon/vinyl/rock
	name = "nanovinyl - rock"
	unformatted = "rock"
	formatted = "Rock"
/obj/item/weapon/vinyl/shoegaze
	name = "nanovinyl - shoegaze"
	desc = "More reverb than you can handle."
	unformatted = "shoegaze"
	formatted = "Shoegaze"
	mask = "#FF00FF"//magenta
/obj/item/weapon/vinyl/security
	name = "nanovinyl - security"
	unformatted = "security"
	formatted = "Security"
/obj/item/weapon/vinyl/shuttle
	name = "nanovinyl - shuttle"
	unformatted = "shuttle"
	formatted = "Shuttle"
	mask = "#000080"//navy
/obj/item/weapon/vinyl/thunderdome
	name = "nanovinyl - thunderdome"
	unformatted = "thunderdome"
	formatted =	"Thunderdome"
/obj/item/weapon/vinyl/upbeat_dance
	name = "nanovinyl - dance"
	unformatted = "upbeathypedancejam"
	formatted = "Dance"
/obj/item/weapon/vinyl/vidya
	name = "nanovynil - vidya"
	unformatted = "vidya"
	formatted = "Video Games"
	mask = "##0096FF"
/obj/item/weapon/vinyl/scotland
	name = "nanovinyl - highlander"
	desc = "Oh no."
	unformatted = "SCOTLANDFOREVER"
	formatted = "Highlander"
	mask = "#0000FF"//blue
/obj/item/weapon/vinyl/halloween
	name = "nanovinyl - halloween"
	unformatted = "halloween"
	formatted = "Halloween"
/obj/item/weapon/vinyl/slugger
	name = "nanovynil - slugger"
	desc = "A go-to for bars all over the sector. Every time you walk in one, you can almost bet it's playing."
	unformatted = "lilslugger"
	formatted = "Battle of Lil Slugger"
/obj/item/weapon/vinyl/christmas
	name = "nanovynil - christmas"
	unformatted = "christmas"
	formatted = "Christmas Jingles"
/obj/item/weapon/vinyl/holy
	name = "nanovinyl - holy"
	unformatted = "holy"
	formatted = "Holy"
	mask = "#8000FF"//purple
