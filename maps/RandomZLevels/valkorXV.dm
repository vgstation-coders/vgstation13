//Valkor XV: THE AWAY MISSION

//A grey mining station controlled by the GDR mothership in a contested border system has gone silent.
//Central Command intelligence suggests that the mining operations were aimed at collecting crystallized minerals referred to as "kydarr"
//Central Command has authorized an operation to recover some of these minerals, rescue survivors from a previous NT expedition, and determine the cause of the mining station's shutdown
//A significant reward will be given to the station for any kydarr crystals that are shipped to Central Command

//////////////////////////////
// MISSION
//////////////////////////////
/datum/map_element/away_mission/valkor_xv
	name = "Valkor_XV"
	file_path = "maps/RandomZLevels/Valkor_XV.dmm"
	desc = "A grey mining station in a contested border system has gone offline. Send a team from the station to rendevous with Nanotrasen's expeditionary forces on site. The main objectives are to recover samples of the crystals that the greys were excavating, and discover the cause behind the mining station's shutdown."

/datum/map_element/away_mission/valkor_xv/pre_load()
	..()
	// Load the other levels
	load_dungeon(/datum/map_element/dungeon/upper_caves)
	load_dungeon(/datum/map_element/dungeon/deep_caves)

//////////////////////////////
// AREAS
//////////////////////////////
/area/awaymission/planet_NTfob // The "safe" area
	name = "\improper Nanotrasen FOB"
	icon_state = "centcom-ert"
	requires_power = 0
	flags = NO_PACIFICATION
	base_turf_type = /turf/unsimulated/floor/grey_sand

/area/awaymission/planet_caves // Here be monsters
	name = "\improper Valkor XV Caves"
	icon_state = "cave"
	flags = NO_PACIFICATION
	base_turf_type = /turf/unsimulated/floor/grey_cave

/area/awaymission/deep_caves // Here be more monsters
	name = "\improper Valkor XV Deep Caves"
	icon_state = "mothershiplab_cavemaint"
	jammed = 2 // Teleportation won't be saving ya here, laddie
	flags = NO_PACIFICATION
	base_turf_type = /turf/unsimulated/floor/grey_cave_deep

//////////////////////////////
// FLOORS
//////////////////////////////
/turf/simulated/floor/plating/grey_planet
	icon_state = "plating"
	name = "FOB plating"
	temperature = T20C

/turf/simulated/floor/plating/grey_planet/New()
	..()
	name = "plating"

/turf/unsimulated/floor/grey_sand
	name = "chalky soil"
	icon = 'icons/turf/floors.dmi'
	icon_state = "xeno_rock_tile_1"
	temperature = T20C
	plane = PLATING_PLANE

/turf/unsimulated/floor/grey_sand/New()
	..()
	if(prob(33))
		icon_state = "xeno_rock_tile_[rand(1,12)]"

/turf/unsimulated/floor/grey_cave
	name = "stone floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "xenorockfloor_uc_1"
	temperature = T0C - 25
	plane = PLATING_PLANE

/turf/unsimulated/floor/grey_cave/New()
	..()
	icon_state = "xenorockfloor_uc_[rand(1,5)]"
	if(prob(25))
		overlay_state = "xenorock_overlay_[rand(1,5)]"
		add_rock_overlay()

/turf/unsimulated/floor/grey_cave/add_rock_overlay(var/image/img = image('icons/turf/overlays.dmi', overlay_state,layer = SIDE_LAYER),var/offset=-4) // Overlay stuff
	if(!overlay_state || overlay_state == "")
		return
	img.pixel_x = offset*PIXEL_MULTIPLIER
	img.pixel_y = offset*PIXEL_MULTIPLIER
	img.plane = ABOVE_TURF_PLANE
	overlays += img

/turf/unsimulated/floor/grey_cave/Entered(atom/A, atom/OL) // The planet's caves are lightly radioactive, and a bit cold
	..()
	if(istype(A,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = A
		if(prob(15))
			H.apply_radiation(1,RAD_EXTERNAL)

/turf/unsimulated/floor/grey_cave_deep
	name = "stone floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "xenorockfloor_dc_1"
	temperature = T0C - 50

/turf/unsimulated/floor/grey_cave_deep/New()
	..()
	icon_state = "xenorockfloor_dc_[rand(1,5)]"
	if(prob(25))
		overlay_state = "xenorock_overlay_[rand(1,5)]"
		add_rock_overlay()

/turf/unsimulated/floor/grey_cave_deep/Entered(atom/A, atom/OL) // The deeper caves are more radioactive, and even colder. Hope you brought your wool socks!
	..()
	if(istype(A,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = A
		if(prob(15))
			H.apply_radiation(3,RAD_EXTERNAL)

/turf/unsimulated/floor/acid_lake // Now probably isn't the time for a swim
	name = "acid lake"
	icon = 'icons/turf/floors.dmi'
	icon_state = "acid_tile"

/turf/unsimulated/floor/acid_lake/Entered(atom/A, atom/OL) // Entering these tiles is a horrible idea, unless you have an acid proofed rigsuit, or are flying
	..()
	if(istype(A,/obj/item)) // An object that isn't acid proof will melt away and be lost
		var/obj/item/O = A
		playsound(src, 'sound/effects/grue_burn.ogg', 50, 1) // Audio feedback is always good, so a player knows something just happened.
		if(O.dissolvable() == PACID)
			src.visible_message("<span class='danger'>\the [O] melts away on contact with the acid!</span>")
			qdel(O)
		if(!(O.dissolvable() == PACID))
			src.visible_message("<span class='danger'>\the [O] sizzles on contact with the acid, but remains intact.</span>")

	if(istype(A,/mob/living/simple_animal))
		var/mob/living/simple_animal/L = A
		if(L.on_foot()) // If the mob is flying, nothing happens
			if(L.acidimmune == 1)
				return
			else // If it's on foot and it isn't acid immune, rip
				src.visible_message("<span class='danger'>\the [L] falls into the acid and melts away!</span>")
				playsound(src, 'sound/effects/grue_burn.ogg', 50, 1)
				qdel(L)

//////////////////////////////
// WALLS
//////////////////////////////
/turf/unsimulated/wall/grey_planet // Dense rock walls that will border the map edges and serve as obstacles that need to be moved around, not dug through
	name = "thick rock wall"
	desc = "An incredibly dense wall, composed of some strange alien minerals."
	icon = 'icons/turf/walls.dmi'
	icon_state = "xenorockwall"
	overlay_state = "xenorockwall_overlay"
	explosion_block = 9999

/turf/unsimulated/wall/grey_planet/New() // Add dat overlay
	..()
	add_rock_overlay()

/turf/unsimulated/wall/grey_planet/add_rock_overlay(var/image/img = image('icons/turf/rock_overlay.dmi', overlay_state,layer = SIDE_LAYER),var/offset=-4) // Overlay stuff
	if(!overlay_state || overlay_state == "")
		return
	img.pixel_x = offset*PIXEL_MULTIPLIER
	img.pixel_y = offset*PIXEL_MULTIPLIER
	img.plane = BELOW_TURF_PLANE
	overlays += img

//////////////////////////////
// CAVES: FLORA, ACID PUDDLES, CRYSTALS, AND MISC STRUCTURES
//////////////////////////////
/obj/structure/flora/xeno_flora
	name = "oork reed"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "oork_grown"
	anchored = 1
	shovelaway = TRUE

/obj/structure/flora/xeno_flora/blue
	name = "bvvak blossoms"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "bvvak_grown"

/obj/structure/acid_puddle // One of the more dangerous obstacles in the caves. Will melt shoes away, followed by feet if a careless spaceman runs over them
	name = "sizzling puddle"
	icon = 'icons/obj/acidcloset.dmi'
	icon_state = "acidpuddle_uc_1"
	desc = "Watch your step..."
	anchored = 1

/obj/structure/acid_puddle/New()
	..()
	icon_state = "acidpuddle_uc_[rand(1,3)]"

/obj/structure/acid_puddle/splashable()
	return FALSE

/obj/structure/acid_puddle/Crossed(AM)
	if(isliving(AM) && isturf(src.loc))

		var/mob/living/L = AM

		if(L.on_foot()) //Flying mobs won't suffer the consequences of stepping in the acid, nor will lying mobs (we're assuming they're being smart and crawling around the pool)
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				if(H.m_intent == "run") // Running over the sizzling puddles has a 60% chance of stepping in them, to nasty results
					if(prob(60))
						to_chat(H, "<span class='warning'>You step in [src]!</span>")
						var /obj/item/clothing/shoes/melting_shoes = H.shoes
						playsound(src, 'sound/effects/grue_burn.ogg', 50, 1) // Audio feedback is always good, so a player knows something just happened.

						if(melting_shoes && !(melting_shoes.dissolvable() == PACID)) // Are our shoes acid proof? Lucky us!
							to_chat(H, "<span class='warning'>Your footwear sizzles on contact, but remains intact.</span>")

						if(melting_shoes && (melting_shoes.dissolvable() == PACID)) // If not, they melt away. Still not the worst that can happen.
							to_chat(H, "<span class='warning'>Your footwear sizzles on contact, and dissolves!</span>")
							H.drop_from_inventory(melting_shoes)
							qdel(melting_shoes)
							new/obj/effect/decal/cleanable/molten_item(H.loc)

						if(!melting_shoes && isgrey(H)) // Are we a grey? We don't have any trouble with acid, even barefoot.
							to_chat(H, "<span class='warning'>You feel a slight tingling as you step in [src], but it quickly subsides.</span>")

						if(!melting_shoes && !isgrey(H)) // Otherwise we just lost a foot. How unfortunate.
							var/datum/organ/external/foot_organ = H.pick_usable_organ(LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT)
							to_chat(H, "<span class='danger'>You feel a horrific pain as you step in [src], and your foot melts away!</span>")
							H.audible_scream()
							foot_organ.droplimb(1, 0, 0)

						else
							return
					else
						to_chat(H, "<span class='warning'>You stumble over [src], barely avoiding stepping in it!</span>") // Fair warning to be careful, if you were spared.

				else // Walking is safe
					to_chat(H, "<span class='notice'>You step carefully over [src].</span>")
					return

/obj/structure/acid_puddle/deep_cave
	icon_state = "acidpuddle_dc_1"

/obj/structure/acid_puddle/deep_cave/New()
	..()
	icon_state = "acidpuddle_dc_[rand(1,3)]"

/obj/structure/xeno_crystals // One of the main objectives of the expedition, radioactive crystals that give off harvestable energy. Handle with care!
	name = "kydarr crystal cluster"
	icon = 'icons/obj/flora/rocks.dmi'
	icon_state = "xeno_crystal"
	desc = "The crystals in this cluster give off a hazy glow."
	anchored = 1
	light_color = "#C3E5BD"

	var/busy = 0 //No message spam, thanks
	var/harvested = FALSE

	var/radiation_range = 8
	var/radiation_power = 12

	var/radiation_cooldown = 10 SECONDS
	var/last_pulse
	var/trip_chance = 60

/obj/structure/xeno_crystals/New()
	..()
	set_light(3)
	processing_objects.Add(src)

/obj/structure/xeno_crystals/process() // Radiation pulses, repurposed from the hive away mission. Thank you to that author
	if((last_pulse + radiation_cooldown < world.time) && prob(15))
		last_pulse = world.time

		emit_radiation(radiation_range, radiation_power)

/obj/structure/xeno_crystals/proc/emit_radiation(rad_range, rad_power)
	for(var/mob/living/carbon/M in range(src, rad_range))
		var/mob/living/carbon/human/H = M
		var/msg
		if(istype(H) && H.species && H.species.flags & RAD_ABSORB)
			msg = pick(\
			"You feel curiously warm.",\
			"You receive a small dose of radiation.",\
			"You feel a negligible tingling sensation.")
		else
			msg = pick(\
			"You hear a slow clicking.",\
			"Your head begins to hurt.",\
			"You feel tired.",\
			"You feel mildly nauseated.")

		to_chat(M, "<span class='warning'>[msg]</span>")
		M.apply_radiation(rad_power, RAD_EXTERNAL)

/obj/structure/xeno_crystals/proc/harvest() // If someone drills a chunk off, light gets dimmer, icon state updates to the harvested version
	harvested = TRUE

	radiation_range = 4 // Harvested crystals still emit some radiation, but less and at a much shorter range
	radiation_power = 6
	trip_chance = 30

	icon_state = "xeno_crystal_mined"
	desc = "The crystals in this cluster give off a hazy glow. A large chunk has been harvested."
	set_light(2)

/obj/structure/xeno_crystals/Crossed(AM)
	if(isliving(AM) && isturf(src.loc))

		var/mob/living/L = AM

		if(L.on_foot()) //Flying mobs won't trip over the crystals, nor will lying mobs
			if (ishuman(L))
				var/mob/living/carbon/human/H = L
				if(H.m_intent == "run") // Running over the crystal clusters has a 60% chance of making you trip
					if(prob(trip_chance))
						to_chat(H, "<span class='warning'>You trip over the crystal cluster!</span>")
						H.Knockdown(4)
						H.adjustBruteLoss(1) // Ow, my shin!
						playsound(src, 'sound/weapons/thudswoosh.ogg', 50, 1) // Audio feedback is always good, so a player knows something just happened.
					else
						to_chat(H, "<span class='warning'>You stumble over the crystal cluster!</span>")
				else // Walking is safe
					to_chat(H, "<span class='notice'>You step carefully over the crystal cluster.</span>")
					return

/obj/structure/xeno_crystals/attackby(obj/item/weapon/W as obj, mob/user as mob) // We're mining up crystals!
	if (istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/P = W

		if(harvested == TRUE)
			to_chat(user, "<span class='warning'>This crystal cluster has already been harvested.</span>")
			return

		if(!(P.diggables & DIG_ROCKS))
			return

		to_chat(user, "<span class='rose'>You start [P.drill_verb] [src].</span>")

		busy = 1

		if(do_after(user,src, (MINE_DURATION * P.toolspeed)))

			busy = 0

			to_chat(user, "<span class='notice'>You finish [P.drill_verb] [src].</span>")
			if(prob(60)) // Make some crystals, now in portable item form. Most likely you will drill up three
				new /obj/item/xeno_crystal(src.loc)
				new /obj/item/xeno_crystal(src.loc)
				new /obj/item/xeno_crystal(src.loc)
				playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1) // Audio feedback is always good.
				harvest()
			else // But there's a chance of getting one less
				new /obj/item/xeno_crystal(src.loc)
				new /obj/item/xeno_crystal(src.loc)
				playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1) // Audio feedback is always good.
				harvest()

		else
			busy = 0

/obj/structure/xeno_crystals/harvested // Harvested version, gives a hint that the previous expedition came through here
	icon_state = "xeno_crystal_mined"
	desc = "The crystals in this cluster give off a hazy glow. A large chunk has been harvested."

	radiation_range = 4
	radiation_power = 6
	trip_chance = 30

	harvested = TRUE

/obj/structure/xeno_crystals/harvested/New()
	..()
	set_light(2)

/obj/structure/squid_burrow // A burrow that occasionally spawns xeno squids if a player is nearby
	name = "strange burrow"
	icon = 'icons/obj/flora/rocks.dmi'
	icon_state = "squid_burrow"
	desc = "It looks like something tunneled into the rock here..."
	anchored = 1

	var/squidspawn_cooldown = 40 SECONDS
	var/last_spawn

/obj/structure/squid_burrow/New()
	..()
	processing_objects.Add(src)

/obj/structure/squid_burrow/process() // Handles spawning the squid if a human is in range
	if(last_spawn + squidspawn_cooldown < world.time)

		for(var/mob/living/carbon/human/H in range(4,src))
			visible_message("<span class = 'warning'>A podapiida clambers out of the burrow!</span>")
			new /mob/living/simple_animal/hostile/podapiida(get_turf(src))
			last_spawn = world.time

/obj/structure/squid_burrow/deep_caves // Deep cave version with slightly darker sprite
	icon_state = "squid_burrow2"

/obj/structure/xeno_boulder // Less dense mineral walls that can be drilled through.
	name = "alien rock debris"
	desc = "An rather brittle wall, composed of some strange alien minerals."
	icon = 'icons/obj/mining.dmi'
	icon_state = "xeno_boulder"
	density = 1
	opacity = 1
	anchored = 1
	var/busy = 0 //No message spam, thanks

/obj/structure/xeno_boulder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/P = W

		if(!(P.diggables & DIG_ROCKS))
			return

		to_chat(user, "<span class='rose'>You start [P.drill_verb] [src].</span>")

		busy = 1

		if(do_after(user,src, (MINE_DURATION * P.toolspeed)))

			busy = 0

			to_chat(user, "<span class='notice'>You finish [P.drill_verb] [src].</span>")

			if(prob(5)) // A 1 in 20 chance of getting a single crystal per rocky debris mined, so there's a reason to drill them besides getting them out of the way!
				to_chat(user, "<span class='warning'>A crystal was hidden within!</span>")
				new /obj/item/xeno_crystal(src.loc)
				playsound(src, 'sound/effects/stone_crumble.ogg', 100, 1) // Audio feedback is always good.
				qdel(src)
			else
				playsound(src, 'sound/effects/stone_crumble.ogg', 100, 1) // Audio feedback is always good.
				qdel(src)

		else
			busy = 0

//////////////////////////////
// MISC ITEMS (CRYSTAL, BAG, CLOSETS/CRATES)
//////////////////////////////
/obj/item/xeno_crystal // To-Do: Make it shatter and create a small radioactive pulse when thrown
	name = "kydarr crystal"
	desc = "A smooth alien crystal harvested from a cluster. It's oddly warm to the touch."
	icon = 'icons/obj/mining.dmi'
	icon_state = "xeno_crystal"
	w_class = W_CLASS_TINY
	light_color = "#C3E5BD"

/obj/item/xeno_crystal/New() // Still gives off some light
	..()
	set_light(2)

/obj/item/weapon/storage/bag/materials/crystal // A bag to speed up crystal collecting
	icon = 'icons/obj/hydroponics/hydro_tools.dmi'
	icon_state = "matsbag"
	name = "Crystal Bag"
	desc = "Can hold a large quantity of kydarr crystals."
	storage_slots = 50; //the number of crystals it can carry.
	fits_max_w_class = 3
	max_combined_w_class = 200
	w_class = W_CLASS_TINY
	can_only_hold = list("/obj/item/xeno_crystal")
	display_contents_with_number = TRUE

/obj/structure/closet/crate/xeno_crystal // Renamed radiation crate for storing crystals. There will be a few of these filled with crystals from the work of the previous expedition.
	desc = "A crate with a radiation sign on it, meant for storing radioactive crystals."
	name = "crystal storage crate"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "radiation"
	density = 1
	icon_opened = "radiationopen"
	icon_closed = "radiation"

/obj/structure/closet/radiation_armor // Closet that contains many of the bare essentials for the intrepid cave explorer
	name = "armored radiation suit closet"
	desc = "It's a storage unit for rad-protective suits with some integrated armor."
	icon_state = "radsuitcloset"
	icon_opened = "toolclosetopen"
	icon_closed = "radsuitcloset"

/obj/structure/closet/radiation_armor/atoms_to_spawn()
	return list(
		/obj/item/clothing/suit/radiation/armored = 2,
		/obj/item/clothing/head/radiation = 2,
		/obj/item/weapon/tank/emergency_oxygen/double = 2,
		/obj/item/device/geiger_counter = 2,
		/obj/item/device/gps/mining = 2,
	)

//////////////////////////////
// ARMORED RADIATION SUIT (A unique radsuit with some integrated armor. Quickly codersprited by layering an armor vest over the standard radsuit)
//////////////////////////////
/obj/item/clothing/suit/radiation/armored // Unlike a default radsuit, it offers the wearer a little protection from melee and lasers. It can also hold a gun in its storage slot.
	name = "armored radiation suit"
	desc = "A suit that protects against radiation. It has been modified with some additional armor plates."
	icon_state = "rad_armored"
	item_state = "rad_armored"
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen, /obj/item/weapon/gun/energy, /obj/item/weapon/gun/projectile)
	armor = list(melee = 30, bullet = 5, laser = 15,energy = 5, bomb = 15, bio = 60, rad = 100)

//////////////////////////////
// ALIEN SQUID MASK (Oh no...)
//////////////////////////////
/obj/item/clothing/mask/podapiida
	name = "podapiida"
	desc = "A squid-like creature, possessing bulbous sacs full of an unknown icor."
	icon = 'icons/mob/animal.dmi'
	icon_state = "xenosquid_latched"
	item_state = "xenosquid"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 25, rad = 100)
	body_parts_covered = FULL_HEAD
	slot_flags = SLOT_HEAD
	canremove = 0  // You need to resist out of it.
	cant_remove_msg = " is latched on tight!"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED, GREY_SHAPED)
	var/is_being_resisted = 0
	var/countdown_start
	var/assimilation_countdown = 45 SECONDS

/obj/item/clothing/mask/podapiida/New()
	..()
	processing_objects.Add(src)

/obj/item/clothing/mask/podapiida/process() // Heals its host from most common damage types while equipped
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(prob(15))
			to_chat(H, "<span class='sinister'>[pick("You feel something probing at your mind...","Assimilate, consume...","You feel ravenously hungry...","Malevolent whispers are scratching at your mind...","GET OUT OF MY HEAD.")]</span>")
			switch(rand(1,3)) // But applies several other nasty effects as well
				if(1)
					H.hallucination += 75
					H.adjustBrainLoss(10)
				if(2)
					H.nutrition -= 100
					H.vomit()
				if(3)
					H.pain_shock_stage += 100
					H.audible_scream()
		if(H.getOxyLoss())
			H.adjustOxyLoss(-5)
		if(H.getBruteLoss())
			H.heal_organ_damage(5)
		if(H.getFireLoss())
			H.heal_organ_damage(5)
		if(H.getToxLoss())
			H.adjustToxLoss(-5)
	if(ishuman(loc) && (countdown_start + assimilation_countdown < world.time)) // When time is up, it takes full control of the host. Turning them into... a ZOMBIE
		var/mob/living/carbon/human/H = loc
		Assume_Control(H)

/obj/item/clothing/mask/podapiida/equipped(mob/living/carbon/human/H)
	countdown_start = world.time
	if(H.isDead())
		Drop_Off(H)

/obj/item/clothing/mask/podapiida/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/target = user
		if(target && target.head == src)
			target.resist()
		else
			..()

/obj/item/clothing/mask/podapiida/proc/Drop_Off(mob/living/L) // Called in a variety of checks in case the host died prematurely
	L.drop_from_inventory(src)
	L.visible_message("<span class='danger'>\the [src] releases its grip from [L]'s head!</span>")
	var/mob/living/simple_animal/hostile/podapiida/P = new /mob/living/simple_animal/hostile/podapiida(get_turf(src))
	P.recover_start = world.time
	P.recovering = TRUE
	qdel(src)

/obj/item/clothing/mask/podapiida/proc/Assume_Control(mob/living/L) // Time is up, let's zombify the host
	var/mob/living/carbon/human/target = L
	if(target.head != src) // Was taken off or something
		return

	if(target.isDead()) //They died? Fug. Drop off and find a new host
		Drop_Off(target)

	if(target.head == src && !target.isDead())
		visible_message("<span class='danger'>[target.real_name] begins to shake and convulse violently!</span>")
		to_chat(target, "<span class='sinister'>You feel something taking control of your mind as your consciousness slips away...</span>")
		target.Stun(30)
		target.Jitter(500)
		sleep(150)
		target.remove_jitter()
		if(target.head == src)
			if(target.isDead())	//They died? Fug. Drop off and find a new host
				Drop_Off(target)
				return
			target.death(0)
			playsound(src, 'sound/hallucinations/wail.ogg', 100, 1)
			var/mob/living/simple_animal/hostile/necro/zombie/xeno_squid/Z = target.zombify(retain_mind = 1, podazombie = 1)
			Z.poda = src
			to_chat(Z, text("<span class='warning'>You are a podapiida, a parasitic creature that assimilates and devours sapient lifeforms.</span>"))
			to_chat(Z, text("<span class='warning'>Find more sapient lifeforms like the one you have thralled.</span>"))
			to_chat(Z, text("<span class='warning'>Help other podapiida assimilate them, and grow your numbers.</span>"))
			to_chat(Z, text("<span class='warning'>What you cannot assimilate, devour.</span>"))

//////////////////////////////
// CORPSES
//////////////////////////////
/obj/effect/landmark/corpse/miner/xeno_expedition
	name = "Miner"
	corpseback = /obj/item/weapon/tank/oxygen
	corpseshoes = /obj/item/clothing/shoes/workboots
	corpsehelmet = /obj/item/clothing/head/radiation
	corpsesuit = /obj/item/clothing/suit/radiation/armored
	corpsemask = /obj/item/clothing/mask/breath
	corpsebelt = /obj/item/weapon/storage/bag/materials/crystal
	corpseradio = /obj/item/device/radio/headset/headset_mining
	corpseid = 1
	corpseidjob = "NT Expedition Miner"
	corpseidaccess = "Shaft Miner"
	corpseidicon = "cargo"

	suit_sensors = 3

/obj/effect/landmark/corpse/miner/xeno_expedition/insectoid // Makes sense NT would contract some insectoids to help on this dig.
	mutantrace = "Insectoid"

/obj/effect/landmark/corpse/miner/xeno_expedition_zombie //Squid zombie miner corpses don't have their masks or helmet
	name = "Miner"
	corpseback = /obj/item/weapon/tank/oxygen
	corpseshoes = /obj/item/clothing/shoes/workboots
	corpsesuit = /obj/item/clothing/suit/radiation/armored
	corpsebelt = /obj/item/weapon/storage/bag/materials/crystal
	corpseradio = /obj/item/device/radio/headset/headset_mining
	corpseid = 1
	corpseidjob = "NT Expedition Miner"
	corpseidaccess = "Shaft Miner"
	corpseidicon = "cargo"

	suit_sensors = 3

/obj/effect/landmark/corpse/miner/xeno_expedition_zombie/insectoid
	mutantrace = "Insectoid"
