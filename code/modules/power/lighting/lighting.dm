// The lighting system
//
// consists of light fixtures (/obj/machinery/light) and light tube/bulb items (/obj/item/weapon/light)

/obj/machinery/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = 1
	plane = OBJ_PLANE
	layer = ABOVE_DOOR_LAYER
	var/stage = 1
	var/fixture_type = "tube"
	var/sheets_refunded = 2
	var/obj/machinery/light/newlight = null

/obj/machinery/light_construct/New()
	..()
	if (fixture_type == "bulb")
		icon_state = "bulb-construct-stage1"

/obj/machinery/light_construct/examine(mob/user)
	..()
	var/mode
	switch(src.stage)
		if(1)
			mode = "It's empty and lacks wiring."
		if(2)
			mode = "It's wired."
	to_chat(user, "<span class='info'>[mode]</span>")

/obj/machinery/light_construct/attackby(obj/item/weapon/W as obj, mob/user as mob)
	src.add_fingerprint(user)
	if (W.is_wrench(user))
		if (src.stage == 1)
			W.playtoolsound(src, 75)
			to_chat(usr, "You begin deconstructing [src].")
			if (!do_after(usr, src, 30))
				return
			var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(get_turf(src))
			M.amount = sheets_refunded
			user.visible_message("[user.name] deconstructs [src].", \
				"You deconstruct [src].", "You hear a noise.")
			playsound(src, 'sound/items/Deconstruct.ogg', 75, 1)
			qdel(src)
			return
		if (src.stage == 2)
			to_chat(usr, "You have to remove the wires first.")
			return

	if(istype(W, /obj/item/stack/cable_coil))
		if (src.stage == 1)
			var/obj/item/stack/cable_coil/coil = W
			coil.use(1)
			switch(fixture_type)
				if ("tube")
					src.icon_state = "tube-empty"
				if("bulb")
					src.icon_state = "bulb-empty"
			src.stage = 2
			user.visible_message("[user.name] adds wires to \the [src].", \
				"You add wires to \the [src]")

			switch(fixture_type)
				if("tube")
					newlight = new /obj/machinery/light/built(src.loc)
				if ("bulb")
					newlight = new /obj/machinery/light/small/built(src.loc)

			newlight.dir = src.dir
			src.transfer_fingerprints_to(newlight)
			qdel(src)
			return
	..()


/obj/machinery/light_construct/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] attempts to kick \the [src].</span>", "<span class='danger'>You attempt to kick \the [src].</span>")
	to_chat(H, "<span class='danger'>Dumb move! You strain a muscle.</span>")

	H.apply_damage(rand(1,2), BRUTE, pick(LIMB_RIGHT_LEG, LIMB_LEFT_LEG, LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT))
	H.do_attack_animation(src, H)
	return SPECIAL_ATTACK_FAILED

/obj/machinery/light_construct/can_overload()
	return 0


/obj/machinery/light_construct/small
	name = "small light fixture frame"
	desc = "A small light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-stage1"
	anchored = 1
	plane = OBJ_PLANE
	layer = ABOVE_DOOR_LAYER
	stage = 1
	fixture_type = "bulb"
	sheets_refunded = 1

var/global/list/obj/machinery/light/alllights = list()

var/list/light_source_images = list()

// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "ltube1"
	desc = "A lighting fixture."
	anchored = 1
	plane = OBJ_PLANE
	layer = ABOVE_DOOR_LAYER
	use_power = 2
	idle_power_usage = 2
	active_power_usage = 10
	power_channel = LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	var/on = 0					// 1 if on, 0 if off
	var/on_gs = 0
	var/static_power_used = 0
	var/flickering = 0
	var/obj/item/weapon/light/current_bulb = null
	var/spawn_with_bulb = /obj/item/weapon/light/tube
	var/fitting = "tube"
	var/image/source_image = null

	// No ghost interaction.
	ghost_read=0
	ghost_write=0

	var/idle = 0 // For process().

// create a new lighting fixture
/obj/machinery/light/New()
	..()
	if(spawn_with_bulb)
		current_bulb = new spawn_with_bulb()
	else
		update(0)
	alllights += src

	spawn(2)
		var/area/A = get_area(src)
		if(A && !A.requires_power)
			on = 1

		if (!map.lights_always_ok)
			switch(fitting)
				if("tube")
					if(prob(2))
						broken(1)
				if("bulb")
					if(prob(5))
						broken(1)
		spawn(1)
			update(0)

/obj/machinery/light/supports_holomap()
	return TRUE

/obj/machinery/light/spook(mob/dead/observer/ghost)
	if(..(ghost, TRUE))
		flicker()

// the smaller bulb light fixture

/obj/machinery/light/cultify()
	new /obj/structure/cult_legacy/pylon(loc)
	qdel(src)

/obj/machinery/light/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet)||istype(Proj,/obj/item/projectile/ricochet))
		if(!istype(Proj ,/obj/item/projectile/beam/lasertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
			broken()
	return ..()

/obj/machinery/light/kick_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] attempts to kick \the [src].</span>", "<span class='danger'>You attempt to kick \the [src].</span>")
	if(H.foot_impact(src,rand(1,2)))
		to_chat(H, "<span class='danger'>Dumb move! You strain a muscle.</span>")

	return SPECIAL_ATTACK_FAILED

/obj/machinery/light/can_overload()
	return 0

/obj/machinery/light/broken
	icon_state = "ltube-broken" //for the mapper
	spawn_with_bulb = /obj/item/weapon/light/tube/broken

/obj/machinery/light/he
	icon_state = "lhetube1"
	spawn_with_bulb = /obj/item/weapon/light/tube/he

/obj/machinery/light/he/broken
	icon_state = "lhetube-broken" //for the mapper
	spawn_with_bulb = /obj/item/weapon/light/tube/he/broken

/obj/machinery/light/he/burned
	icon_state = "lhetube-burned" //for the mapper
	spawn_with_bulb = /obj/item/weapon/light/tube/he/burned

/obj/machinery/light/small
	icon_state = "lbulb1"
	fitting = "bulb"
	desc = "A small lighting fixture."
	spawn_with_bulb = /obj/item/weapon/light/bulb

/obj/machinery/light/small/broken
	icon_state = "lbulb-broken" //for the mapper
	spawn_with_bulb = /obj/item/weapon/light/bulb/broken

/obj/machinery/light/spot
	name = "spotlight"
	fitting = "large tube"
	spawn_with_bulb = /obj/item/weapon/light/tube/large

/obj/machinery/light/built
	icon_state = "ltube-empty" //for the mapper
	spawn_with_bulb = null

/obj/machinery/light/small/built
	icon_state = "lbulb-empty" //for the mapper
	spawn_with_bulb = null

/obj/machinery/light/initialize()
	..()
	add_self_to_holomap()

/obj/machinery/light/Destroy()
	seton(0)
	..()
	alllights -= src

/obj/machinery/light/update_icon()
	if (source_image)
		light_source_images -= source_image
		for (var/mob/living/simple_animal/hostile/giant_spider/GS in player_list)
			if (GS.client)
				GS.client.images -= source_image
	if(current_bulb)
		switch(current_bulb.status)		// set icon_states
			if(LIGHT_OK)
				icon_state = "l[current_bulb.base_state][on]"
			if(LIGHT_BURNED)
				icon_state = "l[current_bulb.base_state]-burned"
				on = 0
			if(LIGHT_BROKEN)
				icon_state = "l[current_bulb.base_state]-broken"
				on = 0
	else
		icon_state = "l[fitting]-empty"
		on = 0
	source_image = image(icon,src,icon_state)
	source_image.plane = LIGHT_SOURCE_PLANE
	light_source_images += source_image
	for (var/mob/living/simple_animal/hostile/giant_spider/GS in player_list)
		if (GS.client)
			GS.client.images += source_image

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update(var/trigger = 1)
	update_icon()
	if(on)
		current_bulb.switchcount++
		if(current_bulb.rigged)
			if(current_bulb.status == LIGHT_OK && trigger)

				log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
				message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast]")
				explode()
		else if( prob( min(60, current_bulb.switchcount*current_bulb.switchcount*0.01) ) )
			if(current_bulb.status == LIGHT_OK && trigger)
				current_bulb.status = LIGHT_BURNED
				icon_state = "l[current_bulb.base_state]-burned"
				on = 0
				kill_light()
		else
			use_power = 2
			set_light(current_bulb.brightness_range, current_bulb.brightness_power, current_bulb.brightness_color)
	else
		use_power = 1
		kill_light()

	if(current_bulb)
		active_power_usage = (current_bulb.cost * 10)
	if(on != on_gs)
		on_gs = on
		if(on)
			static_power_used = current_bulb.cost * 20 //20W per unit luminosity
			addStaticPower(static_power_used, STATIC_LIGHT)
		else
			removeStaticPower(static_power_used, STATIC_LIGHT)


/*
 * Attempt to set the light's on/off status.
 * Will not switch on if broken/burned/empty.
 */
/obj/machinery/light/proc/seton(const/s)
	on = (s && current_bulb && current_bulb.status == LIGHT_OK)
	update()

// examine verb
/obj/machinery/light/examine(mob/user)
	..()
	if(current_bulb)
		switch(current_bulb.status)
			if(LIGHT_OK)
				to_chat(user, "<span class='info'>It is turned [on? "on" : "off"].</span>")
			if(LIGHT_BURNED)
				to_chat(user, "<span class='info'>The [fitting] is burnt out.</span>")
			if(LIGHT_BROKEN)
				to_chat(user, "<span class='info'>The [fitting] has been smashed.</span>")
	else
		to_chat(user, "<span class='info'>The [fitting] has been removed.</span>")

// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/W, mob/living/user)
	user.delayNextAttack(8)
	//Light replacer code
	if(istype(W, /obj/item/device/lightreplacer))
		var/obj/item/device/lightreplacer/LR = W
		if(isliving(user))
			var/mob/living/U = user
			LR.ReplaceLight(src, U)
			return

	// attempt to insert light
	if(istype(W, /obj/item/weapon/light))
		if(current_bulb)
			to_chat(user, "There is a [fitting] already inserted.")
			return
		else
			src.add_fingerprint(user)
			var/obj/item/weapon/light/L = W
			if(L.fitting == fitting)
				if(!user.drop_item(L, src))
					user << "<span class='warning'>You can't let go of \the [L]!</span>"
					return

				to_chat(user, "You insert \the [L.name].")
				current_bulb = L
				on = has_power()
				update()

				if(on && current_bulb.rigged)

					log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
					message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast]")

					explode(get_mob_by_key(fingerprintslast))
			else
				to_chat(user, "This type of light requires a [fitting].")
				return

		// attempt to break the light
		//If xenos decide they want to smash a light bulb with a toolbox, who am I to stop them? /N

	else if(current_bulb && current_bulb.status != LIGHT_BROKEN)


		user.do_attack_animation(src, W)
		if(prob(1+W.force * 5))

			to_chat(user, "You hit the light, and it smashes!")
			for(var/mob/M in viewers(src))
				if(M == user)
					continue
				M.show_message("[user.name] smashed the light!", 1, "You hear a tinkle of breaking glass", 2)
			if(on && (W.is_conductor()))
				//if(!user.mutations & M_RESIST_COLD)
				if (prob(12))
					electrocute_mob(user, get_area(src), src, 0.3)
			broken()

		else
			to_chat(user, "You hit the light!")
	// attempt to deconstruct / stick weapon into light socket
	else if(!current_bulb)
		if(W.is_wirecutter(user)) //If it's a wirecutter take out the wires
			W.playtoolsound(src, 75)
			user.visible_message("[user.name] removes \the [src]'s wires.", \
				"You remove \the [src]'s wires.", "You hear a noise.")
			var/obj/machinery/light_construct/newlight = null
			switch(fitting)
				if("tube")
					newlight = new /obj/machinery/light_construct(src.loc)
					newlight.icon_state = "tube-construct-stage1"

				if("bulb")
					newlight = new /obj/machinery/light_construct/small(src.loc)
					newlight.icon_state = "bulb-construct-stage1"
			new /obj/item/stack/cable_coil(get_turf(src.loc), 1, "red")
			newlight.dir = src.dir
			newlight.stage = 1
			newlight.fingerprints = src.fingerprints
			newlight.fingerprintshidden = src.fingerprintshidden
			newlight.fingerprintslast = src.fingerprintslast
			qdel(src)
			return

		to_chat(user, "You stick \the [W] into the light socket!")//If not stick it in the socket.

		if(has_power() && (W.is_conductor()))
			spark(src)
			//if(!user.mutations & M_RESIST_COLD)
			if (prob(75))
				electrocute_mob(user, get_area(src), src, rand(7,10)/10)

/*
 * Returns whether this light has power
 * TRUE if area has power and lightswitch is on otherwise FALSE.
 */
/obj/machinery/light/proc/has_power()
	var/area/this_area = get_area(src)
	return this_area.lightswitch && this_area.power_light

/obj/machinery/light/proc/flicker(var/amount = rand(10, 20))
	if(flickering)
		return
	flickering = 1
	spawn(0)
		if(on && current_bulb.status == LIGHT_OK)
			for(var/i = 0; i < amount; i++)
				if(current_bulb.status != LIGHT_OK)
					break
				on = !on
				update(0)
				sleep(rand(5, 15))
			on = (current_bulb.status == LIGHT_OK)
			update(0)
		flickering = 0
		on = has_power()
		update(0)

/obj/machinery/light/attack_ghost(mob/user)
	if(!can_spook())
		return
	src.add_hiddenprint(user)
	src.flicker(1)
	investigation_log(I_GHOST, "|| was made to flicker by [key_name(user)][user.locked_to ? ", who was haunting [user.locked_to]" : ""]")
	return

// ai attack - make lights flicker, because why not
/obj/machinery/light/attack_ai(mob/user)
	// attack_robot is flaky.
	if(isMoMMI(user))
		return attack_hand(user)
	src.add_hiddenprint(user)
	src.flicker(1)
	return

/obj/machinery/light/attack_robot(mob/user)
	if(isMoMMI(user))
		return attack_hand(user)
	else
		return attack_ai(user)


// Aliens smash the bulb but do not get electrocuted./N
/obj/machinery/light/attack_alien(mob/living/carbon/alien/humanoid/user)//So larva don't go breaking light bulbs.
	if(!current_bulb || current_bulb.status == LIGHT_BROKEN)
		to_chat(user, "<span class='good'>That object is useless to you.</span>")
		return
	else if (current_bulb.status == LIGHT_OK || current_bulb.status == LIGHT_BURNED)
		user.do_attack_animation(src, user)
		for(var/mob/M in viewers(src))
			M.show_message("<span class='attack'>[user.name] smashed the light!</span>", 1, "You hear a tinkle of breaking glass", 2)
		broken()
	return

/obj/machinery/light/attack_animal(mob/living/simple_animal/M)
	if(M.melee_damage_upper == 0)
		return
	if(!current_bulb || current_bulb.status == LIGHT_BROKEN)
		to_chat(M, "<span class='warning'>That object is useless to you.</span>")
		return
	else if (current_bulb.status == LIGHT_OK || current_bulb.status == LIGHT_BURNED)
		M.do_attack_animation(src, M)
		for(var/mob/O in viewers(src))
			O.show_message("<span class='attack'>[M.name] smashed the light!</span>", 1, "You hear a tinkle of breaking glass", 2)
		if (isspider(M))
			var/datum/faction/spider_infestation/infestation = find_active_faction_by_type(/datum/faction/spider_infestation)
			if (infestation)
				var/datum/objective/spider/S = locate() in infestation.objective_holder.objectives
				if (S)
					S.broken_lights++
		broken()
// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_hand(mob/user)
	if(isobserver(user))
		return

	if(!Adjacent(user))
		return

	add_fingerprint(user)

	if(!current_bulb)
		to_chat(user, "There is no [fitting] in this light.")
		return

	// make it burn hands if not wearing fire-insulated gloves
	if(on)
		var/prot = 0

		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					prot = (G.max_heat_protection_temperature > 360)
		else
			prot = 1
		var/datum/organ/external/active_hand_organ = user.get_active_hand_organ()
		if(prot > 0 || (M_RESIST_HEAT in user.mutations) || active_hand_organ?.is_robotic())
			to_chat(user, "You remove the light [fitting]")
		else
			to_chat(user, "You try to remove the light [fitting], but it's too hot and you don't want to burn your hand.")
			return				// if burned, don't remove the light

	current_bulb.update()
	current_bulb.add_fingerprint(user)

	if(!user.put_in_active_hand(current_bulb)) //puts it in our active hand if possible
		current_bulb.forceMove(get_turf(user))
	current_bulb = null
	update()

// break the light and make sparks if was on

/obj/machinery/light/proc/broken(var/skip_sound_and_sparks = 0)
	if(!current_bulb)
		return

	if(!skip_sound_and_sparks)
		if(current_bulb.status == LIGHT_OK || current_bulb.status == LIGHT_BURNED)
			playsound(src, 'sound/effects/Glasshit.ogg', 75, 1)
		if(on)
			spark(src)
	current_bulb.status = LIGHT_BROKEN
	update()

/obj/machinery/light/proc/fix()
	if(current_bulb.status == LIGHT_OK)
		return
	current_bulb.status = LIGHT_OK
	on = 1
	update()

// explosion effect
// destroy the whole light fixture or just shatter it

/obj/machinery/light/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(75))
				broken()
		if(3.0)
			if (prob(50))
				broken()
	return

//blob effect

/obj/machinery/light/blob_act()
	if(prob(75))
		broken()
/*
 * Called when area power state changes.
 */
/obj/machinery/light/power_change()
	spawn(10)
		var/area/this_area = get_area(src)
		seton(this_area.lightswitch && this_area.power_light)

// called when on fire

/obj/machinery/light/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		broken()

/*
 * Explode the light.
 */
/obj/machinery/light/proc/explode(var/mob/user)
	spawn(0)
		broken() // Break it first to give a warning.
		sleep(2)
		explosion(get_turf(src), 0, 0, 2, 2, whodunnit = user)
		sleep(1)
		qdel(src)

// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/weapon/light
	icon = 'icons/obj/lighting.dmi'
	flags = FPRINT
	force = 2
	throwforce = 5
	w_class = W_CLASS_TINY
	var/status = 0		// LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/base_state
	var/switchcount = 0	// number of times switched
	//starting_materials = list(MAT_IRON = 60) //Not necessary, as this exact type should never appear and each subtype has its materials defined.
	var/rigged = 0		// true if rigged to explode
	var/brightness_range = 2 //how much light it gives off
	var/brightness_power = 1
	var/brightness_color = null
	var/cost = 2 //How much power does it consume in an idle state?
	var/fitting = "tube"
	var/frequency = 1500 //for smart lights

/obj/item/weapon/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "tube"
	base_state = "tube"
	item_state = "c_tube"
	starting_materials = list(MAT_GLASS = 100, MAT_IRON = 60)
	w_type = RECYK_GLASS
	brightness_range = 5
	brightness_power = 3
	brightness_color = LIGHT_COLOR_TUNGSTEN
	cost = 4

/obj/item/weapon/light/tube/he
	name = "high efficiency light tube"
	desc = "An efficient light used to reduce strain on the station's power grid."
	base_state = "hetube"
	starting_materials = list(MAT_GLASS = 300, MAT_IRON = 60)
	brightness_range = 8
	brightness_power = 4
	brightness_color = LIGHT_COLOR_HALOGEN
	cost = 2

/obj/item/weapon/light/tube/smart
	name = "smart light tube"
	desc = "An LED light tube with built-in electronics to control various properties."
	base_state = "hetube"
	starting_materials = list(MAT_GLASS = 200, MAT_IRON = 60)
	brightness_range = 8
	brightness_power = 4
	brightness_color = "#FFFFFF"
	cost = 2

/obj/item/weapon/light/tube/broken
	status = LIGHT_BROKEN

/obj/item/weapon/light/tube/burned
	status = LIGHT_BURNED

/obj/item/weapon/light/tube/he/broken
	status = LIGHT_BROKEN

/obj/item/weapon/light/tube/he/burned
	status = LIGHT_BURNED

/obj/item/weapon/light/tube/large
	w_class = W_CLASS_SMALL
	name = "large light tube"
	brightness_range = 8
	brightness_power = 4
	starting_materials = list(MAT_GLASS = 200, MAT_IRON = 100)
	cost = 8

/obj/item/weapon/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "bulb"
	base_state = "bulb"
	item_state = "contvapour"
	fitting = "bulb"
	brightness_range = 4
	brightness_power = 3
	brightness_color = LIGHT_COLOR_TUNGSTEN
	starting_materials = list(MAT_GLASS = 50, MAT_IRON = 30)
	cost = 2
	w_type = RECYK_GLASS

/obj/item/weapon/light/bulb/broken
	status = LIGHT_BROKEN

/obj/item/weapon/light/bulb/he
	name = "high efficiency light bulb"
	desc = "An efficient light used to reduce strain on the station's power grid."
	base_state = "hebulb"
	brightness_range = 6
	brightness_power = 3
	brightness_color = LIGHT_COLOR_HALOGEN
	cost = 1
	starting_materials = list(MAT_GLASS = 150, MAT_IRON = 30)

/obj/item/weapon/light/bulb/smart
	name = "smart light bulb"
	desc = "An LED light bulb with built-in electronics to control various properties."
	base_state = "hebulb"
	brightness_range = 6
	brightness_power = 3
	brightness_color = "#FFFFFF"
	cost = 1
	starting_materials = list(MAT_GLASS = 100, MAT_IRON = 30)

/obj/item/weapon/light/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/device/lightreplacer))
		var/obj/item/device/lightreplacer/LR = W
		if(LR.insert_if_possible(src))
			to_chat(user, "<span class='notice'>\the [LR] picks up \the [src].</span>")
	..()

/obj/item/weapon/light/throw_impact(atom/hit_atom)
	..()
	shatter()

/obj/item/weapon/light/bulb/fire
	name = "fire bulb"
	desc = "A replacement fire bulb."
	icon_state = "fbulb"
	base_state = "fbulb"
	item_state = "egg4"
	brightness_range = 5
	brightness_power = 2
	starting_materials = list(MAT_GLASS = 300, MAT_IRON = 60)

// update the icon state and description of the light

/obj/item/weapon/light/proc/update()
	switch(status)
		if(LIGHT_OK)
			icon_state = base_state
			desc = "A replacement [name]."
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			desc = "A burnt-out [name]."
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
			desc = "A broken [name]."


/obj/item/weapon/light/New()
	..()
	update()

// A syringe can inject plasma to make the light explode when it turns on.
/obj/item/weapon/light/on_syringe_injection(var/mob/user, var/obj/item/weapon/reagent_containers/syringe/tool)
	var/datum/reagents/syringe_reagents = tool.reagents
	if(rigged)
		to_chat(user, "<span class='warning'>\The [src] is already full!</span>")
		return INJECTION_RESULT_FAIL
	if(!(syringe_reagents.reagent_list.len == 1 && syringe_reagents.has_reagent(PLASMA, 5)))
		to_chat(user, "<span class='warning'>Injecting this solution wouldn't have any effect on \the [src].</span>")
		return INJECTION_RESULT_FAIL
	if(syringe_reagents.remove_reagent(PLASMA, 5))
		stack_trace("Couldn't remove plasma from the syringe?")
		return INJECTION_RESULT_FAIL
	log_admin("LOG: [user.name] ([user.ckey]) injected a light with plasma, rigging it to explode.")
	message_admins("LOG: [user.name] ([user.ckey]) injected a light with plasma, rigging it to explode.")
	rigged = 1
	return INJECTION_RESULT_SUCCESS_BUT_SKIP_REAGENT_TRANSFER

/obj/item/weapon/light/attack_self(var/mob/user)
	if(user.a_intent == I_HURT)
		to_chat(user, "<span class='warning'>You clench \the [src] in your hand, crushing it.</span>")
		shatter()

// called after an attack with a light item
// shatter light, unless it was an attempt to put it in a light socket
// now only shatter if the intent was harm

/obj/item/weapon/light/afterattack(var/atom/target, var/mob/user)
	if (!user.Adjacent(target))
		return
	if(istype(target, /obj/machinery/light))
		return
	if(user.a_intent != I_HURT)
		return
	to_chat(user, "<span class='warning'>\The [src] shatters as you whack it against \the [target].</span>")
	shatter()

/obj/item/weapon/light/proc/shatter(verbose = TRUE)
	if(status == LIGHT_OK || status == LIGHT_BURNED)
		if(verbose)
			visible_message("<span class='warning'>[name] shatters.</span>","<span class='warning'>You hear a small glass object shatter.</span>")
		status = LIGHT_BROKEN
		force = 5
		playsound(src, 'sound/effects/Glasshit.ogg', 75, 1)
		update()
