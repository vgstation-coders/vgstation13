/obj/item/weapon/melee/energy
	var/active = 0
	sharpness = 1.5 //very very sharp
	var/sharpness_on = 1.5 //so badmins can VV this!
	sharpness_flags = SHARP_BLADE | HOT_EDGE
	heat_production = 3500
	source_temperature = TEMPERATURE_PLASMA
	sterility = 0

/obj/item/weapon/melee/energy/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='danger'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>", \
						"<span class='danger'>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</span>"))
	return (SUICIDE_ACT_BRUTELOSS|SUICIDE_ACT_FIRELOSS)

/obj/item/weapon/melee/energy/is_hot()
	if(active)
		return source_temperature
	return 0

/obj/item/weapon/melee/energy/is_sharp()
	if(active)
		return sharpness
	return 0

/obj/item/weapon/melee/energy/axe
	name = "energy axe"
	desc = "An energised battle axe."
	icon_state = "axe0"
	force = 40
	var/active_force = 150
	throwforce = 25
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_MEDIUM
	flags = FPRINT
	siemens_coefficient = 1
	origin_tech = Tc_COMBAT + "=3"
	attack_verb = list("attacks", "chops", "cleaves", "tears", "cuts")
	armor_penetration = 50


/obj/item/weapon/melee/energy/axe/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] swings the [src.name] towards /his head! It looks like \he's trying to commit suicide.</span>")
	return (SUICIDE_ACT_BRUTELOSS|SUICIDE_ACT_FIRELOSS)

/obj/item/weapon/melee/energy/axe/rusty
	name = "rusty energy axe"
	desc = "A rusted energised battle axe."
	force = 3
	active_force = 30
	throwforce = 5
	armor_penetration = 50

/obj/item/weapon/melee/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"
	var/base_state = "sword"
	var/active_state = ""
	sharpness_flags = 0 //starts inactive
	force = 3
	var/activeforce = 30
	var/onsound = 'sound/weapons/saberon.ogg'
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = FPRINT
	origin_tech = Tc_MAGNETS + "=3;" + Tc_SYNDICATE + "=4"
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	var/dualsaber_type = /obj/item/weapon/melee/energy/sword/dualsaber

/obj/item/weapon/melee/energy/sword/activated/New()
	..()
	active = 1
	sterility = 100
	force = 30
	w_class = W_CLASS_LARGE
	sharpness = sharpness_on
	sharpness_flags = SHARP_TIP | SHARP_BLADE | INSULATED_EDGE | HOT_EDGE | CHOPWOOD | CUT_WALL | CUT_AIRLOCK
	armor_penetration = 100
	hitsound = "sound/weapons/blade1.ogg"
	update_icon()


/obj/item/weapon/melee/energy/sword/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/melee/energy/sword/New()
	..()
	_color = pick("red","blue","green","purple")
	if(!active_state)
		active_state = base_state + _color
	update_icon()

/obj/item/weapon/melee/energy/sword/attack_self(mob/living/user as mob)
	if(!(flags & TWOHANDABLE))
		if (clumsy_check(user) && prob(50) && active) //only an on blade can cut
			to_chat(user, "<span class='danger'>You accidentally cut yourself with [src]!</span>")
			user.take_organ_damage(5,5)
			return
		toggleActive(user)
		add_fingerprint(user)
		return
	..()


/obj/item/weapon/melee/energy/sword/proc/toggleActive(mob/user, var/togglestate = "") //you can use togglestate to manually set the sword on or off
	switch(togglestate)
		if("on")
			active = 1
		if("off")
			active = 0
		else
			active = !active
	if (active)
		force = activeforce
		sterility = 100
		w_class = W_CLASS_LARGE
		sharpness = sharpness_on
		sharpness_flags = SHARP_TIP | SHARP_BLADE | INSULATED_EDGE | HOT_EDGE | CHOPWOOD | CUT_WALL | CUT_AIRLOCK
		armor_penetration = 100
		hitsound = "sound/weapons/blade1.ogg"
		if(onsound)
			playsound(user, onsound, 50, 1)
		to_chat(user, "<span class='notice'> [src] is now active.</span>")
	else
		force = 3
		sterility = 0
		w_class = W_CLASS_SMALL
		sharpness = 0
		sharpness_flags = 0
		armor_penetration = initial(armor_penetration)
		if(onsound)
			playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		hitsound = "sound/weapons/empty.ogg"
		to_chat(user, "<span class='notice'> [src] can now be concealed.</span>")
	update_icon()

/obj/item/weapon/melee/energy/sword/update_icon()
	if(active && _color)
		icon_state = active_state
	else
		icon_state = "[base_state][active]"

/obj/item/weapon/melee/energy/sword/attackby(obj/item/weapon/W, mob/living/user)
	if(combine(W, user))
		return
	..()

/obj/item/weapon/melee/energy/sword/proc/combine(obj/item/W, mob/living/user)
	if(can_combine_with(W))
		to_chat(user, "<span class='notice'>You attach the ends of the two energy swords, making a single double-bladed weapon! You're cool.</span>")
		var/obj/item/weapon/melee/energy/sword/dualsaber/saber = new dualsaber_type(user.loc)
		saber.colorset = W._color + src._color
		saber.swords.Add(W, src)
		user.drop_item(W)
		W.forceMove(saber)
		user.drop_item(src)
		forceMove(saber)
		user.put_in_hands(saber)
		return 1
	return 0

/obj/item/weapon/melee/energy/sword/proc/can_combine_with(obj/item/W)
	return istype(W, /obj/item/weapon/melee/energy/sword) && !is_type_in_list(W, list(/obj/item/weapon/melee/energy/sword/bsword, /obj/item/weapon/melee/energy/sword/pirate, /obj/item/weapon/melee/energy/sword/dualsaber))

/obj/item/weapon/melee/energy/sword/bsword
	name = "banana"
	desc = "It's yellow."
	base_state = "bsword0"
	active_state = "bsword1"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	dualsaber_type = /obj/item/weapon/melee/energy/sword/dualsaber/bananabunch

/obj/item/weapon/melee/energy/sword/bsword/update_icon()
	if(active)
		icon_state = active_state
		name = "energized bananium sword"
		desc = "Advanced technology from a long forgotten clown civilization."
	else
		icon_state = "[base_state]"
		name = "banana"
		desc = "It's yellow."

/obj/item/weapon/melee/energy/sword/bsword/clumsy_check(mob/living/user)
	return 0

/obj/item/weapon/melee/energy/sword/bsword/can_combine_with(obj/item/W)
	return istype(W, /obj/item/weapon/melee/energy/sword/bsword)

/obj/item/weapon/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"
	active_state = "cutlass1"
	base_state = "cutlass"

/obj/item/weapon/melee/energy/sword/pirate/New()
	..()
	_color = "red"
	update_icon()

/obj/item/weapon/melee/energy/sword/pirate/can_combine_with(obj/item/W)
	return 0

/*
 * Double-Bladed Energy Swords
 */

/obj/item/weapon/melee/energy/sword/dualsaber
	icon_state = "dualsaber0"
	name = "double-bladed energy sword"
	desc = "Handle with care."
	var/colorset = ""
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = FPRINT | TWOHANDABLE
	origin_tech = Tc_MAGNETS + "=3;" + Tc_SYNDICATE + "=4"
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	var/list/swords = list()

/obj/item/weapon/melee/energy/sword/dualsaber/can_combine_with(obj/item/W)
	return 0

/obj/item/weapon/melee/energy/sword/dualsaber/Destroy()
	for(var/obj/item/I in swords)
		qdel(I)
	swords.Cut()
	..()

/obj/item/weapon/melee/energy/sword/dualsaber/toggleActive(mob/user)
	update_wield(user)

/obj/item/weapon/melee/energy/sword/dualsaber/update_wield(mob/user)
	..()
	force = wielded ? 30 : 3
	w_class = wielded ? 5 : 2
	sharpness_flags = wielded ? SHARP_TIP | SHARP_BLADE | INSULATED_EDGE | HOT_EDGE | CHOPWOOD | CUT_WALL | CUT_AIRLOCK : 0
	sharpness = wielded ? 1.5 : 0
	armor_penetration = wielded ? 100 : 0
	hitsound = wielded ? "sound/weapons/blade1.ogg" : "sound/weapons/empty.ogg"
	if(user)
		user.update_inv_hands()
	playsound(src, wielded ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 50, 1)
	update_icon()

/obj/item/weapon/melee/energy/sword/dualsaber/update_icon()
	icon_state = "dualsaber[wielded ? colorset : 0]"
	item_state = "dualsaber[wielded ? colorset : 0]"

/obj/item/weapon/melee/energy/sword/dualsaber/attack(target as mob, mob/living/user as mob)
	..()
	if(clumsy_check(user) && (wielded) &&prob(40))
		to_chat(user, "<span class='warning'>You twirl around a bit before losing your balance and impaling yourself on the [src].</span>")
		user.take_organ_damage(20,25)
		return
	if((wielded) && prob(50))
		spawn for(var/i=1, i<=8, i++)
			user.dir = turn(user.dir, 45)
			sleep(1)

/obj/item/weapon/melee/energy/sword/dualsaber/attackby(obj/item/I, mob/user)
	if(I.is_screwdriver(user) && do_after(src, user, 1 SECONDS))
		to_chat(user, "<span class = 'notice'>You deconstruct \the [src] into its components.</span>")
		for(var/obj/item/II in swords)
			II.forceMove(get_turf(src))
			swords.Remove(II)
			user.put_in_hands(src)
		qdel(src)
		return
	..()

/obj/item/weapon/melee/energy/sword/dualsaber/IsShield()
	if(wielded)
		return 1
	else
		return 0

/obj/item/weapon/melee/energy/sword/dualsaber/New()
	..()
	if(!colorset)
		colorset = pick("redred","blueblue","greengreen","purplepurple")
	update_icon()

/*
 * Banana Bunch
 */
/obj/item/weapon/melee/energy/sword/dualsaber/bananabunch
	icon_state = "bananabunch0"
	name = "banana bunch"
	desc = "Potential for some serious chaos."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')

/obj/item/weapon/melee/energy/sword/dualsaber/bananabunch/update_icon()
	icon_state = "bananabunch[wielded ? 1 : 0]"
	item_state = "bananabunch[wielded ? 1 : 0]"

/obj/item/weapon/melee/energy/sword/dualsaber/bananabunch/attack(target as mob, mob/living/user as mob)
	if(user.mind && !(user.mind.assigned_role == "Clown"))
		to_chat(user, "<span class='warning'>Your clumsy hands fumble and you slice yourself open with [src].</span>")
		user.take_organ_damage(40,50)
		return
	if((wielded) && (user.mind.assigned_role == "Clown"))
		..()
		spawn for(var/i=1, i<=8, i++)
			user.dir = turn(user.dir, 45)
			sleep(1)

/obj/item/weapon/melee/energy/sword/dualsaber/bananabunch/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if (M.Slip(2, 2, 1))
			M.simple_message("<span class='notice'>You slipped on [src]!</span>",
				"<span class='userdanger'>Something is scratching at your feet! Oh god!</span>")

/obj/item/weapon/melee/energy/sword/dualsaber/bananabunch/clumsy_check(mob/living/user)
	return 0
/*
 * High frequency Machete
 */
/obj/item/weapon/melee/energy/hfmachete
	name = "high-frequency machete"
	desc = "A high-frequency broad blade used either as an implement or in combat like a short sword."
	icon_state = "hfmachete0"
	var/base_state = "hfmachete"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	sharpness_flags = SHARP_BLADE | SERRATED_BLADE | CHOPWOOD
	force = 13 // You can be crueler than that, Jack.
	throwforce = 20
	throw_speed = 8
	throw_range = 8
	w_class = W_CLASS_MEDIUM
	flags = FPRINT
	mech_flags = MECH_SCAN_ILLEGAL
	siemens_coefficient = 1
	origin_tech = Tc_COMBAT + "=3" + Tc_SYNDICATE + "=3"
	attack_verb = list("attacks", "dices", "cleaves", "tears", "cuts", "slashes",)
	armor_penetration = 50
	var/event_key

/obj/item/weapon/melee/energy/hfmachete/update_icon()
	icon_state = "[base_state][active]"

/obj/item/weapon/melee/energy/hfmachete/attack_self(mob/living/user)
	toggleActive(user)
	add_fingerprint(user)

/obj/item/weapon/melee/energy/hfmachete/proc/toggleActive(mob/user, var/togglestate = "")
	switch(togglestate)
		if("on")
			active = 1
		if("off")
			active = 0
		else
			active = !active
	if(active)
		force = 25
		sterility = 100
		throwforce = 6
		throw_speed = 3
		sharpness = 1.7
		sharpness_flags += HOT_EDGE | CUT_WALL | CUT_AIRLOCK
		armor_penetration = 100
		to_chat(user, "<span class='warning'> [src] starts vibrating.</span>")
		playsound(user, 'sound/weapons/hfmachete1.ogg', 40, 0)
		event_key = user.on_moved.Add(src, "mob_moved")
	else
		force = initial(force)
		sterility = initial(sterility)
		throwforce = initial(throwforce)
		throw_speed = initial(throw_speed)
		sharpness = initial(sharpness)
		sharpness_flags = initial(sharpness_flags)
		armor_penetration = initial(armor_penetration)
		to_chat(user, "<span class='notice'> [src] stops vibrating.</span>")
		playsound(user, 'sound/weapons/hfmachete0.ogg', 40, 0)
		user.on_moved.Remove(event_key)
		event_key = null
	update_icon()

/obj/item/weapon/melee/energy/hfmachete/throw_at(atom/target, range, speed, override = 1)
	if(!usr)
		return ..()
	spawn()
		playsound(src, get_sfx("machete_throw"),30, 0)
		animate(src, transform = turn(matrix(), -30), time = 1, loop = -1)
		animate(transform = turn(matrix(), -60), time = 1)
		animate(transform = turn(matrix(), -90), time = 1)
		animate(transform = turn(matrix(), -120), time = 1)
		animate(transform = turn(matrix(), -150), time = 1)
		animate(transform = null, time = 1)
		while(throwing)
			sleep(5)
		animate(src)
	..(target, range, speed, override, fly_speed = 3)

/obj/item/weapon/melee/energy/hfmachete/throw_impact(atom/hit_atom)
	if(isturf(hit_atom))
		for(var/mob/M in hit_atom)
			playsound(M, get_sfx("machete_throw_hit"),60, 0)
	..()

/obj/item/weapon/melee/energy/hfmachete/attack(target as mob, mob/living/user as mob)
	if(isliving(target))
		playsound(target, get_sfx("machete_hit"),50, 0)
	if(clumsy_check(user) && prob(50))
		to_chat(user, "<span class='warning'>Christ.</span>")
		playsound(target, get_sfx("machete_hit"),50, 0)
		user.take_organ_damage(active ? 25 : 13)
		return
	..()

/obj/item/weapon/melee/energy/hfmachete/proc/mob_moved(var/list/event_args, var/mob/holder)
	if(iscarbon(holder) && active)
		for(var/obj/effect/plantsegment/P in range(holder,0))
			qdel(P)

/obj/item/weapon/melee/energy/hfmachete/attackby(obj/item/weapon/W, mob/living/user)
	..()
	if(istype(W, /obj/item/weapon/melee/energy/hfmachete))
		to_chat(user, "<span class='notice'>You combine the two [W] together, making a single scissor-bladed weapon! You feel fucking invincible!</span>")
		qdel(W)
		W = null
		qdel(src)
		var/B = new /obj/item/weapon/bloodlust(user.loc)
		user.put_in_hands(B)

/obj/item/weapon/melee/energy/hfmachete/activated/New()
	..()
	active = 1
	sterility = 100
	force = 25
	throwforce = 6
	throw_speed = 3
	sharpness = 1.7
	w_class = W_CLASS_LARGE
	sharpness_flags = SHARP_BLADE | SERRATED_BLADE | CHOPWOOD | HOT_EDGE | CUT_WALL | CUT_AIRLOCK
	armor_penetration = 100
	hitsound = get_sfx("machete_hit")
	update_icon()