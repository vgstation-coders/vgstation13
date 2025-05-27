var/list/tetris_machines = list()
var/list/deleted_machines_tetris_highscores = list()

/obj/machinery/computer/tetris
	name = "T.E.T.R.I.S."
	desc = "The pinnacle of human technology."
	icon = 'icons/obj/computer.dmi'
	icon_state = "arcade"
	circuit = "/obj/item/weapon/circuitboard/tetris"
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	light_color = LIGHT_COLOR_GREEN

	var/total_score = list()
	var/next_tech_threshold = list()

	// Basic anti-cheat prevention (doesn't really matter)
	var/init_times = list()
	var/secret_pass_key

	var/list/leaderboard_init = list()

	var/list/leaderboard_this_round = list()

	// Available techs for reasearch
	var/list/loaded_techs = list(
		Tc_PROGRAMMING = 3,
		Tc_ENGINEERING = 3,
		Tc_MAGNETS = 3,
		Tc_POWERSTORAGE = 3,
		Tc_COMBAT = 3,
		Tc_MATERIALS = 3,
	)

/obj/machinery/computer/tetris/New()
	secret_pass_key = rand(1, 9999)
	tetris_machines += src
	return ..()

/obj/machinery/computer/tetris/initialize()
	leaderboard_init = SSpersistence_misc.read_data(/datum/persistence_task/highscores/tetris)
	return ..()

/obj/machinery/computer/tetris/Destroy()
	tetris_machines -= src
	deleted_machines_tetris_highscores += leaderboard_this_round
	return ..()

/obj/machinery/computer/tetris/Topic(href, href_list)
	if(..())
		return 1
	else
		usr.set_machine(src)
		if(href_list["refresh"])
			updateUsrDialog()
			return
		if(href_list["tetrisScore"])
			if (text2num(href_list["init_time"]) != init_times[usr.key])
				say("CHEATERS NEVER PROPSER.")
				return
			if (text2num(href_list["secretPassKey"]) != secret_pass_key)
				say("CHEATERS NEVER PROPSER.")
				return
			var/temp_score = text2num(href_list["tetrisScore"])
			if (temp_score < total_score[usr.key]) // Means they restarted!
				next_tech_threshold[usr.key] = 100
			total_score[usr.key] = temp_score

			if (isliving(usr)) // Sorry ghosts
				if(!next_tech_threshold[usr.key])
					next_tech_threshold[usr.key] = 100
				if(total_score[usr.key] > next_tech_threshold[usr.key])
					next_tech_threshold[usr.key] += 100
					var/area/this_area = get_area(src)
					if(!isarea(this_area) || isspace(this_area))
						say("Unable to process synchronization")
						return
					var/obj/machinery/computer/rdconsole/rdc = locate() in this_area
					if(!rdc)
						say("Unable to process synchronization")
						return
					say("YOU HAVE REACHED: [temp_score]!")
					say("You have unlocked a new technology.")
					rdc.GiveRandomResearch(src)
					rdc.griefProtection() //Update centcomm too

			// Insert into the leaderboard
			var/found = 0
			for (var/list/L in leaderboard_this_round)
				if (L["ckey"] == usr.ckey)
					L["cash"] = temp_score > L["cash"] ? temp_score : L["cash"] // if they had a high score on a previous session, keep it
					found = 1
					break

			if (!found)
				var/list/L = list(list(
					"ckey" = usr.ckey,
					"role" = (ishuman(usr) ? usr.mind.assigned_role : "Ghost"),
					"cash" = temp_score
				))
				leaderboard_this_round += L
	return

/obj/machinery/computer/tetris/attack_ai(var/mob/user)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/computer/tetris/attack_paw(var/mob/user)
	return src.attack_hand(user)

/obj/machinery/computer/tetris/attackby(var/obj/I, var/mob/user)
	if(..(I,user))
		return

	// Pasted from destructive analyzer
	if(istype(I, /obj/item))
		if(!I.origin_tech)
			to_chat(user, "<span class='warning'>This doesn't seem to have a tech origin!</span>")
			return

		var/list/temp_tech = ConvertReqString2List(I.origin_tech)

		if(!temp_tech.len)
			to_chat(user, "<span class='warning'>You cannot deconstruct this item!</span>")
			return

		// Twice as fast as decon analyser
		if(user.drop_item(I, src))
			to_chat(user, "<span class='notice'>You deconstruct \the [I] for reverse telemetry.</span>")
			for(var/T in temp_tech)
				if (!loaded_techs[T])
					loaded_techs[T] = 2
				else
					loaded_techs[T] = loaded_techs[T]+2
			qdel(I)
			return

/obj/machinery/computer/tetris/attack_hand(var/mob/user)
	if(..())
		return
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	if(user.client)
		var/datum/asset/simple/C = new/datum/asset/simple/tetris()
		send_asset_list(user.client, C.assets)

	var/init_time = world.time

	init_times[user.key] = init_time

	var/dat ={"<!DOCTYPE html><html><head><title>Telemetry Enhanced Testing and Research Informatic Simulator (BLOX)</title>
	<meta charset="utf-8">
	<meta name="description" content="Using Blox, from https://github.com/gdaws/tetris">
	<link rel="stylesheet" href="//fonts.googleapis.com/css?family=Press+Start+2P" type="text/css">
	<link rel="stylesheet" href="tetris.css" type="text/css">
	<script src="jquery.min.js"></script>

	<!-- MUST BE INCLUDED BEFORE -->
	<script language='JavaScript'>
	function submitScore(s){
		window.location.href = 'byond://?src=\ref[src];init_time=[init_time];secretPassKey=[secret_pass_key];tetrisScore=' + s;
	}
	function ShowMain(){
		$('.container').css('display', '');
		$('.leaderboard').css('display', 'none');
		$('.enabled_tech').css('display', 'none');
	}
	function ShowLeaderBoard(){
		$('.container').css('display', 'none');
		$('.leaderboard').css('display', '');
		$('.enabled_tech').css('display', 'none');
	}
	function ShowEnabledTech(){
		$('.container').css('display', 'none');
		$('.leaderboard').css('display', 'none');
		$('.enabled_tech').css('display', '');
	}
	</script>

	<script src="main_tetris.js"></script>

	</head>
	<body>
		<h1>T.E.T.R.I.S</h1>
		<center>
			<a href=# class="nav-link" onclick="ShowMain();return false;">Show research interface</a> <br/>
			<a href=# class="nav-link" onclick="ShowLeaderBoard();return false;">Show research leaderboard</a> <br/>
			<a href=# class="nav-link" onclick="ShowEnabledTech();return false;">Show enabled technologies</a> <br/>
		</center>
		<div class="leaderboard" style='display:none'>
			[show_leaderboard()]
		</div>
		<div class="enabled_tech" style='display:none'>
			[show_available_techs()]
		</div>

		<div class="container">
		<div id="game-start"><h3>Telemetry Enhanced Testing and Research Informatic Simulator (BLOX)</h3>
		<table id="controls" cellpadding="0" cellspacing="0" width="100%">
			<tbody>
			<tr>
				<td>Right arrow</td>
				<td>Move right </td>
			</tr>
			<tr>
				<td>Left arrow</td>
				<td>Move left</td>
			</tr>
			<tr>
				<td>Up arrow</td>
				<td>Rotate</td>
			</tr>
			<tr>
				<td>Down arrow</td>
				<td>Move down</td>
			</tr>
			<tr>
				<td>Space</td>
				<td>Fast drop</td>
			</tr>
			<tr>
				<td>P</td>
				<td>Pause</td>
			</tr>
			</tbody>
		</table>
		</div>

		<div id="game-loading"></div>

		<script>
		$('#game-loading').text('Game loading...')
		</script>

		<noscript>
		<div class="error">Error! Your web browser has Javascript disabled.</div>
		</noscript>

		<div style="display:none" class="status-container">
			<table border="0" cellpadding="5">
			<tbody>
				<tr>
					<td colspan="2" align="center" width="100">
						<div id="preview"></div>
					</td>
				</tr>
				<tr>
					<td>Level</td>
					<td>
						<div id="level"></div>
					</td>
				</tr>
				<tr>
					<td>Score</td>
					<td><div id="score"></div></td>
				</tr>
				<tr>
					<td>Lines</td>
					<td><div id="lines"></div></td>
				</tr>
			</tbody>
			</table>
		</div>
		<div style="display:none" class="game-container">
			<div id="game" style="width:300px; height: 600px;" class="game"></div>
			<div id="menu" class="overlay"></div>
		</div>
	</div>
	<audio id="collapse1-sound" src="beep1.mp3" preload="auto"></audio>
	<audio id="collapse2-sound" src="beep2.mp3" preload="auto"></audio>
	<audio id="collapse3-sound" src="beep3.mp3" preload="auto"></audio>
	<audio id="collapse4-sound" src="beep4.mp3" preload="auto"></audio>

	</body>
	</html>"}
	user << browse(dat, "window=tetris;size=600x850")
	user.set_machine(src)
	onclose(user, "tetris")

/obj/machinery/computer/tetris/proc/show_leaderboard()
	var/dat = {"
		<br/>
		<h2>The pride of Science itself</h2>
		<br/>
		<table id="controls" cellpadding="0" cellspacing="0" width="100%">
		<tbody>"}

	if (!leaderboard_init || !leaderboard_init.len)
		dat += "<tr>No top scientists yet!</tr>"

	for(var/datum/data/record/money/record in leaderboard_init)
		dat += {"
			<tr>
				<td>"[record.fields["ckey"]]"</td>
				<td>[record.fields["cash"]]</td>
			</tr>
		"}

	dat += {"
		<tbody>
		</table>
	"}

	dat += {"
	<br/>
	<h2>Hardest working scientists this shift</h2>
	<br/>
	<table id="controls" cellpadding="0" cellspacing="0" width="100%">
	<tbody>
	"}

	if (!leaderboard_this_round.len)
		dat += "<tr>No top scientists yet!</tr>"

	for(var/list/L in leaderboard_this_round)
		dat += {"
			<tr>
				<td>"[L["ckey"]]"</td>
				<td>[L["cash"]]</td>
			</tr>
		"}

	dat += {"
		<tbody>
		</table>
		<center><a class="nav-link" href=?src=\ref[src];refresh=1>Refresh</a></center>
	"}

	return dat

/obj/machinery/computer/tetris/proc/show_available_techs()
	var/dat = {"
		<br/>
		<h2>Available technologies for telemetry</h2>
		<br/>
		<table id="controls" cellpadding="0" cellspacing="0" width="100%">
		<tbody>"}

	for(var/tech in loaded_techs)
		dat += {"
			<tr>
				<td>[capitalize(tech)]</td>
				<td>[loaded_techs[tech]]</td>
			</tr>
		"}

	dat += {"
		<tbody>
		</table>
		<center><a class="nav-link" href=?src=\ref[src];refresh=1>Refresh</a></center>
	"}
	return dat
