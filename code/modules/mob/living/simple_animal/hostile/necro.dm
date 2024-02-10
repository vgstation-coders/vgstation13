/mob/living/simple_animal/hostile/necro
	var/mob/creator
	var/unique_name = 0
	faction = "necro"
	mob_property_flags = MOB_UNDEAD

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

/mob/living/simple_animal/hostile/necro/New(loc, mob/living/Owner, var/mob/living/Victim, datum/mind/Controller)
	..()
	if(Victim && Victim.mind)
		Victim.mind.transfer_to(src)
		var/mob/dead/observer/ghost = get_ghost_from_mind(mind)
		if(ghost && ghost.can_reenter_corpse)
			key = mind.key // Force the ghost in here
	if(Owner)
		faction = "necro"
		friends += makeweakref(Owner)
		creator = Owner
		if(client)
			to_chat(src, "<big><span class='warning'>You have been risen from the dead by your new master, [Owner].</span></big>")

	if(name == initial(name) && !unique_name)
		name += " ([rand(1,1000)])"

/mob/living/simple_animal/hostile/necro/meat_ghoul
	name = "meat ghoul"
	desc = "An abomination of muscle and fat. Ironically, it's very hungry."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "meatghoul"
	icon_living = "meatghoul"
	icon_dead = "meatghoul_dead"
	speak_chance = 0
	turns_per_move = 1
	speed = 5
	move_to_delay = 3
	maxHealth = 10
	health = 10
	melee_damage_lower = 5
	melee_damage_upper = 8
	attacktext = "meats"
	environment_smash_flags = 0
	var/bites = 3

/mob/living/simple_animal/hostile/necro/meat_ghoul/proc/ghoulifyMeat(M)
	var/obj/item/weapon/reagent_containers/food/snacks/meat/mType = M
	bites = mType.bitesize
	maxHealth += bites + mType.reagents.get_reagent_amount(NUTRIMENT)
	health = maxHealth
	melee_damage_upper += bites
	melee_damage_lower += bites

/mob/living/simple_animal/hostile/necro/meat_ghoul/Life()
	..()
	if(prob(bites))
		new /obj/effect/decal/cleanable/blood(get_turf(src))

/mob/living/simple_animal/hostile/necro/meat_ghoul/bite_act(mob/living/carbon/human/user)
	..()
	bites--
	user.reagents.add_reagent(NUTRIMENT, bites)
	playsound(user, 'sound/items/eatfood.ogg', 50, 1)
	if(bites <= 0)
		to_chat(user, "<span class='notice'>You devour \the [src]!</span>")
		qdel(src)

/mob/living/simple_animal/hostile/necro/meat_ghoul/death(var/gibbed = FALSE)
	..(gibbed)
	new /obj/effect/decal/cleanable/ash(loc)
	qdel(src)

/mob/living/simple_animal/hostile/necro/animal_ghoul
	name = "ghoulish animal"
	desc = "A ghoulish animal."
	icon_state = "skelly"
	icon_living = "skelly"
	icon_dead = "skelly_dead"
	turns_per_move = 1
	speed = 7
	move_to_delay = 5
	maxHealth = 30
	health = 30
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "bites"
	speak_emote = list("groans", "moans")
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS

/mob/living/simple_animal/hostile/necro/animal_ghoul/proc/ghoulifyAnimal(S)
	var/mob/living/aGhoul = S
	var/icon/zombIcon = icon(aGhoul.icon, aGhoul.icon_state)
	if(isanimal(aGhoul))
		var/mob/living/simple_animal/ghoulToBe = aGhoul
		zombIcon = icon(ghoulToBe.icon, ghoulToBe.icon_living)
		speed = ghoulToBe.speed*2	//Slower than we were
		maxHealth = ghoulToBe.maxHealth
		health = maxHealth
		melee_damage_upper = ghoulToBe.melee_damage_upper
		melee_damage_lower = ghoulToBe.melee_damage_lower
		attacktext = ghoulToBe.attacktext
		speak = ghoulToBe.speak
	zombIcon.ColorTone("#85B060")
	icon = zombIcon
	name = "[aGhoul.name] ghoul"
	desc = "A ghoulish [aGhoul.name]."

/mob/living/simple_animal/hostile/necro/animal_ghoul/death(var/gibbed = FALSE)
	..(gibbed)
	new /obj/effect/decal/cleanable/ash(loc)
	qdel(src)

/mob/living/simple_animal/hostile/necro/skeleton
	name = "skeleton"
	desc = "Truly the ride never ends."
	icon_state = "skelly"
	icon_living = "skelly"
	icon_dead = "skelly_dead"
	icon_gib = "skelly_dead"
	speak_chance = 0
	turns_per_move = 1
	can_butcher = 0
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 9
	move_to_delay = 3
	maxHealth = 50
	health = 50

	can_butcher = 0

	harm_intent_damage = 10
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK | OPEN_DOOR_SMART
	meat_type = null

#define MAX_EAT_MULTIPLIER 4 //Dead for humans is -maxHealth, uncloneable is -maxHealth * 2

/mob/living/simple_animal/hostile/necro/zombie
	name = "zombie"
	desc = "A reanimated corpse that looks like it has seen better days."
	icon_state = "zombie"
	icon_living = "zombie"
	icon_dead = "zombie"
	icon_gib = "zombie"
	speak_chance = 0
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/animal
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 3
	move_to_delay = 6
	maxHealth = 100
	health = 100
	canRegenerate = 1
	minRegenTime = 30 SECONDS
	maxRegenTime = 120 SECONDS

	harm_intent_damage = 15
	melee_damage_lower = 10
	melee_damage_upper = 20
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	stat_attack = DEAD

	var/times_revived //Tracks how many times the zombie has regenerated from death
	var/times_eaten //Tracks how many times the zombie has chewed on a human corpse
	var/can_evolve = FALSE //False if we don't want it to evolve
	//var/busy //If the zombie is busy, and what it's busy doing

	var/health_cap = 250 //Maximum possible health it can have. Because screw having a 1000 health mob
	var/busy = FALSE //Stop spamming the damn doorsmash
	wanted_objects = list(
		/obj/machinery/light,
	)
	search_objects = 1

	var/list/clothing = list() //If the previous corpse had clothing, it 'wears' it

/mob/living/simple_animal/hostile/necro/zombie/update_perception()
	if(!client)
		return
	if(dark_plane)
		dark_plane.alphas["zombie"] = 90
		see_in_dark = 8
		check_dark_vision()

/mob/living/simple_animal/hostile/necro/zombie/New() //(mob/living/L)
	..()
	hud_list[STATUS_HUD]      = new/image/hud('icons/mob/hud.dmi', src, "hudundead")

/mob/living/simple_animal/hostile/necro/zombie/CanAttack(var/atom/the_target)
	if(the_target == creator)
		return 0
	if(ismob(the_target))
		var/mob/living/M = the_target
		if(ishuman(the_target)) //Checking for food
			var/mob/living/carbon/human/H = the_target
			if(H.isDead())
				if(check_edibility(H))
					return the_target
				else
					return 0
			else
				return ..(the_target)
		else
			if(M.isDead())
				return 0
	if(istype(the_target,/obj/machinery/light))
		var/obj/machinery/light/L = the_target
		return L.current_bulb && L.current_bulb.status != LIGHT_BROKEN

	return ..(the_target)

/mob/living/simple_animal/hostile/necro/zombie/AttackingTarget()
	if(!target)
		return

	if(target == creator)
		return

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.isDead() && check_edibility(H))
			eat(H)
			return 0

	return..()

/mob/living/simple_animal/hostile/necro/zombie/Life()
	if(!isUnconscious())
		if(stance == HOSTILE_STANCE_IDLE && !client) //Not doing anything at the time
			if(can_evolve) //Can we evolve, and have we fed
				check_evolve()
	..()

/mob/living/simple_animal/hostile/necro/zombie/proc/check_edibility(var/mob/living/carbon/human/target)
	if(busy)
		return 0
	if((health < maxHealth) || (maxHealth < health_cap))
		if(!(target.isDead()))
			return 0 //It ain't dead
		if(target.health > -(target.maxHealth*MAX_EAT_MULTIPLIER)) //So they're not caught eating the same dumb bird all day
			return 1
	return 0

/mob/living/simple_animal/hostile/necro/zombie/proc/eat(var/mob/living/carbon/human/target)
	//Deal a random amount of brute damage to the corpse in question, heal the zombie by the damage dealt halved
	visible_message("<span class='warning'>\The [src] takes a bite out of \the [target].</span>")
	stop_automated_movement = 1
	playsound(src, 'sound/weapons/bite.ogg', 50, 1)
	var/damage = rand(melee_damage_lower, melee_damage_upper)
	target.adjustBruteLoss(damage)
	if(maxHealth < health_cap)
		maxHealth += 5 //A well fed zombie is a scary zombie
	health = min(maxHealth, health+damage)
	times_eaten += 1
	stop_automated_movement = 0

/mob/living/simple_animal/hostile/necro/zombie/proc/check_evolve()
	if(!can_evolve)
		return

	/*
					Turned (Just reanimated, can be turned back)
										V
				Rotting (If eaten once, or died once, can't be turned back)
				/													\
			Putrid													Crimson
	Eaten too much, died too little								Eaten too little, died too much
	*/

/mob/living/simple_animal/hostile/necro/zombie/proc/stats()
	stat(null, "Times revived - [times_revived]")
	stat(null, "Times eaten - [times_eaten]")

/mob/living/simple_animal/hostile/necro/zombie/Stat()
	..()
	if(statpanel("Status"))
		stats()

/mob/living/simple_animal/hostile/necro/zombie/proc/evolve(var/mob/living/simple_animal/evolve_to)
	if(ispath(evolve_to, /mob/living/simple_animal/hostile/necro))
		var/mob/living/simple_animal/hostile/necro/evolution = new evolve_to(src.loc,,)
		evolution.name = name //We want to keep the name
		evolution.inherit_mind(src)
		evolution.creator = creator
		evolution.friends = friends.Copy()
		get_clothes(src, evolution)
		if(mind)
			mind.transfer_to(evolution) //Just in the offchance we have a player in control
			evolution.add_spell(/spell/aoe_turf/necro/zombie/evolve)
		qdel(src)
	else
		//Now, how did you get here when this is supposed to be the zombie evolution tree?
		new evolve_to(src.loc)
		qdel(src)

/mob/living/simple_animal/hostile/necro/zombie/update_transform() //Literally pulled from carbon/update_icons.dm
	if(lying != lying_prev)
		var/matrix/final_transform = matrix()
		var/final_pixel_y = pixel_y
		var/final_dir = dir

		if(lying == 0) // lying to standing
			final_pixel_y += 6 * PIXEL_MULTIPLIER
		else //if(lying != 0)
			if(lying_prev == 0) // standing to lying
				final_pixel_y -= 6 * PIXEL_MULTIPLIER
				final_transform.Turn(90)

		lying_prev = lying // so we don't try to animate until there's been another change.

		animate(src, transform = final_transform, pixel_y = final_pixel_y, dir = final_dir, time = 2, easing = EASE_IN | EASE_OUT)

/mob/living/simple_animal/hostile/necro/zombie/revive(refreshbutcher = 1)
	..()
	times_revived += 1
	lying = 0
	update_transform()

/mob/living/simple_animal/hostile/necro/zombie/death(var/gibbed = FALSE)
	..(gibbed)
	lying = 1
	update_transform()

/mob/living/simple_animal/hostile/necro/zombie/UnarmedAttack(atom/A) //There's got to be a better way to keep everything together
	if(A == creator) //Evil necromancy magic means no attacking our creator
		to_chat(src, "Try as you might, you can't bring yourself to attack [A].")
		return
	..()
	if(istype(A, /mob/living/carbon/human))
		if(check_edibility(A))
			eat(A)

/mob/living/simple_animal/hostile/necro/zombie/Destroy()
	for(var/obj/item/I in clothing)
		I.forceMove(get_turf(src))
		clothing.Remove(I)
	..()

/mob/living/simple_animal/hostile/necro/zombie/turned
	icon_state = "zombie_turned" //Looks almost not unlike just a naked guy to potentially catch others off guard
	icon_living = "zombie_turned"
	icon_dead = "zombie_turned"
	desc = "A reanimated corpse that looks like it has seen better days. This one still appears quite fresh."
	maxHealth = 50
	health = 50
	can_evolve = TRUE
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK | OPEN_DOOR_SMART
	var/mob/living/carbon/human/host //Whoever the zombie was previously, kept in a reference to potentially bring back
	var/being_unzombified = FALSE

/mob/living/simple_animal/hostile/necro/zombie/turned/check_evolve()
	..()
	if(times_revived > 0 || times_eaten > 0)
		evolve(/mob/living/simple_animal/hostile/necro/zombie/rotting)

/mob/living/simple_animal/hostile/necro/zombie/turned/Destroy()
	if(host)
		QDEL_NULL(host)
	..()

/mob/living/simple_animal/hostile/necro/zombie/turned/attackby(var/obj/item/weapon/W, var/mob/user)
	..()
	if(!istype(W, /obj/item/weapon/storage/bible)) //This calls for divine intervention
		return
	if(being_unzombified)
		to_chat(user, "<span class='warning'>\The [src] is already being repeatedly whacked!</span>")
		return
	being_unzombified = TRUE
	var/obj/item/weapon/storage/bible/bible = W
	user.visible_message("\The [user] begins whacking at [src] repeatedly with a bible for some reason.", "<span class='notice'>You attempt to invoke the power of [bible.my_rel.deity_name] to bring this poor soul back from the brink.</span>")

	var/holy_bonus = 0 //How much the potential for reconversion works
	if(do_after(user, src, 25)) //So there's a nice delay
		if(user.reagents.reagent_list.len)
			if(user.reagents.has_reagent(WHISKEY) || user.reagents.has_reagent(HOLYWATER)) //Take a swig, then get to work
				holy_bonus += 10
		var/turf/turf_on = get_turf(src) //See if the dead guy's on holy ground
		if(turf_on.holy) //We're in the chapel
			holy_bonus += 10
		if(turf_on.blessed) //Blessed ground by holy water
			holy_bonus += 10
		if(user.mind && isReligiousLeader(user)) //chaplain
			holy_bonus += 65
		if(prob(5+holy_bonus)) //Gotta have faith
			to_chat (user, "<span class='notice'>By [bible.my_rel.deity_name], it's working!</span>")
			unzombify()
		else
			to_chat (user, "<span class='notice'>Well, that didn't work.</span>")
	being_unzombified = FALSE

/mob/living/simple_animal/hostile/necro/zombie/turned/proc/unzombify()
	if(host && mind)
		host.loc = get_turf(src)
		mind.transfer_to(host)
		var/mob/dead/observer/ghost = get_ghost_from_mind(mind)
		if(ghost && ghost.can_reenter_corpse)
			key = mind.key
		host.resurrect() //It's a miracle!
		host.revive()
		host.become_zombie = FALSE
		host.update_perception()
		host.see_in_dark = initial(host.see_in_dark)
		visible_message("<span class='notice'>\The [src]'s eyes regain focus, and the smell of decay vanishes. [host] has come back to their senses!</span>")
		host = null
		qdel(src)
	else
		visible_message("<span class='notice'>\The [src] grumbles for a moment, then begins to decay at an accelerated rate. Seems there was nobody left to save.</span>")
		dust()

/mob/living/simple_animal/hostile/necro/zombie/rotting
	icon_living = "zombie_rotten"
	icon_state = "zombie_rotten"
	icon_dead = "zombie_rotten"
	desc = "A reanimated corpse that looks like it has seen better days. Whoever this was is long gone."
	maxHealth = 100
	health = 100

	can_evolve = TRUE
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK | OPEN_DOOR_SMART

/mob/living/simple_animal/hostile/necro/zombie/rotting/check_evolve()
	..()
	if(times_eaten > (1+times_revived)*2) //Have to have eaten at least twice and more than double that of times died
		evolve(/mob/living/simple_animal/hostile/necro/zombie/putrid)
	else if(times_revived > times_eaten+1) //Died at least twice
		evolve(/mob/living/simple_animal/hostile/necro/zombie/crimson)

/mob/living/simple_animal/hostile/necro/zombie/putrid
	icon_living = "zombie" //The original
	icon_state = "zombie"
	icon_dead = "zombie"
	desc = "A reanimated corpse that looks like it has seen better days. This one appears to be quite gluttonous."
	maxHealth = 150
	health = 150
	can_evolve = 0
	var/zombify_chance = 25 //Down with hardcoding
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK

/mob/living/simple_animal/hostile/necro/zombie/putrid/eat(mob/living/carbon/human/target)
	..()
	if(target.health < -150) //Gotta be a bit chewed on
		visible_message("<span class='warning'>\The [target] stirs, as if it's trying to get up.</span>")
		if(prob(zombify_chance))
			var/master = creator ? creator : src
			target.zombify(master)

/mob/living/simple_animal/hostile/necro/zombie/proc/get_clothes(var/mob/target, var/mob/living/simple_animal/hostile/necro/zombie/new_zombie)
	/*Check what mob type the target is, if it's carbon, run through their wear_ slots see human_defines.dm L#34
	Coalate these into a list
	add the targets overlay to the zombie
	make the target drop everything
	transfer everything that was on the list into the zombie
	Otherwise if it's zombie just transfer the overlay and the clothes reference*/
	var/list/clothes_to_transfer = list()
	var/image/I = image('icons/effects/32x32.dmi',"blank")
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		I.overlays |= H.overlays
		for(var/obj/item/IT in H.get_all_slots())
			clothes_to_transfer += IT
			H.drop_from_inventory(IT)
			IT.forceMove(new_zombie)
	else if(istype(target, /mob/living/simple_animal/hostile/necro/zombie))
		var/mob/living/simple_animal/hostile/necro/zombie/Z = target
		I.overlays |= Z.overlays
		for(var/obj/item/IT in Z.clothing)
			clothes_to_transfer += IT
			Z.clothing.Remove(IT)
			IT.forceMove(new_zombie)

	new_zombie.overlays += I
	for(var/obj/item/IT in clothes_to_transfer)
		new_zombie.clothing.Add(IT)

/mob/living/simple_animal/hostile/necro/zombie/crimson
	name = "crimson skull"
	icon_state = "zombie_crimson"
	icon_living = "zombie_crimson"
	icon_dead = "zombie_crimson"
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 40 //Those claws are not messing around

	attacktext = "slashes"
	attack_sound = "sound/weapons/bloodyslice.ogg"
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG

/mob/living/simple_animal/hostile/necro/zombie/leatherman
	name = "leatherman"
	icon_dead = "zombie_leather"
	icon_gib = "zombie_leather"
	icon_state = "zombie_leather"
	icon_living = "zombie_leather"
	desc = "Fuck you!"
	can_evolve = 0
	unique_name = 1

///////////////// Grey Soldier Zombie ////////////////////
/mob/living/simple_animal/hostile/necro/zombie/greysoldier
	name = "decaying soldier"
	desc = "A zombified grey soldier, wearing a tattered armor vest. It carries itself rather steadily for a zombie."
	icon_state = "decaying_soldier"
	icon_living = "decaying_soldier"
	icon_dead = "decaying_soldier"
	move_to_delay = 3 // Quite a bit faster than a normal zombie, though still easy to outrun
	can_evolve = 0
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/grey // Slighty rotten AND acidic. Nice.

/mob/living/simple_animal/hostile/necro/zombie/greylaborer
	name = "mauled laborer"
	desc = "A zombified grey laborer, wearing the torn remains of its overalls. It shambles quite rapidly."
	icon_state = "mauled_laborer"
	icon_living = "mauled_laborer"
	icon_dead = "mauled_laborer"
	move_to_delay = 4 // A bit faster than a regular zombie
	can_evolve = 0
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/grey // Slighty rotten AND acidic. Nice.

	maxHealth = 80 // Slightly less health
	health = 80

///////////////// Vox Raider Zombies ////////////////////
/mob/living/simple_animal/hostile/necro/zombie/raider1
	name = "tainted raider"
	desc = "A zombified vox raider, still clad in the remains of armored hardsuit plates. Its remaining eye gleams with a new kind of hunger."
	icon_state = "rotting_raider1"
	icon_living = "rotting_raider1"
	icon_dead = "rotting_raider1"
	move_to_delay = 4 // A bit faster due to recently turning
	can_evolve = 0
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/vox // Would you eat zombie chicken?

	health = 125 // A little tankier due to wearing remains of armor
	maxHealth = 125

	melee_damage_lower = 15
	melee_damage_upper = 25

	attacktext = "claws"
	attack_sound = 'sound/weapons/slice.ogg'
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK

/mob/living/simple_animal/hostile/necro/zombie/raider2
	name = "rotting raider"
	desc = "A zombified vox raider, still clad in the remains of armored hardsuit plates. Its remaining eye gleams with a new kind of hunger."
	icon_state = "rotting_raider2"
	icon_living = "rotting_raider2"
	icon_dead = "rotting_raider2"
	move_to_delay = 4
	can_evolve = 0
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken/vox

	health = 125
	maxHealth = 125

	melee_damage_lower = 15
	melee_damage_upper = 25

	attacktext = "claws"
	attack_sound = 'sound/weapons/slice.ogg'
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK

///////////////// GHOULS ////////////////////
/mob/living/simple_animal/hostile/necro/zombie/ghoul
	name = "ghoul"
	icon_state = "ghoul"
	icon_dead = "ghoul"
	icon_living = "ghoul"
	desc = "Suffering from onset decay from radiation exposure. They have lost their mind and soul, but not their hunger."
	can_evolve = 0
	canRegenerate = 0

	health = 150
	maxHealth = 150

	melee_damage_lower = 10
	melee_damage_upper = 20
	attacktext = "punches"
	attack_sound = "sound/weapons/punch1.ogg"
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG

/mob/living/simple_animal/hostile/necro/zombie/ghoul/Life()
	..()
	if(!isDead() && radiation && health < maxHealth)
		health++
		radiation--

/mob/living/simple_animal/hostile/necro/zombie/ghoul/unarmed_attack_mob(mob/living/target)
	..()
	target.apply_radiation(rand(melee_damage_lower, melee_damage_upper)/5, RAD_EXTERNAL)

#define RAD_COST 100

/mob/living/simple_animal/hostile/necro/zombie/ghoul/glowing_one
	name = "glowing one"
	icon_state = "glowing_one"
	icon_dead = "glowing_one"
	icon_living = "glowing_one"
	desc = "Some poor fool, having been caught in an incident involving radiation, has now suffered it binding to their very essence."

	health = 200
	maxHealth = 200
	health_cap = 400

	melee_damage_lower = 15
	melee_damage_upper = 25
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART
	var/last_rad_blast = 0

/mob/living/simple_animal/hostile/necro/zombie/ghoul/glowing_one/Life()
	..()
	if(!isDead())
		if(world.time > last_rad_blast+20 SECONDS)
			rad_blast()
		radiation+=5

/mob/living/simple_animal/hostile/necro/zombie/ghoul/glowing_one/proc/rad_blast()
	if(radiation > RAD_COST)
		if(prob(30))
			visible_message("<span class = 'blob'>\The [src] glows with a brilliant light!</span>")
		set_light(vision_range/2, vision_range, "#a1d68b")
		spawn(1 SECONDS)
			emitted_harvestable_radiation(get_turf(src), rand(250, 500), range = 7)

			var/list/can_see = view(src, vision_range)
			for(var/mob/living/carbon/human/H in can_see)
				var/rad_cost = min(radiation, rand(10,20))
				H.apply_radiation(rad_cost, RAD_EXTERNAL)
				radiation -= rad_cost
				if(!radiation)
					break
			if(radiation > 25)
				for(var/mob/living/simple_animal/hostile/necro/zombie/ghoul/G in can_see)
					if(G.isDead() && radiation > 100)
						G.revive()
						radiation -= 100
					if(radiation > 25)
						var/rad_cost = min(radiation, rand(10,20))
						G.apply_radiation(10, RAD_EXTERNAL)
						radiation -= rad_cost
					if(radiation < 25)
						break
			last_rad_blast = world.time
			spawn(3 SECONDS)
				set_light(1, 2, "#5dca31")

#undef RAD_COST

///////////////// HEADCRAB ZOMBIES ////////////////////
/mob/living/simple_animal/hostile/necro/zombie/headcrab
	icon_state = "zombie_headcrab"
	icon_living = "zombie_headcrab"
	icon_dead = "zombie_headcrab"
	desc = "A human that is under control of a headcrab. Better stay away unless you want to become one too."
	maxHealth = 75
	health = 75
	can_evolve = FALSE
	canRegenerate = 0
	var/mob/living/carbon/human/host //Whoever the zombie was previously, kept in a reference to potentially bring back
	var/obj/item/clothing/mask/facehugger/headcrab/crab //The crab controlling it.
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK | OPEN_DOOR_SMART

/mob/living/simple_animal/hostile/necro/zombie/headcrab/New(loc, mob/living/Owner, var/mob/living/Victim, datum/mind/Controller)
	..()
	if (!Victim)
		icon_state = "zombie_headcrab_clothed"
		icon_living = "zombie_headcrab_clothed"
		icon_dead = "zombie_headcrab_clothed"

/mob/living/simple_animal/hostile/necro/zombie/headcrab/Destroy()
	if(host)
		QDEL_NULL(host)
	..()

/mob/living/simple_animal/hostile/necro/zombie/headcrab/death(var/gibbed = FALSE)
	if(transmogged_from) // we're not a real zombie!
		..(gibbed)
		return
	..(gibbed)
	if(host)
		host.forceMove(get_turf(src))
		if(mind)
			mind.transfer_to(host)
			var/mob/dead/observer/ghost = get_ghost_from_mind(mind)
			if(ghost && ghost.can_reenter_corpse)
				key = mind.key
		if(prob(33))	//33% chance to blow up their fucking head
			var/datum/organ/external/head/head_organ = host.get_organ(LIMB_HEAD)
			head_organ.explode()
		else
			visible_message("<span class='danger'>The headcrab releases it's grasp from [src]!</span>")
		crab?.escaping = 1
		crab?.stat = CONSCIOUS
		crab?.target = null
		host = null
	else
		host = new /mob/living/carbon/human(get_turf(src))
		host.get_organ(LIMB_HEAD).explode()
		host = null
		visible_message("<span class='danger'>The [src] collapses weakly!</span>")  //There was not a host.
	qdel(src)

/mob/living/simple_animal/hostile/necro/zombie/headcrab/say(message, bubble_type)
	return ..(reverse_text(message))


/*Necromorphs
	4 types
		Slasher, melee based, simple mobs
		Leaper, melee based, high mobility, latch onto foes, hide in vents
		Puker, semi-ranged based, vomits a highly corrosive cone of acid forwards towards its victims
		Exploder, melee based, steady shuffle towards a target before exploding. Explodes on death
*/
/mob/living/simple_animal/hostile/necro/necromorph
	name = "necromorph"
	desc = "A twisted husk of what was once human, repurposed to kill."
	speak_emote = list("roars")
	icon = 'icons/mob/monster_big.dmi'
	icon_state = "nmorph_standard"
	icon_living = "nmorph_standard"
	icon_dead = "nmorph_dead"
	health = 80
	maxHealth = 80
	melee_damage_lower = 25
	melee_damage_upper = 50
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = "marker"
	speed = 5
	size = SIZE_BIG
	move_to_delay = 4
	canRegenerate = 1
	minRegenTime = 30 SECONDS
	maxRegenTime = 60 SECONDS
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART

/mob/living/simple_animal/hostile/necro/necromorph/leaper
	desc = "A twisted husk of what was once human. Sporting razor-sharp fangs, along with a long scythe-tipped tail."
	icon_state = "nmorph_leaper"
	icon_living = "nmorph_leaper"
	icon_dead = "nmorph_leaper_dead"
	speed = 1
	health = 45
	maxHealth = 45

	melee_damage_lower = 10
	melee_damage_upper = 20
	attacktext = "slashes"
	attack_sound = 'sound/weapons/slashmiss.ogg'

	ranged = 1
	ranged_cooldown_cap = 8
	ranged_message = "leaps"

/mob/living/simple_animal/hostile/necro/necromorph/leaper/Shoot(var/atom/target, var/atom/start, var/mob/user, var/bullet = 0)
	if(locked_to)
		return 0

	src.throw_at(get_turf(target),7,1)
	return 1

/mob/living/simple_animal/hostile/necro/necromorph/leaper/to_bump(atom/A)
	if(throwing && isliving(A) && CanAttack(A))
		attach(A)
	..()

/mob/living/simple_animal/hostile/necro/necromorph/leaper/Life()
	update_climb()
	if(!isUnconscious())
		if(stance == HOSTILE_STANCE_IDLE && !client)
			var/list/can_see = view(get_turf(src), vision_range/2) //Nothing too close for comfort
			var/all_clear = 1
			for(var/mob/living/L in can_see)
				if(!istype(L, /mob/living/simple_animal/hostile/necro/necromorph) && !(L.isDead()))
					all_clear = 0
			if(!istype(loc, /obj/machinery/atmospherics/unary/vent_pump) && istype(loc, /turf) && all_clear)
				stop_automated_movement = 0

				for(var/obj/machinery/atmospherics/unary/vent_pump/vent in can_see)
					if(Adjacent(vent))
						//Climb in
						visible_message("<span class = 'warning'>\The [src] starts climbing into \the [vent]!</span>")
						forceMove(vent)
						stop_automated_movement = 1
						break
					else
						if(prob(30))
							step_towards(src, vent)//Step towards it
							if(environment_smash_flags & SMASH_LIGHT_STRUCTURES)
								EscapeConfinement()
						break

			else if(istype(loc, /obj/machinery/atmospherics/unary/vent_pump) && !all_clear)
				loc.visible_message("<span class = 'warning'>\The [src] clambers out of \the [loc]!</span>")
				forceMove(get_turf(loc))
	..()

/mob/living/simple_animal/hostile/necro/necromorph/leaper/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Object"
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)

/mob/living/simple_animal/hostile/necro/necromorph/leaper/proc/update_climb()
	var/mob/living/L = locked_to

	if(!istype(L))
		return

	if(incapacitated())
		return detach()

	if(!CanAttack(L))
		return detach()

/mob/living/simple_animal/hostile/necro/necromorph/leaper/proc/detach()
	unlock_from()

	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)

/mob/living/simple_animal/hostile/necro/necromorph/leaper/proc/attach(mob/living/victim)
	victim.lock_atom(src, /datum/locking_category/)
	victim.visible_message("<span class = 'warning'>\The [src] latches onto \the [victim]!</span>","<span class = 'userdanger'>\The [src] latches onto you!</span>")

	pixel_x = rand(-8,8) * PIXEL_MULTIPLIER
	pixel_y = rand(0,16) * PIXEL_MULTIPLIER

/mob/living/simple_animal/hostile/necro/necromorph/leaper/AttackingTarget()
	.=..()

	if(locked_to == target && isliving(target))
		var/mob/living/L = target

		if(prob(10))
			to_chat(L, "<span class='userdanger'>\The [src] throws you to the ground!</span>")
			var/incapacitation_duration = rand(2, 5)
			L.Knockdown(incapacitation_duration)
			L.Stun(incapacitation_duration)

/mob/living/simple_animal/hostile/necro/necromorph/leaper/adjustBruteLoss(amount)
	.=..()

	if(locked_to && prob(amount * 5))
		detach()

/mob/living/simple_animal/hostile/necro/necromorph/exploder
	desc = "A twisted husk of what was once human. A large glowing pustule attached to their left arm."
	icon_state = "nmorph_exploder"
	icon_living = "nmorph_exploder"
	icon_dead = ""
	health = 30
	maxHealth = 30
	speed = 2

/mob/living/simple_animal/hostile/necro/necromorph/exploder/AttackingTarget()
	visible_message("<span class='warning'>\The [src] hits \the [target] with their left arm!</span>")
	death()

/mob/living/simple_animal/hostile/necro/necromorph/exploder/death(var/gibbed = FALSE)
	..(TRUE)
	visible_message("<span class='warning'>\The [src] explodes!</span>")
	var/turf/T = get_turf(src)
	new /obj/effect/gibspawner/generic(T)
	qdel(src)
	explosion(T, -1, 1, 4, whodunnit = src)

/mob/living/simple_animal/hostile/necro/necromorph/puker
	desc = "A twisted, engorged husk of what was once human. It reeks of stomach acid."
	icon_state = "nmorph_puker"
	icon_living = "nmorph_puker"
	icon_dead = "nmorph_puker_dead"

	ranged = 1
	ranged_cooldown_cap = 20
	projectiletype = /obj/item/projectile/puke
	ranged_message = "pukes"

	melee_damage_lower = 10
	melee_damage_upper = 15
