/////////////////////////////////////////////////////////
//   Minesweeper, by Deity Link, based on Winmine95    //
/////////////////////////////////////////////////////////

///////////MINESWEEPER//////////////////////////////////////////////////////////////

/datum/pda_app/minesweeper
	name = "Minesweeper"
	desc = "A video game. This old classic from Earth made it all the way to the far reaches of space! Includes station leaderboard."
	category = "Games"
	price = 5
	icon = "pda_game"
	assets_type = /datum/asset/simple/pda_mine
	var/ingame = 0
	var/datum/minesweeper_game/minesweeper_game = null


/datum/pda_app/minesweeper/onInstall(var/obj/item/device/pda/device)
	..()
	minesweeper_game = new()

/datum/pda_app/minesweeper/Destroy()
	minesweeper_game = null
	..()

/datum/pda_app/minesweeper/get_dat(var/mob/user)
	var/dat = {"<h4><span class='pda_icon [icon]'></span> Minesweeper</h4><br>
			<div style="position: relative; left: 0; top: 0;">
			<img src="minesweeper_bg_[minesweeper_game.current_difficulty].png" style="position: relative; top: 0; left: 0;"/>
			"}
	if(!ingame)
		for(var/datum/mine_tile/T in minesweeper_game.tiles)
			dat += {"<a href='byond://?src=\ref[src];mineNewGame=\ref[T]'><img src="minesweeper_tile_full.png" style="position: absolute; top: [(T.y * 16 * -1) + (minesweeper_game.rows * 16)]px; left: [T.x * 16]px;"/></a>"}
	else
		for(var/datum/mine_tile/T in minesweeper_game.tiles)
			var/mine_icon = ""
			if(T.dug)
				if(T.mined)
					mine_icon = "minesweeper_tile_mine_splode"
				else if(T.num)
					mine_icon = "minesweeper_tile_[T.num]"
				else
					mine_icon = "minesweeper_tile_empty"

			else
				if(T.mined && minesweeper_game.gameover)
					if(T.flagged == 1)
						mine_icon = "minesweeper_tile_flag"
					else
						mine_icon = "minesweeper_tile_mine_unsplode"
				else if(T.flagged == 1)
					if(minesweeper_game.gameover)
						mine_icon = "minesweeper_tile_mine_wrong"
					else
						mine_icon = "minesweeper_tile_flag"
				else if(T.flagged == 2)
					mine_icon = "minesweeper_tile_question"
				else
					mine_icon = "minesweeper_tile_full"
			if(T.selected && !minesweeper_game.gameover)
				mine_icon += "_selected"
			dat += {"<a href='byond://?src=\ref[src];mineDig=\ref[T]'><img src="[mine_icon].png" style="position: absolute; top: [(T.y * 16 * -1) + (minesweeper_game.rows * 16)]px; left: [T.x * 16]px;"/></a>"}
		dat += {"<a href='byond://?src=\ref[src];mineFlag=1'><img src="minesweeper_flag.png" style="position: absolute; top: [minesweeper_game.rows * 16 + 48]px; left: 16px;"/></a>"}
		dat += {"<a href='byond://?src=\ref[src];mineQuestion=1'><img src="minesweeper_question.png" style="position: absolute; top: [minesweeper_game.rows * 16 + 48]px; left: 48px;"/></a>"}
	dat += {"<a href='byond://?src=\ref[src];mineSettings=1'><img src="minesweeper_settings.png" style="position: absolute; top: [minesweeper_game.rows * 16 + 48]px; left: 96px;"/></a>"}

	dat += {"<img src="minesweeper_frame_smiley.png" style="position: absolute; top: -33px; left: [(minesweeper_game.columns * 8)+3]px;"/></a>"}
	dat += {"<a href='byond://?src=\ref[src];mineReset=1'><img src="minesweeper_smiley_[minesweeper_game.face].png" style="position: absolute; top: -32px; left: [(minesweeper_game.columns * 8)+4]px;"/></a>"}

	dat += {"<img src="minesweeper_frame_counter.png" style="position: absolute; top: -33px; left: 21px;"/>"}
	var/mine_counter = minesweeper_game.initial_mines
	for(var/datum/mine_tile/T in minesweeper_game.tiles)
		if(T.flagged == 1)
			mine_counter--
	dat += {"<img src="minesweeper_counter_[round(mine_counter / 100) % 10].png" style="position: absolute; top: -32px; left: 22px;"/>"}
	dat += {"<img src="minesweeper_counter_[round(mine_counter / 10) % 10].png" style="position: absolute; top: -32px; left: 35px;"/>"}
	dat += {"<img src="minesweeper_counter_[mine_counter % 10].png" style="position: absolute; top: -32px; left: 48px;"/>"}

	dat += {"<img src="minesweeper_frame_counter.png" style="position: absolute; top: -33px; left: [(minesweeper_game.columns * 16)-30]px;"/>"}
	var/time_counter = round((world.time - minesweeper_game.timer)/10)
	time_counter = min(999,time_counter)
	if(!ingame || minesweeper_game.gameover)
		time_counter = minesweeper_game.end_timer
	dat += {"<img src="minesweeper_counter_[round(time_counter / 100) % 10].png" style="position: absolute; top: -32px; left: [(minesweeper_game.columns * 16)-29]px;"/>"}
	dat += {"<img src="minesweeper_counter_[round(time_counter / 10) % 10].png" style="position: absolute; top: -32px; left: [(minesweeper_game.columns * 16)-16]px;"/>"}
	dat += {"<img src="minesweeper_counter_[time_counter % 10].png" style="position: absolute; top: -32px; left: [(minesweeper_game.columns * 16)-3]px;"/>"}

	dat += {"<img src="minesweeper_border_cornertopleft.png" style="position: absolute; top: -16px; left: 0px;"/>"}
	dat += {"<img src="minesweeper_border_cornerbotleft.png" style="position: absolute; top: [(minesweeper_game.rows * 16)]px; left: 0px;"/>"}
	dat += {"<img src="minesweeper_border_cornertopright.png" style="position: absolute; top: -16px; left: [(minesweeper_game.columns * 16) + 16]px;"/>"}
	dat += {"<img src="minesweeper_border_cornerbotright.png" style="position: absolute; top: [(minesweeper_game.rows * 16)]px; left: [(minesweeper_game.columns * 16) + 16]px;"/>"}
	for(var/x=1;x<=minesweeper_game.columns;x++)
		dat += {"<img src="minesweeper_border_top.png" style="position: absolute; top: -16px; left: [16*x]px;"/>"}
	for(var/x=1;x<=minesweeper_game.columns;x++)
		dat += {"<img src="minesweeper_border_bot.png" style="position: absolute; top: [(minesweeper_game.rows * 16)]px; left: [16*x]px;"/>"}
	for(var/y=0;y<minesweeper_game.rows;y++)
		dat += {"<img src="minesweeper_border_left.png" style="position: absolute; top: [16*y]px; left: 0px;"/>"}
	for(var/y=0;y<minesweeper_game.rows;y++)
		dat += {"<img src="minesweeper_border_right.png" style="position: absolute; top: [16*y]px; left: [(minesweeper_game.columns * 16) + 16]px;"/>"}


	dat += {"</div>"}
	if(minesweeper_game.current_difficulty != "custom")
		dat += {"<br>[minesweeper_game.current_difficulty] difficulty highscore held by <b>[minesweeper_best_players[minesweeper_game.current_difficulty]]</b> (in <b>[minesweeper_station_highscores[minesweeper_game.current_difficulty]]</b> seconds)"}
	return dat

/datum/pda_app/minesweeper/Topic(href, href_list)
	if(..())
		return
	if(href_list["mineNewGame"])
		var/datum/mine_tile/T = locate(href_list["mineNewGame"])
		ingame = 1
		minesweeper_game.game_start(T)
		game_tick(usr)

	if(href_list["mineDig"])
		var/datum/mine_tile/T = locate(href_list["mineDig"])
		minesweeper_game.dig_tile(T)
		game_tick(usr)

	if(href_list["mineFlag"])
		if(!minesweeper_game.gameover)
			for(var/datum/mine_tile/T in minesweeper_game.tiles)
				if(!T.dug && T.selected)
					if(!T.flagged)
						T.flagged = 1
					else if(T.flagged == 2)
						T.flagged = 1
					else
						T.flagged = 0

	if(href_list["mineQuestion"])
		if(!minesweeper_game.gameover)
			for(var/datum/mine_tile/T in minesweeper_game.tiles)
				if(!T.dug && T.selected)
					if(!T.flagged)
						T.flagged = 2
					else if(T.flagged == 1)
						T.flagged = 2
					else
						T.flagged = 0

	if(href_list["mineSettings"])
		if(alert(usr, "Changing the settings will reset the game, are you sure?", "Minesweeper Settings", "Yes", "No") != "Yes")
			return
		var/list/difficulties = list(
			"beginner",
			"intermediate",
			"expert",
			"custom",
			)
		var/choice = input("What Difficulty?", "Minesweeper Settings") in difficulties
		minesweeper_game.set_difficulty(choice)
		ingame = 0

	if(href_list["mineReset"])
		minesweeper_game.face = "press"
		game_update(usr)
		sleep(5)
		minesweeper_game.reset_game()
		ingame = 0
	refresh_pda()

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
				if((locate(src.type) in pda_device.applications) && pda_device.app_menu)
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
