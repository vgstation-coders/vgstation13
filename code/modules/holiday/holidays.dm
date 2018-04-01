/datum/holiday
	var/name = "Bugsgiving"

	var/begin_day = 1
	var/begin_month = 0
	var/end_day = 0 // Default of 0 means the holiday lasts a single day
	var/end_month = 0
	var/begin_week = FALSE //If set to a number, then this holiday will begin on certain week
	var/begin_weekday = FALSE //If set to a weekday, then this will trigger the holiday on the above week
	var/always_celebrate = FALSE // for christmas neverending, or testing.
	var/current_year = 0
	var/year_offset = 0
	var/obj/item/drone_hat //If this is defined, drones without a default hat will spawn with this one during the holiday; check drones_as_items.dm to see this used

// This proc gets run before the game starts when the holiday is activated. Do festive shit here.
/datum/holiday/proc/celebrate()
	return

// When the round starts, this proc is ran to get a text message to display to everyone to wish them a happy holiday
/datum/holiday/proc/greet()
	return "Have a happy [name]!"

// Returns special prefixes for the station name on certain days. You wind up with names like "Christmas Object Epsilon". See new_station_name()
/datum/holiday/proc/getStationPrefix()
	//get the first word of the Holiday and use that
	var/i = findtext(name," ",1,0)
	return copytext(name,1,i)

// Return 1 if this holidy should be celebrated today
/datum/holiday/proc/shouldCelebrate(dd, mm, yy, ww, ddd)
	if(always_celebrate)
		return TRUE

	if(!end_day)
		end_day = begin_day
	if(!end_month)
		end_month = begin_month
	if(begin_week && begin_weekday)
		if(begin_week == ww && begin_weekday == ddd && begin_month == mm)
			return TRUE
	if(end_month > begin_month) //holiday spans multiple months in one year
		if(mm == end_month) //in final month
			if(dd <= end_day)
				return TRUE

		else if(mm == begin_month)//in first month
			if(dd >= begin_day)
				return TRUE

		else if(mm in begin_month to end_month) //holiday spans 3+ months and we're in the middle, day doesn't matter at all
			return TRUE

	else if(end_month == begin_month) // starts and stops in same month, simplest case
		if(mm == begin_month && (dd in begin_day to end_day))
			return TRUE

	else // starts in one year, ends in the next
		if(mm >= begin_month && dd >= begin_day) // Holiday ends next year
			return TRUE
		if(mm <= end_month && dd <= end_day) // Holiday started last year
			return TRUE

	return FALSE

// The actual holidays

/datum/holiday/new_year
	name = NEW_YEAR
	begin_day = 30
	begin_month = DECEMBER
	end_day = 2
	end_month = JANUARY

/datum/holiday/new_year/getStationPrefix()
	return pick("Party","New","Hangover","Resolution")

/datum/holiday/groundhog
	name = "Groundhog Day"
	begin_day = 2
	begin_month = FEBRUARY

/datum/holiday/valentines
	name = VALENTINES
	begin_day = 13
	end_day = 15
	begin_month = FEBRUARY

/datum/holiday/valentines/getStationPrefix()
	return pick("Love","Amore","Single","Smootch","Hug")

/datum/holiday/birthday
	name = "Birthday of Space Station 13"
	begin_day = 16
	begin_month = FEBRUARY

/datum/holiday/birthday/greet()
	var/game_age = text2num(time2text(world.timeofday, "YY")) - 3
	var/Fact
	switch(game_age)
		if(16)
			Fact = " SS13 is now old enough to drive!"
		if(18)
			Fact = " SS13 is now legal!"
		if(21)
			Fact = " SS13 can now drink!"
		if(26)
			Fact = " SS13 can now rent a car!"
		if(30)
			Fact = " SS13 can now go home and be a family man!"
		if(40)
			Fact = " SS13 can now suffer a midlife crisis!"
		if(50)
			Fact = " Happy golden anniversary!"
		if(65)
			Fact = " SS13 can now start thinking about retirement!"
		if(96)
			Fact = " Please send a time machine back to pick me up, I need to update the time formatting for this feature!" //See you later suckers
	if(!Fact)
		Fact = " SS13 is now [game_age] years old!"

	return "Say 'Happy Birthday' to Space Station 13, first publicly playable on February 16th, 2003![Fact]"

/datum/holiday/random_kindness
	name = "Random Acts of Kindness Day"
	begin_day = 17
	begin_month = FEBRUARY

/datum/holiday/random_kindness/greet()
	return "Go do some random acts of kindness for a stranger!" //haha yeah right

/datum/holiday/leap
	name = "Leap Day"
	begin_day = 29
	begin_month = FEBRUARY

/datum/holiday/pi
	name = "Pi Day"
	begin_day = 14
	begin_month = MARCH

/datum/holiday/no_this_is_patrick
	name = "St. Patrick's Day"
	begin_day = 17
	begin_month = MARCH

/datum/holiday/no_this_is_patrick/getStationPrefix()
	return pick("Blarney","Green","Leprechaun","Booze")

/datum/holiday/april_fools
	name = APRIL_FOOLS
	begin_day = 1
	end_day = 5
	begin_month = APRIL

/datum/holiday/april_fools/celebrate()
	SSjob.overflow_role = "Clown"
	SSticker.login_music = 'sound/ambience/clown.ogg'
	for(var/mob/dead/new_player/P in GLOB.mob_list)
		if(P.client)
			P.client.playtitlemusic()

/datum/holiday/fourtwenty
	name = "Four-Twenty"
	begin_day = 20
	begin_month = APRIL

/datum/holiday/fourtwenty/getStationPrefix()
	return pick("Snoop","Blunt","Toke","Dank")

/datum/holiday/earth
	name = "Earth Day"
	begin_day = 22
	begin_month = APRIL

/datum/holiday/labor
	name = "Labor Day"
	begin_day = 1
	begin_month = MAY
	drone_hat = /obj/item/clothing/head/hardhat

/datum/holiday/firefighter
	name = "Firefighter's Day"
	begin_day = 4
	begin_month = MAY
	drone_hat = /obj/item/clothing/head/hardhat/red

/datum/holiday/firefighter/getStationPrefix()
	return pick("Burning","Blazing","Plasma","Fire")

/datum/holiday/summersolstice
	name = "Summer Solstice"
	begin_day = 21
	begin_month = JUNE

/datum/holiday/doctor
	name = "Doctor's Day"
	begin_day = 1
	begin_month = JULY
	drone_hat = /obj/item/clothing/head/nursehat

/datum/holiday/UFO
	name = "UFO Day"
	begin_day = 2
	begin_month = JULY

/datum/holiday/UFO/getStationPrefix() //Is such a thing even possible?
	return pick("Ayy","Truth","Tsoukalos","Mulder") //Yes it is!

/datum/holiday/writer
	name = "Writer's Day"
	begin_day = 8
	begin_month = JULY

/datum/holiday/friendship
	name = "Friendship Day"
	begin_day = 30
	begin_month = JULY

/datum/holiday/friendship/greet()
	return "Have a magical [name]!"

/datum/holiday/beer
	name = "Beer Day"
	begin_day = 5
	begin_month = AUGUST

/datum/holiday/pirate
	name = "Talk-Like-a-Pirate Day"
	begin_day = 19
	begin_month = SEPTEMBER
	drone_hat = /obj/item/clothing/head/pirate

/datum/holiday/pirate/greet()
	return "Ye be talkin' like a pirate today or else ye'r walkin' tha plank, matey!"

/datum/holiday/pirate/getStationPrefix()
	return pick("Yarr","Scurvy","Yo-ho-ho")

/datum/holiday/programmers
	name = "Programmers' Day"

/datum/holiday/programmers/shouldCelebrate(dd, mm, yy, ww, ddd) //Programmer's day falls on the 2^8th day of the year
	if(mm == 9)
		if(yy/4 == round(yy/4)) //Note: Won't work right on September 12th, 2200 (at least it's a Friday!)
			if(dd == 12)
				return 1
		else
			if(dd == 13)
				return 1
	return 0

/datum/holiday/programmers/getStationPrefix()
	return pick("span>","DEBUG: ","null","/list","EVENT PREFIX NOT FOUND") //Portability

/datum/holiday/questions
	name = "Stupid-Questions Day"
	begin_day = 28
	begin_month = SEPTEMBER

/datum/holiday/questions/greet()
	return "Are you having a happy [name]?"

/datum/holiday/animal
	name = "Animal's Day"
	begin_day = 4
	begin_month = OCTOBER

/datum/holiday/animal/getStationPrefix()
	return pick("Parrot","Corgi","Cat","Pug","Goat","Fox")

/datum/holiday/smile
	name = "Smiling Day"
	begin_day = 7
	begin_month = OCTOBER

/datum/holiday/boss
	name = "Boss' Day"
	begin_day = 16
	begin_month = OCTOBER

/datum/holiday/halloween
	name = HALLOWEEN
	begin_day = 28
	begin_month = OCTOBER
	end_day = 2
	end_month = NOVEMBER

/datum/holiday/halloween/greet()
	return "Have a spooky Halloween!"

/datum/holiday/halloween/getStationPrefix()
	return pick("Bone-Rattling","Mr. Bones' Own","2SPOOKY","Spooky","Scary","Skeletons")

/datum/holiday/vegan
	name = "Vegan Day"
	begin_day = 1
	begin_month = NOVEMBER

/datum/holiday/kindness
	name = "Kindness Day"
	begin_day = 13
	begin_month = NOVEMBER

/datum/holiday/flowers
	name = "Flowers Day"
	begin_day = 19
	begin_month = NOVEMBER

/datum/holiday/hello
	name = "Saying-'Hello' Day"
	begin_day = 21
	begin_month = NOVEMBER

/datum/holiday/hello/greet()
	return "[pick(list("Aloha", "Bonjour", "Hello", "Hi", "Greetings", "Salutations", "Bienvenidos", "Hola", "Howdy"))]! " + ..()

/datum/holiday/human_rights
	name = "Human-Rights Day"
	begin_day = 10
	begin_month = DECEMBER

/datum/holiday/monkey
	name = "Monkey Day"
	begin_day = 14
	begin_month = DECEMBER

/datum/holiday/thanksgiving
	name = "Thanksgiving in the United States"
	begin_week = 4
	begin_month = NOVEMBER
	begin_weekday = THURSDAY
	drone_hat = /obj/item/clothing/head/that //This is the closest we can get to a pilgrim's hat

/datum/holiday/thanksgiving/canada
	name = "Thanksgiving in Canada"
	begin_week = 2
	begin_month = OCTOBER
	begin_weekday = MONDAY

/datum/holiday/columbus
	name = "Columbus Day"
	begin_week = 2
	begin_month = OCTOBER
	begin_weekday = MONDAY

/datum/holiday/mother
	name = "Mother's Day"
	begin_week = 2
	begin_month = MAY
	begin_weekday = SUNDAY

/datum/holiday/mother/greet()
	return "Happy Mother's Day in most of the Americas, Asia, and Oceania!"

/datum/holiday/father
	name = "Father's Day"
	begin_week = 3
	begin_month = JUNE
	begin_weekday = SUNDAY

/datum/holiday/ramadan
	name = "Start of Ramadan"

/*

For anyone who stumbles on this some time in the future: this was calibrated to 2017
Calculated based on the start and end of Ramadan in 2000 (First year of the Gregorian Calendar supported by BYOND)
This is going to be accurate for at least a decade, likely a lot longer
Since the date fluctuates, it may be inaccurate one year and then accurate for several after
Inaccuracies will never be by more than one day for at least a hundred years
Finds the number of days since the day in 2000 and gets the modulo of that and the average length of a Muslim year since the first one (622 AD, Gregorian)
Since Ramadan is an entire month that lasts 29.5 days on average, the start and end are holidays and are calculated from the two dates in 2000

*/

/datum/holiday/ramadan/shouldCelebrate(dd, mm, yy, ww, ddd)
	if (round(((world.realtime - 285984000) / 864000) % 354.373435326843) == 0)
		return TRUE
	return FALSE

/datum/holiday/ramadan/getStationPrefix()
	return pick("Harm","Halaal","Jihad","Muslim")

/datum/holiday/ramadan/end
	name = "End of Ramadan"

/datum/holiday/ramadan/end/shouldCelebrate(dd, mm, yy, ww, ddd)
	if (round(((world.realtime - 312768000) / 864000) % 354.373435326843) == 0)
		return TRUE
	return FALSE

/datum/holiday/doomsday
	name = "Mayan Doomsday Anniversary"
	begin_day = 21
	begin_month = DECEMBER
	drone_hat = /obj/item/clothing/mask/rat/tribal

/datum/holiday/xmas
	name = CHRISTMAS
	begin_day = 22
	begin_month = DECEMBER
	end_day = 27
	drone_hat = /obj/item/clothing/head/santa

/datum/holiday/xmas/greet()
	return "Have a merry Christmas!"

/datum/holiday/xmas/celebrate()
	SSticker.OnRoundstart(CALLBACK(src, .proc/roundstart_celebrate))

/datum/holiday/xmas/proc/roundstart_celebrate()
	for(var/obj/machinery/computer/security/telescreen/entertainment/Monitor in GLOB.machines)
		Monitor.icon_state = "entertainment_xmas"

	for(var/mob/living/simple_animal/pet/dog/corgi/Ian/Ian in GLOB.mob_living_list)
		Ian.place_on_head(new /obj/item/clothing/head/helmet/space/santahat(Ian))


/datum/holiday/festive_season
	name = FESTIVE_SEASON
	begin_day = 1
	begin_month = DECEMBER
	end_day = 31
	drone_hat = /obj/item/clothing/head/santa

/datum/holiday/festive_season/greet()
	return "Have a nice festive season!"

/datum/holiday/boxing
	name = "Boxing Day"
	begin_day = 26
	begin_month = DECEMBER

/datum/holiday/friday_thirteenth
	name = "Friday the 13th"

/datum/holiday/friday_thirteenth/shouldCelebrate(dd, mm, yy, ww, ddd)
	if(dd == 13 && ddd == FRIDAY)
		return TRUE
	return FALSE

/datum/holiday/friday_thirteenth/getStationPrefix()
	return pick("Mike","Friday","Evil","Myers","Murder","Deathly","Stabby")

/datum/holiday/easter
	name = EASTER
	drone_hat = /obj/item/clothing/head/rabbitears
	var/const/days_early = 1 //to make editing the holiday easier
	var/const/days_extra = 1

/datum/holiday/easter/shouldCelebrate(dd, mm, yy, ww, ddd)
	if(!begin_month)
		current_year = text2num(time2text(world.timeofday, "YYYY"))
		var/list/easterResults = EasterDate(current_year+year_offset)

		begin_day = easterResults["day"]
		begin_month = easterResults["month"]

		end_day = begin_day + days_extra
		end_month = begin_month
		if(end_day >= 32 && end_month == MARCH) //begins in march, ends in april
			end_day -= 31
			end_month++
		if(end_day >= 31 && end_month == APRIL) //begins in april, ends in june
			end_day -= 30
			end_month++

		begin_day -= days_early
		if(begin_day <= 0)
			if(begin_month == APRIL)
				begin_day += 31
				begin_month-- //begins in march, ends in april

	return ..()

/datum/holiday/easter/celebrate()
	GLOB.maintenance_loot += list(
		/obj/item/reagent_containers/food/snacks/egg/loaded = 15,
		/obj/item/storage/bag/easterbasket = 15)

/datum/holiday/easter/greet()
	return "Greetings! Have a Happy Easter and keep an eye out for Easter Bunnies!"

/datum/holiday/easter/getStationPrefix()
	return pick("Fluffy","Bunny","Easter","Egg")
