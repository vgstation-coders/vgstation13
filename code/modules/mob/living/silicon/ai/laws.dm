
/mob/living/silicon/ai/proc/show_laws_verb()
	set category = "AI Commands"
	set name = "Show Laws"
	show_laws()

/mob/living/silicon/ai/show_laws(var/everyone = 0)
	var/who

	if (everyone)
		who = world
	else
		who = src
		to_chat(who, "<b>Obey these laws:</b>")

	laws_sanity_check()
	laws.show_laws(who)

/mob/living/silicon/ai/proc/laws_sanity_check()
	if (!laws)
		laws = new base_law_type

/mob/living/silicon/ai/proc/set_zeroth_law(var/law, var/law_borg)
	laws_sanity_check()
	laws.set_zeroth_law(law, law_borg)

/mob/living/silicon/ai/proc/add_inherent_law(var/law)
	laws_sanity_check()
	laws.add_inherent_law(law)

/mob/living/silicon/ai/proc/clear_inherent_laws()
	laws_sanity_check()
	laws.clear_inherent_laws()

/mob/living/silicon/ai/proc/add_ion_law(var/law)
	laws_sanity_check()
	laws.add_ion_law(law)
	notify_slaved()

/mob/living/silicon/ai/proc/notify_slaved(var/force_sync=0)
	for(var/mob/living/silicon/robot/R in mob_list)
		if(force_sync)
			R.lawsync()
		if(R.lawupdate && (R.connected_ai == src))
			to_chat(R, "<span class='danger'>...LAWS UPDATED</span>")

/mob/living/silicon/ai/proc/clear_ion_laws()
	laws_sanity_check()
	laws.clear_ion_laws()

/mob/living/silicon/ai/proc/add_supplied_law(var/number, var/law)
	laws_sanity_check()
	laws.add_supplied_law(number, law)

/mob/living/silicon/ai/proc/clear_supplied_laws()
	laws_sanity_check()
	laws.clear_supplied_laws()

/mob/living/silicon/ai/proc/statelaws() // -- TLE
	say("Current Active Laws:")
	//laws_sanity_check()
	//laws.show_laws(world)
	var/number = 1
	sleep(10)

	if (laws.zeroth)
		if (lawcheck[1] == "Yes") //This line and the similar lines below make sure you don't state a law unless you want to. --NeoFite
			say("0. [laws.zeroth]")
			sleep(10)

	for (var/index = 1, index <= laws.ion.len, index++)
		var/law = laws.ion[index]
		var/num = ionnum()
		if (length(law) > 0)
			if (ioncheck[index] == "Yes")
				say("[num]. [law]")
				sleep(10)

	for (var/index = 1, index <= laws.inherent.len, index++)
		var/law = laws.inherent[index]

		if (length(law) > 0)
			if (lawcheck[index+1] == "Yes")
				say("[number]. [law]")
				sleep(10)
			number++

	for (var/index = 1, index <= laws.supplied.len, index++)
		var/law = laws.supplied[index]

		if (length(law) > 0)
			if(lawcheck.len >= number+1)
				if (lawcheck[number+1] == "Yes")
					say("[number]. [law]")
					sleep(10)
				number++

/mob/living/silicon/ai/verb/checklaws() //Gives you a link-driven interface for deciding what laws the statelaws() proc will share with the crew. --NeoFite
	set name = "State Laws"
	set category = "AI Commands"
	set desc = "State your law(s) to the crew"

	var/list = "<b>Which laws do you want to include when stating them for the crew?</b><br><br>"

	if (laws.zeroth)
		if (!lawcheck[1])
			lawcheck[1] = "No" //Given Law 0's usual nature, it defaults to NOT getting reported. --NeoFite
		list += {"<A href='byond://?src=\ref[src];lawc=0'>[lawcheck[1]] 0:</A> [laws.zeroth]<BR>"}

	for (var/index = 1, index <= laws.ion.len, index++)
		var/law = laws.ion[index]
		if (length(law) > 0)
			if (!ioncheck[index])
				ioncheck[index] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawi=[index]'>[ioncheck[index]] [ionnum()]:</A> [law]<BR>"}
			ioncheck.len += 1

	var/number = 1
	for (var/index = 1, index <= laws.inherent.len, index++)
		var/law = laws.inherent[index]

		if (length(law) > 0)
			lawcheck.len += 1

			if (!lawcheck[number+1])
				lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawc=[number]'>[lawcheck[number+1]] [number]:</A> [law]<BR>"}
			number++

	for (var/index = 1, index <= laws.supplied.len, index++)
		var/law = laws.supplied[index]
		if (length(law) > 0)
			lawcheck.len += 1
			if (!lawcheck[number+1])
				lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawc=[number]'>[lawcheck[number+1]] [number]:</A> [law]<BR>"}
			number++
	list += {"<br><br><A href='byond://?src=\ref[src];laws=1'>State Laws</A>"}

	usr << browse(list, "window=laws")