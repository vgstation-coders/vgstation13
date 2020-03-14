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

	var/list/current_holidays = list()	//Because it's possible to have multiple holidays on the same day

	Holiday = null // reset our switch now so we can recycle it as our Holiday name

	var/YY = text2num(time2text(world.timeofday, "YY")) 	// get the current year
	var/MM = text2num(time2text(world.timeofday, "MM")) 	// get the current month
	var/DD = text2num(time2text(world.timeofday, "DD")) 	// get the current day

	var/list/Easter_date = Computus()

	// Main switch. If any of these are too dumb/inappropriate, or you have better ones, feel free to change whatever
	switch(MM)
		if(1) // Jan
			switch(DD)
				if(1)
					current_holidays += NEW_YEARS_DAY

		if(2) // Feb
			switch(DD)
				if(2)
					current_holidays += GROUNDHOG_DAY
				if(14)
					current_holidays += VALENTINES_DAY
				if(17)
					current_holidays += RANDOM_ACTS_OF_KINDNESS_DAY

		if(3) // Mar
			switch(DD)
				if(14)
					current_holidays += PI_DAY
				if(17)
					current_holidays += ST_PATRICKS_DAY

		if(4) // Apr
			switch(DD)
				if(1)
					current_holidays += APRIL_FOOLS_DAY
				if(2)
					current_holidays += AUTISM_AWARENESS_DAY
				if(20)
					current_holidays += FOUR_TWENTY
				if(22)
					current_holidays += EARTH_DAY

		if(5) // May
			switch(DD)
				if(1)
					current_holidays += LABOUR_DAY
				if(4)
					current_holidays += FIREFIGHTERS_DAY
				if(12)
					current_holidays += OWL_AND_PUSSYCAT_DAY // what a dumb day of observence...but we -do- have costumes already :3

		if(6) // Jun
			switch(DD)
				if(18)
					current_holidays += INTERNATIONAL_PICNIC_DAY
				if(21)
					current_holidays += SUMMER_SOLSTICE // its not always the 21 but sue me

		if(7) // Jul
			switch(DD)
				if(1)
					current_holidays += DOCTORS_DAY
				if(2)
					current_holidays += UFO_DAY
				if(8)
					current_holidays += WRITERS_DAY
				if(30)
					current_holidays += FRIENDSHIP_DAY

		if(8) // Aug
			switch(DD)
				if(5)
					current_holidays += BEER_DAY

		if(9) // sep
			switch(DD)
				if(19)
					current_holidays += TALK_LIKE_A_PIRATE_DAY
				if(28)
					current_holidays += STUPID_QUESTIONS_DAY

		if(10) // Oct
			switch(DD)
				if(4)
					current_holidays += ANIMALS_DAY
				if(7)
					current_holidays += SMILING_DAY
				if(16)
					current_holidays += BOSS_DAY
				if(31)
					current_holidays += HALLOWEEN

		if(11) // Nov
			switch(DD)
				if(1)
					current_holidays += VEGAN_DAY
				if(13)
					current_holidays += KINDNESS_DAY
				if(19)
					current_holidays += FLOWERS_DAY
				if(21)
					current_holidays += SAYING_HELLO_DAY

		if(12) // Dec
			switch(DD)
				if(10)
					current_holidays += HUMAN_RIGHTS_DAY
				if(14)
					current_holidays += MONKEY_DAY
				if(21)
					if(YY==12)
						current_holidays += END_OF_THE_WORLD
				if(22)
					current_holidays += ORGASMING_DAY	//lol. These all actually exist
				if(24)
					current_holidays += XMAS_EVE
				if(25)
					current_holidays += XMAS
				if(26)
					current_holidays += BOXING_DAY
				if(31)
					current_holidays += NEW_YEARS_EVE

	if(MM == Easter_date["month"] && DD == Easter_date["day"])
		current_holidays += EASTER

	if(current_holidays.len)
		Holiday = pick(current_holidays)

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
		to_chat(world, "<span class='notice'>and...</span>")
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

/proc/Computus()	//This proc calculates the date that Easter falls on for a given year.
	var/current_year = text2num(time2text(world.timeofday, "YYYY"))
	var/M
	var/N
	switch(current_year)
		if(1900 to 2099)
			M = 24
			N = 5
		if(2100 to 2199)
			M = 24
			N = 6
		if(2200 to 2299)
			M = 25
			N = 0
		else
			return	//Easter machine needs maintenance in 300 years
	var/a = current_year % 19
	var/b = current_year % 4
	var/c = current_year % 7
	var/d = (19*a + M) % 30
	var/e = (2*b + 4*c + 6*d + N) % 7
	var/list/Easter_date = list("month" = 0, "day" = 0)
	if((d + e) < 10)
		Easter_date["month"] = 3
		Easter_date["day"] = (d + e + 22)
	else if((d + e) > 9)
		Easter_date["month"] = 4
		Easter_date["day"] = (d + e - 9)
	if(Easter_date["month"] == 4 && Easter_date["day"] == 26)
		Easter_date["day"] = 19
	if(Easter_date["month"] == 4 && Easter_date["day"] == 25 && d == 28 && e == 6 && a > 10)
		Easter_date["day"] = 18

	return Easter_date
