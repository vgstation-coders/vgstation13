/datum/role/ninja
	name = NINJA
	id = NINJA
	required_pref = NINJA
	special_role = NINJA
	logo_state = "ninja-logo"
	refund_value = BASE_SOLO_REFUND
	wikiroute = NINJA
	disallow_job = TRUE
	restricted_jobs = list("Trader") //Spawns in space
	greets = list(GREET_DEFAULT,GREET_WEEB,GREET_CUSTOM)

/datum/role/ninja/OnPostSetup()
	. =..()
	if(ishuman(antag.current))
		antag.current << sound('sound/effects/gong.ogg')
		equip_ninja(antag.current)
		name_ninja(antag.current)

/datum/role/ninja/ForgeObjectives()
	AppendObjective(/datum/objective/target/steal)
	AppendObjective(/datum/objective/target/assassinate)
	AppendObjective(/datum/objective/target/skulls)
	AppendObjective(/datum/objective/escape)

/datum/role/ninja/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if(GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>[custom]</span>")
		if(GREET_WEEB)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Crazed Weeaboo.<br>The crew has insulted glorious Space Nippon. Equipped with your authentic Space Kimono, your Space Katana that was folded over a million times, and your honobru bushido code, you must implore them to reconsider!</span>")
			to_chat(antag.current, "<span class='danger'>Remember that guns are not honobru, and that your katana has an ancient power imbued within it. Take a closer look at it if you've forgotten how it works.</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Space Ninja.<br>The Spider Clan has been insulted for the last time. Send Nanotrasen a message. You are forbidden by your code to use guns, do not forget!</span>")

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
		if(H.mind.GetRole(NINJA))
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
	return TRUE

/obj/item/weapon/substitutionhologram/on_block(damage, attack_text = "the_attack")
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
	desc = "A special sort of gloved that can be used to drain some technologies of power."
	icon_state = "powerfist"
	item_state = "black"
	siemens_coefficient = 0
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	heat_conductivity = INS_GLOVES_HEAT_CONDUCTIVITY
	pressure_resistance = 200 * ONE_ATMOSPHERE
	var/cooldown = 0
	var/reservoir = 0
	var/shuriken_icon = "radial_print"

/obj/item/clothing/gloves/ninja/examine(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mind.GetRole(NINJA))
			to_chat(H,"<span class='info'>Alt-Click to use drained power. It currently holds [round(reservoir)] energy units.</span>")
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
				if(draincell(A.get_cell()))
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
	reservoir += C.charge
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

/obj/item/clothing/gloves/ninja/proc/charge_sword(mob/user)
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
		if(H.mind.GetRole(NINJA) && P)
			P.entry_turf = get_turf(user)
			user.forceMove(P)
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


//Special Katana. Main katana in weaponry.dm
/obj/item/weapon/katana/hesfast //it's a normal katana, except alt clicking lets you teleport behind someone for epic slice and dice time
	var/teleportcooldown = 600 //one minute cooldown
	var/active = FALSE
	var/activate_message = "Weakness."
	siemens_coefficient = 0

/obj/item/weapon/katana/hesfast/IsShield()
	return TRUE

/obj/item/weapon/katana/hesfast/examine(mob/user)
	..()
	if(!isninja(user))
		return
	to_chat(user, "<span class='notice'>This katana has an ancient power dwelling inside of it!</span>")
	var/message = "<span class='notice'>"
	if(teleportcooldown < world.time)
		message += "Oh yeah, the ancient power stirs. This is the katana that will pierce the heavens!"
	else
		var/cooldowncalculated = round((teleportcooldown - world.time)/10)
		message += "Your steel has unleashed its dark and unwholesome power, so it's tapped out right now. It'll be ready again in [cooldowncalculated] seconds."
	if(active)
		message += " Alt-click it to stop teleporting, just in case you enter a no-warp trap room like the ones in Aincrad.</span>"
	else
		message += " Alt-click it to enable your teleportation, just like Goku's Shunkan Idou (Instant Transmission for Gaijin).</span>"
	to_chat(user, "[message]")

/obj/item/weapon/katana/hesfast/AltClick(mob/user)
	if(!isninja(user))
		return
	if(!active)
		active = TRUE
		to_chat(user, "<span class='notice'>You will teleport on attacks if you can.</span>")
	else//i could return on the above but this is much more readable or something
		to_chat(user, "<span class='notice'>You will not teleport for now. \"Not today, katana-san.\"</span>")
		active = FALSE

/obj/item/weapon/katana/hesfast/preattack(var/atom/A, mob/user)
	if(!active || !isninja(user) || !ismob(A) || (A == user)) //sanity
		return
	if(teleportcooldown > world.time)//you're trying to teleport when it's on cooldown.
		return
	var/mob/living/L = A
	var/turf/SHHHHIIIING = get_step(L.loc, turn(L.dir, 180))
	if(!SHHHHIIIING) //sanity for avoiding banishing our weebs into the shadow realm
		return
	teleportcooldown = initial(teleportcooldown) + world.time
	playsound(src, "sound/weapons/shing.ogg",50,1)
	user.forceMove(SHHHHIIIING)
	user.dir = L.dir
	user.say("[activate_message]")
	..()

/obj/item/weapon/katana/hesfast/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is slicing \his chest open with the [src.name]! It looks like \he's trying to commit sudoku.</span>")
	return(SUICIDE_ACT_BRUTELOSS)

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

/obj/item/weapon/katana/hesfast/weeb
	activate_message = "Pshh... nothing personnel... kid..."

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