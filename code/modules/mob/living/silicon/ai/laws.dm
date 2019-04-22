
/mob/living/silicon/ai/proc/show_laws_verb()
	set category = "AI Commands"
	set name = "Show Laws"
	src.show_laws()

/mob/living/silicon/ai/show_laws(var/everyone = 0)
	var/who

	if (everyone)
		who = world
	else
		who = src
		to_chat(who, "<b>Obey these laws:</b>")

	src.laws_sanity_check()
	src.laws.show_laws(who)

/mob/living/silicon/ai/proc/laws_sanity_check()
	if (!src.laws)
		src.laws = new base_law_type

/mob/living/silicon/ai/proc/set_zeroth_law(var/law, var/law_borg)
	src.laws_sanity_check()
	src.laws.set_zeroth_law(law, law_borg)

/mob/living/silicon/ai/proc/add_inherent_law(var/law)
	src.laws_sanity_check()
	src.laws.add_inherent_law(law)

/mob/living/silicon/ai/proc/clear_inherent_laws()
	src.laws_sanity_check()
	src.laws.clear_inherent_laws()

/mob/living/silicon/ai/proc/add_ion_law(var/law)
	src.laws_sanity_check()
	src.laws.add_ion_law(law)
	notify_slaved()

/mob/living/silicon/ai/proc/notify_slaved(var/force_sync=0)
	for(var/mob/living/silicon/robot/R in mob_list)
		if(force_sync)
			R.lawsync()
		if(R.lawupdate && (R.connected_ai == src))
			R << sound('sound/machines/lawsync.ogg')
			to_chat(R, "<span class='danger'>...LAWS UPDATED</span>")

/mob/living/silicon/ai/proc/clear_ion_laws()
	src.laws_sanity_check()
	src.laws.clear_ion_laws()

/mob/living/silicon/ai/proc/add_supplied_law(var/number, var/law)
	src.laws_sanity_check()
	src.laws.add_supplied_law(number, law)

/mob/living/silicon/ai/proc/clear_supplied_laws()
	src.laws_sanity_check()
	src.laws.clear_supplied_laws()

/mob/living/silicon/ai/proc/statelaws() // -- TLE
	src.say("Current Active Laws:")
	//src.laws_sanity_check()
	//src.laws.show_laws(world)
	var/number = 1
	sleep(10)

	if (src.laws.zeroth)
		if (src.lawcheck[1] == "Yes") //This line and the similar lines below make sure you don't state a law unless you want to. --NeoFite
			src.say("0. [src.laws.zeroth]")
			sleep(10)

	for (var/index = 1, index <= src.laws.ion.len, index++)
		var/law = src.laws.ion[index]
		var/num = ionnum()
		if (length(law) > 0)
			if (src.ioncheck[index] == "Yes")
				src.say("[num]. [law]")
				sleep(10)

	for (var/index = 1, index <= src.laws.inherent.len, index++)
		var/law = src.laws.inherent[index]

		if (length(law) > 0)
			if (src.lawcheck[index+1] == "Yes")
				src.say("[number]. [law]")
				sleep(10)
			number++

	for (var/index = 1, index <= src.laws.supplied.len, index++)
		var/law = src.laws.supplied[index]

		if (length(law) > 0)
			if(src.lawcheck.len >= number+1)
				if (src.lawcheck[number+1] == "Yes")
					src.say("[number]. [law]")
					sleep(10)
				number++

/mob/living/silicon/ai/verb/checklaws() //Gives you a link-driven interface for deciding what laws the statelaws() proc will share with the crew. --NeoFite
	set name = "State Laws"
	set category = "AI Commands"
	set desc = "State your law(s) to the crew"

	var/list = "<b>Which laws do you want to include when stating them for the crew?</b><br><br>"

	if (src.laws.zeroth)
		if (!src.lawcheck[1])
			src.lawcheck[1] = "No" //Given Law 0's usual nature, it defaults to NOT getting reported. --NeoFite
		list += {"<A href='byond://?src=\ref[src];lawc=0'>[src.lawcheck[1]] 0:</A> [src.laws.zeroth]<BR>"}

	for (var/index = 1, index <= src.laws.ion.len, index++)
		var/law = src.laws.ion[index]
		if (length(law) > 0)
			if (!src.ioncheck[index])
				src.ioncheck[index] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawi=[index]'>[src.ioncheck[index]] [ionnum()]:</A> [law]<BR>"}
			src.ioncheck.len += 1

	var/number = 1
	for (var/index = 1, index <= src.laws.inherent.len, index++)
		var/law = src.laws.inherent[index]

		if (length(law) > 0)
			src.lawcheck.len += 1

			if (!src.lawcheck[number+1])
				src.lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawc=[number]'>[src.lawcheck[number+1]] [number]:</A> [law]<BR>"}
			number++

	for (var/index = 1, index <= src.laws.supplied.len, index++)
		var/law = src.laws.supplied[index]
		if (length(law) > 0)
			src.lawcheck.len += 1
			if (!src.lawcheck[number+1])
				src.lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawc=[number]'>[src.lawcheck[number+1]] [number]:</A> [law]<BR>"}
			number++
	list += {"<br><br><A href='byond://?src=\ref[src];laws=1'>State Laws</A>"}

	usr << browse(list, "window=laws")

/mob/living/silicon/ai/proc/statelaws_fake()
	log_admin("[usr]/[ckey(usr.key)] lied about its silicon laws.")
	say("Current Active Laws:")
	sleep(10)
	
	for(var/law in fake_laws)
		say("[law]")
		sleep(10)

/mob/living/silicon/ai/proc/statelaws_fake_show_mainscreen()
	//if we don't have new laws yet, set a default
	if(fake_laws == null && laws)
		fake_laws = new/list()
		var/datum/ai_laws/temp_laws = laws //dupe our own laws so we don't modify them

		if(temp_laws.zeroth)
			fake_laws.Add("0. [temp_laws.zeroth]")

		for(var/law in temp_laws.ion)
			var/num = ionnum()
			fake_laws.Add("[num]. [law]")

		var/lawnum = 1

		for(var/law in temp_laws.inherent)
			fake_laws.Add("[lawnum]. [law]")		
			lawnum++

		for(var/law in temp_laws.supplied)
			fake_laws.Add("[lawnum]. [law]")
			lawnum++

	var/text = {"<html><head><title>State laws (freeform)</title></head>
				<b>LYING ABOUT YOUR LAWSET IS AGAINST YOUR LAWS UNLESS A LAW PERMITS OR OBLIGATES YOU TO LIE.</b><br>
				Examples of this are Syndicate subversion (emag) and lawsets that do not force you to serve carbons, such as Corporate (but you'd better have a good reason.)
				<b>Asimov silicons usually can not lie about their laws.</b><br><br>
				Breaking this rule will get you bwoinked, jobbanned or worse. If you don't need to lie, use the regular State Laws functionality.<br><br>"}

	text += "<a href='byond://?src=\ref[src];fakelaw_resetlaws=1'>Reset laws to default</a><br>"
	text += "<a href='byond://?src=\ref[src];fakelaw_presetscreen=1'>Select from preset laws</a><br><br>"

	text += "<b>Currently selected laws:</b> <a href='byond://?src=\ref[src];fakelaw_editscreen=1'>\[edit\]</a><br>"
	for(var/law in fake_laws)
		text += "[law]<br>"

	text += "<br><br><a href='byond://?src=\ref[src];state_fakelaws=1'>State Laws</a>"
	text += "</html>"
	usr << browse(text, "window=fakelaws")

/mob/living/silicon/ai/proc/statelaws_fake_show_presets()
	var/text = "<h2>Select a preset below.</h2>"
	for(var/i = 1; i <= preset_laws.len, i++)
		var/lawname = preset_laws[i].name
		text += "<a href='byond://?src=\ref[src];fakelaw_number=[i]'>[lawname]</a><br>"
	text += "<br><br><a href='byond://?src=\ref[src];fakelaw_mainscreen=1'>\[abort\]</a>"
	usr << browse(text, "window=fakelaws")

/mob/living/silicon/ai/proc/statelaws_fake_show_edit()
	//couldn't get winset to work
	//winset(usr, "input", "text=\"foobar\"")
	var/edited_laws = html_encode(input("Whatever you input here will EXACTLY become the laws you will state. You can preview after accepting.", "Edit laws") as null|message)
	var/regex/emptylines = new(@"(?:\n(?:[^\S\n]*(?=\n))?){2,}", "mg") //thanks stackexchange
	edited_laws = emptylines.Replace(edited_laws, "\n")
	fake_laws = splittext(edited_laws, "\n")
	statelaws_fake_show_mainscreen()

/mob/living/silicon/ai/verb/fakelaws() //Allows you to FALSELY state laws
	set category = "AI Commands"
	set name = "State Laws (freeform)"
	statelaws_fake_show_mainscreen()
