/datum/role/weeaboo
	name = WEEABOO
	id = WEEABOO
	required_pref = WEEABOO
	special_role = WEEABOO
	logo_state = "weeaboo-logo"
	refund_value = BASE_SOLO_REFUND
	wikiroute = WEEABOO
	disallow_job = TRUE
	restricted_jobs = list("Trader") //Spawns in space

/datum/role/weeaboo/OnPostSetup()
	. =..()
	if(ishuman(antag.current))
		antag.current << sound('sound/effects/gong.ogg')
		equip_weeaboo(antag.current)
		name_weeaboo(antag.current)

/datum/role/weeaboo/ForgeObjectives()
	AppendObjective(/datum/objective/target/steal)
	AppendObjective(/datum/objective/target/assassinate)
	AppendObjective(/datum/objective/target/skulls)
	AppendObjective(/datum/objective/escape)

/datum/role/weeaboo/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>[custom]</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Space Weeaboo.<br>The crew has insulted glorious Space Nippon. Equipped with your authentic Space Kimono, your Space Katana that was folded over a million times, and your honobru bushido code, you must implore them to reconsider!</span>")

	to_chat(antag.current, "<span class='danger'>Remember that guns are not honobru, and that your katana has an ancient power imbued within it. Take a closer look at it if you've forgotten how it works.</span>")
	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")

//Weeb Items

/obj/item/stack/shuriken
	name = "pizza roll shuriken"
	desc = "Anybody wanna pizza roll?"
	icon = 'icons/obj/food.dmi'
	icon_state = "donkpocket"
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
		if(H.mind.GetRole(WEEABOO))
			if(amount>1)
				use(1)
				var/obj/item/stack/shuriken/S = new(loc)
				S.throw_at(A,throw_range,throw_speed*2)
				H.put_in_hands(src)
			else
				..(A,throw_range,throw_speed*2)
		else
			to_chat(usr,"<span class='warning'>You fumble with \the [src]!</span>")
			//It drops to the ground in throwcode already
	else
		if(ismob(usr))
			to_chat(usr,"<span class='warning'>You fumble with \the [src]!</span>")
		//Sometimes things are thrown by objects like vending machines or pneumatic cannons

//Eat, or throw for massive damage
/obj/item/stack/shuriken/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = usr
		if(H.mind.GetRole(WEEABOO))
			playsound(H, 'sound/items/eatfood.ogg', rand(10,50), 1)
			H.reagents.add_reagent(NUTRIMENT,8)
			to_chat(user,"<span class='notice'>You quickly stuff \the [src] down your throat!")
			//Absolutely no sanity here. A weeb can eat all his pizza rolls if he likes, instantly.
	else
		return ..()

//Shield
/obj/item/weapon/dakimakura
	name = "dakimakura"
	desc = "Like the classic pocket monster doll or even the humble log, a true ninja can use this to perform a substitution no jutsu when held."
	w_class = W_CLASS_MEDIUM
	icon = 'icons/obj/weapons.dmi'
	icon_state = "dakimakura"
	//In an earlier iteration, it was a rechargeable shield item. Now you leave it behind on the ground.

/obj/item/weapon/dakimakura/IsShield()
	return TRUE

/obj/item/weapon/dakimakura/on_block(damage, attack_text = "the_attack")
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.mind.GetRole(WEEABOO))
			var/turf/target_ground
			var/list/bright_grounds = list()
			for(var/turf/T in orange(10,H))
				if(!istype(T, /turf/space) && !(locate(/obj/machinery/door/airlock) in T))
					if(T.get_lumcount() * 10 > 2)
						bright_grounds += T
						continue
					target_ground = T
					break
			if(!target_ground && bright_grounds.len)
				target_ground = pick(bright_grounds)
			if(target_ground)
				var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
				smoke.set_up(3, 0, get_turf(H))
				smoke.start()
				//recharge = 10 SECONDS
				H.say("Substitution no jutsu!")
				H.drop_item(src,get_turf(H),TRUE) //Force drop to turf
				H.forceMove(target_ground)
				return TRUE
			else
				to_chat(H,"<span class='warning'>There wasn't an empty space to teleport to!</span>")

	return FALSE

/obj/item/weapon/dakimakura/prepickup(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mind.GetRole(WEEABOO))
			return FALSE //allow pickup
		else
			to_chat(H,"<span class='warning'>You really, really don't want to pick that up.</span>")
			return TRUE

//The mighty power glove. Not to be confused with engineering power gloves, of course.
/obj/item/clothing/gloves/nentendiepower
	name = "Nen/tendie power glove"
	desc = "Combines the power of 'Nen' (sense) with grease-resistant properties so you can still eat your tendies. Use on an APC to unleash your hacker skills from community college."
	icon_state = "powerfist"
	item_state = "black"
	siemens_coefficient = 0
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	heat_conductivity = INS_GLOVES_HEAT_CONDUCTIVITY
	pressure_resistance = 200 * ONE_ATMOSPHERE
	var/cooldown = 0
	var/reservoir = 0

/obj/item/clothing/gloves/nentendiepower/examine(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mind.GetRole(WEEABOO))
			to_chat(H,"<span class='info'>Alt-Click to use drained power. It currently holds [round(reservoir)] energy units.</span>")
			if(cooldown-world.time>0)
				to_chat(H,"<span class='warning'>It will be ready to drain an APC in [round((cooldown-world.time)/10)] seconds.</span>")
			else
				to_chat(H,"<span class='good'>It is ready to drain an APC!</span>")

/obj/item/clothing/gloves/nentendiepower/Touch(atom/A, mob/living/user, prox)
	if(!prox)
		return ..()
	if(world.time > cooldown)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.mind.GetRole(WEEABOO))
				if(istype(A,/obj/machinery/power/apc))
					var/obj/machinery/power/apc/APC = A
					if(APC.cell.charge>10)
						reservoir += APC.cell.charge
					APC.cell.use(APC.cell.charge)
					var/turf/simulated/floor/T = get_turf(APC)
					if(istype(T))
						T.break_tile()
					//APC.terminal.Destroy()
					playsound(APC, pick(lightning_sound), 100, 1, "vary" = 0)
					APC.charging = 0
					APC.chargecount = 0
					cooldown = world.time + 10 SECONDS
	else
		..()

/obj/item/clothing/gloves/nentendiepower/proc/radial_check_handler(list/arguments)
	var/event/E = arguments["event"]
	return radial_check(E.holder)

/obj/item/clothing/gloves/nentendiepower/proc/radial_check(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/clothing/gloves/nentendiepower/AltClick(mob/user)
	if(!user.Adjacent(src) || user.incapacitated())
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mind.GetRole(WEEABOO))

			var/list/choices = list(
				list("Make Shuriken", "radial_cook", "Fabricate a new shuriken. Cost: 1000."),
				list("Charge Sword", "radial_zap", "Reset the cooldown on your blade's teleport. Cost: 40 per second."),
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

#define MAKE_SHURIKEN_COST 1000
#define CHARGE_COST_MULTIPLIER 4
/obj/item/clothing/gloves/nentendiepower/proc/make_shuriken(mob/user)
	if(reservoir>=MAKE_SHURIKEN_COST)
		var/obj/item/stack/shuriken/S = locate(/obj/item/stack/shuriken) in user.held_items
		if(S)
			to_chat(user,"<span class='notice'>Your generated shuriken is added to the stack.</span>")
			S.amount++

		else
			to_chat(user,"<span class='good'>Your glove generates a fresh shuriken in your hand!</span>")
			user.put_in_hands(new /obj/item/stack/shuriken(user))
		reservoir -= MAKE_SHURIKEN_COST
	else
		to_chat(user,"<span class='warning'>You need [MAKE_SHURIKEN_COST] to make that!</span>")

/obj/item/clothing/gloves/nentendiepower/proc/charge_sword(mob/user)
	var/obj/item/weapon/katana/hesfast/oursword = locate(/obj/item/weapon/katana/hesfast) in user.held_items
	if(oursword)
		var/difference = (oursword.teleportcooldown-world.time)*CHARGE_COST_MULTIPLIER
		if(difference<=0)
			to_chat(user,"<span class='warning'>Your blade is already fully charged!</span>")
			return
		var/to_subtract = min(difference,reservoir) //Take the least between: how much we need, how much we have
		oursword.teleportcooldown -= to_subtract
		reservoir -= to_subtract
		if(oursword.teleportcooldown < world.time)
			to_chat(user,"<span class='good'>The glove's power flows into your weapon. Your blade is ready to be unleashed!</span>")
		else
			to_chat(user,"<span class='notice'>The glove's power flows into your weapon. It will be ready in [round((oursword.teleportcooldown - world.time)/10)] seconds.</span>")


/obj/item/mounted/poster/anime
	name = "rolled-up anime poster"
	build_time = 5
	path = /obj/structure/sign/poster/anime
	serial = FALSE
	serial_number = 0

/obj/item/mounted/poster/anime/do_build(turf/on_wall, mob/user)
	var/turf/T = get_turf(user)
	if(T.density)
		to_chat(user,"<span class='warning'>Not while we're inside something dense!</span>")
		return //Don't place a poster while we're on dense ground.
	var/obj/structure/sign/poster/anime/P = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mind.GetRole(WEEABOO) && P)
			P.entry_turf = get_turf(user)
			user.forceMove(P)
	return P

/obj/item/mounted/poster/anime/poster_animation(obj/D,mob/user)
	return //Silent and no animation

/obj/structure/sign/poster/anime
	name = "anime poster"
	desc = "It's everybody's favorite anime."
	var/entry_turf

/obj/structure/sign/poster/anime/New()
	..(loc)
	icon_state = pick("animeposter1","animeposter2","animeposter3","animeposter4","animeposter5","animeposter6")
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

/obj/structure/sign/poster/anime/relaymove(mob/user as mob)
	if(user.stat)
		return
	playsound(src, 'sound/items/poster_ripped.ogg', 100, 1)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!entry_turf)
			H.forceMove(get_turf(src))
		else
			H.forceMove(entry_turf)
		H.put_in_hands(new /obj/item/mounted/poster/anime)
		qdel(src)

/obj/structure/sign/poster/anime/proc/dropall()
	var/turf/T
	if(entry_turf)
		T = entry_turf
	else
		T = get_turf(src)
	for(var/atom/movable/A in contents)
		A.forceMove(T)

/obj/structure/sign/poster/anime/Destroy()
	dropall()
	..()

/obj/structure/sign/poster/anime/rip(mob/user)
	roll_and_drop(get_turf(user))

/obj/structure/sign/poster/anime/roll_and_drop(turf/newloc)
	if(newloc)
		new /obj/item/mounted/poster/anime(newloc, serial_number)
	else
		new /obj/item/mounted/poster/anime(get_turf(src), serial_number)
	qdel(src)