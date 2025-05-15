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

/obj/machinery/computer/tetris/Topic(href, href_list)
	if(..())
		return 1
	else
		usr.set_machine(src)
		if(href_list["tetrisScore"])
			var/temp_score = text2num(href_list["tetrisScore"])
			total_score[usr.key] += temp_score
			if(!next_tech_threshold[usr.key])
				next_tech_threshold[usr.key] = 250
			if(total_score[usr.key] > next_tech_threshold[usr.key])
				next_tech_threshold[usr.key] += 250
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
				rdc.GiveRandomResearch()
				rdc.griefProtection() //Update centcomm too
	return

/obj/machinery/computer/tetris/attack_ai(user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/computer/tetris/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/tetris/attack_hand(mob/user as mob)
	if(..())
		return
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	if(user.client)
		var/datum/asset/simple/C = new/datum/asset/simple/tetris()
		send_asset_list(user.client, C.assets)

	var/dat ={"<!DOCTYPE html><html><head><title>Telemetry Enhanced Testing and Research Informatic Simulator (BLOX)</title>
	<meta charset="utf-8">
	<meta name="description" content="Using Blox, from https://github.com/gdaws/tetris">
	<link rel="stylesheet" href="//fonts.googleapis.com/css?family=Press+Start+2P" type="text/css">
	<link rel="stylesheet" href="tetris.css" type="text/css">
	<script src="jquery.min.js"></script>

	<!-- MUST BE INCLUDED BEFORE -->
	<script language='JavaScript'>
	function submitScore(s){
		window.location.href = 'byond://?src=\ref[src];tetrisScore=' + s;
	}
	</script>

	<script src="main_tetris.js"></script>


	</head>
	<body>
		<div class="container">
		<div id="game-start"><h1>Telemetry Enhanced Testing and Research Informatic Simulator (BLOX)</h1>
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
	user << browse(dat, "window=tetris;size=550x700")
	user.set_machine(src)
	onclose(user, "tetris")
