var/global/list/lemuria_stuff = list(
	//3 of a kind
	/obj/item/weapon/fakeposter_kit, /obj/item/weapon/fakeposter_kit, /obj/item/weapon/fakeposter_kit,
	//2 of a kind
	/obj/item/weapon/storage/bag/gibtonite,/obj/item/weapon/storage/bag/gibtonite,
    /obj/item/device/digsite_depressor_modkit,/obj/item/device/digsite_depressor_modkit,
	//1 of a kind
	/obj/item/weapon/quantumroutingcomputer,
	/obj/item/weapon/disk/shuttle_coords/vault/mecha_graveyard,
	/obj/item/goliath_lure,
	/obj/item/cosmic_grill/preloaded
)
/obj/structure/closet/crate/lemuria
	name = "Lost Crate of Lemuria"
	desc = "Famously, Space Lemuria was once a sacred warehouse-planet among Cargo peoples, and the holiest city in the Cargo Cult. It was lost, along with most of its crates. Why has this one resurfaced now...? What does it mean?"

/obj/structure/closet/crate/lemuria/New()
	..()
	for(var/i = 1 to 5)
		if(!shoal_stuff.len)
			return
		var/path = pick_n_take(lemuria_stuff)
		new path(src)

/obj/item/weapon/quantumroutingcomputer
    name = "quantum routing gcomputer"
    desc = "A quantum supercomputer uses q-bits to perform very large calculations. This one can reduce shipping times dramatically by calculating the most efficient use of gravity wells along a route."
    inhand_states = list("left_hand" = 'icons/mob/in-hand/left/boxes_and_storage.dmi', "right_hand" = 'icons/mob/in-hand/right/boxes_and_storage.dmi')
    icon = 'icons/obj/storage/smallboxes.dmi'
    icon_state = "box_of_doom"
    item_state = "box_of_doom"

/obj/item/weapon/quantumroutingcomputer/preattack(var/atom/A, var/mob/user, proximity_flag)
	if(proximity_flag != 1)
		return
	if(istype(A,/obj/machinery/computer/supplycomp))
		visible_message("<span class='good'>You add \the [src] to \the [A]. It sets to work calculating a faster route.</span>")
		SSsupply_shuttle.movetime /= 2
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		qdel(src)

/area/vault/mecha_graveyard

/obj/item/weapon/disk/shuttle_coords/vault/mecha_graveyard
	name = "Coordinates to the Mecha Graveyard"
	desc = "Here lay the dead steel of lost mechas, so says some gypsy."
	destination = /obj/docking_port/destination/vault/mecha_graveyard

/obj/docking_port/destination/vault/mecha_graveyard
	areaname = "mecha graveyard"

/datum/map_element/dungeon/mecha_graveyard
	file_path = "maps/randomvaults/dungeons/mecha_graveyard.dmm"
	unique = TRUE

/obj/effect/decal/mecha_wreckage/graveyard_ripley
	name = "Ripley wreckage"
	desc = "Surprisingly well preserved."
	icon_state = "ripley-broken"

/obj/effect/decal/mecha_wreckage/graveyard_ripley/New()
	..()
	var/list/parts = list(/obj/item/mecha_parts/part/ripley_torso,
								/obj/item/mecha_parts/part/ripley_left_arm,
								/obj/item/mecha_parts/part/ripley_right_arm,
								/obj/item/mecha_parts/part/ripley_left_leg,
								/obj/item/mecha_parts/part/ripley_right_leg)
	welder_salvage += parts

	if(prob(80))
		add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/drill,100)
	else
		add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/jetpack,100)

/obj/effect/decal/mecha_wreckage/graveyard_clarke
	name = "Clarke wreckage"
	desc = "Surprisingly well preserved."
	icon_state = "clarke-broken"

/obj/effect/decal/mecha_wreckage/graveyard_clarke/New()
	..()
	var/list/parts = list(
								/obj/item/mecha_parts/part/clarke_torso,
								/obj/item/mecha_parts/part/clarke_head,
								/obj/item/mecha_parts/part/clarke_left_arm,
								/obj/item/mecha_parts/part/clarke_right_arm,
								/obj/item/mecha_parts/part/clarke_left_tread,
								/obj/item/mecha_parts/part/clarke_right_tread)
	welder_salvage += parts

	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/collector,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/tiler,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/switchtool,100)

/obj/item/weapon/fakeposter_kit
	name = "cargo cache kit"
	desc = "Used to create a hidden cache behind what appears to be a cargo poster."
	icon = 'icons/obj/barricade.dmi'
	icon_state = "barricade_kit"
	w_class = W_CLASS_MEDIUM
	w_type = RECYK_WOOD
	flammable = TRUE

/obj/item/weapon/fakeposter_kit/preattack(atom/target, mob/user , proximity)
	if(!proximity)
		return
	if(istype(target,/turf/simulated/wall))
		playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
		if(do_after(user,target,4 SECONDS))
			to_chat(user,"<span class='notice'>Using the kit, you hollow out the wall and hang the poster in front.</span>")
			var/obj/structure/fakecargoposter/FCP = new(target)
			FCP.access_loc = get_turf(user)
			qdel(src)
			return 1
	else
		return ..()

/obj/structure/fakecargoposter
	icon = 'icons/obj/posters.dmi'
	var/obj/item/weapon/storage/cargocache/cash
	var/turf/access_loc

/obj/structure/fakecargoposter/New()
	..()
	var/datum/poster/type = pick(/datum/poster/special/cargoflag,/datum/poster/special/cargofull)
	icon_state = initial(type.icon_state)
	desc = initial(type.desc)
	name = initial(type.name)
	cash = new(src)

/obj/structure/fakecargoposter/examine(mob/user)
	..()
	if(user.loc == access_loc)
		to_chat(user, "<span class='info'>Upon closer inspection, there's a hidden cache behind it accessible with a free hand.</span>")

/obj/structure/fakecargoposter/Destroy()
	for(var/atom/movable/A in cash.contents)
		A.forceMove(loc)
	QDEL_NULL(cash)
	..()

/obj/structure/fakecargoposter/attackby(var/obj/item/weapon/W, mob/user)
	if(iswelder(W))
		visible_message("<span class='warning'>[user] is destroying the hidden cache disguised as a poster!</span>")
		var/obj/item/tool/weldingtool/WT=W
		if(WT.do_weld(user, src, 10 SECONDS, 5))
			visible_message("<span class='warning'>[user] destroyed the hidden cache!</span>")
			qdel(src)
	else if(user.loc == access_loc)
		cash.attackby(W,user)
	else
		..()

/obj/structure/fakecargoposter/attack_hand(mob/user)
	if(user.loc == access_loc)
		cash.AltClick(user)

/obj/item/weapon/storage/cargocache
	name = "cargo cache"
	desc = "A large hidey hole for all your goodies."
	icon = 'icons/obj/posters.dmi'
	icon_state = "cargoposter-flag"
	fits_max_w_class = W_CLASS_LARGE
	max_combined_w_class = 28
	slot_flags = 0

/obj/item/weapon/storage/cargocache/distance_interact(mob/user)
	if(istype(loc,/obj/structure/fakecargoposter) && user.Adjacent(loc))
		return TRUE
	return FALSE

/obj/item/weapon/storage/bag/gibtonite
	name = "gibtonite satchel"
	desc = "A satchel specifically designed for the transport of gibtonite. It has deep, padded pockets to keep it safe. The gibtonite needs to be disarmed first, of course."
	can_only_hold = list("/obj/item/weapon/gibtonite")
	fits_max_w_class = W_CLASS_LARGE
	icon_state = "satchel-eng"
	item_state = "engiepack"

/obj/item/weapon/storage/bag/gibtonite/can_be_inserted(obj/item/W, stop_messages = 0)
	if(!..())
		return FALSE
	var/obj/item/weapon/gibtonite/G = W
	if(istype(G) && !G.primed)
		return TRUE

/obj/item/goliath_lure
	name = "goliath lure"
	desc = "Goliaths have a sophisticated set of eyes that can see infrared. This emits beams that will attract goliaths. After placing it on the ground, wrench it into place. Use meat on the lure to create bait."
	var/pity = 0
	icon = 'icons/obj/barricade.dmi'
	icon_state = "barricade_kit"
	w_class = W_CLASS_LARGE

/obj/item/goliath_lure/attackby(obj/item/I, mob/user)
	if(I.is_wrench() && do_after(user, src, 2 SECONDS))
		if(!istype(loc,/turf/unsimulated/floor/asteroid))
			to_chat(user, "<span class='warning'>\The [src] won't sink into anything but the soft sand of the asteroid.</span>")
			return
		anchored = !anchored
		if(anchored)
			to_chat(user, "<span class='warning'>\The [src] thrums with activity after being anchored. It is running.</span>")
			processing_objects += src
		else
			to_chat(user, "<span class='warning'>\The [src] stills as you unanchor it.</span>")
			processing_objects -= src
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/meat))
		to_chat(user, "<span class='notice'>You create some bait at the base of \the [src].</span>")
		new /mob/living/simple_animal/bait(loc)
		qdel(I)

/obj/item/goliath_lure/Destroy()
	processing_objects -= src
	..()

/obj/item/goliath_lure/process()
	if(!anchored)
		processing_objects -= src
		return
	pity++
	if(prob(pity) && isturf(loc))
		pity = 0
		create_goliath()


/obj/item/goliath_lure/proc/create_goliath()
	var/turf/target_ground
	var/list/mid_search_group = orange(7,src)
	var/list/far_grounds = orange(12,src) - mid_search_group
	var/list/near_grounds = orange(3,src)
	//Create 3 oranges: 8 to 12, 4 to 7, and 1 to 3. Prefer the furthest.
	//Needs to not be a space or dense turf, must have a valid path to the lure.

	target_ground = check_turfs(shuffle(far_grounds)) //shuffle is necessary or else the goliath will always approach from the same direction

	if(!target_ground)
		var/list/mid_grounds = mid_search_group - near_grounds
		target_ground = check_turfs(shuffle(mid_grounds))

	if(!target_ground)
		target_ground = check_turfs(shuffle(near_grounds))

	if(!target_ground)
		log_debug("Goliath lure could not find a spawn position.")
		return
	var/mob/living/simple_animal/hostile/asteroid/goliath/G = new (target_ground)
	G.shake(1,3)
	var/mob/bait = locate(/mob/living/simple_animal/bait) in view(2,loc)
	if(bait)
		G.GiveTarget(bait)
	else
		G.Goto(target_ground,G.move_to_delay,G.idle_vision_range) //Move toward the lure, but stop at idle vision range

/obj/item/goliath_lure/proc/check_turfs(var/list/grounds)
	for(var/turf/T in grounds)
		if(!istype(T,/turf/unsimulated/floor/asteroid))
			continue
		if(T.density)
			continue
		if(locate(/mob) in T)
			continue
		if(!pathfind(T,loc))
			continue
		return T

//Extremely primative pathfinding, only looks for a straight line
/obj/item/goliath_lure/proc/pathfind(turf/A, turf/B)
	var/turf/T = A
	for(var/i = 1 to 12) //max range is 12
		var/turf/Tx = get_step_towards(T, B) //Step toward B
		if(Tx == B)
			return TRUE
		if(Tx.density)
			return FALSE
		for(var/obj/O in T)
			if(O.density)
				return FALSE
		T = Tx

/mob/living/simple_animal/bait
    name = "bait"
    desc = "This is bait. There isn't even a hook in this one!"
    icon = 'icons/effects/blood.dmi'
    icon_state = "gib2-old"
    icon_living = "gib2-old"
    pass_flags = PASSTABLE
    maxHealth = 1
    health = 1
    response_help  = "adjusts"
    response_disarm = "prods"
    response_harm   = "beats"
    faction = "neutral"
    density = 0
    minbodytemp = 0
    maxbodytemp = INFINITY
    min_oxy = 0
    max_oxy = 0
    min_tox = 0
    max_tox = 0
    min_co2 = 0
    max_co2 = 0
    min_n2 = 0
    max_n2 = 0
    treadmill_speed = 0
    wander = 0
    size = SIZE_TINY

/mob/living/simple_animal/bait/death(gibbed)
	..(TRUE)
	qdel(src)

/mob/living/simple_animal/bait/can_be_pulled(mob/user)
	return FALSE

/obj/item/cosmic_grill
	name = "cosmic grill"
	desc = "A grilltop that uses stellar radiation to cook meals: just float it in space and the pan will heat up! This is the go-to for the miner that wants to cook some asteroid cuisine."
	is_cooktop = TRUE
	icon = 'icons/obj/items_weird.dmi'
	icon_state = "cosmicgrill0"
	w_class = W_CLASS_MEDIUM

/obj/item/cosmic_grill/update_icon()
    icon_state = "cosmicgrill[!isnull(cookvessel)]"
    render_cookvessel()

/obj/item/cosmic_grill/on_cook_start()
	icon_state = "cosmicgrill1"

/obj/item/cosmic_grill/on_cook_stop()
	icon_state = "cosmicgrill0"

/obj/item/cosmic_grill/can_cook()
	return istype(loc, /turf/space)

/obj/item/cosmic_grill/render_cookvessel(offset_x, offset_y)
	overlays.len = 0
	..()

/obj/item/cosmic_grill/preloaded/New()
    ..()
    cookvessel = new /obj/item/weapon/reagent_containers/pan(src)
    update_icon()

/obj/item/device/digsite_depressor_modkit
	name = "digsite depressor modification kit"
	desc = "A kit containing all the needed tools and parts to make mining drills shove archaeological digsites into the ground beneath."
	icon_state = "modkit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	origin_tech = Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=2"
	toolsounds = list('sound/items/Screwdriver.ogg')

/obj/item/weapon/pickaxe
    var/depresses_digsites = FALSE
    
/obj/item/weapon/pickaxe/examine(mob/user, size, show_name)
    . = ..()
    if(depresses_digsites)
        to_chat(user, "<span class='notice'>\The [src] can depress digsites into the ground when drilling them.</span>")

/obj/item/device/digsite_depressor_modkit/afterattack(obj/O, mob/user as mob)
    if(!istype(O,/obj/item/weapon/pickaxe/drill))
        to_chat(user, "<span class='notice'>This only works on mining drills.</span>")
        return
    if(!isturf(O.loc))
        to_chat(user, "<span class='warning'>\The [O] must be safely placed on the ground for modification.</span>")
        return
    playtoolsound(user.loc, 100)
    var/obj/item/weapon/pickaxe/drill/D = O
    D.depresses_digsites = TRUE
    user.visible_message("<span class='warning'>[user] opens \the [src] and modifies \the [O] to depress digsites.</span>","<span class='warning'>You open \the [src] and modify \the [O] to depress digsites.</span>")
    qdel(O)