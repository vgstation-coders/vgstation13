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
	Holiday = APRIL_FOOLS_DAY

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
