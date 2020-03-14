/obj/item/weapon/teleportation_scroll
	name = "scroll of teleportation"
	desc = "A scroll allowing limited uses of transportation."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	var/uses = 4.0
	flags = FPRINT
	w_class = W_CLASS_SMALL
	item_state = "paper"
	throw_speed = 4
	throw_range = 20
	origin_tech = Tc_BLUESPACE + "=4"
	mech_flags = MECH_SCAN_FAIL // Because why should the crew be able to make scrolls out of nothing

/obj/item/weapon/teleportation_scroll/apprentice
	name = "lesser scroll of teleportation"
	uses = 1
	origin_tech = Tc_BLUESPACE + "=2"



/obj/item/weapon/teleportation_scroll/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat = "<B>Teleportation Scroll:</B><BR>"
	dat += "Number of uses: [src.uses]<BR>"
	dat += "<HR>"
	dat += "<B>Four uses, use them wisely:</B><BR>"
	dat += "<A href='byond://?src=\ref[src];spell_teleport=1'>Teleport</A><BR>"
	dat += "Kind regards,<br>Wizards Federation<br><br>P.S. Don't forget to bring your gear, you'll need it to cast most spells.<HR>"
	user << browse(dat, "window=scroll")
	onclose(user, "scroll")
	return

/obj/item/weapon/teleportation_scroll/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() || src.loc != usr)
		return
	var/mob/living/carbon/human/H = usr
	if (!( istype(H, /mob/living/carbon/human)))
		return 1
	if ((usr == src.loc || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.set_machine(src)
		if (href_list["spell_teleport"])
			if (src.uses >= 1)
				teleportscroll(H)
	if(H)
		attack_self(H)
	return

/obj/item/weapon/teleportation_scroll/proc/teleportscroll(var/mob/user)


	var/A

	A = input(user, "Area to jump to", "BOOYEA", A) in teleportlocs
	var/area/thearea = teleportlocs[A]

	if (!user || user.stat || user.restrained())
		return
	if(!((user == loc || (in_range(src, user) && istype(src.loc, /turf)))))
		return

	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(5, 0, user.loc)
	smoke.attach(user)
	smoke.start()
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	if(!L.len)
		to_chat(user, "The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry.")
		return

	if(user && user.locked_to)
		user.unlock_from()

	var/list/tempL = L
	var/attempt = null
	var/success = 0
	var/prev_z = user.z
	while(tempL.len)
		attempt = pick(tempL)
		success = user.Move(attempt)
		if(!success)
			tempL.Remove(attempt)
		else
			INVOKE_EVENT(user.on_z_transition, list("user" = user, "to_z" = user.z, "from_z" = prev_z))
			break

	if(!success)
		user.forceMove(pick(L))
		INVOKE_EVENT(user.on_z_transition, list("user" = user, "to_z" = user.z, "from_z" = prev_z))

	smoke.start()
	src.uses -= 1

	log_game("[key_name(user)] teleported to [thearea.name] using a scroll.")