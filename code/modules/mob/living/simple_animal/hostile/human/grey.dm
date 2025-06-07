///////////////////////////////////////////////////////////////////FERAL GREY///////////
//Previously found in Blacksite Prism
/mob/living/simple_animal/hostile/humanoid/grey
	name = "Grey"
	desc = "A thin alien humanoid. This one seems to be feral."
	see_in_dark = 5 // ayy darkvision

	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "grey"
	icon_living = "grey"

	var/waterproof = 0
	acidimmune = 1

	attacktext = "bites" // so uncivilized
	attack_sound = 'sound/weapons/bite.ogg'

	corpse = /obj/effect/landmark/corpse/grey

/mob/living/simple_animal/hostile/humanoid/grey/reagent_act(id, method, volume) // Grey hostile mobs have immunity to acids but take damage from water if not wearing protective gear, much like the player species
	if(isDead())
		return

	.=..()

	switch(id)
		if(WATER)
			if(!waterproof)
				visible_message("<span class='danger'>[src] writhes in agony as the water washes over them!</span>")
				adjustBruteLoss(volume * 1)

/mob/living/simple_animal/hostile/humanoid/grey/New() // grayy mobs can speak quack! thanks kurfurst!
	..()
	languages += all_languages[LANGUAGE_GREY]

//////////////////////////////
// GREY PRISONERS
//////////////////////////////
//Found in Blacksite Prism
/mob/living/simple_animal/hostile/humanoid/grey/prisoner // Boring default prisoner, for inheritance
	name = "Grey Prisoner"
	desc = "A thin alien humanoid. This is wearing a prisoner's uniform and seems to be hostile."

	icon_state = "grey_testsubject"
	icon_living = "grey_testsubject"

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART
	stat_attack = UNCONSCIOUS // No mercy in the big house

	melee_damage_lower = 4
	melee_damage_upper = 6 // Very weak melee attacks

	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'

	speak = list("I don't remember who I am... why? I must be someone.","Praise the... praise the... what? What was so important?","I don't remember how I arrived here, just red suits and pain. So much pain...","I will escape. I will.","So thirsty. There must be a drop of acid somewhere.","I cannot feel other minds anymore. I am alone.")
	speak_chance = 1

	corpse = /obj/effect/landmark/corpse/grey/prisoner
	faction = "prisoner" // We're all brothers and sisters in binds now

/mob/living/simple_animal/hostile/humanoid/grey/prisoner/Aggro()
	..()
	say(pick("No, no more experiments!","I'll eviscerate you!","Greeeeeeeeeee!","You won't take me again!","Ngaaaaah! Die!"), all_languages[LANGUAGE_GREY])

///////////////////////////////////////////////////////////////////Melee Prisoner///////////
//Prisoner with a makeshift spear. Can occasionally do a piercing attack that bypasses armor damage resistance
/mob/living/simple_animal/hostile/humanoid/grey/prisoner/melee
	desc = "A thin alien humanoid. This one is armed with a makeshift spear and seems to be hostile."

	icon_state = "grey_testsubject_melee"
	icon_living = "grey_testsubject_melee"

	melee_damage_lower = 14
	melee_damage_upper = 18 // Speermin

	attacktext = "jabs"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	items_to_drop = list(/obj/item/weapon/spear)

	retreat_distance = 2 // Will attempt to kite/avoid incoming melee attacks
	minimum_distance = 1

	var/pierceattack_chance = 10

/mob/living/simple_animal/hostile/humanoid/grey/prisoner/melee/AttackingTarget()
	if(prob(pierceattack_chance)) // Attack that does the mob's max damage and ignores damage resistance
		var/mob/living/carbon/human/H = target
		if(ishuman(H))
			visible_message("<b><span class='warning'>[src] gores [H] with a carefully aimed spear thrust!</span>")
			playsound(src, 'sound/weapons/bladeslice.ogg', 50, 1)
			var/datum/organ/external/chest/C = H.get_organ(LIMB_CHEST)
			if(C)
				C.take_damage(18) // If human, damage targets the chest
		else
			visible_message("<b><span class='warning'>[src] gores [H] with a carefully aimed spear thrust!</span>")
			playsound(src, 'sound/weapons/bladeslice.ogg', 50, 1)
			H.adjustBruteLoss(18) // Otherwise just adjust bruteloss on the mob
	else // A regular spear stabbin'
		..()

///////////////////////////////////////////////////////////////////Ranged Prisoner///////////
//Prisoner with a makeshift laser musket. Decent ranged damage, but has to crank between shots
/mob/living/simple_animal/hostile/humanoid/grey/prisoner/ranged
	desc = "A thin alien humanoid. This one is armed with a makeshift laser musket and seems to be hostile."

	icon_state = "grey_testsubject_musket"
	icon_living = "grey_testsubject_musket"

	items_to_drop = list(/obj/item/weapon/gun/energy/lasmusket)

	projectiletype = /obj/item/projectile/beam/lightlaser
	projectilesound = 'sound/weapons/Laser.ogg'
	retreat_distance = 4
	minimum_distance = 4
	ranged = 1

	var/last_musketshot = 0
	var/const/musketshot_cooldown = 6 SECONDS // Gotta crank it after firing!

/mob/living/simple_animal/hostile/humanoid/grey/prisoner/ranged/Shoot() // This doesn't work as well as I'd hoped. Ideally it would only go on cooldown after they fire at a target, but what can you do. It works well enough, I suppose
	if(last_musketshot + musketshot_cooldown > world.time)
		visible_message("<b><span class='warning'>[src] cranks their laser musket!</span>")
		playsound(src, 'sound/items/crank.ogg', 50, 1)
	else
		last_musketshot = world.time
		..()

//////////////////////////////
// GREY EXPLORERS
//////////////////////////////
/mob/living/simple_animal/hostile/humanoid/grey/explorer
	name = "Grey Explorer"
	desc = "A thin alien humanoid. This is wearing a mothership explorer uniform and seems to be hostile."

	icon_state = "greyexplorer"
	icon_living = "greyexplorer"

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART // Lesson learned, don't leave just an OPEN_DOOR_STRONG flag on a ranged mob. It doesn't work!
	stat_attack = UNCONSCIOUS // Grey hostile humanoids are too smart to think that someone is dead just because they fell over

	melee_damage_lower = 5
	melee_damage_upper = 8 // Their arms may be noodly and weak, but getting kicked by a steel toed boot hurts!

	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'

	faction = "mothership"

	corpse = /obj/effect/landmark/corpse/grey/explorer

/mob/living/simple_animal/hostile/humanoid/grey/explorer/GetAccess()
	return list(access_mothership_general, access_mothership_military)

///////////////////////////////////////////////////////////////////SPACEWORTHY EXPLORERS///////////
/mob/living/simple_animal/hostile/humanoid/grey/explorer/space
	name = "Grey Explorer"
	desc = "A thin alien humanoid in a space suit. This one seems to be hostile."

	icon_state = "greyexplorer_space"
	icon_living = "greyexplorer_space"

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 1000 // Spess protection stats

	corpse = /obj/effect/landmark/corpse/grey/explorer_space

	waterproof = 1

/mob/living/simple_animal/hostile/humanoid/grey/explorer/space/Process_Spacemove(var/check_drift = 0) // They can follow enemies into space, and won't just drift off
	return 1

///////////////////////////////////////////////////////////////////SPACE EXPLORER TECHNICIAN///////////

/mob/living/simple_animal/hostile/humanoid/grey/explorer/space/toolbox
	name = "Explorer Technician"
	desc = "A thin alien humanoid in a space suit. This one is wielding a toolbox."

	icon_state = "greyexplorer_space_toolbox"
	icon_living = "greyexplorer_space_toolbox"
	melee_damage_lower = 12
	melee_damage_upper = 15

	attacktext = "batters"
	attack_sound = 'sound/weapons/toolbox.ogg'

	items_to_drop = list(/obj/item/weapon/storage/toolbox/mechanical)

	speak = list("Speak softly, and carry a robust toolbox.","Where did I put that soldering iron?","Mothership guide us...")
	speak_chance = 1

	waterproof = 1

/mob/living/simple_animal/hostile/humanoid/grey/explorer/space/toolbox/Aggro()
	..()
	say(pick("I won't allow you to damage mothership equipment!","Time to apply percussive maintenance!"), all_languages[LANGUAGE_GREY])

///////////////////////////////////////////////////////////////////SPACE EXPLORER SURGEON///////////

/mob/living/simple_animal/hostile/humanoid/grey/explorer/space/scalpel
	name = "Explorer Surgeon"
	desc = "A thin alien humanoid in a space suit. This one is carrying a scalpel."

	icon_state = "greyexplorer_space_scalpel"
	icon_living = "greyexplorer_space_scalpel"
	melee_damage_lower = 15
	melee_damage_upper = 18

	attacktext = "slices"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	waterproof = 1

	items_to_drop = list(/obj/item/tool/scalpel)

	speak = list("I need a new specimen to dissect.","A dissection is all I need... just one more dissection.","Praise the mothership.")
	speak_chance = 1

/mob/living/simple_animal/hostile/humanoid/grey/explorer/space/scalpel/Aggro()
	..()
	say(pick("I need your organs for testing!","You'll make a fine specimen for an operation!"), all_languages[LANGUAGE_GREY])

///////////////////////////////////////////////////////////////////SPACE EXPLORER GUARD///////////

/mob/living/simple_animal/hostile/humanoid/grey/explorer/space/ranged
	name = "Explorer Guard"
	desc = "A thin alien humanoid in a space suit. This one is armed with a disintegrator."

	icon_state = "greyexplorer_space_laser"
	icon_living = "greyexplorer_space_laser"

	items_to_drop = list(/obj/item/weapon/gun/energy/smalldisintegrator)

	speak = list("Set disintegrators to scorch, medium well.","Praise the mothership, and all hail the Chairman.","Disintegrate all unidentified targets.")
	speak_chance = 1

	waterproof = 1

	projectiletype = /obj/item/projectile/beam/scorchray
	projectilesound = 'sound/weapons/ray1.ogg'
	retreat_distance = 4
	minimum_distance = 4
	ranged = 1

/mob/living/simple_animal/hostile/humanoid/grey/explorer/space/ranged/Aggro()
	..()
	say(pick("Intruder!","You will be disintegrated!"), all_languages[LANGUAGE_GREY])

//////////////////////////////
// GREY SOLDIERS
//////////////////////////////
//Default unarmed simplemob, here for the sake of inheritance
/mob/living/simple_animal/hostile/humanoid/grey/soldier
	name = "Grey Soldier"
	desc = "A thin alien humanoid. This one is armored and seems to be hostile."

	icon_state = "greysoldier_base"
	icon_living = "greysoldier_base"

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART // Lesson learned, don't leave just an OPEN_DOOR_STRONG flag on a ranged mob. It doesn't work!
	stat_attack = UNCONSCIOUS // Grey hostile humanoids are too smart to think that someone is dead just because they fell over

	health = 125
	maxHealth = 125 // A bit tankier due to wearing armor
	melee_damage_lower = 6
	melee_damage_upper = 10 // Their arms may be noodly and weak, but getting kicked by a steel toed boot hurts!

	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'

	faction = "mothership"

	corpse = /obj/effect/landmark/corpse/grey/soldier_sentry

/mob/living/simple_animal/hostile/humanoid/grey/soldier/GetAccess()
	return list(access_mothership_general, access_mothership_military)

///////////////////////////////////////////////////////////////////GREY GUARD///////////
//Baseline soldier. Has an additional 25 HP and a disintegrator ranged weapon. They can also change firing modes in combat!
/mob/living/simple_animal/hostile/humanoid/grey/soldier/sentry
	name = "MDF Sentry"
	desc = "A thin alien humanoid. This one is armored and armed with a disintegrator."

	icon_state = "greysentry"
	icon_living = "greysentry"

	items_to_drop = list(/obj/item/weapon/gun/energy/smalldisintegrator)

	speak = list("The MDF is prepared for anything.","Five of theirs shall be disintegrated for every one of ours.","I need to refill my canteen...")
	speak_chance = 1

	var/microwave = 0

	retreat_distance = 4
	minimum_distance = 4
	ranged = 1

/mob/living/simple_animal/hostile/humanoid/grey/soldier/sentry/Life()
	..()
	if(microwave == 0)
		projectiletype = /obj/item/projectile/beam/scorchray
		projectilesound = 'sound/weapons/ray1.ogg'
		icon_state = "greysentry"
		icon_living = "greysentry"
	if(microwave == 1)
		projectiletype = /obj/item/projectile/energy/microwaveray
		projectilesound = 'sound/weapons/ray2.ogg'
		icon_state = "greysentry1"
		icon_living = "greysentry1"

/mob/living/simple_animal/hostile/humanoid/grey/soldier/sentry/Shoot()
	if(prob(5)) //Handles switching firing modes in combat
		if(microwave == 0)
			visible_message("<span class='warning'>[src] switches their disintegrator to microwave mode!</span>")
			microwave = 1
		else
			visible_message("<span class='warning'>[src] switches their disintegrator to scorch mode!</span>")
			microwave = 0
	else // Otherwise fire the projectile for whatever mode is active
		..()

/mob/living/simple_animal/hostile/humanoid/grey/soldier/sentry/Aggro()
	..()
	say(pick("Hostile!","Engage, exterminate.","Report, target marked for disintegration.","The probability of defeat is a statistically insignificant outlier.","For the mothership!"), all_languages[LANGUAGE_GREY])

///////////////////////////////////////////////////////////////////GREY SOLDIER///////////
//Slightly more dangerous soldier. No additional HP, but equipped with a heavy disintegrator. They can also change firing modes in combat!
/mob/living/simple_animal/hostile/humanoid/grey/soldier/regular
	name = "MDF Regular"
	desc = "A thin alien humanoid. This one is armored and armed with a heavy disintegrator."

	icon_state = "greysoldier"
	icon_living = "greysoldier"

	corpse = /obj/effect/landmark/corpse/grey/soldier_regular

	items_to_drop = list(/obj/item/weapon/gun/energy/heavydisintegrator)

	speak = list("The MDF is prepared for anything.","Five of theirs shall be disintegrated for every one of ours.","I need to refill my canteen...")
	speak_chance = 1

	var/scramble = 0

	retreat_distance = 5
	minimum_distance = 5
	ranged = 1

/mob/living/simple_animal/hostile/humanoid/grey/soldier/regular/Life()
	..()
	if(scramble == 0)
		projectiletype = /obj/item/projectile/beam/immolationray
		projectilesound = 'sound/weapons/ray1.ogg'
		icon_state = "greysoldier"
		icon_living = "greysoldier"
	if(scramble == 1)
		projectiletype = /obj/item/projectile/energy/scramblerray
		projectilesound = 'sound/weapons/ray2.ogg'
		icon_state = "greysoldier1"
		icon_living = "greysoldier1"

/mob/living/simple_animal/hostile/humanoid/grey/soldier/regular/Shoot()
	if(prob(5)) //Handles switching firing modes in combat
		if(scramble == 0)
			visible_message("<span class='warning'>[src] switches their heavy disintegrator to scramble mode!</span>")
			scramble = 1
		else
			visible_message("<span class='warning'>[src] switches their heavy disintegrator to immolate mode!</span>")
			scramble = 0
	else // Otherwise fire the projectile for whatever mode is active
		..()

/mob/living/simple_animal/hostile/humanoid/grey/soldier/regular/Aggro()
	..()
	say(pick("Hostile!","Engage, exterminate.","Report, target marked for disintegration.","The probability of defeat is a statistically insignificant outlier.","For the mothership!"), all_languages[LANGUAGE_GREY])

///////////////////////////////////////////////////////////////////GREY PACIFIER///////////
//Ayy riot soldier. Don't let him get close, his stun probe isn't just for show
/mob/living/simple_animal/hostile/humanoid/grey/soldier/pacifier
	name = "MDF Pacifier"
	desc = "A thin alien humanoid. This one is armored and equipped with an alien stun baton."

	icon_state = "greypacifier"
	icon_living = "greypacifier"

	maxHealth = 135 // Slightly more health than a standard soldier
	health = 135
	melee_damage_lower = 10
	melee_damage_upper = 20 // Decent melee damage, but the stun is the real danger
	move_to_delay = 1.8 // This is what he trained for! To fill the unforgiving minute with sixty seconds of distance sprinting

	items_to_drop = list(/obj/item/weapon/melee/stunprobe)

	attacktext = "beats"
	attack_sound = 'sound/weapons/genhit1.ogg'

	corpse = /obj/effect/landmark/corpse/grey/soldier_pacifier

	speak = list("Pacification unit reporting.","Stun probe ready.","Fortune favors the bold.","Praise the mothership.","I am ready for anything.")
	speak_chance = 1

	var/last_shockattack = 0
	var/const/shockattack_cooldown = 20 SECONDS // Some cooldown variables to remove the chance of getting stunlocked by a single one of these guys

/mob/living/simple_animal/hostile/humanoid/grey/soldier/pacifier/proc/shockAttack(mob/living/carbon/human/target) // It's not a great idea to fight these guys in CQC if you don't have some kind of stun resistance
	var/damage = rand(5, 10)
	target.electrocute_act(damage, src, incapacitation_duration = 6 SECONDS, def_zone = LIMB_CHEST) // 6 seconds is pretty rough, twice as long as a carp stun
	if(iscarbon(target))
		var/mob/living/L = target
		L.apply_effect(6, STUTTER)
	return

/mob/living/simple_animal/hostile/humanoid/grey/soldier/pacifier/AttackingTarget() // Won't keep stunning a downed player, so they should have a chance to run when they get up
	var/mob/living/carbon/human/H = target
	if((last_shockattack + shockattack_cooldown < world.time) && !H.lying && ishuman(H))
		shockAttack(H)
		H.visible_message("<span class='danger'>[src] shocks [H] with their stun probe!</span>")
		playsound(src, 'sound/weapons/electriczap.ogg', 50, 1)
		last_shockattack = world.time
	else
		..()

/mob/living/simple_animal/hostile/humanoid/grey/soldier/pacifier/Aggro()
	..()
	say(pick("Enemy of the mothership!","Pacifying target!","Engaging!","Attack!"), all_languages[LANGUAGE_GREY])

///////////////////////////////////////////////////////////////////GDR EXPLORER///////////
//Explorer subtype of the pacifier. Identical in behavior, health, and damage
/mob/living/simple_animal/hostile/humanoid/grey/soldier/pacifier/explorer
	name = "Explorer Guard"
	desc = "A thin alien humanoid. This one is armored and equipped with an alien stun baton."

	icon_state = "greyexplorer_melee"
	icon_living = "greyexplorer_melee"

	corpse = /obj/effect/landmark/corpse/grey/explorer_melee

///////////////////////////////////////////////////////////////////GREY GRENADIER///////////
//Soldier that can launch grenades, very dangerous. Slightly better vision than the average soldier
/mob/living/simple_animal/hostile/humanoid/grey/soldier/grenadier
	name = "MDF Grenadier"
	desc = "A thin alien humanoid. This one is armed with a grenade launcher and several strange-looking grenades."

	icon_state = "greygrenadier"
	icon_living = "greygrenadier"

	corpse = /obj/effect/landmark/corpse/grey/soldier_grenadier

	items_to_drop = list(/obj/item/weapon/gun/grenadelauncher, /obj/item/weapon/grenade/chem_grenade/mothershipacid, /obj/item/weapon/grenade/spawnergrenade/mothershipdrone)

	speak = list("Grenade belt loaded, standing by.","A few grenades never fail to soften the enemy up.","When are we due for rotation?")
	speak_chance = 1

	vision_range = 10
	aggro_vision_range = 10
	idle_vision_range = 10 // Keeping an eye open for a target to launch a grenade towards at all times

	ranged = 1
	retreat_distance = 6
	minimum_distance = 6
	ranged_cooldown_cap = 8 // Launching grenades is pretty powerful, gotta give it a cooldown

	var/reloading = 0 // Grenadier will move further away or closer depending on if cooling down from a grenade launch, or ready to fire
	var/loaded = 1

/mob/living/simple_animal/hostile/humanoid/grey/soldier/grenadier/Life()
	..()
	if(reloading == 1) // We're cooling down or "reloading" after the last shot. Run farther away!
		retreat_distance = 9
		minimum_distance = 9
		spawn(8 SECONDS)
			loaded = 1
			reloading = 0
	if(loaded == 1) // Locked and loaded. Back into the fray!
		retreat_distance = 6
		minimum_distance = 6

/mob/living/simple_animal/hostile/humanoid/grey/soldier/grenadier/Shoot(var/atom/target, var/atom/start, var/mob/user)
	switch(rand(1,2))
		if(1)
			visible_message("<span class = 'warning'>\The [src] launches a grenade towards \the [target]!</span>")
			say("[pick("A gift from the mothership.", "Ordinance away!", "Let's see how you like this.")]")
			playsound(src, 'sound/weapons/grenadelauncher.ogg', 50, 1)
			var/atom/movable/grenade_to_throw = new /obj/item/weapon/grenade/spawnergrenade/mothershipdrone(get_turf(src))
			var/obj/item/weapon/grenade/F = grenade_to_throw
			grenade_to_throw.throw_at(target,10,2)
			F.activate()
			ranged_cooldown = 8
			loaded = 0
			reloading = 1
		if(2)
			visible_message("<span class = 'warning'>\The [src] launches a grenade towards \the [target]!</span>")
			say("[pick("A gift from the mothership.", "Ordinance away!", "Let's see how you like this.")]")
			playsound(src, 'sound/weapons/grenadelauncher.ogg', 50, 1)
			var/atom/movable/grenade_to_throw = new /obj/item/weapon/grenade/chem_grenade/mothershipacid(get_turf(src))
			var/obj/item/weapon/grenade/F = grenade_to_throw
			grenade_to_throw.throw_at(target,10,2)
			F.activate()
			ranged_cooldown = 8
			loaded = 0
			reloading = 1

/mob/living/simple_animal/hostile/humanoid/grey/soldier/grenadier/Aggro()
	..()
	say(pick("Hostile target!","Prepping grenade.","Open fire!","For the mothership!"), all_languages[LANGUAGE_GREY])

///////////////////////////////////////////////////////////////////GREY HEAVY SOLDIER///////////
//A much tankier but slower grey soldier. Has a small chance to throw a grenade, and when health gets low will deploy an energy shield to protect himself
/mob/living/simple_animal/hostile/humanoid/grey/soldier/heavy
	name = "MDF Heavy"
	desc = "A thin alien humanoid. This one is heavily armored from head to toe and armed with a heavy disintegrator."

	icon_state = "greyheavy"
	icon_living = "greyheavy"

	maxHealth = 200 // Pretty hefty amount of hp
	health = 200

	melee_damage_type = BURN
	melee_damage_lower = 50 // The nastiest "melee" damage of all the grey enemies. Give him his space
	melee_damage_upper = 50

	attacktext = "fires point-blank at"
	attack_sound = 'sound/weapons/ray1.ogg'

	move_to_delay = 3 // Being densely armored means slow going

	corpse = /obj/effect/landmark/corpse/grey/soldier_heavy

	items_to_drop = list(/obj/item/weapon/gun/energy/heavydisintegrator, /obj/item/weapon/shield/energy/red)

	speak = list("The MDF is prepared for anything.","Praise the mothership, and all hail the Chairman.","Our enemies stand no chance against us.","Shoulder to shoulder, back to back.")
	speak_chance = 1

	waterproof = 1
	var/shield_up = 0

	projectiletype = /obj/item/projectile/beam/immolationray
	projectilesound = 'sound/weapons/ray1.ogg'
	retreat_distance = 3
	minimum_distance = 3
	ranged = 1

/mob/living/simple_animal/hostile/humanoid/grey/soldier/heavy/Shoot(var/atom/target, var/atom/start, var/mob/user)
	if(shield_up == 0 && prob(5)) // If the shield isn't up, maybe we throw a grenade
		visible_message("<span class = 'warning'>\The [src] primes a grenade and hurls it towards \the [target]!</span>")
		say("[pick("A gift from the mothership.", "Ordinance away!", "Let's see how you like this.")]")
		var/atom/movable/grenade_to_throw = new /obj/item/weapon/grenade/chem_grenade/mothershipacid(get_turf(src))
		var/obj/item/weapon/grenade/F = grenade_to_throw
		grenade_to_throw.throw_at(target,10,2)
		F.activate()
	else // Otherwise just fire a projectile normally
		..()

/mob/living/simple_animal/hostile/humanoid/grey/soldier/heavy/Life()
	..()
	if(health <= 150 && shield_up == 0) // Health is getting low, turn on shield and go into "defense" mode
		shield_up = 1
		icon_state = "greyheavy1"
		icon_living = "greyheavy1"
		playsound(src, 'sound/weapons/saberon.ogg', 50, 1)
		visible_message("<span class = 'warning'>\The [src] activates an energy shield!</span>")
		say("[pick("Taking heavy fire, deploying shield.", "Shield up.", "I need covering fire!")]")
	if(health > 150 && shield_up == 1) // Health has somehow been restored. Shield off and back to "offense" mode
		shield_up = 0
		icon_state = "greyheavy"
		icon_living = "greyheavy"
		playsound(src, 'sound/weapons/saberoff.ogg', 50, 1)
		visible_message("<span class = 'warning'>\The [src] deactives their energy shield.</span>")

/mob/living/simple_animal/hostile/humanoid/grey/soldier/heavy/attackby(var/obj/item/O as obj, var/mob/user as mob) // Has a chance to block melee attacks while shield is up
	if(shield_up == 1)
		user.delayNextAttack(8)
		if(O.force)
			if(prob(65))
				var/damage = O.force
				if (O.damtype == HALLOSS)
					damage = 0
				health -= damage
				visible_message("<span class='danger'>[src] has been attacked with [O] by [user]. </span>")
			else
				visible_message("<span class='danger'>[src] blocks [O] with their shield! </span>")
		else
			to_chat(usr, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
			visible_message("<span class='warning'>[user] gently taps [src] with [O]. </span>")
	else
		..()

/mob/living/simple_animal/hostile/humanoid/grey/soldier/heavy/bullet_act(var/obj/item/projectile/Proj) // Has a chance to block projectiles while shield is up
	if(shield_up == 1)
		if(!Proj)
			return PROJECTILE_COLLISION_DEFAULT
		if(prob(50))
			src.health -= Proj.damage
		else
			visible_message("<span class='danger'>[src] blocks [Proj] with their shield!</span>")
		return PROJECTILE_COLLISION_DEFAULT
	else
		..()
	return PROJECTILE_COLLISION_DEFAULT

/mob/living/simple_animal/hostile/humanoid/grey/soldier/heavy/Aggro()
	..()
	say(pick("For the Administration!","Report, target marked for disintegration.","Sterilizing target.","For the mothership!","You cannot stand against us."), all_languages[LANGUAGE_GREY])

///////////////////////////////////////////////////////////////////GREY TROOPER BASE///////////
//Baseline unarmed spaceworthy ayy soldier, here for the sake of inheritance. Has a slightly larger vision range than the average soldier
/mob/living/simple_animal/hostile/humanoid/grey/soldier/space
	name = "MDF Trooper"
	desc = "A thin alien humanoid. This one is wearing an armored rigsuit and seems to be hostile."

	icon_state = "greytrooper"
	icon_living = "greytrooper"

	vision_range = 10
	aggro_vision_range = 10
	idle_vision_range = 10

	maxHealth = 140 // More hp than a standard soldier, less than the heavy soldier
	health = 140

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 1000 // Spess protection stats

	corpse = /obj/effect/landmark/corpse/grey/soldier_space

/mob/living/simple_animal/hostile/humanoid/grey/soldier/space/Process_Spacemove(var/check_drift = 0) // They can follow enemies into space, and won't just drift off
	return 1

///////////////////////////////////////////////////////////////////GREY MELEE TROOPER///////////
//Spaceworthy ayy soldier with a baton. Quite mobile for an enemy in a hardsuit and has slightly less cooldown on the baton stun than a regular pacifier
/mob/living/simple_animal/hostile/humanoid/grey/soldier/space/melee
	name = "MDF Trooper"
	desc = "A thin alien humanoid. This one is wearing an armored rigsuit and armed with an alien stun baton."

	icon_state = "greytrooper_melee"
	icon_living = "greytrooper_melee"

	maxHealth = 150 // Slightly more health than a standard trooper
	health = 150
	melee_damage_lower = 10
	melee_damage_upper = 20 // Decent melee damage, but the stun is the real danger
	move_to_delay = 1.8 // This is what he trained for! To fill the unforgiving minute with sixty seconds of distance sprinting

	items_to_drop = list(/obj/item/weapon/melee/stunprobe)

	attacktext = "beats"
	attack_sound = 'sound/weapons/genhit1.ogg'

	speak = list("Sweeping sector, be prepared for EVA.","Praise the mothership, and all hail the Chairman.","Air supply capacity check is green.","Terminate all unauthorized personnel and unidentified xenofauna.","Stun probe charged and ready.")
	speak_chance = 1

	var/last_shockattack = 0
	var/const/shockattack_cooldown = 15 SECONDS // Some cooldown variables to remove the chance of getting stunlocked by a single one of these guys

/mob/living/simple_animal/hostile/humanoid/grey/soldier/space/melee/proc/shockAttack(mob/living/carbon/human/target) // It's not a great idea to fight these guys in CQC if you don't have some kind of stun resistance
	var/damage = rand(5, 10)
	target.electrocute_act(damage, src, incapacitation_duration = 6 SECONDS, def_zone = LIMB_CHEST) // 6 seconds is pretty rough, twice as long as a carp stun
	if(iscarbon(target))
		var/mob/living/L = target
		L.apply_effect(6, STUTTER)
	return

/mob/living/simple_animal/hostile/humanoid/grey/soldier/space/melee/AttackingTarget() // Won't keep stunning a downed player, so they should have a chance to run when they get up
	var/mob/living/carbon/human/H = target
	if((last_shockattack + shockattack_cooldown < world.time) && !H.lying && ishuman(H))
		shockAttack(H)
		H.visible_message("<span class='danger'>[src] shocks [H] with their stun probe!</span>")
		playsound(src, 'sound/weapons/electriczap.ogg', 50, 1)
		last_shockattack = world.time
	else
		..()

/mob/living/simple_animal/hostile/humanoid/grey/soldier/space/melee/Aggro()
	..()
	say(pick("Hostile sighted, my sector.","Report, target marked for pacification.","Pacifying target.","For the mothership!","Target acquired. Pacify with extreme prejudice."), all_languages[LANGUAGE_GREY])

///////////////////////////////////////////////////////////////////GREY RANGED TROOPER///////////
//Less tanky than the heavy soldier, but spaceworthy. A little more clever than a regular soldier with its tactics, will back off and shoot from further away if his health gets low. Can also throw drone grenades
/mob/living/simple_animal/hostile/humanoid/grey/soldier/space/ranged
	name = "MDF Trooper"
	desc = "A thin alien humanoid. This one is wearing an armored rigsuit and armed with a heavy disintegrator."

	icon_state = "greytrooper_laser"
	icon_living = "greytrooper_laser"

	var/defensive_stance = 0

	items_to_drop = list(/obj/item/weapon/gun/energy/heavydisintegrator)

	speak = list("Sweeping sector, prepared for EVA maneuvers.","Praise the mothership, and all hail the Chairman.","Air supply capacity check is green.","Terminate all unauthorized personnel and unidentified xenofauna.")
	speak_chance = 1

	projectiletype = /obj/item/projectile/beam/immolationray
	projectilesound = 'sound/weapons/ray1.ogg'
	retreat_distance = 5
	minimum_distance = 5
	ranged = 1

/mob/living/simple_animal/hostile/humanoid/grey/soldier/space/ranged/Life()
	..()
	if(health <= 70 && defensive_stance == 0) // Health is getting low, lets back off and try to use range to our advantage
		defensive_stance = 1
		retreat_distance = 8
		minimum_distance = 8
		say("[pick("Trooper under heavy fire! Moving to reserve position.", "Hostile is proving resilient. Backup required.", "Covering fire! Now!")]")
	if(health > 70 && defensive_stance == 1) // Health has somehow been restored, lets get closer and be more aggressive
		defensive_stance = 0
		retreat_distance = 5
		minimum_distance = 5

/mob/living/simple_animal/hostile/humanoid/grey/soldier/space/ranged/Shoot(var/atom/target, var/atom/start, var/mob/user)
	if(prob(5)) // Throw a grenade
		visible_message("<span class = 'warning'>\The [src] primes a grenade and hurls it towards \the [target]!</span>")
		say("[pick("A gift from the mothership.", "Ordinance away!", "Let's see how you like this.")]")
		var/atom/movable/grenade_to_throw = new /obj/item/weapon/grenade/spawnergrenade/mothershipdrone(get_turf(src))
		var/obj/item/weapon/grenade/F = grenade_to_throw
		grenade_to_throw.throw_at(target,10,2)
		F.activate()
	else // Otherwise just fire a projectile normally
		..()

/mob/living/simple_animal/hostile/humanoid/grey/soldier/space/ranged/Aggro()
	..()
	say(pick("Hostile sighted, my sector.","Report, target marked for disintegration.","Sterilizing target.","For the mothership!","Target acquired. Disintegrate with extreme prejudice."), all_languages[LANGUAGE_GREY])

///////////////////////////////////////////////////////////////////GREY COMMANDO///////////
//Durable, spaceproof, and very dangerous. Uses two disintegrators to quickly melt enemies to ash, and can change firing modes in combat
/mob/living/simple_animal/hostile/humanoid/grey/soldier/space/commando
	name = "MDF Commando"
	desc = "A thin alien humanoid. This one is wearing an armored rigsuit and equipped with twin disintegrators."

	icon_state = "greytrooper_commando"
	icon_living = "greytrooper_commando"

	maxHealth = 175 // More health than a standard trooper, less than a heavy soldier
	health = 175
	melee_damage_lower = 10
	melee_damage_upper = 15

	items_to_drop = list(/obj/item/weapon/gun/energy/smalldisintegrator, /obj/item/weapon/gun/energy/smalldisintegrator)

	speak = list("Sweeping sector, prepared for EVA maneuvers.","We need more action in this sector.","Air supply capacity check is green.","This deployment hasn't had nearly enough disintegrations.")
	speak_chance = 1

	projectiletype = /obj/item/projectile/beam/scorchray
	projectilesound = 'sound/weapons/ray1.ogg'
	retreat_distance = 3
	minimum_distance = 3
	ranged = 1
	doubleshot = 1

	var/microwave = 0

/mob/living/simple_animal/hostile/humanoid/grey/soldier/space/commando/Life()
	..()
	if(microwave == 0)
		projectiletype = /obj/item/projectile/beam/scorchray
		projectilesound = 'sound/weapons/ray1.ogg'
		icon_state = "greytrooper_commando"
		icon_living = "greytrooper_commando"
	if(microwave == 1)
		projectiletype = /obj/item/projectile/energy/microwaveray
		projectilesound = 'sound/weapons/ray2.ogg'
		icon_state = "greytrooper_commando1"
		icon_living = "greytrooper_commando1"

/mob/living/simple_animal/hostile/humanoid/grey/soldier/space/commando/Shoot()
	if(prob(5)) //Handles switching firing modes in combat
		if(microwave == 0)
			visible_message("<span class='warning'>[src] switches their disintegrators to microwave mode!</span>")
			microwave = 1
		else
			visible_message("<span class='warning'>[src] switches their disintegrators to scorch mode!</span>")
			microwave = 0
	else // Otherwise fire the projectile for whatever mode is active
		..()

/mob/living/simple_animal/hostile/humanoid/grey/soldier/space/ranged/Aggro()
	..()
	say(pick("Hostile sighted, my sector.","No contest.","Time for cleanup.","Erasing hostile.","Target acquired. Disintegrate with extreme prejudice.","You've made your last mistake, scum."), all_languages[LANGUAGE_GREY])

//////////////////////////////
// GREY RESEARCHERS
//////////////////////////////
//Baseline researcher, here for the sake of some inheritance sanity
/mob/living/simple_animal/hostile/humanoid/grey/researcher
	name = "Mothership Researcher"
	desc = "A thin alien humanoid. This one is wearing a labcoat and appears to be unfriendly."

	icon_state = "greyresearcher_base"
	icon_living = "greyresearcher_base"

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART // Can smash things open, nerd rage
	stat_attack = UNCONSCIOUS // Grey hostile humanoids are too smart to think that someone is dead just because they fell over

	melee_damage_lower = 4
	melee_damage_upper = 6 // Very weak melee attacks, angry nerd flailing

	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'

	faction = "mothership"

	corpse = /obj/effect/landmark/corpse/grey/researcher

/mob/living/simple_animal/hostile/humanoid/grey/researcher/GetAccess()
	return list(access_mothership_general, access_mothership_research)

///////////////////////////////////////////////////////////////////GREY SCIENTIST///////////
//Grey ranged researcher. Less hit points than a soldier, will shoot their disintegrator at targets and occasionally change firing modes
/mob/living/simple_animal/hostile/humanoid/grey/researcher/laser
	name = "Mothership Researcher"
	desc = "A thin alien humanoid. This one is armed with a disintegrator."

	icon_state = "greyresearcher_laser"
	icon_living = "greyresearcher_laser"

	items_to_drop = list(/obj/item/weapon/gun/energy/smalldisintegrator)

	speak = list("I can't believe these reports.","This will be my most impressive breakthrough yet.","Can't those MDF buffoons do anything right?","The Administration will make me a senior researcher when they see these results.")
	speak_chance = 1

	faction = "mothership"

	var/microwave = 0

	projectiletype = /obj/item/projectile/beam/scorchray
	projectilesound = 'sound/weapons/ray1.ogg'
	retreat_distance = 4
	minimum_distance = 4
	ranged = 1

/mob/living/simple_animal/hostile/humanoid/grey/researcher/laser/Life()
	..()
	if(microwave == 0)
		projectiletype = /obj/item/projectile/beam/scorchray
		projectilesound = 'sound/weapons/ray1.ogg'
		icon_state = "greyresearcher_laser"
		icon_living = "greyresearcher_laser"
	if(microwave == 1)
		projectiletype = /obj/item/projectile/energy/microwaveray
		projectilesound = 'sound/weapons/ray2.ogg'
		icon_state = "greyresearcher_laser1"
		icon_living = "greyresearcher_laser1"

/mob/living/simple_animal/hostile/humanoid/grey/researcher/laser/Shoot()
	if(prob(5)) //Handles switching firing modes in combat
		if(microwave == 0)
			visible_message("<span class='warning'>[src] switches their disintegrator to microwave mode!</span>")
			microwave = 1
		else
			visible_message("<span class='warning'>[src] switches their disintegrator to scorch mode!</span>")
			microwave = 0
	else // Otherwise fire the projectile for whatever mode is active
		..()

/mob/living/simple_animal/hostile/humanoid/grey/researcher/laser/Aggro()
	..()
	say(pick("Brain beats brawn!","It seems you've volunteered to be my next weapon testing subject.","You don't belong here! Get out of my laboratory!"), all_languages[LANGUAGE_GREY])

///////////////////////////////////////////////////////////////////GREY CHEMIST///////////
//Grey chemist. Less hit points than a soldier and not technically "armed". However, they will throw unstable goo and flasks of nasty chemicals at targets. Best not to underestimate them
/mob/living/simple_animal/hostile/humanoid/grey/researcher/chemist
	name = "Mothership Chemist"
	desc = "A thin alien humanoid. This one doesn't seemed armed, but has several flasks of unknown chemicals sticking out of their labcoat pockets."

	items_to_drop = list(/obj/item/toy/snappop/virus, /obj/item/weapon/reagent_containers/glass/jar/erlenmeyer)

	speak = list("I can't believe these reports.","This will be my most impressive breakthrough yet.","Can't those MDF buffoons do anything right?","The Administration will make me a senior researcher when they see these results.")
	speak_chance = 1

	ranged_message = "rants angrily"
	ranged_cooldown = 5
	ranged_cooldown_cap = 5
	retreat_distance = 3
	minimum_distance = 3
	ranged = 1

/mob/living/simple_animal/hostile/humanoid/grey/researcher/chemist/Shoot(var/atom/target, var/atom/start, var/mob/user) // Angry nerd will throw unstable goo, or a flask filled with nasty chems
	switch(rand(0,3))
		if(0)
			visible_message("<span class = 'warning'>\The [src] pulls a glob of unstable goo from one of their labcoat pockets and hurls it towards \the [target]!</span>")
			var/atom/movable/goo_to_throw = new /obj/item/toy/snappop/virus(get_turf(src))
			goo_to_throw.throw_at(target,10,3) // Deals a decent amount of brute damage
		if(1)
			visible_message("<span class = 'warning'>\The [src] pulls a huge flask from one of their labcoat pockets and hurls it towards \the [target]!</span>")
			var/atom/movable/acidflask_to_throw = new /obj/item/weapon/reagent_containers/glass/jar/erlenmeyer/pacid(get_turf(src))
			acidflask_to_throw.throw_at(target,10,3) // Tasty acid beaker
		if(2)
			visible_message("<span class = 'warning'>\The [src] pulls a huge flask from one of their labcoat pockets and hurls it towards \the [target]!</span>")
			var/atom/movable/mutaflask_to_throw = new /obj/item/weapon/reagent_containers/glass/jar/erlenmeyer/mutagen(get_turf(src))
			mutaflask_to_throw.throw_at(target,10,3) // Mutagen beaker, oh boy
		if(3)
			visible_message("<span class = 'warning'>\The [src] pulls a huge flask from one of their labcoat pockets and hurls it towards \the [target]!</span>")
			var/atom/movable/beetusflask_to_throw = new /obj/item/weapon/reagent_containers/glass/jar/erlenmeyer/diabeetus(get_turf(src))
			beetusflask_to_throw.throw_at(target,10,3) // Because diabeetusol doesn't show up enough, and it's a hilarious chem
	return 1

/mob/living/simple_animal/hostile/humanoid/grey/researcher/chemist/Aggro()
	..()
	say(pick("Stay out of chemistry!","You are interrupting the flow of chemistry!","You don't belong here! Get out of chemistry!"), all_languages[LANGUAGE_GREY])

///////////////////////////////////////////////////////////////////GREY SURGEON///////////
//Grey melee researcher. Less hit points than a soldier, but is one of the only enemies in the vault that can use psychic attacks
/mob/living/simple_animal/hostile/humanoid/grey/researcher/surgeon
	name = "Mothership Surgeon"
	desc = "A thin alien humanoid. This one is armed with a laser scalpel."

	icon_state = "greyresearcher_scalpel"
	icon_living = "greyresearcher_scalpel"

	melee_damage_lower = 15
	melee_damage_upper = 25 // One of the more dangerous greys in melee combat

	attacktext = "slices"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	corpse = /obj/effect/landmark/corpse/grey/surgeon

	items_to_drop = list(/obj/item/tool/scalpel/laser)

	speak = list("Another day, another dissection.","Measure twice, cut once.","Can't those MDF buffoons do anything right?","The Administration will make me a senior researcher when they see these results.")
	speak_chance = 1

	ranged_message = "stares intently"
	ranged_cooldown = 20
	ranged_cooldown_cap = 20
	ranged = 1

/mob/living/simple_animal/hostile/humanoid/grey/researcher/surgeon/Shoot()
	var/mob/living/carbon/human/H = target
	if(H.isUnconscious() || H.is_wearing_item(/obj/item/clothing/head/tinfoil) || (M_PSY_RESIST in H.mutations)) // Psy-attacks don't work if the target is unconsious, wearing a tin foil hat, or has genetic resistance
		return
	else
		switch(rand(0,4))
			if(0) //Minor brain damage
				to_chat(H, "<span class='userdanger'>You get a blindingly painful headache.</span>")
				H.adjustBrainLoss(10)
				H.eye_blurry = max(H.eye_blurry, 5)
				playsound(H, 'sound/effects/alien_psy.ogg', 50, 0, -4)
			if(1) //Brief knockdown
				to_chat(H, "<span class='userdanger'>You suddenly lose your sense of balance!</span>")
				H.emote("me", 1, "collapses!")
				H.Knockdown(2)
				playsound(H, 'sound/effects/alien_psy.ogg', 50, 0, -4)
			if(2) //Target gets put to sleep for a few seconds
				to_chat(H, "<span class='userdanger'>You feel exhausted...</span>")
				H.drowsyness += 4
				playsound(H, 'sound/effects/alien_psy.ogg', 50, 0, -4)
				spawn(2 SECONDS)
					H.sleeping += 3
			if(3) //Minor hallucinations and jittering
				to_chat(H, "<span class='userdanger'>Your mind feels less stable, and you feel nervous.</span>")
				H.hallucination += 60 // For some reason it has to be this high at least or seemingly nothing happens
				H.Jitter(20)
				H.stuttering += 20
				playsound(H, 'sound/effects/alien_psy.ogg', 50, 0, -4)
			if(4) //Ranged disarm
				to_chat(H, "<span class='userdanger'>Your arm jerks involuntarily, and you drop what you're holding!</span>")
				H.drop_item()
				playsound(H, 'sound/effects/alien_psy.ogg', 50, 0, -4)
		return 1

/mob/living/simple_animal/hostile/humanoid/grey/researcher/surgeon/Aggro()
	..()
	say(pick("I could use more tissue samples.","Hold still, this will only sting for a moment.","You don't belong here! Good, I needed a new specimen to dissect."), all_languages[LANGUAGE_GREY])

//////////////////////////////
// GREY LEADER
//////////////////////////////

///////////////////////////////////////////////////////////////////GREY LEADER///////////
//One of the big bawsses of the mothership. Equipped with a decently damaging ranged weapon, and strong psychic attack capabilities. Can buff allies in the vicinity with a small health boost or drain their health to replenish its own
/mob/living/simple_animal/hostile/humanoid/grey/leader
	name = "GDR Administrator"
	desc = "A thin alien humanoid. This one is wearing an armored pressure suit and brandishing an advanced disintegrator."

	icon_state = "grey_leader"
	icon_living = "grey_leader"

	corpse = null

	maxHealth = 300
	health = 300

	see_in_dark = 10 // superior ayy darkvision
	vision_range = 12 // Capable of seeing farther than your average mob
	aggro_vision_range = 12
	idle_vision_range = 12

	melee_damage_lower = 20
	melee_damage_upper = 40 // Moderate melee damage

	attacktext = "telekinetically repels" // Not really the fisticuffs type, will just try to fling targets away
	attack_sound = 'sound/effects/lightning/chainlightning2.ogg'

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART // Can smash many things open thanks to stronk brain muscles
	status_flags = UNPACIFIABLE // Not pacifiable due to being a "boss" mob
	stat_attack = UNCONSCIOUS // Grey hostile humanoids are too smart to think that someone is dead just because they fell over

	universal_speak = 1
	universal_understand = 1
	waterproof = 1

	var/psychic_range = 10 // Range limit on psychic attacks

	var/last_psychicdrain = 0
	var/const/psychicdrain_cooldown = 10 SECONDS // Cooldown on the ability to leech health from an ally

	var/last_psychicrejuvenate = 0
	var/const/psychicrejuvenate_cooldown = 30 SECONDS // Cooldown on the ability to heal an ally

	var/last_psychicattack = 0
	var/const/psychicattack_cooldown = 20 SECONDS // Cooldown on general psychic attacks used against players

	var/telekinesis_throw_chance = 80 // Values for flinging a target away with a melee attack
	var/telekinesis_throw_speed = 3
	var/telekinesis_throw_range = 10

	items_to_drop = list(/obj/item/weapon/gun/energy/advdisintegrator, /obj/item/weapon/card/id/mothership_leader, /obj/item/clothing/under/grey/grey_leader, /obj/item/clothing/mask/gas/mothership/advanced, /obj/item/clothing/shoes/jackboots/steeltoe/mothership_superior, /obj/item/clothing/suit/space/rig/grey/leader)

	speak = list("These imbeciles... it's all so tiresome.","The latest clone batch has been less than impressive.","I will not tolerate further failure.","The mothership and the Chairman are counting on us, cowardice and incompetence are unacceptable.","Do I have to tell you cretins how to do everything?","To think the Chairman assigned me to this backwater sector... what a waste of my talents.")
	speak_chance = 5

	faction = "mothership"

	projectiletype = /obj/item/projectile/beam/atomizationray
	projectilesound = 'sound/weapons/ray1.ogg'
	retreat_distance = 8
	minimum_distance = 8
	ranged = 1

/mob/living/simple_animal/hostile/humanoid/grey/leader/Life()
	..()
	if(last_psychicrejuvenate + psychicrejuvenate_cooldown < world.time) // Can heal allies slightly
		for(var/mob/living/simple_animal/hostile/humanoid/grey/soldier/S in view(src, psychic_range))
			if(S.health < (S.maxHealth/2))
				visible_message("<span class = 'warning'>\The [src] fixes an intense gaze on the wounded [S], and they suddenly appear to be slightly revitalized!</span>")
				if(prob(25))
					say(pick("You don't deserve this, you useless lobotomite.","The pain in your nervous system is an illusion.","Your death in the line of duty is unacceptable for the time being.","The mothership requires your continued service.","I have seen mothership soldiers survive far worse, compose yourself."))
				S.health+=30
				last_psychicrejuvenate = world.time

			if(target && S.target != target)
				S.GiveTarget(target)

	if(last_psychicdrain + psychicdrain_cooldown < world.time) // Or drain health from them to heal himself
		for(var/mob/living/simple_animal/hostile/humanoid/grey/soldier/S in view(src, psychic_range))
			if(health < (maxHealth/2))
				visible_message("<span class = 'warning'>\The [src] fixes an intense gaze on [S], and they writhe in agony. \The [src] appears to have been rejuvenated by the exchange, however.</span>")
				if(prob(25))
					say(pick("The mothership will remember your sacrifice.","Your psychic energy will serve me better.","Your strength becomes my strength.","You have failed to defend your administrator, this is the price."))
				health+=150
				S.health-=75
				last_psychicdrain = world.time

			if(target && S.target != target)
				S.GiveTarget(target)

	if(health >= (maxHealth/3)) // Decently high health? Stay far back
		retreat_distance = 8
		minimum_distance = 8

	if(health < (maxHealth/3)) // Health getting really low? Lower than it should be with our psychic drain ability? Fuck it, we're getting aggressive
		retreat_distance = 2
		minimum_distance = 2

/mob/living/simple_animal/hostile/humanoid/grey/leader/AttackingTarget() // Fling the people trying to beat him up awaaaaaay
	..()
	if(istype(target, /mob/living))
		var/mob/living/M = target
		if(telekinesis_throw_range && prob(telekinesis_throw_chance))
			visible_message("<span class='danger'>\The [M] is flung away from [src]!</span>")
			if(ishuman(M))
				M.Knockdown(2)
				M.Stun(2)
			var/turf/T = get_turf(src)
			var/turf/target_turf
			if(istype(T, /turf/space)) // if ended in space, then range is unlimited
				target_turf = get_edge_target_turf(T, dir)
			else
				target_turf = get_ranged_target_turf(T, dir, telekinesis_throw_range)
			M.throw_at(target_turf,100,telekinesis_throw_speed)

/mob/living/simple_animal/hostile/humanoid/grey/leader/Shoot()
	if(last_psychicattack + psychicattack_cooldown < world.time)
		var/list/victims = list()
		for(var/mob/living/carbon/human/H in view(src, psychic_range))
			victims.Add(H)

		if(!victims.len)
			return
		switch(rand(0,4))
			if(0) //Brain damage, confusion, and dizziness
				for(var/mob/living/carbon/human/H in victims)
					if(H.isUnconscious() || H.is_wearing_item(/obj/item/clothing/head/tinfoil) || (M_PSY_RESIST in H.mutations)) // Psy-attacks don't work if the target is unconsious, wearing a tin foil hat, or has genetic resistance
						continue
					to_chat(H, "<span class='userdanger'>An unbearable pain stabs into your mind!</span>")
					H.adjustBrainLoss(20)
					H.eye_blurry = max(H.eye_blurry, 10)
					H.confused += 10
					H.dizziness += 10
					playsound(H, 'sound/effects/alien_psy.ogg', 50, 0, -4)
					last_psychicattack = world.time
					if(prob(25))
						H.audible_scream()
			if(1) //A knockdown, with some dizziness
				for(var/mob/living/carbon/human/H in victims)
					if(H.isUnconscious() || H.is_wearing_item(/obj/item/clothing/head/tinfoil) || (M_PSY_RESIST in H.mutations)) // Psy-attacks don't work if the target is unconsious, wearing a tin foil hat, or has genetic resistance
						continue
					to_chat(H, "<span class='userdanger'>You suddenly lose your sense of balance!</span>")
					H.emote("me", 1, "collapses!")
					H.Knockdown(4)
					H.confused += 6
					H.dizziness += 6
					playsound(H, 'sound/effects/alien_psy.ogg', 50, 0, -4)
					last_psychicattack = world.time
			if(2) //Naptime
				for(var/mob/living/carbon/human/H in victims)
					if(H.isUnconscious() || H.is_wearing_item(/obj/item/clothing/head/tinfoil) || (M_PSY_RESIST in H.mutations)) // Psy-attacks don't work if the target is unconsious, wearing a tin foil hat, or has genetic resistance
						continue
					to_chat(H, "<span class='userdanger'>You feel exhausted beyond belief. You can't keep your eyes open...</span>")
					H.drowsyness += 6
					playsound(H, 'sound/effects/alien_psy.ogg', 50, 0, -4)
					last_psychicattack = world.time
					spawn(2 SECONDS)
						H.sleeping += 5
			if(3) //Serious hallucinations and jittering
				for(var/mob/living/carbon/human/H in victims)
					if(H.isUnconscious() || H.is_wearing_item(/obj/item/clothing/head/tinfoil) || (M_PSY_RESIST in H.mutations)) // Psy-attacks don't work if the target is unconsious, wearing a tin foil hat, or has genetic resistance
						continue
					to_chat(H, "<span class='userdanger'>Your mind feels much less stable, and you feel a terrible dread.</span>")
					H.hallucination += 75
					H.Jitter(30)
					H.stuttering += 30
					playsound(H, 'sound/effects/alien_psy.ogg', 50, 0, -4)
					last_psychicattack = world.time
			if(4) //Brief period of pacification
				for(var/mob/living/carbon/human/H in victims)
					if(H.isUnconscious() || H.is_wearing_item(/obj/item/clothing/head/tinfoil) || (M_PSY_RESIST in H.mutations)) // Psy-attacks don't work if the target is unconsious, wearing a tin foil hat, or has genetic resistance
						continue
					to_chat(H, "<span class='userdanger'>You feel strangely calm and passive. What's the point in fighting?</span>")
					H.reagents.add_reagent(CHILLWAX, 2)
					playsound(H, 'sound/effects/alien_psy.ogg', 50, 0, -4)
					last_psychicattack = world.time

	if(!last_psychicattack + psychicattack_cooldown < world.time) // If not done cooling down from the previous psychic attack, just shoot a laser beem
		..()

/mob/living/simple_animal/hostile/humanoid/grey/leader/bullet_act(var/obj/item/projectile/P) // Lasers have a 50% chance to reflect off the armor, which matches up if the player takes it and puts it on
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam) || istype(P, /obj/item/projectile/forcebolt) || istype(P, /obj/item/projectile/change))
		var/reflectchance = 50 - round(P.damage/3)
		if(prob(reflectchance))
			visible_message("<span class='danger'>The [P.name] gets reflected by \the [src]'s pressure suit!</span>")

			if(!istype(P, /obj/item/projectile/beam)) //has seperate logic
				P.reflected = 1
				P.rebound(src)

			return PROJECTILE_COLLISION_REBOUND // complete projectile permutation

	return (..(P))

/mob/living/simple_animal/hostile/humanoid/grey/leader/Aggro()
	..()
	say(pick("You came this far, even after being warned not to? So be it.","You are clearly too intellectually inferior to understand anything but force.","Attacking a mothership administrator? I almost pity your stupidity.","What do you even hope to accomplish from this?","What a grand and intoxicating insolence.","Once I've disintegrated your body I will keep your brain to study your unnatural behavior."), all_languages[LANGUAGE_GREY])

/mob/living/simple_animal/hostile/humanoid/grey/leader/death(var/gibbed = FALSE) // One last act of defiance against the attackers that caused this
	visible_message("<span class=danger><B>Before collapsing, the Administrator lets loose one last blast of psychic energy that tears their body apart!</span></B>")
	say("[pick("NO- NO! IMPOSSIBLE!", "I WON'T ALLOW YOU TO SURVIVE MY FAILURE!", "DIE, REPROBATE!", "GLORY TO THE MOTHERSHIP!")]")


	for(var/mob/living/carbon/human/H in view(src, psychic_range))
		if(H.isUnconscious() || H.is_wearing_item(/obj/item/clothing/head/tinfoil) || (M_PSY_RESIST in H.mutations)) // Psy-attacks don't work if the target is unconsious, wearing a tin foil hat, or has genetic resistance
			continue
		to_chat(H, "<span class='userdanger'>An unbearable pain stabs into your mind!</span>")
		H.adjustBrainLoss(20)
		H.eye_blurry = max(H.eye_blurry, 10)
		H.confused += 10
		H.dizziness += 10
		H.Knockdown(4)
		H.Stun(4)
		H.audible_scream()
		playsound(H, 'sound/effects/alien_psy.ogg', 50, 0, -4)

	playsound(src, 'sound/effects/flesh_squelch.ogg', 50, 1)
	new /obj/effect/gibspawner/genericmothership(src.loc)
	..(gibbed)

/mob/living/simple_animal/hostile/humanoid/grey/leader/GetAccess()
	return list(access_mothership_general, access_mothership_maintenance, access_mothership_military, access_mothership_research, access_mothership_leader)

/mob/living/simple_animal/hostile/humanoid/grey/leader/Process_Spacemove(var/check_drift = 0) // The ayy leader can follow enemies into space, and won't just drift off
	return 1

///////////////////////////////////////////////////////////////////ADMINISTRATOR ZORB///////////
//Named subtype of the ayy leader present in the lab vault
/mob/living/simple_animal/hostile/humanoid/grey/leader/zorb
	name = "Administrator Zorb"
