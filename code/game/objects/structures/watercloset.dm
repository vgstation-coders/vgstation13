//todo: toothbrushes, and some sort of "toilet-filthinator" for the hos

/obj/structure/wc
	name = "base WC object"
	icon = 'icons/obj/watercloset.dmi'
	density = 0
	anchored = 1
	var/obj/item/watersource = null
	var/watertype = /obj/item/reagent_core //TODO: Make /obj/item/weapon/reagent_containers/glass/beaker/water when plumbing starts to exist.
	var/can_be_wrenched = TRUE

/obj/structure/wc/New()
	. = ..()
	if(watertype)
		watersource = new watertype

/obj/structure/wc/Destroy()
	QDEL_NULL(watersource)
	. = ..()

/obj/structure/wc/verb/empty_container_into()
	set name = "Empty container into"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return
	if(!is_open())
		to_chat(usr, "<span class='warning'>\The [src] is closed!</span>")
		return
	var/obj/item/weapon/reagent_containers/container = usr.get_active_hand()
	if(!istype(container))
		to_chat(usr, "<span class='warning'>You need a reagent container in your active hand to do that.</span>")
		return
	return container.drain_into(usr, src)

/obj/structure/wc/proc/is_open()
	return TRUE

/obj/structure/wc/AltClick()
	if(Adjacent(usr))
		return empty_container_into()
	return ..()

/obj/structure/wc/attackby(obj/item/I as obj, mob/living/user as mob)
	if(can_be_wrenched && I.is_wrench(user))
		to_chat(user, "<span class='notice'>You [anchored ? "un":""]bolt \the [src]'s grounding lines.</span>")
		anchored = !anchored
		update_dir() // just so it updates a subtype
		return 1
	if(!anchored)
		if(!watersource && (istype(I,/obj/item/weapon/reagent_containers/glass/beaker) || istype(I,/obj/item/reagent_core)))
			if(user.drop_item(I,src))
				watersource = I
				to_chat(user, "<span class='notice'>You add [I] as a reagent source for [src].</span>")
				return 1
		to_chat(user, "<span class='warning'>\The [src] needs to be bolted to the floor to work.</span>")
		return 1

/obj/structure/wc/attack_hand(mob/living/user)
	if(!anchored)
		if(watersource)
			user.put_in_hands(watersource)
			to_chat(user, "<span class='warning'>You remove [watersource] from [src].</span>")
			watersource = null
			return
		to_chat(user, "<span class='warning'>\The [src] needs to be bolted to the floor to work.</span>")
		return 1

/obj/structure/wc/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon_state = "toilet00"
	var/open = 0			//if the lid is up
	var/rodded = 0			//1 if rods added; 0 if not
	var/cistern = 0			//if the cistern bit is open
	var/mob/living/swirlie = null	//the mob being given a swirlie
	var/base_icon = "toilet"

/obj/structure/wc/toilet/New()
	. = ..()
	open = round(rand(0, 1))
	update_icon()

/obj/structure/wc/toilet/is_open()
	return open

/obj/structure/wc/toilet/attack_hand(mob/living/user)
	if(..())
		return
	if(user.attack_delayer.blocked())
		return
	if(swirlie)
		user.delayNextAttack(1 SECONDS)
		swirlie.visible_message("<span class='danger'>[user] slams the toilet seat onto [swirlie.name]'s head!</span>", "<span class='userdanger'>[user] slams the toilet seat onto your head!</span>", "You hear reverberating porcelain.")
		swirlie.apply_damage(8, BRUTE, LIMB_HEAD, used_weapon = name)
		playsound(src, 'sound/weapons/tablehit1.ogg', 50, TRUE)
		add_attacklogs(user, swirlie, "slammed the toilet seat", admin_warn=FALSE)
		add_fingerprint(user)
		add_fingerprint(swirlie)
		return

	if(cistern && !open)
		if(!contents.len)
			to_chat(user, "<span class='notice'>The cistern is empty.</span>")
			return
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user) && istype(I))
				user.put_in_hands(I)
			else
				I.forceMove(get_turf(src))
			to_chat(user, "<span class='notice'>You find \an [I] in the cistern.</span>")
			return

	open = !open
	update_icon()

/obj/structure/wc/toilet/proc/get_contents_w_class()
	. = 0
	for(var/obj/item/I in contents)
		. += I.w_class

/obj/structure/wc/toilet/update_icon()
	icon_state = "[base_icon][open][cistern]"

/obj/structure/wc/toilet/attackby(obj/item/I as obj, mob/living/user as mob)
	if(..())
		return 1
	if(open && cistern && rodded == 0 && istype(I,/obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(R.amount < 2)
			return
		to_chat(user, "<span class='notice'>You add the rods to the toilet, creating flood avenues.</span>")
		R.use(2)
		rodded = 1 //rodded 0 -> 1
		return
	if(open && cistern && rodded == 1 && istype(I,/obj/item/weapon/paper))
		to_chat(user, "<span class='notice'>You create a filter with the paper and insert it.</span>")
		var/obj/structure/centrifuge/C = new /obj/structure/centrifuge(src.loc)
		C.dir = src.dir
		qdel(I)
		qdel(src)
		return
	if(iscrowbar(I) || istype(I,/obj/item/weapon/chisel))
		to_chat(user, "<span class='notice'>You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"].</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(do_after(user, src, 30))
			user.visible_message("<span class='notice'>[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!</span>", "<span class='notice'>You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "You hear grinding porcelain.")
			cistern = !cistern
			update_icon()
			return

	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I

		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting

			if(G.state>1)
				if(GM.loc != get_turf(src))
					to_chat(user, "<span class='warning'>[GM.name] needs to be on the toilet.</span>")
					return
				if(open && !swirlie)
					GM.visible_message("<span class='danger'>[user] starts to place [GM.name]'s head inside \the [src].</span>", "<span class='userdanger'>[user] is placing your head inside \the [src]!</span>")
					swirlie = GM
					if(do_after(user, src, 3 SECONDS, needhand = FALSE))
						add_fingerprint(user)
						add_fingerprint(GM)
						var/blind_msg = watersource && !watersource.reagents.is_empty() ? "You hear a toilet flushing." : null
						GM.visible_message("<span class='danger'>[user] gives [GM.name] a swirlie!</span>", "<span class='userdanger'>[user] gives you a swirlie!</span>", blind_msg)
						if(watersource && !watersource.reagents.is_empty())
							watersource.reagents.reaction(GM, TOUCH, zone_sels = list(LIMB_HEAD,TARGET_EYES,TARGET_MOUTH))
							GM.forcesay(list("-BLERGH", "-BLURBL", "-HURGBL"))
							playsound(src, 'sound/misc/toilet_flush.ogg', 50, TRUE)
						else
							GM.visible_message("<span class='danger'>...with no effect, as [src] is dry!</span>")

						if(watersource && !watersource.reagents.is_empty() && !GM.internal && GM.losebreath <= 30)
							GM.losebreath += 5
							add_attacklogs(user, GM, "gave a swirlie to", admin_warn=FALSE)
						else
							add_attacklogs(user, GM, "gave a swirle with no effect to", admin_warn=FALSE)
					swirlie = null
				else
					if(user.attack_delayer.blocked())
						return
					user.delayNextAttack(1 SECONDS)
					GM.visible_message("<span class='danger'>[user] slams [GM.name] into \the [src]!</span>", "<span class='userdanger'>[user] slams you into \the [src]!</span>")
					GM.adjustBruteLoss(8)
					playsound(src, 'sound/weapons/tablehit1.ogg', 50, TRUE)
					add_attacklogs(user, GM, "slammed into the toilet", admin_warn=FALSE)
					add_fingerprint(user)
					add_fingerprint(GM)
					return
			else
				to_chat(user, "<span class='warning'>You need a tighter grip.</span>")
		return

	if(cistern)
		if(I.w_class > W_CLASS_MEDIUM)
			to_chat(user, "<span class='notice'>\The [I] does not fit.</span>")
			return
		if(get_contents_w_class() + I.w_class > W_CLASS_HUGE)
			to_chat(user, "<span class='notice'>The cistern is full.</span>")
			return
		if(user.drop_item(I, src))
			to_chat(user, "You carefully place \the [I] into the cistern.")
			if(watersource)
				watersource.reagents.reaction(I, TOUCH) // Handles water affecting items, such as making dissolvable items dissolve.
			return

/obj/structure/wc/toilet/bite_act(mob/user)
	user.simple_message("<span class='notice'>That would be disgusting.</span>", "<span class='info'>You're not high enough for that... Yet.</span>") //Second message 4 hallucinations

/obj/structure/wc/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon_state = "urinal"
	pixel_y = 32
	verb_rotates = TRUE
	var/flushing = FALSE

//mapping subtypes
/obj/structure/wc/urinal/north
	//no dir because it was like that on xoq
	pixel_y = -32

/obj/structure/wc/urinal/east
	dir = EAST
	pixel_x = -30
	pixel_y = 0

/obj/structure/wc/urinal/west
	dir = WEST
	pixel_x = 30
	pixel_y = 0

/obj/structure/wc/urinal/update_dir()
	. = ..()
	if(anchored)
		var/turf/T = get_step(src,opposite_dirs[dir])
		if(T?.density)
			switch(dir)
				if(NORTH)
					pixel_x = 0
					pixel_y = -32
				if(SOUTH)
					pixel_x = 0
					pixel_y = 32
				if(EAST)
					pixel_x = -30
					pixel_y = 0
				if(WEST)
					pixel_x = 30
					pixel_y = 0
			return
	pixel_x = 0
	pixel_y = 0

/obj/structure/wc/urinal/attack_hand(mob/living/user)
	. = ..()
	if(!.)
		if(flushing)
			if(watersource && watersource.reagents && !watersource.reagents.is_empty())
				to_chat(user, "<span class='notice'>You run your hands under [src], for some reason.</span>")
				watersource.reagents.reaction(user, TOUCH, zone_sels = list(LIMB_LEFT_HAND,LIMB_RIGHT_HAND))
				return 1
		else
			flush(user)
			return 1

/obj/structure/wc/urinal/attackby(obj/item/I as obj, mob/user as mob)
	if(..())
		return 1

	if(istype(I, /obj/item/tool/crowbar))
		to_chat(user, "<span class='notice'>You begin to disassemble \the [src].</span>")
		I.playtoolsound(src, 50)
		if(do_after(user, src, 3 SECONDS))
			new /obj/item/stack/sheet/metal(loc, 2)
			if(watersource)
				watersource.forceMove(loc)
				watersource = null
			qdel(src)
		return

	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(G.state>1)
				if(!GM.loc == get_turf(src))
					to_chat(user, "<span class='notice'>[GM.name] needs to be on the urinal.</span>")
					return
				user.visible_message("<span class='danger'>[user] slams [GM.name] into the [src]!</span>", "<span class='notice'>You slam [GM.name] into the [src]!</span>")
				if(!flushing || user.a_intent == I_HURT)
					GM.adjustBruteLoss(8)
				if(flushing && watersource && watersource.reagents && !watersource.reagents.is_empty())
					watersource.reagents.reaction(GM, TOUCH, zone_sels = list(LIMB_HEAD,TARGET_EYES,TARGET_MOUTH))
			else
				to_chat(user, "<span class='notice'>You need a tighter grip.</span>")

	else if(flushing && watersource && watersource.reagents && !watersource.reagents.is_empty())
		watersource.reagents.reaction(I, TOUCH)

/obj/structure/wc/urinal/bite_act(mob/user)
	user.simple_message("<span class='notice'>That would be disgusting.</span>", "<span class='info'>You're not high enough for that... Yet.</span>") //Second message 4 hallucinations

/obj/structure/wc/urinal/proc/flush(mob/user)
	if(!watersource || !watersource.reagents || watersource.reagents.is_empty())
		to_chat(user,"<span class='warning'>You flush the handle but nothing happens.</span>")
		return
	flushing = !flushing
	if(!flushing)
		return
	overlays.len = 0
	var/image/flushover = image(icon,src,"urinal_flush")
	flushover.color = mix_color_from_reagents(watersource.reagents.reagent_list)
	overlays += flushover
	visible_message("<span class='notice'>\The [src] flushes.</span>")
	for(var/ticks in 1 to 10)
		watersource.reagents.remove_all(5)
		sleep(1 SECONDS)
		if(!flushing || !anchored || watersource.reagents.is_empty())
			break
	flushing = FALSE
	overlays.len = 0

/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	icon_state_open = "shower_t"
	density = 0
	anchored = 1
	use_power = MACHINE_POWER_USE_NONE
	var/on = 0
	var/obj/effect/mymist = null
	var/ismist = 0 //Needs a var so we can make it linger~
	var/watertemp = "cool" //Freezing, normal, or boiling
	var/obj/item/watersource = null
	var/watertype = /obj/item/reagent_core //TODO: Make /obj/item/weapon/reagent_containers/glass/beaker/water when plumbing starts to exist.
	var/clean_power = CLEANLINESS_SPACECLEANER//Nanotrasen showers scrub you clean
	var/coldtemp = -137
	var/hottemp = 60

	machine_flags = SCREWTOGGLE

	ghost_read = 0
	ghost_write = 0

/obj/machinery/shower/New() //Our showers actually wet people and floors now
	..()
	watersource = new watertype

//Add heat controls? When emagged, you can freeze to death in it?

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	plane = ABOVE_HUMAN_PLANE
	anchored = 1
	mouse_opacity = 0

/obj/machinery/shower/togglePanelOpen(var/obj/toggleitem, var/mob/user)
	if(on)
		to_chat(user, "<span class='warning'>You need to turn off \the [src] first.</span>")
		return
	..()

/obj/machinery/shower/attack_hand(mob/M as mob)
	if(..())
		return
	if(panel_open)
		to_chat(M, "<span class='warning'>\The [src]'s maintenance hatch needs to be closed first.</span>")
		return
	if(!anchored)
		if(watersource)
			M.put_in_hands(watersource)
			watersource = null
			to_chat(M, "<span class='warning'>You remove [M] from [src].</span>")
		else
			to_chat(M, "<span class='warning'>\The [src] needs to be bolted to the floor to work.</span>")
		return

	on = !on
	M.visible_message("<span class='notice'>[M] turns \the [src] [on ? "on":"off"]</span>", \
					  "<span class='notice'>You turn \the [src] [on ? "on":"off"]</span>")
	update_icon()
	if(on)
		for(var/atom/movable/G in get_turf(src))
			if(clean_power)
				G.clean_act(clean_power)
			else
				G.clean_blood()

/obj/machinery/shower/attackby(obj/item/I as obj, mob/user as mob)

	..()

	if(I.type == /obj/item/device/analyzer)
		to_chat(user, "<span class='notice'>The water's temperature seems to be [watertemp].</span>")
	if(!anchored && !watersource && istype(I,/obj/item/weapon/reagent_containers/glass/beaker))
		if(user.drop_item(I,src))
			watersource = I
			to_chat(user, "<span class='notice'>You add [I] as a reagent source for [src].</span>")
			return 1
	if(panel_open) //The panel is open
		if(I.is_wrench(user))
			user.visible_message("<span class='warning'>[user] begins to adjust \the [src]'s temperature valve with \a [I.name].</span>", \
								 "<span class='notice'>You begin to adjust \the [src]'s temperature valve with \a [I.name].</span>")
			if(do_after(user, src, 50))
				switch(watertemp)
					if("cool")
						watertemp = "freezing cold"
					if("freezing cold")
						watertemp = "searing hot"
					if("searing hot")
						watertemp = "cool"
				I.playtoolsound(src, 100)
				user.visible_message("<span class='warning'>[user] adjusts \the [src]'s temperature with \a [I.name].</span>",
				"<span class='notice'>You adjust \the [src]'s temperature with \a [I.name], the water is now [watertemp].</span>")
				add_fingerprint(user)
	else
		if(I.is_wrench(user))
			user.visible_message("<span class='warning'>[user] starts adjusting the bolts on \the [src].</span>", \
								 "<span class='notice'>You start adjusting the bolts on \the [src].</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 100, 1)
			if(do_after(user, src, 50))
				if(anchored)
					src.visible_message("<span class='warning'>[user] unbolts \the [src] from the floor.</span>", \
								 "<span class='notice'>You unbolt \the [src] from the floor.</span>")
					on = 0
					anchored = 0
					update_icon()
				else
					src.visible_message("<span class='warning'>[user] bolts \the [src] to the floor.</span>", \
								 "<span class='notice'>You bolt \the [src] to the floor.</span>")
					anchored = 1
/obj/machinery/shower/update_icon()	//This is terribly unreadable, but basically it makes the shower mist up
	overlays.len = 0 //Once it's been on for a while, in addition to handling the water overlay.
	if(mymist)
		QDEL_NULL(mymist)

	var/misttype = /obj/effect/mist
	var/overlay_state = "water"
	if(watersource?.reagents?.has_any_reagents(ACIDS))
		misttype = /obj/effect/acidvapor
		overlay_state = "acid"
	if(on)
		var/image/water = image(icon, src, overlay_state, BELOW_OBJ_LAYER, dir)
		water.plane = relative_plane(ABOVE_HUMAN_PLANE)
		overlays += water
		if(watertemp == "freezing cold") //No mist if the water is really cold
			return
		if(!ismist)
			spawn(50)
				if(src && on)
					ismist = 1
					mymist = new misttype(get_turf(src))
		else
			ismist = 1
			mymist = new misttype(get_turf(src))
	else if(ismist)
		ismist = 1
		mymist = new misttype(get_turf(src))
		spawn(250)
			if(src && !on)
				QDEL_NULL(mymist)
				ismist = 0

/obj/machinery/shower/Crossed(atom/movable/O)
	..()
	wash(O)

//Yes, showers are super powerful as far as washing goes
//Shower cleaning has been nerfed (no, really). 75 % chance to clean everything on each tick
//You'll have to stay under it for a bit to clean every last noggin

#define CLEAN_PROB 75 //Percentage

/obj/machinery/shower/proc/wash(atom/movable/O as obj|mob)
	if(!on)
		return

	if(iscarbon(O))
		var/mob/living/carbon/M = O
		if(prob(CLEAN_PROB))
			M.clean_blood()//cleaning feet for humans
		for(var/obj/item/I in M.held_items)
			if(prob(CLEAN_PROB))
				I.clean_blood()
				if(clean_power)
					I.clean_act(clean_power)
				M.update_inv_hand(M.is_holding_item(I))
		if(M.back && prob(CLEAN_PROB))
			if(M.back.clean_blood())
				M.update_inv_back(0)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/washgloves = 1
			var/washshoes = 1
			var/washmask = 1
			var/washears = 1
			var/washglasses = 1

			if(H.wear_suit)
				washgloves = !(is_slot_hidden(H.wear_suit.body_parts_covered, HIDEGLOVES, 0, H.wear_suit.body_parts_visible_override))
				washshoes = !(is_slot_hidden(H.wear_suit.body_parts_covered, HIDESHOES, 0, H.wear_suit.body_parts_visible_override))

			if(H.head)
				washmask = !(is_slot_hidden(H.head.body_parts_covered, HIDEMASK, 0, H.head.body_parts_visible_override))
				washglasses = !(is_slot_hidden(H.head.body_parts_covered, HIDEEYES, 0, H.head.body_parts_visible_override))
				washears = !(is_slot_hidden(H.head.body_parts_covered, HIDEEARS, 0, H.head.body_parts_visible_override))

			if(H.wear_mask)
				if(washears)
					washears = !(is_slot_hidden(H.wear_mask.body_parts_covered, HIDEEARS, 0, H.wear_mask.body_parts_visible_override))
				if(washglasses)
					washglasses = !(is_slot_hidden(H.wear_mask.body_parts_covered, HIDEEYES, 0, H.wear_mask.body_parts_visible_override))

			if(H.head)
				if(prob(CLEAN_PROB) && H.head.clean_blood())
					H.update_inv_head(0)
			if(H.wear_suit)
				if(prob(CLEAN_PROB) && H.wear_suit.clean_blood())
					H.update_inv_wear_suit(0)
			else if(H.w_uniform)
				if(prob(CLEAN_PROB) && H.w_uniform.clean_blood())
					H.update_inv_w_uniform(0)
			if(H.gloves && washgloves)
				if(prob(CLEAN_PROB) && H.gloves.clean_blood())
					H.update_inv_gloves(0)
			if(H.shoes && washshoes)
				if(prob(CLEAN_PROB) && H.shoes.clean_blood())
					H.update_inv_shoes(0)
			if(H.wear_mask && washmask)
				if(prob(CLEAN_PROB) && H.wear_mask.clean_blood())
					H.update_inv_wear_mask(0)
			if(H.glasses && washglasses)
				if(prob(CLEAN_PROB) && H.glasses.clean_blood())
					H.update_inv_glasses(0)
			if(H.ears && washears)
				if(prob(CLEAN_PROB) && H.ears.clean_blood())
					H.update_inv_ears(0)
			if(H.belt)
				if(prob(CLEAN_PROB) && H.belt.clean_blood())
					H.update_inv_belt(0)
		else
			if(M.wear_mask) //If the mob is not human, it cleans the mask without asking for bitflags
				if(prob(CLEAN_PROB) && M.wear_mask.clean_blood())
					M.update_inv_wear_mask(0)
	else
		if(prob(CLEAN_PROB))
			O.clean_blood()
			if(clean_power)
				O.clean_act(clean_power)

	var/turf/turf = get_turf(src)
	if(prob(CLEAN_PROB))
		turf.clean_blood()
		for(var/obj/effect/E in turf)
			if(istype(E, /obj/effect/rune_legacy) || istype(E, /obj/effect/decal/cleanable) || istype(E, /obj/effect/overlay))
				qdel(E)

/obj/machinery/shower/process()
	if(!on)
		return
	for(var/atom/movable/O in loc)
		if(iscarbon(O))
			var/mob/living/carbon/C = O
			check_heat(C)
		wash(O)
		watersource.reagents.reaction(O, TOUCH)
		if(istype(O, /obj/item/weapon/reagent_containers/glass))
			var/obj/item/weapon/reagent_containers/glass/G = O
			watersource.reagents.trans_to(G, 5)
	watersource.reagents.reaction(get_turf(src), TOUCH)

/obj/machinery/shower/proc/check_heat(mob/living/carbon/C as mob)
	if(!on)
		return

	//Note : Remember process() rechecks this, so the mix/max procs slowly increase/decrease body temperature
	//Every second under the shower adjusts body temperature by 1 degree Celsius. Water conducts heat pretty efficiently in real life too
	if(watertemp == "freezing cold") //Down to -137 degree Celsius, water's glass transition temperature. we don't need cryo tubes where we're going
		C.bodytemperature = max(T0C + coldtemp, C.bodytemperature - 1)
		return
	if(watertemp == "searing hot") //Up to 60 degree Celsius, upper limit for common water boilers. Getting super hot easily in space is hard.
		C.bodytemperature = min(T0C + hottemp, C.bodytemperature + 1)
		return
	if(watertemp == "cool") //Adjusts towards "perfect" body temperature, 37.5 degree Celsius. Actual showers tend to average at 40 degree Celsius, but it's the future
		if(C.bodytemperature > T0C + 37.5) //Cooling down
			C.bodytemperature = max(T0C + 37.5, C.bodytemperature - 1)
			return
		if(C.bodytemperature < T0C + 37.5) //Heating up
			C.bodytemperature = min(T0C + 37.5, C.bodytemperature + 1)
			return

/obj/machinery/shower/npc_tamper_act(mob/living/L)
	attack_hand(L)

/obj/structure/wc/sink
	name = "sink"
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	var/clean_power = CLEANLINESS_SPACECLEANER//Nanotrasen sinks are equipped with state of the art water propulsion for extra cleanliness
	var/busy = 0 	//Something's being washed at the moment

/obj/structure/wc/sink/splashable()
	return FALSE

/obj/structure/wc/sink/attack_hand(mob/M as mob)
	if(isrobot(M) || isAI(M))
		return

	if(..())
		return

	if(!Adjacent(M))
		return

	if(busy)
		to_chat(M, "<span class='warning'>Someone's already washing here.</span>")
		return

	if(!watersource || !watersource.reagents || watersource.reagents.is_empty())
		M.visible_message("<span class='warning'>The tap runs dry! Refuel the reservoir.</span>")
		return 1

	to_chat(usr, "<span class='notice'>You start washing your hands.</span>")

	busy = TRUE
	if (do_after(M,src, 40))
		M.clean_blood()
		M.visible_message("<span class='notice'>[M] washes \his hands using \the [src].</span>","<span class='notice'>You wash your hands using \the [src].</span>")
		if(ishuman(M))
			var/mob/living/carbon/human/HM = M
			HM.update_inv_gloves()
			//normally the below line would handle reagents on hands but this hotcode has to stay because while writing this PR i didn't want to touch acid reaction code again.
			if(HM.species)
				var/flag = (HM.species.anatomy_flags & ACID4WATER) && watersource.reagents.has_reagent(WATER)
				if(watersource.reagents.has_any_reagents(ACIDS))
					flag = !flag
				if(flag)
					if(HM.gloves) //This should make it so any ayy who isn't wearing gloves will get some burns
						to_chat(HM, "<span class='warning'>Your gloves block direct contact with the [watersource.reagents.get_master_reagent_name()].</span>")
					else
						to_chat(HM, "<span class='warning'>The [watersource.reagents.get_master_reagent_name()] burns your hands!</span>")
						HM.adjustFireLossByPart(rand(5, 10), LIMB_LEFT_HAND, src)
						HM.adjustFireLossByPart(rand(5, 10), LIMB_RIGHT_HAND, src)
					busy = FALSE
					return
		watersource.reagents.reaction(M, TOUCH, zone_sels = list(LIMB_LEFT_HAND,LIMB_RIGHT_HAND))
	busy = FALSE

/obj/structure/wc/sink/mop_act(obj/item/weapon/mop/M, mob/user)
	if(busy)
		return 1
	if(!watersource || watersource.reagents.is_empty())
		user.visible_message("<span class='warning'>The tap runs dry! Refuel the reservoir.</span>")
		return 1
	user.visible_message("<span class='notice'>[user] puts \the [M] underneath the running [watersource.reagents.get_master_reagent_name()].","<span class='notice'>You put \the [M] underneath the running [watersource.reagents.get_master_reagent_name()].</span>")
	busy = TRUE
	if (do_after(user,src, 40))
		M.clean_blood()
		if(watersource && !watersource.reagents.is_empty())
			watersource.reagents.reaction(M, TOUCH)
		if(M)
			if(M.reagents.maximum_volume > M.reagents.total_volume)
				playsound(src, 'sound/effects/slosh.ogg', 25, 1)
				watersource.reagents.trans_to(src, min(M.reagents.maximum_volume - M.reagents.total_volume, 50))
				user.visible_message("<span class='notice'>[user] finishes soaking \the [M], \he could clean the entire station with that.</span>","<span class='notice'>You finish soaking \the [M], you feel as if you could clean anything now, even the Chef's backroom...</span>")
			else
				user.visible_message("<span class='notice'>[user] removes \the [M], cleaner than before.</span>","<span class='notice'>You remove \the [M] from \the [src], it's all nice and sparkly now but somehow didnt get it any wetter.</span>")
	busy = FALSE
	return 1

/obj/structure/wc/sink/attackby(obj/item/O as obj, mob/user as mob)
	if(busy)
		to_chat(user, "<span class='warning'>Someone's already washing here.</span>")
		return

	if(..())
		return 1

	if(istype(O, /obj/item/weapon/mop) || istype(O, /obj/item/toy/waterballoon))
		return

	if(!watersource || watersource.reagents.is_empty())
		user.visible_message("<span class='warning'>The tap runs dry! Refuel the reservoir.</span>")
		return

	if (istype(O, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/RG = O
		if(RG.reagents.total_volume >= RG.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>\The [RG] is full.</span>")
			return
		if (istype(RG, /obj/item/weapon/reagent_containers/chempack)) //Chempack can't use amount_per_transfer_from_this, so it needs its own if statement.
			var/obj/item/weapon/reagent_containers/chempack/C = RG
			watersource.reagents.trans_to(C, C.fill_amount)
		else
			watersource.reagents.trans_to(RG, RG.amount_per_transfer_from_this)
		user.visible_message("<span class='notice'>[user] fills \the [RG] using \the [src].</span>","<span class='notice'>You fill the [RG] using \the [src].</span>")
		return

	if (istype(O, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = O
		if (B.bcell && B.bcell.charge > 0 && B.status == 1)
			flick("baton_active", src)
			user.Stun(10)
			user.stuttering = 10
			user.Knockdown(10)
			if(isrobot(user))
				use_cell_charge(user,20)
			else
				B.deductcharge(1)
			user.visible_message( \
				"<span class='warning'>[user] was stunned by \his wet [O.name]!</span>", \
				"<span class='warning'>You have wet \the [O.name], it shocks you!</span>")
			return

	else if (istype(O, /obj/item/weapon/pen/fountain))
		..()
		var/obj/item/weapon/pen/fountain/P = O
		if (P.bloodied)
			to_chat(user, "<span class='notice'>You clean the blood out of the nib of \the [P].</span>")
			P.colour = "black"
			P.bloodied = FALSE

	else if(istype(O, /obj/item/stack/sheet/hairlesshide))
		var/obj/item/stack/sheet/hairlesshide/H = O
		user.visible_message("<span class='notice'>[user] puts \the [H] underneath the running [watersource.reagents.get_master_reagent_name()] and begins soaking it.","<span class='notice'>You put \the [H] underneath the running [watersource.reagents.get_master_reagent_name()] and begin soaking it.</span>")
		busy = TRUE
		if (do_after(user, src, 10*H.amount))
			var/obj/item/stack/sheet/wetleather/WL = new(src)
			WL.amount = H.amount
			WL.source_string = H.source_string
			WL.name = H.source_string ? "wet [H.source_string] leather" : "wet leather"
			user.create_in_hands(H, WL, msg = "<span class='notice'>You finish up, creating [WL].</span>")
			QDEL_NULL(H)
		else
			to_chat(user, "<span class='notice'>You stop soaking \the [H].</span>")
		busy = FALSE
		return

	if (!isturf(user.loc))
		return

	if (isitem(O))
		to_chat(user, "<span class='notice'>You start washing \the [O].</span>")
		busy = TRUE

		if (do_after(user,src, 40))
			user.visible_message( \
				"<span class='notice'>[user] washes \the [O] using \the [src].</span>", \
				"<span class='notice'>You wash \the [O] using \the [src].</span>")
			if(clean_power)
				O.clean_act(clean_power)//removes blood, unglues, etc
			else
				O.clean_blood()
			if(watersource && !watersource.reagents.is_empty())
				watersource.reagents.reaction(O, TOUCH)
			..()

		busy = FALSE

/obj/structure/wc/sink/npc_tamper_act(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/gremlin))
		visible_message("<span class='danger'>\The [L] climbs into \the [src] and turns the faucet on!</span>")

		var/mob/living/simple_animal/hostile/gremlin/G = L
		G.divide()

	return NPC_TAMPER_ACT_NOMSG

/obj/structure/wc/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"


/obj/structure/wc/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	icon_state = "puddle"
	desc = "You can see your reflection! You look awful!"

/obj/structure/wc/sink/puddle/attack_hand(mob/M as mob)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

/obj/structure/wc/sink/puddle/attackby(obj/item/O as obj, mob/user as mob)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

//TODO: Remove this and replace them with when stations get water plumbing, if ever.
/obj/item/reagent_core
	name = "water core"
	desc = "Anomalous bluespace device that provides water to plumbing sources."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "reagentcore"
	w_class = W_CLASS_TINY
	origin_tech = Tc_BLUESPACE + "=1" //just so mechanics can make more of these and replace em
	var/reagent_filled = WATER

/obj/item/reagent_core/New()
	. = ..()
	create_reagents(200) //pretty heavy duty
	reagents.add_reagent(reagent_filled,200)
	processing_objects += src
	update_icon()

/obj/item/reagent_core/update_icon()
	overlays.len = 0
	var/image/over = image(icon,src,"reagentcore_overlay")
	var/datum/reagent/R = chemical_reagents_list[reagent_filled]
	if(R)
		over.color = R.color
	overlays += over

/obj/item/reagent_core/Destroy()
	processing_objects -= src
	. = ..()

/obj/item/reagent_core/process()
	if(reagents.total_volume < reagents.maximum_volume)
		reagents.add_reagent(reagent_filled,reagents.maximum_volume-reagents.total_volume)

/obj/item/reagent_core/acid
	name = "acid core"
	desc = "Anomalous bluespace device that provides sulphuric acid to plumbing sources."
	reagent_filled = SACID

/obj/item/reagent_core/admin/attack_self(mob/user)
	. = ..()
	if(user.check_rights(R_ADMIN))
		reagent_filled = input(user,"Type a reagent ID for this thing to regenerate","Reagent ID on refill",WATER) as text
		if(reagent_filled && reagent_filled != "")
			reagents.clear_reagents()
			if(reagents.add_reagent(reagent_filled, reagents.maximum_volume, admin = user))
				to_chat(user, "<span class='warning'>[reagent_filled] doesn't exist.</span>")
				return
			var/datum/reagent/R = chemical_reagents_list[reagent_filled]
			if(R)
				name = "[R.name] core"
				desc = "Anomalous bluespace device that provides [R.name] to plumbing sources."
			update_icon()
