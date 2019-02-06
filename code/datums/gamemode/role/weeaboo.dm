/datum/role/weeaboo
	name = WEEABOO
	id = WEEABOO
	required_pref = ROLE_WEEABOO
	special_role = WEEABOO
	logo_state = "weeaboo-logo"
	refund_value = BASE_SOLO_REFUND
	wikiroute = WEEABOO

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


//Weeb Items

/obj/item/stack/shuriken
	name = "pizza roll shuriken"
	desc = "Anybody wanna pizza roll?"
	icon_state = "rods"
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
	icon_state = "riot"
	var/recharge = TRUE //In an earlier iteration, it was a rechargeable shield item. Now you leave it behind on the ground.

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
	desc = "Combines the power of 'Nen' (sense) with grease-resistant properties so you can still eat your tendies."
	icon_state = "black"
	item_state = "black"
	siemens_coefficient = 0
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	heat_conductivity = INS_GLOVES_HEAT_CONDUCTIVITY
	pressure_resistance = 200 * ONE_ATMOSPHERE
	var/cooldown = 0

/obj/item/clothing/gloves/nentendiepower/examine(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mind.GetRole(WEEABOO))
			to_chat(H,"<span class='info'>It will be ready to blast an APC in [max(0,cooldown-world.time)/10] seconds.")

/obj/item/clothing/gloves/nentendiepower/Touch(atom/A, mob/living/user, prox)
	if(world.time > cooldown)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.mind.GetRole(WEEABOO))
				if(istype(A,/obj/machinery/power/apc))
					var/obj/machinery/power/apc/APC = A
					APC.cell.use(cell.charge)
					var/turf/simulated/floor/T = get_turf(APC)
					if(istype(T))
						T.break_tile()
					APC.terminal.Destroy()
					cooldown = world.time + 10 SECONDS
	else
		..()

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
	..(loc,0)
	icon_state = pick("animeposter1","animeposter2","animeposter3")

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
		new /obj/item/mounted/poster/anime(newloc)
	else
		new /obj/item/mounted/poster/anime(get_turf(src))
	qdel(src)