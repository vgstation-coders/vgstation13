/obj/item/weapon/ctf_flag
	name = "Flag"
	desc = "Its a flag"
	w_class = W_CLASS_HUGE
	icon = 'flags.dmi'
	icon_state = "flag_neutral"
	item_state = "paper"

/obj/item/weapon/ctf_flag/red
	name = "The Red Flag"
	desc = "Catch dat fukken flag"
	icon_state = "flag_red"

/obj/item/weapon/ctf_flag/green
	name = "The Green Flag"
	desc = "Catch dat fukken flag"
	icon_state = "flag_green"

/obj/item/weapon/ctf_flag/New()
	..()
	spawn(200)
		process()
	return

/obj/item/weapon/ctf_flag/process()
	if(istype(src, /obj/item/weapon/ctf_flag/green))
		var/obj/L = locate("landmark*Green-Flag")
		if(locate("landmark*Green-Flag", src))
			spawn(200)
				process()
			return
		else if(!check_if_equipped() && L)
			new /obj/item/weapon/ctf_flag/green(L.loc)
			del(src)
	if(istype(src, /obj/item/weapon/ctf_flag/red))
		var/obj/L = locate("landmark*Red-Flag")
		if(locate("landmark*Red-Flag", src))
			spawn(200)
				process()
			return
		else if(!check_if_equipped() && L)
			new /obj/item/weapon/ctf_flag/red(L.loc)
			del(src)
	return

/obj/item/weapon/ctf_flag/proc/check_if_equipped()
	var/equipped = 0
	for(var/mob/M in living_mob_list)
		if(M &&!M.stat)
			var/list/L = M.get_contents()
			if(src in L)
				equipped = 1
				break
	return equipped

/obj/machinery/red_injector
	name = "Red Team Flag Injector"
	desc = "Insert flag here"
	anchored = 1
	density = 1
	var/score = 0
	var/operating = 0
	icon = 'flags.dmi'
	icon_state = "red_injector"
/*
/obj/machinery/red_injector/ex_act(severity)
	return

/obj/machinery/red_injector/attackby(var/obj/item/weapon/ctf_flag/C, mob/user)
	if(operating)
		to_chat(user, "Cannot put a flag in right now")
		return
	operating = 1
	if(istype(C, /obj/item/weapon/ctf_flag/green))
		if(locate("landmark*Red-Flag", /obj/item/weapon/ctf_flag/red))
			score++
			to_chat(world, "<B>[user.real_name] has scored for the red team!</B>")
			if(ticker.mode.name == "ctf")
				ticker.red_score++
				var/obj/L = locate("landmark*Green-Flag")
				if (L)
					del(C)
					new /obj/item/weapon/ctf_flag/green(L.loc)
				else
					to_chat(world, "No green flag spawn point detected")
				if(score >= 15)
					to_chat(world, "<FONT size = 3><B>The Red Team has won!</B></FONT>")
					to_chat(world, "<B>They have scored [score] times with the flag!</B>")
					sleep(300)
					world.Reboot()
		else
			to_chat(user, "<span class='warning'>You need to have your flag in the beginning position!</span>")
	else if(istype(C, /obj/item/weapon/ctf_flag/red))
		to_chat(world, "<B>[user.real_name] has tried to score with their own flag! Idiot!</B>")
	operating = 0
	return
*/
/obj/machinery/green_injector
	name = "Green Team Flag Injector"
	desc = "Insert flag here"
	anchored = 1
	density = 1
	var/operating = 0
	var/score = 0
	icon = 'flags.dmi'
	icon_state = "green_injector"

/obj/machinery/green_injector/ex_act(severity)
	return
/*
/obj/machinery/green_injector/attackby(var/obj/item/weapon/ctf_flag/C, mob/user)
	if(operating)
		to_chat(user, "Cannot put a flag in right now")
		return
	operating = 1
	if(istype(C, /obj/item/weapon/ctf_flag/red))
		if(locate("landmark*Green-Flag", /obj/item/weapon/ctf_flag/green))
			score++
			to_chat(world, "<B>[user.real_name] has scored for the green team!</B>")
			if(ticker.mode.name == "ctf")
				ticker.green_score++
				var/obj/L = locate("landmark*Red-Flag")
				if (L)
					del(C)
					new /obj/item/weapon/ctf_flag/red(L.loc)
				else
					to_chat(world, "No red flag spawn point detected")
				if(score >= 15)
					to_chat(world, "<FONT size = 3><B>The Green Team has won!</B></FONT>")
					to_chat(world, "<B>They have scored [score] times with the flag!</B>")
					sleep(300)
					world.Reboot()
		else
			to_chat(user, "<span class='warning'>You need to have your flag in the beginning position!</span>")
	else if(istype(C, /obj/item/weapon/ctf_flag/green))
		to_chat(world, "<B>[user.real_name] has tried to score with their own flag! Idiot!</B>")
	operating = 0
	return
*/