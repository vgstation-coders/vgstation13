/obj/machinery/computer/arcade
	name = "arcade machine"
	desc = "Does not support pinball."
	icon = 'icons/obj/computer.dmi'
	icon_state = "arcade"
	circuit = "/obj/item/weapon/circuitboard/arcade"
	var/enemy_name = "Space Villain"
	var/temp = "Winners Don't Use Spacedrugs" //Temporary message, for attack messages, etc
	var/player_hp = 30 //Player health/attack points
	var/player_max_hp = 30
	var/player_mp = 10
	var/player_max_mp = 10
	var/enemy_hp = 45 //Enemy health/attack points
	var/enemy_max_hp = 45
	var/enemy_mp = 20
	var/enemy_max_mp = 20
	var/gameover = 0
	var/blocked = 0 //Player cannot attack/heal while set
	var/list/cheaters = list() //Trying to cheat twice at cuban pete gibs you

	machine_flags = EMAGGABLE | SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	emag_cost = 0 // because fun

	light_color = LIGHT_COLOR_GREEN

	var/list/prizes = list(	/obj/item/weapon/storage/box/snappops			= 2,
							/obj/item/toy/cards								= 2,
							/obj/item/toy/blink								= 2,
							/obj/item/clothing/under/syndicate/tacticool	= 2,
							/obj/item/toy/sword								= 2,
							/obj/item/toy/bomb								= 1,
							/obj/item/toy/gun								= 2,
							/obj/item/toy/crossbow							= 2,
							/obj/item/clothing/suit/syndicatefake			= 2,
							/obj/item/weapon/storage/fancy/crayons			= 2,
							/obj/item/toy/spinningtoy						= 2,
							/obj/item/toy/minimeteor						= 2,
							/obj/item/device/whisperphone					= 2,
							/obj/item/weapon/storage/box/mechfigures		= 1,
							/obj/item/weapon/boomerang/toy					= 1,
							/obj/item/toy/foamblade							= 1,
							/obj/item/weapon/storage/box/actionfigure		= 1,
							/obj/item/toy/syndicateballoon/ntballoon		= 1,
							)

/obj/machinery/computer/arcade
	var/turtle = 0

/obj/machinery/computer/arcade/New()
	..()
	var/name_action
	var/name_part1
	var/name_part2

	name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ", "Pwn ", "Own ")

	name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Cuban ", "the Evil ", "the Dread King ", "the Space ", "Lord ", "the Great ", "Duke ", "General ")
	name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon", "Uhangoid", "Vhakoid", "Peteoid", "slime", "Griefer", "ERPer", "Lizard Man", "Unicorn")

	src.enemy_name = replacetext((name_part1 + name_part2), "the ", "")
	src.name = (name_action + name_part1 + name_part2)


/obj/machinery/computer/arcade/proc/import_game_data(var/obj/item/weapon/circuitboard/arcade/A)
	if(!A || !A.game_data || !A.game_data.len)
		return
	name = A.game_data["name"]
	emagged = A.game_data["emagged"]
	enemy_name = A.game_data["enemy_name"]
	temp = A.game_data["temp"]
	player_hp = A.game_data["player_hp"]
	player_max_hp = A.game_data["player_max_hp"]
	player_mp = A.game_data["player_mp"]
	player_max_mp = A.game_data["player_max_mp"]
	enemy_hp = A.game_data["enemy_hp"]
	enemy_max_hp = A.game_data["enemy_max_hp"]
	enemy_mp = A.game_data["enemy_mp"]
	enemy_max_mp = A.game_data["enemy_max_mp"]
	gameover = A.game_data["gameover"]
	blocked = A.game_data["blocked"]

/obj/machinery/computer/arcade/proc/export_game_data(var/obj/item/weapon/circuitboard/arcade/A)
	if(!A)
		return
	if(!A.game_data)
		A.game_data = list()
	A.game_data.len = 0
	A.game_data["name"] = name
	A.game_data["emagged"] = emagged
	A.game_data["enemy_name"] = enemy_name
	A.game_data["temp"] = temp
	A.game_data["player_hp"] = player_hp
	A.game_data["player_max_hp"] = player_max_hp
	A.game_data["player_mp"] = player_mp
	A.game_data["player_max_mp"] = player_max_mp
	A.game_data["enemy_hp"] = enemy_hp
	A.game_data["enemy_max_hp"] = enemy_max_hp
	A.game_data["enemy_mp"] = enemy_mp
	A.game_data["enemy_max_mp"] = enemy_max_mp
	A.game_data["gameover"] = gameover
	A.game_data["blocked"] = blocked


/obj/machinery/computer/arcade/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/computer/arcade/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/arcade/attack_hand(mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a>"

	dat += {"<center><h4>[src.enemy_name]</h4></center>
		<br><center><h3>[src.temp]</h3></center>
		<br><center>Health: [src.player_hp] | Magic: [src.player_mp] | Enemy Health: [src.enemy_hp]</center>"}
	if (src.gameover)
		dat += "<center><b><a href='byond://?src=\ref[src];newgame=1'>New Game</a>"
	else

		dat += {"<center><b><a href='byond://?src=\ref[src];attack=1'>Attack</a> |
			<a href='byond://?src=\ref[src];heal=1'>Heal</a> |
			<a href='byond://?src=\ref[src];charge=1'>Recharge Power</a>"}

	dat += "</b></center>"

	user << browse(dat, "window=arcade")
	onclose(user, "arcade")
	return

/obj/machinery/computer/arcade/proc/action_attack()
	src.blocked = 1
	var/attackamt = rand(2,6)
	src.temp = "You attack for [attackamt] damage!"
	src.updateUsrDialog()
	if(turtle > 0)
		turtle--

	sleep(10)
	src.enemy_hp -= attackamt
	src.arcade_action()

/obj/machinery/computer/arcade/proc/action_heal()
	src.blocked = 1
	var/pointamt = rand(1,3)
	var/healamt = rand(6,8)
	src.temp = "You use [pointamt] magic to heal for [healamt] damage!"
	src.updateUsrDialog()
	turtle++

	sleep(10)
	src.player_mp -= pointamt
	src.player_hp += healamt
	src.blocked = 1
	src.updateUsrDialog()
	src.arcade_action()

/obj/machinery/computer/arcade/proc/action_charge()
	src.blocked = 1
	var/chargeamt = rand(4,7)
	src.temp = "You regain [chargeamt] points"
	src.player_mp += chargeamt
	if(turtle > 0)
		turtle--

	src.updateUsrDialog()
	sleep(10)
	src.arcade_action()

/obj/machinery/computer/arcade/Topic(href, href_list)
	if(..())
		return

	if (!src.blocked && !src.gameover)
		if (href_list["attack"])
			action_attack()

		else if (href_list["heal"])
			action_heal()

		else if (href_list["charge"])
			action_charge()

	if (href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=arcade")

	else if (href_list["newgame"]) //Reset everything
		if(is_cheater(usr))
			return

		temp = "New Round"
		player_hp = player_max_hp
		player_mp = player_max_mp
		enemy_hp = enemy_max_hp
		enemy_mp = enemy_max_mp
		gameover = 0
		turtle = 0

		if(emagged)
			src.New()
			emagged = 0

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/arcade/proc/arcade_action()
	if ((src.enemy_mp <= 0) || (src.enemy_hp <= 0))
		if(!gameover)
			src.gameover = 1
			src.temp = "[src.enemy_name] has fallen! Rejoice!"

			if(emagged)
				feedback_inc("arcade_win_emagged")
				new /obj/item/clothing/head/collectable/petehat(src.loc)
				new /obj/item/device/maracas/cubanpete(src.loc)
				new /obj/item/device/maracas/cubanpete(src.loc)
				message_admins("[key_name_admin(usr)] has outbombed Cuban Pete and been awarded explosive maracas.")
				log_game("[key_name_admin(usr)] has outbombed Cuban Pete and been awarded explosive maracas.")
				src.New()
				emagged = 0

			else if(!contents.len)
				feedback_inc("arcade_win_normal")
				var/prizeselect = pickweight(prizes)
				new prizeselect(src.loc)

				if(istype(prizeselect, /obj/item/toy/gun)) //Ammo comes with the gun
					new /obj/item/toy/ammo/gun(src.loc)

				else if(istype(prizeselect, /obj/item/clothing/suit/syndicatefake)) //Helmet is part of the suit
					new	/obj/item/clothing/head/syndicatefake(src.loc)

			else //admins can varedit arcades to have special prizes via contents, but it removes the prize rather than spawn a new one
				feedback_inc("arcade_win_normal")
				var/atom/movable/prize = pick(contents)
				prize.forceMove(src.loc)

	else if (emagged && (turtle >= 4))
		var/boomamt = rand(5,10)
		src.temp = "[src.enemy_name] throws a bomb, exploding you for [boomamt] damage!"
		src.player_hp -= boomamt

	else if ((src.enemy_mp <= 5) && (prob(70)))
		var/stealamt = rand(2,3)
		src.temp = "[src.enemy_name] steals [stealamt] of your power!"
		src.player_mp -= stealamt
		src.updateUsrDialog()

		if (src.player_mp <= 0)
			src.gameover = 1
			sleep(10)
			src.temp = "You have been drained! GAME OVER"
			if(emagged)
				feedback_inc("arcade_loss_mana_emagged")
				usr.gib()
			else
				feedback_inc("arcade_loss_mana_normal")

	else if ((src.enemy_hp <= 10) && (src.enemy_mp > 4))
		src.temp = "[src.enemy_name] heals for 4 health!"
		src.enemy_hp += 4
		src.enemy_mp -= 4

	else
		var/attackamt = rand(3,6)
		src.temp = "[src.enemy_name] attacks for [attackamt] damage!"
		src.player_hp -= attackamt

	if ((src.player_mp <= 0) || (src.player_hp <= 0))
		src.gameover = 1
		src.temp = "You have been crushed! GAME OVER"
		if(emagged)
			feedback_inc("arcade_loss_hp_emagged")
			usr.gib()
		else
			feedback_inc("arcade_loss_hp_normal")

	src.blocked = 0
	return

/obj/machinery/computer/arcade/emag(mob/user as mob)
	if(is_cheater(user))
		return

	temp = "If you die in the game, you die for real!"
	player_hp = 30
	player_mp = 10
	enemy_hp = 45
	enemy_mp = 20
	gameover = 0
	blocked = 0

	emagged = 1

	enemy_name = "Cuban Pete"
	name = "Outbomb Cuban Pete"

	src.updateUsrDialog()

/obj/machinery/computer/arcade/emp_act(severity)
	if(stat & (NOPOWER|BROKEN))
		..(severity)
		return
	var/empprize = null
	var/num_of_prizes = 0
	switch(severity)
		if(1)
			num_of_prizes = rand(1,4)
		if(2)
			num_of_prizes = rand(0,2)
	for(num_of_prizes; num_of_prizes > 0; num_of_prizes--)
		empprize = pickweight(prizes)
		new empprize(src.loc)

	..(severity)

/obj/machinery/computer/arcade/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(is_cheater(user))
		return

	var/obj/item/weapon/circuitboard/arcade/A
	if(circuit)
		A = new
		export_game_data(A)
	..(toggleitem, user, A)

/obj/machinery/computer/arcade/kick_act()
	..()
	if(stat & (NOPOWER|BROKEN))
		return

	if(is_cheater(usr))
		return

	if(!emagged && prob(5)) //Bug
		temp = "|eW R0vnb##[rand(0,9)]#"
		player_hp = rand(1,30)
		player_mp = rand(1,10)
		enemy_hp = rand(1,60)
		enemy_mp = rand(1,40)
		gameover = 0
		turtle = 0

/obj/machinery/computer/arcade/proc/is_cheater(mob/user as mob)
	var/cheater = 0
	if(emagged && !gameover)
		if(stat & (NOPOWER|BROKEN))
			return cheater
		else if(user in cheaters)
			to_chat(usr, "<span class='danger'>[src.enemy_name] throws a bomb at you for trying to cheat him again.</span>")
			explosion(get_turf(src.loc),-1,0,2)//IED sized explosion
			user.gib()
			cheaters = null
			qdel(src)
			cheater = 1
		else
			to_chat(usr, "<span class='danger'>[src.enemy_name] isn't one to tolerate cheaters. Don't try that again.</span>")
			cheaters += user
			cheater = 1
	return cheater

/obj/machinery/computer/arcade/npc_tamper_act(mob/living/L)
	switch(rand(0,2))
		if(0)
			action_attack()
		if(1)
			action_heal()
		if(2)
			action_charge()
