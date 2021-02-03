/*
 * TODO: 2/2/2021
 */
var/list/barsigns = list()

#define PREMADE_SCREEN 0
#define CUSTOM_SCREEN 1

#define MAX_QUEUE_LIMIT 31 //Max amount of entries we can make
#define MAX_FILTER_LIMIT 3 //You only get 3

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

/obj/effect/overlay/custom_barsign
	name = "Wowee"
	desc = "Its a error, If you see this"
	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_LAYER|VIS_INHERIT_PLANE

/obj/structure/sign/double/barsign	// The sign is 64x32, so it needs two tiles. ;3
	name = "--------"
	desc = "a bar sign"
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"
	req_access = list(access_bar)
	var/cult = 0

	var/current_screen = PREMADE_SCREEN
//Predef Barsign Var Shit
	var/datum/barsign/current_preview = null //What are we on, the drop down still exists tho
	var/current_position = 1

//Custom Barsign Var shit
	var/obj/effect/overlay/custom_barsign/ass = null
	var/list/sound_selection = list("Nothing" = null,
									"Rooster" = 'sound/misc/6amRooster.wav',
									"Wolf" = 'sound/misc/6pmWolf.wav',
									"Male Scream" = 'sound/misc/malescream5.ogg',
									"Female Scream" = 'sound/misc/femalescream5.ogg',
									"Vox Scream" = 'sound/misc/shriek1.ogg',
									"Bike Horn" = 'sound/items/bikehorn.ogg'
									)
	
	//Dropshadows are safe, waves... might brutalize clients but they have a v limited amount of filters to use
	var/list/filter_selection = list("Nothing",
									"Dropshadow" = list("color" = "#1bf555"),
										"Waves")
	var/current_filter = "Nothing"
//Custom Barsign Configurable Shit
//Basically its a list, each index number is the current tick,
//So you could make a shitty song I guess.
//Also If you are asking why the numbers are strings, then I think its safer/less problematic(?)
	var/list/interval_queue = list("1" = list("letter_message" = "JTGSZ",
											"letter_color" = "#1bf555",
											"letter_size" = "12",
											"sound_key" = "Nothing",
											"sound_tone" = 40000,
											"sound_volume" = 50),
									"2" = list("letter_message" = "THE BEST",
											"letter_color" = "#f51b1b",
											"letter_size" = "12",
											"sound_key" = "Nothing",
											"sound_tone" = 40000,
											"sound_volume" = 50))

//Interval Mode Shit for Custom Barsigns
	var/interval_mode = FALSE
//To help keep track of where process() at
	var/interval_ticker = 0
	var/already_fired = FALSE


/obj/structure/sign/double/barsign/Destroy()
	if(ass)
		vis_contents -= ass
		ass.filters = null
		qdel(ass)
		ass = null
	current_preview = null
	if(interval_mode)
		processing_objects -= src
	..()

/obj/structure/sign/double/barsign/ghetto
	req_access = null

/obj/structure/sign/double/barsign/attack_ai(mob/user)
	return attack_hand(user)

/obj/structure/sign/double/barsign/attack_ghost(mob/user)
	if(isAdminGhost(user))
		attack_hand(user)

/obj/structure/sign/double/barsign/attack_hand(mob/user)
	if(!isAdminGhost(user))
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access denied.</span>")
			return

	if(!barsigns.len)
		for(var/bartype in typesof(/datum/barsign))
			var/datum/barsign/signinfo = new bartype
			barsigns[signinfo.name] = signinfo

	if(!current_preview)
		for(var/fuckyou in barsigns)
			current_preview = barsigns[fuckyou]
			break
	
	if(!ass)
		ass = new()

	barsign_menu(user)

/obj/structure/sign/double/barsign/proc/barsign_menu(mob/user)
	var/dat
	//SCREEN SELECTION
	dat += {"
			<b>Menus Available:
			<a href='?src=\ref[src];current_screen=premade'>Pre-Defined</a>
			<a href='?src=\ref[src];current_screen=custom_screen'>Custom Menu</a>
			<hr>
			"}
	if(current_screen == CUSTOM_SCREEN) //CUSTOM SCREEN
		var/interval_mode_string = "OFF"
		if(interval_mode)
			interval_mode_string = "ON"
		
		dat += "Screen Filter: <a href=\"?src=\ref[src];set_filter=choose\">[current_filter]</a>"
		if(current_filter == "Dropshadow")
			dat += "<a href=\"?src=\ref[src];set_filter=dshadow_color\"><span style='border:1px solid #161616; background-color: [filter_selection["Dropshadow"]["color"]];'>&nbsp;&nbsp;&nbsp;</span></a>"
		
		dat += "<a href=\"?src=\ref[src];set_filter=[current_filter]\">Apply Filter</a>"
		dat += "<br><b>Interval Mode:</b><a href=\"?src=\ref[src];interval_mode=1\">[interval_mode_string]</a><br><hr>"
		
		for(var/i in interval_queue)
			dat += {"
					<div style="width:100%; background-color:#1f1c1c; border-style:solid; border-color: #999797">
						Msg: <a href="?src=\ref[src];set_message=[i]">[interval_queue[i]["letter_message"]]</a>
						Color: <a href="?src=\ref[src];set_letter_color=[i]"><span style='border:1px solid #161616; background-color: [interval_queue[i]["letter_color"]];'>&nbsp;&nbsp;&nbsp;</span></a>
						Size: <a href="?src=\ref[src];set_letter_size=[i]">[interval_queue[i]["letter_size"]]</a>
						<br>Sound: <a href="?src=\ref[src];set_sound=[i]">[interval_queue[i]["sound_key"]]</a>
						Sound Tone: <a href="?src=\ref[src];set_sound_tone=[i]">[interval_queue[i]["sound_tone"]]</a>
						Sound Vol: <a href="?src=\ref[src];set_sound_volume=[i]">[interval_queue[i]["sound_volume"]]</a>
						<a href='?src=\ref[src];delete_block=[i]'>Delete</a>
					</div>
					"}
			
		dat += "<br><a href='?src=\ref[src];add_block=1'>Add Block</a>"
		dat += "<br><a href=\"?src=\ref[src];apply_settings=custom_screen\">Apply Settings</a>"

				 
	if(current_screen == PREMADE_SCREEN) //PRE-DEFINED SCREEN
		user << browse_rsc(icon('icons/obj/barsigns.dmi', "[current_preview.icon]"), "cur_barsign.png")
		dat += {"<div id="fuck" style="width:100%; height:100%; display:flex;">
					<div style="float: left; width: 50%">
						<b>Current Selection</b><br>
						<b>Name:</b>[current_preview.name]<br>
						<b>Desc:</b>[current_preview.desc]<br>
					</div>
					<div style="float:right; width:50%; background-color:#1f1c1c; border-style:solid; border-color: #999797">
						<img src="cur_barsign.png">
						<a href="?src=\ref[src];change_img=prev" title="Previous">["&larr;"]</a>
						<a href="?src=\ref[src];change_img=next" title="Next">["&rarr;"]</a>
					</div>
				</div>
				<div id="fuuuuuuck">
					<a href="?src=\ref[src];direct_select=1">Direct Select</a>
					<a href="?src=\ref[src];apply_settings=premade">Apply Settings</a><br>
				</div>
				"}

	var/datum/browser/popup = new(user, "barsignmenu", "Custom Barsign Menu",500,500)
	popup.set_content(dat)
	popup.open()

/obj/structure/sign/double/barsign/Topic(href, href_list)
	if(..())
		return
	if(in_range(src, usr) && isliving(usr) || isAdminGhost(usr))
		var/mob/user = usr
		
		if(href_list["direct_select"])
			var/picked_name = input(user,"Available Signage", "Bar Sign", "Cancel") as null|anything in barsigns
			if(!picked_name)
				return
			
			current_preview = barsigns[picked_name]
			
		if(href_list["change_img"])
			var/name_string //ah man i am still unsure if i should be keeping barsigns as a assc list at this point.
			switch(href_list["change_img"])
				if("next")
					if(current_position+1 <= barsigns.len)
						name_string = barsigns[current_position+1]
						current_position = current_position+1
				if("prev")
					if(current_position-1 > 0)
						name_string = barsigns[current_position-1]
						current_position = current_position-1
			current_preview = barsigns[name_string]

		if(href_list["current_screen"])
			switch(href_list["current_screen"])
				if("premade")
					current_screen = PREMADE_SCREEN
				if("custom_screen")
					current_screen = CUSTOM_SCREEN
		

		if(href_list["apply_settings"])
			vis_contents.Cut()
			switch(href_list["apply_settings"])
				if("premade")
					clean_me_up()
					icon_state = current_preview.icon
					name = current_preview.name
					if(current_preview.pixel_x)
						pixel_x = current_preview.pixel_x * PIXEL_MULTIPLIER
					else
						pixel_x = 0
					if(current_preview.pixel_y)
						pixel_y = current_preview.pixel_y * PIXEL_MULTIPLIER
					else
						pixel_y = 0
					if(current_preview.desc)
						desc = current_preview.desc
					else
						desc = "It displays \"[name]\"."					
				if("custom_screen")
					icon_state = "kustom"
					vis_contents += ass
					ass.maptext_width = 62 //Yeah guess what, it doesn't exit the actual icon
					ass.maptext_height = 29
					ass.maptext_x = 4
					ass.maptext_y = 4
					if(interval_mode)
						if(!already_fired)
							already_fired = TRUE
							processing_objects += src
					else
						interval_ticker = 0
						var/string = interval_queue["1"]["letter_message"]
						if(string)
							ass.maptext = "<span style=\"color:[interval_queue["1"]["letter_color"]];font-size:[interval_queue["1"]["letter_size"]]px;\">[interval_queue["1"]["letter_message"]]</span>"
		
		if(href_list["set_filter"])
			switch(href_list["set_filter"])
				if("choose")
					var/picked_filter = input(user,"Available Filters", "Filters", "Cancel") as null|anything in filter_selection
					if(picked_filter)
						current_filter = picked_filter
				if("Nothing")
					ass.filters = null //SPECIAL LIST, IT CANNOT BE CUT NOOOOOOOOO
				if("Dropshadow")
					if(ass.filters.len <= MAX_FILTER_LIMIT)
						ass.filters += filter(type="drop_shadow", x=0, y=0, size=3, offset=2, color="[filter_selection["Dropshadow"]["color"]]")
				if("dshadow_color")
					var/colorhex = input(user, "Choose your dropshadow color:", "Sign Color Selection",filter_selection["Dropshadow"]["color"]) as color|null
					if(colorhex)
						filter_selection["Dropshadow"]["color"] = colorhex					
				if("Waves")
					if(ass.filters.len <= MAX_FILTER_LIMIT)
						summon_shitty_example_waves()

		if(href_list["delete_block"])
			var/safety = text2num(href_list["delete_block"])
			if(safety > 1)
				interval_queue -= interval_queue[safety]
		
		if(href_list["add_block"])
			if(interval_queue.len <= MAX_QUEUE_LIMIT)
				interval_queue["[interval_queue.len+1]"] = list("letter_message" = "BAR",
															"letter_color" = "#1bf555",
															"letter_size" = "12",
															"sound_key" = "Nothing",
															"sound_tone" = 40000,
															"sound_volume" = 50)

		if(href_list["set_message"])
			var/sign_text = copytext(sanitize(input(user, "What would you like to write on this barsign?", "Custom Barsign", null) as text|null), 1, MAX_NAME_LEN*3)
			if(sign_text)
				var/safety = text2num(href_list["set_message"])
				if(safety <= MAX_QUEUE_LIMIT)
					name = sign_text 
					interval_queue["[safety]"]["letter_message"] = sign_text
					log_game("[key_name(user)] changed barsign name to [sign_text]")
		
		if(href_list["set_description"])
			var/desc_text = copytext(sanitize(input(user, "What would you like to have as the description?", "Custom Barsign Desc", null) as text|null), 1, MAX_NAME_LEN*3)
			if(desc_text)
				desc = desc_text
				log_game("[key_name(user)] changed barsign desc to [desc]")

		if(href_list["set_letter_color"])
			var/safety = text2num(href_list["set_letter_color"])
			if(safety <= MAX_QUEUE_LIMIT)
				var/colorhex = input(user, "Choose your text color:", "Sign Color Selection",interval_queue["[safety]"]["letter_color"]) as color|null
				if(colorhex)
					interval_queue["[safety]"]["letter_color"] = colorhex

		if(href_list["set_letter_size"])
			var/safety = text2num(href_list["set_letter_size"])
			if(safety <= MAX_QUEUE_LIMIT)
				var/font_size = input(user, "What size are the letters", "Letter Size", interval_queue["[safety]"]["letter_size"]) as num|null
				if(font_size)
					interval_queue["[safety]"]["letter_size"] = font_size //This shit can't go outside of the maptext box anyways, so they get disappointment

		if(href_list["interval_mode"])
			interval_mode = !interval_mode
		
		if(href_list["set_sound"])
			var/safety = text2num(href_list["set_sound"])
			if(safety <= MAX_QUEUE_LIMIT)
				var/picked_sound = input(user,"Available Sounds", "Sounds", "Cancel") as null|anything in sound_selection
				if(picked_sound)
					interval_queue["[safety]"]["sound_key"] = picked_sound

		if(href_list["set_sound_tone"])
			var/safety = text2num(href_list["set_sound_tone"])
			if(safety <= MAX_QUEUE_LIMIT)
				var/new_soundtone = input("Choose a new sound frequency 12000-55000:", "Sound Tone Menu", interval_queue["[safety]"]["sound_tone"]) as null|num
				if(new_soundtone)
					interval_queue["[safety]"]["sound_tone"] = clamp(new_soundtone,12000,55000)
		
		if(href_list["set_sound_volume"])
			var/safety = text2num(href_list["set_sound_volume"])
			if(safety <= MAX_QUEUE_LIMIT)
				var/new_volume = input("Choose a new sound volume 1-100:", "Sound Tone Menu",interval_queue["[safety]"]["sound_volume"]) as null|num
				if(new_volume)
					interval_queue["[safety]"]["sound_volume"] = clamp(new_volume,1,100)

		barsign_menu(user)

/obj/structure/sign/double/barsign/process()
	if(!interval_mode)
		processing_objects -= src
		interval_ticker = 0
		already_fired = FALSE
		return
	
	interval_ticker++
	var/check_sound = sound_selection["[interval_queue["[interval_ticker]"]["sound_key"]]"]
	if(check_sound)
		playsound(src, check_sound, interval_queue["[interval_ticker]"]["sound_volume"], 1, frequency = interval_queue["[interval_ticker]"]["sound_tone"])
	ass.maptext = "<span style=\"color:[interval_queue["[interval_ticker]"]["letter_color"]];font-size:[interval_queue["[interval_ticker]"]["letter_size"]]px;\">[interval_queue["[interval_ticker]"]["letter_message"]]</span>"
	if(interval_ticker >= interval_queue.len)
		interval_ticker = 0

/*
	Cleans up the object for the emp/cult shit if interval mode on
*/
/obj/structure/sign/double/barsign/proc/clean_me_up()
	vis_contents.Cut()
	if(interval_mode)
		processing_objects -= src
		interval_mode = FALSE
		already_fired = FALSE
		interval_ticker = 0

/*
	Don't hate on me, its literally the example for waves in the byond ref
*/
/obj/structure/sign/double/barsign/proc/summon_shitty_example_waves()
	var/start = ass.filters.len
	var/X
	var/Y
	var/rsq
	var/i
	var/waves
	for(i=1, i<=7, ++i)
		// choose a wave with a random direction and a period between 10 and 30 pixels
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while(rsq<100 || rsq>900)   // keep trying if we don't like the numbers
		// keep distortion (size) small, from 0.5 to 3 pixels
		// choose a random phase (offset)
		ass.filters += filter(type="wave", x=X, y=Y, size=rand()*2.5+0.5, offset=rand())
	for(i=1, i<=7, ++i)
		// animate phase of each wave from its original phase to phase-1 and then reset;
		// this moves the wave forward in the X,Y direction
		waves = ass.filters[start+i]
		animate(waves, offset=waves:offset, time=0, loop=-1, flags=ANIMATION_PARALLEL)
		animate(offset=waves:offset-1, time=rand()*20+10)


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

#undef PREMADE_SCREEN
#undef CUSTOM_SCREEN
#undef MAX_QUEUE_LIMIT
#undef MAX_FILTER_LIMIT