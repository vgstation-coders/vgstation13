// Inherited

// Except for this, of course.
/mob/living/silicon/robot/mommi/laws_sanity_check()
	if (!laws)
		laws = new mommi_base_law_type

// And this.
/mob/living/silicon/robot/mommi/statelaws() // -- TLE
	var/prefix=";"
	if(keeper)
		prefix=":b" // Binary channel.
	say(prefix+"Current Active Laws:")
	//laws_sanity_check()
	//laws.show_laws(world)
	var/number = 1
	sleep(10)
	if (laws.zeroth)
		if (lawcheck[1] == "Yes") //This line and the similar lines below make sure you don't state a law unless you want to. --NeoFite
			say("[prefix]0. [laws.zeroth]")
			sleep(10)

	for (var/index = 1, index <= laws.ion.len, index++)
		var/law = laws.ion[index]
		var/num = ionnum()
		if (length(law) > 0)
			if (ioncheck[index] == "Yes")
				say("[prefix][num]. [law]")
				sleep(10)

	for (var/index = 1, index <= laws.inherent.len, index++)
		var/law = laws.inherent[index]

		if (length(law) > 0)
			if (lawcheck[index+1] == "Yes")
				say("[prefix][number]. [law]")
				sleep(10)
			number++


	for (var/index = 1, index <= laws.supplied.len, index++)
		var/law = laws.supplied[index]

		if (length(law) > 0)
			if(lawcheck.len >= number+1)
				if (lawcheck[number+1] == "Yes")
					say("[prefix][number]. [law]")
					sleep(10)
				number++

// Disable this.
/mob/living/silicon/robot/mommi/lawsync()
	laws_sanity_check()
	return