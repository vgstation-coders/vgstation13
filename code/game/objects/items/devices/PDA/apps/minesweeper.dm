/////////////////////////////////////////////////////////
//   Minesweeper, by Deity Link, based on Winmine95    //
/////////////////////////////////////////////////////////

///////////MINESWEEPER//////////////////////////////////////////////////////////////

/datum/pda_app/minesweeper
	name = "Minesweeper"
	desc = "A video game. This old classic from Earth made it all the way to the far reaches of space! Includes station leaderboard."
	price = 5
	menu = PDA_APP_MINESWEEPER
	icon = "pda_game"
	var/ingame = 0
	var/datum/minesweeper_game/minesweeper_game = null


/datum/pda_app/minesweeper/onInstall(var/obj/item/device/pda/device)
	..()
	minesweeper_game = new()

/datum/pda_app/minesweeper/Destroy()
	minesweeper_game = null
	..()

/datum/pda_app/minesweeper/proc/game_tick(var/mob/user)
	sleep(1)	//to give the game the time to process all tiles if many are dug at once.
	if(minesweeper_game.gameover && (minesweeper_game.face == "win"))
		save_score()
	game_update(user)

/datum/pda_app/minesweeper/proc/game_update(var/mob/user)
	if(istype(user,/mob/living/carbon))
		var/mob/living/carbon/C = user
		if(C.machine && istype(C.machine,/obj/item/device/pda))
			var/obj/item/device/pda/pda_device = C.machine
			var/turf/user_loc = get_turf(user)
			var/turf/pda_loc = get_turf(pda_device)
			if(get_dist(user_loc,pda_loc) <= 1)
				if(pda_device.mode == PDA_APP_MINESWEEPER)
					pda_device.attack_self(C)
			else
				user.unset_machine()
				user << browse(null, "window=pda")

/datum/pda_app/minesweeper/proc/save_score()
	if(minesweeper_game.current_difficulty == "custom")
		return
	if(minesweeper_game.end_timer < minesweeper_station_highscores[minesweeper_game.current_difficulty])
		minesweeper_station_highscores[minesweeper_game.current_difficulty] = minesweeper_game.end_timer
		minesweeper_best_players[minesweeper_game.current_difficulty] = pda_device.owner

/datum/mine_tile
	var/x = 1
	var/y = 1
	var/selected = 0
	var/dug = 0
	var/mined = 0
	var/flagged = 0	//1 = red flag; 2 = question mark;
	var/num = 0

/datum/minesweeper_game
	var/list/tiles = list()
	var/gameover = 0
	var/columns = 8
	var/rows = 8
	var/initial_mines = 10
	var/current_difficulty = "beginner"
	var/mine_count = 0
	var/timer = 0
	var/end_timer = 0
	var/holes = 0
	var/face = "normal"

/datum/minesweeper_game/New()
	end_timer = 0
	timer = 0
	mine_count = 0
	holes = 0
	tiles = list()
	for(var/y=1;y<=rows;y++)
		for(var/x=1;x<=columns;x++)
			var/datum/mine_tile/T = new()
			tiles += T
			T.x = x
			T.y = y

/datum/minesweeper_game/proc/game_start(var/datum/mine_tile/first_T)
	first_T.selected = 1
	timer = world.time
	while(mine_count < initial_mines)
		var/datum/mine_tile/T = pick(tiles)
		if(!T.mined && !T.selected)
			T.mined = 1
			mine_count++

	dig_tile(first_T)

/datum/minesweeper_game/proc/dig_tile(var/datum/mine_tile/T,var/force=0)
	if(T.dug)
		return
	if(!T.selected && !force)
		for(var/datum/mine_tile/other_T in tiles)
			other_T.selected = 0
		T.selected = 1
		face = "fear"
		return
	if(T.flagged == 1)
		return
	T.selected = 0
	face = "normal"
	T.dug = 1
	if(T.mined)
		face = "dead"
		end_timer = min(999,round((world.time - timer)/10))
		gameover = 1
	else
		holes++
		if((mine_count+holes) == tiles.len)
			for(var/datum/mine_tile/other_T in tiles)
				if(other_T.mined)
					other_T.flagged = 1
			face = "win"
			end_timer = min(999,round((world.time - timer)/10))
			gameover = 1
	var/list/neighbors = list()
	for(var/datum/mine_tile/near_T in tiles)
		if(((near_T.x - T.x)*(near_T.x - T.x) + (near_T.y - T.y)*(near_T.y - T.y)) <= 2)
			if(near_T.mined)
				T.num++
			else
				neighbors += near_T
	if(!T.num)
		for(var/datum/mine_tile/near_T in neighbors)
			spawn()
				dig_tile(near_T,1)

/datum/minesweeper_game/proc/set_difficulty(var/choice)
	switch(choice)
		if("beginner")
			rows = 8
			columns = 8
			initial_mines = 10
		if("intermediate")
			rows = 16
			columns = 16
			initial_mines = 40
		if("expert")
			rows = 16
			columns = 30
			initial_mines = 99
		if("custom")
			var/choiceX = input("How many columns?", "Minesweeper Settings") as num
			var/choiceY = input("How many rows?", "Minesweeper Settings") as num
			var/choiceM = input("How many mines?", "Minesweeper Settings") as num
			choiceX = max(8,min(30,choiceX))
			choiceY = max(8,min(24,choiceY))
			choiceM = max(10,min((choiceX-1)*(choiceY-1),choiceM))
			columns = choiceX
			rows = choiceY
			initial_mines = choiceM
	current_difficulty = choice
	reset_game()

/datum/minesweeper_game/proc/reset_game()
	gameover = 0
	face = "normal"
	end_timer = 0
	timer = 0
	mine_count = 0
	holes = 0
	tiles = list()
	for(var/y=1;y<=rows;y++)
		for(var/x=1;x<=columns;x++)
			var/datum/mine_tile/T = new()
			tiles += T
			T.x = x
			T.y = y
