/mob/living/silicon/hive_mainframe/New()
	Namepick()

/mob/living/silicon/hive_mainframe/Life()
	if(timestopped) return 0 //under effects of time magick
	if (stat == 2)
		return
	else
		updatehealth()

		if (health <= 0)
			death()
			return

	if(force_mind)
		if(!mind)
			if(client)
				mind = new
				mind.key = key
				mind.current = src
		force_mind = 0

/mob/living/silicon/hive_mainframe/Stat()
	..()

	if(statpanel("Status"))
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

/mob/living/silicon/hive_mainframe/updatehealth()
	if (nodamage == 0)
		health = 100 - getFireLoss() - getBruteLoss()
	else
		health = 100
		stat = 0

/mob/living/silicon/hive_mainframe/death(gibbed)
	stat = 2
	canmove = 0
	if(blind)
		blind.layer = 0
	sight |= SEE_TURFS
	sight |= SEE_MOBS
	sight |= SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	lying = 1
	icon_state = "hive_main-crash"

	var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	mind.store_memory("Time of death: [tod]", 0)

	if (key)
		spawn(50)
			if(key && stat == 2)
				verbs += /client/proc/ghost
	return ..(gibbed)

/mob/living/silicon/hive_mainframe/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[copytext(text, 1, length(text))]\"";

	return "states, \"[text]\"";


/mob/living/silicon/hive_mainframe/proc/return_to(var/mob/user)
	if(user.mind)
		user.mind.transfer_to(src)
		spawn(20)
			user:shell = 1
			user:real_name = "Robot [pick(rand(1, 999))]"
			user:name = user:real_name


		return

/mob/living/silicon/hive_mainframe/verb/cmd_deploy_to()
	set category = "Mainframe Commands"
	set name = "Deploy to shell."
	deploy_to()

/mob/living/silicon/hive_mainframe/verb/deploy_to()


	if(usr.stat == 2 || (usr.status_flags & FAKEDEATH))
		to_chat(usr, "You can't deploy because you are dead!")
		return

	var/list/bodies = new/list()

	for(var/mob/living/silicon/hivebot/H in mob_list)
		if(H.z == z)
			if(H.shell)
				if(!H.stat)
					bodies += H

	var/target_shell = input(usr, "Which body to control?") as null|anything in bodies

	if (!target_shell)
		return

	else if(mind)
		spawn(30)
			target_shell:mainframe = src
			target_shell:dependent = 1
			target_shell:real_name = name
			target_shell:name = target_shell:real_name
		mind.transfer_to(target_shell)
		return


/client/proc/MainframeMove(n,direct,var/mob/living/silicon/hive_mainframe/user)
	return
/obj/hud/proc/hive_mainframe_hud()
	return





/mob/living/silicon/hive_mainframe/Login()
	..()
	update_clothing()
	for(var/S in client.screen)
		del(S)
	flash = new /obj/screen( null )
	flash.icon_state = "blank"
	flash.name = "flash"
	flash.screen_loc = "1,1 to 15,15"
	flash.layer = 17
	blind = new /obj/screen( null )
	blind.icon_state = "black"
	blind.name = " "
	blind.screen_loc = "1,1 to 15,15"
	blind.layer = 0
	client.screen += list( blind, flash )
	if(!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	if (stat == 2)
		verbs += /client/proc/ghost
	return



/mob/living/silicon/hive_mainframe/proc/Namepick()
	var/randomname = pick(ai_names)
	var/newname = input(src,"You are the a Mainframe Unit. Would you like to change your name to something else?", "Name change",randomname)

	if (length(newname) == 0)
		newname = randomname

	if (newname)
		if (length(newname) >= 26)
			newname = copytext(newname, 1, 26)
		newname = replacetext(newname, ">", "'")
		real_name = newname
		name = newname