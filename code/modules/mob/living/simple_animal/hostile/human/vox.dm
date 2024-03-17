///////////////////////////////////////////////////////////////////FERAL VOX///////////
//Previously found in Blacksite Prism
/mob/living/simple_animal/hostile/humanoid/vox
	name = "vox"
	desc = "A bird-like creature. This one is feral."
	see_in_dark = 3

	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "vox"
	melee_damage_lower = 5
	melee_damage_upper = 10 // Ouch ow, vox beak

	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	min_oxy = 0
	max_oxy = 1
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 5 //breathe N2
	max_n2 = 0

	corpse = /obj/effect/landmark/corpse/vox

/mob/living/simple_animal/hostile/humanoid/vox/New() // vox hostiles will speak chikun
	..()
	languages += all_languages[LANGUAGE_VOX]

//////////////////////////////
// VOX PRISONERS
//////////////////////////////
//Found in Blacksite Prism
/mob/living/simple_animal/hostile/humanoid/vox/prisoner // Boring default prisoner, for inheritance
	name = "Vox Prisoner"
	desc = "A bird-like creature. This one is wearing a prisoner's uniform and seems to be hostile."
	icon_state = "vox_testsubject"

	melee_damage_lower = 5
	melee_damage_upper = 10

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART
	stat_attack = UNCONSCIOUS // No mercy in the big house

	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'

	max_oxy = 0
	max_tox = 0
	max_co2 = 0
	min_n2 = 0 // Won't die immediately when they spawn in Blacksite Prism anymore

	speak = list("Head itches inside, but can't scratch. Annoying.","When escape, will tear them all apart piece by piece.","Last remember, was making good trade for shoal on human station. Deal go bad, maybe.","Kreh, so hungry. Will eat anything, don't care.","Kill, kill, kill...")
	speak_chance = 1

	corpse = /obj/effect/landmark/corpse/vox/prisoner
	faction = "prisoner" // We're all brothers and sisters in binds now

/mob/living/simple_animal/hostile/humanoid/vox/prisoner/Aggro()
	..()
	say(pick("I rip you apart!","Kill or eat, why not both?","Don't care who you are. Die now!","Will slaughter you, then use your skin as rug!","KREEEEEEEEEEE!"), all_languages[LANGUAGE_VOX])

///////////////////////////////////////////////////////////////////Melee Prisoner///////////
//Prisoner with a makeshift hatchet. Will throw bolas at distant targets, then close in to tear them up
/mob/living/simple_animal/hostile/humanoid/vox/prisoner/melee
	desc = "A bird-like creature. This one is grasping a makeshift hatchet and some bolas in its claws."
	icon_state = "vox_testsubject_melee"

	melee_damage_lower = 12
	melee_damage_upper = 16

	attacktext = "chops"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	items_to_drop = list(/obj/item/weapon/hatchet/tomahawk/metal, /obj/item/weapon/legcuffs/bolas)

	ranged_message = "shrieks angrily"
	retreat_distance = 2 // Will attempt to kite/avoid incoming melee attacks
	minimum_distance = 1
	ranged = 1

	var/last_bolathrow = 0
	var/const/bolathrow_cooldown = 45 SECONDS // Needs to wait a while between bola throws

/mob/living/simple_animal/hostile/humanoid/vox/prisoner/melee/Shoot(var/atom/target, var/atom/start, var/mob/user)
	var/mob/living/carbon/human/H = target
	if(last_bolathrow + bolathrow_cooldown < world.time) // If we're not on cooldown, chuck some bolas at a distant target
		var/atom/movable/bola_to_throw = new /obj/item/weapon/legcuffs/bolas(get_turf(src))
		visible_message("<b><span class='warning'>[src] tosses some bolas at [H]!</span>")
		bola_to_throw.throw_at(target,10,3)
		last_bolathrow = world.time
	else // Otherwise shriek angrily at the target for a massive debuff to their morale
		..()

///////////////////////////////////////////////////////////////////Ranged Prisoner///////////
//Prisoner with a powered crossbow. Just as dangerous as the old vox raiders
/mob/living/simple_animal/hostile/humanoid/vox/prisoner/ranged
	desc = "A bird-like creature. This one is grasping a jury-rigged powered crossbow in its claws."
	icon_state = "vox_testsubject_crossbow"

	items_to_drop = list(/obj/item/weapon/crossbow, /obj/item/weapon/arrow/quill, /obj/item/weapon/arrow/quill, /obj/item/weapon/arrow/quill)

	ranged = 1
	retreat_distance = 4
	minimum_distance = 4
	ranged_cooldown_cap = 6

/mob/living/simple_animal/hostile/humanoid/vox/prisoner/ranged/Shoot(var/target, var/start, var/user, var/bullet = 0)
	if(target == start)
		return
	if(!istype(target, /turf))
		return

	var/obj/item/weapon/arrow/A = new /obj/item/weapon/arrow/quill(get_turf(src))
	visible_message("<b><span class='warning'>[src] launches a quill from their crossbow!</span>")
	A.throw_at(target,10,25)

	ranged_cooldown = 6
	return

//////////////////////////////
// NU VOX RAIDERS
//////////////////////////////
//Vox raiders armed with various ranged weapons, with a bias towards cheaper ballistics

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider //Baseline chikun raider, here so that the others that follow inherit all its useful properties
	name = "Vox Raider"
	desc = "A bird-like creature in a space suit. This one seems partial to raiding."
	icon_state = "voxraider"
	health = 150
	maxHealth = 150
	melee_damage_lower = 6
	melee_damage_upper = 12

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART // Will smash through obstacles and force open doors to track down targets
	stat_attack = UNCONSCIOUS //These raiders are extra mean

	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'

	max_oxy = 0
	max_tox = 0
	max_co2 = 0
	min_n2 = 0
	minbodytemp = 0
	maxbodytemp = 1000 //Spess protection stats

	corpse = /obj/effect/landmark/corpse/vox/spaceraider

	faction = "raider" //Assigning them a shared faction means they will attack most mobs but not each other

	var/noloot_retreat = null
	var/noloot_minimum = 1

	search_objects = 1
	wanted_objects = list(/obj/item/weapon/spacecash) //Gotta grab everything I can

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/Found(atom/A)
	if(istype(A,/obj/item/weapon/spacecash))
		return TRUE

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/ranged_mode() //So they don't shoot money instead of running to it and picking it up
	if(is_type_in_list(target, wanted_objects))
		retreat_distance = null
		minimum_distance = 1
		return FALSE
	if(isliving(target))
		retreat_distance = noloot_retreat
		minimum_distance = noloot_minimum
	return ..()

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/AttackingTarget() //Grab dat loot
	if(istype(target,/obj/item/weapon/spacecash))
		var/atom/movable/cash = target
		say(pick("What's this? Mine!","Love smell of fresh credits in morning.","This is my loot.","Money! Happiness!","Ah... \a [target]. Very good, yes."), all_languages[LANGUAGE_VOX]) //Money looting speech dialogue
		cash.forceMove(src)
		LoseAggro()
	else
		..()

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/death(gibbed = FALSE) //Drop the loot on death
	for(var/obj/item/weapon/spacecash/S in src)
		S.forceMove(loc)
	..()

//The two lines below mean this mob and any that inherit from it can follow someone retreating into space, and won't just float off once they hit vacuum
/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/Process_Spacemove(var/check_drift = 0)
	return 1

///////////////////////////////////////////////////////////////////MEDIC RAIDER///////////
//Weakest of the bunch in terms of damage potential, but can heal itself

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/medic
	name = "Vox Medic"
	desc = "A vox raider in a pressure suit. This one is clutching a syringe and brandishing a glock pistol."
	icon_state = "voxraider_medic"

	var/last_healed = 0
	var/const/heal_cooldown = 30 SECONDS // Can heal himself when he starts losing health

	corpse = /obj/effect/landmark/corpse/vox/spaceraider_medic

	items_to_drop = list(/obj/item/weapon/gun/projectile/glock, /obj/item/weapon/reagent_containers/syringe, /obj/item/weapon/storage/pill_bottle/random)

	speak = list("Syringes are sterile, if you trade good.","The raid life is hard, but it is the best life.","CPR costs credits.")
	speak_chance = 1

	projectiletype = /obj/item/projectile/bullet/auto380
	projectilesound = 'sound/weapons/semiauto.ogg'
	noloot_retreat = 4
	noloot_minimum = 4
	ranged = 1

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/medic/Aggro()
	..()
	say(pick("Come here, I promise to do no harm. Keheheh!","Time to shoot and loot!","I see you! Dying time now.","I take some organs for Shoal account."), all_languages[LANGUAGE_VOX])

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/medic/Life(var/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/medic/M)
	..()

	if((last_healed + heal_cooldown < world.time) && health<120) // This raider medic only heals himself. His patients must all be poor
		health+=30
		visible_message("<span class='warning'>[src] stabs themselves with a syringe and injects the contents. Their wounds start to heal!</span>")
		new /obj/item/weapon/reagent_containers/syringe/broken(src.loc)
		last_healed = world.time

///////////////////////////////////////////////////////////////////ASSASSIN RAIDER///////////
//More dangerous than the medic. Throws knives and has a retro laser gun, also remembers the basics...

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/assassin
	name = "Vox Assassin"
	desc = "A vox raider in a pressure suit. This one is wielding an old laser gun and is equipped with an array of knives for throwing."
	icon_state = "voxraider_assassin"

	melee_damage_lower = 15
	melee_damage_upper = 25 // He's got a knoif

	attacktext = "stabs"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	see_in_dark = 5 // Can see a little better in the dark

	corpse = /obj/effect/landmark/corpse/vox/spaceraider_assassin

	items_to_drop = list(/obj/item/weapon/gun/energy/laser/retro, /obj/item/weapon/kitchen/utensil/knife/tactical)

	speak = list("My knives are thirsty.","Too long since seen blood.","I take only the strong ones as slaves.")
	speak_chance = 1

	projectiletype = /obj/item/projectile/beam/retro
	projectilesound = 'sound/weapons/Laser.ogg'
	noloot_retreat = 2
	noloot_minimum = 2
	ranged = 1

	var/last_takedown = 0 // He remembers the basics
	var/const/takedown_cooldown = 20 SECONDS

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/assassin/Aggro()
	..()
	say(pick("Challenge, khm?","We fight, then.","You will die quickly."), all_languages[LANGUAGE_VOX])

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/assassin/AttackingTarget() // Vox judo chooooooooooooooop
	var/mob/living/carbon/human/H = target
	if((last_takedown + takedown_cooldown < world.time) && !H.lying && ishuman(H) && (H.get_strength() < 2)) // Will only bully weak spessmen with this. You shoulda trained HARDER
		H.visible_message("<span class='danger'>[src] sweeps [H]'s legs and slams them to the ground!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 50, 1)
		last_takedown = world.time
		H.adjustBruteLoss(10)
		H.Knockdown(3)
	else // Otherwise just give 'em a stab
		..()

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/assassin/Shoot(var/atom/target, var/atom/start, var/mob/user)
	if(prob(10))
		visible_message("<span class = 'warning'>\The [src] hurls a knife towards \the [target]!</span>")
		var/atom/movable/knife_to_throw = new /obj/item/weapon/kitchen/utensil/knife/tactical(get_turf(src))
		knife_to_throw.throw_at(target,10,10) // In practice the damage done per throw at these values is about ~20 brute
	else
		..()

//This one has a submachine gun instead of a retro laser. Does not fire in bursts
/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/assassin/smg
	desc = "A vox raider in a pressure suit. This one is wielding a submachine gun and is equipped with an array of knives for throwing."
	icon_state = "voxraider_assassin2"

	items_to_drop = list(/obj/item/weapon/gun/projectile/automatic, /obj/item/weapon/kitchen/utensil/knife/tactical)

	projectiletype = /obj/item/projectile/bullet/midbullet2
	projectilesound = 'sound/weapons/Gunshot.ogg'

///////////////////////////////////////////////////////////////////BREACHER RAIDER///////////
//A bit slower, but a bit tankier. Has a shotgun to greatly discourage CQC, will occasionally throw bangers

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/breacher
	name = "Vox Breacher"
	desc = "A vox raider in a pressure suit. This one seems to be more heavily armored, and is equipped with a shotgun."
	icon_state = "voxraider_breacher"

	health = 200
	maxHealth = 200

	move_to_delay = 3 // Sacrifices speed for more health/armor

	corpse = /obj/effect/landmark/corpse/vox/spaceraider

	items_to_drop = list(/obj/item/weapon/gun/projectile/shotgun/pump/combat, /obj/item/weapon/grenade/flashbang)

	speak = list("Greys and humans are so squishy, keheh.","So much loot, I can retire soon.","Need to clean gun again.")
	speak_chance = 1

	projectiletype = /obj/item/projectile/bullet/buckshot
	projectilesound = 'sound/weapons/shotgun.ogg'
	noloot_retreat = 3
	noloot_minimum = 3
	ranged = 1

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/breacher/Shoot(var/atom/target, var/atom/start, var/mob/user)
	if(prob(5)) // Throw a banger
		visible_message("<span class = 'warning'>\The [src] primes a flashbang and hurls it towards \the [target]!</span>")
		say("[pick("No credit needed for this.", "Gift for friend!", "Throwing bang!")]")
		var/atom/movable/grenade_to_throw = new /obj/item/weapon/grenade/flashbang(get_turf(src))
		var/obj/item/weapon/grenade/F = grenade_to_throw
		grenade_to_throw.throw_at(target,10,2)
		F.activate()
	else // Otherwise just fire the shotgun
		..()

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/breacher/Aggro()
	..()
	say(pick("Some rats going to die... here I come!","We see how brave you are after some buckshot.","Attack! Kill them!"), all_languages[LANGUAGE_VOX])

///////////////////////////////////////////////////////////////////DEADEYE RAIDER///////////
//Aptly named. One shot is enough to send any spessman running home to medbay, or worse

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/deadeye
	name = "Vox Deadeye"
	desc = "A vox raider in a pressure suit. This one is hefting a large mosin rifle, and you're in their sights..."
	icon_state = "voxraider_deadeye"

	see_in_dark = 10
	vision_range = 10
	aggro_vision_range = 10
	idle_vision_range = 10 // He's got good eyes

	corpse = /obj/effect/landmark/corpse/vox/spaceraider_deadeye

	items_to_drop = list(/obj/item/weapon/gun/projectile/mosin)

	speak = list("Right between eyes...","Kill from far, then plunder the shiny things.","A good hunt for the Shoal.")
	speak_chance = 1

	ranged = 1
	projectiletype = /obj/item/projectile/bullet/a762x55
	projectilesound = 'sound/weapons/mosin.ogg'
	noloot_retreat = 7
	noloot_minimum = 7
	ranged_cooldown_cap = 6 // Fairly long cooldown to balance the serious punch these guys pack

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/deadeye/Aggro()
	..()
	say(pick("Run, run, run! Keheh.","You will look good as wall trophy.","Hold still just a moment, yes?."), all_languages[LANGUAGE_VOX])

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/deadeye/Shoot()
	ranged_cooldown = 6
	..()

///////////////////////////////////////////////////////////////////RAID LEADER///////////
//He's the boss, boss chikun. Should be a fairly tough fight

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/leader
	name = "Vox Raid Leader"
	desc = "A vox raider in an armored blood-red hardsuit. He is heavily armed, wielding a compact shotgun and a high-frequency machete."
	icon_state = "voxraider_leader"
	health = 300
	maxHealth = 300

	see_in_dark = 10
	vision_range = 10
	aggro_vision_range = 10
	idle_vision_range = 10 // He's the boss, nothing gets past him

	melee_damage_lower = 40 // That machete is no joke
	melee_damage_upper = 60

	attacktext = "cleaves"
	attack_sound = 'sound/weapons/machete_hit01.ogg'

	status_flags = UNPACIFIABLE // Too angry to be pacified. Also meant to be a "boss" mob, so that would be a bit silly
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART // Here's Johnny

	var/berserk = 0
	var/last_bigheal = 0
	var/const/bigheal_cooldown = 30 SECONDS // Can heal himself when his health gets very low, but has to wait before doing it again

	var/last_handchop = 0
	var/const/handchop_cooldown = 15 SECONDS // Uh oh

	corpse = /obj/effect/landmark/corpse/vox/spaceraider_leader

	items_to_drop = list(/obj/item/weapon/gun/projectile/shotgun/pump/combat/shorty, /obj/item/weapon/melee/energy/hfmachete)

	speak = list("When the reinforcements get here...","Kraaaah, this take too much time!","Stupid fleshies.","For every ten prisoners... kill five, take four for slaves, and leave one to tell tale.")
	speak_chance = 5

	ranged = 1
	projectiletype = /obj/item/projectile/bullet/buckshot
	projectilesound = 'sound/weapons/shotgun.ogg'
	noloot_retreat = 3
	noloot_minimum = 3

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/leader/Aggro()
	..()
	say(pick("I will drink from your skull!","Kraaah, die die die!","You brave, I take you as crop growing slave.","I am strong, you are weak!"), all_languages[LANGUAGE_VOX])

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/leader/Life()
	..()
	if(health <= (maxHealth/2)) // Will go berserk if he loses half his health
		berserk()

	if((last_bigheal + bigheal_cooldown < world.time) && health < 75) // After he heals he has to wait quite a while before doing it again. Don't give him time to do it again
		health+=150
		visible_message("<span class='warning'>[src] draws a giant syringe and injects himself with the contents. He shrieks, but his wounds rapidly begin to heal!</span>")
		playsound(src, 'sound/misc/shriek1.ogg', 50, 1)
		new /obj/item/weapon/reagent_containers/syringe/giant(src.loc)
		last_bigheal = world.time

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/leader/AttackingTarget()
	if(istype(target, /mob/living))
		var/mob/living/M = target
		if(ishuman(M) && (last_handchop + handchop_cooldown < world.time))
			handChop(M)
		else
			..()

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/leader/proc/berserk()
	visible_message("<span class='warning'>[src] lowers his shotgun and charges with his machete raised!</span>")
	ranged = 0
	move_to_delay = 1.6 // Chaaaaaaaaaaarge
	noloot_retreat = 2 // Will attempt to get close
	noloot_minimum = 1

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/leader/proc/handChop(var/mob/living/carbon/human/H)
	var/datum/organ/external/toChop = H.pick_usable_organ(LIMB_LEFT_HAND, LIMB_RIGHT_HAND)
	if(toChop)
		toChop.droplimb(1,1)
		visible_message("<span class='warning'>[src] slices [H]'s hand clean off with a well placed slash!</span>")
		playsound(src, 'sound/weapons/machete_hit01.ogg', 50, 1)
		H.update_icons()
		say(pick("Another for the collection!","Still feel brave, fool?","Need a hand? Krahahahaaa!","That is the fate of all weaklings!"), all_languages[LANGUAGE_VOX])
		last_handchop = world.time
	else
		return

//Named subtype present in the lab vault
/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/leader/named
	name = "Hakiyikachiyayi the Handchopper"
	desc = "A notorious shoal raider, wanted dead or alive in at least twelve sectors."

	corpse = /obj/effect/landmark/corpse/vox/spaceraider_leader_named

/////////VOX SHARPSHOOTERS
//Armed with crossbows

/mob/living/simple_animal/hostile/humanoid/vox/crossbow
	name = "vox sharpshooter"
	desc = "A raider with ranged combat training and a crossbow."
	icon_state = "sharpshooter"

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5

	ranged_cooldown_cap = 6

	corpse = /obj/effect/landmark/corpse/vox/crossbow
	items_to_drop = list(/obj/item/weapon/crossbow, /obj/item/weapon/arrow/quill, /obj/item/weapon/arrow/quill, /obj/item/weapon/arrow/quill)

/mob/living/simple_animal/hostile/humanoid/vox/crossbow/Shoot(var/target, var/start, var/user, var/bullet = 0)
	if(target == start)
		return
	if(!istype(target, /turf))
		return

	var/obj/item/weapon/arrow/A = new /obj/item/weapon/arrow/quill(get_turf(src))
	visible_message("<b><span class='warning'>[src] launches a quill from their crossbow!</span>")
	A.throw_at(target,10,25)

	ranged_cooldown = 6 // Why this wasn't here before is beyond me. This should make it so these guys don't fire crossbows like machine guns
	return

/mob/living/simple_animal/hostile/humanoid/vox/crossbow/spacesuit
	desc = "A raider with ranged combat training, crossbow and a spacesuit to survive in an environment without N2."
	icon_state = "sharpshooter_space"

	max_oxy = 0
	max_tox = 0
	max_co2 = 0
	min_n2 = 0
	minbodytemp = 0
	maxbodytemp = 1000

	corpse = /obj/effect/landmark/corpse/vox/crossbow/space

///////VOX CYBER OPERATORS
//Armed with ion guns

/mob/living/simple_animal/hostile/humanoid/vox/ion
	name = "vox cyber operator"
	desc = "A raider equipped with an ion gun, to take down cyborgs and mechs."
	icon_state = "ion"

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/ion
	projectilesound = 'sound/weapons/ion.ogg'
	ranged_cooldown_cap = 4

	items_to_drop = list(/obj/item/weapon/gun/energy/ionrifle)

	corpse = /obj/effect/landmark/corpse/vox/ion

/mob/living/simple_animal/hostile/humanoid/vox/ion/spacesuit
	desc = "A raider equipped with an ion gun and a spacesuit to survive in an environment without N2."
	icon_state = "ion_space"

	max_oxy = 0
	max_tox = 0
	max_co2 = 0
	min_n2 = 0
	minbodytemp = 0
	maxbodytemp = 1000

	corpse = /obj/effect/landmark/corpse/vox/ion/space
