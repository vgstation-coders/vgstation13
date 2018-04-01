//Uncommenting ALLOW_HOLIDAYS in config.txt will enable Holidays
var/global/Holiday = null

//Just thinking ahead! Here's the foundations to a more robust Holiday event system.
//It's easy as hell to add stuff. Just set Holiday to something using the switch (or something else)
//then use if(Holiday == "MyHoliday") to make stuff happen on that specific day only
//Please, Don't spam stuff up with easter eggs, I'd rather somebody just delete this than people cause
//the game to lag even more in the name of one-day content.

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//ALSO, MOST IMPORTANTLY: Don't add stupid stuff! Discuss bonus content with Project-Heads first please!//
//////////////////////////////////////////////////////////////////////////////////////////////////////////
//																							~Carn

// sets up the Holiday global variable. Shouldbe called on game configuration or something.
/proc/Get_Holiday()
	if(!Holiday)  //  Holiday stuff was not enabled in the config!
		return

	Holiday = null // reset our switch now so we can recycle it as our Holiday name

	var/YY = text2num(time2text(world.timeofday, "YY")) 	// get the current year
	var/MM = text2num(time2text(world.timeofday, "MM")) 	// get the current month
	var/DD = text2num(time2text(world.timeofday, "DD")) 	// get the current day

	// Main switch. If any of these are too dumb/inappropriate, or you have better ones, feel free to change whatever
	switch(MM)
		if(1) // Jan
			switch(DD)
				if(1)
					Holiday = NEW_YEARS_DAY

		if(2) // Feb
			switch(DD)
				if(2)
					Holiday = GROUNDHOG_DAY
				if(14)
					Holiday = VALENTINES_DAY
				if(17)
					Holiday = RANDOM_ACTS_OF_KINDNESS_DAY

		if(3) // Mar
			switch(DD)
				if(14)
					Holiday = PI_DAY
				if(17)
					Holiday = ST_PATRICKS_DAY
				if(27)
					if(YY == 16)
						Holiday = EASTER
				if(31)
					if(YY == 13)
						Holiday = EASTER

		if(4) // Apr
			switch(DD)
				if(1)
					Holiday = APRIL_FOOLS_DAY
					if(YY == 18 && prob(50))
						Holiday = EASTER
				if(2)
					Holiday = AUTISM_AWARENESS_DAY
				if(5)
					if(YY == 15)
						Holiday = EASTER
				if(16)
					if(YY == 17)
						Holiday = EASTER
				if(20)
					Holiday = FOUR_TWENTY
					if(YY == 14 && prob(50))
						Holiday = EASTER
				if(22)
					Holiday = EARTH_DAY

		if(5) // May
			switch(DD)
				if(1)
					Holiday = LABOUR_DAY
				if(4)
					Holiday = FIREFIGHTERS_DAY
				if(12)
					Holiday = OWL_AND_PUSSYCAT_DAY // what a dumb day of observence...but we -do- have costumes already :3

		if(6) // Jun
			switch(DD)
				if(18)
					Holiday = INTERNATIONAL_PICNIC_DAY
				if(21)
					Holiday = SUMMER_SOLSTICE // its not always the 21 but sue me

		if(7) // Jul
			switch(DD)
				if(1)
					Holiday = DOCTORS_DAY
				if(2)
					Holiday = UFO_DAY
				if(8)
					Holiday = WRITERS_DAY
				if(30)
					Holiday = FRIENDSHIP_DAY

		if(8) // Aug
			switch(DD)
				if(5)
					Holiday = BEER_DAY

		if(9) // sep
			switch(DD)
				if(19)
					Holiday = TALK_LIKE_A_PIRATE_DAY
				if(28)
					Holiday = STUPID_QUESTIONS_DAY

		if(10) // Oct
			switch(DD)
				if(4)
					Holiday = ANIMALS_DAY
				if(7)
					Holiday = SMILING_DAY
				if(16)
					Holiday = BOSS_DAY
				if(31)
					Holiday = HALLOWEEN

		if(11) // Nov
			switch(DD)
				if(1)
					Holiday = VEGAN_DAY
				if(13)
					Holiday = KINDNESS_DAY
				if(19)
					Holiday = FLOWERS_DAY
				if(21)
					Holiday = SAYING_HELLO_DAY

		if(12) // Dec
			switch(DD)
				if(10)
					Holiday = HUMAN_RIGHTS_DAY
				if(14)
					Holiday = MONKEY_DAY
				if(21)
					if(YY==12)
						Holiday = END_OF_THE_WORLD
				if(22)
					Holiday = ORGASMING_DAY	//lol. These all actually exist
				if(24)
					Holiday = XMAS_EVE
				if(25)
					Holiday = XMAS
				if(26)
					Holiday = BOXING_DAY
				if(31)
					Holiday = NEW_YEARS_EVE
	if(!Holiday)
		// Friday the 13th
		if(DD == 13)
			if(time2text(world.timeofday, "DDD") == "Fri")
				Holiday = FRIDAY_THE_13TH

//Allows GA and GM to set the Holiday variable
/client/proc/Set_Holiday(T as text|null)
	set name = ".Set Holiday"
	set category = "Fun"
	set desc = "Force-set the Holiday variable to make the game think it's a certain day."
	if(!check_rights(R_SERVER))
		return

	Holiday = T
	//get a new station name
	station_name = null
	station_name()
	//update our hub status
	world.update_status()
	Holiday_Game_Start()

	message_admins("<span class='notice'>ADMIN: Event: [key_name(src)] force-set Holiday to \"[Holiday]\"</span>")
	log_admin("[key_name(src)] force-set Holiday to \"[Holiday]\"")


// Run at the  start of a round
/proc/Holiday_Game_Start()
	if(Holiday)
		to_chat(world, "<font color='blue'>and...</font>")
		to_chat(world, "<h4>Happy [Holiday] Everybody!</h4>")
		if(Holiday == XMAS_EVE || Holiday == XMAS)
			Christmas_Game_Start()

// Nested in the random events loop. Will be triggered every 2 minutes
/proc/Holiday_Random_Event()
	switch(Holiday) // special holidays
		if("",null)	// no Holiday today! Back to work!
			return

		if(END_OF_THE_WORLD) //2012 is long gone, not clue why this is still a thing.
			if(prob(eventchance))
				GameOver()

		if(XMAS_EVE,XMAS)
			if(prob(eventchance))
				ChristmasEvent()
