/*******************************
 * Largely a rewrite of the Jukebox from D2K5
 *
 * By N3X15
 *******************************/
// For error handling.
#define PLAYLIST_INVALID		-1 // When we don't get JSON back
#define PLAYLIST_EMPTY			-2 // When our playlist came back empty
#define PLAYLIST_NULL_RESPONSE	-3 // When the HTTP request returns null
#define PLAYLIST_SERVER_ERROR	-4 // When the media server errors (N3X15's new code anyway)

#define JUKEMODE_SHUFFLE     1 // Default
#define JUKEMODE_REPEAT_SONG 2
#define JUKEMODE_PLAY_ONCE   3 // Play, then stop.
#define JUKEMODE_COUNT       3

#define JUKEBOX_SCREEN_MAIN     1 // Default
#define JUKEBOX_SCREEN_PAYMENT  2
#define JUKEBOX_SCREEN_SETTINGS 3

#define JUKEBOX_RELOAD_COOLDOWN 600 // 60s

// Global juke playlist.
var/global/global_playlists = list()
/proc/load_juke_playlists()
	if(!config.media_base_url)
		return
	for(var/playlist_id in list("bar", "jazz", "rock", "muzak", "emagged", "endgame", "clockwork", "vidyaone", "vidyatwo", "vidyathree", "vidyafour"))
		var/playlist = get_playlist(playlist_id)
		if(!istype(playlist, /list))
			continue
		global_playlists["[playlist_id]"] = playlist

/proc/get_playlist(var/playlistid)
	if(isnull(playlistid))
		return
	var/url="[config.media_base_url]/index.php?playlist=[playlistid]"
	testing("Updating playlist from [url]...")

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
		var/json = file2text(response["CONTENT"])
		if("/>" in json)
			return PLAYLIST_INVALID
		var/list/songdata = json_decode(json)
		if(!isnull(songdata["errors"])) // If we get back JSON that looks like {"errors:":[]}
			return PLAYLIST_SERVER_ERROR

		for(var/list/record in songdata)
			playlist += new /datum/song_info(record)
		if(playlist.len==0)
			return PLAYLIST_EMPTY
		return playlist
	else
		return PLAYLIST_NULL_RESPONSE

/obj/machinery/media/jukebox/proc/retrieve_playlist(var/playlistid = playlist_id)
	if(!config.media_base_url || !playlistid)
		return
	playlist_id = playlistid
	if(global_playlists["[playlistid]"])
		var/list/temp = global_playlists["[playlistid]"]
		playlist = temp.Copy()

	else
		var/list_get = get_playlist(playlist_id)
		if(istype(list_get, /list) && isnull(list_get["errors"])) // No errors
			playlist = list_get
			global_playlists["[playlistid]"] = playlist.Copy()
			visible_message("<span class='notice'>[bicon(src)] \The [src] beeps, and the menu on its front fills with [playlist.len] items.</span>","<em>You hear a beep.</em>")
		else // Something errored
			if(PLAYLIST_NULL_RESPONSE)
				testing("[src] failed to update playlist: Response null.")
			visible_message("<span class='warning'>[bicon(src)] \The [src] buzzes, unable to update its playlist.</span>","<em>You hear a buzz.</em>")
			// These lines would mean that the jukebox would have to be maintained every time the playlist failed to load
			// But they also didn't break the juke in the first place because it should have been |= not &=
			// stat &= BROKEN
			//update_icon()
			return 0
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

	var/emagged = 0

	New(var/list/json)
		title  = json["title"]
		artist = json["artist"]
		album  = json["album"]

		url    = json["url"]

		length = text2num(json["length"])

	proc/display()
		var/str="\"[title]\""
		if(artist!="")
			str += ", by [artist]"
		if(album!="")
			str += ", from '[album]'"
		return str

	proc/displaytitle()
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
	luminosity = 4 // Why was this 16

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

/obj/machinery/media/jukebox/New(loc)
	..(loc)
	allowed_modes = loopModeNames.Copy()
	wires = new(src)
	if(department)
		linked_account = department_accounts[department]
	else
		linked_account = station_account

/obj/machinery/media/jukebox/Destroy()
	if(wires)
		qdel(wires)
		wires = null
	..()

/obj/machinery/media/jukebox/attack_ai(var/mob/user)
	attack_hand(user)

/obj/machinery/media/jukebox/attack_paw(var/mob/user)
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	attack_hand(user)

/obj/machinery/media/jukebox/power_change()
	..()
	if(emagged && !(stat & (NOPOWER|BROKEN)) && !any_power_cut())
		playing = 1
		if(current_song)
			update_music()
	update_icon()

/obj/machinery/media/jukebox/proc/any_power_cut()
	var/total = wires.IsIndexCut(JUKE_POWER_ONE) || wires.IsIndexCut(JUKE_POWER_TWO) || wires.IsIndexCut(JUKE_POWER_THREE)
	return total

/obj/machinery/media/jukebox/update_icon()
	overlays = 0
	if(stat & (NOPOWER|BROKEN) || !anchored || any_power_cut())
		if(stat & BROKEN)
			icon_state = "[state_base]-broken"
		else
			icon_state = "[state_base]-nopower"
		stop_playing()
		return
	icon_state = state_base
	if(playing)
		if(emagged)
			overlays += image(icon = icon, icon_state = "[state_base]-emagged")
		else
			overlays += image(icon = icon, icon_state = "[state_base]-running")

/obj/machinery/media/jukebox/proc/check_reload()
	return world.time > last_reload + JUKEBOX_RELOAD_COOLDOWN

/obj/machinery/media/jukebox/attack_hand(var/mob/user)
	if(stat & NOPOWER || any_power_cut())
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
	var/dat={"<h1>Settings</h1>
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
		<input type="submit" name="act" value="Save Settings" />
		</form>"}
	return dat



/obj/machinery/media/jukebox/attackby(obj/item/W, mob/user)
	. = ..()
	if(.)
		return .
	if(iswiretool(W))
		if(panel_open)
			wires.Interact(user)
		return
	if(istype(W,/obj/item/weapon/card/id))
		if(!selected_song || screen!=JUKEBOX_SCREEN_PAYMENT)
			visible_message("<span class='notice'>The machine buzzes.</span>","<span class='warning'>You hear a buzz.</span>")
			return
		var/obj/item/weapon/card/id/I = W
		if(!linked_account)
			visible_message("<span class='warning'>The machine buzzes, and flashes \"NO LINKED ACCOUNT\" on the screen.</span>","You hear a buzz.")
			return
		var/datum/money_account/acct = get_card_account(I)
		if(!acct)
			visible_message("<span class='warning'>The machine buzzes, and flashes \"NO ACCOUNT\" on the screen.</span>","You hear a buzz.")
			return
		if(credits_needed > acct.money)
			visible_message("<span class='warning'>The machine buzzes, and flashes \"NOT ENOUGH FUNDS\" on the screen.</span>","You hear a buzz.")
			return
		visible_message("<span class='notice'>The machine beeps happily.</span>","You hear a beep.")
		acct.charge(credits_needed,linked_account,"Song selection at [areaMaster.name]'s [name].")
		credits_needed = 0

		successful_purchase()

		attack_hand(user)
	else if(istype(W,/obj/item/weapon/spacecash))
		if(!selected_song || screen!=JUKEBOX_SCREEN_PAYMENT)
			visible_message("<span class='notice'>The machine buzzes.</span>","<span class='warning'>You hear a buzz.</span>")
			return
		if(!linked_account)
			visible_message("<span class='warning'>The machine buzzes, and flashes \"NO LINKED ACCOUNT\" on the screen.</span>","You hear a buzz.")
			return
		var/obj/item/weapon/spacecash/C=W
		credits_held += C.worth*C.amount
		if(credits_held >= credits_needed)
			visible_message("<span class='notice'>The machine beeps happily.</span>","You hear a beep.")
			credits_held -= credits_needed
			credits_needed=0
			screen=JUKEBOX_SCREEN_MAIN
			if(credits_held)
				var/obj/item/weapon/storage/box/B = new(loc)
				dispense_cash(credits_held,B)
				B.name="change"
				B.desc="A box of change."
			credits_held=0

			successful_purchase()
		attack_hand(user)

/obj/machinery/media/jukebox/emag(mob/user)
	if(!emagged)
		user.visible_message("<span class='warning'>[user.name] slides something into the [src.name]'s card-reader.</span>","<span class='warning'>You short out the [src.name].</span>")
		wires.CutWireIndex(JUKE_CONFIG)
		short()
	return

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
	update_icon()
	update_music()

/obj/machinery/media/jukebox/wrenchAnchor(mob/user)
	if(..())
		playing = emagged
		update_music()
		update_icon()

/obj/machinery/media/jukebox/proc/successful_purchase()
		next_song = selected_song
		selected_song = 0
		screen = JUKEBOX_SCREEN_MAIN

/obj/machinery/media/jukebox/proc/rad_pulse() //Called by pulsing the transmit wire
	for(var/mob/living/carbon/M in view(src,3))
		var/rads = 50 * sqrt( 1 / (get_dist(M, src) + 1) ) //It's like a transmitter, but 1/3 as powerful
		if(istype(M,/mob/living/carbon/human))
			M.apply_effect((rads*2),IRRADIATE)
		else
			M.radiation += rads

/obj/machinery/media/jukebox/Topic(href, href_list)
	if(isobserver(usr) && !isAdminGhost(usr))
		to_chat(usr, "<span class='warning'>You can't push buttons when your fingers go right through them, dummy.</span>")
		return
	if(..())
		return 1
	if(emagged)
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
				if("lock" in href_list && href_list["lock"] != "")
					change_access = list(text2num(href_list["lock"]))
				else
					change_access = list()

				screen=POS_SCREEN_SETTINGS

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

	if (href_list["song"])
		if(wires.IsIndexCut(JUKE_CAPITAL))
			to_chat(usr, "<span class='warning'>You select a song, but [src] is unresponsive...</span>")
			return
		if(isobserver(usr) && !canGhostWrite(usr,src,""))
			to_chat(usr, "<span class='warning'>You can't do that.</span>")
			return
		selected_song=Clamp(text2num(href_list["song"]),1,playlist.len)
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
		if(current_song && playlist.len)
			song = playlist[current_song]
		if(!current_song || (song && world.time >= media_start_time + song.length))
			current_song=1
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
					if(JUKEMODE_REPEAT_SONG)
						current_song=current_song
					if(JUKEMODE_PLAY_ONCE)
						playing=0
						update_icon()
						return
			update_music()

/obj/machinery/media/jukebox/update_music()
	if(!playlist)
		process()
		if(!playlist || !playlist.len)
			return
	if(current_song > playlist.len)
		current_song = 0
	if(current_song && playing)
		var/datum/song_info/song = playlist[current_song]
		media_url = song.url
		last_song = current_song
		media_start_time = world.time
		visible_message("<span class='notice'>[bicon(src)] \The [src] begins to play [song.display()].</span>","<em>You hear music.</em>")
		//visible_message("<span class='notice'>[bicon(src)] \The [src] warbles: [song.length/10]s @ [song.url]</notice>")
	else
		media_url=""
		media_start_time = 0
	..()

/obj/machinery/media/jukebox/proc/stop_playing()
	//current_song=0
	playing=0
	update_music()
	return


/obj/machinery/media/jukebox/npc_tamper_act(mob/living/L)
	if(!panel_open)
		togglePanelOpen(null, L)
	if(wires)
		wires.npc_tamper(L)

/obj/machinery/media/jukebox/kick_act(mob/living/H)
	..()
	if(stat & NOPOWER || any_power_cut())
		return
	playing=!playing
	update_music()
	update_icon()

/obj/machinery/media/jukebox/bar
	department = "Civilian"
	req_access = list(access_bar)

	playlist_id="bar"
	// Must be defined on your server.
	playlists=list(
		"bar"  = "Bar Mix",
		"jazz" = "Jazz",
		"rock" = "Rock",
		"vidyaone" = "Vidya Pt.1",
		"vidyatwo" = "Vidya Pt.2",
		"vidyathree" = "Vidya Pt.3",
		"vidyafour" = "Vidya Pt.4",
	)

// Relaxing elevator music~
/obj/machinery/media/jukebox/dj

	playlist_id="muzak"
	autoplay = 1
	change_cost = 0

	id_tag="DJ Satellite" // For autolink

	// Must be defined on your server.
	playlists=list(
		"bar"  = "Bar Mix",
		"jazz" = "Jazz",
		"rock" = "Rock",
		"muzak" = "Muzak",
		"thunderdome" = "Thunderdome", // For thunderdome I guess
		"vidyaone" = "Vidya Pt.1",
		"vidyatwo" = "Vidya Pt.2",
		"vidyathree" = "Vidya Pt.3",
		"vidyafour" = "Vidya Pt.4",
	)

// So I don't have to do all this shit manually every time someone sacrifices pun-pun.
// Also for debugging.
/obj/machinery/media/jukebox/superjuke
	name = "Super Juke"
	desc = "The ultimate jukebox. Your brain begins to liquify from simply looking at it."

	state_base = "superjuke"
	icon_state = "superjuke"

	change_cost = 0

	playlist_id="bar"
	// Must be defined on your server.
	playlists=list(
		"bar"  = "Bar Mix",
		"jazz" = "Jazz",
		"rock" = "Rock",
		"muzak" = "Muzak",


		"emagged" = "Syndie Mix",
		"shuttle" = "Shuttle",

		"endgame" = "Apocalypse",
		"clockwork" = "Clockwork", // Unfinished new cult stuff
		"thunderdome" = "Thunderdome", // For thunderdome I guess
//Vidya musak
		"vidyaone" = "Vidya Pt.1",
		"vidyatwo" = "Vidya Pt.2",
		"vidyathree" = "Vidya Pt.3",
		"vidyafour" = "Vidya Pt.4",
	)

/obj/machinery/media/jukebox/superjuke/attackby(obj/item/W, mob/user)
	// NO FUN ALLOWED.  Emag list is included, anyway.
	if(istype(W, /obj/item/weapon/card/emag))
		to_chat(user, "<span class='warning'>Your [W] refuses to touch \the [src]!</span>")
		return
	..()

/obj/machinery/media/jukebox/superjuke/shuttle
	playlist_id="shuttle"
	id_tag="Shuttle" // For autolink


/obj/machinery/media/jukebox/superjuke/thematic
	playlist_id="endgame"

/obj/machinery/media/jukebox/superjuke/thematic/update_music()
	if(current_song && playing)
		var/datum/song_info/song = playlist[current_song]
		media_url = song.url
		last_song = current_song
		media_start_time = world.time
		visible_message("<span class='notice'>[bicon(src)] \The [src] begins to play [song.display()].</span>","<em>You hear music.</em>")
		//visible_message("<span class='notice'>[bicon(src)] \The [src] warbles: [song.length/10]s @ [song.url]</notice>")
	else
		media_url=""
		media_start_time = 0

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
	plane = EFFECTS_PLANE
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
	if(playing)
		overlays += image(icon = icon, icon_state = "beats")
	else
		overlays = 0
	return

/obj/machinery/media/jukebox/superjuke/adminbus/ex_act(severity)
	return

/obj/machinery/media/jukebox/superjuke/adminbus/cultify()
	return
