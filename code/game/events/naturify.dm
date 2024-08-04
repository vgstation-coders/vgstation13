var/list/flora_types = list(
									/obj/structure/flora/ausbushes/lavendergrass = 10,
									/obj/structure/flora/ausbushes/sparsegrass = 35,
	                             	/obj/structure/flora/ausbushes/fullgrass = 20,
								  	/obj/structure/flora/rock/pile = 15,
									/obj/structure/flora/rock = 6,
									/obj/structure/flora/ausbushes/leafybush = 3,
									/obj/structure/flora/ausbushes/palebush = 3,
									/obj/structure/flora/ausbushes/stalkybush = 3,
									/obj/structure/flora/ausbushes/sunnybush = 3,
									/obj/structure/flora/ausbushes/genericbush = 3,
									/obj/structure/flora/ausbushes/pointybush = 3,
									/obj/structure/flora/ausbushes/ywflowers = 14,
									/obj/structure/flora/ausbushes/brflowers = 14,
									/obj/structure/flora/ausbushes/ppflowers = 14,
									/obj/structure/seedbush = 10,
							 )

var/list/animal_types = list(
									/mob/living/simple_animal/hostile/retaliate/goat = 5,
									/mob/living/simple_animal/cow = 8,
									/mob/living/simple_animal/hostile/retaliate/box/pig = 9,
									/mob/living/simple_animal/chicken = 14,
									/mob/living/simple_animal/rabbit = 12,
									/mob/living/simple_animal/rabbit/bunny = 12,
									/mob/living/carbon/complex/gondola = 1,
									/mob/living/simple_animal/capybara = 1,
							 )

var/list/cave_decor_types = list(
								  	/obj/structure/flora/rock/pile = 160,
									/obj/structure/flora/rock = 60,
									/obj/item/device/flashlight/torch = 20,
									/obj/item/weapon/pickaxe/shovel = 6,
									/obj/item/weapon/melee/bone_club = 1,
									/obj/item/weapon/melee/wooden_club = 1,
									/obj/structure/boulder = 12
							 )

var/list/beach_decor_types = list(
									/obj/structure/flora/rock/pile = 30,
									/obj/structure/flora/coconut = 16,
									/obj/item/weapon/grown/log/tree = 4,
									/obj/item/weapon/melee/defib_basic/electric_eel = 4,
							 )

var/list/beach_animal_types = list(
									/mob/living/simple_animal/crab = 10,
									/mob/living/simple_animal/hostile/carp/baby/friendly = 15,
									/mob/living/simple_animal/hostile/carp/friendly = 10,
							 )

var/list/ignored_cave_deletion_types = list(/obj/structure/window, /obj/machinery/door/airlock, /obj/structure/grille, /obj/structure/plasticflaps/mining, /obj/machinery/door/poddoor)

var/list/medicine_cow_possible_reagents = list(ALLICIN, TANNIC_ACID, THYMOL, PHYTOCARISOL, PHYTOSINE)

var/list/seedbush_spawns = list(
		/obj/item/seeds/bananaseed = 10,
		/obj/item/seeds/berryseed = 10,
		/obj/item/seeds/carrotseed = 10,
		/obj/item/seeds/chantermycelium = 10,
		/obj/item/seeds/chiliseed = 10,
		/obj/item/seeds/cornseed = 10,
		/obj/item/seeds/eggplantseed = 10,
		/obj/item/seeds/potatoseed = 10,
		/obj/item/seeds/dionanode = 10,
		/obj/item/seeds/soyaseed = 10,
		/obj/item/seeds/sunflowerseed = 10,
		/obj/item/seeds/tomatoseed = 10,
		/obj/item/seeds/towermycelium = 10,
		/obj/item/seeds/wheatseed = 10,
		/obj/item/seeds/appleseed = 10,
		/obj/item/seeds/poppyseed = 10,
		/obj/item/seeds/ambrosiavulgarisseed = 10,
		/obj/item/seeds/whitebeetseed = 10,
		/obj/item/seeds/sugarcaneseed = 10,
		/obj/item/seeds/watermelonseed = 10,
		/obj/item/seeds/limeseed = 10,
		/obj/item/seeds/lemonseed = 10,
		/obj/item/seeds/orangeseed = 10,
		/obj/item/seeds/grassseed = 10,
		/obj/item/seeds/cloverseed = 10,
		/obj/item/seeds/cocoapodseed = 10,
		/obj/item/seeds/cabbageseed = 10,
		/obj/item/seeds/grapeseed = 10,
		/obj/item/seeds/pumpkinseed = 10,
		/obj/item/seeds/cherryseed = 10,
		/obj/item/seeds/plastiseed = 10,
		/obj/item/seeds/riceseed = 10,
		/obj/item/seeds/cinnamomum = 10,
		/obj/item/seeds/avocadoseed = 10,
		/obj/item/seeds/pearseed = 10,
		/obj/item/seeds/peanutseed = 10,
		/obj/item/seeds/mustardplantseed = 10,
		/obj/item/seeds/flaxseed = 10,
		/obj/item/seeds/amanitamycelium = 6,
		/obj/item/seeds/glowshroom = 6,
		/obj/item/seeds/libertymycelium = 6,
		/obj/item/seeds/nettleseed = 6,
		/obj/item/seeds/plumpmycelium = 6,
		/obj/item/seeds/reishimycelium = 6,
		/obj/item/seeds/harebell = 6,
)

/**
	Return your station to nature.
		All walls become wood. All floors become grass or stone. The station is populated with
		animals, trees, and other nature things, as well as some interesting tidbits.

		All APC's are gone. All batteries are drained. Electricity no longer operates.
*/

/proc/naturify_station()
	var/target_zlevel = map.zMainStation
	for(var/area/target in areas)
		// Note: there should really be a better way to check whether it's the space area...
		if(target.name != "Space" && target.z == target_zlevel)
			if(istype(target, /area/hallway))
				break_room(target)
				grassify_room(target, spawn_flora=TRUE, spawn_trees=TRUE, spawn_animals=TRUE)
			else if(istype(target, /area/crew_quarters/bar))
				break_room(target)
				grassify_room(target, spawn_flora=TRUE, spawn_medicine_cows=TRUE)
			else if(istype(target, /area/security/armory))
				break_room(target)
				caveify_room(target)
				generate_bear_den(target)
			else if(istype(target, /area/maintenance))
				clear_objects_in_room(target, ignored_cave_deletion_types)
				break_room(target)
				caveify_room(target)
			else if(istype(target, /area/medical))
				break_room(target)
				beachify_room(target)
			else
				break_room(target)
				grassify_room(target, spawn_flora=TRUE)
	for(var/area/target in areas)
		if(target.name != "Space" && target.z == target_zlevel)
			for(var/turf/simulated/wall/W in target)
				// Before roundstart, the walls don't visually connect with each other unless we call this.
				W.relativewall()
	to_chat(map.zLevels[target_zlevel], "<span class='sinister'>You blink, and suddenly the smell of grass permeates the air...</span>")

/// Turns a room grassy and makes the walls wooden. Other options are available for other nature-related spawns.
/proc/grassify_room(var/area/target, var/spawn_flora=TRUE, var/spawn_trees=FALSE, var/spawn_animals=FALSE, var/spawn_medicine_cows=FALSE)
	for(var/turf/T in target)
		if(istype(T, /turf/simulated/floor/))
			T.ChangeTurf(/turf/simulated/floor/planetary_grass)
		else if(istype(T, /turf/simulated/wall) || istype(T, /turf/simulated/wall/r_wall))
			T.ChangeTurf(/turf/simulated/wall/mineral/wood, tell_universe = 0)

	for(var/obj/machinery/light/L in target)
		var/obj/structure/hanging_lantern/HL = new /obj/structure/hanging_lantern(L.loc)
		HL.dir = L.dir
		HL.lantern_can_be_removed = FALSE
		HL.update()
		qdel(L)

	for(var/obj/machinery/door/airlock/AL in target)
		if(!istype(AL, /obj/machinery/door/airlock/external))
			new /obj/machinery/door/mineral/wood/log(AL.loc)
			qdel(AL)
	for(var/obj/machinery/door/unpowered/shuttle/S in target)
		new /obj/machinery/door/mineral/wood/log(S.loc)
		qdel(S)

	if(spawn_flora)
		for(var/turf/simulated/floor/F in target)
			if(!F.has_dense_content() && prob(55))
				var/flora_type = pickweight(flora_types)
				new flora_type(F)

	if(spawn_trees)
		for(var/turf/simulated/floor/F in target)
			if(!F.has_dense_content() && prob(5))
				for(var/obj/O in F)
					qdel(O)
				new/obj/structure/flora/tree/shitty(F)

	if(spawn_animals)
		for(var/turf/simulated/floor/F in target)
			if(!F.has_dense_content() && prob(4))
				var/animal_type = pickweight(animal_types)
				new animal_type(F)

	if(spawn_medicine_cows)
		for(var/turf/simulated/floor/F in target)
			if(!F.has_dense_content() && prob(8))
				var/mob/living/simple_animal/cow/medical_cow = generate_medicine_cow()
				medical_cow.forceMove(F)


/// Turns a room into a cave with rocks. Perfect for a caveman.
/proc/caveify_room(var/area/target)
	for(var/turf/T in target)
		if(istype(T, /turf/simulated/floor/))
			T.ChangeTurf(/turf/simulated/floor/asteroid/air)
		else if(istype(T, /turf/simulated/wall) || istype(T, /turf/simulated/wall/r_wall))
			T.ChangeTurf(/turf/unsimulated/mineral/random/air, tell_universe = 1)

	for(var/turf/simulated/floor/F in target)
		if(!F.has_dense_content() && prob(25))
			var/cave_decor_type = pickweight(cave_decor_types)
			new cave_decor_type(F)

	for(var/obj/machinery/door/airlock/AL in target)
		if(!istype(AL, /obj/machinery/door/airlock/external))
			new /obj/machinery/door/mineral/wood/log(AL.loc)
			qdel(AL)

	for(var/obj/machinery/light/L in target)
		var/obj/structure/hanging_lantern/HL = new /obj/structure/hanging_lantern/dim(L.loc)
		HL.dir = L.dir
		HL.lantern_can_be_removed = FALSE
		HL.update()
		qdel(L)

/proc/beachify_room(var/area/target)
	for(var/turf/T in target)
		if(istype(T, /turf/simulated/floor/))
			T.ChangeTurf(/turf/simulated/floor/beach/sand)
		else if(istype(T, /turf/simulated/wall) || istype(T, /turf/simulated/wall/r_wall))
			T.ChangeTurf(/turf/unsimulated/mineral/random/air, tell_universe = 1)

	for(var/obj/machinery/light/L in target)
		var/obj/structure/hanging_lantern/HL = new /obj/structure/hanging_lantern(L.loc)
		HL.dir = L.dir
		HL.lantern_can_be_removed = FALSE
		HL.update()
		qdel(L)

	for(var/obj/machinery/door/airlock/AL in target)
		if(!istype(AL, /obj/machinery/door/airlock/external))
			new /obj/machinery/door/mineral/wood/log(AL.loc)
			qdel(AL)
	for(var/obj/machinery/door/unpowered/shuttle/S in target)
		new /obj/machinery/door/mineral/wood/log(S.loc)
		qdel(S)

	for(var/turf/simulated/floor/F in target)
		if(!F.has_dense_content() && prob(5))
			for(var/obj/O in F)
				qdel(O)
			new/obj/structure/flora/tree/palm(F)


	for(var/turf/simulated/floor/F in target)
		if(!F.has_dense_content() && prob(13))
			var/flora_type = pickweight(beach_decor_types)
			new flora_type(F)

	for(var/turf/simulated/floor/F in target)
		if(!F.has_dense_content() && prob(4))
			var/animal_type = pickweight(beach_animal_types)
			new animal_type(F)


/proc/generate_bear_den(var/area/target)
	for(var/turf/simulated/floor/F in target)
		if(!F.has_dense_content() && prob(15))
			new /mob/living/simple_animal/hostile/bear(F)

/// Does various things to make the room look old and run down. For instance, breaks machines, eliminates power, etc.
/proc/break_room(var/area/target)
	for(var/obj/machinery/power/apc in target)
		qdel(apc)

	for(var/obj/machinery/M in target)
		if(!istype(M, /obj/machinery/computer) && prob(50))
			M.stat |= BROKEN

	for(var/obj/machinery/camera/C in target)
		C.deactivate(null)

	// Recursive check to uncharge all cells. Bit laggy!
	for(var/turf/T in target)
		uncharge_all_cells_recursive(T)

/proc/uncharge_all_cells_recursive(var/atom/A)
	var/obj/item/weapon/cell/C = A
	if(istype(C))
		C.charge = 0
	for(var/atom/content in A.contents)
		uncharge_all_cells_recursive(content)
	A.update_icon()

/proc/clear_objects_in_room(var/area/target, var/list/blacklist)
	for(var/turf/T in target)
		if(istype(T, /turf/simulated/floor/))
			for(var/obj/O in T)
				var/should_be_deleted = TRUE
				for(var/blacklisted_type in blacklist)
					if(istype(O, blacklisted_type))
						should_be_deleted = FALSE
						break
				if(should_be_deleted)
					qdel(O)

/proc/generate_medicine_cow()
	var/mob/living/simple_animal/cow/medicine_cow = new /mob/living/simple_animal/cow
	medicine_cow.name = "medical cow"
	medicine_cow.desc = "The cows will heal him."
	medicine_cow.milktype = pick(medicine_cow_possible_reagents)
	medicine_cow.min_reagent_regen_per_tick = 2
	medicine_cow.max_reagent_regen_per_tick = 3
	medicine_cow.reagent_regen_chance_per_tick = 15
	medicine_cow.milkable_reagents.maximum_volume = 30
	return medicine_cow



/obj/structure/seedbush
	name = "seed bush"
	desc = "This mysterious bush of grass is genetically modified to produce a type of seed when harvested."
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "grassybush_1"

/obj/structure/seedbush/New()
	..()
	icon_state = "grassybush_[rand(1, 4)]"

/obj/structure/seedbush/attack_hand(mob/user)
	var/seed_type = pickweight(seedbush_spawns)
	var/obj/item/seeds/harvested_seed = new seed_type(user.loc)
	user.put_in_active_hand(harvested_seed)
	playsound(loc, "sound/effects/plant_rustle.ogg", 50, 1, -1)
	user.visible_message("<span class='notice'>[user] harvests \the [harvested_seed] from \the [src].</span>", "You harvest \the [harvested_seed] from \the [src].")
	if(prob(60))
		qdel(src)



/turf/simulated/floor/planetary_grass
	name = "Grass"
	icon = 'icons/turf/floors.dmi'
	icon_state = "grass1"
	plane = PLATING_PLANE
	flammable = FALSE
	var/dirt_left = 10

/turf/simulated/floor/planetary_grass/update_icon()
	return

/turf/simulated/floor/planetary_grass/create_floor_tile()
	return

/turf/simulated/floor/planetary_grass/New()
	icon_state = "grass[pick("1","2","3","4")]"
	..()
	spawn(4)
		if(src)
			update_icon()
			for(var/direction in cardinal)
				if(istype(get_step(src,direction),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,direction)
					FF.update_icon()

/turf/simulated/floor/planetary_grass/canBuildLattice()
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents))
		return BUILD_SUCCESS

/turf/simulated/floor/planetary_grass/canBuildCatwalk()
	return BUILD_FAILURE

/turf/simulated/floor/planetary_grass/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(isshovel(W))
		if(dirt_left > 0)
			user.visible_message("<span class='notice'>[user] digs out some dirt with \the [W].</span>", \
			"<span class='notice'>You dig out some dirt with \the [W].</span>")
			playsound(src, 'sound/items/shovel.ogg', 50, 1)
			var/amount = min(dirt_left, 2)
			dirt_left -= amount
			drop_stack(/obj/item/stack/ore/glass, src, amount)
			user.delayNextAttack(20)
		else
			to_chat(user, "<span class='notice'>There's not enough dirt left here to dig anymore!</span>")
		return

/obj/structure/flora/tree/shitty
	icon = 'icons/obj/flora/trees.dmi'
	icon_state = "shittytree"
	randomize_on_creation = FALSE

/obj/structure/flora/tree/palm
	name = "Palm tree"
	desc = "The coconut-nut is a giant nut!"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"
	pixel_x = 0

/obj/structure/flora/tree/palm/New()
	icon_state = "palm[rand(1,2)]"

/obj/item/clothing/suit/unathi/robe/plasmaman
	name = "plasmaman robes"
	desc = "Somehow these robes keep a plasmaman safe, even outside of plasma."
	species_restricted = list(PLASMAMAN_SHAPED)
	species_fit = list(PLASMAMAN_SHAPED)
	clothing_flags = PLASMAGUARD|CONTAINPLASMAMAN
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS

/obj/item/clothing/head/bearpelt/brown/plasmaman
	name = "plasmaman wolf pelt"
	desc = "Somehow this wolf pelt keep a plasmaman safe, even outside of plasma."
	species_restricted = list(PLASMAMAN_SHAPED)
	species_fit = list(PLASMAMAN_SHAPED)
	clothing_flags = PLASMAGUARD|CONTAINPLASMAMAN
	hides_identity = HIDES_IDENTITY_NEVER
	body_parts_covered = FULL_HEAD|HIDEHAIR

/obj/item/clothing/head/helmet/space/plasmaman
	name = "plasmaman helmet"
	desc = "A special containment helmet designed to protect a plasmaman's volatile body from outside exposure and quickly extinguish it in emergencies."





/obj/item/weapon/melee/defib_basic
	name = "emergency defibrillator"
	desc = "Used to restore fibrillating patients."
	var/defib_delay = 30
	var/ignores_clothes = FALSE

/obj/item/weapon/melee/defib_basic/attack(mob/M, mob/user)
	if(!ishuman(M))
		to_chat(user, "<span class='warning'>You can't defibrillate [M]. You don't even know where to put the [src]!</span>")
	else
		var/mob/living/carbon/human/target = M
		if(!(target.stat == 2 || target.stat == DEAD))
			to_chat(user, "<span class='warning'>[src] buzzes: Vital signs detected.</span>")
		else
			attempt_defib(target, user)
	return

/obj/item/weapon/melee/defib_basic/proc/display_start_message(mob/living/carbon/human/target, mob/user)
	user.visible_message("<span class='notice'>[user] starts setting up the [src] on [target]'s chest.</span>", \
	"<span class='notice'>You start setting up the [src] on [target]'s chest.</span>")

/obj/item/weapon/melee/defib_basic/proc/attempt_defib(mob/living/carbon/human/target, mob/user)
	display_start_message(target, user)
	if(target.mind && !target.client && target.get_heart() && target.get_organ(LIMB_HEAD) && target.has_brain() && !target.mind.suiciding && target.health+target.getOxyLoss() > config.health_threshold_dead)
		target.ghost_reenter_alert("Someone is about to try to defibrillate your body. Return to it if you want to be resurrected!")
	if(do_after(user,target,defib_delay))
		if(pre_defib_check(target, user))
			perform_defib(target, user)
			return TRUE
	return FALSE

/obj/item/weapon/melee/defib_basic/proc/pre_defib_check(mob/living/carbon/human/target, mob/user)
	return TRUE

/obj/item/weapon/melee/defib_basic/proc/post_defib_actions(mob/living/carbon/human/target, mob/user)
	return

/obj/item/weapon/melee/defib_basic/proc/perform_defib(mob/living/carbon/human/target, mob/user)
	spark(src, 5, FALSE)
	playsound(src,'sound/items/defib.ogg',50,1)
	update_icon()
	to_chat(user, "<span class='notice'>You shock [target] with the [src].</span>")
	var/datum/organ/internal/heart/heart = target.get_heart()
	if(!heart)
		target.visible_message("<span class='warning'>[src] buzzes: Defibrillation failed. Subject requires a heart.</span>")
		target.apply_damage(rand(1,5),BURN,LIMB_CHEST)
		return
	var/datum/organ/external/head/head = target.get_organ(LIMB_HEAD)
	if(!head || head.status & ORGAN_DESTROYED)
		target.visible_message("<span class='warning'>[src] buzzes: Defibrillation failed. Severe cranial damage detected.</span>")
		return
	if((M_HUSK in target.mutations) && (M_NOCLONE in target.mutations))
		target.visible_message("<span class='warning'>[src] buzzes: Defibrillation failed. Irremediable genetic damage detected.</span>")
		return
	if(!target.has_brain())
		target.visible_message("<span class='warning'>[src] buzzes: Defibrillation failed. No central nervous system detected.</span>")
		return
	if(!target.has_attached_brain())
		target.visible_message("<span class='warning'>[src] buzzes: Defibrillation failed. Central nervous system detachment detected.</span>")
		return
	if(target.mind && target.mind.suiciding)
		target.visible_message("<span class='warning'>[src] buzzes: Defibrillation failed. Unrecoverable nerve trauma detected.</span>") // They suicided so they fried their brain. Space Magic.
		return
	if(!ignores_clothes)
		if(istype(target.wear_suit,/obj/item/clothing/suit/armor) && (target.wear_suit.body_parts_covered & UPPER_TORSO) && prob(95)) //75 ? Let's stay realistic here
			target.visible_message("<span class='warning'>[src] buzzes: Defibrillation failed. Please apply on bare skin.</span>")
			target.apply_damage(rand(1,5),BURN,LIMB_CHEST)
			return
		if(istype(target.w_uniform,/obj/item/clothing/under) && (target.w_uniform.body_parts_covered & UPPER_TORSO) && prob(50))
			target.visible_message("<span class='warning'>[src] buzzes: Defibrillation failed. Please apply on bare skin.</span>")
			target.apply_damage(rand(1,5),BURN,LIMB_CHEST)
			return
	if(target.mind && !target.client) //Let's call up the ghost! Also, bodies with clients only, thank you.
		target.visible_message("<span class='warning'>[src] buzzes: Defibrillation failed. [target.ghost_reenter_alert("Someone has tried to defibrillate your body. Return to it if you want to be resurrected!") ? "Vital signs are too weak, please try again in five seconds" : "No brainwaves detected"].</span>")
		return
	target.apply_damage(-target.getOxyLoss(),OXY)
	target.updatehealth()
	target.visible_message("<span class='danger'>[target]'s body convulses a bit.</span>")
	if(target.health > config.health_threshold_dead)
		target.timeofdeath = 0
		target.visible_message("<span class='notice'>[src] beeps: Defibrillation successful.</span>")

		target.resurrect()

		target.tod = null
		target.stat = target.status_flags & BUDDHAMODE ? CONSCIOUS : UNCONSCIOUS
		target.regenerate_icons()
		target.update_canmove()
		target.flash_eyes(visual = 1)
		target.apply_effect(10, EYE_BLUR) //I'll still put this back in to avoid dumb "pounce back up" behavior
		target.apply_effect(10, PARALYZE)
		target.update_canmove()
		has_been_shade.Remove(target.mind)
		to_chat(target, "<span class='notice'>You suddenly feel a spark and your consciousness returns, dragging you back to the mortal plane.</span>")
		post_defib_actions(target, user)
	else
		target.visible_message("<span class='warning'>[src] buzzes: Defibrillation failed. Patient's condition does not allow reviving.</span>")
	return

/obj/item/weapon/melee/defib_basic/electric_eel
	name = "defibrillating eel"
	desc = "Slimy... but also a highly versatile weapon."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "electric_eel_full"
	var/charge = 50
	var/max_charge = 50
	var/recharge_rate_per_tick = 0.15
	var/revive_charge_usage = 15
	var/attack_charge_usage = 5

/obj/item/weapon/melee/defib_basic/electric_eel/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/melee/defib_basic/electric_eel/Destroy()
	processing_objects.Remove(src)
	..()


/obj/item/weapon/melee/defib_basic/electric_eel/process()
	charge = min(max_charge, charge + recharge_rate_per_tick)
	update_icon()

/obj/item/weapon/melee/defib_basic/electric_eel/update_icon()
	if(charge > max_charge * 0.7)
		icon_state = "electric_eel_full"
	else if(charge > max_charge * 0.2)
		icon_state = "electric_eel_half"
	else
		icon_state = "electric_eel_low"

/obj/item/weapon/melee/defib_basic/electric_eel/examine(mob/user)
	..()
	if(charge > max_charge * 0.7)
		to_chat(user, "<span class='notice'>It's brimming with electricity!</span>")
	else if(charge > max_charge * 0.3)
		to_chat(user, "<span class='notice'>It's got some electricity in it.</span>")
	else
		to_chat(user, "<span class='notice'>There's hardly any electricity left in it.</span>")

/obj/item/weapon/melee/defib_basic/electric_eel/attack(mob/M, mob/user)
	if(user.a_intent == I_HURT)
		var/charge_fullness = charge / max_charge
		var/electric_damage = rand(5, 17) * charge_fullness
		var/brute_damage = rand(4, 7)
		var/mob/living/carbon/human/H = M
		if(istype(H))
			if (charge > attack_charge_usage && H.electrocute_act(electric_damage, src, def_zone = LIMB_CHEST))
				var/datum/organ/internal/heart/heart = H.get_heart()
				if(heart)
					heart.damage += rand(2,4)
				H.audible_scream()
				charge = max(0, charge - attack_charge_usage)
				playsound(src, "sparks", 70, 1)
			H.adjustBruteLoss(brute_damage)
			spawn()
				user.attack_log += "\[[time_stamp()]\]<font color='red'> Shocked [H] ([H.ckey]) with [src]</font>"
				H.attack_log += "\[[time_stamp()]\]<font color='orange'> Shocked by [user] ([user.ckey]) with [src]</font>"
				log_attack("<font color='red'>[user] ([user.ckey]) shocked [H] ([H.ckey]) with [src]</font>" )
				H.assaulted_by(user)
			playsound(src,'sound/effects/fishslap.ogg', 60, 1)
			if(prob(15))
				user.drop_from_inventory(src)
				user.visible_message("<span class='notice'>[src] slips right out of [user]'s hand!.</span>", \
					"<span class='notice'>[src] slips right out of your hand!</span>")
			update_icon()
		else
			var/mob/living/L = M
			if(istype(L))
				if (charge > attack_charge_usage)
					L.take_organ_damage(burn=electric_damage)
					charge = max(0, charge - attack_charge_usage)
					playsound(L, "sparks", 70, 1)
					spark(L.loc, 5)
				L.take_organ_damage(brute=brute_damage)
				playsound(src,'sound/effects/fishslap.ogg', 60, 1)
				update_icon()
				if(prob(15))
					user.drop_from_inventory(src)
					user.visible_message("<span class='notice'>[src] slips right out of [user]'s hand!.</span>", \
						"<span class='notice'>[src] slips right out of your hand!</span>")
				return
			else
				to_chat(user, "<span class='notice'>You can't hit [M] with the [src]! That's just wrong!</span>")
				return
	else
		return ..()

/obj/item/weapon/defib_basic/proc/electric_eel(mob/living/carbon/human/target, mob/user)
	user.visible_message("<span class='notice'>[user] starts pressing the [src] onto [target]'s chest.</span>", \
	"<span class='notice'>You start pressing the [src] onto [target]'s chest</span>")

/obj/item/weapon/melee/defib_basic/electric_eel/pre_defib_check(mob/living/carbon/human/target, mob/user)
	if(charge < revive_charge_usage)
		to_chat(user, "<span class='notice'>[src] doesn't feel lively enough to revive someone! Wait some time.</span>")
		return FALSE
	return TRUE

/obj/item/weapon/melee/defib_basic/electric_eel/post_defib_actions(mob/living/carbon/human/target, mob/user)
	charge = min(0, charge-revive_charge_usage)


/obj/structure/flora/coconut
	plane = OBJ_PLANE
	name = "Coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"
