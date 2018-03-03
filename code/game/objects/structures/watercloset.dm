//todo: toothbrushes, and some sort of "toilet-filthinator" for the hos
#define NORODS 0
#define RODSADDED 1

/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = 0
	anchored = 1
	var/state = 0			//1 if rods added; 0 if not
	var/open = 0			//if the lid is up
	var/cistern = 0			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie

/obj/structure/toilet/New()
	. = ..()
	open = round(rand(0, 1))
	update_icon()

/obj/structure/toilet/verb/empty_container_into()
	set name = "Empty container into"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return
	if(!open)
		to_chat(usr, "<span class='warning'>\The [src] is closed!</span>")
		return
	var/obj/item/weapon/reagent_containers/container = usr.get_active_hand()
	if(!istype(container))
		to_chat(usr, "<span class='warning'>You need a reagent container in your active hand to do that.</span>")
		return
	return container.drain_into(usr, src)

/obj/structure/toilet/AltClick()
	if(Adjacent(usr))
		return empty_container_into()
	return ..()
/obj/structure/toilet/attack_hand(mob/living/user as mob)
	if(swirlie)
		usr.visible_message("<span class='danger'>[user] slams the toilet seat onto [swirlie.name]'s head!</span>", "<span class='notice'>You slam the toilet seat onto [swirlie.name]'s head!</span>", "You hear reverberating porcelain.")
		swirlie.adjustBruteLoss(8)
		return

	if(cistern && !open)
		if(!contents.len)
			to_chat(user, "<span class='notice'>The cistern is empty.</span>")
			return
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.put_in_hands(I)
			else
				I.forceMove(get_turf(src))
			to_chat(user, "<span class='notice'>You find \an [I] in the cistern.</span>")
			w_items -= I.w_class
			return

	open = !open
	update_icon()

/obj/structure/toilet/update_icon()
	icon_state = "toilet[open][cistern]"

/obj/structure/toilet/attackby(obj/item/I as obj, mob/living/user as mob)
	if(iswrench(I))
		to_chat(user, "<span class='notice'>You [anchored ? "un":""]bolt \the [src]'s grounding lines.</span>")
		anchored = !anchored
	if(anchored == 0)
		return
	if(open && cistern && state == NORODS && istype(I,/obj/item/stack/rods)) //State = 0 if no rods
		var/obj/item/stack/rods/R = I
		if(R.amount < 2)
			return
		to_chat(user, "<span class='notice'>You add the rods to the toilet, creating flood avenues.</span>")
		R.use(2)
		state = RODSADDED //State 0 -> 1
		return
	if(open && cistern && state == RODSADDED && istype(I,/obj/item/weapon/paper)) //State = 1 if rods are added
		to_chat(user, "<span class='notice'>You create a filter with the paper and insert it.</span>")
		var/obj/structure/centrifuge/C = new /obj/structure/centrifuge(src.loc)
		C.dir = src.dir
		qdel(I)
		qdel(src)
		return
	if(iscrowbar(I))
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
				if(!GM.loc == get_turf(src))
					to_chat(user, "<span class='notice'>[GM.name] needs to be on the toilet.</span>")
					return
				if(open && !swirlie)
					user.visible_message("<span class='danger'>[user] starts to give [GM.name] a swirlie!</span>", "<span class='notice'>You start to give [GM.name] a swirlie!</span>")
					swirlie = GM
					if(do_after(user, 30, 5, 0))
						user.visible_message("<span class='danger'>[user] gives [GM.name] a swirlie!</span>", "<span class='notice'>You give [GM.name] a swirlie!</span>", "You hear a toilet flushing.")
						if(!GM.internal)
							GM.adjustOxyLoss(5)
					swirlie = null
				else
					user.visible_message("<span class='danger'>[user] slams [GM.name] into the [src]!</span>", "<span class='notice'>You slam [GM.name] into the [src]!</span>")
					GM.adjustBruteLoss(8)
			else
				to_chat(user, "<span class='notice'>You need a tighter grip.</span>")

	if(cistern)
		if(I.w_class > W_CLASS_MEDIUM)
			to_chat(user, "<span class='notice'>\The [I] does not fit.</span>")
			return
		if(w_items + I.w_class > W_CLASS_HUGE)
			to_chat(user, "<span class='notice'>The cistern is full.</span>")
			return
		if(user.drop_item(I, src))
			w_items += I.w_class
			to_chat(user, "You carefully place \the [I] into the cistern.")
			return

/obj/structure/toilet/bite_act(mob/user)
	user.simple_message("<span class='notice'>That would be disgusting.</span>", "<span class='info'>You're not high enough for that... Yet.</span>") //Second message 4 hallucinations

/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = 0
	anchored = 1

/obj/structure/urinal/verb/empty_container_into()
	set name = "Empty container into"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return
	var/obj/item/weapon/reagent_containers/container = usr.get_active_hand()
	if(!istype(container))
		to_chat(usr, "<span class='warning'>You need a reagent container in your active hand to do that.</span>")
		return
	return container.drain_into(usr, src)

/obj/structure/urinal/AltClick()
	if(Adjacent(usr))
		return empty_container_into()
	return ..()

/obj/structure/urinal/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(G.state>1)
				if(!GM.loc == get_turf(src))
					to_chat(user, "<span class='notice'>[GM.name] needs to be on the urinal.</span>")
					return
				user.visible_message("<span class='danger'>[user] slams [GM.name] into the [src]!</span>", "<span class='notice'>You slam [GM.name] into the [src]!</span>")
				GM.adjustBruteLoss(8)
			else
				to_chat(user, "<span class='notice'>You need a tighter grip.</span>")

/obj/structure/urinal/bite_act(mob/user)
	user.simple_message("<span class='notice'>That would be disgusting.</span>", "<span class='info'>You're not high enough for that... Yet.</span>") //Second message 4 hallucinations

/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	icon_state_open = "shower_t"
	density = 0
	anchored = 1
	use_power = 0
	var/on = 0
	var/obj/effect/mist/mymist = null
	var/ismist = 0 //Needs a var so we can make it linger~
	var/watertemp = "cool" //Freezing, normal, or boiling
	var/obj/item/weapon/reagent_containers/glass/beaker/water/watersource = null

	machine_flags = SCREWTOGGLE

	ghost_read = 0
	ghost_write = 0

/obj/machinery/shower/New() //Our showers actually wet people and floors now
	..()
	watersource = new /obj/item/weapon/reagent_containers/glass/beaker/water()

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
		to_chat(M, "<span class='warning'>\The [src] needs to be bolted to the floor to work.</span>")
		return

	on = !on
	M.visible_message("<span class='notice'>[M] turns \the [src] [on ? "on":"off"]</span>", \
					  "<span class='notice'>You turn \the [src] [on ? "on":"off"]</span>")
	update_icon()
	if(on)
		for(var/atom/movable/G in get_turf(src))
			G.clean_blood()

/obj/machinery/shower/attackby(obj/item/I as obj, mob/user as mob)

	..()

	if(I.type == /obj/item/device/analyzer)
		to_chat(user, "<span class='notice'>The water's temperature seems to be [watertemp].</span>")
	if(panel_open) //The panel is open
		if(iswrench(I))
			user.visible_message("<span class='warning'>[user] starts adjusting the bolts on \the [src].</span>", \
								 "<span class='notice'>You start adjusting the bolts on \the [src].</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 100, 1)
			if(do_after(user, src, 50))
				if(anchored == 1)
					src.visible_message("<span class='warning'>[user] unbolts \the [src] from the floor.</span>", \
								 "<span class='notice'>You unbolt \the [src] from the floor.</span>")
					anchored = 0
				else
					src.visible_message("<span class='warning'>[user] bolts \the [src] to the floor.</span>", \
								 "<span class='notice'>You bolt \the [src] to the floor.</span>")
					anchored = 1
	else
		if(iswrench(I))
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
				user.visible_message("<span class='warning'>[user] adjusts \the [src]'s temperature with \a [I.name].</span>",
				"<span class='notice'>You adjust \the [src]'s temperature with \a [I.name], the water is now [watertemp].</span>")
				add_fingerprint(user)

/obj/machinery/shower/update_icon()	//This is terribly unreadable, but basically it makes the shower mist up
	overlays.len = 0 //Once it's been on for a while, in addition to handling the water overlay.
	if(mymist)
		returnToPool(mymist)
		mymist = null

	if(on)
		var/image/water = image('icons/obj/watercloset.dmi', src, "water", BELOW_OBJ_LAYER, dir)
		water.plane = ABOVE_HUMAN_PLANE
		overlays += water
		if(watertemp == "freezing") //No mist if the water is really cold
			return
		if(!ismist)
			spawn(50)
				if(src && on)
					ismist = 1
					mymist = getFromPool(/obj/effect/mist, get_turf(src))
		else
			ismist = 1
			mymist = getFromPool(/obj/effect/mist, get_turf(src))
	else if(ismist)
		ismist = 1
		mymist = getFromPool(/obj/effect/mist, get_turf(src))
		spawn(250)
			if(src && !on)
				returnToPool(mymist)
				mymist = null
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
		for(var/obj/item/I in M.held_items)
			if(prob(CLEAN_PROB))
				I.clean_blood()
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
				washgloves = !(is_slot_hidden(H.wear_suit.body_parts_covered, HIDEGLOVES))
				washshoes = !(is_slot_hidden(H.wear_suit.body_parts_covered, HIDESHOES))

			if(H.head)
				washmask = !(is_slot_hidden(H.head.body_parts_covered, HIDEMASK))
				washglasses = !(is_slot_hidden(H.head.body_parts_covered, HIDEEYES))
				washears = !(is_slot_hidden(H.head.body_parts_covered, HIDEEARS))

			if(H.wear_mask)
				if(washears)
					washears = !(is_slot_hidden(H.wear_mask.body_parts_covered, HIDEEARS))
				if(washglasses)
					washglasses = !(is_slot_hidden(H.wear_mask.body_parts_covered, HIDEEYES))

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

	var/turf/turf = get_turf(src)
	if(prob(CLEAN_PROB))
		turf.clean_blood()
		for(var/obj/effect/E in turf)
			if(istype(E, /obj/effect/rune) || istype(E, /obj/effect/decal/cleanable) || istype(E, /obj/effect/overlay))
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
			G.reagents.add_reagent(WATER, 5)
	watersource.reagents.reaction(get_turf(src), TOUCH)

/obj/machinery/shower/proc/check_heat(mob/living/carbon/C as mob)
	if(!on)
		return

	//Note : Remember process() rechecks this, so the mix/max procs slowly increase/decrease body temperature
	//Every second under the shower adjusts body temperature by 0.5 degree Celsius. Water conducts heat pretty efficiently in real life too
	if(watertemp == "freezing cold") //Down to 0 degree Celsius, Nanotrasen waterworks are perfect and never fluctuate even slightly below that
		C.bodytemperature = max(T0C, C.bodytemperature - 0.5)
		return
	if(watertemp == "searing hot") //Up to 60 degree Celsius, upper limit for common water boilers
		C.bodytemperature = min(T0C + 60, C.bodytemperature + 0.5)
		return
	if(watertemp == "cool") //Adjusts towards "perfect" body temperature, 37.5 degree Celsius. Actual showers tend to average at 40 degree Celsius, but it's the future
		if(C.bodytemperature > T0C + 37.5) //Cooling down
			C.bodytemperature = max(T0C + 37.5, C.bodytemperature - 0.5)
			return
		if(C.bodytemperature < T0C + 37.5) //Heating up
			C.bodytemperature = min(T0C + 37.5, C.bodytemperature + 0.5)
			return

/obj/machinery/shower/npc_tamper_act(mob/living/L)
	attack_hand(L)

/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = 1
	var/busy = 0 	//Something's being washed at the moment

/obj/structure/sink/verb/empty_container_into()
	set name = "Empty container into"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return
	var/obj/item/weapon/reagent_containers/container = usr.get_active_hand()
	if(!istype(container))
		to_chat(usr, "<span class='warning'>You need a reagent container in your active hand to do that.</span>")
		return
	return container.drain_into(usr, src)

/obj/structure/sink/AltClick()
	if(Adjacent(usr))
		return empty_container_into()
	return ..()

/obj/structure/sink/attack_hand(mob/M as mob)
	if(isrobot(M) || isAI(M))
		return

	if(!Adjacent(M))
		return

	if(anchored == 0)
		return

	if(busy)
		to_chat(M, "<span class='warning'>Someone's already washing here.</span>")
		return

	to_chat(usr, "<span class='notice'>You start washing your hands.</span>")

	busy = 1
	sleep(40)
	busy = 0

	if(!Adjacent(M))
		return		//Person has moved away from the sink

	M.clean_blood()
	if(ishuman(M))
		M:update_inv_gloves()
	for(var/mob/V in viewers(src, null))
		V.show_message("<span class='notice'>[M] washes their hands using \the [src].</span>")

/obj/structure/sink/mop_act(obj/item/weapon/mop/M, mob/user)
	if(busy)
		return 1
	user.visible_message("<span class='notice'>[user] puts \the [M] underneath the running water.","<span class='notice'>You put \the [M] underneath the running water.</span>")
	busy = 1
	sleep(40)
	busy = 0
	M.clean_blood()
	if(M.reagents.maximum_volume > M.reagents.total_volume)
		playsound(src, 'sound/effects/slosh.ogg', 25, 1)
		M.reagents.add_reagent(WATER, min(M.reagents.maximum_volume - M.reagents.total_volume, 50))
		user.visible_message("<span class='notice'>[user] finishes soaking \the [M], \he could clean the entire station with that.</span>","<span class='notice'>You finish soaking \the [M], you feel as if you could clean anything now, even the Chef's backroom...</span>")
	else
		user.visible_message("<span class='notice'>[user] removes \the [M], cleaner than before.</span>","<span class='notice'>You remove \the [M] from \the [src], it's all nice and sparkly now but somehow didnt get it any wetter.</span>")
	return 1

/obj/structure/sink/attackby(obj/item/O as obj, mob/user as mob)
	if(busy)
		to_chat(user, "<span class='warning'>Someone's already washing here.</span>")
		return

	if(iswrench(O))
		to_chat(user, "<span class='notice'>You [anchored ? "un":""]bolt \the [src]'s grounding lines.</span>")
		anchored = !anchored
	if(anchored == 0)
		return

	if(istype(O, /obj/item/weapon/mop))
		return

	if (istype(O, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/RG = O
		if(RG.reagents.total_volume >= RG.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>\The [RG] is full.</span>")
			return
		if (istype(RG, /obj/item/weapon/reagent_containers/chempack)) //Chempack can't use amount_per_transfer_from_this, so it needs its own if statement.
			var/obj/item/weapon/reagent_containers/chempack/C = RG
			C.reagents.add_reagent(WATER, C.fill_amount)
		else
			RG.reagents.add_reagent(WATER, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		user.visible_message("<span class='notice'>[user] fills \the [RG] using \the [src].</span>","<span class='notice'>You fill the [RG] using \the [src].</span>")
		return

	else if (istype(O, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = O
		if (B.bcell && B.bcell.charge > 0 && B.status == 1)
			flick("baton_active", src)
			user.Stun(10)
			user.stuttering = 10
			user.Knockdown(10)
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.charge -= 20
			else
				B.deductcharge(1)
			user.visible_message( \
				"<span class='warning'>[user] was stunned by \his wet [O.name]!</span>", \
				"<span class='warning'>You have wet \the [O.name], it shocks you!</span>")
			return

	if (!isturf(user.loc))
		return

	if (isitem(O))
		to_chat(user, "<span class='notice'>You start washing \the [O].</span>")
		busy = TRUE

		if (do_after(user,src, 40))
			O.clean_blood()
			user.visible_message( \
				"<span class='notice'>[user] washes \a [O] using \the [src].</span>", \
				"<span class='notice'>You wash \a [O] using \the [src].</span>")

		busy = FALSE

/obj/structure/sink/npc_tamper_act(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/gremlin))
		visible_message("<span class='danger'>\The [L] climbs into \the [src] and turns the faucet on!</span>")

		var/mob/living/simple_animal/hostile/gremlin/G = L
		G.divide()

	return NPC_TAMPER_ACT_NOMSG

/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"


/obj/structure/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	icon_state = "puddle"
	desc = "You can see your reflection! You look awful!"

/obj/structure/sink/puddle/attack_hand(mob/M as mob)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

/obj/structure/sink/puddle/attackby(obj/item/O as obj, mob/user as mob)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"
