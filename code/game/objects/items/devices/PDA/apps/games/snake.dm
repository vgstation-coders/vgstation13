////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Snake II, by Deity Link, based on the original game from the year 2000, installed on Nokia phones, most notably the Nokia 3310   //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/pda_app/snake
	name = "Snake II"
	desc = "A video game. This old classic from Earth made it all the way to the far reaches of space! Includes station leaderboard."
	category = "Games"
	price = 3
	icon = "pda_game"
	assets_type = /datum/asset/simple/pda_snake
	var/volume = 6
	var/datum/snake_game/snake_game = null
	var/list/highscores = list()
	var/ingame = 0
	var/paused = 0
	var/labyrinth = 0

/datum/pda_app/snake/onInstall(var/obj/item/device/pda/device)
	..()
	for(var/x=1;x<=PDA_APP_SNAKEII_MAXSPEED;x++)
		highscores += x
		highscores[x] = list()
		var/list/templist = highscores[x]
		for(var/y=1;y<=PDA_APP_SNAKEII_MAXLABYRINTH;y++)
			templist += y
			templist[y] = 0

	snake_game = new()

/datum/pda_app/snake/Destroy()
	snake_game = null
	..()

/datum/pda_app/snake/get_dat(var/mob/user)
	var/dat = {"<h4><span class='pda_icon [icon]'></span> Snake II  <a href='byond://?src=\ref[src];snakeVolume=-1'><b>-</b></a><img src="snake_volume[volume].png"/><a href='byond://?src=\ref[src];snakeVolume=1'><b>+</b></a></h4>
		<br>
		<div style="position: relative; left: 0; top: 0;">
		<img src="snake_background.png" style="position: relative; top: 0; left: 0;"/>
		"}
	if(!ingame)
		dat += {"<a href='byond://?src=\ref[src];snakeNewGame=1'><img src="snake_newgame.png" style="position: absolute; top: 50px; left: 100px;"/></a>"}
		dat += {"<img src="snake_highscore.png" style="position: absolute; top: 90px; left: 50px;"/>"}
		var/list/templist = highscores[snake_game.level]
		var/list/winnerlist = snake_station_highscores[snake_game.level]
		dat += {"<img src="snake_[round(templist[labyrinth+1] / 1000) % 10].png" style="position: absolute; top: 90px; left: 210px;"/>"}
		dat += {"<img src="snake_[round(templist[labyrinth+1] / 100) % 10].png" style="position: absolute; top: 90px; left: 226px;"/>"}
		dat += {"<img src="snake_[round(templist[labyrinth+1] / 10) % 10].png" style="position: absolute; top: 90px; left: 242px;"/>"}
		dat += {"<img src="snake_[templist[labyrinth+1] % 10].png" style="position: absolute; top: 90px; left: 258px;"/>"}
		dat += {"<img src="snake_station.png" style="position: absolute; top: 130px; left: 50px;"/>"}
		dat += {"<img src="snake_[round(winnerlist[labyrinth+1] / 1000) % 10].png" style="position: absolute; top: 130px; left: 178px;"/>"}
		dat += {"<img src="snake_[round(winnerlist[labyrinth+1] / 100) % 10].png" style="position: absolute; top: 130px; left: 194px;"/>"}
		dat += {"<img src="snake_[round(winnerlist[labyrinth+1] / 10) % 10].png" style="position: absolute; top: 130px; left: 210px;"/>"}
		dat += {"<img src="snake_[winnerlist[labyrinth+1] % 10].png" style="position: absolute; top: 130px; left: 226px;"/>"}
		var/list/snakebestlist = snake_best_players[snake_game.level]
		dat += "<br>(Station Highscore held by <B>[snakebestlist[labyrinth+1]]</B>)"
		dat += "<br>Set speed: "
		for(var/x=1;x<=9;x++)
			if(x == snake_game.level)
				dat += "<B>[x]</B>, "
			else
				dat += "<a href='byond://?src=\ref[src];snakeLevel=[x]'>[x]</a>, "
		dat += "<br>Set labyrinth: [!labyrinth ? "<b>None</b>" : "<a href='byond://?src=\ref[src];snakeLabyrinth=1;lType=0'>None</a>"], "
		for(var/x=1;x<=7;x++)
			if(x == labyrinth)
				dat += "<B>[x]</B>, "
			else
				dat += "<a href='byond://?src=\ref[src];snakeLabyrinth=1;lType=[x]'>[x]</a>, "
		dat += "<br>Gyroscope (orient yourself to control): "
		dat += "<a href='byond://?src=\ref[src];snakeGyro=1'>[snake_game.gyroscope ? "ON" : "OFF"]</a>"
	else
		if(labyrinth)
			dat += {"<img src="snake_maze[labyrinth].png" style="position: absolute; top: 0px; left: 0px;"/>"}
		for(var/datum/snake/body/B in snake_game.snakeparts)
			var/body_dir = ""
			if(B.life == 1)
				switch(B.dir)
					if(EAST)
						body_dir = "pda_snake_bodytail_east"
					if(WEST)
						body_dir = "pda_snake_bodytail_west"
					if(NORTH)
						body_dir = "pda_snake_bodytail_north"
					if(SOUTH)
						body_dir = "pda_snake_bodytail_south"
			else if(B.life > 1)
				if(B.corner)
					switch(B.dir)
						if(EAST)
							switch(B.corner)
								if(SOUTH)
									body_dir = "pda_snake_bodycorner_eastsouth2"
								if(NORTH)
									body_dir = "pda_snake_bodycorner_eastnorth2"
						if(WEST)
							switch(B.corner)
								if(SOUTH)
									body_dir = "pda_snake_bodycorner_westsouth2"
								if(NORTH)
									body_dir = "pda_snake_bodycorner_westnorth2"
						if(NORTH)
							switch(B.corner)
								if(EAST)
									body_dir = "pda_snake_bodycorner_eastnorth"
								if(WEST)
									body_dir = "pda_snake_bodycorner_westnorth"
						if(SOUTH)
							switch(B.corner)
								if(EAST)
									body_dir = "pda_snake_bodycorner_eastsouth"
								if(WEST)
									body_dir = "pda_snake_bodycorner_westsouth"
				else
					switch(B.dir)
						if(EAST)
							body_dir = "pda_snake_body_east"
						if(WEST)
							body_dir = "pda_snake_body_west"
						if(NORTH)
							body_dir = "pda_snake_body_north"
						if(SOUTH)
							body_dir = "pda_snake_body_south"

				if(B.isfull)
					body_dir += "_full"
			if(!B.flicking)
				dat += {"<img src="[body_dir].png" style="position: absolute; top: [(B.y * 16 * -1) + 152]px; left: [B.x * 16 - 16]px;"/>"}

		dat += {"<img src="pda_snake_egg.png" style="position: absolute; top: [(snake_game.next_egg.y * 16 * -1) + 152]px; left: [snake_game.next_egg.x * 16 - 16]px;"/>"}

		if(snake_game.next_bonus.life > 0)
			dat += {"<img src="pda_snake_bonus[snake_game.next_bonus.bonustype].png" style="position: absolute; top: [(snake_game.next_bonus.y * 16 * -1) + 152]px; left: [snake_game.next_bonus.x * 16 - 8]px;"/>"}
			dat += {"<img src="pda_snake_bonus[snake_game.next_bonus.bonustype].png" style="position: absolute; top: [(180 * -1) + 152]px; left: [280 - 8]px;"/>"}
			dat += {"<img src="snake_[round(snake_game.next_bonus.life / 10) % 10].png" style="position: absolute; top: [(182 * -1) + 152]px; left: [302 - 8]px;"/>"}
			dat += {"<img src="snake_[snake_game.next_bonus.life % 10].png" style="position: absolute; top: [(182 * -1) + 152]px; left: [318 - 8]px;"/>"}

		dat += {"<img src="snake_[round(snake_game.snakescore / 1000) % 10].png" style="position: absolute; top: [(182 * -1) + 152]px; left: [2 - 8]px;"/>"}
		dat += {"<img src="snake_[round(snake_game.snakescore / 100) % 10].png" style="position: absolute; top: [(182 * -1) + 152]px; left: [18 - 8]px;"/>"}
		dat += {"<img src="snake_[round(snake_game.snakescore / 10) % 10].png" style="position: absolute; top: [(182 * -1) + 152]px; left: [34 - 8]px;"/>"}
		dat += {"<img src="snake_[snake_game.snakescore % 10].png" style="position: absolute; top: [(182 * -1) + 152]px; left: [50 - 8]px;"/>"}

		var/head_dir = ""
		switch(snake_game.head.dir)
			if(EAST)
				head_dir = "pda_snake_head_east"
			if(WEST)
				head_dir = "pda_snake_head_west"
			if(NORTH)
				head_dir = "pda_snake_head_north"
			if(SOUTH)
				head_dir = "pda_snake_head_south"
		if(snake_game.head.open_mouth)
			head_dir += "_open"
		if(!snake_game.head.flicking)
			dat += {"<img src="[head_dir].png" style="position: absolute; top: [(snake_game.head.y * 16 * -1) + 152]px; left: [snake_game.head.x * 16 - 16]px;"/>"}
		if(paused)
			dat += {"<a href='byond://?src=\ref[src];snakeUnPause=1'><img src="snake_pause.png" style="position: absolute; top: 50px; left: 128px;"/></a>"}
	dat += {"</div>"}

	dat += {"<h5>Controls</h5>
		<a href='byond://?src=\ref[src];snakeUp=1'><img src="pda_snake_arrow_north.png"></a>
		<br><a href='byond://?src=\ref[src];snakeLeft=1'><img src="pda_snake_arrow_west.png"></a>
		<a href='byond://?src=\ref[src];snakeRight=1'><img src="pda_snake_arrow_east.png"></a>
		<br><a href='byond://?src=\ref[src];snakeDown=1'><img src="pda_snake_arrow_south.png"></a>
		"}
	return dat

/datum/pda_app/snake/Topic(href, href_list)
	if(..())
		return
	if(href_list["snakeNewGame"])
		ingame = 1
		snake_game.game_start()
		game_tick(usr)

	if(href_list["snakeUp"])
		snake_game.lastinput = NORTH

	if(href_list["snakeLeft"])
		snake_game.lastinput = WEST

	if(href_list["snakeRight"])
		snake_game.lastinput = EAST

	if(href_list["snakeDown"])
		snake_game.lastinput = SOUTH

	if(href_list["snakeUnPause"])
		pause(usr)

	if(href_list["snakeLabyrinth"])
		labyrinth = text2num(href_list["lType"])
		snake_game.set_labyrinth(text2num(href_list["lType"]))

	if(href_list["snakeLevel"])
		snake_game.level = text2num(href_list["snakeLevel"])

	if(href_list["snakeGyro"])
		snake_game.gyroscope = !snake_game.gyroscope

	if(href_list["snakeVolume"])
		volume += text2num(href_list["snakeVolume"])
		volume = max(0,volume)
		volume = min(6,volume)
	refresh_pda()

/datum/pda_app/snake/proc/game_tick(var/mob/user)
	snake_game.game_tick(user.dir)

	game_update(user)

	if(snake_game.head.next_full)
		playsound(pda_device, 'sound/misc/pda_snake_eat.ogg', volume * 5, 1)

	if(!paused)
		if(!snake_game.gameover)
			var/snakesleep = 10 - (snake_game.level)
			spawn(snakesleep)
				game_tick(user)
		else
			game_over(user)


/datum/pda_app/snake/proc/game_update(var/mob/user)
	if(istype(user,/mob/living/carbon))
		var/mob/living/carbon/C = user
		if(C.machine && istype(C.machine,/obj/item/device/pda))
			var/obj/item/device/pda/pda_device = C.machine
			var/turf/user_loc = get_turf(user)
			var/turf/pda_loc = get_turf(pda_device)
			if(get_dist(user_loc,pda_loc) <= 1)
				if((locate(src.type) in pda_device.applications) && pda_device.app_menu)
					pda_device.attack_self(C)
				else
					pause(user)
			else
				user.unset_machine()
				user << browse(null, "window=pda")
				pause(user)
		else
			pause(user)
	else
		pause(user)

/datum/pda_app/snake/proc/game_over(var/mob/user)
	playsound(pda_device, 'sound/misc/pda_snake_over.ogg', volume * 5, 0)
	for(var/i=1;i <= 4;i++)
		for(var/datum/snake/body/B in snake_game.snakeparts)
			B.flicking = 1
		snake_game.head.flicking = 1
		game_update(user)
		sleep(5)
		for(var/datum/snake/body/B in snake_game.snakeparts)
			B.flicking = 0
		snake_game.head.flicking = 0
		game_update(user)
		sleep(5)

	save_score()

	//if(snake_game.snakeparts.len >= 179)
	//TODO: achievement

	ingame = 0

	game_update(user)

/datum/pda_app/snake/proc/pause(var/mob/user)
	if(ingame)
		if(!paused)
			paused = 1
		else
			paused = 0
			game_tick(user)

/datum/pda_app/snake/proc/save_score()
	var/list/templist = highscores[snake_game.level]
	templist[labyrinth+1] = max(templist[labyrinth+1], snake_game.snakescore)

	var/list/leaderlist = snake_station_highscores[snake_game.level]
	var/list/winnerlist = snake_best_players[snake_game.level]

	if(templist[labyrinth+1] > leaderlist[labyrinth+1])
		leaderlist[labyrinth+1] = templist[labyrinth+1]
		winnerlist[labyrinth+1] = pda_device.owner

/datum/snake
	var/x = 10
	var/y = 5
	var/life = 7
	var/dir = EAST
	var/isfull = 0
	var/flicking = 0

/datum/snake/head
	var/open_mouth
	var/next_full = 0

/datum/snake/body
	var/corner = null

/datum/snake/bonus
	var/bonustype = 1

/datum/snake/egg

/datum/snake/wall

/datum/snake/wall/New(var/xx,var/yy)
	x = xx
	y = yy

/datum/snake_game
	var/level = 1
	var/snakescore = 0
	var/eggs_eaten = 0	//eggs eaten since the last bonus got eaten/despawned
	var/lastinput = null
	var/gameover = 0
	var/gyroscope = 0
	var/labyrinth = 0

	var/datum/snake/head/head = null
	var/datum/snake/egg/next_egg = null
	var/datum/snake/bonus/next_bonus = null
	var/list/snakeparts = list()
	var/list/labyrinthwalls = list()

/datum/snake_game/proc/game_start()
	gameover = 0
	head = new()
	snakeparts = list()
	for(var/i=6; i > 0; i--)
		var/datum/snake/body/B = new()
		B.x = i+3
		B.life = i
		snakeparts += B
	next_egg = new()
	next_egg.x = 15
	next_bonus = new()
	next_bonus.life = 0
	eggs_eaten = 0
	snakescore = 0
	switch(labyrinth)
		if(3)
			for(var/datum/snake/body/B in snakeparts)
				B.y = 6
				B.x += 5
			head.y = 6
			head.x += 5
			next_egg.y = 6
			next_egg.x = 3
		if(4)
			for(var/datum/snake/body/B in snakeparts)
				B.x += 8
			head.x += 8
			next_egg.x = 3
		if(6)
			for(var/datum/snake/body/B in snakeparts)
				B.x += 8
				B.y = 6
			head.x += 8
			head.y = 6
			next_egg.x = 3
			next_egg.y = 6
		if(7)
			for(var/datum/snake/body/B in snakeparts)
				B.y = 6
			head.y = 6
			next_egg.y = 6

/datum/snake_game/proc/game_tick(var/dir)
	var/datum/snake/body/newbody = new()
	snakeparts += newbody
	newbody.x = head.x
	newbody.y = head.y
	newbody.life = head.life
	if(head.next_full)
		newbody.isfull = 1
		head.next_full = 0

	if(gyroscope)
		lastinput = dir

	var/old_dir = head.dir

	if(lastinput && !((head.dir == NORTH) && (lastinput == SOUTH)) && !((head.dir == SOUTH) && (lastinput == NORTH)) && !((head.dir == EAST) && (lastinput == WEST)) && !((head.dir == WEST) && (lastinput == EAST)))
		if(head.dir != lastinput)
			newbody.corner = head.dir
		head.dir = lastinput
		lastinput = null
	else
		lastinput = null

	newbody.dir = head.dir

	var/next_x = head.x
	var/next_y = head.y
	var/afternext_x = head.x
	var/afternext_y = head.y
	switch(head.dir)
		if(NORTH)
			next_x = head.x
			next_y = head.y + 1
		if(SOUTH)
			next_x = head.x
			next_y = head.y - 1
		if(EAST)
			next_x = head.x + 1
			next_y = head.y
		if(WEST)
			next_x = head.x - 1
			next_y = head.y
	if(next_x > 20)
		next_x = 1
	if(next_x < 1)
		next_x = 20
	if(next_y > 9)
		next_y = 1
	if(next_y < 1)
		next_y = 9
	switch(head.dir)
		if(NORTH)
			afternext_x = next_x
			afternext_y = next_y + 1
		if(SOUTH)
			afternext_x = next_x
			afternext_y = next_y - 1
		if(EAST)
			afternext_x = next_x + 1
			afternext_y = next_y
		if(WEST)
			afternext_x = next_x - 1
			afternext_y = next_y
	if(afternext_x > 20)
		afternext_x = 1
	if(afternext_x < 1)
		afternext_x = 20
	if(afternext_y > 9)
		afternext_y = 1
	if(afternext_y < 1)
		afternext_y = 9

	for(var/datum/snake/body/B in snakeparts)
		if((B.life > 0) && (B.x == next_x) && (B.y == next_y))
			gameover = 1
			head.dir = old_dir
			newbody.life = 0
			snakeparts -= newbody
			return

	for(var/datum/snake/wall/W in labyrinthwalls)
		if((W.x == next_x) && (W.y == next_y))
			gameover = 1
			head.dir = old_dir
			newbody.life = 0
			snakeparts -= newbody
			return

	var/hunger = 0
	if((next_egg.x == next_x) && (next_egg.y == next_y))
		eat_egg(next_x,next_y)
		head.next_full = 1
	if((next_egg.x == afternext_x) && (next_egg.y == afternext_y))
		hunger = 1
	if((next_bonus.life > 0) && ((next_bonus.x == next_x) || (next_bonus.x + 1 == next_x)) && (next_bonus.y == next_y))
		eat_bonus()
		head.next_full = 1
	if((next_bonus.life > 0) && ((next_bonus.x == afternext_x) || (next_bonus.x + 1 == afternext_x)) && (next_bonus.y == afternext_y))
		hunger = 1

	if(hunger)
		head.open_mouth = 1
	else
		head.open_mouth = 0

	if(next_bonus.life > 0)
		next_bonus.life--
		if(next_bonus.life == 0)
			eggs_eaten = 0

	for(var/datum/snake/body/B in snakeparts)
		B.life--
		if(B.life <= 0)
			snakeparts -= B

	head.x = next_x
	head.y = next_y

	if(snakescore >= 9999)
		gameover = 1


/datum/spot
	var/x = 0
	var/y = 0

/datum/spot/New(var/xx,var/yy)
	x = xx
	y = yy

/datum/snake_game/proc/eat_egg(var/next_x,var/next_y)
	head.life++
	for(var/datum/snake/body/B in snakeparts)
		B.life++
	snakescore += level
	var/list/available_spots = list()
	for(var/x=1;x<=20;x++)
		for(var/y=1;y<=9;y++)
			var/datum/spot/S = new(x,y)
			available_spots += S
	for(var/datum/spot/S in available_spots)
		for(var/datum/snake/wall/W in labyrinthwalls)
			if((S.x == W.x) && (S.y == W.y))
				available_spots -= S
		for(var/datum/snake/body/B in snakeparts)
			if((B.life > 0) && (S.x == B.x) && (S.y == B.y))
				available_spots -= S
		if((S.x == head.x) && (S.y == head.y))
			available_spots -= S
		if((S.x == next_x) && (S.y == next_y))
			available_spots -= S
		if((next_bonus.life > 0) && (next_bonus.x == S.x) && (next_bonus.y == S.y))
			available_spots -= S
		if((next_bonus.life > 0) && (next_bonus.x + 1 == S.x) && (next_bonus.y == S.y))
			available_spots -= S
	if(!available_spots.len)
		gameover = 1
		return
	var/datum/spot/chosen_spot = pick(available_spots)
	next_egg.x = chosen_spot.x
	next_egg.y = chosen_spot.y
	eggs_eaten++
	if(eggs_eaten == 5)
		spawn_bonus()

/datum/snake_game/proc/spawn_bonus()
	next_bonus.bonustype = rand(1,6)
	var/list/available_spots = list()
	for(var/x=1;x<=19;x++)	//bonus items are two spot wide.
		for(var/y=1;y<=9;y++)
			var/datum/spot/S = new(x,y)
			available_spots += S
	for(var/datum/spot/S in available_spots)
		for(var/datum/snake/wall/W in labyrinthwalls)
			if((S.x == W.x) && (S.y == W.y))
				available_spots -= S
			if(((S.x+1) == W.x) && (S.y == W.y))
				available_spots -= S
		for(var/datum/snake/body/B in snakeparts)
			if((B.life > 0) && (S.x == B.x) && (S.y == B.y))
				available_spots -= S
			if((B.life > 0) && ((S.x+1) == B.x) && (S.y == B.y))
				available_spots -= S
		if((S.x == head.x) && (S.y == head.y))
			available_spots -= S
		if(((S.x+1) == head.x) && (S.y == head.y))
			available_spots -= S
		if((next_egg.x == S.x) && (next_egg.y == S.y))
			available_spots -= S
		if((next_egg.x == (S.x+1)) && (next_egg.y == S.y))
			available_spots -= S
	if(!available_spots.len)
		eggs_eaten = 4
		return
	var/datum/spot/chosen_spot = pick(available_spots)
	next_bonus.x = chosen_spot.x
	next_bonus.y = chosen_spot.y
	next_bonus.life = 20

/datum/snake_game/proc/eat_bonus()
	snakescore += (next_bonus.life * 2 * level)
	next_bonus.life = 0
	eggs_eaten = 0

////////////////LABYRINTHS//////////////////

/datum/snake_game/proc/set_labyrinth(var/lab_type)
	labyrinthwalls = list()
	labyrinth = lab_type
	switch(lab_type)
		if(0)
			return
		if(1)
			for(var/x=1;x<=20;x++)
				var/datum/snake/wall/W = new(x,1)
				labyrinthwalls += W
			for(var/x=1;x<=20;x++)
				var/datum/snake/wall/W = new(x,9)
				labyrinthwalls += W
			for(var/y=2;y<=8;y++)
				var/datum/snake/wall/W = new(1,y)
				labyrinthwalls += W
			for(var/y=2;y<=8;y++)
				var/datum/snake/wall/W = new(20,y)
				labyrinthwalls += W
		if(2)
			var/datum/snake/wall/W1 = new(1,1)
			labyrinthwalls += W1
			var/datum/snake/wall/W2 = new(2,1)
			labyrinthwalls += W2
			var/datum/snake/wall/W3 = new(1,2)
			labyrinthwalls += W3
			var/datum/snake/wall/W4 = new(20,1)
			labyrinthwalls += W4
			var/datum/snake/wall/W5 = new(19,1)
			labyrinthwalls += W5
			var/datum/snake/wall/W6 = new(20,2)
			labyrinthwalls += W6
			var/datum/snake/wall/W7 = new(1,9)
			labyrinthwalls += W7
			var/datum/snake/wall/W8 = new(1,8)
			labyrinthwalls += W8
			var/datum/snake/wall/W9 = new(2,9)
			labyrinthwalls += W9
			var/datum/snake/wall/W10 = new(20,9)
			labyrinthwalls += W10
			var/datum/snake/wall/W11 = new(19,9)
			labyrinthwalls += W11
			var/datum/snake/wall/W12 = new(20,8)
			labyrinthwalls += W12
			for(var/x=9;x<=12;x++)
				var/datum/snake/wall/W = new(x,4)
				labyrinthwalls += W
			for(var/x=9;x<=12;x++)
				var/datum/snake/wall/W = new(x,6)
				labyrinthwalls += W
		if(3)
			for(var/x=1;x<=10;x++)
				var/datum/snake/wall/W = new(x,3)
				labyrinthwalls += W
			for(var/x=11;x<=20;x++)
				var/datum/snake/wall/W = new(x,7)
				labyrinthwalls += W
			for(var/y=1;y<=5;y++)
				var/datum/snake/wall/W = new(12,y)
				labyrinthwalls += W
			for(var/y=5;y<=9;y++)
				var/datum/snake/wall/W = new(9,y)
				labyrinthwalls += W
		if(4)
			for(var/x=1;x<=20;x++)
				var/datum/snake/wall/W = new(x,1)
				labyrinthwalls += W
			for(var/x=1;x<=20;x++)
				var/datum/snake/wall/W = new(x,9)
				labyrinthwalls += W
			for(var/y=2;y<=8;y++)
				if(y!=5)
					var/datum/snake/wall/W = new(1,y)
					labyrinthwalls += W
			for(var/y=2;y<=8;y++)
				if(y!=5)
					var/datum/snake/wall/W = new(20,y)
					labyrinthwalls += W
			for(var/y=3;y<=7;y++)
				var/datum/snake/wall/W = new(8,y)
				labyrinthwalls += W
			for(var/y=3;y<=7;y++)
				var/datum/snake/wall/W = new(13,y)
				labyrinthwalls += W
		if(5)
			for(var/x=1;x<=20;x++)
				var/datum/snake/wall/W = new(x,3)
				labyrinthwalls += W
			for(var/x=1;x<=20;x++)
				if(x!=10)
					var/datum/snake/wall/W = new(x,6)
					labyrinthwalls += W
			for(var/x=1;x<=17;x++)
				if(x!=4)
					var/datum/snake/wall/W = new(x,9)
					labyrinthwalls += W
			var/datum/snake/wall/W1 = new(1,8)
			labyrinthwalls += W1
			var/datum/snake/wall/W2 = new(9,7)
			labyrinthwalls += W2
			var/datum/snake/wall/W3 = new(9,8)
			labyrinthwalls += W3
			var/datum/snake/wall/W4 = new(11,1)
			labyrinthwalls += W4
			var/datum/snake/wall/W5 = new(11,2)
			labyrinthwalls += W5
		if(6)
			for(var/x=1;x<=20;x++)
				var/datum/snake/wall/W = new(x,5)
				labyrinthwalls += W
			for(var/y=1;y<=9;y++)
				if(y!=5)
					var/datum/snake/wall/W = new(11,y)
					labyrinthwalls += W
		if(7)
			for(var/x=1;x<=20;x++)
				var/datum/snake/wall/W = new(x,5)
				labyrinthwalls += W
			for(var/y=1;y<=4;y++)
				var/datum/snake/wall/W = new(5,y)
				labyrinthwalls += W
			for(var/y=1;y<=4;y++)
				var/datum/snake/wall/W = new(16,y)
				labyrinthwalls += W
