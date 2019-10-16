/**********************Mineral deposits**************************/
/turf/unsimulated/mineral //wall piece
	name = "Rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"
	var/base_icon_state = "rock" // above is for mappers.
	oxygen = 0
	nitrogen = 0
	opacity = 1
	density = 1
	blocks_air = 1
	//temperature = TCMB
	var/mineral/mineral
	var/last_act = 0
	var/datum/geosample/geologic_data
	var/excavation_level = 0
	var/list/finds = list()//no longer null to prevent those pesky runtime errors
//	var/next_rock = 0
	var/archaeo_overlay = ""
	var/excav_overlay = ""
	var/obj/item/weapon/last_find
	var/datum/artifact_find/artifact_find
	var/busy = 0 //Used for a bunch of do_after actions, because we can walk into the rock to trigger them
	var/mineral_overlay
	var/mined_type = /turf/unsimulated/floor/asteroid
	var/overlay_state = "rock_overlay"
	var/no_finds = 0 //whether or not we want xenoarchaeology stuff here
	var/rockernaut = NONE
	var/minimum_mine_time = 0
	var/mining_difficulty = MINE_DIFFICULTY_NORM


/turf/unsimulated/mineral/snow
	icon_state = "snow_rock"
	base_icon_state = "snow_rock"
	mined_type = /turf/unsimulated/floor/snow/permafrost
	overlay_state = "snow_rock_overlay"

/turf/unsimulated/mineral/snow/New()
	base_icon_state = pick("snow_rock","snow_rock1","snow_rock2","snow_rock3","snow_rock4")
	..()

/turf/unsimulated/mineral/underground
	icon_state = "cave_wall"
	base_icon_state = "cave_wall"
	mined_type = /turf/unsimulated/floor/asteroid/underground

/turf/unsimulated/mineral/air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
	mined_type = /turf/unsimulated/floor/asteroid/air

//These walls produce a simulated floor tile for easy interior area expansion (Roidstation)
//they also can't contain xenoarch sites
/turf/unsimulated/mineral/internal
	no_finds = 1
	mined_type = /turf/simulated/floor/asteroid

/turf/simulated/wall/r_rock
	name = "reinforced rock"
	desc = "It has metal struts that need to be welded away before it can be mined."
	icon_state = "rock_rf0"
	dismantle_type = /turf/unsimulated/mineral
	girder_type = null
	walltype = "rock_rf"

/*turf/simulated/wall/r_rock/New()
	..()
	add_rock_overlay()

/turf/simulated/wall/r_rock/proc/add_rock_overlay(var/image/img = image('icons/turf/rock_overlay.dmi', "rock_overlay",layer = SIDE_LAYER),var/offset=-4)
	img.pixel_x = offset*PIXEL_MULTIPLIER
	img.pixel_y = offset*PIXEL_MULTIPLIER
	img.plane = BELOW_TURF_PLANE
	overlays += img*/

/turf/simulated/wall/r_rock/porous
	name = "reinforced porous rock"
	desc = "This rock is filled with pockets of breathable air. It has metal struts to protect it from mining."
	dismantle_type = /turf/unsimulated/mineral/internal/air

/turf/unsimulated/mineral/internal/air
	name = "porous rock"
	desc = "This rock is filled with pockets of breathable air, which interfere with the efficiency of some high speed mining equipment."
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
	mined_type = /turf/simulated/floor/asteroid/air
	minimum_mine_time = 30 //3 seconds

//this one's for the snowmaps
/turf/unsimulated/mineral/internal/ice
	icon_state = "snow_rock"
	base_icon_state = "snow_rock"
	overlay_state = "snow_rock_overlay"
	no_finds = 1
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T0C
	mined_type = /turf/simulated/floor/plating/snow/cold

/turf/unsimulated/mineral/internal/ice/New()
	base_icon_state = pick("snow_rock","snow_rock1","snow_rock2","snow_rock3","snow_rock4")
	..()

/turf/unsimulated/mineral/hive
	mined_type = /turf/unsimulated/floor/evil

/turf/unsimulated/mineral/Destroy()
	return

/turf/unsimulated/mineral/New()
	mineral_turfs += src
	. = ..()
	MineralSpread()
	update_icon()

var/list/icon_state_to_appearance = list()

/turf/unsimulated/mineral/update_icon(var/mineral_name = "empty", var/use_overlay = TRUE) // feed in a mineral name to 'force' its appearance on an object.
	if(mineral && mineral_name == "empty")
		mineral_name = mineral.display_name
	if(use_overlay && icon_state_to_appearance["[base_icon_state]-[mineral_name]"])
		appearance = icon_state_to_appearance["[base_icon_state]-[mineral_name]"]
	else
		overlays.Cut()
		if(mineral)
			mineral_overlay = image('icons/turf/mine_overlays.dmi', mineral_name)
			overlays += mineral_overlay
		icon_state = base_icon_state
		add_rock_overlay()
		icon_state_to_appearance["[base_icon_state]-[mineral_name]"] = appearance

/turf/unsimulated/mineral/proc/add_rock_overlay(var/image/img = image('icons/turf/rock_overlay.dmi', overlay_state,layer = SIDE_LAYER),var/offset=-4)
	img.pixel_x = offset*PIXEL_MULTIPLIER
	img.pixel_y = offset*PIXEL_MULTIPLIER
	img.plane = BELOW_TURF_PLANE
	overlays += img

/turf/unsimulated/mineral/underground/add_rock_overlay()
	..(img = image('icons/turf/spookycave.dmi', "spooky_cave",layer = SIDE_LAYER),offset=-16)
	..(img = image('icons/turf/spookycave.dmi', "spooky_cave_corners",layer = CORNER_LAYER),offset = -16)

turf/unsimulated/mineral/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	mineral_turfs -= src
	return ..(N, tell_universe, 1, allow)


/turf/unsimulated/mineral/ex_act(severity)
	if(mining_difficulty > MINE_DIFFICULTY_TOUGH)
		return
	switch(severity)
		if(3.0)
			if (prob(75))
				GetDrilled()
		if(2.0)
			if (prob(90))
				GetDrilled()
		if(1.0)
			GetDrilled()

/turf/unsimulated/mineral/blob_act()
	if(mining_difficulty > MINE_DIFFICULTY_DENSE)
		if(prob(10))
			GetDrilled()
		return

	switch(mining_difficulty)
		if(MINE_DIFFICULTY_NORM)
			if(prob(90))
				GetDrilled()
		if(MINE_DIFFICULTY_TOUGH)
			if(prob(60))
				GetDrilled()
		if(MINE_DIFFICULTY_DENSE)
			if(prob(30))
				GetDrilled()

/turf/unsimulated/mineral/Bumped(AM)
	. = ..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if(istype(H.get_active_hand(),/obj/item/weapon/pickaxe))
			attackby(H.get_active_hand(), H)
		else if(istype(H.get_inactive_hand(),/obj/item/weapon/pickaxe))
			attackby(H.get_inactive_hand(), H)

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/weapon/pickaxe))
			attackby(R.module_active, R)

	else if(istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/tool/drill))
			M.selected.action(src)

	else if(istype(AM,/obj/structure/bed/chair/vehicle/gigadrill))
		var/obj/structure/bed/chair/vehicle/gigadrill/G = AM
		G.drill(src)

	else if(istype(AM,/mob/living/simple_animal/construct/armoured))
		attack_construct(AM)

/turf/unsimulated/mineral/proc/MineralSpread()
	if(mineral && mineral.spread)
		for(var/trydir in cardinal)
			if(prob(mineral.spread_chance))
				var/turf/unsimulated/mineral/random/target_turf = get_step(src, trydir)
				if(istype(target_turf) && !target_turf.mineral)
					if(prob(1) && prob(25)) //People wanted them rarer
						rockernaut = TURF_CONTAINS_REGULAR_ROCKERNAUT
					target_turf.mineral = mineral
					target_turf.UpdateMineral()
					target_turf.MineralSpread()

/turf/unsimulated/mineral/proc/UpdateMineral()
	if(!mineral)
		name = "rock"
		return
	name = "\improper [mineral.display_name] deposit"
	update_icon()

/turf/unsimulated/mineral/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(busy)
		return

	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if (istype(W, /obj/item/device/core_sampler))
		if(!geologic_data)
			geologic_data = new/datum/geosample(src)
		geologic_data.UpdateNearbyArtifactInfo(src)
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
		return

	if (istype(W, /obj/item/device/depth_scanner))
		var/obj/item/device/depth_scanner/C = W
		C.scan_atom(user, src)
		return

	if (istype(W, /obj/item/device/measuring_tape))
		var/obj/item/device/measuring_tape/P = W
		user.visible_message("<span class='notice'>[user] extends [P] towards [src].</span>","<span class='notice'>You extend [P] towards [src].</span>")
		to_chat(user, "<span class='notice'>[bicon(P)] [src] has been excavated to a depth of [2*excavation_level]cm.</span>")
		return

	if(istype(W,/obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/S = W
		if(S.amount < 2)
			to_chat(user,"<span class='warning>You don't have enough material.</span>")
			return
		user.visible_message("<span class='notice'>[user] starts installing reinforcements to \the [src].</span>", \
			"<span class='notice'>You start installing reinforcements to \the [src].</span>")
		if(do_after(user, src, max(minimum_mine_time,4 SECONDS*mining_difficulty)))
			if(!S.use(2))
				to_chat(user,"<span class='warning>You don't have enough material.</span>")
				return
			user.visible_message("<span class='notice'>[user] finishes installing reinforcements to \the [src].</span>", \
				"<span class='notice'>You finish installing reinforcements to \the [src].</span>")
			var/old_type = type
			var/old_name = name
			var/turf/simulated/wall/X = ChangeTurf(/turf/simulated/wall/r_rock)
			if(X)
				X.name = "reinforced [old_name]"
				X.dismantle_type = old_type
				X.add_fingerprint(user)

	if (istype(W, /obj/item/weapon/pickaxe))
		if(user.loc != get_turf(user))
			return //if we aren't in the tile we are located in, return

		var/obj/item/weapon/pickaxe/P = W

		if(!istype(P))
			return

		if(!(P.diggables & DIG_ROCKS))
			return

		if(last_act + P.digspeed > world.time)//prevents message spam
			return

		last_act = world.time

		playsound(user, P.drill_sound, 20, 1)

		var/fail_message = ""
		//handle any archaeological finds we might uncover
		if(finds && finds.len)
			var/datum/find/F = finds[1]

			if(excavation_level + P.excavation_amount > F.excavation_required)
				fail_message = "<b>[pick("There is a crunching noise","[W] collides with some different rock","Part of the rock face crumbles away","Something breaks under [W]")]</b>"
				to_chat(user, "<span class='rose'>[fail_message].</span>")

		if(fail_message && prob(90))
			if(prob(5))
				excavate_find(5, finds[1])
			else if(prob(50))
				finds.Remove(finds[1])
				if(prob(50))
					artifact_debris()

		busy = 1

		if(do_after(user, src, max(P.digspeed,minimum_mine_time)) && user)
			busy = 0

			if(finds && finds.len)
				var/datum/find/F = finds[1]
				if(round(excavation_level + P.excavation_amount) == F.excavation_required)

					if(excavation_level + P.excavation_amount > F.excavation_required)

						excavate_find(100, F)
					else
						excavate_find(80, F)

				else if(excavation_level + P.excavation_amount > F.excavation_required - F.clearance_range)

					excavate_find(0, F)

			if( excavation_level + P.excavation_amount >= 100 )

				var/obj/structure/boulder/B
				if(artifact_find)
					if(excavation_level > 0)

						B = getFromPool(/obj/structure/boulder, src)
						B.geological_data = geologic_data
						if(artifact_find)
							B.artifact_find = artifact_find
							B.investigation_log(I_ARTIFACT, "|| [artifact_find.artifact_find_type] - [artifact_find.artifact_id] found by [key_name(user)].")
					else
						artifact_debris(1)

				else if(prob(15))
					B = getFromPool(/obj/structure/boulder, src)
					B.geological_data = geologic_data
				if(B)
					GetDrilled(0)
				else
					GetDrilled(1)

				return

			if(finds && finds.len)
				var/I = rand(1,100)
				if(I == 1)
					switch(polarstar)
						if(0)
							new/obj/item/weapon/gun/energy/polarstar(src)
							polarstar = 1
							visible_message("<span class='notice'>A gun was buried within!</span>")
						if(1)
							new/obj/item/device/modkit/spur_parts(src)
							visible_message("<span class='notice'>Something came out of the wall! Looks like scrap metal.</span>")
							polarstar = 2

			excavation_level += P.excavation_amount

			if(!archaeo_overlay && finds && finds.len)
				var/datum/find/F = finds[1]
				if(F.excavation_required <= excavation_level + F.view_range)
					archaeo_overlay = "overlay_archaeo[rand(1,3)]"
					overlays += archaeo_overlay

			var/update_excav_overlay = 0

			var/subtractions = 0
			while(excavation_level - 25*(subtractions + 1) >= 0 && subtractions < 3)
				subtractions++
			if(excavation_level - P.excavation_amount < subtractions * 25)
				update_excav_overlay = 1

			//update overlays displaying excavation level
			if( !(excav_overlay && excavation_level > 0) || update_excav_overlay )
				var/excav_quadrant = round(excavation_level / 25) + 1
				excav_overlay = "overlay_excv[excav_quadrant]_[rand(1,3)]"
				overlays += excav_overlay
/*
			//drop some rocks
			next_rock += P.excavation_amount * 10
			while(next_rock > 100)
				next_rock -= 100
				var/obj/item/stack/ore/O = new(src)
				if(!geologic_data)
					geologic_data = new/datum/geosample(src)
				geologic_data.UpdateNearbyArtifactInfo(src)
				O.geologic_data = geologic_data
*/

		else //Note : If the do_after() fails
			busy = 0

	else
		return attack_hand(user)

/turf/unsimulated/mineral/attack_animal(var/mob/living/simple_animal/M)
	M.delayNextAttack(8)
	if(M.environment_smash_flags & SMASH_ASTEROID && prob(30))
		GetDrilled(0)

/turf/unsimulated/mineral/attack_construct(var/mob/user)
	if (!Adjacent(user))
		return 0
	if(istype(user,/mob/living/simple_animal/construct/armoured))
		playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
		if(do_after(user, src, max(minimum_mine_time,40*mining_difficulty)))
			GetDrilled(0)
		return 1
	return 0

/turf/unsimulated/mineral/proc/DropMineral()
	if(!mineral)
		return
	return mineral.DropMineral(src)

/**
* artifact_fail: If true, negative effects will be applied to mobs in range when artifacts inside
*                this turf are destroyed.
* safety_override: If true, dangerous side effects of the turf being drilled will be immediately
*                  disabled after drilling (ie. gibtonite will be immediately disarmed).
* driller: Whatever is doing the drilling.  Used for some messages.
*/
/turf/unsimulated/mineral/proc/GetDrilled(var/artifact_fail = FALSE, var/safety_override = FALSE, var/atom/driller)
	if (mineral && mineral.result_amount)
		DropMineral()
	switch(rockernaut)
		if(TURF_CONTAINS_REGULAR_ROCKERNAUT)
			var/mob/living/simple_animal/hostile/asteroid/rockernaut/R = new(src)
			if(mineral)
				R.possessed_ore = mineral.ore
		if(TURF_CONTAINS_BOSS_ROCKERNAUT)
			var/mob/living/simple_animal/hostile/asteroid/rockernaut/boss/R = new(src)
			if(mineral)
				R.possessed_ore = mineral.ore
	//destroyed artifacts have weird, unpleasant effects
	//make sure to destroy them before changing the turf though
	if(artifact_find && artifact_fail)
		investigation_log(I_ARTIFACT, "|| [artifact_find.artifact_find_type] destroyed by [key_name(usr)].")
		for(var/mob/living/M in range(src, 200))
			to_chat(M, "<span class='red'><b>[pick("A high pitched [pick("keening","wailing","whistle")]","A rumbling noise like [pick("thunder","heavy machinery")]")] somehow penetrates your mind before fading away!</b></span>")
			if(prob(50)) //pain
				flick("pain",M.pain)
				if(prob(50))
					M.adjustBruteLoss(5)
			else
				M.flash_eyes(visual = 1)
				if(prob(50))
					M.Stun(5)
			M.apply_radiation(25, RAD_EXTERNAL)

	if(artifact_fail && !mineral)
		if(prob(1))
			switch(polarstar)
				if(0)
					new/obj/item/weapon/gun/energy/polarstar(src)
					polarstar = 1
					visible_message("<span class='notice'>A gun was buried within!</span>")
				if(1)
					new/obj/item/device/modkit/spur_parts(src)
					visible_message("<span class='notice'>Something came out of the wall! Looks like scrap metal.</span>")
					polarstar = 2

	if(rand(1,500) == 1)
		visible_message("<span class='notice'>An old dusty crate was buried within!</span>")
		DropAbandonedCrate()

	ChangeTurf(mined_type)

/turf/unsimulated/mineral/proc/DropAbandonedCrate()
	var/crate_type = pick(valid_abandoned_crate_types)
	new crate_type(src)

/turf/unsimulated/mineral/proc/GetScanState()
	if(mineral)
		var/mineral_name = mineral.display_name
		if(rockernaut)
			return "[has_icon('icons/turf/mine_overlays.dmi',"embed_[mineral_name]")?"embed_[mineral_name]":"embed_Iron"]"
		return mineral_name
	return null

/turf/unsimulated/mineral/proc/excavate_find(var/prob_clean = 0, var/datum/find/F)
	//with skill and luck, players can cleanly extract finds
	//otherwise, they come out inside a chunk of rock
	var/obj/item/weapon/X
	if(prob_clean)
		X = F.create_find(src)
	else
		X = new /obj/item/weapon/strangerock(src, F)
		if(!geologic_data)
			geologic_data = new/datum/geosample(src)
		geologic_data.UpdateNearbyArtifactInfo(src)
		X:geologic_data = geologic_data

	//many finds are ancient and thus very delicate - luckily there is a specialised energy suspension field which protects them when they're being extracted
	if(prob(F.prob_delicate))
		var/obj/effect/suspension_field/S = locate() in src
		if(!S || S.field_type != F.responsive_reagent)
			if(X)
				visible_message("<span class='danger'>\The [X] [pick("crumbles away into dust","breaks apart")].</span>")
				qdel(X)
				X = null
	finds.Remove(F)

/turf/unsimulated/mineral/proc/artifact_debris(var/severity = 0)
	if(severity)
		switch(rand(1,3))
			if(1)
				var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, (src))
				M.amount = rand(5,25)
			if(2)
				var/obj/item/stack/sheet/plasteel/R = new(src)
				R.amount = rand(5,25)
			if(3)
				var/obj/item/stack/sheet/mineral/uranium/R = new(src)
				R.amount = rand(5,25)
	else
		switch(rand(1,5))
			if(1)
				var/obj/item/stack/rods/R = new(src)
				R.amount = rand(5,25)
			if(2)
				var/obj/item/stack/tile/plasteel/R = new(src)
				R.amount = rand(1,5)
			if(3)
				var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, (src))
				M.amount = rand(1,5)
			if(4)
				var/quantity = rand(1,3)
				for(var/i=0, i<quantity, i++)
					getFromPool(/obj/item/weapon/shard, loc)
			if(5)
				var/quantity = rand(1,3)
				for(var/i=0, i<quantity, i++)
					getFromPool(/obj/item/weapon/shard/plasma, loc)

/turf/unsimulated/mineral/dense
	name = "dense rock"
	mining_difficulty = MINE_DIFFICULTY_DENSE
	minimum_mine_time = 5 SECONDS

/turf/unsimulated/mineral/hyperdense
	name = "hyperdense rock"
	mining_difficulty = MINE_DIFFICULTY_DENSE
	minimum_mine_time = 99 SECONDS //GL HF

/**********************Asteroid**************************/

/turf/unsimulated/floor/airless //floor piece
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/unsimulated/floor/asteroid //floor piece
	name = "Asteroid"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB
	//icon_plating = "asteroid"
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug
	var/sand_type = /obj/item/stack/ore/glass
	plane = PLATING_PLANE

/turf/unsimulated/floor/asteroid/air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

/turf/unsimulated/floor/asteroid/underground
	name = "cave floor"
	temperature = T0C-150
	oxygen = MOLES_O2STANDARD_ARCTIC
	nitrogen = MOLES_N2STANDARD_ARCTIC
	icon_state = "cavefl_1"
	sand_type = /obj/item/stack/ore/glass/cave

/turf/unsimulated/floor/asteroid/underground/New()
	..()
	icon_state = pick("cavefl_1","cavefl_2","cavefl_3","cavefl_4")

/turf/unsimulated/floor/asteroid/New()
	var/proper_name = name
	..()

	name = proper_name

	if(prob(20) && icon_state == "asteroid")
		icon_state = "asteroid[rand(0,12)]"


/turf/unsimulated/floor/asteroid/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(70))
				gets_dug()
		if(1.0)
			gets_dug()
	return

/turf/unsimulated/floor/asteroid/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(!W || !user)
		return 0

	if (istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/used_digging = W //cast for dig speed and flags
		if (get_turf(user) != user.loc) //if we aren't somehow on the turf we're in
			return

		if(!(used_digging.diggables & DIG_SOIL)) //if the pickaxe can't dig soil, we don't
			to_chat(user, "<span class='rose'>You can't dig soft soil with \the [W].</span>")
			return

		if (dug)
			to_chat(user, "<span class='rose'>This area has already been dug.</span>")
			return

		to_chat(user, "<span class='rose'>You start digging.<span>")
		playsound(src, 'sound/effects/rustle1.ogg', 50, 1) //russle sounds sounded better

		if(do_after(user, src, used_digging.digspeed) && user) //the better the drill, the faster the digging
			playsound(src, 'sound/items/shovel.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You dug a hole.</span>")
			gets_dug()

	else
		..(W,user)
	return

/turf/unsimulated/floor/asteroid/update_icon()
	if(dug && ispath(sand_type, /obj/item/stack/ore/glass))
		icon_state = "asteroid_dug"

/turf/unsimulated/floor/asteroid/proc/gets_dug()
	if(dug)
		return
	drop_stack(sand_type, src, 5)
	dug = 1
	//icon_plating = "asteroid_dug"
	update_icon()

//***Simulated version of asteroid floors for use inside of stations (roidstation)***

/turf/simulated/floor/asteroid
	name = "Asteroid"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	intact = 0
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB
	plane = PLATING_PLANE
	var/dug
	var/sand_type = /obj/item/stack/ore/glass

/turf/simulated/floor/asteroid/air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

/turf/simulated/floor/asteroid/New()
	..()
	qdel(floor_tile)
	floor_tile = null
	name = initial(name)
	if(prob(20))
		icon_state = "asteroid[rand(0,12)]"
	icon_regular_floor = initial(icon_state)

/turf/simulated/floor/asteroid/is_plating()
	return 0

/turf/simulated/floor/asteroid/canBuildCatwalk()
	return BUILD_FAILURE

/turf/simulated/floor/asteroid/canBuildLattice()
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/simulated/floor/asteroid/canBuildPlating()
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(!dug)
		return BUILD_IGNORE
	if(locate(/obj/structure/lattice) in contents)
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/simulated/floor/asteroid/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(70))
				gets_dug()
		if(1.0)
			gets_dug()

/turf/simulated/floor/asteroid/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!W || !user)
		return 0
	if (istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/used_digging = W //cast for dig speed and flags
		if (get_turf(user) != user.loc) //if we aren't somehow on the turf we're in
			return
		if(!(used_digging.diggables & DIG_SOIL)) //if the pickaxe can't dig soil, we don't
			to_chat(user, "<span class='rose'>You can't dig soft soil with \the [W].</span>")
			return
		if (dug)
			to_chat(user, "<span class='rose'>This area has already been dug.</span>")
			return
		to_chat(user, "<span class='rose'>You start digging.<span>")
		playsound(src, 'sound/effects/rustle1.ogg', 50, 1) //russle sounds sounded better
		if(do_after(user, src, used_digging.digspeed) && user) //the better the drill, the faster the digging
			playsound(src, 'sound/items/shovel.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You dug a hole.</span>")
			gets_dug()
	else
		..(W,user)
	return

/turf/simulated/floor/asteroid/update_icon()
	if(dug && ispath(sand_type, /obj/item/stack/ore/glass))
		icon_state = "asteroid_dug"

/turf/simulated/floor/asteroid/proc/gets_dug()
	if(dug)
		return
	drop_stack(sand_type, src, 5)
	dug = 1
	//icon_plating = "asteroid_dug"
	update_icon()



/turf/unsimulated/mineral/random
	name = "Mineral deposit"
	var/mineralSpawnChanceList = list(
		"Iron"      = 50,
		"Plasma"    = 25,
		"Ice"		= 10,
		"Uranium"   = 5,
		"Gold"      = 5,
		"Silver"    = 5,
		"Gibtonite" = 5,
		"Diamond"   = 1,
		"Cave"      = 1,
		/*
		"Pharosium"  = 5,
		"Char"  = 5,
		"Claretine"  = 5,
		"Bohrum"  = 5,
		"Syreline"  = 5,
		"Erebite"  = 5,
		"Uqill"  = 5,
		"Telecrystal"  = 5,
		"Mauxite"  = 5,
		"Cobryl"  = 5,
		"Cerenkite"  = 5,
		"Molitz"  = 5,
		"Cytine"  = 5
		*/
	)
	//Currently, Adamantine won't spawn as it has no uses. -Durandan
	var/mineralChance = 10  //means 10% chance of this plot changing to a mineral deposit

/turf/unsimulated/mineral/random/New()
	if (prob(mineralChance) && !mineral)
		var/mineral_name = pickweight(mineralSpawnChanceList) //temp mineral name

		if(!name_to_mineral)
			SetupMinerals()

		if (mineral_name)
			if(mineral_name in name_to_mineral)
				mineral = name_to_mineral[mineral_name]
				mineral.UpdateTurf(src)
			else
				warning("Unknown mineral ID: [mineral_name]")

	. = ..()

/turf/unsimulated/mineral/random/snow
	icon_state = "snow_rock"
	base_icon_state = "snow_rock"
	mined_type = /turf/unsimulated/floor/snow/permafrost
	overlay_state = "snow_rock_overlay"

	mineralSpawnChanceList = list(
		"Iron"      = 50,
		"Plasma"    = 25,
		"Ice"		= 10,
		"Uranium"   = 5,
		"Gold"      = 5,
		"Silver"    = 5,
		"Gibtonite" = 5,
		"Diamond"   = 1,
		"Ice Cave"  = 1,
	)

/turf/unsimulated/mineral/random/high_chance
	icon_state = "rock(high)"
	mineralChance = 25
	mineralSpawnChanceList = list(
		"Uranium" = 10,
		"Iron"    = 30,
		"Diamond" = 2,
		"Gold"    = 10,
		"Silver"  = 10,
		"Plasma"  = 25,
		/*
		"Pharosium"  = 5,
		"Char"  = 5,
		"Claretine"  = 5,
		"Bohrum"  = 5,
		"Syreline"  = 5,
		"Erebite"  = 5,
		"Uqill"  = 5,
		"Telecrystal"  = 5,
		"Mauxite"  = 5,
		"Cobryl"  = 5,
		"Cerenkite"  = 5,
		"Molitz"  = 5,
		"Cytine"  = 5
		*/
	)

/turf/unsimulated/mineral/random/high_chance/snow
	icon_state = "snow_rock"
	base_icon_state = "snow_rock"
	mined_type = /turf/unsimulated/floor/snow/permafrost
	overlay_state = "snow_rock_overlay"


/turf/unsimulated/mineral/random/high_chance_clown
	icon_state = "rock(clown)"
	mineralChance = 40
	mineralSpawnChanceList = list(
		"Uranium" = 10,
		//"Iron"    = 10,
		"Diamond" = 2,
		"Gold"    = 5,
		"Silver"  = 5,
		/*
		"Pharosium"  = 1,
		"Char"  = 1,
		"Claretine"  = 1,
		"Bohrum"  = 1,
		"Syreline"  = 1,
		"Erebite"  = 1,
		"Uqill"  = 1,
		"Telecrystal"  = 1,
		"Mauxite"  = 1,
		"Cobryl"  = 1,
		"Cerenkite"  = 1,
		"Molitz"  = 1,
		"Cytine"  = 1,
		*/
		"Plasma"  = 25,
		"Clown"   = 15,
		"Phazon"  = 10
	)

/turf/unsimulated/mineral/random/high_chance_clown/snow
	icon_state = "snow_rock"
	base_icon_state = "snow_rock"
	mined_type = /turf/unsimulated/floor/snow/permafrost
	overlay_state = "snow_rock_overlay"


/turf/unsimulated/mineral/random/Destroy()
	return

/turf/unsimulated/mineral/uranium
	name = "Uranium deposit"
	icon_state = "rock_Uranium"
	mineral = new /mineral/uranium


/turf/unsimulated/mineral/iron
	name = "Iron deposit"
	icon_state = "rock_Iron"
	mineral = new /mineral/iron


/turf/unsimulated/mineral/diamond
	name = "Diamond deposit"
	icon_state = "rock_Diamond"
	mineral = new /mineral/diamond


/turf/unsimulated/mineral/gold
	name = "Gold deposit"
	icon_state = "rock_Gold"
	mineral = new /mineral/gold


/turf/unsimulated/mineral/silver
	name = "Silver deposit"
	icon_state = "rock_Silver"
	mineral = new /mineral/silver


/turf/unsimulated/mineral/plasma
	name = "Plasma deposit"
	icon_state = "rock_Plasma"
	mineral = new /mineral/plasma


/turf/unsimulated/mineral/clown
	name = "Bananium deposit"
	icon_state = "rock_Clown"
	mineral = new /mineral/clown


/turf/unsimulated/mineral/phazon
	name = "Phazite deposit"
	icon_state = "rock_Phazon"
	mineral = new /mineral/phazon

/turf/unsimulated/mineral/pharosium
	name = "Pharosium deposit"
	icon_state = "rock_Pharosium"
	mineral = new /mineral/pharosium

/turf/unsimulated/mineral/char
	name = "Char deposit"
	icon_state = "rock_Char"
	mineral = new /mineral/char

/turf/unsimulated/mineral/claretine
	name = "Claretine deposit"
	icon_state = "rock_Claretine"
	mineral = new /mineral/claretine

/turf/unsimulated/mineral/bohrum
	name = "Bohrum deposit"
	icon_state = "rock_Bohrum"
	mineral = new /mineral/bohrum

/turf/unsimulated/mineral/syreline
	name = "Syreline deposit"
	icon_state = "rock_Syreline"
	mineral = new /mineral/syreline

/turf/unsimulated/mineral/erebite
	name = "Erebite deposit"
	icon_state = "rock_Erebite"
	mineral = new /mineral/erebite

/turf/unsimulated/mineral/cytine
	name = "Cytine deposit"
	icon_state = "rock_Cytine"
	mineral = new /mineral/cytine

/turf/unsimulated/mineral/uqill
	name = "Uqill deposit"
	icon_state = "rock_Uqill"
	mineral = new /mineral/uqill

/turf/unsimulated/mineral/telecrystal
	name = "Telecrystal deposit"
	icon_state = "rock_Telecrystal"
	mineral = new /mineral/telecrystal

/turf/unsimulated/mineral/mauxite
	name = "Mauxite deposit"
	icon_state = "rock_Mauxite"
	mineral = new /mineral/mauxite

/turf/unsimulated/mineral/cobryl
	name = "Cobryl deposit"
	icon_state = "rock_Cobryl"
	mineral = new /mineral/cobryl

/turf/unsimulated/mineral/cerenkite
	name = "Cerenkite deposit"
	icon_state = "rock_Cerenkite"
	mineral = new /mineral/cerenkite

/turf/unsimulated/mineral/molitz
	name = "Molitz deposit"
	icon_state = "rock_Molitz"
	mineral = new /mineral/molitz

/turf/unsimulated/mineral/mythril
	name = "Silver deposit"
	icon_state = "rock_Silver"
	mineral = new /mineral/mythril

////////////////////////////////Gibtonite
/turf/unsimulated/mineral/gibtonite
	name = "Diamond deposit" //honk
	icon_state = "rock_Gibtonite"
	mineral = new /mineral/gibtonite
	var/det_time = 8 //Countdown till explosion, but also rewards the player for how close you were to detonation when you defuse it
	var/stage = 0 //How far into the lifecycle of gibtonite we are, 0 is untouched, 1 is active and attempting to detonate, 2 is benign and ready for extraction
	var/activated_ckey = null //These are to track who triggered the gibtonite deposit for logging purposes
	var/activated_name = null

/turf/unsimulated/mineral/gibtonite/New()
	det_time = rand(8,10) //So you don't know exactly when the hot potato will explode
	..()

/turf/unsimulated/mineral/gibtonite/update_icon(var/mineral_name = "empty")
	if(mineral_name == "empty" && !stage)
		..("Diamond", FALSE)
	else ..(mineral_name)

/turf/unsimulated/mineral/gibtonite/Bumped(AM)
	var/bump_reject = 0
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if((istype(H.get_active_hand(),/obj/item/weapon/pickaxe) || istype(H.get_inactive_hand(),/obj/item/weapon/pickaxe)) && src.stage == 1)
			to_chat(H, "<span class='warning'>You don't think that's a good idea...</span>")
			bump_reject = 1

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active, /obj/item/weapon/pickaxe))
			to_chat(R, "<span class='warning'>You don't think that's a good idea...</span>")
			bump_reject = 1
		else if(istype(R.module_active, /obj/item/device/mining_scanner))
			attackby(R.module_active, R) //let's bump to disable. This is kinder, because borgs need some love

	if(!bump_reject) //if we haven't been pushed off, we do the drilling bit
		return ..()

/turf/unsimulated/mineral/gibtonite/attackby(obj/item/I, mob/user)
	if(((istype(I, /obj/item/device/mining_scanner)) || (istype(I, /obj/item/device/depth_scanner))) && stage == 1)
		user.visible_message("<span class='notice'>You use [I] to locate where to cut off the chain reaction and attempt to stop it...</span>")
		defuse()
	if(istype(I, /obj/item/weapon/pickaxe))
		src.activated_ckey = "[user.ckey]"
		src.activated_name = "[user.name]"
	..()

/turf/unsimulated/mineral/gibtonite/proc/explosive_reaction()
	if(stage == 0)
		update_icon("Gibtonite_active")
		name = "Gibtonite deposit"
		desc = "An active gibtonite reserve. Run!"
		stage = 1
		visible_message("<span class='warning'>There was gibtonite inside! It's going to explode!</span>")
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)
		var/log_str = "[src.activated_ckey]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> [src.activated_name] has triggered a gibtonite deposit reaction <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>."
		log_game(log_str)
		countdown()

/turf/unsimulated/mineral/gibtonite/proc/countdown()
	spawn(0)
		while(stage == 1 && det_time > 0 && mineral.result_amount >= 1)
			det_time--
			sleep(5)
		if(stage == 1 && det_time <= 0 && mineral.result_amount >= 1)
			var/turf/bombturf = get_turf(src)
			mineral.result_amount = 0
			explosion(bombturf,1,3,5, adminlog = 0)
		if(stage == 0 || stage == 2)
			return

/turf/unsimulated/mineral/gibtonite/proc/defuse()
	if(stage == 1)
		update_icon("Gibtonite") //inactive does not exist. The other icon is active.
		desc = "An inactive gibtonite reserve. The ore can be extracted."
		stage = 2
		if(det_time < 0)
			det_time = 0
		visible_message("<span class='notice'>The chain reaction was stopped! The gibtonite had [src.det_time] reactions left till the explosion!</span>")

/turf/unsimulated/mineral/gibtonite/GetDrilled(var/artifact_fail = FALSE, var/safety_override = FALSE, var/atom/driller)
	if(stage == 0 && mineral.result_amount >= 1) //Gibtonite deposit is activated
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		explosive_reaction()
		if (safety_override)
			if (driller && istype(driller))
				driller.visible_message("<span class='notice'>\The [driller] safely defuses the [src].</span>")
			defuse()
		return
	if(stage == 1 && mineral.result_amount >= 1) //Gibtonite deposit goes kaboom
		var/turf/bombturf = get_turf(src)
		mineral.result_amount = 0
		explosion(bombturf,1,2,5, adminlog = 0)
	if(stage == 2) //Gibtonite deposit is now benign and extractable. Depending on how close you were to it blowing up before defusing, you get better quality ore.
		var/obj/item/weapon/gibtonite/G = new /obj/item/weapon/gibtonite/(src)
		if(det_time <= 0)
			G.det_quality = 3
			G.icon_state = "Gibtonite ore 3"
		if(det_time >= 1 && det_time <= 2)
			G.det_quality = 2
			G.icon_state = "Gibtonite ore 2"
	ChangeTurf(/turf/unsimulated/floor/asteroid/gibtonite_remains)

/turf/unsimulated/floor/asteroid/gibtonite_remains
	var/det_time = 0
	var/stage = 0

////////////////////////////////End Gibtonite

/turf/unsimulated/floor/asteroid/cave
	var/length = 100
	var/mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath  = 5,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 1,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 3,
		/mob/living/simple_animal/hostile/asteroid/hivelord = 5,
		/mob/living/simple_animal/hostile/asteroid/magmaw = 4,
		/mob/living/simple_animal/hostile/asteroid/pillow = 2
	)
	var/sanity = 1
	var/turf/floor_type = /turf/unsimulated/floor/asteroid

/turf/unsimulated/floor/asteroid/cave/permafrost
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/bear = 4,
		/mob/living/simple_animal/hostile/asteroid/pillow = 3,
		/mob/living/simple_animal/hostile/scarybat = 5,
		/mob/living/simple_animal/hostile/giant_spider/hunter = 4,
		/mob/living/simple_animal/hostile/giant_spider/nurse = 3,
		/mob/living/simple_animal/hostile/wendigo = 1)

	floor_type = /turf/unsimulated/floor/snow/permafrost

	icon = 'icons/turf/new_snow.dmi'
	icon_state = "permafrost_full"
	temperature = T_ARCTIC
	oxygen = MOLES_O2STANDARD_ARCTIC
	nitrogen = MOLES_N2STANDARD_ARCTIC
	light_color = "#e5ffff"
	can_border_transition = 1
	dynamic_lighting = 0
	luminosity = 1
	plane = PLATING_PLANE

/turf/unsimulated/floor/asteroid/cave/New(loc, var/length, var/go_backwards = 1, var/exclude_dir = -1)

	// If length (arg2) isn't defined, get a random length; otherwise assign our length to the length arg.
	if(!length)
		src.length = rand(25, 50)
	else
		src.length = length

	// Get our directiosn
	var/forward_cave_dir = pick(alldirs - exclude_dir)
	// Get the opposite direction of our facing direction
	var/backward_cave_dir = angle2dir(dir2angle(forward_cave_dir) + 180)

	// Make our tunnels
	make_tunnel(forward_cave_dir)
	if(go_backwards)
		make_tunnel(backward_cave_dir)
	// Kill ourselves by replacing ourselves with a normal floor.
	SpawnFloor(src)
	..()

/turf/unsimulated/floor/asteroid/cave/proc/make_tunnel(var/dir)


	var/turf/unsimulated/mineral/tunnel = src
	var/next_angle = pick(45, -45)

	for(var/i = 0; i < length; i++)
		if(!sanity)
			break

		var/list/L = list(45)
		if(IsOdd(dir2angle(dir))) // We're going at an angle and we want thick angled tunnels.
			L += -45

		// Expand the edges of our tunnel
		for(var/edge_angle in L)
			var/turf/unsimulated/mineral/edge = get_step(tunnel, angle2dir(dir2angle(dir) + edge_angle))
			if(istype(edge))
				SpawnFloor(edge)

		// Move our tunnel forward
		tunnel = get_step(tunnel, dir)

		if(istype(tunnel))
			// Small chance to have forks in our tunnel; otherwise dig our tunnel.
			if(i > 3 && prob(20))
				new src.type(tunnel, rand(10, 15), 0, dir)
			else
				SpawnFloor(tunnel)
		else //if(!istype(tunnel, src.parent)) // We hit space/normal/wall, stop our tunnel.
			break

		// Chance to change our direction left or right.
		if(i > 2 && prob(33))
			// We can't go a full loop though
			next_angle = -next_angle
			dir = angle2dir(dir2angle(dir) + next_angle)

/turf/unsimulated/floor/asteroid/cave/proc/SpawnFloor(var/turf/T)
	for(var/turf/S in range(2,T))
		if(istype(S, /turf/space) || istype(S.loc, /area/mine/explored))
			sanity = 0
			break
	if(!sanity)
		return

	SpawnMonster(T)

	T.ChangeTurf(floor_type) // TODO: FIX THIS

/turf/unsimulated/floor/asteroid/cave/proc/SpawnMonster(var/turf/T)
	if(prob(2))
		if(istype(loc, /area/mine/explored))
			return
		for(var/atom/A in range(7,T))//Lowers chance of mob clumps
			if(istype(A, /mob/living/simple_animal/hostile/asteroid))
				return
		var/randumb = pickweight(mob_spawn_list)
		new randumb(T)
	return

/turf/unsimulated/floor/asteroid/plating
	intact=0
	icon_state="asteroidplating"

/turf/unsimulated/floor/asteroid/canBuildCatwalk()
	return BUILD_FAILURE

/turf/unsimulated/floor/asteroid/canBuildLattice()
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/unsimulated/floor/asteroid/canBuildPlating()
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(!dug)
		return BUILD_IGNORE
	if(locate(/obj/structure/lattice) in contents)
		return BUILD_SUCCESS
	return BUILD_FAILURE
