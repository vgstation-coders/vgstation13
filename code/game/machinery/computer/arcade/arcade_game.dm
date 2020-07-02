/datum/arcade_game
	var/name = "arcade game"
	var/obj/machinery/computer/arcade/holder
	var/list/prizes = list()
	var/list/cheaters = list()
	var/emagged = 0

/datum/arcade_game/Destroy()
	cheaters = null
	holder = null
	..()

/datum/arcade_game/Topic(href, href_list)
	if(..())
		return TRUE
	if(isobserver(usr) && !isAdminGhost(usr) && !holder.haunted)
		return TRUE

/datum/arcade_game/proc/import_data(var/list/args)
	if(!args || !args["arcade_type"])
		return 0
	if(args["arcade_type"] != type)
		return 0
	return 1

/datum/arcade_game/proc/export_data()
	return list()

/datum/arcade_game/proc/get_dat()
	return ""


/datum/arcade_game/proc/is_cheater(mob/user)
	if(user in cheaters)
		return 1
	return 0

/datum/arcade_game/proc/emag_act(mob/user)

/datum/arcade_game/proc/emp_act(var/severity)

/datum/arcade_game/proc/kick_act()

/datum/arcade_game/proc/npc_tamper_act(mob/living/L)

/datum/arcade_game/proc/dispense_prize(var/num_of_prizes)
	for(var/i=1 to num_of_prizes)
		if(holder.contents.len) //So admins can add a one-time win item.
			var/atom/movable/prize = pick(holder.contents)
			prize.forceMove(holder.loc)
		else
			var/prizeselect = pickweight(prizes)
			if(islist(prizeselect))
				for(var/I in prizeselect)
					new I(holder.loc)
			else
				new prizeselect(holder.loc)

/datum/arcade_game/New(var/holder)
	..()
	src.holder = holder

/datum/arcade_game/space_villain
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
	var/turtle = 0 //Is the player turtling?
	prizes = list(/obj/item/weapon/storage/box/snappops			= 2,
				/obj/item/toy/cards								= 2,
				/obj/item/toy/blink								= 2,
				/obj/item/clothing/under/syndicate/tacticool	= 2,
				/obj/item/toy/sword								= 2,
				/obj/item/toy/bomb								= 1,
				list(/obj/item/toy/gun, /obj/item/toy/ammo/gun) = 2,
				/obj/item/toy/crossbow							= 2,
				/obj/item/weapon/storage/box/syndicatefake/space = 2,
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

/datum/arcade_game/space_villain/New()
	..()
	var/name_action
	var/name_part1
	var/name_part2

	name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ", "Pwn ", "Own ")

	name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Cuban ", "the Evil ", "the Dread King ", "the Space ", "Lord ", "the Great ", "Duke ", "General ")
	name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon", "Uhangoid", "Vhakoid", "Peteoid", "slime", "Griefer", "ERPer", "Lizard Man", "Unicorn")

	enemy_name = replacetext((name_part1 + name_part2), "the ", "")
	name = (name_action + name_part1 + name_part2)

/datum/arcade_game/space_villain/export_data()
	return list("name" = name,
				"emagged" = emagged,
				"enemy_name" = enemy_name,
				"temp" = temp,
				"player_hp" = player_hp,
				"player_max_hp" = player_max_hp,
				"player_mp" = player_mp,
				"player_max_mp" = player_max_mp,
				"enemy_hp" = enemy_hp,
				"enemy_max_hp" = enemy_max_hp,
				"enemy_mp" = enemy_mp,
				"enemy_max_mp" = enemy_max_mp,
				"gameover" = gameover,
				"blocked" = blocked,
				"arcade_type" = type,
				)

/datum/arcade_game/space_villain/import_data(var/list/args)
	if(!..())
		return
	name = args["name"]
	emagged = args["emagged"]
	enemy_name = args["enemy_name"]
	temp = args["temp"]
	player_hp = args["player_hp"]
	player_max_hp = args["player_max_hp"]
	player_mp = args["player_mp"]
	player_max_mp = args["player_max_mp"]
	enemy_hp = args["enemy_hp"]
	enemy_max_hp = args["enemy_max_hp"]
	enemy_mp = args["enemy_mp"]
	enemy_max_mp = args["enemy_max_mp"]
	gameover = args["gameover"]
	blocked = args["blocked"]

/datum/arcade_game/space_villain/get_dat()
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a>"

	dat += {"<center><h4>[enemy_name]</h4></center>
		<br><center><h3>[temp]</h3></center>
		<br><center>Health: [player_hp] | Magic: [player_mp] | Enemy Health: [enemy_hp]</center>"}
	if (gameover)
		dat += "<center><b><a href='byond://?src=\ref[src];newgame=1'>New Game</a>"
	else

		dat += {"<center><b><a href='byond://?src=\ref[src];attack=1'>Attack</a> |
			<a href='byond://?src=\ref[src];heal=1'>Heal</a> |
			<a href='byond://?src=\ref[src];charge=1'>Recharge Power</a>"}

	dat += "</b></center>"

	return dat

/datum/arcade_game/space_villain/Topic(href, href_list)
	if(..())
		return
	if (!blocked && !gameover)
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

	holder.add_fingerprint(usr)
	holder.updateUsrDialog()


/datum/arcade_game/space_villain/proc/arcade_action()
	if ((enemy_mp <= 0) || (enemy_hp <= 0))
		if(!gameover)
			gameover = 1
			temp = "[enemy_name] has fallen! Rejoice!"

			if(emagged)
				feedback_inc("arcade_win_emagged")
				new /obj/item/clothing/head/collectable/petehat(holder.loc)
				new /obj/item/device/maracas/cubanpete(holder.loc)
				new /obj/item/device/maracas/cubanpete(holder.loc)
				message_admins("[key_name_admin(usr)] has outbombed Cuban Pete and been awarded explosive maracas.")
				log_game("[key_name_admin(usr)] has outbombed Cuban Pete and been awarded explosive maracas.")
				holder.New()
				emagged = 0

			else
				feedback_inc("arcade_win_normal")
				dispense_prize(1)

	else if (emagged && (turtle >= 4))
		var/boomamt = rand(5,10)
		temp = "[enemy_name] throws a bomb, exploding you for [boomamt] damage!"
		player_hp -= boomamt

	else if ((enemy_mp <= 5) && (prob(70)))
		var/stealamt = rand(2,3)
		temp = "[enemy_name] steals [stealamt] of your power!"
		player_mp -= stealamt
		holder.updateUsrDialog()

		if (player_mp <= 0)
			gameover = 1
			sleep(10)
			temp = "You have been drained! GAME OVER"
			if(emagged)
				feedback_inc("arcade_loss_mana_emagged")
				usr.gib()
			else
				feedback_inc("arcade_loss_mana_normal")

	else if ((enemy_hp <= 10) && (enemy_mp > 4))
		temp = "[enemy_name] heals for 4 health!"
		enemy_hp += 4
		enemy_mp -= 4

	else
		var/attackamt = rand(3,6)
		temp = "[enemy_name] attacks for [attackamt] damage!"
		player_hp -= attackamt

	if ((player_mp <= 0) || (player_hp <= 0))
		gameover = 1
		temp = "You have been crushed! GAME OVER"
		if(emagged)
			feedback_inc("arcade_loss_hp_emagged")
			usr.gib()
		else
			feedback_inc("arcade_loss_hp_normal")

	blocked = 0

/datum/arcade_game/space_villain/proc/action_charge()
	blocked = 1
	var/chargeamt = rand(4,7)
	temp = "You regain [chargeamt] points"
	player_mp += chargeamt
	if(turtle > 0)
		turtle--

	holder.updateUsrDialog()
	sleep(10)
	arcade_action()

/datum/arcade_game/space_villain/proc/action_heal()
	blocked = 1
	var/pointamt = rand(1,3)
	var/healamt = rand(6,8)
	temp = "You use [pointamt] magic to heal for [healamt] damage!"
	holder.updateUsrDialog()
	turtle++

	sleep(10)
	player_mp -= pointamt
	player_hp += healamt
	blocked = 1
	holder.updateUsrDialog()
	arcade_action()

/datum/arcade_game/space_villain/proc/action_attack()
	blocked = 1
	var/attackamt = rand(2,6)
	temp = "You attack for [attackamt] damage!"
	holder.updateUsrDialog()
	if(turtle > 0)
		turtle--

	sleep(10)
	enemy_hp -= attackamt
	arcade_action()

/datum/arcade_game/space_villain/is_cheater(mob/user)
	if(emagged && !gameover)
		if(holder.stat & (NOPOWER|BROKEN))
			return 0
		else if(user in cheaters)
			to_chat(usr, "<span class='danger'>[enemy_name] throws a bomb at you for trying to cheat him again.</span>")
			explosion(holder.loc,-1,0,2)//IED sized explosion
			user.gib()
			cheaters = null
			qdel(src)
			return 1
		else
			to_chat(usr, "<span class='danger'>[enemy_name] isn't one to tolerate cheaters. Don't try that again.</span>")
			cheaters += user
			return 1
	return 0

/datum/arcade_game/space_villain/emag_act(mob/user)
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

	holder.updateUsrDialog()

/datum/arcade_game/space_villain/emp_act(var/severity)
	var/num_of_prizes = 0
	switch(severity)
		if(1)
			num_of_prizes = rand(1,4)
		if(2)
			num_of_prizes = rand(0,2)
	dispense_prize(num_of_prizes)

/datum/arcade_game/space_villain/kick_act()
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

/datum/arcade_game/space_villain/npc_tamper_act(mob/living/L)
	switch(rand(0,2))
		if(0)
			action_attack()
		if(1)
			action_heal()
		if(2)
			action_charge()
