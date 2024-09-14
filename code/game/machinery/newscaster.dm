//##############################################
//################### NEWSCASTERS BE HERE! ####
//###-Agouri###################################

#define NEWSCASTER_MENU 0
#define NEWSCASTER_CHANNEL_LIST 1
#define NEWSCASTER_NEW_CHANNEL 2
#define NEWSCASTER_NEW_MESSAGE 3
#define NEWSCASTER_NEW_MESSAGE_SUCCESS 4
#define NEWSCASTER_NEW_CHANNEL_SUCCESS 5
#define NEWSCASTER_NEW_MESSAGE_ERROR 6
#define NEWSCASTER_NEW_CHANNEL_ERROR 7
#define NEWSCASTER_PRINT_NEWSPAPER 8
#define NEWSCASTER_VIEW_CHANNEL 9
#define NEWSCASTER_CENSORSHIP_MENU 10
#define NEWSCASTER_D_NOTICE_MENU 11
#define NEWSCASTER_CENSORSHIP_CHANNEL 12
#define NEWSCASTER_D_NOTICE_CHANNEL 13
#define NEWSCASTER_WANTED 14
#define NEWSCASTER_WANTED_SUCCESS 15
#define NEWSCASTER_WANTED_ERROR 16
#define NEWSCASTER_WANTED_DELETED 17
#define NEWSCASTER_WANTED_SHOW 18
#define NEWSCASTER_WANTED_EDIT 19
#define NEWSCASTER_PRINT_NEWSPAPER_SUCCESS 20
#define NEWSCASTER_PRINT_NEWSPAPER_ERROR 21

/datum/feed_message
	var/author =""
	var/headline = ""
	var/body =""
	//var/parent_channel

	//Backup variables are used to store the details of the message if it's redacted so it can be unredacted safely
	var/backup_author =""
	var/backup_headline = ""
	var/backup_body =""
	var/is_admin_message = FALSE

	var/author_log // Log of the person who did it.

	var/icon/img = null
	var/icon/backup_img
	var/icon/img_pda = null
	var/icon/backup_img_pda
	var/img_info = "" //Stuff like "You can see Honkers on the photo. Honkers looks hurt..."

/datum/feed_channel
	var/channel_name=""
	var/backup_name = ""
	var/list/datum/feed_message/messages = list()
	var/locked = FALSE
	var/author = ""
	var/backup_author = ""
	var/censored = FALSE
	var/is_admin_channel = FALSE
	var/anonymous = FALSE

/datum/feed_message/proc/clear()
	author = ""
	body = ""
	headline = ""
	backup_body = ""
	backup_author = ""
	backup_headline = ""
	img = null
	backup_img = null
	img_pda = null
	backup_img_pda = null

/proc/ImagePDA(var/icon/img)
	if (img)
		var/icon/img_pda = icon(img)
		//turns the image grayscale then applies an olive coat of paint
		img_pda.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(128,128,0))
		//lowers the brightness then ups the contrast so we get something that fits on a PDA screen
		img_pda.MapColors(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,-0.53,-0.53,-0.53,0)
		img_pda.MapColors(1.75,0,0,0,0,1.75,0,0,0,0,1.75,0,0,0,0,1.75,-0.375,-0.375,-0.375,0)
		return img_pda

/datum/feed_message/proc/NewspaperCopy()//We only copy the vars we'll need
	var/datum/feed_message/copy = new()
	copy.author = author
	copy.body = body
	copy.headline = headline
	copy.author_log = author_log
	copy.img = icon(img)
	copy.img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28))//grayscale
	copy.img_info = img_info
	return copy

/datum/feed_channel/proc/clear()
	channel_name = ""
	backup_name = ""
	messages = list()
	locked = 0
	author = ""
	backup_author = ""
	censored = 0
	is_admin_channel = 0

/datum/feed_channel/proc/NewspaperCopy()//We only copy the vars we'll need
	var/datum/feed_channel/copy = new()
	copy.channel_name = channel_name
	copy.author = author
	copy.messages = list()
	for(var/datum/feed_message/message in messages)
		copy.messages += message.NewspaperCopy()
	return copy

/datum/feed_network
	var/list/datum/feed_channel/network_channels = list()
	var/datum/feed_message/wanted_issue

var/datum/feed_network/news_network = new /datum/feed_network     //The global news-network, which is coincidentally a global list.

var/list/obj/machinery/newscaster/allCasters = list() //Global list that will contain reference to all newscasters in existence.

/datum/feed_channel/preset
	locked = 1
	is_admin_channel = 1

/datum/feed_channel/preset/tauceti
	channel_name = "Tau Ceti Daily"
	author = "CentComm Minister of Information"

/datum/feed_channel/preset/gibsongazette
	channel_name = "The Gibson Gazette"
	author = "Editor Mike Hammers"

/obj/machinery/newscaster
	name = "newscaster"
	desc = "A standard Nanotrasen-licensed newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_normal"
	var/buildstage = 1 // 1 = complete, 0 = unscrewed
	ghost_write = 1 // Allow ghosts to send Topic()s.
	custom_aghost_alerts = 1 // We handle our own logging.

	var/screen = 0
		//Or maybe I'll make it into a list within a list afterwards... whichever I prefer, go fuck yourselves :3
		// 0 = welcome screen - main menu
		// 1 = view feed channels
		// 2 = create feed channel
		// 3 = create feed story
		// 4 = feed story submited successfully
		// 5 = feed channel created successfully
		// 6 = ERROR: Cannot create feed story
		// 7 = ERROR: Cannot create feed channel
		// 8 = print newspaper
		// 9 = viewing channel feeds
		// 10 = censor feed story
		// 11 = censor feed channel

	var/paper_remaining = 15
	var/securityCaster = FALSE
		// FALSE = Caster cannot be used to issue wanted posters
		// TRUE = the opposite

	var/unit_no = 0 //Each newscaster has a unit number
	var/alert_delay = 500
	var/alert = FALSE
		// FALSE = there hasn't been a news/wanted update in the last alert_delay
		// TRUE = there has

	var/scanned_user = "Unknown" //Will contain the name of the person who currently uses the newscaster
	var/mob/masterController = null // Mob with control over the newscaster.
	var/hdln = ""; //Feed headline
	var/msg = ""; //Feed message
	var/photo = null
	var/channel_name = ""; //the feed channel which will be receiving the feed, or being created
	var/c_locked = FALSE; //Will our new channel be locked to public submissions?
	var/c_anonymous = FALSE //Will our new channel be anonymous?
	var/c_anoncreate = FALSE //Will our new channel be created anonymously?
	var/hitstaken = 0 //Death at 3 hits from an item with force>=15
	var/datum/feed_channel/viewing_channel = list()
	var/anonymous_posting = FALSE
	luminosity = 0
	anchored = TRUE


/obj/machinery/newscaster/security_unit //Security unit
	name = "Security Newscaster"
	securityCaster = TRUE

/obj/machinery/newscaster/New(var/loc, var/ndir, var/building = 1)
	buildstage = building
	if(!buildstage) //Already placed newscasters via mapping will not be affected by this
		pixel_x = (ndir & 3)? 0 : (ndir == 4 ? 28 * PIXEL_MULTIPLIER: -28 * PIXEL_MULTIPLIER)
		pixel_y = (ndir & 3)? (ndir == 1 ? 28 * PIXEL_MULTIPLIER: -28 * PIXEL_MULTIPLIER) : 0
		dir = ndir
	allCasters += src
	for(var/obj/machinery/newscaster/NEWSCASTER in allCasters) // Let's give it an appropriate unit number
		unit_no++
	update_icon()
	..()

/obj/machinery/newscaster/Destroy()
	allCasters -= src
	..()

/obj/machinery/newscaster/update_icon()
	if(buildstage != 1)
		icon_state = "newscaster_0"
		kill_moody_light()
		return

	if((stat & (FORCEDISABLE|NOPOWER)) || (stat & BROKEN))
		icon_state = "newscaster_off"
		if(stat & BROKEN) //If the thing is smashed, add crack overlay on top of the unpowered sprite.
			overlays.Cut()
			overlays += image(icon, "crack3")
		kill_moody_light()
		return

	overlays.Cut() //reset overlays

	if(news_network.wanted_issue) //wanted icon state, there can be no overlays on it as it's a priority message
		icon_state = "newscaster_wanted"
		return

	if(alert) //new message alert overlay
		overlays += image(icon = icon, icon_state = "newscaster_alert")

	if(hitstaken > 0) //Cosmetic damage overlay
		overlays += image(icon, "crack[hitstaken]")

	icon_state = "newscaster_normal"
	update_moody_light('icons/lighting/moody_lights.dmi', "overlay_newscaster")

/obj/machinery/newscaster/power_change()
	if(stat & BROKEN || buildstage != 1) //Broken shit can't be powered.
		return
	if( powered() )
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			update_icon()


/obj/machinery/newscaster/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			stat |= BROKEN
			if(prob(50))
				qdel(src)
			else
				update_icon() //can't place it above the return and outside the if-else. or we might get runtimes of null.update_icon() if(prob(50)) goes in.
			return
		else
			if(prob(50))
				stat |= BROKEN
			update_icon()
			return

/obj/machinery/newscaster/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet)||istype(Proj,/obj/item/projectile/ricochet))
		if(!istype(Proj ,/obj/item/projectile/beam/lasertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
			hitstaken++
			if(hitstaken>=3 && !(stat & BROKEN))
				stat |= BROKEN
				playsound(src, 'sound/effects/Glassbr3.ogg', 100, 1)
			else
				playsound(src, 'sound/effects/Glasshit.ogg', 100, 1)
			update_icon()
	return ..()

/obj/machinery/newscaster/attack_hand(mob/user as mob)            //########### THE MAIN BEEF IS HERE! And in the proc below this...############

	if(buildstage != 1)
		return

	. = ..()

	if (user.lying)
		user << browse(null, "window=newscaster_main;size=400x600")

	if (.)
		return

	if(istype(user, /mob/living/carbon/human) || istype(user,/mob/living/silicon) || isobserver(user))
		var/mob/M = user
		var/dat
		dat = text("<HEAD><TITLE>Newscaster</TITLE></HEAD><H3>Newscaster Unit #[unit_no]</H3>")

		scan_user(M) //Newscaster scans you

		switch(screen)
			if(NEWSCASTER_MENU)

				dat += {"Welcome to Newscasting Unit #[unit_no].<BR> Interface & News networks Operational.
					<BR><FONT SIZE=1>property of Nanotrasen Inc</FONT>"}
				if(news_network.wanted_issue)
					dat+= "<HR><A href='?src=\ref[src];view_wanted=1'>Read Wanted Issue</A>"

				dat += {"<HR><BR><A href='?src=\ref[src];create_channel=1'>Create Feed Channel</A>
					<BR><A href='?src=\ref[src];view=1'>View Feed Channels</A>
					<BR><A href='?src=\ref[src];create_feed_story=1'>Submit new Feed story</A>
					<BR><A href='?src=\ref[src];menu_paper=1'>Print newspaper</A>
					<BR><A href='?src=\ref[src];refresh=1'>Re-scan User</A>
					<BR><BR><A href='?src=\ref[M];mach_close=newscaster_main'>Exit</A>"}
				if(securityCaster)
					var/wanted_already = FALSE
					if(news_network.wanted_issue)
						wanted_already = TRUE


					dat += {"<HR><B>Feed Security functions:</B><BR>
						<BR><A href='?src=\ref[src];menu_wanted=1'>[(wanted_already) ? ("Manage") : ("Publish")] \"Wanted\" Issue</A>
						<BR><A href='?src=\ref[src];menu_censor_story=1'>Censor Feed Stories</A>
						<BR><A href='?src=\ref[src];menu_censor_channel=1'>Mark Feed Channel with Nanotrasen D-Notice</A>"}
				dat+="<BR><HR>The newscaster recognises you as: <FONT COLOR='green'>[scanned_user]</FONT>"
			if(NEWSCASTER_CHANNEL_LIST)
				dat+= "Station Feed Channels<HR>"
				if( isemptylist(news_network.network_channels) )
					dat+="<I>No active channels found...</I>"
				else
					for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
						if(CHANNEL.is_admin_channel)
							dat+="<B><FONT style='BACKGROUND-COLOR: LightGreen '><A href='?src=\ref[src];show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A></FONT></B><BR>"
						else
							dat+="<B><A href='?src=\ref[src];show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ""]<BR></B>"

				dat += {"<HR><A href='?src=\ref[src];refresh=1'>Refresh</A>
					<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Back</A>"}
			if(NEWSCASTER_NEW_CHANNEL)

				dat += {"Creating new Feed Channel...
					<HR><B><A href='?src=\ref[src];set_channel_name=1'>Channel Name</A>:</B> [channel_name]<BR>
					<B>Channel Author:</B> <FONT COLOR='green'>[scanned_user]</FONT><BR>
					<B><A href='?src=\ref[src];set_channel_lock=1'>Will Accept Public Feeds</A>:</B> [(c_locked) ? ("NO") : ("YES")]<BR>
					<B><A href='?src=\ref[src];set_channel_anonymous=1'>Anonymous feed</A>:</B> [(c_anonymous) ? ("YES") : ("NO")]<BR><BR>
					<B><A href='?src=\ref[src];set_channel_anoncreate=1'>Create feed anonymously</A>:</B> [(c_anoncreate) ? ("YES") : ("NO")]<BR><BR>
					<BR><A href='?src=\ref[src];submit_new_channel=1'>Submit</A><BR><BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Cancel</A><BR>"}

			if(NEWSCASTER_NEW_MESSAGE)

				var/datum/feed_channel/our_channel
				var/author_text
				for (var/datum/feed_channel/FC in news_network.network_channels)
					if (FC.channel_name == channel_name)
						our_channel = FC
						break

				if (our_channel && our_channel.anonymous)
					author_text = "<a href='?src=\ref[src];set_anon_posting=1'><FONT COLOR='green'>[anonymous_posting ? "Anonymous" : scanned_user]</FONT></a>"
				else
					author_text = "<FONT COLOR='green'>[scanned_user]</FONT>"

				dat += {"Creating new Feed Message...
					<HR><B><A href='?src=\ref[src];set_channel_receiving=1'>Receiving Channel</A>:</B> [channel_name]<BR>
					<B>Message Author:</B>[author_text]<BR>
					<B><A href='?src=\ref[src];set_new_headline=1'>Headline</A>:</B> [hdln] <BR>
					<B><A href='?src=\ref[src];set_new_message=1'>Message Body</A>:</B> [msg] <BR>"}

				dat += AttachPhotoButton(user)

				dat += "<BR><A href='?src=\ref[src];submit_new_message=1'>Submit</A><BR><BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Cancel</A><BR>"
			if(NEWSCASTER_NEW_MESSAGE_SUCCESS)

				dat += {"Feed story successfully submitted to [channel_name].<BR><BR>
					<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Return</A><BR>"}
			if(NEWSCASTER_NEW_CHANNEL_SUCCESS)

				dat += {"Feed Channel [channel_name] created successfully.<BR><BR>
					<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Return</A><BR>"}
			if(NEWSCASTER_NEW_MESSAGE_ERROR)
				dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed story to Network.</B></FONT><HR><BR>"
				if(channel_name=="")
					dat+="<FONT COLOR='maroon'>Invalid receiving channel name.</FONT><BR>"
				if(scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>Channel author unverified.</FONT><BR>"
				if(msg == "" || msg == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>Invalid message body.</FONT><BR>"

				dat+="<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_NEW_MESSAGE]'>Return</A><BR>"
			if(NEWSCASTER_NEW_CHANNEL_ERROR)
				dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed Channel to Network.</B></FONT><HR><BR>"
				var/list/existing_authors = list()
				for(var/datum/feed_channel/FC in news_network.network_channels)
					if(FC.author == "\[REDACTED\]")
						existing_authors += FC.backup_author
					else
						existing_authors += FC.author
				if(scanned_user in existing_authors)
					dat+="<FONT COLOR='maroon'>There already exists a Feed channel under your name.</FONT><BR>"
				if(channel_name=="" || channel_name == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>Invalid channel name.</FONT><BR>"
				var/check = FALSE
				for(var/datum/feed_channel/FC in news_network.network_channels)
					if(FC.channel_name == channel_name)
						check = TRUE
						break
				if(check)
					dat+="<FONT COLOR='maroon'>Channel name already in use.</FONT><BR>"
				if(scanned_user=="Unknown" && !c_anonymous)
					dat+="<FONT COLOR='maroon'>Channel author unverified.</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_NEW_CHANNEL]'>Return</A><BR>"
			if(NEWSCASTER_PRINT_NEWSPAPER)
				var/total_num = length(news_network.network_channels)
				var/active_num = total_num
				var/message_num = 0
				for(var/datum/feed_channel/FC in news_network.network_channels)
					if(!FC.censored)
						message_num += length(FC.messages)    //Dont forget, datum/feed_channel's var messages is a list of datum/feed_message
					else
						active_num--

				dat += {"Network currently serves a total of [total_num] Feed channels, [active_num] of which are active, and a total of [message_num] Feed Stories.
					<BR><BR><B>Liquid Paper remaining:</B> [(paper_remaining) *100 ] cm^3
					<BR><BR><A href='?src=\ref[src];print_paper=[0]'>Print Paper</A>
					<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Cancel</A>"}
			if(NEWSCASTER_VIEW_CHANNEL)
				dat+="<B>[viewing_channel.channel_name]: </B><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[viewing_channel.author]</FONT>\]</FONT><HR>"
				if(viewing_channel.censored)

					dat += {"<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>
						No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>"}
				else
					if( isemptylist(viewing_channel.messages) )
						dat+="<I>No feed messages found in channel...</I><BR><HR>"
					else
						var/i = 0
						for(var/datum/feed_message/MESSAGE in viewing_channel.messages)
							i++
							dat+="<b><u>[MESSAGE.headline]</u></b><BR>[MESSAGE.body] <BR>"
							if(MESSAGE.img)
								usr << browse_rsc(MESSAGE.img, "tmp_photo[i].png")

								dat+="<BR><a href='?src=\ref[src];show_photo_info=\ref[MESSAGE]'><img src='tmp_photo[i].png' width = '192' style='-ms-interpolation-mode:nearest-neighbor'></a><BR>"
							dat+="<BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR><HR>"

				dat += {"<A href='?src=\ref[src];refresh=1'>Refresh</A>
					<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_CHANNEL_LIST]'>Back</A>"}
			if(NEWSCASTER_CENSORSHIP_MENU)

				dat += {"<B>Nanotrasen Feed Censorship Tool</B><BR>
					<FONT SIZE=1>NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>
					Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.</FONT>
					<HR>Select Feed channel to get Stories from:<BR>"}
				if(isemptylist(news_network.network_channels))
					dat+="<I>No feed channels found active...</I><BR>"
				else
					for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
						dat+="<A href='?src=\ref[src];pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ""]<BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Cancel</A>"
			if(NEWSCASTER_D_NOTICE_MENU)

				dat += {"<B>Nanotrasen D-Notice Handler</B><HR>
					<FONT SIZE=1>A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the station's
					morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed
					stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.</FONT><HR>"}
				if(isemptylist(news_network.network_channels))
					dat+="<I>No feed channels found active...</I><BR>"
				else
					for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
						dat+="<A href='?src=\ref[src];pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ""]<BR>"

				dat+="<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Back</A>"
			if(NEWSCASTER_CENSORSHIP_CHANNEL)

				dat += {"<B>[viewing_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[viewing_channel.author]</FONT> \]</FONT><BR>
					<FONT SIZE=2><A href='?src=\ref[src];censor_channel_name=\ref[viewing_channel]'>[(viewing_channel.channel_name=="\[REDACTED\]") ? ("Undo Title censorship") : ("Censor channel Title")]</A>
					<A href='?src=\ref[src];censor_channel_author=\ref[viewing_channel]'>[(viewing_channel.author=="\[REDACTED\]") ? ("Undo Author censorship") : ("Censor channel Author")]</A></FONT><HR>"}
				if( isemptylist(viewing_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR><HR>"
				else
					for(var/datum/feed_message/MESSAGE in viewing_channel.messages)

						dat += {"<b><u>[MESSAGE.headline]</u></b><BR>[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>
							<FONT SIZE=2><A href='?src=\ref[src];censor_channel_story_body=\ref[MESSAGE]'>[(MESSAGE.body == "\[REDACTED\]") ? ("Undo story censorship") : ("Censor story")]</A>  -  <A href='?src=\ref[src];censor_channel_story_author=\ref[MESSAGE]'>[(MESSAGE.author == "\[REDACTED\]") ? ("Undo Author Censorship") : ("Censor message Author")]</A></FONT><BR><HR>"}
				dat+="<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_CENSORSHIP_MENU]'>Back</A>"
			if(NEWSCASTER_D_NOTICE_CHANNEL)

				dat += {"<B>[viewing_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[viewing_channel.author]</FONT> \]</FONT><BR>
					Channel messages listed below. If you deem them dangerous to the station, you can <A href='?src=\ref[src];toggle_d_notice=\ref[viewing_channel]'>Bestow a D-Notice upon the channel</A>.<HR>"}
				if(viewing_channel.censored)

					dat += {"<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>
						No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>"}
				else
					if( isemptylist(viewing_channel.messages) )
						dat+="<I>No feed messages found in channel...</I><BR><HR>"
					else
						for(var/datum/feed_message/MESSAGE in viewing_channel.messages)
							dat+="<b><u>[MESSAGE.headline]</u></b><BR>[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR><HR>"

				dat+="<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_D_NOTICE_MENU]'>Back</A>"
			if(NEWSCASTER_WANTED)
				dat+="<B>Wanted Issue Handler:</B>"
				var/wanted_already = FALSE
				var/end_param = 1
				if(news_network.wanted_issue)
					wanted_already = TRUE
					end_param = 2

				if(wanted_already)
					dat+="<FONT SIZE=2><BR><I>A wanted issue is already in Feed Circulation. You can edit or cancel it below.</FONT></I>"

				dat += {"<HR>
					<A href='?src=\ref[src];set_wanted_name=1'>Criminal Name</A>: [channel_name] <BR>
					<A href='?src=\ref[src];set_wanted_desc=1'>Description</A>: [msg] <BR>"}
				dat += AttachPhotoButton(user)
				if(wanted_already)
					dat+="<B>Wanted Issue created by:</B><FONT COLOR='green'> [news_network.wanted_issue.backup_author]</FONT><BR>"
				else
					dat+="<B>Wanted Issue will be created under prosecutor:</B><FONT COLOR='green'> [scanned_user]</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
				if(wanted_already)
					dat+="<BR><A href='?src=\ref[src];cancel_wanted=1'>Take down Issue</A>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Cancel</A>"
			if(NEWSCASTER_WANTED_SUCCESS)

				dat += {"<FONT COLOR='green'>Wanted issue for [channel_name] is now in Network Circulation.</FONT><BR><BR>
					<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Return</A><BR>"}
			if(NEWSCASTER_WANTED_ERROR)
				dat+="<B><FONT COLOR='maroon'>ERROR: Wanted Issue rejected by Network.</B></FONT><HR><BR>"
				if(channel_name=="" || channel_name == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>�Invalid name for person wanted.</FONT><BR>"
				if(scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>�Issue author unverified.</FONT><BR>"
				if(msg == "" || msg == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>�Invalid description.</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Return</A><BR>"
			if(NEWSCASTER_WANTED_DELETED)

				dat += {"<B>Wanted Issue successfully deleted from Circulation</B><BR>
					<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Return</A><BR>"}
			if(NEWSCASTER_WANTED_SHOW)

				dat += {"<B><FONT COLOR ='maroon'>-- STATIONWIDE WANTED ISSUE --</B></FONT><BR><FONT SIZE=2>\[Submitted by: <FONT COLOR='green'>[news_network.wanted_issue.backup_author]</FONT>\]</FONT><HR>
					<B>Criminal</B>: [news_network.wanted_issue.author]<BR>
					<B>Description</B>: [news_network.wanted_issue.body]<BR>
					<B>Photo:</B>: "}
				if(news_network.wanted_issue.img)
					usr << browse_rsc(news_network.wanted_issue.img, "tmp_photow.png")
					dat+="<BR><img src='tmp_photow.png' width = '180'>"
				else
					dat+="None"
				dat+="<BR><BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Back</A><BR>"
			if(NEWSCASTER_WANTED_EDIT)

				dat += {"<FONT COLOR='green'>Wanted issue for [channel_name] successfully edited.</FONT><BR><BR>
					<BR><A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Return</A><BR>"}
			if(NEWSCASTER_PRINT_NEWSPAPER_SUCCESS)

				dat += {"<FONT COLOR='green'>Printing successfull. Please receive your newspaper from the bottom of the machine.</FONT><BR><BR>
					<A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Return</A>"}
			if(NEWSCASTER_PRINT_NEWSPAPER_ERROR)

				dat += {"<FONT COLOR='maroon'>Unable to print newspaper. Insufficient paper. Please notify maintenance personnell to refill machine storage.</FONT><BR><BR>
					<A href='?src=\ref[src];setScreen=[NEWSCASTER_MENU]'>Return</A>"}
			else
				dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"


		M << browse(dat, "window=newscaster_main;size=400x600")
		onclose(M, "newscaster_main")

/obj/machinery/newscaster/Topic(href, href_list)
	if(..())
		return
	if(masterController && !isobserver(masterController) && get_dist(masterController,src)<=1 && usr!=masterController)
		to_chat(usr, "<span class='warning'>You must wait for [masterController] to finish and move away.</span>")
		return
	if (!isobserver(usr) && usr.stat)
		return
	if (ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if (H.lying)
			return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon) || isobserver(usr)))
		usr.set_machine(src)
		if(href_list["set_channel_name"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"set a channel's name"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			channel_name = stripped_input(usr, "Provide a Feed Channel Name", "Network Channel Handler", "")
			while (findtext(channel_name," ") == 1)
				channel_name = copytext(channel_name,2,length(channel_name)+1)
			updateUsrDialog()

		else if(href_list["set_channel_lock"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"locked a channel"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			c_locked = !c_locked
			updateUsrDialog()

		else if(href_list["set_channel_anonymous"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"set channel anonymous"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			c_anonymous = !c_anonymous
			updateUsrDialog()

		else if(href_list["set_channel_anoncreate"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"created anonymous channel"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			c_anoncreate = !c_anoncreate
			updateUsrDialog()

		else if(href_list["set_anon_posting"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"made the author of the post anonymous"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			anonymous_posting = !anonymous_posting
			updateUsrDialog()

		else if(href_list["submit_new_channel"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"created a new channel"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			var/list/existing_authors = list()
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.author == "\[REDACTED\]")
					existing_authors += FC.backup_author
				else
					existing_authors  +=FC.author
			var/check = FALSE
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == channel_name)
					check = TRUE
					break
			if(channel_name == "" || channel_name == "\[REDACTED\]" || scanned_user == "Unknown" || check || (scanned_user in existing_authors) )
				screen=NEWSCASTER_NEW_CHANNEL_ERROR
			else
				var/choice = alert("Please confirm Feed channel creation","Network Channel Handler","Confirm","Cancel")
				if(choice=="Confirm")
					var/datum/feed_channel/newChannel = new /datum/feed_channel
					newChannel.channel_name = channel_name
					newChannel.author = c_anoncreate ? "Anonymous": scanned_user
					newChannel.locked = c_locked
					newChannel.anonymous = c_anonymous
					feedback_inc("newscaster_channels",1)
					news_network.network_channels += newChannel                        //Adding channel to the global network
					screen = NEWSCASTER_MENU
			updateUsrDialog()

		else if(href_list["set_channel_receiving"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to set the receiving channel"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return

			var/list/available_channels = list()
			for(var/datum/feed_channel/F in news_network.network_channels)
				if( (!F.locked || F.author == scanned_user) && !F.censored)
					available_channels += F.channel_name
			channel_name = input(usr, "Choose receiving Feed Channel", "Network Channel Handler") in available_channels
			updateUsrDialog()

		else if(href_list["set_new_headline"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"set the headline of a new feed story"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			if(isnull(hdln))
				hdln = ""
			hdln = stripped_input(usr, "Write your story headline", "Network Channel Handler", hdln, 64)
			while (findtext(hdln," ") == 1)
				hdln = copytext(hdln,2,length(hdln)+1)
			updateUsrDialog()

		else if(href_list["set_new_message"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"set the message of a new feed story"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			if(isnull(msg))
				msg = ""
			msg = stripped_message(usr, "Write your Feed story", "Network Channel Handler", msg, MAX_BOOK_MESSAGE_LEN)
	//		while (findtext(msg," ") == 1)
	//			msg = copytext(msg,2,length(msg)+1)

			updateUsrDialog()

		else if(href_list["set_attachment"])
			if(isobserver(usr))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			AttachPhoto(usr)
			updateUsrDialog()

		else if(href_list["upload_photo"])
			if(!issilicon(usr))
				return
			if(photo)
				EjectPhoto()
				updateUsrDialog()
				return
			var/obj/item/device/camera/silicon/targetcam = null

			if(isAI(usr))
				var/mob/living/silicon/ai/A = usr
				targetcam = A.aicamera
			else if((isrobot(usr)))
				var/mob/living/silicon/robot/R = usr
				if(R.connected_ai)
					targetcam = R.connected_ai.aicamera
				else
					targetcam = R.aicamera
			else
				to_chat(usr, "<span class='warning'>You cannot interface with the silicon photo uploading network.</span>")
				return

			var/list/nametemp = list()
			var/find

			if(!targetcam.aipictures.len)
				to_chat(usr, "<span class='danger'>No images saved<span>")
				return
			for(var/datum/picture/t in targetcam.aipictures)
				nametemp += t.fields["name"]
			find = input("Select image") in nametemp
			for(var/datum/picture/q in targetcam.aipictures)
				if(q.fields["name"] == find)
					photo = q
					break
			updateUsrDialog()

		else if(href_list["submit_new_message"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"added a new story"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			if(msg =="" || msg=="\[REDACTED\]" || scanned_user == "Unknown" || channel_name == "" )
				screen=NEWSCASTER_NEW_MESSAGE_ERROR
			else
				var/datum/feed_channel/our_channel
				for(var/datum/feed_channel/FC in news_network.network_channels)
					if(FC.channel_name == channel_name)
						our_channel = FC
				var/datum/feed_message/newMsg = new /datum/feed_message
				if (our_channel.anonymous && anonymous_posting)
					newMsg.author = "Anonymous"
				else
					newMsg.author = scanned_user
				newMsg.headline = hdln
				newMsg.body = msg
				newMsg.author_log = key_name(usr)
				if(photo)
					if(istype(photo,/obj/item/weapon/photo))
						var/obj/item/weapon/photo/P = photo
						newMsg.img = P.img
						newMsg.img_info = P.info
						assassination_check(P)
					else if(istype(photo,/datum/picture))
						var/datum/picture/P = photo
						newMsg.img = P.fields["img"]
						newMsg.img_info = P.fields["info"]
					newMsg.img_pda = ImagePDA(newMsg.img)
					EjectPhoto()
				feedback_inc("newscaster_stories",1)
				our_channel.messages += newMsg                  //Adding message to the network's appropriate feed_channel
				screen = NEWSCASTER_MENU
				log_game("[key_name(usr)] posted the message [newMsg.body] as [newMsg.author].")
				for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
					NEWSCASTER.newsAlert(channel_name, newMsg.headline)
				for(var/obj/item/device/pda/PDA in PDAs)
					var/datum/pda_app/newsreader/reader = locate(/datum/pda_app/newsreader) in PDA.applications
					if(reader)
						reader.newsAlert(channel_name,newMsg.headline)

			updateUsrDialog()

		else if(href_list["create_channel"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"created a channel"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			screen=NEWSCASTER_NEW_CHANNEL
			updateUsrDialog()

		else if(href_list["create_feed_story"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"created a feed story"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			screen=NEWSCASTER_NEW_MESSAGE
			updateUsrDialog()

		else if(href_list["menu_paper"])
			if(isobserver(usr) && !canGhostWrite(usr,src,""))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			screen=NEWSCASTER_PRINT_NEWSPAPER
			updateUsrDialog()
		else if(href_list["print_paper"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"printed a paper"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			if(!paper_remaining)
				screen=NEWSCASTER_PRINT_NEWSPAPER_ERROR
			else
				print_paper()
				screen = NEWSCASTER_PRINT_NEWSPAPER_SUCCESS
			updateUsrDialog()

		else if(href_list["menu_censor_story"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"censored a story"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			screen=NEWSCASTER_CENSORSHIP_MENU
			updateUsrDialog()

		else if(href_list["menu_censor_channel"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"censored a channel"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			screen=NEWSCASTER_D_NOTICE_MENU
			updateUsrDialog()

		else if(href_list["menu_wanted"])
			if(isobserver(usr) && !canGhostWrite(usr,src,""))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			var/already_wanted = FALSE
			if(news_network.wanted_issue)
				already_wanted = TRUE

			if(already_wanted)
				channel_name = news_network.wanted_issue.author
				msg = news_network.wanted_issue.body
			screen = NEWSCASTER_WANTED
			updateUsrDialog()

		else if(href_list["set_wanted_name"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to set the name of a wanted person"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			channel_name = stripped_input(usr, "Provide the name of the Wanted person", "Network Security Handler", "")
			while (findtext(channel_name," ") == 1)
				channel_name = copytext(channel_name,2,length(channel_name)+1)
			updateUsrDialog()

		else if(href_list["set_wanted_desc"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to set the description of a wanted person"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			msg = stripped_input(usr, "Provide the a description of the Wanted person and any other details you deem important", "Network Security Handler", "")
			while (findtext(msg," ") == 1)
				msg = copytext(msg,2,length(msg)+1)
			updateUsrDialog()

		else if(href_list["submit_wanted"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"submitted a wanted poster"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			var/input_param = text2num(href_list["submit_wanted"])
			if(msg == "" || channel_name == "" || scanned_user == "Unknown")
				screen = NEWSCASTER_WANTED_ERROR
			else
				var/choice = alert("Please confirm Wanted Issue [(input_param==1) ? ("creation.") : ("edit.")]","Network Security Handler","Confirm","Cancel")
				if(choice=="Confirm")
					if(input_param==1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one. See the else below
						var/datum/feed_message/WANTED = new /datum/feed_message
						WANTED.author = channel_name
						WANTED.body = msg
						WANTED.backup_author = scanned_user //I know, a bit wacky
						if(photo)
							if(istype(photo,/obj/item/weapon/photo))
								var/obj/item/weapon/photo/P = photo
								WANTED.img = P.img
							else if(istype(photo,/datum/picture))
								var/datum/picture/P = photo
								WANTED.img = P.fields["img"]
							WANTED.img_pda = ImagePDA(WANTED.img)
						news_network.wanted_issue = WANTED
						for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
							NEWSCASTER.newsAlert()
							NEWSCASTER.update_icon()
						for(var/obj/item/device/pda/PDA in PDAs)
							var/datum/pda_app/newsreader/reader = locate(/datum/pda_app/newsreader) in PDA.applications
							if(reader)
								reader.newsAlert()
						screen = NEWSCASTER_WANTED_SUCCESS
					else
						if(news_network.wanted_issue.is_admin_message)
							alert("The wanted issue has been distributed by a Nanotrasen higherup. You cannot edit it.","Ok")
							return
						news_network.wanted_issue.author = channel_name
						news_network.wanted_issue.body = msg
						news_network.wanted_issue.backup_author = scanned_user
						if(photo)
							if(istype(photo,/obj/item/weapon/photo))
								var/obj/item/weapon/photo/P = photo
								news_network.wanted_issue.img = P.img
							else if(istype(photo,/datum/picture))
								var/datum/picture/P = photo
								news_network.wanted_issue.img = P.fields["img"]
						screen = NEWSCASTER_WANTED_EDIT

			updateUsrDialog()

		else if(href_list["cancel_wanted"])
			if(news_network.wanted_issue.is_admin_message)
				alert("The wanted issue has been distributed by a Nanotrasen higherup. You cannot take it down.","Ok")
				return
			var/choice = alert("Please confirm Wanted Issue removal","Network Security Handler","Confirm","Cancel")
			if(choice=="Confirm")
				news_network.wanted_issue = null
				for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
					NEWSCASTER.update_icon()
				screen=NEWSCASTER_WANTED_DELETED
			updateUsrDialog()

		else if(href_list["view_wanted"])
			screen=NEWSCASTER_WANTED_SHOW
			updateUsrDialog()

		else if(href_list["censor_channel_name"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to censor a channel title"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			var/datum/feed_channel/FC = locate(href_list["censor_channel_name"])
			if(FC.is_admin_channel)
				alert("This channel was created by a Nanotrasen Officer. You cannot censor it.","Ok")
				return
			if(FC.channel_name != "<B>\[REDACTED\]</B>")
				FC.backup_name = FC.channel_name
				FC.channel_name = "<B>\[REDACTED\]</B>"
			else
				FC.channel_name = FC.backup_name
			updateUsrDialog()

		else if(href_list["censor_channel_author"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to censor an author"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			var/datum/feed_channel/FC = locate(href_list["censor_channel_author"])
			if(FC.is_admin_channel)
				alert("This channel was created by a Nanotrasen Officer. You cannot censor it.","Ok")
				return
			if(FC.author != "<B>\[REDACTED\]</B>")
				FC.backup_author = FC.author
				FC.author = "<B>\[REDACTED\]</B>"
			else
				FC.author = FC.backup_author
			updateUsrDialog()

		else if(href_list["censor_channel_story_author"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to censor a story's author"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			var/datum/feed_message/MSG = locate(href_list["censor_channel_story_author"])
			if(MSG.is_admin_message)
				alert("This message was created by a Nanotrasen Officer. You cannot censor its author.","Ok")
				return
			if(MSG.author != "<B>\[REDACTED\]</B>")
				MSG.backup_author = MSG.author
				MSG.author = "<B>\[REDACTED\]</B>"
			else
				MSG.author = MSG.backup_author
			updateUsrDialog()

		else if(href_list["censor_channel_story_body"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to censor a story"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			var/datum/feed_message/MSG = locate(href_list["censor_channel_story_body"])
			if(MSG.is_admin_message)
				alert("This channel was created by a Nanotrasen Officer. You cannot censor it.","Ok")
				return
			if(MSG.img != null)
				MSG.backup_img = MSG.img
				MSG.img = null
				MSG.backup_img_pda = MSG.img_pda
				MSG.img_pda = null
			else
				MSG.img = MSG.backup_img
				MSG.img_pda = MSG.backup_img_pda
			if(MSG.body != "<B>\[REDACTED\]</B>")
				MSG.backup_headline = MSG.headline
				MSG.headline = ""
				MSG.backup_body = MSG.body
				MSG.body = "<B>\[REDACTED\]</B>"
			else
				MSG.headline = MSG.backup_headline
				MSG.body = MSG.backup_body
			updateUsrDialog()

		else if(href_list["pick_d_notice"])
			if(isobserver(usr) && !canGhostWrite(usr,src,""))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			var/datum/feed_channel/FC = locate(href_list["pick_d_notice"])
			viewing_channel = FC
			screen=NEWSCASTER_D_NOTICE_CHANNEL
			updateUsrDialog()

		else if(href_list["toggle_d_notice"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to set a D-notice"))
				to_chat(usr, "<span class='warning'>You can't do that.</span>")
				return
			var/datum/feed_channel/FC = locate(href_list["toggle_d_notice"])
			if(FC.is_admin_channel)
				alert("This channel was created by a Nanotrasen Officer. You cannot place a D-Notice upon it.","Ok")
				return
			FC.censored = !FC.censored
			updateUsrDialog()

		else if(href_list["view"])
			screen=NEWSCASTER_CHANNEL_LIST
			updateUsrDialog()

		else if(href_list["setScreen"]) //Brings us to the main menu and resets all fields~
			screen = text2num(href_list["setScreen"])
			if (screen == NEWSCASTER_MENU)
				scanned_user = "Unknown";
				msg = "";
				c_locked=0;
				channel_name="";
				viewing_channel = null
			updateUsrDialog()

		else if(href_list["show_channel"])
			var/datum/feed_channel/FC = locate(href_list["show_channel"])
			viewing_channel = FC
			screen = NEWSCASTER_VIEW_CHANNEL
			updateUsrDialog()

		else if(href_list["pick_censor_channel"])
			var/datum/feed_channel/FC = locate(href_list["pick_censor_channel"])
			viewing_channel = FC
			screen = NEWSCASTER_CENSORSHIP_CHANNEL
			updateUsrDialog()

		else if(href_list["show_photo_info"])
			var/datum/feed_message/FM = locate(href_list["show_photo_info"])

			if(istype(FM) && FM.img_info)
				usr.show_message("<span class='info'>[FM.img_info]</span>", MESSAGE_SEE)

			updateUsrDialog()

		else if(href_list["refresh"])
			updateUsrDialog()

/obj/machinery/newscaster/proc/assassination_check(var/obj/item/weapon/photo/P)
	if (assassination_objectives.len > 0)
		for (var/datum/objective/target/assassinate/ass in assassination_objectives)
			for(var/datum/weakref/ass_ref in P.double_agent_completion_ids)
				var/datum/objective/target/assassinate/ass_dat = ass_ref.get()
				if (ass == ass_dat)
					ass.SyndicateCertification()

/obj/machinery/newscaster/attackby(obj/item/I as obj, mob/user as mob)
	switch(buildstage)
		if(0)
			if(iscrowbar(I))
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] begins prying off the [src]!</span>", "<span class='notice'>You begin prying off the [src]</span>")
				if(do_after(user, src,10))
					to_chat(user, "<span class='notice'>You pry off the [src]!.</span>")
					new /obj/item/mounted/frame/newscaster(loc)
					EjectPhoto(user)
					qdel(src)
					return

			if(I.is_screwdriver(user) && !(stat & BROKEN))
				user.visible_message("<span class='notice'>[user] screws in the [src]!</span>", "<span class='notice'>You screw in the [src]</span>")
				I.playtoolsound(src, 100)
				buildstage = 1

		if(1)
			if(I.is_screwdriver(user) && !(stat & BROKEN))
				user.visible_message("<span class='notice'>[user] unscrews the [src]!</span>", "<span class='notice'>You unscrew the [src]</span>")
				I.playtoolsound(src, 100)
				buildstage = 0
				update_icon()
				return

			if ((stat & BROKEN) && (istype(I, /obj/item/stack/sheet/glass/glass)))
				var/obj/item/stack/sheet/glass/glass/stack = I
				if ((stack.amount - 2) < 0)
					to_chat(user, "<span class='warning'>You need more glass to do that.</span>")
				else
					stack.use(2)
					hitstaken = 0
					stat &= ~BROKEN
					playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)

			else if (stat & BROKEN)
				playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 100, 1)
				visible_message("<EM>[user.name]</EM> further abuses the shattered [src].")

			else
				var/obj/item/weapon/photo/P = I
				if(istype(P) && !photo && user.drop_item(P, src))
					photo = P
					to_chat(user, "<span class='notice'>You add \the [P] to \the [src].</span>")
					updateUsrDialog()

				else if(istype(I, /obj/item/weapon) )
					var/obj/item/weapon/W = I
					if(W.force <15)
						visible_message("[user.name] hits the [src] with the [W] with no visible effect." )
						playsound(src, 'sound/effects/Glasshit.ogg', 100, 1)
					else
						user.do_attack_animation(src, W)
						hitstaken++
						if(hitstaken==3)
							visible_message("[user.name] smashes the [src]!")
							stat |= BROKEN
							playsound(src, 'sound/effects/Glassbr3.ogg', 100, 1)
						else
							visible_message("[user.name] forcefully slams the [name] with the [I.name]!")
							playsound(src, 'sound/effects/Glasshit.ogg', 100, 1)
				else
					to_chat(user, "<span class='notice'>This does nothing.</span>")
	update_icon()

/obj/machinery/newscaster/attack_paw(mob/user as mob)
	to_chat(user, "<span class='notice'>The newscaster controls are far too complicated for your tiny brain!</span>")
	return

/obj/machinery/newscaster/proc/AttachPhoto(mob/user as mob)
	if(photo)
		return EjectPhoto(user)

	var/obj/item/weapon/photo/P = user.get_active_hand()
	if(istype(P) && user.drop_item(P, src))
		photo = P

/obj/machinery/newscaster/proc/EjectPhoto(mob/user as mob)
	if(!photo)
		return
	if(istype(photo,/obj/item/weapon/photo))
		var/obj/item/weapon/photo/P = photo
		P.forceMove(loc)

		photo = null
	else if(istype(photo,/datum/picture))
		photo = null

/obj/machinery/newscaster/proc/AttachPhotoButton(mob/user as mob)
	var/name = "Attach Photo"
	var/href = "set_attachment=1"
	if(issilicon(user))
		name = "Upload Photo"
		href = "upload_photo=1"

	if(photo)
		if(istype(photo,/datum/picture))
			var/datum/picture/P = photo
			name = "Delete Photo ([P.fields["name"]])"
		else
			name = "Eject Photo"

	return "<B><A href='?src=\ref[src];[href]'>[name]</A></B><BR>"

//########################################################################################################################
//###################################### NEWSPAPER! ######################################################################
//########################################################################################################################

#define NEWSPAPER_TITLE_PAGE 0
#define NEWSPAPER_CONTENT_PAGE 1
#define NEWSPAPER_LAST_PAGE 2

/obj/item/weapon/newspaper
	name = "newspaper"
	desc = "An issue of The Griffon, the newspaper circulating aboard Nanotrasen Space Stations."
	icon = 'icons/obj/bureaucracy.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/books.dmi', "right_hand" = 'icons/mob/in-hand/right/books.dmi')
	item_state = "newspaper"
	icon_state = "newspaper"
	force = 1 //Getting hit by rolled up newspapers hurts!
	throwforce = 0
	w_class = W_CLASS_SMALL	//Let's make it fit in trashbags!
	w_type = RECYK_WOOD
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 1
	attack_verb = list("baps", "smacks", "whaps")
	flammable = TRUE

	var/screen = 0
	var/pages = 0
	var/curr_page = 0
	var/list/datum/feed_channel/news_content = list()
	var/datum/feed_message/important_message = null
	var/scribble=""
	var/scribble_page = null

/obj/item/weapon/newspaper/attack_self(var/mob/user)
	if (user.incapacitated())
		return
	if(ishuman(user))
		item_state = "newspaper-open"
		user.update_inv_hand(user.active_hand)
		spawn (1 SECONDS)
			if (!gcDestroyed)
				item_state = "newspaper"
		var/dat
		pages = 0
		switch(screen)
			if(NEWSPAPER_TITLE_PAGE) //Cover

				dat += {"<DIV ALIGN='center'><B><FONT SIZE=6>The Griffon</FONT></B></div>
					<DIV ALIGN='center'><FONT SIZE=2>Nanotrasen-standard newspaper, for use on Nanotrasen Space Facilities</FONT></div><HR>"}
				if(isemptylist(news_content))
					if(important_message)
						dat+="Contents:<BR><ul><B><FONT COLOR='red'>**</FONT>Important Security Announcement<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[page [pages+2]\]</FONT><BR></ul>"
					else
						dat+="<I>Other than the title, the rest of the newspaper is unprinted...</I>"
				else
					dat+="Contents:<BR><ul>"
					for(var/datum/feed_channel/NP in news_content)
						pages++
					if(important_message)
						dat+="<B><FONT COLOR='red'>**</FONT>Important Security Announcement<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[page [pages+2]\]</FONT><BR>"
					var/temp_page=0
					for(var/datum/feed_channel/NP in news_content)
						temp_page++
						dat+="<B>[NP.channel_name]</B> <FONT SIZE=2>\[page [temp_page+1]\]</FONT><BR>"
					dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:right;'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV> <div style='float:left;'><A href='?src=\ref[usr];mach_close=newspaper_main'>Done reading</A></DIV>"
			if(NEWSPAPER_CONTENT_PAGE) // X channel pages inbetween.
				for(var/datum/feed_channel/NP in news_content)
					pages++ //Let's get it right again.
				var/datum/feed_channel/C = news_content[curr_page]
				dat+="<FONT SIZE=4><B>[C.channel_name]</B></FONT><FONT SIZE=1> \[created by: <b>[C.author]</b>\]</FONT><BR><BR>"
				if(C.censored)
					dat+="This channel was deemed dangerous to the general welfare of the station and therefore marked with a <B><FONT COLOR='red'>D-Notice</B></FONT>. Its contents were not transferred to the newspaper at the time of printing."
				else
					if(isemptylist(C.messages))
						dat+="No Feed stories stem from this channel..."
					else
						dat+="<ul>"
						var/i = 0
						for(var/datum/feed_message/MESSAGE in C.messages)
							i++
							dat+="<b><u>[MESSAGE.headline]</u></b><BR>[MESSAGE.body] <BR>"
							if(MESSAGE.img)
								user << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
								dat+="<BR><img src='tmp_photo[i].png' width = '180'><BR>"
							dat+="<BR><FONT SIZE=1>\[Story by <b>[MESSAGE.author]</b>\]</FONT><BR><HR>"
						dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
				dat+= "<BR><HR><DIV STYLE='float:left;'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV> <DIV STYLE='float:right;'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV>"
			if(NEWSPAPER_LAST_PAGE) //Last page
				for(var/datum/feed_channel/NP in news_content)
					pages++
				if(important_message!=null)

					dat += {"<DIV STYLE='align:center;'><FONT SIZE=4><B>!!Wanted!!</B></FONT SIZE></DIV>
						<B>Criminal name</B>: <b>[important_message.author]</b><BR>
						<B>Description</B>: [important_message.body]<BR>
						<B>Photo:</B>: "}
					if(important_message.img)
						user << browse_rsc(important_message.img, "tmp_photow.png")
						dat+="<BR><img src='tmp_photow.png' width = '180'>"
					else
						dat+="None"
				else
					dat+="<I>Apart from some uninteresting Classified ads, there's nothing on this page...</I>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:left;'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV>"
			else
				dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

		dat+="<BR><HR><div align='center'>[curr_page+1]</div>"
		usr << browse("<body style='background-color:#969696;color:black;'>[dat]</body>", "window=newspaper_main;size=400x400")
		onclose(usr, "newspaper_main")
	else
		to_chat(user, "The paper is full of intelligible symbols!")


/obj/item/weapon/newspaper/Topic(href, href_list)
	var/mob/U = usr
	//..() // Allow ghosts to do pretty much everything except add shit
	if ((src in U.contents) || ( istype(loc, /turf) && in_range(src, U) ))
		U.set_machine(src)
		if(href_list["next_page"])
			if(curr_page==pages+1)
				return //Don't need that at all, but anyway.
			if(curr_page == pages) //We're at the middle, get to the end
				screen = NEWSPAPER_LAST_PAGE
			else
				if(curr_page == 0) //We're at the start, get to the middle
					screen = NEWSPAPER_CONTENT_PAGE
			curr_page++
			playsound(src, "pageturn", 50, 1)

		else if(href_list["prev_page"])
			if(curr_page == 0)
				return
			if(curr_page == 1)
				screen = NEWSPAPER_TITLE_PAGE

			else
				if(curr_page == pages+1) //we're at the end, let's go back to the middle.
					screen = NEWSPAPER_CONTENT_PAGE
			curr_page--
			playsound(src, "pageturn", 50, 1)

		if (istype(loc, /mob))
			attack_self(loc)


/obj/item/weapon/newspaper/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pen))
		if(scribble_page == curr_page)
			to_chat(user, "<span class='notice'>There's already a scribble in this page... You wouldn't want to make things too cluttered, would you?</span>")
		else
			var/s = stripped_input(user, "Write something", "Newspaper", "")
			s = copytext(sanitize(s), 1, MAX_MESSAGE_LEN)
			if (!s)
				return
			if (!in_range(src, usr) && loc != usr)
				return
			scribble_page = curr_page
			scribble = s
			attack_self(user)
		return

	else if(W.is_hot())
		ashify_item(user)
		return

#undef NEWSPAPER_TITLE_PAGE
#undef NEWSPAPER_CONTENT_PAGE
#undef NEWSPAPER_LAST_PAGE

////////////////////////////////////helper procs


/obj/machinery/newscaster/proc/scan_user(mob/user)
	if(masterController)
		if(masterController != user)
			if(get_dist(masterController,src)<=1)
				if(!isobserver(masterController))
					to_chat(user, "<span class='warning'>Wait for [masterController] to finish and move away.</span>")
					return
	if(istype(user,/mob/living/carbon/human))                       //User is a human
		var/mob/living/carbon/human/human_user = user
		if(human_user.wear_id)                                      //Newscaster scans you
			if(istype(human_user.wear_id, /obj/item/device/pda) )	//autorecognition, woo!
				var/obj/item/device/pda/P = human_user.wear_id
				if(P.id)
					scanned_user = "[P.id.registered_name] ([P.id.assignment])"
				else
					scanned_user = "Unknown"
			else if(istype(human_user.wear_id, /obj/item/weapon/card/id) )
				var/obj/item/weapon/card/id/ID = human_user.wear_id
				scanned_user ="[ID.registered_name] ([ID.assignment])"
			else
				scanned_user ="Unknown"
		else
			scanned_user ="Unknown"
	else if (issilicon(user))
		var/mob/living/silicon/ai_user = user
		scanned_user = "[ai_user.name] ([ai_user.job])"
	else if (isAdminGhost(user))
		scanned_user = "Nanotrasen Officer #[rand(0,9)][rand(0,9)][rand(0,9)]"
	else if (isobserver(user))
		scanned_user = "Space-Time Anomaly #[rand(0,9)][rand(0,9)][rand(0,9)]"
	masterController = user

/obj/machinery/newscaster/proc/print_paper()
	feedback_inc("newscaster_newspapers_printed",1)
	var/obj/item/weapon/newspaper/printed_issue = new /obj/item/weapon/newspaper(src)
	for(var/datum/feed_channel/FC in news_network.network_channels)
		if (!FC.censored)//censored channels aren't printed at all, why waste all this good paper
			printed_issue.news_content += FC.NewspaperCopy()
	if(news_network.wanted_issue)
		printed_issue.important_message = news_network.wanted_issue.NewspaperCopy()
	anim(target = src, a_icon = icon, flick_anim = "newscaster_print", sleeptime = 30, offX = pixel_x, offY = pixel_y)
	playsound(src, "sound/effects/fax.ogg", 50, 1)
	paper_remaining--
	spawn(0.8 SECONDS)
		printed_issue.forceMove(get_turf(src))

/obj/machinery/newscaster/proc/newsAlert(channel, newsHead)   //This isn't Agouri's work, for it is ugly and vile.
	var/turf/T = get_turf(src)                      //Who the fuck uses spawn(600) anyway, jesus christ
	if(channel)
		if(newsHead != "")
			say("Breaking news from [channel] - [newsHead]")
		else
			say("Breaking news from [channel]!")
		alert = TRUE
		update_icon()
		spawn(30 SECONDS)
			alert = FALSE
			update_icon()
		playsound(src, 'sound/machines/twobeep.ogg', 75, 1)
	else
		for(var/mob/O in hearers(world.view-1, T))
		say("Attention! Wanted issue distributed!")
		playsound(src, 'sound/machines/warning-buzzer.ogg', 75, 1)

/obj/machinery/newscaster/say_quote(text)
	return "beeps, [text]"

#undef NEWSCASTER_MENU
#undef NEWSCASTER_CHANNEL_LIST
#undef NEWSCASTER_NEW_CHANNEL
#undef NEWSCASTER_NEW_MESSAGE
#undef NEWSCASTER_NEW_MESSAGE_SUCCESS
#undef NEWSCASTER_NEW_CHANNEL_SUCCESS
#undef NEWSCASTER_NEW_MESSAGE_ERROR
#undef NEWSCASTER_NEW_CHANNEL_ERROR
#undef NEWSCASTER_PRINT_NEWSPAPER
#undef NEWSCASTER_VIEW_CHANNEL
#undef NEWSCASTER_CENSORSHIP_MENU
#undef NEWSCASTER_D_NOTICE_MENU
#undef NEWSCASTER_CENSORSHIP_CHANNEL
#undef NEWSCASTER_D_NOTICE_CHANNEL
#undef NEWSCASTER_WANTED
#undef NEWSCASTER_WANTED_SUCCESS
#undef NEWSCASTER_WANTED_ERROR
#undef NEWSCASTER_WANTED_DELETED
#undef NEWSCASTER_WANTED_SHOW
#undef NEWSCASTER_WANTED_EDIT
#undef NEWSCASTER_PRINT_NEWSPAPER_SUCCESS
#undef NEWSCASTER_PRINT_NEWSPAPER_ERROR
