/obj/structure/bed/chair/vehicle/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"
	keytype = /obj/item/key/security
	can_have_carts = FALSE
	wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle/secway
	var/clumsy_check = 1

/obj/item/key/security
	name = "secway key"
	desc = "A keyring with a small steel key, and a rubber stun baton accessory."
	icon_state = "keysec"

/obj/structure/bed/chair/vehicle/secway/set_keys() //doesn't spawn with keys, mapped in
	return

/obj/structure/bed/chair/vehicle/secway/make_offsets()
	offsets = list(
		"[SOUTH]" = list("x" = 0, "y" = 3 * PIXEL_MULTIPLIER),
		"[WEST]" = list("x" = 2 * PIXEL_MULTIPLIER, "y" = 3 * PIXEL_MULTIPLIER),
		"[NORTH]" = list("x" = 0, "y" = 3 * PIXEL_MULTIPLIER),
		"[EAST]" = list("x" = -2 * PIXEL_MULTIPLIER, "y" = 3 * PIXEL_MULTIPLIER)
		)

/obj/structure/bed/chair/vehicle/secway/handle_layer()
	if(dir == WEST || dir == EAST || dir == SOUTH)
		layer = VEHICLE_LAYER
		plane = ABOVE_HUMAN_PLANE
	else
		layer = OBJ_LAYER
		plane = OBJ_PLANE


/obj/structure/bed/chair/vehicle/secway/to_bump(var/atom/obstacle)
	..()

	if(!occupant)
		return

	if(clumsy_check)
		if(istype(occupant, /mob/living))
			var/mob/living/M = occupant
			if(!clumsy_check(M) && M.dizziness < 450)
				return
	occupant.Knockdown(2)
	occupant.Stun(2)
	playsound(src, "sound/effects/meteorimpact.ogg", 25, 1)
	occupant.visible_message("<span class='danger'>[occupant] crashes into \the [obstacle]!</span>", "<span class='danger'>You crash into \the [obstacle]!</span>")

	if(istype(obstacle, /mob/living))
		var/mob/living/idiot = obstacle
		idiot.Knockdown(2)
		idiot.Stun(2)

/obj/effect/decal/mecha_wreckage/vehicle/secway
	// TODO: SPRITE PLS
	//icon = 'icons/obj/vehicles.dmi'
	//icon_state = "gokart_wreck"
	name = "secway wreckage"
	desc = "Nothing to see here!"

var/list/random_tool_sounds = list('sound/items/Ratchet.ogg','sound/items/Screwdriver.ogg', 'sound/items/Screwdriver2.ogg',
	'sound/items/Wirecutter.ogg', 'sound/weapons/toolhit.ogg','sound/items/Welder.ogg', 'sound/items/Welder2.ogg',
	'sound/items/Crowbar.ogg')

var/list/descriptive_sprites = list("I go for the classics", "A big donut", "A Rottweiler combat cyborg", "I'm the head honcho", "A winged chariot", "A goofy steed")

/obj/item/weapon/secway_kit
	name = "custom secway kit"
	desc = "Everything you need to build your own custom Secway."
	icon = 'icons/obj/device.dmi'
	icon_state = "modkit"
	flags = FPRINT
	w_class = W_CLASS_SMALL
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	var/remaining_upgrades = 3
	var/obj/structure/bed/chair/vehicle/secway/custom/baby
	var/named = FALSE

/obj/item/weapon/secway_kit/New()
	..()
	baby = new(src)

/obj/item/weapon/secway_kit/examine(mob/user)
	..()
	if(!named)
		to_chat(user,"<span class='warning'>It needs a name!</span>")
	to_chat(user,"<span class='warning'>It has room for [remaining_upgrades] more upgrades.</span>")
	if(remaining_upgrades < 1)
		return
	if(!baby.can_have_carts)
		to_chat(user,"<span class='info'>There's space for a cart hook made of metal sheeting.</span>")
	if(baby.max_health < 300)
		to_chat(user,"<span class='info'>It hasn't been upgraded with plasteel for armoring.</span>")
	if(!(baby.pass_flags & PASSMOB) || baby.knockdown_time > 1 || baby.impact_sound)
		//Don't suggest if already adding impact upgrades
		to_chat(user,"<span class='info'>If you rubbed ectoplasm on it, it would cruise through people instead of bumping them.</span>")
	if(!is_type_in_list(/datum/action/vehicle/toggle_headlights,baby.vehicle_actions))
		to_chat(user,"<span class='info'>Noone has added a flashlight for headlights or a siren helmet for police lights.</span>")
	if(baby.knockdown_time < 3 || baby.pass_flags & PASSMOB)
		//Note: you can't use this upgrade if you already don't bump targets
		to_chat(user,"<span class='info'>A sheet of plastic would make a good bumper for knocking people over.</span>")
	if(baby.can_take_pai == FALSE)
		to_chat(user,"<span class='info'>With an unprinted circuitboard you could slot in a personal AI.</span>")
	if(!baby.impact_sound || baby.pass_flags & PASSMOB)
		//Don't suggest if already ethereal
		to_chat(user,"<span class='info'>There's a good spot for a hailer to make legal noises when you hit stuff.</span>")
	if(!baby.can_spacemove)
		to_chat(user,"<span class='info'>A spacepod core is just what this thing needs to move in space.</span>")
	if(baby.movement_delay > 0.8)
		to_chat(user,"<span class='info'>If it had an RTG cell, this thing could go a little faster.</span>")
	if(baby.explodes)
		to_chat(user,"<span class='info'>With a taser, it could be rigged to fire a countermeasure if destroyed.</span>")
	if(baby.buckle_range < 7)
		to_chat(user,"<span class='info'>Just needs a bluespace crystal and you could buckle in remotely!</span>")

/obj/item/weapon/secway_kit/attack_self(mob/user)
	var/choice = alert(user, "What would you like to do?","Custom Secway","Name","Appearance", "Finish")

	switch(choice)
		if("Name")
			baby.name = input(user, "What will you call it?", "Secway Name", baby.name) as null|text
			named = TRUE

		if("Appearance")
			var/iconchoice = input(user, "What inspired your design?", "Secway Appearance", null) as null|anything in descriptive_sprites
			switch(iconchoice)
				if("I go for the classics")
					baby.icon_state = "secway-custom-classic"
				if("A big donut")
					baby.icon_state = "secway-custom-sprinkles"
				if("A Rottweiler combat cyborg")
					baby.icon_state = "secway-custom-rottweiler"
				if("I'm the head honcho")
					baby.icon_state = "secway-custom-HoS"
				if("A winged chariot")
					baby.icon_state = "secway-custom-chariot"
				if("A goofy steed")
					baby.icon_state = "secway-custom-steed"

		if("Finish")
			if(remaining_upgrades < 1 && named)
				baby.forceMove(get_turf(loc))
				new /obj/item/key/security/spare(baby.loc)
				qdel(src)
			else
				to_chat(user,"<span class='warning'>It isn't done yet!</span>")

/obj/item/weapon/secway_kit/attackby(obj/item/W, mob/living/user)
	if(remaining_upgrades<1)
		return ..()
	if(istype(W, /obj/item/stack/sheet/metal) && !baby.can_have_carts)
		baby.can_have_carts = TRUE
	else if(istype(W, /obj/item/stack/sheet/plasteel) && baby.max_health < 300)
		baby.max_health = 300
		baby.health = 300
	else if(istype(W, /obj/item/weapon/ectoplasm) && !(baby.pass_flags & PASSMOB))
		baby.pass_flags |= PASSMOB
	else if(istype(W, /obj/item/device/flashlight) && !is_type_in_list(/datum/action/vehicle/toggle_headlights,baby.vehicle_actions))
		new /datum/action/vehicle/toggle_headlights(baby)
	else if(istype(W, /obj/item/clothing/head/helmet/siren) && !is_type_in_list(/datum/action/vehicle/toggle_headlights,baby.vehicle_actions))
		new /datum/action/vehicle/toggle_headlights/siren(baby)
		baby.siren = TRUE
	else if(istype(W,/obj/item/stack/sheet/mineral/plastic) && baby.knockdown_time < 3)
		baby.knockdown_time = 3
	else if(istype(W,/obj/item/device/hailer) && !baby.impact_sound)
		baby.impact_sound = 'sound/voice/halt.ogg'
	else if(istype(W,/obj/item/weapon/circuitboard/blank) && !baby.can_take_pai)
		baby.can_take_pai = TRUE
	else if(istype(W,/obj/item/pod_parts/core) && !baby.can_spacemove)
		baby.can_spacemove = TRUE
	else if(istype(W,/obj/item/weapon/cell/rad) && baby.movement_delay > 0.8)
		baby.movement_delay = 0.8
	else if(istype(W,/obj/item/bluespace_crystal) && baby.buckle_range < 7)
		baby.buckle_range = 7
	else if(istype(W,/obj/item/weapon/gun/energy/taser) && baby.explodes)
		baby.explodes = FALSE
	else
		return ..()
	playsound(src, pick(random_tool_sounds), 50, 1)
	to_chat(user,"<span class='notice'>You add \the [W] to \the [src].")
	use(W, user)
	remaining_upgrades--
	return TRUE //cancel attack

/obj/item/weapon/secway_kit/proc/use(var/obj/item/I, mob/living/user)
	if(istype(I,/obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = I
		S.use(1)
	else
		user.drop_item(I,src)
		qdel(I)

/obj/structure/bed/chair/vehicle/secway/custom
	name = "Baby"
	desc = "An elite secway, lovingly crafted by a security member."
	icon_state = "secway-custom-classic"
	keytype = /obj/item/key/security/spare
	req_access = list(63)
	health = 200
	max_health = 200
	var/knockdown_time = 1
	var/hit_damage = 0
	var/impact_sound = null
	var/explodes = TRUE
	var/siren = FALSE

/obj/structure/bed/chair/vehicle/secway/custom/process()
	..()
	if(light_obj && siren)
		if(light_color == "#FF0000")
			light_color = "#0000FF"
		else
			light_color = "#FF0000"

/obj/structure/bed/chair/vehicle/secway/custom/to_bump(var/atom/obstacle)
	if(istype(obstacle,/obj/machinery) && !istype(obstacle,/obj/machinery/door))
		playsound(src, 'sound/effects/grillehit.ogg', 50, 1)
		obstacle.shake(1, 3)
	if(isliving(obstacle))
		if(impact_sound)
			playsound(src, impact_sound, 100, 1, vary = 0)
		var/mob/living/idiot = obstacle
		if(hit_damage)
			idiot.apply_damage(hit_damage, BRUTE, LIMB_CHEST)
			visible_message("\The [src] slams into [idiot] with its mounted knife!")
		idiot.Knockdown(knockdown_time)
	return ..()

/obj/structure/bed/chair/vehicle/secway/custom/check_key(var/mob/user)
	if(!allowed(user))
		return FALSE
	return ..()

/obj/structure/bed/chair/vehicle/secway/custom/can_warn()
	return FALSE

/obj/structure/bed/chair/vehicle/secway/custom/die()
	density = 0
	visible_message("<span class='warning'>\The [nick] explodes!</span>")
	if(explodes)
		explosion(src.loc,-1,0,2,7,10)
	else
		//fire projectiles
		var/list/fire_shots = alldirs.Copy()
		while(fire_shots.len)
			var/target_dir = pick_n_take(fire_shots)
			var/obj/item/projectile/energy/electrode/E = new(src.loc)
			E.starting = E.loc
			var/throwturf = get_ranged_target_turf(src, target_dir, 7)
			E.OnFired(throwturf)
			E.process()

	unlock_atom(occupant)
	if(wreckage_type)
		var/obj/effect/decal/mecha_wreckage/wreck = new wreckage_type(src.loc)
		setup_wreckage(wreck)
	qdel(src)

/obj/structure/bed/chair/vehicle/secway/custom/pAImove(mob/living/silicon/pai/user, dir)
	if(!..())
		return
	var/turf/T = loc
	if(!T.has_gravity() && !can_spacemove)
		return
	step(src, dir)

/obj/structure/bed/chair/vehicle/secway/custom/Process_Spacemove(var/check_drift = 0)
	return can_spacemove

/obj/structure/bed/chair/vehicle/secway/custom/can_apply_inertia()
	return !can_spacemove

/obj/structure/bed/chair/vehicle/secway/custom/everything
	name = "The Towberman"
	icon_state = "secway-custom-HoS"
	health = 300
	max_health = 300
	knockdown_time = 3
	impact_sound = 'sound/voice/halt.ogg'
	explodes = FALSE
	buckle_range = 7
	movement_delay = 0.9
	can_take_pai = TRUE
	can_spacemove = TRUE
	can_have_carts = TRUE
	//Doesn't have ectoplasm upgrade since that renders the crash upgrades pointless

/obj/structure/bed/chair/vehicle/secway/custom/everything/New()
	..()
	new /datum/action/vehicle/toggle_headlights/siren(src)
