/datum/role/ninja
	name = NINJA
	id = NINJA
	required_pref = NINJA
	special_role = NINJA
	logo_state = "ninja-logo"
	wikiroute = NINJA
	disallow_job = TRUE
	restricted_jobs = list()
	greets = list(GREET_DEFAULT,GREET_WEEB,GREET_CUSTOM)

	stat_datum_type = /datum/stat/role/ninja

/datum/role/ninja/OnPostSetup()
	. =..()
	if(ishuman(antag.current))
		antag.current << sound('sound/effects/gong.ogg')
		equip_ninja(antag.current)
		name_ninja(antag.current)

/datum/role/ninja/ForgeObjectives()

	if(cyborg_list.len)
		AppendObjective(/datum/objective/target/killsilicons)
	else
		if(prob(70))
			AppendObjective(/datum/objective/target/delayed/assassinate)
		else
			AppendObjective(/datum/objective/target/skulls)

	if(ai_list.len)
		AppendObjective(/datum/objective/killorstealAI)
	else
		AppendObjective(/datum/objective/target/steal)

	var/living = 0
	for(var/mob/living/M in player_list)
		if(!M.client)
			continue
		if(!iscarbon(M) && !issilicon(M))
			continue
		var/turf/T = get_turf(M)
		if(T.z != STATION_Z)
			continue
		if(M.stat != DEAD)
			living++
	if(living<=16 && prob(25))
		AppendObjective(/datum/objective/silence)
	else
		AppendObjective(/datum/objective/survive)
	if(prob(15))
		AppendObjective(/datum/objective/stealsake)

/datum/role/ninja/extraPanelButtons()
	var/dat = ""
	if(istype(GetNinjaWeapon(antag.current),/obj/item/weapon/katana/hesfast))
		dat = " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];toggleweeb=ninja;'>(Make ninja)</a><br>"
	else
		dat = " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];toggleweeb=weeb;'>(Make weeaboo)</a><br>"
	return dat

/datum/role/ninja/RoleTopic(href, href_list, var/datum/mind/M, var/admin_auth)
	if(href_list["toggleweeb"])
		if(href_list["toggleweeb"]=="ninja")
			equip_ninja(antag.current)
		else
			equip_weeaboo(antag.current)

/datum/role/ninja/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if(GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>[custom]</span>")
		if(GREET_WEEB)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Crazed Weeaboo.<br>The crew has insulted glorious Space Nippon. Equipped with your authentic Space Kimono, your Space Katana that was folded over a million times, and your honobru bushido code, you must implore them to reconsider!</span>")
			to_chat(antag.current, "<span class='danger'>Remember that guns are not honoraburu, and that your katana has an ancient power imbued within it. Take a closer look at it if you've forgotten how it works.</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Space Ninja.<br>The Spider Clan has been insulted for the last time. Send Nanotrasen a message. You are forbidden by your code to use guns, do not forget!</span>")
			to_chat(antag.current, "<span class='danger'>You are currently on a direct course to the station.</span>")
			to_chat(antag.current, "<span class='userdanger'>Your suit will lose pressure in approximately two minutes.</span>")
			to_chat(antag.current, "<span class='danger'>Find a way inside before your suit's life support systems give out!</span>")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")

/**********************************
****                           ****
****             GEAR          ****
****                           ****
**********************************/


/obj/item/stack/shuriken
	name = "3D printed shuriken"
	desc = "A specially designed shuriken that can only be used to its full potential by one trained in Spider Clan techniques. Highly effective against unarmored targets."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "shuriken"
	singular_name = "shuriken"
	throw_range = 20
	force = 4
	throwforce = 30
	flags = NO_THROW_MSG //No fingerprints, no throw message
	w_class = W_CLASS_SMALL
	max_amount = 10

/obj/item/stack/shuriken/examine(mob/user)
	..()
	to_chat(user,"<span class='info'>They are specially designed for use one-handed. Attempting to throw the entire stack will throw only one.")

/obj/item/stack/shuriken/throw_at(var/atom/A, throw_range, throw_speed)
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		var/datum/role/ninja/N = H.mind.GetRole(NINJA)
		if(N)
			if(amount>1)
				use(1)
				var/obj/item/stack/shuriken/S = new(loc)
				S.throw_at(A,throw_range,throw_speed*2)
				H.put_in_hands(src)
				//statistics collection: ninja shuriken thrown
				if(istype(N.stat_datum, /datum/stat/role/ninja))
					var/datum/stat/role/ninja/ND = N.stat_datum
					ND.shuriken_thrown++
			else
				..(A,throw_range,throw_speed*2)
		else
			to_chat(usr,"<span class='warning'>You fumble with \the [src]!</span>")
			//It drops to the ground in throwcode already
	else
		if(ismob(usr))
			to_chat(usr,"<span class='warning'>You fumble with \the [src]!</span>")
		//Sometimes things are thrown by objects like vending machines or pneumatic cannons

/obj/item/stack/shuriken/Crossed(atom/movable/A)
	if(!ishuman(A))
		return
	var/mob/living/carbon/human/H = A
	if(!isninja(H))
		return
	var/obj/item/stack/shuriken/S = locate(/obj/item/stack/shuriken) in H.held_items
	if(S)
		to_chat(H,"<span class='notice'>You add the shuriken to the stack.</span>")
		S.amount += amount
		qdel(src)

	else
		to_chat(H,"<span class='notice'>You pick up the shuriken!</span>")
		H.put_in_hands(src)

//Shield
/obj/item/weapon/substitutionhologram
	name = "hologram projector"
	desc = "Projects a hologram and displaces the user, allowing them to escape if attacked."
	w_class = W_CLASS_MEDIUM
	icon = 'icons/mob/AI.dmi'
	icon_state = "hologram-ninja"
	var/reject_message = "Your hand passes right through it!"
	var/activate_message = "Too slow."

/obj/item/weapon/substitutionhologram/IsShield()
	return SHIELD_ADVANCED

/obj/item/weapon/substitutionhologram/on_block(damage, atom/blocked)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.mind.GetRole(NINJA))
			var/turf/target_ground
			var/list/bright_grounds = list()
			var/list/close_dark_grounds = list()
			var/list/close_bright_grounds = list()
			for(var/turf/T in orange(10,H))
				if(istype(T,/turf/space))
					continue
				if(T.density)
					continue
				if(locate(/obj/machinery/door/airlock) in T)
					continue
				if(get_dist(H,T)<5)
					if(T.get_lumcount() * 10 > 2)
						close_bright_grounds += T
					else
						close_dark_grounds += T
					continue
				if(T.get_lumcount() * 10 > 2)
					bright_grounds += T
					continue

				target_ground = T //Top priority: a far, dark place.
				break
			if(!target_ground && bright_grounds.len) //Next: a far, bright place
				target_ground = pick(bright_grounds)
			if(!target_ground && close_dark_grounds.len) //Next: a close dark, place
				target_ground = pick(close_dark_grounds)
			if(!target_ground && close_bright_grounds.len) //Final: whatever is left
				target_ground = pick(close_bright_grounds)
			if(target_ground)
				var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
				smoke.set_up(3, 0, get_turf(H))
				smoke.start()
				H.say("[activate_message]")
				H.drop_item(src,get_turf(H),TRUE) //Force drop to turf
				H.forceMove(target_ground)
				return TRUE
			else
				to_chat(H,"<span class='warning'>There wasn't an empty space to teleport to!</span>")

	return FALSE

/obj/item/weapon/substitutionhologram/prepickup(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mind.GetRole(NINJA))
			return FALSE //allow pickup
		else
			to_chat(H,"<span class='warning'>[reject_message]</span>")
			return TRUE

/obj/item/weapon/substitutionhologram/can_be_pulled(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mind.GetRole(NINJA))
			return TRUE
		else
			to_chat(H,"<span class='warning'>[reject_message]</span>")
			return FALSE

//The mighty power glove. Not to be confused with engineering power gloves, of course.
/obj/item/clothing/gloves/ninja
	name = "ninja power glove"
	desc = "A special sort of glove that can be used to drain some technologies of power."
	icon_state = "powerfist"
	item_state = "black"
	siemens_coefficient = 0
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	heat_conductivity = INS_GLOVES_HEAT_CONDUCTIVITY
	pressure_resistance = 200 * ONE_ATMOSPHERE
	var/cooldown = 0
	var/shuriken_icon = "radial_print"
	actions_types = list(/datum/action/item_action/make_shuriken, /datum/action/item_action/charge_sword)

/obj/item/clothing/gloves/ninja/examine(mob/user)
	..()
	if(ishuman(user) && user.is_wearing_item(src))
		var/mob/living/carbon/human/H = user
		if(H.mind.GetRole(NINJA))
			var/obj/item/weapon/cell/C = H.get_cell()
			if(C)
				to_chat(H, "<span class='notice'>You have [C.get_charge()] charge remaining.</span>")
			if(cooldown-world.time>0)
				to_chat(H,"<span class='warning'>It will be ready to drain a cell in [round((cooldown-world.time)/10)] seconds.</span>")
			else
				to_chat(H,"<span class='good'>It is ready to drain a cell!</span>")

/obj/item/clothing/gloves/ninja/Touch(atom/A, mob/living/user, prox)
	if(!prox)
		return ..()
	if(world.time > cooldown)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.mind.GetRole(NINJA) && A.get_cell())
				if(draincell(A.get_cell(), user))
					if(istype(A,/obj/machinery/power/apc))
						var/obj/machinery/power/apc/APC = A
						APC.charging = 0
						APC.chargecount = 0
					else if(istype(A,/obj/item/weapon/melee/baton))
						var/obj/item/weapon/melee/baton/B = A
						B.status = 0
					var/turf/simulated/floor/T = get_turf(A)
					if(istype(T))
						T.break_tile()
					A.update_icon()
					return TRUE //Will not perform the normal interaction if drained the cell
	else
		..()

/obj/item/clothing/gloves/ninja/proc/draincell(var/obj/item/weapon/cell/C,mob/user)
	if(C.charge<100)
		return FALSE
	playsound(get_turf(src), pick(lightning_sound), 100, 1, "vary" = 0)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/weapon/cell/CC = H.get_cell()
		if(CC)
			CC.give(C.charge)
	C.use(C.charge)
	cooldown = world.time + 10 SECONDS
	return TRUE

/obj/item/clothing/gloves/ninja/proc/radial_check_handler(list/arguments)
	var/event/E = arguments["event"]
	return radial_check(E.holder)

/obj/item/clothing/gloves/ninja/proc/radial_check(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

#define MAKE_SHURIKEN_COST 1000
#define CHARGE_COST_MULTIPLIER 4

/datum/action/item_action/make_shuriken
	name = "Make Shuriken"
	desc = "Fabricate a new shuriken."
	icon_icon = 'icons/obj/weapons.dmi'
	button_icon_state = "shuriken"

/datum/action/item_action/make_shuriken/Trigger()
	if (!owner.mind.GetRole(NINJA))
		to_chat(owner, "<span class='warning'>Only a true ninja can do that!</span>")
		return FALSE
	var/obj/item/clothing/gloves/ninja/I = target
	I.make_shuriken(owner)

/datum/action/item_action/charge_sword
	name = "Charge Sword"
	desc = "Reset the cooldown on your blade's teleport."
	icon_icon = 'icons/obj/weapons.dmi'
	button_icon_state = "katana"

/datum/action/item_action/charge_sword/Trigger()
	if (!owner.mind.GetRole(NINJA))
		to_chat(owner, "<span class='warning'>Only a true ninja can do that!</span>")
		return FALSE
	var/obj/item/clothing/gloves/ninja/I = target
	I.charge_sword(owner)

/obj/item/clothing/gloves/ninja/AltClick(mob/user)
	if(!user.Adjacent(src) || user.stat)
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mind.GetRole(NINJA))

			var/list/choices = list(
				list("Make Shuriken", shuriken_icon, "Fabricate a new shuriken. Cost: [MAKE_SHURIKEN_COST]."),
				list("Charge Sword", "radial_zap", "Reset the cooldown on your blade's teleport. Cost: [CHARGE_COST_MULTIPLIER]0 per second."),
			)
			var/event/menu_event = new(owner = user)
			menu_event.Add(src, "radial_check_handler")

			var/task = show_radial_menu(usr,loc,choices,custom_check = menu_event)
			if(!radial_check(user))
				return
			switch(task)
				if("Make Shuriken")
					make_shuriken(user)
				if("Charge Sword")
					charge_sword(user)

	..()

/obj/item/clothing/gloves/ninja/proc/make_shuriken(mob/user)
	var/obj/item/weapon/cell/C = user.get_cell()
	if(!C)
		to_chat(user, "<span class = 'notice'>You do not have a cell to draw power from.</span>")
	if(C.use(MAKE_SHURIKEN_COST))
		var/obj/item/stack/shuriken/S = locate(/obj/item/stack/shuriken) in user.held_items
		if(S)
			to_chat(user,"<span class='notice'>Your generated shuriken is added to the stack.</span>")
			S.amount++

		else
			to_chat(user,"<span class='good'>Your glove generates a fresh shuriken in your hand!</span>")
			user.put_in_hands(new /obj/item/stack/shuriken(user))
	else
		to_chat(user,"<span class='warning'>You need [MAKE_SHURIKEN_COST] charge to make a shuriken!</span>")

/obj/item/clothing/gloves/ninja/proc/charge_sword(mob/user)
	var/obj/item/weapon/oursword = GetNinjaWeapon(user)
	if(!oursword)
		to_chat(user,"<span class='warning'>You need to hold the sword to channel power into it!</span>")
		return
	var/datum/daemon/teleport/T = oursword.daemon
	if(!istype(T))
		to_chat(user,"<span class='warning'>No power dwells within that blade!</span>")
		return
	var/difference = (T.cooldown-world.time)*CHARGE_COST_MULTIPLIER
	if(difference<=0)
		to_chat(user,"<span class='warning'>Your blade is already fully charged!</span>")
		return
	var/obj/item/weapon/cell/C = user.get_cell()
	var/to_subtract = min(difference,C.get_charge()) //Take the least between: how much we need, how much we have
	T.cooldown -= to_subtract/CHARGE_COST_MULTIPLIER
	C.use(to_subtract)
	if(T.cooldown < world.time)
		to_chat(user,"<span class='good'>The glove's power flows into your weapon. Your blade is ready to be unleashed!</span>")
	else
		to_chat(user,"<span class='notice'>The glove's power flows into your weapon. It will be ready in [round((T.cooldown - world.time)/10)] seconds.</span>")

	//statistics collection: ninja times charged sword
	var/datum/role/ninja/N = user.mind.GetRole(NINJA)
	if(istype(N.stat_datum, /datum/stat/role/ninja))
		var/datum/stat/role/ninja/ND = N.stat_datum
		ND.times_charged_sword++


/obj/item/mounted/poster/stealth
	name = "rolled-up stealth poster"
	desc = "The nanofilaments can mimic the color of walls and space station infastructure, but the edges remain a giveaway."
	build_time = 5
	path = /obj/structure/sign/poster/stealth
	serial = FALSE
	serial_number = -2

/obj/item/mounted/poster/stealth/do_build(turf/on_wall, mob/user)
	var/turf/T = get_turf(user)
	if(T.density)
		to_chat(user,"<span class='warning'>Not while we're inside something dense!</span>")
		return //Don't place a poster while we're on dense ground.
	var/obj/structure/sign/poster/stealth/P = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/role/ninja/N = H.mind.GetRole(NINJA)
		if(N && P)
			P.entry_turf = get_turf(user)
			user.forceMove(P)
			//statistics collection: ninja stealth posters posted
			if(istype(N.stat_datum, /datum/stat/role/ninja))
				var/datum/stat/role/ninja/ND = N.stat_datum
				ND.stealth_posters_posted++
	return P

/obj/item/mounted/poster/stealth/poster_animation(obj/D,mob/user)
	return //Silent and no animation

/obj/structure/sign/poster/stealth
	name = "machinery poster"
	desc = "A poster depicting a wall-mounted structure."
	var/entry_turf
	var/list/poster_designs = list("poster-apc","poster-extinguisher","poster-firealarm","poster-oxycloset","poster-nosmoking")
	var/poster_path = /obj/item/mounted/poster/stealth

/obj/structure/sign/poster/stealth/New()
	icon_state = pick(poster_designs)
	..()

/obj/structure/sign/poster/stealth/relaymove(mob/user as mob)
	if(user.stat)
		return
	playsound(get_turf(src), 'sound/items/poster_ripped.ogg', 100, 1)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!entry_turf)
			H.forceMove(get_turf(src))
		else
			H.forceMove(entry_turf)
		H.put_in_hands(new poster_path)
		qdel(src)

/obj/structure/sign/poster/stealth/proc/dropall()
	var/turf/T
	if(entry_turf)
		T = entry_turf
	else
		T = get_turf(src)
	for(var/atom/movable/A in contents)
		A.forceMove(T)

/obj/structure/sign/poster/stealth/Destroy()
	dropall()
	..()

/obj/structure/sign/poster/stealth/rip(mob/user)
	roll_and_drop(get_turf(user))

/obj/structure/sign/poster/stealth/roll_and_drop(turf/newloc)
	if(newloc)
		new poster_path(newloc, serial_number)
	else
		new poster_path(get_turf(src), serial_number)
	qdel(src)

/*=======
Ninja Esword
&
Helpers For Both Variants
=======*/
/proc/GetNinjaWeapon(mob/M)
	if(!istype(M))
		return
	else
		var/obj/item/weapon/W = locate(/obj/item/weapon/melee/energy/sword/ninja) in M.held_items
		if(W)
			return W
		else
			return locate(/obj/item/weapon/katana/hesfast) in M.held_items

/datum/action/item_action/toggle_teleport
	name = "Toggle Teleport"

/datum/action/item_action/toggle_teleport/Trigger()
	var/obj/item/weapon/W = GetNinjaWeapon(owner)
	if(!istype(W))
		return
	if(!ismob(owner) || !isninja(owner))
		return
	if(W.daemon && istype(W.daemon,/datum/daemon/teleport))
		W.daemon.activate()
		to_chat(owner,"<span class='notice'>Teleportation is now [W.daemon.active ? "active" : "inactive"].</span>")
		if(!W.daemon.active && istype(W,/obj/item/weapon/katana/hesfast))
			owner.whisper("Not today, katana-san.")

/obj/item/weapon/melee/energy/sword/ninja
	name = "energy katana"
	desc = "It makes you a little nervous even when it's off."
	activeforce = 40
	siemens_coefficient = 0
	onsound = null
	actions_types = list(/datum/action/item_action/toggle_teleport)

/obj/item/weapon/melee/energy/sword/ninja/New()
	..()
	daemon = new /datum/daemon/teleport(src,"Weakness",null)

/obj/item/weapon/melee/energy/sword/ninja/toggleActive(mob/user, var/togglestate = "")
	if(togglestate) //override
		..()
		checkdroppable()
		return
	if(isninja(user))
		..()
		checkdroppable()
	else
		to_chat(user,"<span class='warning'>There's no buttons on it.</span>")
		return

/obj/item/weapon/melee/energy/sword/ninja/proc/checkdroppable()
	return cant_drop = active //they should be the same value every time

/obj/item/weapon/melee/energy/sword/ninja/attackby(obj/item/weapon/W, mob/living/user)
	if(istype(W,/obj/item/weapon/melee/energy/sword))
		return
	else
		return ..()

/obj/item/weapon/melee/energy/sword/ninja/examine(mob/user)
	..()
	if(!isninja(user))
		return
	if(!daemon)
		return
	var/cc = max(round((daemon.cooldown - world.time)/10),0)
	to_chat(user,"<span class='notice'>The hilt displays its status in the form of a cryptic readout.</span>")
	to_chat(user,"<span class='notice'>TP: </span>[daemon.active ? "<span class='good'>I":"<span class='warning'>O"]</span><span class='notice'>; CD: [cc ? "[cc]s ([cc*10*CHARGE_COST_MULTIPLIER]J)</span>" : "</span><span class='warning'><B>X</B></span>"]")

/obj/item/weapon/melee/energy/sword/ninja/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(target == user)
		examine(user)
		return 1
	else
		return ..()

/obj/item/weapon/melee/energy/sword/ninja/dropped(mob/user)
	if(active)
		toggleActive(user,togglestate = "off")
	..()

/obj/item/weapon/melee/energy/sword/ninja/equipped(mob/user)
	if(!isninja(user) && active)
		toggleActive(user,togglestate = "off")
		to_chat(user,"<span class='warning'>The [src] shuts off.</span>")
	..()

/*=======
Suit and assorted
=======*/

/obj/item/clothing/head/helmet/space/ninja
	name = "elite ninja hood"
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	icon_state = "s-ninja"
	item_state = "s-ninja"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 25)
	species_fit = list("Human")
	species_restricted = list("Human")
	eyeprot = 3
	body_parts_covered = FULL_HEAD|BEARD

/obj/item/clothing/head/helmet/space/ninja/apprentice
	name = "ninja hood"
	desc = "What may appear to be a simple black garment is in fact a sophisticated nano-weave helmet. Standard issue ninja apprentice gear."
	eyeprot = 0
	pressure_resistance = ONE_ATMOSPHERE
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/space/ninja/apprentice/New()
	..()
	spawn(120 SECONDS)
		pressure_resistance = 0
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			to_chat(H, "<span class='danger'>\The [src] lets out a hiss.  It's no longer pressurized!</span>")

/obj/item/clothing/suit/space/ninja
	name = "elite ninja suit"
	desc = "A unique, vacuum-proof suit of nano-enhanced armor designed specifically for elite Spider Clan assassins."
	icon_state = "s-ninja"
	item_state = "s-ninja_suit"
	slowdown = NO_SLOWDOWN
	body_parts_covered = ARMS|LEGS|FULL_TORSO
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	allowed = list(/obj/item/weapon/tank, /obj/item/weapon/cell,/obj/item/weapon/melee/energy/sword,/obj/item/stack/shuriken,/obj/item/weapon/storage/box/syndie_kit/smokebombs,/obj/item/toy/snappop/smokebomb,/obj/item/weapon/substitutionhologram,/obj/item/mounted/poster/stealth)
	species_fit = list("Human")
	species_restricted = list("Human") //only have human sprites :/
	can_take_pai = 1
	var/obj/item/weapon/cell/cell

/obj/item/clothing/suit/space/ninja/New()
	..()
	equip_cell()

/obj/item/clothing/suit/space/ninja/proc/equip_cell()
	cell = new /obj/item/weapon/cell/high/empty()

/obj/item/clothing/suit/space/ninja/get_cell()
	return cell
/obj/item/clothing/suit/space/ninja/apprentice
	name = "ninja suit"
	desc = "A rare suit of nano-enhanced armor designed for Spider Clan assassins."
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	pressure_resistance = ONE_ATMOSPHERE

/obj/item/clothing/suit/space/ninja/apprentice/New()
	..()
	spawn(150 SECONDS)
		pressure_resistance = 0
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			if(H.wear_suit == src)
				to_chat(H, "<span class='danger'>\The [src] lets out a hiss. It's no longer pressurized!</span>")

/obj/item/clothing/suit/space/ninja/equipped(mob/living/carbon/human/H, equipped_slot)
	/*if(!isninja(H))
		if(equipped_slot != slot_wear_suit)
			to_chat(H, "<span class='danger'>\The [src] beeps menacingly.</span>")
		else
			src.visible_message("<span class='danger'>\The [src] suddenly explodes as [H] tries to put it on!</span>")
			explosion(H.loc, 0, 0, 1)
			H.u_equip(src, 1)
			qdel(src)*/
	//else //Maybe when there's more functionality to warrant the suit exploding.
	if(equipped_slot == slot_wear_suit)
		icon_state = H.gender==FEMALE ? "s-ninjaf" : "s-ninja"
		H.update_inv_wear_suit()

/obj/item/clothing/shoes/ninja
	name = "ninja shoes"
	desc = "A pair of ninja shoes, excellent for running and even better for smashing skulls."
	icon_state = "s-ninja"
	item_state = "s-ninja"
	permeability_coefficient = 0.01
	mag_slow = NO_SLOWDOWN
	clothing_flags = NOSLIP | MAGPULSE

/obj/item/clothing/shoes/ninja/apprentice
	desc = "A pair of ninja apprentice shoes, excellent for running and even better for smashing skulls."
	clothing_flags = NOSLIP

/obj/item/clothing/shoes/ninja/apprentice/proc/activateMagnets()
	togglemagpulse(override = TRUE)
	spawn(130 SECONDS)
		togglemagpulse(override = TRUE)
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			to_chat(H, "<span class='danger'>The magnetic charge on \the [src] disappates!</span>")

/obj/item/clothing/mask/gas/voice/ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja"
	mode = 2 //Does this even do anything?
	canstage = 0
	actions_types = list()
	species_fit = list("Human")
	species_restricted = list("Human")

/*******************************************
****          WEEABOO VARIANTS          ****
********************************************/
/obj/item/stack/shuriken/pizza
	name = "pizza roll shuriken"
	singular_name = "pizza roll"
	desc = "Anybody wanna pizza roll?"
	icon = 'icons/obj/food.dmi'
	icon_state = "donkpocket"

/obj/item/stack/shuriken/pizza/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = usr
		if(H.mind.GetRole(NINJA))
			playsound(H, 'sound/items/eatfood.ogg', rand(10,50), 1)
			H.reagents.add_reagent(NUTRIMENT,8)
			to_chat(user,"<span class='notice'>You quickly stuff \the [src] down your throat!")
			//Absolutely no sanity here. A weeb can eat all his pizza rolls if he likes, instantly.
	else
		return ..()

/obj/item/clothing/gloves/ninja/nentendiepower
	name = "Nen/tendie power glove"
	desc = "Combines the power of 'Nen' (sense) with grease-resistant properties so you can still eat your tendies. Use on an APC to unleash your hacker skills from community college."
	shuriken_icon = "radial_cook"

/obj/item/weapon/substitutionhologram/dakimakura
	name = "dakimakura"
	desc = "Like the classic pocket monster doll or even the humble log, a true ninja can use this to perform a substitution no jutsu when held."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "dakimakura"
	activate_message = "Substitution no jutsu!"
	reject_message = "You really, really don't want to pick that up."

/obj/item/mounted/poster/stealth/anime
	name = "rolled-up anime poster"
	path = /obj/structure/sign/poster/stealth/anime

/obj/structure/sign/poster/stealth/anime
	name = "anime poster"
	desc = "It's everybody's favorite anime."
	poster_designs = list("animeposter1","animeposter2","animeposter3","animeposter4","animeposter5","animeposter6")
	poster_path = /obj/item/mounted/poster/stealth/anime

/obj/structure/sign/poster/stealth/anime/New()
	..()
	switch(icon_state)
		if("animeposter1")
			name = "Death Note poster"
		if("animeposter2")
			name = "Naruto poster"
		if("animeposter3")
			name = "NERV poster"
		if("animeposter4")
			name = "Akira poster"
		if("animeposter5")
			name = "EVA poster"
		if("animeposter6")
			name = "Mob Psycho poster"

//Special Katana. Main katana in weaponry.dm
/obj/item/weapon/katana/hesfast
	siemens_coefficient = 0
	cant_drop = TRUE
	actions_types = list(/datum/action/item_action/toggle_teleport)

/obj/item/weapon/katana/hesfast/New()
	..()
	daemon = new /datum/daemon/teleport(src,"sound/weapons/shing.ogg", "Pshh... nothing personnel... kid...")

/obj/item/weapon/katana/hesfast/examine(mob/user)
	..()
	if(!isninja(user))
		return
	if(!daemon)
		return
	to_chat(user, "<span class='notice'>This katana has an ancient power dwelling inside of it!</span>")
	var/message = "<span class='notice'>"
	if(daemon.cooldown < world.time)
		message += "Oh yeah, the ancient power stirs. This is the katana that will pierce the heavens!"
	else
		var/cooldowncalculated = round((daemon.cooldown - world.time)/10)
		message += "Your steel has unleashed its dark and unwholesome power, so it's tapped out right now. It'll be ready again in [cooldowncalculated] seconds."
	if(daemon.active)
		message += " Your teleport is active, just like Goku's Shunkan Idou (Instant Transmission for Gaijin).</span>"
	else
		message += " Your teleport is inactive, just like a no-warp trap room in Aincrad.</span>"
	to_chat(user, "[message]")

/obj/item/weapon/katana/hesfast/suicide_act(mob/user)
	visible_message("<span class='danger'>[user] is slicing \his chest open with the [src.name]! It looks like \he's trying to commit [pick("seppuku","sudoku","harikari","crossword puzzle")].</span>")
	return(SUICIDE_ACT_BRUTELOSS)

/obj/item/weapon/katana/hesfast/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(target == user)
		examine(user)
		return 1
	else
		return ..()
