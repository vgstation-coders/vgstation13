/datum/pda_app/ringer
	name = "Ringer"
	desc = "Set the frequency to that of a desk bell to be notified anytime someone presses it."
	price = 10
	icon = "pda_bell"
	var/frequency = 1457	//	1200 < frequency < 1600 , always end with an odd number.
	var/status = 1			//	0=off 1=on

/datum/pda_app/ringer/get_dat(var/mob/user)
	return {"
	<h4>Ringer Application</h4>
	Status: <a href='byond://?src=\ref[src];toggleDeskRinger=1'>[status ? "On" : "Off"]</a><br>
	Frequency:
		<a href='byond://?src=\ref[src];ringerFrequency=-10'>-</a>
		<a href='byond://?src=\ref[src];ringerFrequency=-2'>-</a>
		[format_frequency(frequency)]
		<a href='byond://?src=\ref[src];ringerFrequency=2'>+</a>
		<a href='byond://?src=\ref[src];ringerFrequency=10'>+</a><br>
		<br>
	"}

/datum/pda_app/ringer/Topic(href, href_list)
	if(..())
		return
	if(href_list["toggleDeskRinger"])
		status = !status
	if(href_list["ringerFrequency"])
		var/i = frequency + text2num(href_list["ringerFrequency"])
		if(i < MINIMUM_FREQUENCY)
			i = 1201
		if(i > MAXIMUM_FREQUENCY)
			i = 1599
		frequency = i
	refresh_pda()

/datum/pda_app/light_upgrade
	name = "PDA Flashlight Enhancer"
	desc = "Slightly increases the luminosity of your PDA's flashlight."
	price = 60
	menu = FALSE
	icon = "pda_flashlight"

/datum/pda_app/light_upgrade/onInstall()
	..()
	var/datum/pda_app/light/app = locate(/datum/pda_app/light) in pda_device.applications
	if(app)
		app.f_lum = 3
		if(app.fon)
			pda_device.set_light(app.f_lum)

/datum/pda_app/spam_filter
	name = "Spam Filter"
	desc = "Spam messages won't ring your PDA anymore. Enjoy the quiet."
	price = 30
	icon = "pda_mail"
	var/function = 1	//0=do nothing 1=conceal the spam 2=block the spam

/datum/pda_app/spam_filter/get_dat(var/mob/user)
	return {"
		<h4>Spam Filtering Application</h4>
		<ul>
		<li>[(function == 2) ? "<b>Block the spam.</b>" : "<a href='byond://?src=\ref[src];setFilter=1;filter=2'>Block the spam.</a>"]</li>
		<li>[(function == 1) ? "<b>Conceal the spam.</b>" : "<a href='byond://?src=\ref[src];setFilter=1;filter=1'>Conceal the spam.</a>"]</li>
		<li>[(function == 0) ? "<b>Do nothing.</b>" : "<a href='byond://?src=\ref[src];setFilter=1;filter=0'>Do nothing.</a>"]</li>
		</ul>
		"}

/datum/pda_app/spam_filter/Topic(href, href_list)
	if(..())
		return
	if(href_list["setFilter"])
		function = text2num(href_list["filter"])
	refresh_pda()

/datum/pda_app/station_map
	name = "Station Holo-Map ver. 2.0"
	desc = "Displays a holo-map of the station. Useful for finding your way."
	price = 50
	has_screen = FALSE
	icon = "pda_map"
	var/obj/item/device/station_map/holomap = null

/datum/pda_app/station_map/onInstall(var/obj/item/device/pda/device)
	..()
	if (istype(device))
		holomap = new(device)

/datum/pda_app/station_map/on_select(var/mob/user)
	if (holomap)
		holomap.prevent_close = 1
		spawn(2)
			holomap.prevent_close = 0
		if(!holomap.watching_mob)
			holomap.attack_self(user)
		no_refresh = TRUE
		var/turf/T = get_turf(pda_device)
		if(!holomap.bogus)
			to_chat(user,"[bicon(pda_device)] Current Location: <b>[T.loc.name] ([T.x-WORLD_X_OFFSET[map.zMainStation]],[T.y-WORLD_Y_OFFSET[map.zMainStation]],1)")

/datum/pda_app/station_map/Destroy()
	if (holomap)
		QDEL_NULL(holomap)
	..()

/datum/pda_app/newsreader
	name = "Newsreader"
	desc = "Access to the latest news from the comfort of your pocket."
	price = 40
	icon = "pda_news"
	var/datum/feed_channel/viewing_channel
	var/screen = NEWSREADER_CHANNEL_LIST

/datum/pda_app/newsreader/get_dat(var/mob/user)
	var/dat = ""
	switch(screen)
		if (NEWSREADER_CHANNEL_LIST)
			dat += {"<h4>Station Feed Channels</h4>"}
			if(news_network.wanted_issue)
				dat+= "<HR><b><A href='?src=\ref[src];viewWanted=1'>Read Wanted Issue</A></b><HR>"
			if(isemptylist(news_network.network_channels))
				dat+="<br><i>No active channels found...</i>"
			else
				for(var/datum/feed_channel/channel in news_network.network_channels)
					if(channel.is_admin_channel)
						dat+="<b><a href='?src=\ref[src];readChannel=\ref[channel]'>[channel.channel_name]</a></b><br>"
					else
						dat+="<a href='?src=\ref[src];readChannel=\ref[channel]'>[channel.channel_name]</a> [(channel.censored) ? ("***") : ""]<br>"
		if (NEWSREADER_VIEW_CHANNEL)
			dat+="<b>[viewing_channel.channel_name]: </b><font size=1>\[created by: <b>[viewing_channel.author]</b>\]</font><HR>"
			if(viewing_channel.censored)
				dat += {"<B>ATTENTION: </B></font>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<br>
					No further feed story additions are allowed while the D-Notice is in effect.<br><br>"}
			else
				if( isemptylist(viewing_channel.messages) )
					dat+="<i>No feed messages found in channel...</i><br>"
				else
					var/i = 0
					for(var/datum/feed_message/message in viewing_channel.messages)
						i++
						dat+="<b><u>[message.headline]</u></b><BR>[message.body] <BR>"
						if(message.img)
							usr << browse_rsc(message.img_pda, "tmp_photo_pda[i].png")

							dat+="<a href='?src=\ref[src];showPhotoInfo=\ref[message]'><img src='tmp_photo_pda[i].png' width = '192'></a><br>"
						dat+="<font size=1>\[Story by <b>[message.author]</b>\]</font><HR>"

			dat += {"<br><a href='?src=\ref[src];viewChannels=1'>Back</a>"}
		if (NEWSREADER_WANTED_SHOW)
			dat += {"<B>-- STATIONWIDE WANTED ISSUE --</B><BR><FONT SIZE=2>\[Submitted by: <b>[news_network.wanted_issue.backup_author]</b>\]</FONT><HR>
				<B>Criminal</B>: [news_network.wanted_issue.author]<BR>
				<B>Description</B>: [news_network.wanted_issue.body]<BR>
				<B>Photo:</B>: "}
			if(news_network.wanted_issue.img_pda)
				usr << browse_rsc(news_network.wanted_issue.img_pda, "tmp_photow_pda.png")
				dat+="<BR><img src='tmp_photow_pda.png' width = '180'>"
			else
				dat+="None"

			dat += {"<br><a href='?src=\ref[src];viewChannels=1'>Back</a>"}
	return dat

/datum/pda_app/newsreader/Topic(href, href_list)
	if(..())
		return
	if(href_list["readChannel"])
		var/datum/feed_channel/channel = locate(href_list["readChannel"])
		if (channel)
			viewing_channel = channel
			screen = NEWSREADER_VIEW_CHANNEL

	if(href_list["viewChannels"])
		screen = NEWSREADER_CHANNEL_LIST

	if(href_list["viewWanted"])
		screen = NEWSREADER_WANTED_SHOW

	if(href_list["showPhotoInfo"])
		var/datum/feed_message/FM = locate(href_list["showPhotoInfo"])
		if(istype(FM) && FM.img_info)
			usr.show_message("<span class='info'>[FM.img_info]</span>", MESSAGE_SEE)
	refresh_pda()

/datum/pda_app/newsreader/proc/newsAlert(var/channel_name)
	var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in pda_device.applications
	if(app.silent)
		return
	var/turf/T = get_turf(pda_device)
	playsound(T, 'sound/machines/twobeep.ogg', 50, 1)
	for (var/mob/O in hearers(3, T))
		O.show_message(text("[bicon(pda_device)] [channel_name ? "Breaking news from [channel_name]" : "Attention! Wanted issue distributed!"]!"))
