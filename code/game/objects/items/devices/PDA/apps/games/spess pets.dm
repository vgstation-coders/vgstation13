/////////////////////////////////////////////////////////
//   Spess Pets, by Deity Link, based on Tamagotchi    //
/////////////////////////////////////////////////////////

/datum/pda_app/spesspets
	name = "Spess Pets"
	desc = "A virtual pet simulator. For when you don't have the balls to own a real pet. Includes multi-PDA interactions and Nanocoin mining."
	category = "Games"
	price = 10
	icon = "pda_egg"
	assets_type = /datum/asset/simple/pda_spesspets
	var/obj/machinery/account_database/linked_db

	var/game_state = 0	//0 = First Startup; 1 = Egg Chosen; 2 = Egg Hatched (normal status); 3 = Pet Dead
	var/petname = "Ianitchi"
	var/petID = "000000"
	var/level = 0
	var/exp = 0
	var/race = "Corgegg"//Race set here for sanity purposes, the player chooses the race himself

	var/hatching = 0

	var/ishungry = 0
	var/isdirty = 0

	var/ishurt = 0

	var/ishappy = 0
	var/isatwork = 0
	var/issleeping = 0

	var/last_spoken = "Corgegg"

	var/area/walk_target = null
	var/last_walk_start = 0

	var/total_happiness = 0
	var/total_hunger = 0
	var/total_dirty = 0
	var/walk_completed = 0

	var/next_coin = 0
	var/total_coins = 0

	var/isfighting = 0
	var/list/challenged = list()
	var/isvisiting = 0
	var/list/visited = list()

/datum/pda_app/spesspets/onInstall(var/obj/item/device/pda/device)
	..()
	petID = num2text(rand(000000,999999))
	reconnect_database()

/datum/pda_app/spesspets/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in account_DBs)
		if((DB.z == pda_device.loc.z) || (DB.z == map.zMainStation))
			if((DB.stat == 0) && DB.activated )
				linked_db = DB
				break

/datum/pda_app/spesspets/Destroy()
	linked_db = null
	challenged = null
	visited = null
	..()

/datum/pda_app/spesspets/get_dat(var/mob/user)
	var/dat = {"<h4><span class='pda_icon [icon]'></span> Spess Pets</h4>
		<br>Name = [petname]<br>Level = [level]<br>
		<div style="position: relative; left: 0; top: 0;">
		<img src="spesspets_bg.png" style="position: relative; top: 0; left: 0;"/>
		"}
	switch(game_state)
		if(0)	//First Statup
			dat += {"<br><a href='byond://?src=\ref[src];eggPrev=1'><img src="spesspets_arrow_left.png"></a><a href='byond://?src=\ref[src];eggNext=1'><img src="spesspets_arrow_right.png"></a>"}

			dat += {"<a href='byond://?src=\ref[src];eggChose=1'><img src="spesspets_egg0.png" style="position: absolute; top: 32px; left: 32px;"/></a>"}
			dat += {"</div>"}
		if(1)	//Hatching
			var/eggstate = 0
			if(hatching > 1200)
				eggstate = 3
			else if(hatching > 600)
				eggstate = 2
			else if(hatching > 300)
				eggstate = 1
			dat += {"<img src="spesspets_egg[eggstate].png" style="position: absolute; top: 32px; left: 32px;"/>"}
			if(eggstate >= 2)
				dat += {"<a href='byond://?src=\ref[src];eggHatch=1'><img src="spesspets_hatch.png" style="position: absolute; top: 64px; left: 0px;"/></a>"}

		if(2)	//Normal
			if(ishungry)
				dat += {"<img src="spesspets_hunger.png" style="position: absolute; top: 32px; left: 64px;"/>"}
			if(isdirty)
				dat += {"<img src="spesspets_dirty.png" style="position: absolute; top: 32px; left: 96px;"/>"}
			if(ishurt)
				dat += {"<img src="spesspets_hurt.png" style="position: absolute; top: 32px; left: 128px;"/>"}
			if(isatwork)
				dat += {"<img src="spesspets_mine.png" style="position: absolute; top: 32px; left: 32px;"/>"}
			else
				dat += {"<img src="spesspets_[race].png" style="position: absolute; top: 0px; left: 0px;"/>"}
				if(issleeping)
					dat += {"<img src="spesspets_sleep.png" style="position: absolute; top: 0px; left: 32px;"/>"}
				else
					dat += {"<a href='byond://?src=\ref[src];eggTalk=1'><img src="spesspets_talk.png" style="position: absolute; top: 96px; left: 0px;"/></a>"}
					dat += {"<a href='byond://?src=\ref[src];eggWalk=1'><img src="spesspets_walk.png" style="position: absolute; top: 96px; left: 32px;"/></a>"}
					if(ishungry)
						dat += {"<a href='byond://?src=\ref[src];eggFeed=1'><img src="spesspets_feed.png" style="position: absolute; top: 96px; left: 64px;"/></a>"}
					if(isdirty)
						dat += {"<a href='byond://?src=\ref[src];eggClean=1'><img src="spesspets_clean.png" style="position: absolute; top: 96px; left: 96px;"/></a>"}
					if(ishurt)
						dat += {"<a href='byond://?src=\ref[src];eggHeal=1'><img src="spesspets_heal.png" style="position: absolute; top: 112px; left: 0px;"/></a>"}
					dat += {"<a href='byond://?src=\ref[src];eggFight=1'><img src="spesspets_fight.png" style="position: absolute; top: 112px; left: 32px;"/></a>"}
					dat += {"<a href='byond://?src=\ref[src];eggVisit=1'><img src="spesspets_visit.png" style="position: absolute; top: 112px; left: 64px;"/></a>"}
					if(level >= 16)
						dat += {"<a href='byond://?src=\ref[src];eggWork=1'><img src="spesspets_work.png" style="position: absolute; top: 112px; left: 96px;"/></a>"}
			if(total_coins)
				dat += {"<a href='byond://?src=\ref[src];eggRate=1'><img src="spesspets_rate.png" style="position: absolute; top: 96px; left: 128px;"/></a>"}
			if(total_coins)
				dat += {"<a href='byond://?src=\ref[src];eggCash=1'><img src="spesspets_cash.png" style="position: absolute; top: 112px; left: 128px;"/></a>"}

			dat += {"</div>"}
		if(3)	//Dead
			dat += {"</div>"}
	if(last_spoken != "")
		dat += {"<br><br><br><br>[last_spoken]"}
	if(total_coins)
		dat += {"<br>nanocoins: [total_coins]"}
	return dat

/datum/pda_app/spesspets/Topic(href, href_list)
	if(..())
		return

	if(href_list["eggPrev"])
		previous_egg()

	if(href_list["eggNext"])
		next_egg()

	if(href_list["eggChose"])
		petname = copytext(sanitize(input(usr, "What do you want to name your new pet?", "Name your new pet", "[petname]") as null|text),1,MAX_NAME_LEN)
		if(petname && (alert(usr, "[petname] will be your pet's new name - are you sure?", "Confirm Pet's name: ", "Yes", "No") == "Yes"))
			game_state = 1
			game_tick(usr)
			last_spoken = ""

	if(href_list["eggHatch"])
		button_hatch()

	if(href_list["eggTalk"])
		button_talk()

	if(href_list["eggWalk"])
		button_walk()

	if(href_list["eggFeed"])
		button_feed()

	if(href_list["eggClean"])
		button_clean()

	if(href_list["eggHeal"])
		button_heal()

	if(href_list["eggFight"])
		button_fight()

	if(href_list["eggVisit"])
		button_visit()

	if(href_list["eggWork"])
		button_work()

	if(href_list["eggRate"])
		button_rates()

	if(href_list["eggCash"])
		button_cash()

	refresh_pda()

/datum/pda_app/spesspets/proc/game_tick(var/mob/user)
	if (game_state == 1)
		hatching++
		if(hatching > 1200)
			last_spoken = "Help him hatch already you piece of fuck!"
		else if(hatching > 600)
			last_spoken = "Looks like the pet is trying to hatch from the egg!"
		else if(hatching > 300)
			last_spoken = "Did the egg just move?"
		else
			last_spoken = "The egg stands still."

	if (game_state == 2)
		if(isatwork)
			isatwork--
			next_coin--
			if(next_coin <= 0)
				total_coins++
				next_coin = rand(10,15)
				if(ishappy)
					next_coin = rand(5,7)
			if(!isatwork)
				issleeping = 600

		if(issleeping)
			issleeping--
		if(ishappy)
			ishappy--
			total_happiness++
		if(ishungry)
			total_hunger++
		if(isdirty)
			total_dirty++

		if(ishurt)
			ishurt++
			if(ishurt >= 600)
				game_state = 3

		var/new_exp = 0
		if(!isdirty)
			new_exp = 1
			if(ishappy)
				new_exp = new_exp*2
			if(ishurt)
				new_exp = new_exp/2
		exp += new_exp

		if(exp > 900)
			level++
			exp = 0
			if(level >= 50)
				game_state = 3

	game_update(user)

	if(game_state < 3)
		spawn(10)
			game_tick(user)


/datum/pda_app/spesspets/proc/game_update(var/mob/user)
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

/datum/pda_app/spesspets/proc/button_hatch()
	game_state = 2
	level = 1
	last_spoken = "[petname] is born!"

/datum/pda_app/spesspets/proc/next_egg()
	switch(race)
		if("Corgegg")
			race = "Borgegg"
			petname = "Borgitchi"
		if("Borgegg")
			race = "Chimpegg"
			petname = "PunPunitchi"
		if("Chimpegg")
			race = "Syndegg"
			petname = "Nukitchi"
		if("Syndegg")
			race = "Corgegg"
			petname = "Ianitchi"
	last_spoken = race

/datum/pda_app/spesspets/proc/previous_egg()
	switch(race)
		if("Corgegg")
			race = "Syndegg"
			petname = "Nukitchi"
		if("Borgegg")
			race = "Corgegg"
			petname = "Ianitchi"
		if("Chimpegg")
			race = "Borgegg"
			petname = "Borgitchi"
		if("Syndegg")
			race = "Chimpegg"
			petname = "PunPunitchi"
	last_spoken = race

/datum/pda_app/spesspets/proc/button_talk()
	var/talk_line = ""
	switch(race)
		if("Corgegg")
			switch(level)
				if(1 to 5)
					talk_line = pick("woof","arf","nuff","awoo")
				if(6 to 10)
					talk_line = pick("I wuf U","[isdirty ? "I made that for you":"Arf Arf Arf"]","I wanna walk","Awooo")
				if(11 to 15)
					talk_line = pick("Who you woofing to?","[ishurt ? "Tis but a scratch":"Grrrr"]","[ishappy ? "I feel like a million bones":"Gimme something to rip apart"]","Ian is my idol")
				if(16 to 48)
					talk_line = "[issleeping ? "Zzzzz" : "[pick("Woof sweet Woof","The days come and go, and I'm just here, woofing","I should buy a house","Ouaf! Wan! I can woof in 36 different languages!")]"]"
				if(49 to 50)
					talk_line = pick("so tired","I need some sleep")
		if("Borgegg")
			switch(level)
				if(1 to 5)
					talk_line = pick("beebeep","ping","beep boop","buzz")
				if(6 to 10)
					talk_line = pick("Hello World!","[isdirty ? "out, poop":"bebop!"]","squigity giggity","Am I cute?")
				if(11 to 15)
					talk_line = pick("Imma cut you","[ishurt ? "Minor dents aquired":"*buzzing loudly*"]","[ishappy ? "*beeping loudly*":"c'mon, emmag me"]","ur the autistic one")
				if(16 to 48)
					talk_line = "[issleeping ? "Bzzzz" : "[pick("I built that","I'm gonna be a station AI someday","Can I come outside?","Hello World()")]"]"
				if(49 to 50)
					talk_line = pick("Goodnight World","Shutting down")

		if("Chimpegg")
			switch(level)
				if(1 to 5)
					talk_line = pick("ook","ooki","eek","ook?")
				if(6 to 10)
					talk_line = pick("U got a banana?","[isdirty ? "Imma throw me poop at 'em":"Ook? Ook!"]","Dem balls")
				if(11 to 15)
					talk_line = pick("You lookin for monkey trabble?","[ishurt ? "Dun look at me!":"Come on look at me!"]","[ishappy ? "I feel like a million bananas":"Oooooooki!"]","Later I'll be an astrochimp")
				if(16 to 48)
					talk_line = "[issleeping ? "One banana, Two bananas,...." : "[pick("Good ta see ya","I gat sam spare banana juice, let's throw da paaty","What does Ook mean anyway? Out-Of-Karakter?")]"]"
				if(49 to 50)
					talk_line = pick("don't wake me up","I'll be gone soon")

		if("Syndegg")
			switch(level)
				if(1 to 5)
					talk_line = pick("arrr","errr","newkemm","madabone?")
				if(6 to 10)
					talk_line = pick("Are u valeed","[isdirty ? "Nuclear Poop Emergency":"Im a big guy!"]","Look at dis")
				if(11 to 15)
					talk_line = pick("I'm gonna become a cop, the newer kind of cops.","[ishurt ? "Fetch some gauze":"Pow Pow"]","[ishappy ? "I like my stations in pieces":"Gotta get da deesk!"]","Red suits me so well")
				if(16 to 48)
					talk_line = "[issleeping ? "Zzzzz(muffled banter about nukes)zzzzzzz" : "[pick("Alright! Let's get started","I'm saving cash for a Mauler","See the galaxy, Take down Megacorps!")]"]"
				if(49 to 50)
					talk_line = pick("never say die","I will be back")
	last_spoken = "<b>[petname]</b> says: \"[talk_line]\""


/datum/pda_app/spesspets/proc/button_walk()
	if(!walk_target || ((world.time - last_walk_start) > 36000))
		last_walk_start = world.time
		var/list/valid_area_types = list()
		switch(race)
			if("Corgegg")
				valid_area_types = list(
					/area/crew_quarters/bar,
					/area/chapel/main,
					/area/library,
					/area/hydroponics,
					/area/crew_quarters/kitchen,
					/area/crew_quarters/hop,
					)
			if("Borgegg")
				valid_area_types = list(
					/area/crew_quarters/bar,
					/area/maintenance/incinerator,
					/area/engineering/atmos,
					/area/hydroponics,
					/area/storage/tech,
					/area/storage/nuke_storage,
					)
			if("Chimpegg")
				valid_area_types = list(
					/area/crew_quarters/bar,
					/area/crew_quarters/kitchen,
					/area/science/xenobiology,
					/area/science/telescience,
					/area/science/robotics,
					/area/science/test_area,
					/area/maintenance/ghettobar,
					)
			if("Syndegg")
				valid_area_types = list(
					/area/crew_quarters/bar,
					/area/storage/nuke_storage,
					/area/derelict/ship,
					/area/asteroid/clown,
					/area/vox_trading_post,
					/area/science/test_area,
					/area/derelict,
					/area/djstation,
					)
		walk_target = locate(pick(valid_area_types))
		last_spoken = "Looks like [petname] wants to go visit [walk_target.name]!"
	else
		var/area/current_area = get_area(pda_device)
		if(current_area.name == walk_target.name)
			exp += 900
			ishappy = max(300, ishappy)
			walk_completed++
			last_spoken = "[petname] happily looks around \the [walk_target.name]!"
			walk_target = null
		else
			last_spoken = "Looks like [petname] wants to go visit [walk_target.name]!"


/datum/pda_app/spesspets/proc/button_feed()
	if(ishungry)
		ishungry = 0
		var/food = "meat"
		switch(race)
			if("Corgegg")
				food = "[pick("meat","bones")]"
			if("Borgegg")
				food = "[pick("bolts","oil")]"
			if("Chimpegg")
				food = "[pick("bananas","nuts")]"
			if("Syndegg")
				food = "[pick("syndie-cakes","busta-nuts")]"

		last_spoken = "You feed [petname] some [food]!"
		if((level >= 1) && (level <= 5))
			exp += 900


/datum/pda_app/spesspets/proc/button_clean()
	if(isdirty)
		isdirty = 0
		last_spoken = "You clean up [petname]!"


/datum/pda_app/spesspets/proc/button_heal()
	if(ishurt)
		ishurt = 0
		last_spoken = "You bandage up [petname]!"


/datum/pda_app/spesspets/proc/button_fight()
	isfighting = 1
	var/chance_to_win = 50
	if((level >= 11) && (level <= 15))
		chance_to_win += 15
	if(ishurt)
		chance_to_win -= 15
	var/turf/T = get_turf(pda_device)
	var/list/possible_challengers = list()
	for(var/obj/item/device/pda/check_pda in PDAs)
		var/datum/pda_app/spesspets/pet_app = locate(/datum/pda_app/spesspets) in check_pda.applications
		if(pet_app && (pet_app.game_state == 2) && !pet_app.isfighting && (!challenged[pet_app.petID] || (world.time - challenged[pet_app.petID] >= 6000)))
			var/turf/T2 = get_turf(check_pda)
			if(T2 in range(T,3))
				possible_challengers += pet_app
	if(possible_challengers.len)
		var/datum/pda_app/spesspets/challenger = pick(possible_challengers)
		challenged[challenger.petID] = world.time
		last_spoken = "[petname] runs accross [challenger.petname] (level [challenger.level])"
		challenger.last_spoken = "[challenger.petname] runs accross [petname] (level [level])"
		challenger.isfighting = 1
		spawn(20)
			if((level >= 11) && (level <= 15))
				chance_to_win -= 15
			if(prob(chance_to_win))
				last_spoken = "[petname] has defeated [challenger.petname]!"
				ishappy = 1200
				if((level >= 11) && (level <= 15))
					exp += 900

				challenger.last_spoken = "[challenger.petname] has lost to the enemy!"
				challenger.ishurt = max(1,challenger.ishurt)
			else
				last_spoken = "[petname] has lost to [challenger.petname]!"
				ishurt = 1

				challenger.last_spoken = "[challenger.petname] has defeated [petname]!"
				challenger.ishappy = 1200
				if((challenger.level >= 11) && (challenger.level <= 15))
					challenger.exp += 900
		challenger.isfighting = 0
	else
		var/enemy_level = rand(level-3,level+3)
		last_spoken = "[petname] runs accross a level [enemy_level] enemy [pick("mouse","spider","bee","carp")]"
		spawn(20)
			chance_to_win += (level - enemy_level)*2
			chance_to_win = min(100,max(0,chance_to_win))
			if(prob(chance_to_win))
				last_spoken = "[petname] has defeated the enemy!"
				ishappy = 600
				if((level >= 11) && (level <= 15))
					exp += 900
			else
				last_spoken = "[petname] has lost to the enemy!"
				ishurt = max(1,ishurt)
	isfighting = 0



/datum/pda_app/spesspets/proc/button_visit()
	isvisiting = 1
	var/chance_to_get_along = 50
	if((level >= 6) && (level <= 10))
		chance_to_get_along += 15
	var/turf/T = get_turf(pda_device)
	var/list/possible_visitors = list()
	for(var/obj/item/device/pda/check_pda in PDAs)
		var/datum/pda_app/spesspets/pet_app = locate(/datum/pda_app/spesspets) in check_pda.applications
		if(pet_app && (pet_app.game_state == 2) && !pet_app.isvisiting &&(!visited[pet_app.petID] || (world.time - visited[pet_app.petID] >= 6000)))
			var/turf/T2 = get_turf(check_pda)
			if(T2 in range(T,3))
				possible_visitors += pet_app
	if(possible_visitors.len)
		var/datum/pda_app/spesspets/visitor = pick(possible_visitors)
		visited[visitor.petID] = world.time
		last_spoken = "[petname] meets [visitor.petname]"
		visitor.last_spoken = "[visitor.petname] meets [petname]"
		visitor.isvisiting = 1
		spawn(20)
			if((level >= 6) && (level <= 10))
				chance_to_get_along += 15
			if(race == visitor.race)
				chance_to_get_along += 20
			if(prob(chance_to_get_along))
				last_spoken = "[petname] and [visitor.petname] are getting along nicely!"
				visitor.last_spoken = "[visitor.petname] and [petname] are getting along nicely!"
				exp += 900
				visitor.exp += 900
			else
				last_spoken = "[petname] and [visitor.petname] are shouting at each other!"
				visitor.last_spoken = "[visitor.petname] and [petname] are shouting at each other!"
		visitor.isvisiting = 0

	else
		last_spoken = "There is no one to meet nearby."
	isvisiting = 0



/datum/pda_app/spesspets/proc/button_work()
	if(ishungry)
		last_spoken = "[petname] cannot go to work without having lunch first!"
		return
	if(isdirty)
		last_spoken = "[petname] cannot go to work without taking a shower first!"
		return
	if(ishurt)
		last_spoken = "[petname] cannot go to work without getting some medical assistance first!"
		return
	last_spoken = "[petname] just left for work!"
	isatwork = 600


/datum/pda_app/spesspets/proc/button_cash()
	if(!pda_device.id)
		last_spoken = "<i>Insert an ID card linked to collect the nanocoins at the current rates.</i>"
	else
		if(!(linked_db))
			reconnect_database()
		if(linked_db)
			if(linked_db.activated)
				var/datum/money_account/D = linked_db.attempt_account_access(pda_device.id.associated_account_number, 0, 2, 0)
				if(D)
					last_spoken = {"<i>Transferring all nanocoins to [D.owner_name]'s bank account.</i>"}
					var/transaction_amount = nano2dollar(total_coins)
					D.money += transaction_amount

					new /datum/transaction(D, "Nanocoin Transfer (from [src.name]([petname]))", "[transaction_amount]",\
											"Nanocoin Mines", "[D.owner_name] (via [src.name]([petname]))")

					total_coins = 0
				else
					last_spoken = {"<i>Unable to access account. Either its security settings don't allow remote checking or the account is nonexistent.</i>"}
			else
				last_spoken = {"<i>Unfortunately your station's Accounts Database doesn't allow remote access. Negociate with your HoP or Captain to solve this issue.</i>"}
		else
			last_spoken = {"<i>Unable to connect to accounts database. The database is either nonexistent, inoperative, or too far away.</i>"}

/datum/pda_app/spesspets/proc/button_rates()
	last_spoken = "<i>At the current rates you will get [nanocoins_rates] dollars per nanocoins.</i>"


/proc/nano2dollar(var/nanocoins)
	return round(nanocoins * nanocoins_rates)
