/mob/living/simple_animal/hostile/humanoid/vox
	name = "vox"
	desc = "A bird-like creature. This one is feral."

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

///////////////////////////////////////////////////////////////////NU VOX RAIDERS///////////
//Armed with various ranged weapons, with a bias towards cheaper ballistics

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider //Baseline chikun raider, here so that the others that follow inherit all its useful properties
	name = "Vox Raider"
	desc = "A bird-like creature in a space suit. This one seems partial to raiding."
	icon_state = "voxraider"
	health = 150
	maxHealth = 150
	melee_damage_lower = 6
	melee_damage_upper = 12

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

//The two lines below mean this mob and any that inherit from it can follow someone retreating into space, and won't just float off once they hit vacuum
/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/Process_Spacemove(var/check_drift = 0)
	return 1

///////////////////////////////////////////////////////////////////MEDIC RAIDER///////////
//Weakest of the bunch in terms of damage potential, but can heal itself

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/medic
	name = "Vox Medic"
	desc = "A vox raider in a pressure suit. This one is clutching a syringe and brandishing a glock pistol."
	icon_state = "voxraider_medic"

	environment_smash_flags = 0 // Medics are too skittish to smash stuff, and bootleg medical equipment is expensive

	var/last_healed = 0
	var/const/heal_cooldown = 30 SECONDS // Can heal himself when he starts losing health

	corpse = /obj/effect/landmark/corpse/vox/spaceraider_medic

	items_to_drop = list(/obj/item/weapon/gun/projectile/glock, /obj/item/weapon/reagent_containers/syringe, /obj/item/weapon/storage/pill_bottle/random)

	speak = list("Syringes are sterile, if you trade good.","The raid life is hard, but it is the best life.","CPR costs credits.")
	speak_chance = 1

	projectiletype = /obj/item/projectile/bullet/auto380
	projectilesound = 'sound/weapons/semiauto.ogg'
	retreat_distance = 4
	minimum_distance = 4
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
//More dangerous than the medic. Throws knives and has a retro laser gun

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/assassin
	name = "Vox Assassin"
	desc = "A vox raider in a pressure suit. This one is wielding an old laser gun and is equipped with an array of knives for throwing."
	icon_state = "voxraider_assassin"

	melee_damage_lower = 15
	melee_damage_upper = 25 // He's got a knoif

	attacktext = "stabs"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG // Will smash through obstacles and force open doors to track down targets

	corpse = /obj/effect/landmark/corpse/vox/spaceraider_assassin

	items_to_drop = list(/obj/item/weapon/gun/energy/laser/retro, /obj/item/weapon/kitchen/utensil/knife/tactical)

	speak = list("My knives are thirsty.","Too long since seen blood.","I take only the strong ones as slaves.")
	speak_chance = 1

	projectiletype = /obj/item/projectile/beam/retro
	projectilesound = 'sound/weapons/Laser.ogg'
	retreat_distance = 2
	minimum_distance = 2
	ranged = 1

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/assassin/Aggro()
	..()
	say(pick("Challenge, khm?","We fight, then.","You will die quickly."), all_languages[LANGUAGE_VOX])

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/assassin/Shoot(var/atom/target, var/atom/start, var/mob/user)
	if(prob(10))
		visible_message("<span class = 'warning'>\The [src] hurls a knife towards \the [target]!</span>")
		var/atom/movable/knife_to_throw = new /obj/item/weapon/kitchen/utensil/knife/tactical(get_turf(src))
		knife_to_throw.throw_at(target,10,10) // In practice the damage done per throw at these values is about ~20 brute
	else
		..()

///////////////////////////////////////////////////////////////////BREACHER RAIDER///////////
//A bit slower, but a bit tankier. Has a shotgun to greatly discourage CQC

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/breacher
	name = "Vox Breacher"
	desc = "A vox raider in a pressure suit. This one seems to be more heavily armored, and is equipped with a shotgun."
	icon_state = "voxraider_breacher"

	health = 180
	maxHealth = 180

	move_to_delay = 3 // Sacrifices speed for more health/armor

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG // Breach and clear

	corpse = /obj/effect/landmark/corpse/vox/spaceraider

	items_to_drop = list(/obj/item/weapon/gun/projectile/shotgun/pump/combat)

	speak = list("Greys and humans are so squishy, keheh.","So much loot. I can retire soon.","Need to clean gun again.")
	speak_chance = 1

	projectiletype = /obj/item/projectile/bullet/buckshot
	projectilesound = 'sound/weapons/shotgun.ogg'
	retreat_distance = 3
	minimum_distance = 3
	ranged = 1

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/breacher/Aggro()
	..()
	say(pick("Some rats going to die... here I come!","We see how brave you are after some buckshot.","Attack! Kill them!"), all_languages[LANGUAGE_VOX])

///////////////////////////////////////////////////////////////////DEADEYE RAIDER///////////
//Aptly named. One shot is enough to send any spessman running home to medbay, or worse

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/deadeye
	name = "Vox Deadeye"
	desc = "A vox raider in a pressure suit. This one is hefting a large mosin rifle, and you're in their sights..."
	icon_state = "voxraider_deadeye"
	vision_range = 10
	aggro_vision_range = 10
	idle_vision_range = 10 // He's got good eyes

	environment_smash_flags = OPEN_DOOR_STRONG // This flag allows him to shoot through glass airlocks and open doors

	corpse = /obj/effect/landmark/corpse/vox/spaceraider_deadeye

	items_to_drop = list(/obj/item/weapon/gun/projectile/mosin)

	speak = list("Right between eyes...","Kill from far, then plunder the shiny things.","A good hunt for the Shoal.")
	speak_chance = 1

	ranged = 1
	projectiletype = /obj/item/projectile/bullet/a762x55
	projectilesound = 'sound/weapons/mosin.ogg'
	retreat_distance = 7
	minimum_distance = 7

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/deadeye/Aggro()
	..()
	say(pick("Run, run, run! Keheh.","You will look good as wall trophy.","Hold still just a moment, yes?."), all_languages[LANGUAGE_VOX])

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/deadeye/Shoot()
	if(prob(5))
		visible_message("<span class = 'warning'>\The [src] pauses abruptly to clear a jam!</span>") // This is a good opportunity to blast him with impunity
		playsound(src, 'sound/weapons/mosinreload.ogg', 100, 1)
		new /obj/item/ammo_casing/a762x55(src.loc)
		ranged_cooldown = 4
	else
		ranged_cooldown = 2
		..()

///////////////////////////////////////////////////////////////////RAID LEADER///////////
//He's the boss, boss chikun. Should be a fairly tough fight

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/leader
	name = "Vox Raid Leader"
	desc = "A vox raider in an armored blood-red hardsuit. He is heavily armed, wielding a compact shotgun and a high-frequency machete."
	icon_state = "voxraider_leader"
	health = 300
	maxHealth = 300

	vision_range = 10
	aggro_vision_range = 10
	idle_vision_range = 10 // He's the boss, nothing gets past him

	melee_damage_lower = 40 // That machete is no joke
	melee_damage_upper = 60

	attacktext = "cleaves"
	attack_sound = 'sound/weapons/machete_hit01.ogg'

	status_flags = UNPACIFIABLE // Too angry to be pacified. Also meant to be a "boss" mob, so that would be a bit silly
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG // He can smash stuff open and force open airlocks to attack his target

	var/berserk = 0
	var/last_bigheal = 0
	var/const/bigheal_cooldown = 45 SECONDS // Can heal himself when his health gets very low, but has to wait before doing it again

	corpse = /obj/effect/landmark/corpse/vox/spaceraider_leader

	items_to_drop = list(/obj/item/weapon/gun/projectile/shotgun/pump/combat/shorty, /obj/item/weapon/melee/energy/hfmachete)

	speak = list("When the reinforcements get here...","Kraaaah, this take too much time!","Stupid fleshies.","Of ten, take four for slaves, kill five, and leave one to tell tale.")
	speak_chance = 5

	ranged = 1
	projectiletype = /obj/item/projectile/bullet/buckshot
	projectilesound = 'sound/weapons/shotgun.ogg'
	retreat_distance = 3
	minimum_distance = 3

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/leader/Aggro()
	..()
	say(pick("I will drink from your skull!","Kraaah, die die die!","You brave, I take you as crop growing slave.","I am strong, you are weak!"), all_languages[LANGUAGE_VOX])

/mob/living/simple_animal/hostile/humanoid/vox/spaceraider/leader/Life()
	..()
	if(health <= (maxHealth/2) && berserk == 0) // Will go berserk if he loses half his health
		visible_message("<span class='warning'>[src] lowers his shotgun and charges with his machete raised!</span>")
		berserk = 1
		move_to_delay = 1.8 // Chaaaaaaaaaaarge
		ranged = 0
		retreat_distance = 1
		minimum_distance = 1

	if(health > (maxHealth/2) && berserk == 1) // Will calm down again if he heals himself above half health
		visible_message("<span class='warning'>[src] lowers his machete to a defensive position and raises his shotgun!</span>")
		berserk = 0
		move_to_delay = 2 // Back to normal speed
		ranged = 1
		retreat_distance = 4
		minimum_distance = 4

	if((last_bigheal + bigheal_cooldown < world.time) && health < 75) // After he heals he has to wait quite a while before doing it again. Don't give him time to do it again
		health+=150
		visible_message("<span class='warning'>[src] draws a giant syringe and injects himself with the contents. He shrieks, but his wounds rapidly begin to heal!</span>")
		playsound(src, 'sound/misc/shriek1.ogg', 50, 1)
		new /obj/item/weapon/reagent_containers/syringe/giant(src.loc)
		last_bigheal = world.time

/////////VOX SHARPSHOOTERS
//Armed with crossbows

/mob/living/simple_animal/hostile/humanoid/vox/crossbow
	name = "vox sharpshooter"
	desc = "A raider with ranged combat training and a crossbow."
	icon_state = "sharpshooter"

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5

	ranged_cooldown_cap = 9

	corpse = /obj/effect/landmark/corpse/vox/crossbow
	items_to_drop = list(/obj/item/weapon/crossbow, /obj/item/weapon/arrow/quill, /obj/item/weapon/arrow/quill, /obj/item/weapon/arrow/quill)

/mob/living/simple_animal/hostile/humanoid/vox/crossbow/Shoot(var/target, var/start, var/user, var/bullet = 0)
	if(target == start)
		return
	if(!istype(target, /turf))
		return

	var/obj/item/weapon/arrow/A = new /obj/item/weapon/arrow/quill(get_turf(src))

	A.throw_at(target,10,25)

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
