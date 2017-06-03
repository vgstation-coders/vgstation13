	////////////
	//SECURITY//
	////////////
#define TOPIC_SPAM_DELAY	2		//2 ticks is about 2/10ths of a second; it was 4 ticks, but that caused too many clicks to be lost due to lag
#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 10MB //Boosted this thing. What's the worst that can happen?
#define MIN_CLIENT_VERSION	510		//Just an ambiguously low version for now, I don't want to suddenly stop people playing.
									//I would just like the code ready should it ever need to be used.
	/*
	When somebody clicks a link in game, this Topic is called first.
	It does the stuff in this proc and  then is redirected to the Topic() proc for the src=[0xWhatever]
	(if specified in the link). ie locate(hsrc).Topic()

	Such links can be spoofed.

	Because of this certain things MUST be considered whenever adding a Topic() for something:
		- Can it be fed harmful values which could cause runtimes?
		- Is the Topic call an admin-only thing?
		- If so, does it have checks to see if the person who called it (usr.client) is an admin?
		- Are the processes being called by Topic() particularly laggy?
		- If so, is there any protection against somebody spam-clicking a link?
	If you have any  questions about this stuff feel free to ask. ~Carn
	*/
/client
	var/account_joined = ""
	var/account_age

/client/Topic(href, href_list, hsrc)
	//var/timestart = world.timeofday
	//testing("topic call for [usr] [href]")
	if(!usr || usr != mob)	//stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

	//Reduces spamming of links by dropping calls that happen during the delay period
//	if(next_allowed_topic_time > world.time)
//		return
	//next_allowed_topic_time = world.time + TOPIC_SPAM_DELAY

	//search the href for script injection
	if( findtext(href,"<script",1,0) )
		world.log << "Attempted use of scripts within a topic call, by [src]"
		message_admins("Attempted use of scripts within a topic call, by [src]")
		//del(usr)
		return

	//Admin PM
	if(href_list["priv_msg"])
		var/client/C = locate(href_list["priv_msg"])
		if(ismob(C)) 		//Old stuff can feed-in mobs instead of clients
			var/mob/M = C
			C = M.client
		cmd_admin_pm(C,null)
		return

	//Wiki shortcuts
	if(href_list["getwiki"])
		var/url = href_list["getwiki"]
		usr << link(getVGWiki(url))
		return

	// Global Asset cache stuff.
	if(href_list["asset_cache_confirm_arrival"])
//		to_chat(src, "ASSET JOB [href_list["asset_cache_confirm_arrival"]] ARRIVED.")
		var/job = text2num(href_list["asset_cache_confirm_arrival"])
		completed_asset_jobs += job
		return

	if(href_list["_src_"] == "chat") // Oh god the ping hrefs.
		return chatOutput.Topic(href, href_list)

	//Logs all hrefs
	if(config && config.log_hrefs && investigations[I_HREFS])
		var/datum/log_controller/I = investigations[I_HREFS]
		I.write("<small>[time_stamp()] [src] (usr:[usr])</small> || [hsrc ? "[hsrc] " : ""][copytext(sanitize(href), 1, 3000)]<br />")

	switch(href_list["_src_"])
		if("holder")
			hsrc = holder
		if("usr")
			hsrc = mob
		if("prefs")
			return prefs.process_link(usr,href_list)
		if("vars")
			return view_var_Topic(href,href_list,hsrc)

	switch(href_list["action"])
		if ("openLink")
			src << link(href_list["link"])

	..()	//redirect to hsrc.Topic()
	//testing("[usr] topic call took [(world.timeofday - timestart)/10] seconds")

/client/proc/handle_spam_prevention(var/message, var/mute_type)
	if(config.automute_on && !holder && src.last_message == message)
		src.last_message_count++
		if(src.last_message_count >= SPAM_TRIGGER_AUTOMUTE)
			to_chat(src, "<span class='warning'>You have exceeded the spam filter limit for identical messages. An auto-mute was applied.</span>")
			cmd_admin_mute(src.mob, mute_type, 1)
			return 1
		if(src.last_message_count >= SPAM_TRIGGER_WARNING)
			to_chat(src, "<span class='warning'>You are nearing the spam filter limit for identical messages.</span>")
			return 0
	else
		last_message = message
		src.last_message_count = 0
		return 0

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return 0
/*	//Don't need this at the moment. But it's here if it's needed later.
	//Helps prevent multiple files being uploaded at once. Or right after eachother.
	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		to_chat(src, "<font color='red'>Error: AllowUpload(): Spam prevention. Please wait [round(time_to_wait/10)] seconds.</font>")
		return 0
	fileaccess_timer = world.time + FTPDELAY	*/
	return 1


	///////////
	//CONNECT//
	///////////
/client/New(TopicData)
	// world.log << "creating chatOutput"
	chatOutput = new /datum/chatOutput(src) // Right off the bat.
	// world.log << "Done creating chatOutput"
	if(config)
		winset(src, null, "outputwindow.output.style=[config.world_style_config];")
		winset(src, null, "window1.msay_output.style=[config.world_style_config];") // it isn't possible to set two window elements in the same winset so we need to call it for each element we're assigning a stylesheet.
	else
		to_chat(src, "<span class='warning'>The stylesheet wasn't properly setup call an administrator to reload the stylesheet or relog.</span>")

	TopicData = null							//Prevent calls to client.Topic from connect

	//Admin Authorisation
	holder = admin_datums[ckey]
	if(holder)
		admins += src
		holder.owner = src

	var/static/list/localhost_addresses = list("127.0.0.1","::1")
	if(config.localhost_autoadmin)
		if((!address && !world.port) || (address in localhost_addresses))
			var/datum/admins/D = new /datum/admins("Host", R_HOST, src.ckey)
			D.associate(src)

	if(connection != "seeker")			//Invalid connection type.
		if(connection == "web")
			if(!holder)
				return null
		else
			return null

	if(byond_version < MIN_CLIENT_VERSION)		//Out of date client.
		message_admins("[key]/[ckey] has connected with an out of date client! Their version: [byond_version]. They will be kicked shortly.")
		alert(src,"Your BYOND client is out of date. Please make sure you have have at least version [world.byond_version] installed. Check for a beta update if necessary.", "Update Yo'Self", "OK")
		spawn(5 SECONDS)
			del(src)

	if(!guests_allowed && IsGuestKey(key))
		alert(src,"This server doesn't allow guest accounts to play. Please go to http://www.byond.com/ and register for a key.","Guest","OK")
		del(src)
		return

	// Change the way they should download resources.
	if(config.resource_urls)
		src.preload_rsc = pick(config.resource_urls)
	else
		src.preload_rsc = 1 // If config.resource_urls is not set, preload like normal.

	to_chat(src, "<span class='warning'>If the title screen is black, resources are still downloading. Please be patient until the title screen appears.</span>")

	clients += src
	directory[ckey] = src


	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = preferences_datums[ckey]
	if(!prefs)
		prefs = new /datum/preferences(src)
		preferences_datums[ckey] = prefs
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning
	prefs.client = src
	prefs.initialize_preferences(client_login = 1)

	. = ..()	//calls mob.Login()
	chatOutput.start()

	if(custom_event_msg && custom_event_msg != "")
		to_chat(src, "<h1 class='alert'>Custom Event</h1>")
		to_chat(src, "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>")
		to_chat(src, "<span class='alert'>[html_encode(custom_event_msg)]</span>")
		to_chat(src, "<br>")

	if( (world.address == address || !address) && !host )
		host = key
		world.update_status()

	if(holder)
		add_admin_verbs()
		admin_memo_show()
		holder.add_menu_items()

	log_client_to_db()

	send_resources()

	if(prefs.lastchangelog != changelog_hash) //bolds the changelog button on the interface so we know there are updates.
		winset(src, "rpane.changelog", "background-color=#eaeaea;font-style=bold")
		prefs.SetChangelog(ckey,changelog_hash)
		to_chat(src, "<span class='info'>Changelog has changed since your last visit.</span>")

	//Set map label to correct map name
	winset(src, "rpane.map", "text=\"[map.nameLong]\"")

	// Notify scanners.
	INVOKE_EVENT(on_login,list(
		"client"=src,
		"admin"=(holder!=null)
	))

	if(!winexists(src, "asset_cache_browser")) // The client is using a custom skin, tell them.
		to_chat(src, "<span class='warning'>Unable to access asset cache browser, if you are using a custom skin file, please allow DS to download the updated version, if you are not, then make a bug report. This is not a critical issue but can cause issues with resource downloading, as it is impossible to know when extra resources arrived to you.</span>")
	//This is down here because of the browse() calls in tooltip/New()
	if(!tooltips)
		tooltips = new /datum/tooltip(src)

	//////////////
	//DISCONNECT//
	//////////////
/client/Del()
	if(holder)
		holder.owner = null
		admins -= src
	directory -= ckey
	clients -= src

	return ..()

/client/proc/log_client_to_db()
	if(IsGuestKey(key))
		return

	establish_db_connection()

	if(!dbcon.IsConnected())
		return
	var/list/http[] = world.Export("http://www.byond.com/members/[src.key]?format=text")  // Retrieve information from BYOND
	var/Joined = 2550-01-01
	if(http && http.len && ("CONTENT" in http))
		var/String = file2text(http["CONTENT"])  //  Convert the HTML file to text
		var/JoinPos = findtext(String, "joined")+10  //  Parse for the joined date
		Joined = copytext(String, JoinPos, JoinPos+10)  //  Get the date in the YYYY-MM-DD format

	account_joined = Joined

	var/sql_ckey = sanitizeSQL(ckey)
	var/age
	testing("sql_ckey = [sql_ckey]")
	var/DBQuery/query = dbcon.NewQuery("SELECT id, datediff(Now(),firstseen) as age, datediff(Now(),accountjoined) as age2 FROM erro_player WHERE ckey = '[sql_ckey]'")
	query.Execute()
	var/sql_id = 0
	while(query.NextRow())
		sql_id = query.item[1]
		player_age = text2num(query.item[2])
		age = text2num(query.item[3])
		break

	var/sql_address = sanitizeSQL(address)

	var/DBQuery/query_ip = dbcon.NewQuery("SELECT distinct ckey FROM erro_connection_log WHERE ip = '[sql_address]'")
	query_ip.Execute()
	related_accounts_ip = ""
	while(query_ip.NextRow())
		related_accounts_ip += "[query_ip.item[1]], "


	var/sql_computerid = sanitizeSQL(computer_id)

	var/DBQuery/query_cid = dbcon.NewQuery("SELECT distinct ckey FROM erro_connection_log WHERE computerid = '[sql_computerid]'")
	query_cid.Execute()
	related_accounts_cid = ""
	while(query_cid.NextRow())
		related_accounts_cid += "[query_cid.item[1]], "

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			return

	var/admin_rank = "Player"

	if(istype(holder))
		admin_rank = holder.rank

	var/sql_admin_rank = sanitizeSQL(admin_rank)

	if(sql_id)
		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		var/DBQuery/query_update
		if(isnum(age))
			query_update = dbcon.NewQuery("UPDATE erro_player SET lastseen = Now(), ip = '[sql_address]', computerid = '[sql_computerid]', lastadminrank = '[sql_admin_rank]' WHERE id = [sql_id]")
		else
			query_update = dbcon.NewQuery("UPDATE erro_player SET lastseen = Now(), ip = '[sql_address]', computerid = '[sql_computerid]', lastadminrank = '[sql_admin_rank]', accountjoined = '[Joined]' WHERE id = [sql_id]")
		query_update.Execute()
		if(query_update.ErrorMsg())
			WARNING("FINGERPRINT: [query_update.ErrorMsg()]")

	else
		//New player!! Need to insert all the stuff
		var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO erro_player (id, ckey, firstseen, lastseen, ip, computerid, lastadminrank, accountjoined) VALUES (null, '[sql_ckey]', Now(), Now(), '[sql_address]', '[sql_computerid]', '[sql_admin_rank]', '[Joined]')")
		query_insert.Execute()
		if(query_insert.ErrorMsg())
			WARNING("FINGERPRINT: [query_insert.ErrorMsg()]")

	if(!isnum(age))
		var/DBQuery/query_age = dbcon.NewQuery("SELECT datediff(Now(),accountjoined) as age2 FROM erro_player WHERE ckey = '[sql_ckey]'")
		query_age.Execute()
		while(query_age.NextRow())
			age = text2num(query_age.item[1])
	if(!isnum(player_age))
		player_age = 0
	if(age < 14)
		message_admins("[ckey(key)]/([src]) is a relatively new player, may consider watching them. AGE = [age]  First seen = [player_age]")
		log_admin(("[ckey(key)]/([src]) is a relatively new player, may consider watching them. AGE = [age] First seen = [player_age]"))
	testing("[src]/[ckey(key)] logged in with age of [age]/[player_age]/[Joined]")
	account_age = age

	// logging player access
	var/server_address_port = "[world.internet_address]:[world.port]"
	var/sql_server_address_port = sanitizeSQL(server_address_port)
	var/DBQuery/query_connection_log = dbcon.NewQuery("INSERT INTO `erro_connection_log`(`id`,`datetime`,`serverip`,`ckey`,`ip`,`computerid`) VALUES(null,Now(),'[sql_server_address_port]','[sql_ckey]','[sql_address]','[sql_computerid]');")

	query_connection_log.Execute()
	if(query_connection_log.ErrorMsg())
		WARNING("FINGERPRINT: [query_connection_log.ErrorMsg()]")

#undef TOPIC_SPAM_DELAY
#undef UPLOAD_LIMIT
#undef MIN_CLIENT_VERSION

//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration=3000)
	if(inactivity > duration)
		return inactivity
	return 0

/client/verb/resend_resources()
	set name = "Resend Resources"
	set desc = "Re-send resources for NanoUI. May help those with NanoUI issues."
	set category = "OOC"

	to_chat(usr, "<span class='notice'>Re-sending NanoUI resources.  This may result in lag.</span>")
	nanomanager.send_resources(src)
	send_html_resources()

//send resources to the client. It's here in its own proc so we can move it around easiliy if need be
/client/proc/send_resources()
//	preload_vox() //Causes long delays with initial start window and subsequent windows when first logged in.

	getFiles(
		'html/search.js',
		'html/panels.css',
	)

	// Preload the crew monitor. This needs to be done due to BYOND bug http://www.byond.com/forum/?post=1487244
	//The above bug report thing doesn't exist anymore so uh, whatever.
	spawn
		send_html_resources()

	// Send NanoUI resources to this client
	spawn nanomanager.send_resources(src)


/client/proc/send_html_resources()
	if(crewmonitor && minimapinit)
		crewmonitor.sendResources(src)
	if(adv_camera && minimapinit)
		adv_camera.sendResources(src)
	while(!vote || !vote.interface)
		sleep(1)
	vote.interface.sendAssets(src)

/proc/get_role_desire_str(var/rolepref)
	switch(rolepref & ROLEPREF_VALMASK)
		if(ROLEPREF_NEVER)
			return "Never"
		if(ROLEPREF_NO)
			return "No"
		if(ROLEPREF_YES)
			return "Yes"
		if(ROLEPREF_ALWAYS)
			return "Always"
	return "???"

/client/proc/desires_role(var/role_id, var/display_to_user=0)
	var/role_desired = prefs.roles[role_id]
	if(display_to_user && !(role_desired & ROLEPREF_PERSIST))
		if(!(role_desired & ROLEPREF_POLLED))
			spawn
				var/question={"[role_id]

Yes/No: Only affects this round
Never/Always: Affects future rounds, you will not be polled again.

NOTE:  You will only be polled about this role once per round. To change your choice, use Preferences > Setup Special Roles.  The change will take place AFTER this recruiting period."}
				var/answer = alert(src,question,"Role Recruitment", "Yes","No","Never")
				switch(answer)
					if("Never")
						prefs.roles[role_id] = ROLEPREF_NEVER
					if("No")
						prefs.roles[role_id] = ROLEPREF_NO
					if("Yes")
						prefs.roles[role_id] = ROLEPREF_YES
					//if("Always")
					//	prefs.roles[role_id] = ROLEPREF_ALWAYS
				//testing("Client [src] answered [answer] to [role_id] poll.")
				prefs.roles[role_id] |= ROLEPREF_POLLED
		else
			to_chat(src, "<span style='recruit'>The game is currently looking for [role_id] candidates.  Your current answer is <a href='?src=\ref[prefs]&preference=set_role&role_id=[role_id]'>[get_role_desire_str(role_desired)]</a>.</span>")
	return role_desired & ROLEPREF_ENABLE

/client/proc/colour_transition(var/list/colour_to = default_colour_matrix,var/time = 10)	// call this with no parametres to reset to default.
	if(!color)
		color = default_colour_matrix
	if(!(colour_to.len))
		colour_to = default_colour_matrix
	animate(src, color=colour_to, time=time, easing=SINE_EASING)

/client/proc/changeView(var/newView)
	if(!newView)
		view = world.view
	else
		view = newView

	if(mob && ishuman(mob))
		var/mob/living/carbon/human/H = mob
		var/obj/item/clothing/under/U = H.get_item_by_slot(slot_w_uniform)
		if(istype(U))
			for(var/obj/item/clothing/accessory/holomap_chip/HC in U.accessories)
				HC.update_holomap()

/client/verb/SwapSides()
	set name = "swapsides"
	set hidden = 1
	var/newsplit = 100 - text2num(winget(usr, "mainwindow.mainvsplit", "splitter"))
	if(winget(usr, "mainwindow.mainvsplit", "right") == "rpane")
		winset(usr, "mainwindow.mainvsplit", "right=mapwindow;left=rpane;splitter=[newsplit]")
	else
		winset(usr, "mainwindow.mainvsplit", "right=rpane;left=mapwindow;splitter=[newsplit]")

/client/proc/update_special_views()
	if(prefs.space_parallax)	//Updating parallax for clients that have parallax turned on.
		if(parallax_initialized)
			mob.hud_used.update_parallax_values()

	for(var/obj/structure/window/W in view(view,mob))
		if(W.one_way)
			update_one_way_windows(view(view,mob))	//Updating the one-way window overlay if the client has one in view.
			break

/client/proc/update_one_way_windows(var/list/v)		//Needed for one-way windows to work.
	var/Image										//Code heavily cannibalized from a demo made by Byond member Shadowdarke.
	var/turf/Oneway
	var/obj/structure/window/W
	var/list/newimages = list()
	var/list/onewaylist = list()

	if(!v)
		return

	ObscuredTurfs.len = 0

	for(W in view(view,mob))
		if(W.one_way)
			if(W.dir & get_dir(W,mob))
				Oneway = get_turf(W)
				Oneway.opacity = 1
				onewaylist += Oneway

	if(onewaylist.len)
		var/list/List = v - view(view,mob)
		List += onewaylist
		for(var/turf/T in List)
			T.viewblock = image('icons/turf/overlays.dmi',T,"black_box",10)
			if(T in onewaylist)
				for(W in T.contents)
					if(W.one_way)
						T.viewblock = image('icons/turf/overlays.dmi',T,"black_box[W.dir]",10)
			T.viewblock.plane = FULLSCREEN_PLANE
			src << T.viewblock
			newimages += T.viewblock
			ObscuredTurfs += T

		for(var/turf/I in onewaylist)
			I.opacity = 0

	for(Image in ViewFilter-newimages)
		images -= Image
	ViewFilter = newimages