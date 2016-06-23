/datum/computer/file/computer_program/arcade
	name = "Arcade 500"
	size = 8.0
	var/enemy_name = "Space Villian"
	var/temp = "Winners Don't Use Spacedrugs" //Temporary message, for attack messages, etc
	var/player_hp = 30 //Player health/attack points
	var/player_mp = 10
	var/enemy_hp = 45 //Enemy health/attack points
	var/enemy_mp = 20
	var/gameover = 0
	var/blocked = 0 //Player cannot attack/heal while set

	New(obj/holding as obj)
		if(holding)
			holder = holding

			if(istype(holder.loc,/obj/machinery/computer2))
				master = holder.loc

//		var/name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ")

		var/name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Evil ", "the Dread King ", "the Space ", "Lord ")
		var/name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon")

		enemy_name = replacetext((name_part1 + name_part2), "the ", "")
//		name = (name_action + name_part1 + name_part2)



/datum/computer/file/computer_program/arcade/return_text()
	if(..())
		return

	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a> | "
	dat += "<a href='byond://?src=\ref[src];quit=1'>Quit</a>"

	dat += "<center><h4>[enemy_name]</h4></center>"

	dat += "<br><center><h3>[temp]</h3></center>"
	dat += "<br><center>Health: [player_hp] | Magic: [player_mp] | Enemy Health: [enemy_hp]</center>"

	if (gameover)
		dat += "<center><b><a href='byond://?src=\ref[src];newgame=1'>New Game</a>"
	else
		dat += "<center><b><a href='byond://?src=\ref[src];attack=1'>Attack</a> | "
		dat += "<a href='byond://?src=\ref[src];heal=1'>Heal</a> | "
		dat += "<a href='byond://?src=\ref[src];charge=1'>Recharge Power</a>"

	dat += "</b></center>"

	return dat

/datum/computer/file/computer_program/arcade/Topic(href, href_list)
	if(..())
		return

	if (!blocked)
		if (href_list["attack"])
			blocked = 1
			var/attackamt = rand(2,6)
			temp = "You attack for [attackamt] damage!"
			master.updateUsrDialog()

			sleep(10)
			enemy_hp -= attackamt
			arcade_action()

		else if (href_list["heal"])
			blocked = 1
			var/pointamt = rand(1,3)
			var/healamt = rand(6,8)
			temp = "You use [pointamt] magic to heal for [healamt] damage!"
			master.updateUsrDialog()

			sleep(10)
			player_mp -= pointamt
			player_hp += healamt
			blocked = 1
			master.updateUsrDialog()
			arcade_action()

		else if (href_list["charge"])
			blocked = 1
			var/chargeamt = rand(4,7)
			temp = "You regain [chargeamt] points"
			player_mp += chargeamt

			master.updateUsrDialog()
			sleep(10)
			arcade_action()

	if (href_list["newgame"]) //Reset everything
		temp = "New Round"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0

	master.add_fingerprint(usr)
	master.updateUsrDialog()
	return

/datum/computer/file/computer_program/arcade/proc/arcade_action()
	if ((enemy_mp <= 0) || (enemy_hp <= 0))
		gameover = 1
		temp = "[enemy_name] has fallen! Rejoice!"
		peripheral_command("vend prize")

	else if ((enemy_mp <= 5) && (prob(70)))
		var/stealamt = rand(2,3)
		temp = "[enemy_name] steals [stealamt] of your power!"
		player_mp -= stealamt
		master.updateUsrDialog()

		if (player_mp <= 0)
			gameover = 1
			sleep(10)
			temp = "You have been drained! GAME OVER"

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

	blocked = 0
	return