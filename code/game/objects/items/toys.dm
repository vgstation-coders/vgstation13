/* Toys!
 * ContainsL
 *		Balloons
 *		Fake telebeacon
 *		Fake singularity
 *		Toy guns
 *		Toy crossbow
 *		Toy swords
 *		Foam armblade
 *		Bomb clock
 *		Crayons
 *		Snap pops
 *		Water flower
 *		Cards
 *		Action figures
 */


/obj/item/toy
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	force = 0


/*
 * Balloons
 */

/obj/item/toy/waterballoon
	name = "water balloon"
	desc = "A translucent balloon. There's nothing in it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "waterballoon-e"
	item_state = "balloon-empty"

/obj/item/toy/waterballoon/New()
	. = ..()
	create_reagents(10)

/obj/item/toy/waterballoon/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/toy/waterballoon/afterattack(atom/A as mob|obj, mob/user as mob)
	if(get_dist(src,A) <= 1)
		if(istype(A, /obj/structure/reagent_dispensers/watertank))
			A.reagents.trans_to(src, 10)
			to_chat(user, "<span class = 'notice'>You fill the balloon with the contents of \the [A].</span>")
		else if(istype(A,/obj/structure/sink))
			reagents.add_reagent(WATER, 10)
			to_chat(user, "<span class = 'notice'>You fill the balloon using \the [A].</span>")
		src.desc = "A translucent balloon with some form of liquid sloshing around in it."
		src.update_icon()
	return

/obj/item/toy/waterballoon/attackby(obj/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/reagent_containers/glass))
		if(O.reagents)
			if(O.reagents.total_volume < 1)
				to_chat(user, "The [O] is empty.")
			else if(O.reagents.total_volume >= 1)
				if(O.reagents.has_reagent(PACID, 1))
					to_chat(user, "The acid chews through the balloon!")
					O.reagents.reaction(user)
					qdel(src)
					return
				else
					src.desc = "A translucent balloon with some form of liquid sloshing around in it."
					to_chat(user, "<span class = 'info'>You fill the balloon with the contents of \the [O].</span>")
					O.reagents.trans_to(src, 10)
	src.update_icon()
	return

/obj/item/toy/waterballoon/throw_impact(atom/hit_atom)
	if(src.reagents.total_volume >= 1)
		src.visible_message("<span class = 'danger'>\The [src] bursts!</span>","You hear a pop and a splash.")
		src.reagents.reaction(get_turf(hit_atom))
		for(var/atom/A in get_turf(hit_atom))
			src.reagents.reaction(A)
		src.icon_state = "burst"
		spawn(5)
			if(src)
				qdel(src)
	return

/obj/item/toy/waterballoon/update_icon()
	if(src.reagents.total_volume >= 1)
		icon_state = "waterballoon"
		item_state = "balloon"
	else
		icon_state = "waterballoon-e"
		item_state = "balloon-empty"

/obj/item/toy/syndicateballoon
	name = "syndicate balloon"
	desc = "There is a tag on the back that reads \"FUK NT!11!\"."
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	force = 0
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	item_state = "syndballoon"
	w_class = W_CLASS_LARGE

/obj/item/toy/syndicateballoon/green
    name = "green balloon"
    desc = "it is just a balloon that is green"
    icon_state = "greenballoon"
    item_state = "greenballoon"
    inhand_states = list("left_hand" = 'icons/mob/in-hand/left/memeballoon.dmi', "right_hand" = 'icons/mob/in-hand/right/memeballoon.dmi')

/obj/item/toy/syndicateballoon/ntballoon
    name = "nanotrasen balloon"
    desc = "There is a tag on the back that reads \"LUV NT!<3!\"."
    icon_state = "ntballoon"
    item_state = "ntballoon"
    inhand_states = list("left_hand" = 'icons/mob/in-hand/left/memeballoon.dmi', "right_hand" = 'icons/mob/in-hand/right/memeballoon.dmi')

/obj/item/toy/syndicateballoon/byondballoon
    name = "\improper BYOND balloon"
    desc = "There is a tag on the back that reads \"LUMMOX <3!\"."
    icon_state = "byondballoon"
    item_state = "byondballoon"
    inhand_states = list("left_hand" = 'icons/mob/in-hand/left/memeballoon.dmi', "right_hand" = 'icons/mob/in-hand/right/memeballoon.dmi')

/*
 * Fake telebeacon
 */
/obj/item/toy/blink
	name = "electronic blink toy game"
	desc = "Blink.  Blink.  Blink. Ages 8 and up."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "Gravitational Singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"

/obj/item/toy/spinningtoy/arcane_act(mob/user)
	..()
	processing_objects.Add(src)
	return "I'S LO'SE!"

/obj/item/toy/spinningtoy/bless()
	..()
	if(src in processing_objects)
		processing_objects.Remove(src)

/obj/item/toy/spinningtoy/process()
	if(arcanetampered)
		for(var/atom/X in orange(4, src))
			X.singularity_pull(src, 1)

/obj/item/toy/spinningtoy/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class = 'danger'><b>[user] is putting \his head into \the [src.name]! It looks like \he's  trying to commit suicide!</b></span>")
	return (SUICIDE_ACT_BRUTELOSS|SUICIDE_ACT_TOXLOSS|SUICIDE_ACT_OXYLOSS)


/*
 * Toy gun: Why isnt this an /obj/item/weapon/gun?
 */
/obj/item/toy/gun
	name = "cap gun"
	desc = "It almost looks like the real thing! Ages 8 and up. Please recycle in an autolathe when you're out of caps!"
	icon = 'icons/obj/gun.dmi'
	icon_state = "revolver"
	item_state = "gun"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	w_class = W_CLASS_MEDIUM
	starting_materials = list(MAT_IRON = 10, MAT_GLASS = 10)
	w_type = RECYK_MISC
	melt_temperature = MELTPOINT_PLASTIC
	attack_verb = list("strikes", "pistol whips", "hits", "bashes")
	var/bullets = 7.0

/obj/item/toy/gun/examine(mob/user)
	..()
	to_chat(user, "There [bullets == 1 ? "is" : "are"] [bullets] cap\s left.")

/obj/item/toy/gun/attackby(obj/item/toy/ammo/gun/A as obj, mob/user as mob)
	if (istype(A, /obj/item/toy/ammo/gun))
		if (src.bullets >= 7)
			to_chat(user, "<span class = 'notice'>It's already fully loaded!</span>")
			return 1
		if (A.amount_left <= 0)
			to_chat(user, "<span class = 'warning'>There are no more caps left in \the [A]!</span>")
			return 1
		if (A.amount_left < (7 - src.bullets))
			src.bullets += A.amount_left
			to_chat(user, text("<span class = 'warning'>You reload [] cap\s!</span>", A.amount_left))
			A.amount_left = 0
		else
			to_chat(user, text("<span class = 'warning'>You reload [] cap\s!</span>", 7 - src.bullets))
			A.amount_left -= 7 - src.bullets
			src.bullets = 7
		A.update_icon()
		return 1
	return

/obj/item/toy/gun/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	if (flag)
		return
	if (!user.dexterity_check())
		to_chat(user, "<span class = 'warning'>You don't have the dexterity to do this!</span>")
		return
	src.add_fingerprint(user)
	if (src.bullets < 1)
		user.show_message("<span class = 'danger'>*click* *click*</span>", 2)
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
		return
	playsound(user, 'sound/weapons/Gunshot.ogg', 100, 1)
	src.bullets--
	for(var/mob/O in viewers(user, null))
		O.show_message("<span class = 'danger'><B>[user] fires \the [src] at \the [A]!</B></span>", 1, "<span class = 'danger'>You hear a gunshot</span>", 2)

/obj/item/toy/ammo/gun
	name = "box of cap gun caps"
	desc = "There are 7 caps left! Make sure to recyle the box in an autolathe when it gets empty."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "357-7"
	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_TINY
	starting_materials = list(MAT_IRON = 10, MAT_GLASS = 10)
	melt_temperature = MELTPOINT_PLASTIC
	w_type = RECYK_MISC
	var/amount_left = 7.0

/obj/item/toy/ammo/gun/update_icon()
	src.icon_state = text("357-[]", src.amount_left)
	src.desc = text("There [amount_left == 1 ? "is" : "are"] [] cap\s left! Make sure to recycle the box in an autolathe when it gets empty.", src.amount_left)
	return

/obj/item/toy/ammo/gun/examine(mob/user)
	..()
	if (src.amount_left == 0)
		return
	to_chat(user, "There [amount_left == 1 ? "is" : "are"] [amount_left] cap\s left.")

/*
 * Toy pulse rifle
 */


/obj/item/weapon/gun/energy/pulse_rifle/destroyer/lasertag //subtype because of attack_self override
	name = "pulse destroyer"
	desc = "A heavy-duty, pulse-based lasertag weapon."
	projectile_type = "/obj/item/projectile/beam/lasertag/blue"

/*
 * Fireworks launcher
 */


/obj/item/weapon/gun/energy/fireworkslauncher
	name = "fireworks launcher"
	desc = "Celebrate in style!"
	icon_state = "fireworkslauncher"
	item_state = "riotgun"
	fire_sound = "sound/weapons/railgun_lowpower.ogg"
	projectile_type = "/obj/item/projectile/meteor/firework"
	charge_cost = 0 //infinite ammo!

/obj/item/weapon/gun/energy/fireworkslauncher/update_icon()
	return

/*
 * Toy crossbow
 */

/obj/item/toy/crossbow
	name = "foam dart crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon = 'icons/obj/gun.dmi'
	icon_state = "crossbow"
	item_state = "crossbow"
	flags = FPRINT
	w_class = W_CLASS_SMALL
	attack_verb = list("attacks", "strikes", "hits")
	var/bullets = 5

/obj/item/toy/crossbow/examine(mob/user)
	..()
	if (bullets)
		to_chat(user, "<span class = 'info'>It is loaded with [bullets] foam dart\s!</span>")

/obj/item/toy/crossbow/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/toy/ammo/crossbow))
		if(bullets <= 4)
			if(user.drop_item(I))
				QDEL_NULL(I)
				bullets++
				to_chat(user, "<span class = 'info'>You load the foam dart into \the [src].</span>")
		else
			to_chat(usr, "<span class = 'warning'>It's already fully loaded.</span>")


/obj/item/toy/crossbow/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if(!isturf(target.loc) || target == user)
		return
	if(flag)
		return

	if (locate (/obj/structure/table, src.loc))
		return
	else if (bullets)
		var/turf/trg = get_turf(target)
		var/obj/effect/foam_dart_dummy/D = new/obj/effect/foam_dart_dummy(get_turf(src))
		bullets--
		D.icon_state = "foamdart"
		D.name = "foam dart"
		playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

		for(var/i=0, i<6, i++)
			if (D)
				if(D.loc == trg)
					break
				step_towards(D,trg)

				for(var/mob/living/M in D.loc)
					if(!istype(M,/mob/living))
						continue
					if(M == user)
						continue
					for(var/mob/O in viewers(world.view, D))
						O.show_message(text("<span class = 'danger'>[] was hit by the foam dart!</span>", M), 1)
					new /obj/item/toy/ammo/crossbow(M.loc)
					QDEL_NULL(D)
					return

				for(var/atom/A in D.loc)
					if(A == user)
						continue
					if(A.density)
						new /obj/item/toy/ammo/crossbow(A.loc)
						QDEL_NULL(D)

			sleep(1)

		spawn(10)
			if(D)
				new /obj/item/toy/ammo/crossbow(D.loc)
				QDEL_NULL(D)

		return
	else if (bullets == 0)
		user.Knockdown(5)
		for(var/mob/O in viewers(world.view, user))
			O.show_message(text("<span class = 'danger'>[] realizes they are out of ammo and starts scrounging for some!<span>", user), 1)


/obj/item/toy/crossbow/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)

// ******* Check

	if (src.bullets > 0 && M.lying)

		for(var/mob/O in viewers(M, null))
			if(O.client)
				O.show_message(text("<span class = 'danger'><B>[] casually lines up a shot with []'s head and pulls the trigger!</B></span>", user, M), 1, "<span class = 'danger'>You hear the sound of foam against skull.</span>", 2)
				O.show_message(text("<span class = 'danger'>[] was hit in the head by the foam dart!</span>", M), 1)

		playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)
		new /obj/item/toy/ammo/crossbow(M.loc)
		src.bullets--
	else if (M.lying && src.bullets == 0)
		for(var/mob/O in viewers(M, null))
			if (O.client)
				O.show_message(text("<span class = 'danger'><B>[] casually lines up a shot with []'s head, pulls the trigger, then realizes they are out of ammo and drops to the floor in search of some!</B></span>", user, M), 1, "<span class = 'danger'>You hear someone fall</span>", 2)
		user.Knockdown(5)
	return

/obj/item/toy/ammo/crossbow
	name = "foam dart"
	desc = "Its nerf or nothing! Ages 8 and up."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamdart"
	flags = FPRINT
	w_class = W_CLASS_TINY

/obj/effect/foam_dart_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/toy.dmi'
	icon_state = "null"
	anchored = 1
	density = 0


/*
 * Toy swords
 */
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	icon = 'icons/obj/weapons.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "sword0"
	item_state = "sword0"
	var/active = 0.0
	var/base_state = "sword"
	var/active_state = ""
	w_class = W_CLASS_SMALL
	flags = FPRINT
	attack_verb = list("attacks", "strikes", "hits")
	var/dualsaber_type = /obj/item/toy/sword/dualsaber

/obj/item/toy/sword/New()
	..()
	_color = pick("red","blue","green","purple")
	if(!active_state)
		active_state = base_state + _color
	update_icon()

/obj/item/toy/sword/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		to_chat(user, "<span class = 'info'>You extend the plastic blade with a quick flick of your wrist.</span>")
		playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
		src.w_class = W_CLASS_LARGE
	else
		to_chat(user, "<span class = 'info'>You push the plastic blade back down into the handle.</span>")
		playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		src.w_class = W_CLASS_SMALL
	src.add_fingerprint(user)
	update_icon()

/obj/item/toy/sword/update_icon()
	if(active && _color)
		icon_state = active_state
		item_state = active_state
	else
		icon_state = "[base_state][active]"
		item_state = "[base_state][active]"

/obj/item/toy/sword/attackby(obj/item/weapon/W, mob/living/user)
	if(istype(W, /obj/item/toy/sword))
		to_chat(user, "<span class='notice'>You attach the ends of the two toy swords, making a single double-bladed one! You're cool.</span>")
		var/obj/item/toy/sword/dualsaber/saber = new dualsaber_type(user.loc)
		saber.colorset = W._color + src._color
		saber.swords.Add(W, src)
		user.drop_item(W)
		W.forceMove(saber)
		user.drop_item(src)
		forceMove(saber)
		user.put_in_hands(saber)
		return 1
	return ..()

/obj/item/toy/sword/dualsaber
	name = "toy double-bladed sword"
	desc = "Two cheap, plastic replicas of energy swords, combined together! Ages 4 times 2 and up."
	icon_state = "dualsaber0"
	item_state = "dualsaber0"
	var/list/swords = list()
	var/colorset = ""

/obj/item/toy/sword/dualsaber/attack_self(mob/user as mob)
	..()
	if (src.active)
		src.w_class = W_CLASS_HUGE

/obj/item/toy/sword/dualsaber/update_icon()
	icon_state = "dualsaber[active ? colorset : 0]"
	item_state = "dualsaber[active ? colorset : 0]"

/obj/item/toy/sword/dualsaber/Destroy()
	for(var/obj/item/I in swords)
		qdel(I)
	swords.Cut()
	..()

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 5
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	attack_verb = list("attacks", "slashes", "stabs", "slices")

/obj/item/toy/scythe
	name = "plastic scythe"
	desc = "A blunt and curved plastic blade on a long plastic handle, this tool makes it hard for kids to hurt themselves while trick-or-treating."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "scythe0"
	w_class = W_CLASS_LARGE
	slot_flags = SLOT_BACK
	attack_verb = list("chops", "slices", "cuts", "reaps")

/obj/item/toy/pitchfork
	name = "plastic pitchfork"
	desc = "Great for harassing sinners in the fiery depths of Heck."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "devil_pitchfork"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	w_class = W_CLASS_LARGE
	slot_flags = SLOT_BACK
	attack_verb = list("stabs", "prongs", "pokes")

/obj/item/toy/chainsaw
	name = "plastic chainsaw"
	desc = "Won't cut down anything, except maybe some horny teens' make-out session in your cabin in the woods."
	icon = 'icons/obj/toy.dmi'
	icon_state = "chainsaw"
	w_class = W_CLASS_MEDIUM
	attack_verb = list("attacks", "slashes", "saws", "cuts")
	hitsound = 'sound/items/circularsaw.ogg' //Maybe find a better sfx?
	var/last_revv_time = 0
	var/revv_delay = 60

/obj/item/toy/chainsaw/attack_self(mob/user as mob)
	..()
	if(world.time - last_revv_time >= revv_delay)
		last_revv_time = world.time
		playsound(src, hitsound, 50, 1)
		to_chat(viewers(user), "<span class='danger'>[user] revvs up \the [src.name] </span>")
		add_fingerprint(user)

/*
 * Foam armblade
 */
/obj/item/toy/foamblade
	name = "foam armblade"
	desc = "it says \"Sternside Changs #1 fan\" on it. "
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamblade"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	item_state = "armblade"
	attack_verb = list("pricked", "absorbed", "gored", "stung")
	w_class = W_CLASS_MEDIUM

/obj/item/toy/foamblade/suicide_act(var/mob/living/user)
	user.visible_message("<span class='danger'>[user] is absorbing \himself! It looks like \he's trying to commit suicide.</span>")
	playsound(src, 'sound/effects/lingabsorbs.ogg', 50, 1)
	return (SUICIDE_ACT_BRUTELOSS|SUICIDE_ACT_FIRELOSS)

/*
 * Clock bomb
 */
/obj/item/toy/bomb
	name = "commemorative Toxins clock"
	desc = "A bright-colored plastic clock, commemorating 20 years of Nanotrasen's Plasma division. Comes with permanent snooze button, just twist the valve!"
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "valve"
	item_state = "ttv"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/tanks.dmi', "right_hand" = 'icons/mob/in-hand/right/tanks.dmi')
	var/image/rendered

/obj/item/toy/bomb/New()
	..()
	overlays += image(icon = icon, icon_state = "plasma")
	var/icon/J = new(icon, icon_state = "oxygen")
	J.Shift(WEST, 13)
	underlays += J
	overlays += image(icon = icon, icon_state = "device")
	rendered = getFlatIconDeluxe(sort_image_datas(get_content_image_datas(src)), override_dir = SOUTH)

/obj/item/toy/bomb/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>Station Time: [worldtime2text()]")

/obj/item/toy/bomb/attack_self(mob/user)
	var/turf/T = get_turf(src)
	T.visible_message("[bicon(rendered)]*beep* *beep*", "*beep* *beep*")

/*
 * Crayons
 */

/obj/item/toy/crayon
	name = "crayon"
	desc = "A colourful crayon. Looks tasty. Mmmm..."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonred"
	w_class = W_CLASS_TINY
	attack_verb = list("attacks", "colours", "colors")//teehee
	var/mainColour = DEFAULT_BLOOD //RGB
	var/shadeColour = "#220000" //RGB
	var/uses = 30 //0 for unlimited uses
	var/instant = 0
	var/colourName = "red" //for updateIcon purposes
	var/style_type = /datum/writing_style/crayon
	var/datum/writing_style/style

/obj/item/toy/crayon/New()
	..()

	style = new style_type

/obj/item/toy/crayon/proc/Format(var/mob/user,var/text,var/obj/item/weapon/paper/P)
	return style.Format(text,src,user,P)

/obj/item/toy/crayon/suicide_act(var/mob/living/user)
	user.visible_message("<span class = 'danger'><b>[user] is jamming \the [src.name] up \his nose and into \his brain. It looks like \he's trying to commit suicide.</b></span>")
	return (SUICIDE_ACT_BRUTELOSS|SUICIDE_ACT_OXYLOSS)

/*
 * Snap pops
 */
/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = W_CLASS_TINY

/obj/item/toy/snappop/throw_impact(atom/hit_atom)
	if(!..())
		pop()

/obj/item/toy/snappop/Crossed(var/mob/living/M)
	if(istype(M) && M.size > SIZE_SMALL) //i guess carp and shit shouldn't set them off
		if(M.m_intent == "run" && M.on_foot())
			to_chat(M, "<span class = 'warning'>You step on \the [src.name]!</span>")
			pop()

/obj/item/toy/snappop/proc/pop()
	spark(src, 2, FALSE)
	new /obj/effect/decal/cleanable/ash(src.loc)
	src.visible_message("<span class = 'danger'>\The [src.name] explodes!</span>","<span class = 'danger'>You hear a snap!</span>")
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	qdel(src)

/*
 * From the virus symptom
 */
/obj/item/toy/snappop/virus
	name = "unstable goo"
	desc = "Your palm is oozing this stuff!"
	icon = 'icons/obj/virology.dmi'
	icon_state = "unstable_goo"
	throwforce = 30.0
	throw_speed = 10
	throw_range = 30
	w_class = W_CLASS_TINY

/obj/item/toy/snappop/virus/pop()
	spark(src)
	new /obj/effect/decal/cleanable/ash(src.loc)
	src.visible_message("<span class = 'danger'>\The [src.name] explodes!</span>","</span class = 'danger'>You hear a bang!</span>")
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	qdel(src)

/*
 * Syndie stealthy smokebombs!
*/
/obj/item/toy/snappop/smokebomb
	flags = FPRINT | NO_THROW_MSG
	origin_tech = Tc_COMBAT + "=1;" + Tc_SYNDICATE + "=1"

/obj/item/toy/snappop/smokebomb/pop()
	spark(src, 2, FALSE)
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	for(var/turf/T in trange(1, get_turf(src))) //Cause smoke in all 9 turfs around us, like the wizard smoke spell
		if(T.density) //no wallsmoke pls
			continue
		var/datum/effect/system/smoke_spread/bad/smoke = new /datum/effect/system/smoke_spread/bad()
		smoke.set_up(5, 0, T)
		smoke.start()
	qdel(src)

/*
 * Water flower
 */
/obj/item/toy/waterflower
	name = "Water Flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/hydroponics/sunflower.dmi'
	icon_state = "produce"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/flowers.dmi', "right_hand" = 'icons/mob/in-hand/right/flowers.dmi')
	item_state = "sunflower"
	var/empty = 0
	flags = OPENCONTAINER

/obj/item/toy/waterflower/New()
	. = ..()
	create_reagents(10)
	reagents.add_reagent(WATER, 10)

/obj/item/toy/waterflower/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/toy/waterflower/afterattack(atom/A as mob|obj, mob/user as mob, proximity_flag)

	if (istype(A, /obj/item/weapon/storage/backpack ) || istype(A, /obj/structure/bed/chair/vehicle/clowncart))
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if (istype(A, /obj/structure/reagent_dispensers) && proximity_flag)
		A.reagents.trans_to(src, 10)
		to_chat(user, "<span class = 'notice'>You refill your flower!</span>")
		return

	else if (src.reagents.total_volume < 1)
		src.empty = 1
		to_chat(user, "<span class = 'notice'>Your flower has run dry!</span>")
		return

	else
		src.empty = 0


		var/obj/effect/decal/D = new/obj/effect/decal/(get_turf(src))
		D.name = "water"
		D.icon = 'icons/obj/chemical.dmi'
		D.icon_state = "chempuff"
		D.create_reagents(5)
		reagents.log_bad_reagents(user, src)
		user.investigation_log(I_CHEMS, "sprayed 1u from \a [src] ([type]) containing [reagents.get_reagent_ids(1)] towards [A] ([A.x], [A.y], [A.z]).")
		src.reagents.trans_to(D, 1)
		playsound(src, 'sound/effects/spray3.ogg', 50, 1, -6)

		spawn(0)
			for(var/i=0, i<1, i++)
				step_towards(D,A)
				D.reagents.reaction(get_turf(D))
				for(var/atom/T in get_turf(D))
					D.reagents.reaction(T)
					if(ismob(T) && T:client)
						to_chat(T:client, "<span class = 'danger'>[user] has sprayed you with \the [src]!</span>")
				sleep(4)
			QDEL_NULL(D)

		return

/obj/item/toy/waterflower/examine(mob/user)
	..()
	to_chat(user, "[src.reagents.total_volume] units of water left!")

/*
 * Mech prizes
 */
/obj/item/toy/prize
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"
	var/cooldown = 0
	w_class = W_CLASS_SMALL

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user as mob)
	if(cooldown < world.time - 8)
		to_chat(user, "<span class='notice'>You play with \the [src].</span>")
		playsound(user, 'sound/mecha/mechstep.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/prize/attack_hand(mob/user as mob)
	if(loc == user)
		if(cooldown < world.time - 8)
			to_chat(user, "<span class='notice'>You play with \the [src].</span>")
			playsound(user, 'sound/mecha/mechturn.ogg', 20, 1)
			cooldown = world.time
			return
	..()

/obj/item/toy/prize/ripley
	name = "toy ripley"
	desc = "Mini-Mecha action figure! Collect them all! 1/11."

/obj/item/toy/prize/fireripley
	name = "toy firefighting ripley"
	desc = "Mini-Mecha action figure! Collect them all! 2/11."
	icon_state = "fireripleytoy"

/obj/item/toy/prize/deathripley
	name = "toy deathsquad ripley"
	desc = "Mini-Mecha action figure! Collect them all! 3/11."
	icon_state = "deathripleytoy"

/obj/item/toy/prize/gygax
	name = "toy gygax"
	desc = "Mini-Mecha action figure! Collect them all! 4/11."
	icon_state = "gygaxtoy"


/obj/item/toy/prize/durand
	name = "toy durand"
	desc = "Mini-Mecha action figure! Collect them all! 5/11."
	icon_state = "durandprize"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mecha action figure! Collect them all! 6/11."
	icon_state = "honkprize"

/obj/item/toy/prize/marauder
	name = "toy marauder"
	desc = "Mini-Mecha action figure! Collect them all! 7/11."
	icon_state = "marauderprize"

/obj/item/toy/prize/seraph
	name = "toy seraph"
	desc = "Mini-Mecha action figure! Collect them all! 8/11."
	icon_state = "seraphprize"

/obj/item/toy/prize/mauler
	name = "toy mauler"
	desc = "Mini-Mecha action figure! Collect them all! 9/11."
	icon_state = "maulerprize"

/obj/item/toy/prize/odysseus
	name = "toy odysseus"
	desc = "Mini-Mecha action figure! Collect them all! 10/11."
	icon_state = "odysseusprize"

/obj/item/toy/prize/phazon
	name = "toy phazon"
	desc = "Mini-Mecha action figure! Collect them all! 11/11."
	icon_state = "phazonprize"

/*
 * OMG THEIF
 */
/obj/item/toy/gooncode
	name = "Goonecode"
	desc = "The holy grail of all programmers...or at least it was at some point. It looks like it has fully leaked out."
	icon = 'icons/obj/module.dmi'
	icon_state = "gooncode"
	w_class = W_CLASS_TINY
	origin_tech = Tc_MATERIALS + "=10;" + Tc_PLASMATECH + "=6;" + Tc_SYNDICATE + "=6;" + Tc_PROGRAMMING + "=-10;" + Tc_BLUESPACE + "=6;" + Tc_POWERSTORAGE + "=6;" + Tc_BIOTECH + "=6;" + Tc_NANOTRASEN + "1"
	mech_flags = MECH_SCAN_GOONECODE //It's closed source!

/obj/item/toy/gooncode/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class = 'danger'>[user] is using [src.name]! It looks like \he's trying to re-add poo!</span>")
	return (SUICIDE_ACT_BRUTELOSS|SUICIDE_ACT_FIRELOSS|SUICIDE_ACT_TOXLOSS|SUICIDE_ACT_OXYLOSS)


/obj/item/toy/minimeteor
	name = "Mini Meteor"
	desc = "Relive the horrors of a meteor storm! Space Weather Incorporated is not responsible for any injuries caused by Mini Meteor."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"

/obj/item/toy/minimeteor/attack_self(mob/user as mob)

	playsound(user, 'sound/effects/bamf.ogg', 20, 1)

/obj/item/device/whisperphone
	name = "whisperphone"
	desc = "A device used to project your voice. Quietly."
	icon_state = "megaphone"
	item_state = "megaphone"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	w_class = W_CLASS_TINY
	flags = FPRINT
	siemens_coefficient = 1

	var/spamcheck = 0

/obj/item/device/whisperphone/attack_self(mob/living/user as mob)
	if (user.client)
		if(user.client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class = 'warning'>You cannot speak in IC (muted).</span>")
			return
	if(!ishigherbeing(user))
		to_chat(user, "<span class = 'warning'>You don't know how to use this!</span>")
		return
	if(issilent(user) || user.is_mute())
		to_chat(user, "<span class = 'warning'>You find yourself unable to speak at all.</span>")
		return
	if(spamcheck)
		to_chat(user, "<span class = 'warning'>\The [src] needs to recharge!</span>")
		return

	var/message = copytext(sanitize(input(user, "'Shout' a message?", "Whisperphone", null)  as text),1,MAX_MESSAGE_LEN)
	if(!message)
		return
	message = capitalize(message)
	if ((src.loc == user && usr.stat == 0))

		for(var/mob/O in (viewers(user)))
			O.show_message("<B>[user]</B> broadcasts, <i>\"[message]\"</i>",2)
		spamcheck = 1
		spawn(20)
			spamcheck = 0
		return


/obj/item/toy/gasha
	icon = 'icons/obj/toy.dmi'
	icon_state = "greyshirt"
	var/cooldown = 0
	w_class = W_CLASS_SMALL

/obj/item/toy/gasha/greyshirt
	name = "toy greyshirt"
	desc = "Now with kung-fu grip action!"

/obj/item/toy/gasha/greytide
	name = "toy greytide"
	desc = "Includes small pieces, not for children under or above the age of 5."
	icon_state = "greytide"

/obj/item/toy/gasha/newcop
	name = "toy nuke-op"
	desc = "Mildly explosive."
	icon_state = "newcop"

/obj/item/toy/gasha/newcop/emag_act(mob/user)
	if(!emagged)
		to_chat(user, "<span class='warning'>You turned the toy into a bomb!</span>")
		emagged = 1

		playsound(src, 'sound/effects/kirakrik.ogg', 100, 1)

		sleep(50)
		say("Someone pass the boombox.")
		sleep(5)
		explosion(get_turf(src), -1,1,4, whodunnit = user)
		qdel(src)

/obj/item/toy/gasha/jani
	name = "toy janitor"
	desc = "Cleanliness is next to godliness!"
	icon_state = "jani"

/obj/item/toy/gasha/miner
	name = "toy miner"
	desc = "Walk softly, and carry a ton of monsters."
	icon_state = "gashaminer"

/obj/item/toy/gasha/clown
	name = "toy clown"
	desc = "HONK"
	icon_state = "gashaclown"

/obj/item/toy/gasha/goliath
	name = "toy goliath"
	desc = "Now with fully articulated tentacles!"
	icon_state = "goliath"

/obj/item/toy/gasha/basilisk
	name = "toy basilisk"
	desc = "The eye has a strange shine to it."
	icon_state = "basilisk"

/obj/item/toy/gasha/mommi
	name = "toy MoMMI"
	desc = "*ping"
	icon_state = "mommi"

/obj/item/toy/gasha/guard
	name = "toy guard spider"
	desc = "Miniature giant spider, or just 'spider' for short."
	icon_state = "guard"

/obj/item/toy/gasha/hunter
	name = "toy hunter spider"
	desc = "As creepy looking as the real thing, but with 80% less chance of killing you."
	icon_state = "hunter"

/obj/item/toy/gasha/nurse
	name = "toy nurse spider"
	desc = "Not exactly what most people are hoping for when they hear 'nurse'."
	icon_state = "nurse"

/obj/item/toy/gasha/alium
	name = "toy alien"
	desc = "Has a great smile."
	icon_state = "alium"

/obj/item/toy/gasha/pomf
	name = "toy chicken"
	desc = "Cluck."
	icon_state = "pomf"

/obj/item/toy/gasha/engi
	name = "toy engineer"
	desc = "Probably better at setting up power than the real thing!"
	icon_state = "engi"

/obj/item/toy/gasha/atmos
	name = "toy atmos-tech"
	desc = "Can withstand high temperatures without melting!"
	icon_state = "atmos"

/obj/item/toy/gasha/sec
	name = "toy security"
	desc = "Won't search you on code green!"
	icon_state = "sec"

/obj/item/toy/gasha/plasman
	name = "toy plasmaman"
	desc = "All of the undending agony of the real thing, but in tiny plastic form!"
	icon_state = "plasman"

/obj/item/toy/gasha/shard
	name = "toy supermatter shard"
	desc = "Nowhere near as explosive as the real one."
	icon_state = "shard"

/obj/item/toy/gasha/mime
	name = "toy mime"
	desc = "..."
	icon_state = "gashamime"

/obj/item/toy/gasha/captain
	name = "toy captain"
	desc = "Though some say the captain should always go down with his ship, captains on NT stations tend to be the first on escape shuttles whenever the time comes."
	icon_state = "gashacaptain"

/obj/item/toy/gasha/comdom
	name = "toy comdom"
	desc = "WE GOT THE VALIDS AI CALL THE SHUTTLE"
	icon_state = "comdom"

/obj/item/toy/gasha/maniac
	name = "toy maniac"
	desc = "NOW WITH REAL KUNG-FU SEIZURE ACTION!"
	icon_state = "maniac"

/obj/item/toy/gasha/doctor
	name = "toy doctor"
	desc = "PHD in Malpractice"
	icon_state = "doctor"

/obj/item/toy/gasha/defsquid
	name = "toy death squaddie"
	desc = "Wait what aren't these guys supposed to be top secret or something?"
	icon_state = "defsquid"

/obj/item/toy/gasha/wizard
	name = "toy wizard"
	desc = "This toy is not actually magical."
	icon_state = "wiz"

/*
/obj/item/toy/gasha/bamshoot
	name = "toy Bumshooter"
	desc = "*fart"
	icon_state = "bamshoot"
*/ //No metaclub allowed ;_;

/obj/item/toy/gasha/snowflake
	name = "toy snowflake"
	desc = "What a snowflake."
	icon_state = "fag"

/obj/item/toy/gasha/shade
	name = "toy shade"
	desc = "Eternal torment in cute plastic form!"
	icon_state = "shade"

/obj/item/toy/gasha/wraith
	name = "toy wraith"
	desc = "Not the most subtle of constructs, overly fond of teleporting into walls."
	icon_state = "wraith"

/obj/item/toy/gasha/juggernaut
	name = "toy juggernaut"
	desc = "Big fists to leave big holes in the side of the station."
	icon_state = "juggernaut"

/obj/item/toy/gasha/artificer
	name = "toy artificer"
	desc = "Sort of like a MoMMI, if MoMMIs hated their own existence."
	icon_state = "artificer"

/obj/item/toy/gasha/harvester
	name = "toy harvester"
	desc = "Harvesters tend to have a bad habit of violently stabbing anyone they meet."
	icon_state = "harvester"

/obj/item/toy/gasha/narnar
	name = "toy Nar-Sie"
	desc = "The father figure to all of his faithful, the Geometer of Blood himself; NAR-SIE!"
	icon_state = "narnar"

/obj/item/toy/gasha/quote
	name = "Robot"
	desc = "It's a small robot toy."
	icon_state = "quote"

/obj/item/toy/gasha/quote/curly
	icon_state = "curly"

/obj/item/toy/gasha/quote/malco
	icon_state = "malco"

/obj/item/toy/gasha/quote/scout
	icon_state = "scout"

/obj/item/toy/gasha/mimiga/
	name = "toy mimiga"
	desc = "It looks like some sort of rabbit-thing."
	icon_state = ""

/obj/item/toy/gasha/mimiga/sue
	desc = "It looks like some sort of rabbit-thing. For some reason you get the feeling that this one is the 'best girl'."
	icon_state = "sue"

/obj/item/toy/gasha/mimiga/toroko
	icon_state = "toroko"

/obj/item/toy/gasha/mimiga/king
	icon_state = "king"

/obj/item/toy/gasha/mimiga/chaco
	desc = "It looks like some sort of rabbit-thing. For some reason you get the feeling that this one is the 'worst girl'."
	icon_state = "chaco"

/obj/item/toy/gasha/mario
	name = "toy plumber"
	desc = "It's a toy of a popular plumber character."
	icon_state = "mario"

/obj/item/toy/gasha/mario/luigi
	icon_state = "luigi"

/obj/item/toy/gasha/mario/star
	icon_state = "star"

/obj/item/toy/gasha/bomberman
	name = "toy bomberman"
	desc = "The explosive hero of the Bomberman series!"
	icon_state = "bomberman1"

/obj/item/toy/gasha/bomberman/white
	icon_state = "bomberman1"

/obj/item/toy/gasha/bomberman/black
	icon_state = "bomberman2"

/obj/item/toy/gasha/bomberman/red
	icon_state = "bomberman3"

/obj/item/toy/gasha/bomberman/blue
	icon_state = "bomberman4"

/obj/item/toy/gasha/monkeytoy
	name = "toy monkey"
	desc = "Slightly less likely to throw poop than the real one."
	icon_state = "monkeytoy"

/obj/item/toy/gasha/huggertoy
	name = "toy facehugger"
	desc = "Cannot be worn as a mask, unfortunately."
	icon_state = "huggertoy"

/obj/item/toy/gasha/borertoy
	name = "Mini Borer"
	desc = "Probably not something you should be playing with."
	icon_state = "borertoy"

/obj/item/toy/gasha/minislime
	name = "Pygmy Grey Slime"
	desc = "If you experience a tingling sensation in your hands, please stop playing with your pygmy slime immediately."
	icon_state = "minislime"

/obj/item/toy/gasha/AI/attack_self(mob/user as mob)
	if(cooldown < world.time - 8)
		playsound(user, 'sound/vox/_doop.wav', 20, 1)
		cooldown = world.time

/obj/item/toy/gasha/AI/attack_hand(mob/user as mob)
	if(loc == user)
		if(cooldown < world.time - 8)
			playsound(user, 'sound/vox/_doop.wav', 20, 1)
			cooldown = world.time
			return
	..()

/obj/item/toy/gasha/AI
	name = "Mini AI"
	desc = "Does not open doors."
	icon_state = "AI"

/obj/item/toy/gasha/AI/malf
	name = "Mini Malf"
	desc = "May be a bad influence for cyborgs."
	icon_state = "malfAI"

/obj/item/toy/gasha/minibutt/attack_self(mob/user as mob)
	if(cooldown < world.time - 8)
		playsound(user, 'sound/misc/fart.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/gasha/minibutt/attack_hand(mob/user as mob)
	if(loc == user)
		if(cooldown < world.time - 8)
			playsound(user, 'sound/misc/fart.ogg', 20, 1)
			cooldown = world.time
			return
	..()

/obj/item/toy/gasha/minibutt
	name = "mini-buttbot"
	desc = "Made from real gnome butts!"
	icon_state = "minibutt"

/obj/item/toy/gasha/skub
	name = "Skub"
	desc = "It's just Skub."
	icon_state = "skub"


/obj/item/toy/gasha/fingerbox/attack_self(mob/user as mob)
	if(cooldown < world.time - 8)
		playsound(user, 'sound/weapons/switchblade.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/gasha/fingerbox/attack_hand(mob/user as mob)
	if(loc == user)
		if(cooldown < world.time - 8)
			playsound(user, 'sound/weapons/switchblade.ogg', 20, 1)
			cooldown = world.time
			return
	..()

/obj/item/toy/gasha/fingerbox
	name = "fingerbox"
	desc = "A high quality fingerbox."
	icon_state = "fingerbox"

/obj/item/toy/gasha/bangerboy
	name = "toy Bangerboy"
	icon_state = "bangerboy"
	desc = "<B>BANG</B>"

/obj/item/toy/gasha/femsec
	name = "toy femsec"
	icon_state = "femsec"
	desc = "bodybag accessory not included"

/obj/item/toy/gasha/hoptard
	name = "toy HoPtard"
	icon_state = "hoptard"
	desc = "uhhhhhhhh"

	//I couldn't think of anywhere else to put this
/obj/item/toy/canary
	name = "canary"
	desc = "Small mechanical canary in a cage, does absolutely nothing of any importance!"
	icon = 'icons/mob/animal.dmi'
	icon_state = "canary"

/obj/item/toy/balloon
	name = "balloon"
	desc = "A simple balloon."
	icon = 'icons/obj/toy.dmi'
	icon_state = "balloon_deflated"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/toys.dmi', "right_hand" = 'icons/mob/in-hand/right/toys.dmi')
	w_class = W_CLASS_TINY
	force = 0
	throwforce = 0
	var/col = "#FFFFFF"
	var/inflated_type = /obj/item/toy/balloon/inflated
	var/volume = 12	//liters

/obj/item/toy/balloon/New(atom/A, var/chosen_col)
	..(A)
	if(col)
		if(chosen_col)
			col = chosen_col
		else
			col = rgb(rand(0,255),rand(0,255),rand(0,255))
		color = col
		update_icon()

/obj/item/toy/balloon/update_icon()
	overlays.len = 0
	var/image/shine_overlay = image('icons/obj/toy.dmi', src, "[icon_state]_shine")
	shine_overlay.appearance_flags = RESET_COLOR
	overlays += shine_overlay

/obj/item/toy/balloon/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/haslungs = FALSE
		for(var/I in H.internal_organs)
			if(istype(I, /datum/organ/internal/lungs))
				haslungs = TRUE
		if((H.species && H.species.flags & NO_BREATHE) || !haslungs)
			to_chat(user, "You can't blow up \the [src] without lungs!")
			return
	inflate(user)

/obj/item/toy/balloon/proc/inflate(mob/user, datum/gas_mixture/G)
	var/obj/item/toy/balloon/inflated/B = new inflated_type(get_turf(src), col)
	if(user)
		user.drop_item(src, force_drop = 1)
		user.put_in_hands(B)
		to_chat(user, "You blow up \the [src].")
	playsound(src, 'sound/misc/balloon_inflate.ogg', 50, 1)
	if(!G)
		B.air_contents = new /datum/gas_mixture()
		B.air_contents.volume = volume //liters
		B.air_contents.temperature = T20C
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/datum/organ/internal/lungs/L = H.internal_organs_by_name["lungs"]
			if(!L)
				return
			for(var/i in L.gasses)
				if(istype(i, /datum/lung_gas/waste))
					var/datum/lung_gas/waste/W = i
					B.air_contents.adjust_gas(W.id, 0.5)
		else
			B.air_contents.adjust_gas(GAS_CARBON, 0.5)
	else
		var/moles = ONE_ATMOSPHERE*volume/(R_IDEAL_GAS_EQUATION*G.temperature)
		B.air_contents = G.remove(moles)
		B.air_contents.volume = volume
		B.air_contents.update_values()
		B.air_contents.react()
	qdel(src)
	return B

/obj/item/toy/balloon/inflated
	desc = "An inflated balloon. You have an urge to pop it."
	icon_state = "balloon"
	w_class = W_CLASS_MEDIUM
	var/datum/gas_mixture/air_contents = null
	var/can_be_strung = TRUE

/obj/item/toy/balloon/inflated/attack_self(mob/user)
	return

/obj/item/toy/balloon/inflated/attackby(obj/item/weapon/W, mob/user)
	if(W.sharpness_flags & (SHARP_TIP|HOT_EDGE))
		user.visible_message("<span class='warning'>\The [user] pops \the [src]!</span>","You pop \the [src].")
		pop()
		return
	if(istype(W, /obj/item/stack/cable_coil) && can_be_strung)
		var/obj/item/stack/cable_coil/C = W
		C.use(1)
		to_chat(user, "You tie some of \the [C] around the end of \the [src].")
		var/obj/item/toy/balloon/inflated/string/S = new (get_turf(src), col)
		S.air_contents = air_contents
		qdel(src)

/obj/item/toy/balloon/inflated/proc/pop()
	playsound(src, 'sound/misc/balloon_pop.ogg', 100, 1)
	if(air_contents)
		loc.assume_air(air_contents)
	if(living_balloons.len)
		for(var/obj/item/toy/balloon/inflated/long/shaped/B in living_balloons)
			if(get_turf(src) in view(B))
				B.live()
	qdel(src)

/obj/item/toy/balloon/inflated/bullet_act()
	pop()
	return ..()

/obj/item/toy/balloon/inflated/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C+100)
		pop()

/obj/item/toy/balloon/inflated/string
	desc = "An inflated balloon with a string hanging from it. You have an urge to pop it."
	icon_state = "balloon_with_string"
	can_be_strung = FALSE

/obj/item/toy/balloon/inflated/string/update_icon()
	..()
	var/image/string_overlay = image('icons/obj/toy.dmi', src, "balloon_string")
	string_overlay.appearance_flags = RESET_COLOR
	overlays += string_overlay
	var/image/balleft = image('icons/mob/in-hand/left/toys.dmi', src, "[icon_state]")
	var/image/balleftshine = image('icons/mob/in-hand/left/toys.dmi', src, "[icon_state]_shine")
	var/image/balleftstring = image('icons/mob/in-hand/left/toys.dmi', src, "balloon_string")
	var/image/balright = image('icons/mob/in-hand/right/toys.dmi', src, "[icon_state]")
	var/image/balrightshine = image('icons/mob/in-hand/right/toys.dmi', src, "[icon_state]_shine")
	var/image/balrightstring = image('icons/mob/in-hand/right/toys.dmi', src, "balloon_string")
	balleftshine.appearance_flags = RESET_COLOR
	balleftstring.appearance_flags = RESET_COLOR
	balrightshine.appearance_flags = RESET_COLOR
	balrightstring.appearance_flags = RESET_COLOR
	balleft.color = col
	balright.color = col
	balleft.overlays += balleftshine
	balleft.overlays += balleftstring
	balright.overlays += balrightshine
	balright.overlays += balrightstring
	dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = balleft
	dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = balright

/obj/item/toy/balloon/glove
	name = "latex glove"
	desc = "A latex glove."
	icon = 'icons/obj/items.dmi'
	icon_state = "latexballoon"
	item_state = "lgloves"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/items_righthand.dmi')
	col = null
	inflated_type = /obj/item/toy/balloon/inflated/glove

/obj/item/toy/balloon/inflated/glove
	name = "latex glove balloon"
	desc = "An inflated latex glove."
	icon = 'icons/obj/items.dmi'
	icon_state = "latexballoon_blow"
	item_state = "latexballon"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/items_righthand.dmi')
	col = null
	can_be_strung = FALSE

/obj/item/toy/balloon/inflated/glove/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/toy/balloon/inflated/glove) && !istype(src, /obj/item/toy/balloon/inflated/glove/pair))
		var/obj/item/toy/balloon/inflated/glove/B = W
		if(!air_contents || !B.air_contents)
			return
		to_chat(user, "You tie \the [src]s together.")
		if(W.loc == user)
			user.drop_item(W, force_drop = 1)
		var/obj/item/toy/balloon/inflated/glove/pair/BB = new (get_turf(src))
		BB.air_contents = air_contents
		BB.air_contents.volume += B.air_contents.volume
		BB.air_contents.merge(B.air_contents.remove_ratio(1))
		BB.air_contents.update_values()
		BB.air_contents.react()
		if(loc == user)
			user.drop_item(src, force_drop = 1)
			user.put_in_hands(BB)
		qdel(W)
		qdel(src)

/obj/item/toy/balloon/inflated/glove/pair
	name = "pair of latex glove balloons"
	desc = "A pair of inflated latex gloves."
	icon_state = "latexballoon_pair"
	item_state = "latexballon"

/obj/item/toy/balloon/inflated/glove/pair/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/toy/crayon/red))
		user.create_in_hands(src, /obj/item/clothing/gloves/anchor_arms, msg = "You color \the [src] light red using \the [W].")

/obj/item/toy/balloon/decoy
	name = "inflatable decoy"
	desc = "Use this to fool your enemies into thinking you're a balloon!"
	icon_state = "decoy_balloon_deflated"
	w_class = W_CLASS_TINY
	col = null
	inflated_type = /obj/item/toy/balloon/inflated/decoy
	volume = 120	//liters
	origin_tech = Tc_MATERIALS + "=3"
	var/decoy_phrase = null

/obj/item/toy/balloon/decoy/verb/record_phrase()
	set name = "Record Decoy Phrase"
	set category = "Object"
	set src in usr

	var/mob/M = usr
	if(M.incapacitated())
		return

	var/N = copytext(sanitize(input("Enter a stock phrase for your decoy to say:","[src]") as null|text),1,MAX_MESSAGE_LEN)
	if(N)
		decoy_phrase = N

/obj/item/toy/balloon/decoy/inflate(mob/user, datum/gas_mixture/G)
	var/obj/item/toy/balloon/inflated/decoy/D = ..()
	if(!istype(D))
		return
	user.drop_item(D, force_drop = 1)
	D.appearance = user.appearance
	var/datum/log/L = new
	user.examine(L)
	D.desc = L.log
	qdel(L)
	if(decoy_phrase)
		D.decoy_phrase = decoy_phrase

/obj/item/toy/balloon/inflated/decoy
	desc = "An inflated decoy balloon."
	icon_state = "decoy_balloon_deflated"
	w_class = W_CLASS_GIANT
	density = 1
	can_be_strung = FALSE
	var/decoy_phrase = null
	var/list/hit_sounds = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg',\
	'sound/weapons/punch1.ogg', 'sound/weapons/punch2.ogg', 'sound/weapons/punch3.ogg', 'sound/weapons/punch4.ogg')

/obj/item/toy/balloon/inflated/decoy/examine(mob/user, var/size = "")
	if(desc)
		to_chat(user, desc)

/obj/item/toy/balloon/inflated/decoy/attackby(obj/item/weapon/W, mob/user)
	..()
	if(!src.gcDestroyed)
		attack_hand(user)

/obj/item/toy/balloon/inflated/decoy/attack_hand(mob/user)
	playsound(loc, pick(hit_sounds), 25, 1, -1)
	if(decoy_phrase)
		say(decoy_phrase)
	animate(src, transform = turn(matrix(), -40), pixel_x = -9 * PIXEL_MULTIPLIER, time = 2)
	animate(transform = turn(matrix(), 30), pixel_x = 6 * PIXEL_MULTIPLIER, time = 2)
	animate(transform = turn(matrix(), -20), pixel_x = -4 * PIXEL_MULTIPLIER, time = 2)
	animate(transform = turn(matrix(), 10), pixel_x = 2 * PIXEL_MULTIPLIER, time = 2)
	animate(transform = null, pixel_x = 0, time = 2)

/obj/item/toy/balloon/inflated/decoy/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/toy/balloon/inflated/decoy/attack_animal(mob/living/simple_animal/user)
	if((user.melee_damage_lower && prob(30*user.melee_damage_lower)) || user.environment_smash_flags)
		pop()
	else
		attack_hand(user)

/obj/item/toy/balloon/long
	name = "long balloon"
	desc = "A simple long balloon."
	icon_state = "long_balloon_deflated"
	inflated_type = /obj/item/toy/balloon/inflated/long

/obj/item/toy/balloon/inflated/long
	name = "long balloon"
	desc = "An inflated long balloon. Can be twisted into a variety of shapes."
	icon_state = "long_balloon"
	can_be_strung = FALSE
	var/living = 0
	var/list/available_shapes = list(
								"balloon dog"			= /obj/item/toy/balloon/inflated/long/shaped/animal/dog,
								"balloon giraffe"		= /obj/item/toy/balloon/inflated/long/shaped/animal/giraffe,
								"balloon stegosaurus"	= /obj/item/toy/balloon/inflated/long/shaped/animal/stegosaurus,
								"balloon bear"			= /obj/item/toy/balloon/inflated/long/shaped/animal/bear,
								"balloon sword"			= /obj/item/toy/balloon/inflated/long/shaped/sword,
								"balloon hat"			= /obj/item/toy/balloon/inflated/long/shaped/hat)

/obj/item/toy/balloon/inflated/long/attack_self(mob/user)
	var/product = input("What would you like to try to make?","[src]") as null|anything in available_shapes
	if(product)
		var/is_clumsy = clumsy_check(user)
		var/twist_time = 5 SECONDS
		if(is_clumsy)
			to_chat(user, "You begin deftly shaping \the [src]...")
			twist_time /= 2
			playsound(user, 'sound/misc/balloon_twist_short.ogg', 75, 1, channel = CHANNEL_BALLOON)
		else
			to_chat(user, "You begin squeezing and twisting \the [src]...")
			playsound(user, 'sound/misc/balloon_twist_long.ogg', 75, 1,  channel = CHANNEL_BALLOON)
		if(do_after(user, src, twist_time))
			if(!is_clumsy && prob(25))
				to_chat(user, "<span class='warning>You fumble \the [src] and pop it!</span>")
				pop()
				return
			to_chat(user, "You tie \the [src] into \a [product].")
			var/product_type = available_shapes[product]
			var/obj/item/toy/balloon/inflated/long/shaped/S = new product_type(get_turf(loc), col)
			if(loc == user)
				user.drop_item(src, force_drop = 1)
				user.put_in_hands(S)
			S.air_contents = air_contents
			S.living = living
			if(S.living)
				living_balloons.Add(S)
			qdel(src)
		else
			playsound(user, null, 75, 1, channel = CHANNEL_BALLOON)

/obj/item/toy/balloon/inflated/long/shaped
	name = "balloon shape"
	desc = "What IS this?"
	var/show_in_hand = FALSE
	var/on_body_layer = null

/obj/item/toy/balloon/inflated/long/shaped/Destroy()
	if(src in living_balloons)
		living_balloons.Remove(src)
	..()

/obj/item/toy/balloon/inflated/long/shaped/update_icon()
	..()
	if(show_in_hand)
		var/image/balleft = image('icons/mob/in-hand/left/toys.dmi', src, "[icon_state]")
		var/image/balleftshine = image('icons/mob/in-hand/left/toys.dmi', src, "[icon_state]_shine")
		var/image/balright = image('icons/mob/in-hand/right/toys.dmi', src, "[icon_state]")
		var/image/balrightshine = image('icons/mob/in-hand/right/toys.dmi', src, "[icon_state]_shine")
		balleftshine.appearance_flags = RESET_COLOR
		balrightshine.appearance_flags = RESET_COLOR
		balleft.color = col
		balright.color = col
		balleft.overlays += balleftshine
		balright.overlays += balrightshine
		dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = balleft
		dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = balright
	if(on_body_layer)
		var/target_dmi = null
		switch(on_body_layer)
			if(HEAD_LAYER)
				target_dmi = 'icons/mob/head.dmi'
		if(target_dmi)
			var/image/body_overlay = image(target_dmi, src, "[icon_state]")
			var/image/body_overlay_shine = image(target_dmi, src, "[icon_state]_shine")
			body_overlay_shine.appearance_flags = RESET_COLOR
			body_overlay.color = col
			body_overlay.overlays += body_overlay_shine
			dynamic_overlay["[on_body_layer]"] = body_overlay

/obj/item/toy/balloon/inflated/long/shaped/sword
	name = "balloon sword"
	desc = "If you were a real swordsman, you'd be able to win with this!"
	icon_state = "sword_balloon"
	show_in_hand = TRUE

/obj/item/toy/balloon/inflated/long/shaped/hat
	name = "balloon hat"
	desc = "Just like the ones made in the sweatshops of the clown planet."
	icon_state = "hat_balloon"
	species_fit = list(INSECT_SHAPED)
	slot_flags = SLOT_HEAD
	on_body_layer = HEAD_LAYER

/obj/item/toy/balloon/inflated/long/shaped/sword/update_icon()
	..()
	var/image/balleft = image('icons/mob/in-hand/left/toys.dmi', src, "[icon_state]")
	var/image/balleftshine = image('icons/mob/in-hand/left/toys.dmi', src, "[icon_state]_shine")
	var/image/balright = image('icons/mob/in-hand/right/toys.dmi', src, "[icon_state]")
	var/image/balrightshine = image('icons/mob/in-hand/right/toys.dmi', src, "[icon_state]_shine")
	balleftshine.appearance_flags = RESET_COLOR
	balrightshine.appearance_flags = RESET_COLOR
	balleft.color = col
	balright.color = col
	balleft.overlays += balleftshine
	balright.overlays += balrightshine
	dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = balleft
	dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = balright

/obj/item/toy/balloon/inflated/long/shaped/animal
	name = "balloon snake"
	desc = "How cute!"

/obj/item/toy/balloon/inflated/long/shaped/animal/dog
	name = "balloon dog"
	icon_state = "dog_balloon"

/obj/item/toy/balloon/inflated/long/shaped/animal/giraffe
	name = "balloon giraffe"
	icon_state = "giraffe_balloon"

/obj/item/toy/balloon/inflated/long/shaped/animal/stegosaurus
	name = "balloon stegosaurus"
	icon_state = "stegosaurus_balloon"

/obj/item/toy/balloon/inflated/long/shaped/animal/bear
	name = "balloon bear"
	icon_state = "bear_balloon"

/obj/item/toy/balloon/long/living
	inflated_type = /obj/item/toy/balloon/inflated/long/living

/obj/item/toy/balloon/inflated/long/living
	living = 1

var/list/living_balloons = list()

/obj/item/toy/balloon/inflated/long/shaped/proc/live()
	living_balloons.Remove(src)

/obj/item/toy/balloon/inflated/long/shaped/animal/live()
	..()
	var/mob/living/simple_animal/hostile/balloon/B = new(get_turf(src), col, icon_state)
	B.name = name
	B.air_contents = air_contents
	qdel(src)

/*
 * Action Figures
 */

/obj/item/toy/figure
	name = "\improper Non-Specific Action Figure action figure"
	desc = null
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoy"
	w_class = W_CLASS_SMALL
	var/cooldown = 0
	var/toysay = "What the fuck did you do?"
	var/toysound = 'sound/machines/click.ogg'

/obj/item/toy/figure/New()
    desc = "A \"Space Life\" brand [name]."

/obj/item/toy/figure/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = world.time + 50
		src.say("[toysay]")
		playsound(user, toysound, 20, 1)

/obj/item/toy/figure/cmo
	name = "\improper Chief Medical Officer action figure"
	icon_state = "cmo"
	toysay = "Suit sensors!"

/obj/item/toy/figure/assistant
	name = "\improper Assistant action figure"
	icon_state = "assistant"
	toysay = "Grey tide world wide!"

/obj/item/toy/figure/atmos
	name = "\improper Atmospheric Technician action figure"
	icon_state = "atmo"
	toysay = "Glory to Atmosia!"

/obj/item/toy/figure/bartender
	name = "\improper Bartender action figure"
	icon_state = "bartender"
	toysay = "Where is Pun Pun?"

/obj/item/toy/figure/borg
	name = "\improper Cyborg action figure"
	icon_state = "borg"
	toysay = "I. LIVE. AGAIN."
	toysound = 'sound/voice/liveagain.ogg'

/obj/item/toy/figure/botanist
	name = "\improper Botanist action figure"
	icon_state = "botanist"
	toysay = "Blaze it!"

/obj/item/toy/figure/captain
	name = "\improper Captain action figure"
	icon_state = "captain"
	toysay = "Any heads of staff?"

/obj/item/toy/figure/cargotech
	name = "\improper Cargo Technician action figure"
	icon_state = "cargotech"
	toysay = "For Cargonia!"

/obj/item/toy/figure/ce
	name = "\improper Chief Engineer action figure"
	icon_state = "ce"
	toysay = "Wire the solars!"

/obj/item/toy/figure/chaplain
	name = "\improper Chaplain action figure"
	icon_state = "chaplain"
	toysay = "God, please grant me power!"
	toysound = "sound/effects/prayer.ogg"

/obj/item/toy/figure/chef
	name = "\improper Chef action figure"
	icon_state = "chef"
	toysay = "I'll make you into a burger!"

/obj/item/toy/figure/chemist
	name = "\improper Chemist action figure"
	icon_state = "chemist"
	toysay = "Free creatine and hyperzine!"

/obj/item/toy/figure/clown
	name = "\improper Clown action figure"
	icon_state = "clown"
	toysay = "Honk!"
	toysound = 'sound/items/bikehorn.ogg'

/obj/item/toy/figure/ian
	name = "\improper Ian action figure"
	icon_state = "ian"
	toysay = "Arf!"

/obj/item/toy/figure/detective
	name = "\improper Detective action figure"
	icon_state = "detective"
	toysay = "This airlock has grey jumpsuit and insulated glove fibers on it."

/obj/item/toy/figure/dsquad
	name = "\improper Death Squad Officer action figure"
	icon_state = "dsquad"
	toysay = "Kill 'em all!"

/obj/item/toy/figure/engineer
	name = "\improper Engineer action figure"
	icon_state = "engineer"
	toysay = "Oh god, the singularity is loose!"

/obj/item/toy/figure/geneticist
	name = "\improper Geneticist action figure"
	icon_state = "geneticist"
	toysay = "Smash!"

/obj/item/toy/figure/hop
	name = "\improper Head of Personel action figure"
	icon_state = "hop"
	toysay = "Giving out all access!"

/obj/item/toy/figure/hos
	name = "\improper Head of Security action figure"
	icon_state = "hos"
	toysay = "Go ahead, make my day."

/obj/item/toy/figure/qm
	name = "\improper Quartermaster action figure"
	icon_state = "qm"
	toysay = "Please sign this form in triplicate and we will see about geting you a welding mask within 3 business days."

/obj/item/toy/figure/janitor
	name = "\improper Janitor action figure"
	icon_state = "janitor"
	toysay = "Look at the signs, you idiot."
	toysound ="sound/misc/slip.ogg"

/obj/item/toy/figure/lawyer
	name = "\improper Lawyer action figure"
	icon_state = "lawyer"
	toysay = "My client is a dirty traitor!"

/obj/item/toy/figure/librarian
	name = "\improper Librarian action figure"
	icon_state = "librarian"
	toysay = "One day while Andy..."

/obj/item/toy/figure/md
	name = "\improper Medical Doctor action figure"
	icon_state = "md"
	toysay = "Just clone them."

/obj/item/toy/figure/mime
	name = "\improper Mime action figure"
	icon_state = "mime"
	toysay = "..."
	toysound = null

/obj/item/toy/figure/miner
	name = "\improper Shaft Miner action figure"
	icon_state = "miner"
	toysay = "H-H-HEL-L-PP-P G-GOLIATH-H!"

/obj/item/toy/figure/ninja
	name = "\improper Ninja action figure"
	icon_state = "ninja"
	toysay = "Oh god! Stop shooting, I'm friendly!"

/obj/item/toy/figure/wizard
	name = "\improper Wizard action figure"
	icon_state = "wizard"
	toysay = "EI NATH!"
	toysound = 'sound/effects/bamf.ogg'

/obj/item/toy/figure/rd
	name = "\improper Research Director action figure"
	icon_state = "rd"
	toysay = "BLOWING THE BORGS!"

/obj/item/toy/figure/roboticist
	name = "\improper Roboticist action figure"
	icon_state = "roboticist"
	toysay = "Big stompy mechs!"
	toysound = 'sound/mecha/mechstep.ogg'

/obj/item/toy/figure/scientist
	name = "\improper Scientist action figure"
	icon_state = "scientist"
	toysay = "I'm not doing research."
	toysound = 'sound/effects/explosionfar.ogg'

/obj/item/toy/figure/syndie
	name = "\improper Nuclear Operative action figure"
	icon_state = "syndie"
	toysay = "Get that fukken disk!"

/obj/item/toy/figure/secofficer
	name = "\improper Security Officer action figure"
	icon_state = "secofficer"
	toysay = "I am the LAW!"
	toysound = 'sound/voice/biamthelaw.ogg'

/obj/item/toy/figure/virologist
	name = "\improper Virologist action figure"
	icon_state = "virologist"
	toysay = "The cure is radium!"

/obj/item/toy/figure/warden
	name = "\improper Warden action figure"
	icon_state = "warden"
	toysay = "Seventeen minutes for coughing at an officer!"

/obj/item/toy/figure/trader
	name = "\improper Trader action figure"
	icon_state = "trader"
	toysay = "Shiny rock for nuke, good trade yes?"

/obj/item/toy/foam_hand
	name = "\improper NanoTrasen foam hand"
	desc = "A simple balloon."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foam_hand"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/toys.dmi', "right_hand" = 'icons/mob/in-hand/right/toys.dmi')
	w_class = W_CLASS_LARGE
