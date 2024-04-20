/datum/map_element/vault/mothership_lab
	name = "Mothership Lab"
	file_path = "maps/randomvaults/mothership_lab.dmm"
	spawn_cost = 5

	can_rotate = 0 // I doubt it would work

/datum/map_element/vault/mothership_lab/pre_load()
	// Load the two other levels
	load_dungeon(/datum/map_element/dungeon/habitation)
	load_dungeon(/datum/map_element/dungeon/research)

//////////////////////////////
// AREAS
//////////////////////////////

/area/vault/mothership_lab
	name = "Mothership Lab"

/area/vault/mothership_lab/asteroid
	name = "\improper Mothership Lab Asteroid"
	icon_state = "mothershiplab_asteroid"
	requires_power = 0
	jammed = 2
	flags = NO_PACIFICATION

/area/vault/mothership_lab/hobo
	name = "\improper Mothership Lab Hobo Shack"
	icon_state = "firingrange"
	requires_power = 1
	jammed = 2
	flags = NO_PACIFICATION

/area/vault/mothership_lab/entrance
	name = "\improper Mothership Lab Entry Level"
	icon_state = "mothershiplab_entrydeck"
	requires_power = 0
	jammed = 2
	flags = NO_PACIFICATION

/area/vault/mothership_lab/cave
	name = "\improper Mothership Lab Abandoned Maint"
	icon_state = "mothershiplab_cavemaint"
	requires_power = 0
	jammed = 2
	flags = NO_PACIFICATION

/area/vault/mothership_lab/raidtunnel_upper
	name = "\improper Mothership Lab Raider Tunnel"
	icon_state = "mothershiplab_raidertunnel"
	requires_power = 0
	jammed = 2
	flags = NO_PACIFICATION

/area/vault/mothership_lab/raidtunnel_lower
	name = "\improper Mothership Lab Raider Tunnel"
	icon_state = "mothershiplab_raidertunnel"
	requires_power = 0
	jammed = 2
	flags = NO_PACIFICATION

/area/vault/mothership_lab/habitation
	name = "\improper Mothership Lab Habitation Level"
	icon_state = "mothershiplab_habitdeck"
	requires_power = 0
	jammed = 2
	flags = NO_PACIFICATION

/area/vault/mothership_lab/research
	name = "\improper Mothership Lab Research Level"
	icon_state = "mothershiplab_researchdeck"
	requires_power = 0
	jammed = 2
	flags = NO_PACIFICATION

/area/vault/mothership_lab/samplestorage
	name = "\improper Mothership Lab Sample Storage"
	icon_state = "mothershiplab_researchsamples"
	requires_power = 0
	jammed = 2
	flags = NO_PACIFICATION

/area/vault/mothership_lab/armory
	name = "\improper Mothership Lab Armory"
	icon_state = "mothershiplab_armory"
	requires_power = 0
	jammed = 2
	flags = NO_PACIFICATION

/area/vault/mothership_lab/maintenance
	name = "\improper Mothership Lab Laborer Level"
	icon_state = "mothershiplab_laborerdeck"
	requires_power = 0
	jammed = 2
	flags = NO_PACIFICATION

/area/vault/mothership_lab/administration
	name = "\improper Mothership Lab Administrator's Quarters"
	icon_state = "mothershiplab_leaderdeck"
	requires_power = 0
	jammed = 2
	flags = NO_PACIFICATION

/area/vault/mothership_lab/control_room
	name = "\improper Mothership Lab Control Room"
	icon_state = "mothershiplab_controlroom"
	requires_power = 0
	jammed = 2
	flags = NO_PACIFICATION

//////////////////////////////
// WALLS (Invulnerable ayy-themed walls, applied to appropriate areas to prevent escaping the vault to the Centcomm Z-level, or tunneling into boss rooms)
//////////////////////////////

/turf/unsimulated/wall/ayy
	name = "alien alloy wall"
	desc = "A solid wall of an unknown alloy. It's oddly warm to the touch, and seems to pulse rhymically."
	icon_state = "alloy"
	explosion_block = 9999
	walltype = "alloy"

/turf/unsimulated/wall/ayy/canSmoothWith() // SMOOTH DAT WALL
	var/static/list/smoothables = list(/turf/unsimulated/wall/ayy)
	return smoothables

/turf/unsimulated/wall/r_rock
	name = "riveted porous rock"
	desc = "Asteroid rock reinforced by a wall with massive rivets embedded in the struts."
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock_rf"
	explosion_block = 9999
	walltype = "rock_rf"

/turf/unsimulated/wall/r_rock/canSmoothWith() // SMOOTH DAT WALL
	var/static/list/smoothables = list(/turf/unsimulated/wall/r_rock)
	return smoothables

//////////////////////////////
// FLOORS (Some ayy-themed floors, with walking sound effects!)
//////////////////////////////

/turf/unsimulated/floor/ayy
	name = "alien plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "alien_tile1"
	temperature = T20C
	plane = PLATING_PLANE

/turf/unsimulated/floor/ayy/Entered(atom/A, atom/OL) // Ayy alloy tiles play walking sound effects!
	..()
	if(istype(A,/mob/living/simple_animal))
		var/mob/living/simple_animal/L = A
		if(L.on_foot() && prob(33)) // If the mob is flying, nothing happens. But if it's walking, 33% chance to play a sound effect
			if(prob(50))
				playsound(src, 'sound/effects/metal_walk.ogg', 50, 0)
			else
				playsound(src, 'sound/effects/metal_walk2.ogg', 50, 0)

	if(istype(A,/mob/living/carbon))
		var/mob/living/carbon/M = A
		if(M.on_foot() && prob(33)) // If the mob is flying, nothing happens. But if it's walking, 33% chance to play a sound effect
			if(prob(50))
				playsound(src, 'sound/effects/metal_walk.ogg', 50, 0)
			else
				playsound(src, 'sound/effects/metal_walk2.ogg', 50, 0)

/turf/unsimulated/floor/ayy/tech
	name = "alien plating"
	icon_state = "alien_tile2"

/turf/unsimulated/floor/ayy/maint
	name = "worn alien plating"
	icon_state = "alien_tile_worn"

/turf/unsimulated/floor/ayy/fancy
	name = "ornate alien plating"
	icon_state = "alien_tile_fancy"

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

/turf/unsimulated/floor/grey_sand/Entered(atom/A, atom/OL) // Ayy dirt tiles play walking sound effects!
	..()
	if(istype(A,/mob/living/simple_animal))
		var/mob/living/simple_animal/L = A
		if(L.on_foot() && prob(33)) // If the mob is flying, nothing happens. But if it's walking, 33% chance to play a sound effect
			if(prob(50))
				playsound(src, 'sound/effects/sand_walk1.ogg', 50, 0)
			else
				playsound(src, 'sound/effects/sand_walk2.ogg', 50, 0)

	if(istype(A,/mob/living/carbon))
		var/mob/living/carbon/M = A
		if(M.on_foot() && prob(33)) // If the mob is flying, nothing happens. But if it's walking, 33% chance to play a sound effect
			if(prob(50))
				playsound(src, 'sound/effects/sand_walk1.ogg', 50, 0)
			else
				playsound(src, 'sound/effects/sand_walk2.ogg', 50, 0)

/turf/unsimulated/floor/lab_asteroid
	name = "Asteroid"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	temperature = T20C
	plane = PLATING_PLANE

/turf/unsimulated/floor/lab_asteroid/New()
	..()
	if(prob(20))
		icon_state = "asteroid[rand(0,12)]"

/turf/unsimulated/floor/lab_asteroid/Entered(atom/A, atom/OL) // These play walking sound effects!
	..()
	if(istype(A,/mob/living/simple_animal))
		var/mob/living/simple_animal/L = A
		if(L.on_foot() && prob(33)) // If the mob is flying, nothing happens. But if it's walking, 33% chance to play a sound effect
			if(prob(50))
				playsound(src, 'sound/effects/sand_walk1.ogg', 50, 0)
			else
				playsound(src, 'sound/effects/sand_walk2.ogg', 50, 0)

	if(istype(A,/mob/living/carbon))
		var/mob/living/carbon/M = A
		if(M.on_foot() && prob(33)) // If the mob is flying, nothing happens. But if it's walking, 33% chance to play a sound effect
			if(prob(50))
				playsound(src, 'sound/effects/sand_walk1.ogg', 50, 0)
			else
				playsound(src, 'sound/effects/sand_walk2.ogg', 50, 0)

/turf/unsimulated/floor/lab_underplating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "Floor3"
	temperature = T20C
	plane = PLATING_PLANE

/turf/unsimulated/floor/lab_underplating/Entered(atom/A, atom/OL) // These play walking sound effects!
	..()
	if(istype(A,/mob/living/simple_animal))
		var/mob/living/simple_animal/L = A
		if(L.on_foot() && prob(33)) // If the mob is flying, nothing happens. But if it's walking, 33% chance to play a sound effect
			if(prob(50))
				playsound(src, 'sound/effects/metal_walk.ogg', 50, 0)
			else
				playsound(src, 'sound/effects/metal_walk2.ogg', 50, 0)

	if(istype(A,/mob/living/carbon))
		var/mob/living/carbon/M = A
		if(M.on_foot() && prob(33)) // If the mob is flying, nothing happens. But if it's walking, 33% chance to play a sound effect
			if(prob(50))
				playsound(src, 'sound/effects/metal_walk.ogg', 50, 0)
			else
				playsound(src, 'sound/effects/metal_walk2.ogg', 50, 0)

/turf/unsimulated/floor/lab_sterile
	name = "sterile tile floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "freezerfloor"
	temperature = T20C
	plane = PLATING_PLANE

/turf/unsimulated/floor/lab_sterile/Entered(atom/A, atom/OL) // These play walking sound effects!
	..()
	if(istype(A,/mob/living/simple_animal))
		var/mob/living/simple_animal/L = A
		if(L.on_foot() && prob(33)) // If the mob is flying, nothing happens. But if it's walking, 33% chance to play a sound effect
			if(prob(50))
				playsound(src, 'sound/effects/tile_walk1.ogg', 50, 0)
			else
				playsound(src, 'sound/effects/tile_walk2.ogg', 50, 0)

	if(istype(A,/mob/living/carbon))
		var/mob/living/carbon/M = A
		if(M.on_foot() && prob(33)) // If the mob is flying, nothing happens. But if it's walking, 33% chance to play a sound effect
			if(prob(50))
				playsound(src, 'sound/effects/tile_walk1.ogg', 50, 0)
			else
				playsound(src, 'sound/effects/tile_walk2.ogg', 50, 0)

//////////////////////////////
// DECORATIVE FLORA (Some nice things to go in the facility's petting zoo and plant decorations)
//////////////////////////////

/obj/structure/flora/xeno_flora
	name = "oork reed"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "xeno_plant_1"
	anchored = 1
	shovelaway = TRUE

/obj/structure/flora/xeno_flora/blue
	name = "bvvak blossoms"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "xeno_plant_2"

/obj/structure/acid_puddle // What in the goddamn...
	name = "sizzling puddle"
	icon = 'icons/obj/acidcloset.dmi'
	icon_state = "acid_puddle"
	desc = "Watch your step..."
	anchored = 1

/obj/structure/acid_puddle/splashable()
	return FALSE

/obj/structure/acid_puddle/Crossed(AM)
	if(isliving(AM) && isturf(src.loc))

		var/mob/living/L = AM

		if(L.on_foot()) //Flying mobs won't suffer the consequences of stepping in the acid, nor will lying mobs (we're assuming they're being smart and crawling around the pool)
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				if(H.m_intent == "run") // Running over the puddle has a 60% chance of stepping in it, to nasty results
					if(prob(60))
						to_chat(H, "<span class='warning'>You step in [src]!</span>")
						var /obj/item/clothing/shoes/melting_shoes = H.shoes
						playsound(src, 'sound/effects/grue_burn.ogg', 50, 1) // Audio feedback is always good, so a player knows something just happened.

						if(melting_shoes && !(melting_shoes.dissolvable() == PACID)) // Are our shoes acid proof? Lucky us!
							to_chat(H, "<span class='warning'>Your footwear sizzles on contact, but remains intact.</span>")

						if(melting_shoes && (melting_shoes.dissolvable() == PACID)) // If not, they melt away. Still not the worst thing that can happen.
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

//////////////////////////////
// FURNITURE AND LOCKERS (Ayys need nice places to sit, lie down, and store their gear)
//////////////////////////////

/obj/structure/bed/chair/comfy/ayy1
	icon_state = "ayychair1"
	name = "GDR chair"
	desc = "A plain chair manufactured by greys for other greys. Average comfort, but much better than a stool."

/obj/structure/bed/chair/comfy/ayy2
	icon_state = "ayychair2"
	name = "GDR premium chair"
	desc = "A premium chair manufactured by greys for more important greys. Surprisingly comfortable, good lumbar support."

/obj/structure/bed/ayy1
	name = "GDR standard bed"
	desc = "Manufactured efficiently from basic alloys and sythetic threads. Quality may vary. "
	icon_state = "ayybed1"

/obj/structure/bed/ayy2
	name = "GDR premium bed"
	desc = "Significantly more comfortable than a standard issue bed. A luxury befitting a high-ranking researcher or administrator."
	icon_state = "ayybed2"
	sheet_type = /obj/item/stack/sheet/plasteel
	sheet_amt = 2

/obj/structure/closet/crate/ayy
	name = "GDR crate"
	desc = "A common storage crate, mass produced by grey laborers."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "ayycrate1"
	density = 1
	icon_opened = "ayycrate1open"
	icon_closed = "ayycrate1"

/obj/structure/closet/crate/ayy2
	name = "MDF crate"
	desc = "A rugged storage crate, for transporting mothership military supplies."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "ayycrate2"
	density = 1
	icon_opened = "ayycrate2open"
	icon_closed = "ayycrate2"

/obj/structure/closet/crate/ayy3
	name = "GDR industrial crate"
	desc = "A sturdy storage crate, for transporting tools, electronics, and building materials."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "ayycrate3"
	density = 1
	icon_opened = "ayycrate3open"
	icon_closed = "ayycrate3"

/obj/structure/closet/crate/secure/ayy_general
	name = "GDR secure crate"
	desc = "A common card-locked crate, for shipping mothership goods."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "ayysecurecrate2"
	density = 1
	icon_opened = "ayysecurecrate2open"
	icon_closed = "ayysecurecrate2"

/obj/structure/closet/crate/secure/ayy_mdf
	name = "MDF secure crate"
	desc = "A durable card-locked crate, for shipping disintegrators or other volatile ordnance."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "ayysecurecrate"
	density = 1
	icon_opened = "ayysecurecrateopen"
	icon_closed = "ayysecurecrate"

/obj/structure/closet/ayy
	name = "GDR locker"
	desc = "A common storage unit, mass produced by grey laborers."
	icon_state = "ayy1_closed"
	icon_closed = "ayy1_closed"
	icon_opened = "ayy1_open"

/obj/structure/closet/ayy2
	name = "MDF locker"
	desc = "A rugged storage unit, for transporting mothership military supplies."
	icon_state = "ayy2_closed"
	icon_closed = "ayy2_closed"
	icon_opened = "ayy2_open"

/obj/structure/closet/ayy3
	name = "Laborer locker"
	desc = "A basic storage unit, for holding a grey laborer's spare uniforms and personal items."
	icon_state = "ayy3_closed"
	icon_closed = "ayy3_closed"
	icon_opened = "ayy3_open"

/obj/structure/closet/secure_closet/ayy
	name = "GDR secure locker"
	desc = "A mothership issued card-locked storage unit, perfect for storing a researcher's favorite labcoats."
	icon_state = "ayysecure1"
	icon_closed = "ayysecure"
	icon_locked = "ayysecure1"
	icon_opened = "ayysecureopen"
	icon_broken = "ayysecurebroken"
	icon_off = "ayysecureoff"

/obj/structure/closet/secure_closet/ayy2
	name = "MDF secure locker"
	desc = "A rugged card-locked storage unit, for transporting mothership military supplies."
	icon_state = "ayymdfsecure1"
	icon_closed = "ayymdfsecure"
	icon_locked = "ayymdfsecure1"
	icon_opened = "ayymdfsecureopen"
	icon_broken = "ayymdfsecurebroken"
	icon_off = "ayymdfsecureoff"

/obj/structure/closet/secure_closet/ayy_leader
	name = "Administrator's secure locker"
	desc = "A sleek card-locked storage unit, for keeping the personal effects of the best and brightest secure."
	icon_state = "leadersecure1"
	icon_closed = "leadersecure"
	icon_locked = "leadersecure1"
	icon_opened = "leadersecureopen"
	icon_broken = "leadersecurebroken"
	icon_off = "leadersecureoff"

//////////////////////////////
// NARRATION
//////////////////////////////

/obj/effect/narration/mothership_lab // A fairly explicit warning to turn back if faint of heart or ill-equipped
	msg = "An intense sense of foreboding worms into your mind as you approach the entrance to the lab. Somehow, you know that this place contains great danger."
	play_sound = 'sound/ambience/spookyspace1.ogg'

/obj/effect/narration/mothership_lab/raidertunnel // This tunnel be for pirates, matey
	msg = "As you climb the ladder you find yourself in a hastily dug tunnel. Dark crevices and collapsed piles of rock rubble make this a prime place for an ambush. You should be cautious."
	play_sound = 'sound/ambience/ambigen3.ogg'

/obj/effect/narration/mothership_lab/raidertunnel2 // This tunnel be for pirates, matey
	msg = "There is a soft scratching sound, like claws scraping against rock. And you swear you hear low whispers in the dark. Something is waiting for you just ahead."

/obj/effect/narration/mothership_lab/habitationdeck // This deck be a bad place
	msg = "As you enter the habitation deck, you see a chaotic scene highlighted by the dim red light of emergency flares. Scorched plating, bullet impacts, blood, and makeshift barricades are scattered everywhere."
	play_sound = 'sound/ambience/spookymaint2.ogg'

/obj/effect/narration/mothership_lab/researchdeck // This deck be worse than the last
	msg = "As you approach the ladder down to the research deck, you hear a cacophony of groans. The putrid scent of decaying flesh wafting up from below is revolting."
	play_sound = 'sound/hallucinations/wail.ogg'

/obj/effect/narration/mothership_lab/leaderdeck // Like anyone will stop if they've come this far. Gotta grab everything you can!
	msg = "You feel a scratching presence in your mind, like someone is trying to whisper in your ear. You can only make out a few words, but it seems to be warning you to turn back."
	play_sound = 'sound/hallucinations/turn_around1.ogg'

/obj/effect/narration/mothership_lab/leaderdeck2 // Like anyone will stop if they've come this far. Gotta grab everything you can!
	msg = "The presence is in your mind again, stronger this time. Whoever or whatever it is, it's telling you to turn back the way you came immediately."
	play_sound = 'sound/hallucinations/i_see_you1.ogg'

/obj/effect/narration/mothership_lab/nurseboss // Hello, Nurse?
	msg = "A sharp chill runs down your spine as you enter the doorway of the greyling dormitory."
	play_sound = 'sound/hallucinations/scary.ogg'

/obj/effect/narration/mothership_lab/voxboss // Best be careful about approaching this chicken coop
	msg = "You hear the kind of raucous screeching that can only be created by a flock of vox. They sound angry and ready for a fight."
	play_sound = 'sound/misc/shriek1.ogg'

/obj/effect/narration/mothership_lab/ayyboss // The final battle, oh yeah!
	msg = "It looks like this is the facility's control room. The presence that has been communicating with your mind is much stronger here, and seems extraordinarily displeased with you for coming this far. Whatever the source of it is, it's inside this room."
	play_sound = 'sound/music/elite_syndie_squad.ogg'

//////////////////////////////
// PAPERWORK (Grey aliens have to deal with a lot of bureaucracy)
//////////////////////////////

/obj/item/weapon/paper/mothership/spacepolyp_care
	name = "paper- 'Proper Polyp Care'"
	info = {"<html><style>
			body {color: #000000; background: #FAFAFA;}
			h1 {color: #000000; font-size:30px;}
			fieldset {width:140px;}
			</style>
			<body>
			<center><img src="https://ss13.moe/wiki/images/e/ec/Mothership_logo.png"> <h1>GDR-43X: Space Polyp Care Instructions</h1></center>
			Caring for space polyps is a crucial task to maintain mothership food production. The following simple instructions have been written for you by an experienced Head Laborer. Adhere to them or risk consequences to life, limb, and continuation of cloning cycles.<BR><BR>
			<b>Gelatin Harvesting</b>: Polyps secrete gelatin naturally that helps insulate them from vacuum. After some time has passed, collect excess gelatin from the tendrils below the bell using a bucket.<BR>
			<b>Slaughtering</b>: Pull the polyp you are slaughtering away from its herd to a private room. Use a disintegrator in 40 watt range or a similar substitute. Make it quick.<BR>
			<b>Injuries</b>: If one of your polyps is injured and remains so at the end of your shift, you will be held accountable. To quickly fix minor injuries, feed the polyp fresh meat. Polyps have a rapid metabolism, and proteins assist with natural healing processes.<BR>
			<b>Calming</b>: If you abuse a polyp, or it is attacked, it will become defensive and sting any nearby lifeforms. A defensive polyp will not recognize you as its herder. Feed the agitated polyp fresh meat to calm it. If an entire herd has become agitated, isolate and call for assistance from mothership soldiers.<BR><BR>
			Now that you are armed with knowledge, return to work, laborer. Praise the mothership, and all hail the Chairman!<BR>
			<BR>
			<b>Head Laborer Signature:</b> <i>Glyzz Bvvmrk</i>
			"}

//////////////////////////////
// RAIDER AMBUSH
//////////////////////////////

/obj/effect/trap/frog_trap/raider // A very unfortunate introduction to the new vox assassin enemies
	name = "raider ambush"
	frog_type = /mob/living/simple_animal/hostile/humanoid/vox/spaceraider/assassin

//////////////////////////////
// DEFENSE TURRETS
//////////////////////////////

/obj/machinery/turret/mothership_lab
	name = "Lab Defense System MkI"
	desc = "A turret with a disintegrator installed, meant to protect secure mothership installations."
	faction = "mothership"

/obj/machinery/turret/mothership_lab/update_gun()
	if(!installed)
		installed = new/obj/item/weapon/gun/energy/smalldisintegrator(src)

/obj/machinery/turret/mothership_lab/mkII
	name = "Lab Defense System MkII"
	desc = "A turret with a reinforced frame and a heavy disintegrator installed, meant to protect command-level areas of secure mothership installations."
	health = 125

/obj/machinery/turret/mothership_lab/mkII/update_gun()
	if(!installed)
		installed = new/obj/item/weapon/gun/energy/heavydisintegrator(src)

//////////////////////////////
// AYY MILITARY CLOTHES
//////////////////////////////

//Ayy lmao gas mask
/obj/item/clothing/mask/gas/mothership
	name = "GDR half mask"
	desc = "A close-fitting half mask that can be connected to an air supply. Acid resistant, water soluble."
	icon_state = "ayy_mask"
	item_state = "ayy_mask"
	siemens_coefficient = 0.7
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude", VOX_SHAPED, INSECT_SHAPED)
	body_parts_visible_override = EYES
	can_flip = 0
	canstage = 0

/obj/item/clothing/mask/gas/mothership/dissolvable()
	return WATER

//Superior ayy lmao gas mask
/obj/item/clothing/mask/gas/mothership/advanced
	name = "GDR Half Mask MKII"
	desc = "A close-fitting half mask that can be connected to an air supply. This one is rated for both acid and water exposure."
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 75, rad = 0)
	sterility = 100

/obj/item/clothing/mask/gas/mothership/advanced/dissolvable()
	return FALSE

//Ayy lmao helmets
/obj/item/clothing/head/helmet/mothership
	name = "MDF Helmet"
	icon_state = "ayy_helm"
	item_state = "ayy_helm"
	desc = "A helmet perfectly fitted for an enormous cranium. It provides moderate protection."
	body_parts_visible_override = FACE
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude", VOX_SHAPED, INSECT_SHAPED) // Can fit humans and ayys, but not other exotic species
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0) // Identical to default sec helmet, but a lot more stylish!

/obj/item/clothing/head/helmet/mothership/dissolvable()
	return WATER

/obj/item/clothing/head/helmet/mothership_explorer
	name = "Explorer Helmet"
	icon_state = "explorer_helmet"
	item_state = "explorer_helmet"
	desc = "A segmented helmet of alien alloy, perfect for protecting an explorer's cranium from hostile fauna."
	body_parts_covered = FULL_HEAD|MASKHEADHAIR
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude", VOX_SHAPED, INSECT_SHAPED) // Can fit humans and ayys, but not other exotic species
	armor = list(melee = 50, bullet = 50, laser = 15, energy = 5, bomb = 30, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/mothership_explorer/dissolvable()
	return WATER

/obj/item/clothing/head/helmet/mothership_visor
	name = "MDF Visored Helmet"
	icon_state = "ayy_helm_visor"
	item_state = "ayy_helm_visor"
	desc = "A helmet perfectly fitted for an enormous cranium. This one has a large visor."
	species_restricted = list(GREY_SHAPED)
	species_fit = list(GREY_SHAPED) // This one only fits ayys
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0) // Identical to default sec helmet, but a lot more stylish!

/obj/item/clothing/head/helmet/mothership_visor/dissolvable()
	return WATER

/obj/item/clothing/head/helmet/mothership_visor_heavy
	name = "MDF Heavy Helmet"
	icon_state = "ayy_helm_heavy"
	item_state = "ayy_helm_heavy"
	desc = "A helmet perfectly fitted for an enormous cranium. This one has a reinforced visor that offers some additional protection."
	body_parts_covered = FULL_HEAD
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude", VOX_SHAPED, INSECT_SHAPED) // Can fit humans and ayys, but not other exotic species
	armor = list(melee = 75, bullet = 30, laser = 65, energy = 15, bomb = 50, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/mothership_visor_heavy/dissolvable()
	return FALSE

//Ayy lmao armor vests
/obj/item/clothing/suit/armor/mothership
	name = "MDF Armor"
	desc = "An armored vest perfectly fitted for the thinnest of abdomens. Praise the mothership."
	icon_state = "mdf_armor"
	item_state = "mdf_armor"
	body_parts_covered = FULL_TORSO
	species_fit = list(GREY_SHAPED) // Can be worn by humans and ayys
	species_restricted = list("exclude", VOX_SHAPED, INSECT_SHAPED) // Can fit humans and ayys, but not other exotic species
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0) // Identical to default armor vest, but a lot more stylish!

/obj/item/clothing/suit/armor/mothership/dissolvable()
	return WATER

/obj/item/clothing/suit/armor/mothership/explorer
	name = "Explorer Chestplate"
	desc = "A segmented armored vest of alien alloy, favored by mothership explorers. Protects the vitals from blunt force and ballistic weapons."
	icon_state = "explorer_chestplate"
	item_state = "explorer_chestplate"
	armor = list(melee = 50, bullet = 50, laser = 15, energy = 5, bomb = 30, bio = 0, rad = 0)

//Ayy lmao heavy armor
/obj/item/clothing/suit/armor/mothership_heavy
	name = "MDF Heavy Armor"
	desc = "An alternative to the common MDF vest, fitted with additional and thicker armor plates. It offers better protection and coverage at the cost of some mobility."
	icon_state = "mdf_armor_heavy"
	item_state = "mdf_armor_heavy"
	slowdown = HARDSUIT_SLOWDOWN_LOW // It's called heavy armor for a reason, after all
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS|IGNORE_INV
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude", VOX_SHAPED, INSECT_SHAPED) // Can fit humans and ayys, but not other exotic species
	armor = list(melee = 75, bullet = 30, laser = 65, energy = 15, bomb = 50, bio = 0, rad = 0) // Notably better stats than the vest
	siemens_coefficient = 0.5

/obj/item/clothing/suit/armor/mothership_heavy/dissolvable()
	return FALSE

//Ayy lmao soldier belt
/obj/item/weapon/storage/belt/mothership
	name = "MDF belt"
	desc = "A military-grade belt for mothership soldiers. It can hold a disintegrator sidearm and various other useful implements."
	icon_state = "mdfbelt"
	item_state = "security"
	storage_slots = 14
	fits_max_w_class = 3
	max_combined_w_class = 21
	can_only_hold = list(
		"/obj/item/weapon/gun/energy/smalldisintegrator",
		"/obj/item/weapon/gun/energy/ionrifle/ioncarbine/ionpistol",
		"/obj/item/weapon/melee/stunprobe",
		"/obj/item/device/flash",
		"/obj/item/weapon/grenade",
		"/obj/item/weapon/handcuffs",
		"/obj/item/weapon/reagent_containers/food/snacks/zambiscuit",
		"/obj/item/weapon/zambiscuit_package",
		"/obj/item/weapon/storage/pill_bottle/hyperzine",
		"/obj/item/weapon/reagent_containers/hypospray/autoinjector",
		"/obj/item/stack/medical",
		"/obj/item/device/flashlight",
		"/obj/item/device/gps/secure",
		"/obj/item/binoculars",
		"/obj/item/weapon/storage/fancy/cigarettes",
		"/obj/item/weapon/lighter",
		"/obj/item/clothing/glasses",
		"/obj/item/clothing/mask/gas/mothership",
		"/obj/item/weapon/tank/emergency_oxygen",
		)

/obj/item/weapon/storage/belt/mothership/dissolvable()
	return WATER

/obj/item/weapon/storage/belt/mothership/partial_gear/New()
	..()
	new /obj/item/weapon/gun/energy/ionrifle/ioncarbine/ionpistol(src)
	new /obj/item/binoculars(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/weapon/reagent_containers/food/snacks/zambiscuit(src)
	new /obj/item/weapon/storage/fancy/cigarettes/redsuits(src)
	new /obj/item/weapon/lighter/zippo(src)
	new /obj/item/clothing/mask/gas/mothership(src)
	new /obj/item/weapon/tank/emergency_oxygen/engi(src)

//////////////////////////////
// AYY MISC ITEMS (Uniforms and other stuff that doesn't quite fit a "military" label)
//////////////////////////////

//Ayy lmao jumpsuits
/obj/item/clothing/under/grey
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude", VOX_SHAPED, INSECT_SHAPED) // Can fit humans and ayys, but not other exotic species

/obj/item/clothing/under/grey/dissolvable()
	return WATER

/obj/item/clothing/under/grey/grey_worker
	desc = "A set of high visibility coveralls issued to mothership engineers and technicians. It has minor radiation shielding."
	name = "worker's coveralls"
	icon_state = "greyuniform_worker"
	item_state = "greyuniform_worker"
	_color = "greyuniform_worker"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 10)

/obj/item/clothing/under/grey/grey_scout
	name = "explorer's uniform"
	desc = "A uniform issued to the mothership's exploration league. The strong material offers some protection from the teeth and claws of hostile xenofauna."
	icon_state = "greyuniform_scout"
	item_state = "greyuniform_scout"
	_color = "greyuniform_scout"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/grey/grey_soldier
	name = "soldier's uniform"
	desc = "A uniform issued to the mothership's defense forces. It's made from thermal-resistant fibers that provide some protection from laser fire."
	icon_state = "greyuniform_soldier"
	item_state = "greyuniform_soldier"
	_color = "greyuniform_soldier"
	armor = list(melee = 0, bullet = 0, laser = 10,energy = 5, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/grey/grey_researcher
	name = "researcher's uniform"
	desc = "A sterile uniform for a mothership researcher. It has specialized fibers that offer some protection against biohazards and radiation."
	icon_state = "greyuniform_researcher"
	item_state = "greyuniform_researcher"
	_color = "greyuniform_researcher"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 10)
	sterility = 20

/obj/item/clothing/under/grey/grey_leader
	name = "Administrator's Uniform"
	desc = "A uniform for high-ranking mothership officials. For those who wish to command their minions while looking impeccably stylish."
	icon_state = "greyuniform_leader"
	item_state = "greyuniform_leader"
	_color = "greyuniform_leader"
	armor = list(melee = 10, bullet = 0, laser = 15,energy = 5, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.8

/obj/item/clothing/under/grey/grey_leader/dissolvable() // It'll take more than acid to ruin a uniform this sharp
	return FALSE

//Ayy lmao labcoat (Same as a normal labcoat in stats, but slightly altered spritewise to look better when paired with the uniform)
/obj/item/clothing/suit/storage/labcoat/mothership
	name = "mothership labcoat"
	desc = "A labcoat with an incredibly slim fit. Praise your superior waistline ratio."
	base_icon_state = "labcoat_ayy"
	item_state = "labcoat_ayy"
	species_fit = list(GREY_SHAPED)
	species_restricted = list("exclude", VOX_SHAPED, INSECT_SHAPED) // Can fit humans and ayys, but not other exotic species

/obj/item/clothing/suit/storage/labcoat/mothership/dissolvable() // It'll take more than acid to ruin a uniform this sharp
	return WATER

//Ayy lmao boots
/obj/item/clothing/shoes/jackboots/mothership
	name = "mothership boots"
	desc = "Issued, recalled post-mortem, and reissued countless times to many mothership denizens. Despite that, the boots still shine impeccably."
	sterility = 75

/obj/item/clothing/shoes/jackboots/mothership/dissolvable() // It'll take more than acid to ruin a fine pair of boots like these
	return WATER

/obj/item/clothing/shoes/jackboots/steeltoe/mothership_superior // Meant to be worn by ayy VIPs, like leaders and such
	name = "Superior Mothership Boots"
	desc = "A spotless pair of boots freshly synthesized by a mothership vat. This pair is very durable and has an exceptionally strong grip."
	armor = list(melee = 65, bullet = 30, laser = 65, energy = 25, bomb = 40, bio = 0, rad = 0)
	clothing_flags = NOSLIP
	sterility = 100

/obj/item/clothing/shoes/jackboots/steeltoe/mothership_superior/dissolvable() // It'll take more than acid to ruin a fine pair of boots like these
	return FALSE

//////////////////////////////
// AYY ID CARDS (Some IDs for access requirements for the vault. Also allows future coders to use them for their own projects, if they want.)
//////////////////////////////

/obj/item/weapon/card/id/mothership
	name = "Mothership Traveler ID"
	desc = "A plain ID card, required to legally travel in mothership-controlled territories. Not many of these get issued these days."
	registered_name = "traveler"
	assignment = "Traveler"
	icon_state = "ayy_tourist"
	access = list(access_mothership_general)
	base_access = list(access_mothership_general)

/obj/item/weapon/card/id/mothership_laborer
	name = "Mothership Laborer ID"
	desc = "An ID card for a mothership laborer. It smells faintly of motor oil and iron."
	assignment = "Laborer"
	icon_state = "ayy_laborer"
	access = list(access_mothership_general, access_mothership_maintenance)
	base_access = list(access_mothership_general, access_mothership_maintenance)

/obj/item/weapon/card/id/mothership_soldier
	name = "Mothership Soldier ID"
	desc = "An ID card for a mothership soldier. Just looking at it makes you want to MARCH."
	assignment = "Soldier"
	icon_state = "ayy_soldier"
	access = list(access_mothership_general, access_mothership_military)
	base_access = list(access_mothership_general, access_mothership_military)

/obj/item/weapon/card/id/mothership_researcher
	name = "Mothership Researcher ID"
	desc = "An ID card for a mothership researcher. Why are you just looking at it? Get some alien tissue samples under a microscope."
	assignment = "Researcher"
	icon_state = "ayy_researcher"
	access = list(access_mothership_general, access_mothership_research)
	base_access = list(access_mothership_general, access_mothership_research)

/obj/item/weapon/card/id/mothership_leader
	name = "Mothership Administrator ID"
	desc = "An ID card for a mothership administrator. Fit only for the most important UFO-commanding bureaucrats."
	assignment = "Mothership Administrator"
	icon_state = "ayy_leader"
	access = list(access_mothership_general, access_mothership_maintenance, access_mothership_military, access_mothership_research, access_mothership_leader)
	base_access = list(access_mothership_general, access_mothership_maintenance, access_mothership_military, access_mothership_research, access_mothership_leader)

/obj/item/weapon/card/id/mothership_leader/dissolvable() // ID nanobots or something. This is mostly to prevent it being melted by a stray grenade in the vault crossfire
	return FALSE

//////////////////////////////
// GREY GOO (Pill and pill bottle items for an experimental grey brain medication. More info on Chemistry-Reagents.dm)
//////////////////////////////
/obj/item/weapon/reagent_containers/pill/greygoo
	name = "unknown pill"
	desc = "It has a marking from the mothership's chemical research division, but no other useful information."
	icon_state = "pill7"

/obj/item/weapon/reagent_containers/pill/greygoo/New()
	..()
	reagents.add_reagent(GREYGOO, 5)

/obj/item/weapon/storage/pill_bottle/greygoo
	name = "Cortex MkI"
	desc = "Product not yet approved for cross-species clinical trials. Follow mothership surgeon's dosage recommendation."
	items_to_spawn = list(/obj/item/weapon/reagent_containers/pill/greygoo = 10)

//////////////////////////////
// ALIEN GRENADES (Some ideas I spitballed for ayy-themed nades. One is a polyacid grenade, and one is a spawner grenade that spawns mini-ufo drones)
//////////////////////////////

/obj/item/weapon/grenade/chem_grenade/mothershipacid
	name = "mothership acid grenade"
	icon_state = "acidgrenade"
	desc = "Mothership ordinance is intended for combat use only, do not attempt to remove and consume contents."
	origin_tech = Tc_COMBAT + "=3;" + Tc_MATERIALS + "=2"
	det_time = 3 SECONDS
	stage = GRENADE_STAGE_COMPLETE
	path = PATH_STAGE_CONTAINER_INSERTED

/obj/item/weapon/grenade/chem_grenade/mothershipacid/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/large/B2 = new(src)

	B1.reagents.add_reagent(PACID, 60)
	B1.reagents.add_reagent(POTASSIUM, 40)
	B2.reagents.add_reagent(PHOSPHORUS, 40)
	B2.reagents.add_reagent(SUGAR, 40)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2

/obj/item/weapon/grenade/spawnergrenade/mothershipdrone
	name = "mothership drone grenade"
	desc = "Will unleash a swarm of hostile saucer drones that will attack nearby targets, but not the grenade operator."
	icon_state = "ufogrenade"
	spawner_type = /mob/living/simple_animal/hostile/mothership_saucerdrone
	deliveryamt = 4
	origin_tech = Tc_MATERIALS + "=3;" + Tc_MAGNETS + "=4;" + Tc_COMBAT + "=4"

/obj/item/weapon/grenade/spawnergrenade/mothershipdrone/handle_faction(var/mob/living/spawned, var/mob/living/L)
	if(!spawned || !L)
		return

	spawned.faction = "\ref[L]"

//////////////////////////////
// RED ENERGY SHIELD (A recolored energy shield for ayys to use that better matches their military gear colors)
//////////////////////////////

/obj/item/weapon/shield/energy/red
	name = "mothership combat shield"
	icon_state = "eshieldred0" // eshieldred1 for expanded
	origin_tech = Tc_MATERIALS + "=4;" + Tc_MAGNETS + "=3;" + Tc_COMBAT + "=4" // Not owned by the Syndicate, so it doesn't give Syndicate research

/obj/item/weapon/shield/energy/red/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is putting the [src.name] to their head and activating it! It looks like \he's  trying to commit suicide!</span>")
	return (SUICIDE_ACT_BRUTELOSS)

/obj/item/weapon/shield/energy/red/IsShield()
	if(active)
		return 1
	else
		return 0

/obj/item/weapon/shield/energy/red/attack_self(mob/living/user as mob)
	if (clumsy_check(user) && prob(50))
		to_chat(user, "<span class='warning'>You beat yourself in the head with [src].</span>")
		user.take_organ_damage(5)
	active = !active
	if (active)
		force = 10
		w_class = W_CLASS_LARGE
		playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = 3
		w_class = W_CLASS_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	icon_state = "eshieldred[active]"
	item_state = "eshieldred[active]"
	user.regenerate_icons()
	add_fingerprint(user)
	return

//////////////////////////////
// AYY-THEMED STUN BATON (I tried several times to make this a child of the stun baton, but couldn't get it to play nice with the sprites. My apologies for what you're about to see)
//////////////////////////////

/obj/item/weapon/melee/stunprobe
	name = "stun probe"
	desc = "An unusual baton used by MDF pacifiers. Less than lethal, not quite nonlethal."
	icon_state = "stun probe"
	item_state = "s_probe0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	flags = FPRINT
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = W_CLASS_MEDIUM
	origin_tech = Tc_COMBAT + "=3" + Tc_POWERSTORAGE + "=2"
	attack_verb = list("beats")
	var/status = 0
	var/obj/item/weapon/cell/bcell = null
	var/hitcost = 50 // 20 stuns with integrated cell, but can't upgrade or remove it. Doesn't have a normal baton's vulnerability to emp blasts. Compatible with rechargers
	var/stunsound = 'sound/weapons/electriczap.ogg'
	var/swingsound = "swing_hit"

/obj/item/weapon/melee/stunprobe/get_cell()
	return bcell

/obj/item/weapon/melee/stunprobe/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is putting the live [src.name] in \his mouth! It looks like \he's trying to commit suicide.</span>")
	return (SUICIDE_ACT_FIRELOSS)

/obj/item/weapon/melee/stunprobe/New() // Should always start with a cell integrated
	..()
	bcell = new(src)
	bcell.charge=bcell.maxcharge // Charge this shit
	update_icon()

/obj/item/weapon/melee/stunprobe/Destroy()
	if (bcell)
		QDEL_NULL(bcell)

	return ..()

/obj/item/weapon/melee/stunprobe/proc/deductcharge(var/chrgdeductamt)
	if(bcell)
		if(bcell.use(chrgdeductamt))
			if(bcell.charge < hitcost)
				status = 0
				update_icon()
				depower()
			return 1
		else
			status = 0
			update_icon()
			depower()
			return 0

/obj/item/weapon/melee/stunprobe/update_icon()
	if(status)
		icon_state = "[initial(name)]_active"
		item_state = "s_probe1"
	else if(!bcell)
		icon_state = "[initial(name)]_nocell"
		item_state = "s_probe0"
	else
		icon_state = "[initial(name)]"
		item_state = "s_probe0"

	if (istype(loc,/mob/living/carbon))
		var/mob/living/carbon/M = loc
		M.update_inv_back()
		M.update_inv_hands()

/obj/item/weapon/melee/stunprobe/examine(mob/user)
	..()
	if(bcell)
		to_chat(user, "<span class='info'>The probe is [round(bcell.percent())]% charged.</span>")
	if(!bcell)
		to_chat(user, "<span class='warning'>The probe does not have a power source installed.</span>")

/obj/item/weapon/melee/stunprobe/proc/shockAttack(mob/living/carbon/human/target) // The main difference between this and a stun baton. It uses an electric shock attack, so genetics can make a player resistant
	var/damage = rand(5, 10)
	target.electrocute_act(damage, src, incapacitation_duration = 20 SECONDS, def_zone = LIMB_CHEST) // 20 code seconds is more like 10 real seconds, thus making the stun equal to the stun baton
	if(iscarbon(target))
		var/mob/living/L = target
		L.apply_effect(10, STUTTER)
	return

/obj/item/weapon/melee/stunprobe/attack_self(mob/user)
	if(status && clumsy_check(user) && prob(50))
		user.simple_message("<span class='warning'>You grab the [src] on the wrong side.</span>",
			"<span class='danger'>The [name] blasts you with its power!</span>")
		shockAttack(user)
		playsound(loc, "sparks", 75, 1, -1)
		deductcharge(hitcost)
		return
	if(bcell && bcell.charge >= hitcost)
		status = !status
		user.simple_message("<span class='notice'>[src] is now [status ? "on" : "off"].</span>",
			"<span class='notice'>[src] is now [pick("drowsy","hungry","thirsty","bored","unhappy")].</span>")
		playsound(loc, "sparks", 75, 1, -1)
		update_icon()
	else
		status = 0
		if(!bcell)
			user.simple_message("<span class='warning'>[src] does not have a power source!</span>",
				"<span class='warning'>[src] has no pulse and its soul has departed...</span>")
		else if (bcell.maxcharge < hitcost)
			to_chat(user, "<span class='warning'>[src] clicks but nothing happens. Something must be wrong with the battery.</span>")
		else
			user.simple_message("<span class='warning'>[src] is out of charge.</span>",
				"<span class='warning'>[src] refuses to obey you.</span>")

	add_fingerprint(user)

/obj/item/weapon/melee/stunprobe/attack(mob/M, mob/user)
	if(status && clumsy_check(user) && prob(50))
		user.simple_message("<span class='danger'>You accidentally hit yourself with [src]!</span>",
			"<span class='danger'>The [name] goes mad!</span>")
		shockAttack(user)
		deductcharge(hitcost)
		return

	if(isrobot(M))
		..()
		return
	if(!isliving(M))
		return

	var/mob/living/L = M

	if(user.a_intent == I_HURT) // Harm intent : possibility to miss (in exchange for doing actual damage)
		. = ..() // Does the actual damage and missing chance. Returns null on sucess ; 0 on failure (blame oldcoders)
		playsound(loc, swingsound, 50, 1, -1)

	else
		if(!status) // Help intent + no charge = nothing
			L.visible_message("<span class='attack'>\The [L] has been prodded with \the [src] by \the [user]. Luckily it was off.</span>",
				self_drugged_message="<span class='warning'>\The [name] decides to spare this one.</span>")
			return

	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.check_shields(force,src))
			return FALSE //That way during a harmbaton it will not check for the shield twice

	if(status && . != FALSE) // This is charged : we stun
		user.lastattacked = L
		L.lastattacker = user

		shockAttack(L)
		playsound(loc, stunsound, 50, 1, -1)

		deductcharge(hitcost)

		L.forcesay(hit_appends)

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Zapped [L.name] ([L.ckey]) with [name]</font>"
		L.attack_log += "\[[time_stamp()]\]<font color='orange'> Zapped by [user.name] ([user.ckey]) with [name]</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) zapped [L.name] ([L.ckey]) with [name]</font>" )
		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user
			M.assaulted_by(user)

/obj/item/weapon/melee/stunprobe/throw_impact(atom/hit_atom)
	if(prob(50))
		return ..()
	if(!isliving(hit_atom) || !status)
		return
	var/client/foundclient = directory[ckey(fingerprintslast)]
	var/mob/foundmob = foundclient.mob
	var/mob/living/L = hit_atom
	if(foundmob && ismob(foundmob))
		foundmob.lastattacked = L
		L.lastattacker = foundmob

	shockAttack(L)
	playsound(loc, stunsound, 50, 1, -1)

	deductcharge(hitcost)

	L.forcesay(hit_appends)

	foundmob.attack_log += "\[[time_stamp()]\]<font color='red'> Zapped [L.name] ([L.ckey]) with [name]</font>"
	L.attack_log += "\[[time_stamp()]\]<font color='orange'> Zapped by thrown [src] by [istype(foundmob) ? foundmob.name : ""] ([istype(foundmob) ? foundmob.ckey : ""])</font>"
	log_attack("<font color='red'>Flying [src.name], thrown by [istype(foundmob) ? foundmob.name : ""] ([istype(foundmob) ? foundmob.ckey : ""]) zapped [L.name] ([L.ckey])</font>" )
	if(!iscarbon(foundmob))
		L.LAssailant = null
	else
		L.LAssailant = foundmob
		L.assaulted_by(foundmob)

/obj/item/weapon/melee/stunprobe/emp_act(severity)
	if(bcell)
		deductcharge(1000 / severity)
		if(bcell.reliability != 100 && prob(50/severity))
			bcell.reliability -= 10 / severity
	..()

/obj/item/weapon/melee/stunprobe/restock()
	if(bcell)
		bcell.charge = bcell.maxcharge

/obj/item/weapon/melee/stunprobe/proc/depower()
	force = initial(force)
	throwforce = initial(throwforce)

//////////////////////////////
// AYY SINKS, TOILETS, AND SHOWERS (Only attainable via the vault and bussing for now. Coders forgive me for this terrible copy-paste apocalypse.)
//////////////////////////////

//Idea: Items placed in the cistern of this thing should just melt
/obj/structure/acidtoilet
	name = "acid toilet"
	desc = "The WD-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably acidic."
	icon = 'icons/obj/acidcloset.dmi'
	icon_state = "acidtoilet00"
	density = 0
	anchored = 1
	var/state = 0			//1 if rods added; 0 if not
	var/open = 0			//if the lid is up
	var/cistern = 0			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie
	var/obj/item/weapon/reagent_containers/glass/beaker/acid/acidsource = null

/obj/structure/acidtoilet/New()
	. = ..()
	open = round(rand(0, 1))
	acidsource = new /obj/item/weapon/reagent_containers/glass/beaker/acid()
	update_icon()

/obj/structure/acidtoilet/verb/empty_container_into()
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

/obj/structure/acidtoilet/AltClick()
	if(Adjacent(usr))
		return empty_container_into()
	return ..()
/obj/structure/acidtoilet/attack_hand(mob/living/user)
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
			if(ishuman(user))
				user.put_in_hands(I)
			else
				I.forceMove(get_turf(src))
			to_chat(user, "<span class='notice'>You find \an [I] in the cistern.</span>")
			w_items -= I.w_class
			return

	open = !open
	update_icon()

/obj/structure/acidtoilet/update_icon()
	icon_state = "acidtoilet[open][cistern]"

/obj/structure/acidtoilet/attackby(obj/item/I as obj, mob/living/user as mob)
	if(I.is_wrench(user))
		to_chat(user, "<span class='notice'>You [anchored ? "un":""]bolt \the [src]'s grounding lines.</span>")
		anchored = !anchored
	if(!anchored)
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
						GM.forcesay(list("-BLERGH", "-BLURBL", "-HURGBL"))
						playsound(src, 'sound/misc/toilet_flush.ogg', 50, TRUE)
						GM.visible_message("<span class='danger'>[user] gives [GM.name] a swirlie!</span>", "<span class='userdanger'>[user] gives you a swirlie!</span>", "You hear a toilet flushing.")
						add_fingerprint(user)
						add_fingerprint(GM)
						acidsource.reagents.reaction(GM, TOUCH)

						if(!GM.internal && GM.losebreath <= 30)
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
		if(w_items + I.w_class > W_CLASS_HUGE)
			to_chat(user, "<span class='notice'>The cistern is full.</span>")
			return
		if(user.drop_item(I, src))
			w_items += I.w_class
			to_chat(user, "You carefully place \the [I] into the cistern.")
			return

/obj/structure/acidtoilet/bite_act(mob/user)
	user.simple_message("<span class='notice'>That would be disgusting.</span>", "<span class='info'>You're not high enough for that... Yet.</span>") //Second message 4 hallucinations

/obj/machinery/acidshower // Acid showers have an effect called "vapor" instead of mist, and they have a tendency to melt things left under them too long
	name = "acid shower"
	desc = "The CB-762. Installed by the Mothership's Hygiene Division."
	icon = 'icons/obj/acidcloset.dmi'
	icon_state = "acidshower"
	icon_state_open = "acidshower_t"
	density = 0
	anchored = 1
	use_power = 0
	var/on = 0
	var/obj/effect/acidvapor/myvapor = null
	var/isvapor = 0
	var/acidtemp = "normal" //cold, normal, or boiling
	var/obj/item/weapon/reagent_containers/glass/beaker/acid/acidsource = null

	machine_flags = SCREWTOGGLE

	ghost_read = 0
	ghost_write = 0

/obj/machinery/acidshower/New()
	..()
	acidsource = new /obj/item/weapon/reagent_containers/glass/beaker/acid()

/obj/effect/acidvapor
	name = "acid vapor"
	icon = 'icons/obj/acidcloset.dmi'
	icon_state = "vapor_acid"
	plane = ABOVE_HUMAN_PLANE
	anchored = 1
	mouse_opacity = 0

/obj/machinery/acidshower/togglePanelOpen(var/obj/toggleitem, var/mob/user)
	if(on)
		to_chat(user, "<span class='warning'>You need to turn off \the [src] first.</span>")
		return
	..()

/obj/machinery/acidshower/attack_hand(mob/M as mob)
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

/obj/machinery/acidshower/attackby(obj/item/I as obj, mob/user as mob)

	..()

	if(I.type == /obj/item/device/analyzer)
		to_chat(user, "<span class='notice'>The acid's temperature seems to be [acidtemp].</span>")
	if(panel_open) //The panel is open
		if(I.is_wrench(user))
			user.visible_message("<span class='warning'>[user] begins to adjust \the [src]'s temperature valve with \a [I.name].</span>", \
								 "<span class='notice'>You begin to adjust \the [src]'s temperature valve with \a [I.name].</span>")
			if(do_after(user, src, 50))
				switch(acidtemp)
					if("normal")
						acidtemp = "cold"
					if("cold")
						acidtemp = "searing hot"
					if("searing hot")
						acidtemp = "normal"
				I.playtoolsound(src, 100)
				user.visible_message("<span class='warning'>[user] adjusts \the [src]'s temperature with \a [I.name].</span>",
				"<span class='notice'>You adjust \the [src]'s temperature with \a [I.name], the acid is now [acidtemp].</span>")
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

/obj/machinery/acidshower/update_icon()	//This handles the acid overlay when the shower is on, and makes the vapor appear after a while
	overlays.len = 0
	if(myvapor)
		QDEL_NULL(myvapor)

	if(on)
		var/image/acid = image('icons/obj/acidcloset.dmi', src, "acid", BELOW_OBJ_LAYER, dir)
		acid.plane = relative_plane(ABOVE_HUMAN_PLANE)
		overlays += acid
		if(acidtemp == "cold") //No vapor if the acid is cold
			return
		if(!isvapor)
			spawn(50)
				if(src && on)
					isvapor = 1
					myvapor = new /obj/effect/acidvapor(get_turf(src))
		else
			isvapor = 1
			myvapor = new /obj/effect/acidvapor(get_turf(src))
	else if(isvapor)
		isvapor = 1
		myvapor = new /obj/effect/acidvapor(get_turf(src))
		spawn(250)
			if(src && !on)
				QDEL_NULL(myvapor)
				isvapor = 0

/obj/machinery/acidshower/Crossed(atom/movable/O)
	..()
	wash(O)

//Yes, showers are super powerful as far as washing goes
//Shower cleaning has been nerfed (no, really). 75 % chance to clean everything on each tick
//You'll have to stay under it for a bit to clean every last noggin

#define ACID_CLEANSE_PROB 75 //Percentage

/obj/machinery/acidshower/proc/wash(atom/movable/O as obj|mob)
	if(!on)
		return

	if(iscarbon(O))
		var/mob/living/carbon/M = O
		for(var/obj/item/I in M.held_items)
			if(prob(ACID_CLEANSE_PROB))
				I.clean_blood()
				M.update_inv_hand(M.is_holding_item(I))
		if(M.back && prob(ACID_CLEANSE_PROB))
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
				if(prob(ACID_CLEANSE_PROB) && H.head.clean_blood())
					H.update_inv_head(0)
			if(H.wear_suit)
				if(prob(ACID_CLEANSE_PROB) && H.wear_suit.clean_blood())
					H.update_inv_wear_suit(0)
			else if(H.w_uniform)
				if(prob(ACID_CLEANSE_PROB) && H.w_uniform.clean_blood())
					H.update_inv_w_uniform(0)
			if(H.gloves && washgloves)
				if(prob(ACID_CLEANSE_PROB) && H.gloves.clean_blood())
					H.update_inv_gloves(0)
			if(H.shoes && washshoes)
				if(prob(ACID_CLEANSE_PROB) && H.shoes.clean_blood())
					H.update_inv_shoes(0)
			if(H.wear_mask && washmask)
				if(prob(ACID_CLEANSE_PROB) && H.wear_mask.clean_blood())
					H.update_inv_wear_mask(0)
			if(H.glasses && washglasses)
				if(prob(ACID_CLEANSE_PROB) && H.glasses.clean_blood())
					H.update_inv_glasses(0)
			if(H.ears && washears)
				if(prob(ACID_CLEANSE_PROB) && H.ears.clean_blood())
					H.update_inv_ears(0)
			if(H.belt)
				if(prob(ACID_CLEANSE_PROB) && H.belt.clean_blood())
					H.update_inv_belt(0)
		else
			if(M.wear_mask) //If the mob is not human, it cleans the mask without asking for bitflags
				if(prob(ACID_CLEANSE_PROB) && M.wear_mask.clean_blood())
					M.update_inv_wear_mask(0)
	else
		if(prob(ACID_CLEANSE_PROB))
			O.clean_blood()

	var/turf/turf = get_turf(src)
	if(prob(ACID_CLEANSE_PROB))
		turf.clean_blood()
		for(var/obj/effect/E in turf)
			if(istype(E, /obj/effect/rune_legacy) || istype(E, /obj/effect/decal/cleanable) || istype(E, /obj/effect/overlay))
				qdel(E)

/obj/machinery/acidshower/process()
	if(!on)
		return
	for(var/atom/movable/O in loc)
		if(iscarbon(O))
			var/mob/living/carbon/C = O
			check_heat(C)
		wash(O)
		acidsource.reagents.reaction(O, TOUCH)
		if(istype(O, /obj/item/weapon/reagent_containers/glass))
			var/obj/item/weapon/reagent_containers/glass/G = O
			G.reagents.add_reagent(SACID, 5)
	acidsource.reagents.reaction(get_turf(src), TOUCH)

/obj/machinery/acidshower/proc/check_heat(mob/living/carbon/C as mob)
	if(!on)
		return

	//Note : Remember process() rechecks this, so the mix/max procs slowly increase/decrease body temperature
	//To-Do: Maybe add more sanity to the temperatures that sulphuric acid can reasonably reach? Freezing point is a big offender, since acid freezes at 10 degrees celsius
	if(acidtemp == "cold") //Down to -60 degree Celsius, basically the inverse in temperature extremes compared to the normal shower
		C.bodytemperature = max(T0C - 60, C.bodytemperature - 1)
		return
	if(acidtemp == "searing hot") //Up to 137 degree Celsius. Boiling hot and corrosive! Nice
		C.bodytemperature = min(T0C + 137, C.bodytemperature + 3) // Any less than +3 and it doesn't actually heat above normal body temp
		return
	if(acidtemp == "normal") //Adjusts towards "perfect" body temperature, 37.5 degree Celsius. Actual showers tend to average at 40 degree Celsius, but it's the future
		if(C.bodytemperature > T0C + 37.5) //Cooling down
			C.bodytemperature = max(T0C + 37.5, C.bodytemperature - 1)
			return
		if(C.bodytemperature < T0C + 37.5) //Heating up
			C.bodytemperature = min(T0C + 37.5, C.bodytemperature + 1)
			return

/obj/machinery/acidshower/npc_tamper_act(mob/living/L)
	attack_hand(L)

//Idea: Maybe make it melt more items if you try to clean them
/obj/structure/acidsink
	name = "acid sink"
	icon = 'icons/obj/acidcloset.dmi'
	icon_state = "acidsink"
	desc = "A sink used for washing one's hands and face. This one seems to use acid instead of water."
	anchored = 1
	var/busy = 0 	//Something's being washed at the moment

/obj/structure/acidsink/verb/empty_container_into()
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

/obj/structure/acidsink/AltClick()
	if(Adjacent(usr))
		return empty_container_into()
	return ..()

/obj/structure/acidsink/attack_hand(mob/M as mob)
	if(isrobot(M) || isAI(M))
		return

	if(!Adjacent(M))
		return

	if(!anchored)
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
		var/mob/living/carbon/human/HM = M

		if(HM.gloves) //This should make it so anyone who isn't wearing gloves and isn't an ayy will get some burns
			to_chat(M, "<span class='warning'>Your gloves block direct contact with the acid.</span>")
		if(!HM.gloves)
			if(HM.species && HM.species.anatomy_flags & ACID4WATER)
				to_chat(HM, "<span class='notice'>You feel the pleasant sensation of acid on your hands.</span>")
			else
				to_chat(M, "<span class='warning'>The acid burns your hands!</span>")
				HM.adjustFireLossByPart(rand(5, 10), LIMB_LEFT_HAND, src)
				HM.adjustFireLossByPart(rand(5, 10), LIMB_RIGHT_HAND, src)

	for(var/mob/V in viewers(src, null))
		V.show_message("<span class='notice'>[M] washes their hands using \the [src].</span>")

/obj/structure/acidsink/mop_act(obj/item/weapon/mop/M, mob/user) //It will melt your mop if you try to wet it here!
	if(busy)
		return 1
	user.visible_message("<span class='notice'>[user] puts \the [M] underneath the running acid.","<span class='notice'>You put \the [M] underneath the running acid.</span>")
	busy = 1
	sleep(40)
	busy = 0
	user.visible_message("<span class='danger'>\The [M] melts under the flow of the acid!</span>")
	var/turf/T = get_turf(user)
	new /obj/effect/decal/cleanable/molten_item(T)
	user.drop_item(M, force_drop = 1)
	qdel(M)

/obj/structure/acidsink/attackby(obj/item/O as obj, mob/user as mob)
	if(busy)
		to_chat(user, "<span class='warning'>Someone's already washing here.</span>")
		return

	if(O.is_wrench(user))
		to_chat(user, "<span class='notice'>You [anchored ? "un":""]bolt \the [src]'s grounding lines.</span>")
		anchored = !anchored
	if(!anchored)
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
			C.reagents.add_reagent(SACID, C.fill_amount)
		else
			RG.reagents.add_reagent(SACID, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		user.visible_message("<span class='notice'>[user] fills \the [RG] using \the [src].</span>","<span class='notice'>You fill the [RG] using \the [src].</span>")
		return

	if(istype(O,/obj/item/trash/plate))
		var/obj/item/trash/plate/the_plate = O
		the_plate.clean = TRUE
		O.update_icon()

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

	else if (istype(O, /obj/item/weapon/pen/fountain))
		..()
		var/obj/item/weapon/pen/fountain/P = O
		if (P.bloodied)
			to_chat(user, "<span class='notice'>You clean the blood out of the nib of \the [P].</span>")
			P.colour = "black"
			P.bloodied = FALSE

	if (!isturf(user.loc))
		return

	if (isitem(O))
		to_chat(user, "<span class='notice'>You start washing \the [O].</span>")
		busy = TRUE

		if (do_after(user,src, 40))
			O.clean_blood()
			if(O.current_glue_state == GLUE_STATE_TEMP)
				O.unglue()
			user.visible_message( \
				"<span class='notice'>[user] washes \the [O] using \the [src].</span>", \
				"<span class='notice'>You wash \the [O] using \the [src].</span>")
			..()

		busy = FALSE

/obj/structure/acidsink/npc_tamper_act(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/gremlin))
		visible_message("<span class='danger'>\The [L] climbs into \the [src] and turns the faucet on!</span>")

		var/mob/living/simple_animal/hostile/gremlin/G = L
		G.divide()

	return NPC_TAMPER_ACT_NOMSG
