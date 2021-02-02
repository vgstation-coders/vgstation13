/*
 * TODO:
 * Decide if we need fingerprints on this obj
 * Decide which other mob can use this
 * Sprite bar sign that is destroyed
 * Sprite bar sign that is unpowered
 * Add this obj to power consumers
 * Decide how much power this uses
 * Make this constructable with a decided step how to construct it
 * Make this deconstructable with a decided step how to deconstruct it
 * Decide what materials are used for this obj
 * Logic for area because it's a two tile consuming obj
 * Is this obj can be emagged? if yes what can be the trace that this obj is emagged?
 *									(I suggest broken ID authentication wiring)
 * Need more frames for existing bar signs (icons/obj/barsigns.dmi)
 * An ID scanner that will makes sound and
 *		output something that's the access has been granted
 */
var/list/barsigns = list()

/datum/barsign
	var/icon = "empty"
	var/name = "--------"
	var/desc = null
	var/pixel_x = 0
	var/pixel_y = 0

/datum/barsign/maltesefalcon
	name = "Maltese Falcon"
	icon = "maltesefalcon"
	desc = "Play it again, sam."

/obj/effect/overlay/kustom_barsign
	name = "Wowee"
	desc = "Its a error, If you see this"
	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_LAYER|VIS_INHERIT_PLANE

/datum/barsign/kkustom/custom_barsign
	name = "Custom Barsign"
	icon = "kustom"
	desc = "A barsign of custom variety"

/obj/structure/sign/double/barsign	// The sign is 64x32, so it needs two tiles. ;3
	name = "--------"
	desc = "a bar sign"
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"
	req_access = list(access_bar)
	//var/sign_name = ""
	var/cult = 0
//Custom Barsign Var shit
	var/obj/effect/overlay/kustom_barsign/ass = null
	var/list/sound_selection = list("Nothing",
									"Rooster",
									"Wolf",
									"Male Scream",
									"Female Scream",
									"Bike Horn"
									)
	var/sound_string = "Nothing"
//Custom Barsign Configurable Shit
	var/letter_message = "BAR"
	var/letter_color = "#1bf555"
	var/letter_size = "12"
//Interval Mode Shit for Custom Barsigns
	var/interval_mode = FALSE
	var/second_letter_message = "GRILL"
	var/second_letter_color = "#f51b1b"
	var/second_letter_size = "12"
	var/interval_ticker_end = 0
	var/current_sound = null //Must be a sound
	var/current_tone = 40000
	var/sound_volume = 50
//To help keep track of where process() at
	var/interval_ticker = 0
	var/already_fired = FALSE
	var/other_tick = FALSE

/obj/structure/sign/double/barsign/Destroy()
	if(ass)
		vis_contents -= ass
		qdel(ass)
		ass = null
	..()

/obj/structure/sign/double/barsign/ghetto
	req_access = null

/obj/structure/sign/double/barsign/attack_ai(mob/user)
	return attack_hand(user)

/obj/structure/sign/double/barsign/attack_hand(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	if(!barsigns.len)
		for(var/bartype in typesof(/datum/barsign))
			var/datum/barsign/signinfo = new bartype
			barsigns[signinfo.name] = signinfo

	pick_sign(user)

/obj/structure/sign/double/barsign/proc/pick_sign(mob/user)
	vis_contents.Cut()
	
	var/picked_name = input(user,"Available Signage", "Bar Sign", "Cancel") as null|anything in barsigns
	if(!picked_name)
		return

	var/datum/barsign/picked = barsigns[picked_name]
	icon_state = picked.icon
	if(istype(picked,/datum/barsign/kkustom))	
		if(!ass)
			ass = new()
		vis_contents += ass
		ass.maptext_width = 62 //Yeah guess what, it doesn't exit the actual icon
		ass.maptext_height = 29
		ass.maptext_x = 4
		ass.maptext_y = 4
		custom_barsign_menu(user)

	else
		clean_me_up()
		name = picked.name
		if(picked.pixel_x)
			pixel_x = picked.pixel_x * PIXEL_MULTIPLIER
		else
			pixel_x = 0
		if(picked.pixel_y)
			pixel_y = picked.pixel_y * PIXEL_MULTIPLIER
		else
			pixel_y = 0
		if(picked.desc)
			desc = picked.desc
		else
			desc = "It displays \"[name]\"."


/obj/structure/sign/double/barsign/proc/custom_barsign_menu(mob/user)
	var/dat
	var/interval_mode_string = "OFF"
	if(interval_mode)
		interval_mode_string = "ON"
	
	dat += {"
		<ul>
			<li><b>Set Sign Message:</b><a href="?src=\ref[src];set_sign_message=1">[letter_message]</a></li>
			<li><b>Set Sign Description:</b><a href="?src=\ref[src];set_sign_description=1">[desc]</a></li>
			<li><b>Set Letter Color:</b><a href="?src=\ref[src];set_letter_color=1"><span style='border:1px solid #161616; background-color: [letter_color];'>&nbsp;&nbsp;&nbsp;</span></a></li>
			<li><b>Set Letter Size:</b><a href="?src=\ref[src];set_letter_size=1">[letter_size]</a></li>
			<br><hr>
			<li><b>Interval Mode:</b><a href="?src=\ref[src];interval_mode=1">[interval_mode_string]</a></li>
			<li><b>Interval Mode Settings:</b>Interval needs to be above 0 to function.</li>
			<li><b>Set Intervals:</b><a href="?src=\ref[src];set_interval_tick_end=1">[interval_ticker_end]</a></li>
			<li><b>Set Secondary Color:</b><a href="?src=\ref[src];set_second_color=1"><span style='border:1px solid #161616; background-color: [second_letter_color];'>&nbsp;&nbsp;&nbsp;</span></a></li>
			<li><b>Set Secondary Message:</b><a href="?src=\ref[src];set_second_message=1">[second_letter_message]</a></li>
			<li><b>Set Secondary Size:</b><a href="?src=\ref[src];set_second_letter_size=1">[second_letter_size]</a></li>
			<li><b>Set Sound:</b><a href="?src=\ref[src];set_sound=1">[sound_string]</a></li>
			<li><b>Set Sound Tone:</b><a href="?src=\ref[src];set_sound_tone=1">[current_tone]</a></li>
			<li><b>Set Sound Volume:</b><a href="?src=\ref[src];set_sound_volume=1">[sound_volume]</a></li>
		</ul>
		<br><br><a href="?src=\ref[src];apply_settings=1">Apply Settings</a>
		"}


	var/datum/browser/popup = new(user, "barsignmenu", "Custom Barsign Menu",400,460)
	popup.set_content(dat)
	popup.open()

/obj/structure/sign/double/barsign/Topic(href, href_list)
	if(..())
		return
	if(in_range(src, usr) && isliving(usr))
		var/mob/living/user = usr

		if(href_list["set_sign_message"])
			var/sign_text = copytext(sanitize(input(user, "What would you like to write on this barsign?", "Custom Barsign", null) as text|null), 1, MAX_NAME_LEN*3)
			if(sign_text)
				name = sign_text 
				letter_message = sign_text
				log_game("[key_name(user)] changed barsign name to [letter_message]")
		if(href_list["set_sign_description"])
			var/desc_text = copytext(sanitize(input(user, "What would you like to have as the description?", "Custom Barsign Desc", null) as text|null), 1, MAX_NAME_LEN*3)
			if(desc_text)
				desc = desc_text
				log_game("[key_name(user)] changed barsign desc to [desc]")
		if(href_list["set_second_message"])
			var/sign_text = copytext(sanitize(input(user, "What would you like to on the interval message?", "Custom Barsign", null) as text|null), 1, MAX_NAME_LEN*3)
			if(sign_text)
				second_letter_message = sign_text
				log_game("[key_name(user)] changed barsign second name to [desc]")
		if(href_list["set_letter_color"])
			var/colorhex = input(user, "Choose your text color:", "Sign Color Selection",letter_color) as color|null
			if(colorhex)
				letter_color = colorhex
		
		if(href_list["set_letter_size"])
			var/font_size = input(user, "What size are the letters", "Letter Size", letter_size) as num|null
			if(font_size)
				letter_size = font_size

		if(href_list["set_second_letter_size"])
			var/font_size = input(user, "What size are the secondary letters", "Letter Size", second_letter_size) as num|null
			if(font_size)
				second_letter_size = font_size
		
		if(href_list["interval_mode"])
			interval_mode = !interval_mode
		
		if(href_list["set_interval_tick_end"])
			var/tick_interval = input(user, "What is the tick interval ending?", "Tick Interval End", interval_ticker_end) as num|null
			if(tick_interval)
				interval_ticker_end = tick_interval
		
		if(href_list["set_second_color"])
			var/colorhex = input(user, "Choose your secondary text color:", "Sign Color Selection 2", second_letter_color) as color|null
			if(colorhex)
				second_letter_color = colorhex
		
		if(href_list["set_sound"])
			var/picked_sound = input(user,"Available Sounds", "Sounds", "Cancel") as null|anything in sound_selection
			if(picked_sound)
				switch(picked_sound)
					if("Nothing")
						current_sound = null
					if("Rooster")
						current_sound = 'sound/misc/6amRooster.wav'
					if("Wolf")
						current_sound = 'sound/misc/6pmWolf.wav'
					if("Male Scream")
						current_sound = 'sound/misc/malescream5.ogg'
					if("Female Scream")
						current_sound = 'sound/misc/femalescream5.ogg'
					if("Bike Horn")
						current_sound = 'sound/items/bikehorn.ogg'
				sound_string = picked_sound

		if(href_list["set_sound_tone"])
			var/new_soundtone = input("Choose a new sound frequency 12000-55000:", "Sound Tone Menu", current_tone) as null|num
			if(new_soundtone)
				current_tone = clamp(new_soundtone,12000,55000)
		
		if(href_list["set_sound_volume"])
			var/new_volume = input("Choose a new sound volume 1-100:", "Sound Tone Menu",sound_volume) as null|num
			if(new_volume)
				sound_volume = clamp(new_volume,1,100)
		
		if(href_list["apply_settings"])
			if(interval_mode && interval_ticker_end)
				if(!already_fired)
					already_fired = TRUE
					processing_objects += src
			ass.maptext = "<span style=\"color:[letter_color];font-size:[letter_size]px;\">[letter_message]</span>"
		
		custom_barsign_menu(user)

/obj/structure/sign/double/barsign/process()
	if(!interval_mode)
		already_fired = FALSE
		processing_objects -= src
		interval_ticker = 0
		interval_ticker_end = 0
		current_sound = null
		ass.maptext = "<span style=\"color:[letter_color];font-size:[letter_size]px;\">[letter_message]</span>"
		return
	
	interval_ticker++
	
	if(interval_ticker >= interval_ticker_end)
		if(other_tick)
			ass.maptext = "<span style=\"color:[letter_color];font-size:[letter_size]px;\">[letter_message]</span>"
		else
			ass.maptext = "<span style=\"color:[second_letter_color];font-size:[second_letter_size]px;\">[second_letter_message]</span>"
		if(current_sound)
			playsound(src, current_sound, sound_volume, 1,frequency = current_tone)
		other_tick = !other_tick
		interval_ticker = 0

/*
	Cleans up the object for the emp/cult shit if interval mode on
*/
/obj/structure/sign/double/barsign/proc/clean_me_up()
	if(interval_mode)
		already_fired = FALSE
		processing_objects -= src
		interval_ticker = 0
		interval_ticker_end = 0
		current_sound = null
		vis_contents.Cut()

/obj/structure/sign/double/barsign/cultify()
	if(!cult)
		clean_me_up()
		icon_state = "narsiebistro"
		name = "Narsie Bistro"
		desc = "The last pub before the World's End."
		cult = 1
		pixel_x = 0 // just to make sure.
		pixel_y = 0

/obj/structure/sign/double/barsign/emp_act()
	clean_me_up()
	icon_state = "empbarsign"
	name = "ERROR"
	desc = "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4#*?"
	pixel_x = 0
	pixel_y = 0
