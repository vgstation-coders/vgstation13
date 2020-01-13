/datum/artifact_effect/deadharvest
	effecttype = "deadharvest"
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	var/list/mob_spawn = list()
	var/points = 0
	var/can_be_controlled = 0
	var/mob/living/controller //Whomever is the leader of these brainless minions

/datum/artifact_effect/deadharvest/New()
	..()
	can_be_controlled = pick(0,1)
	if(!mob_spawn.len)
		new_mob_spawn_list()

/datum/artifact_effect/deadharvest/proc/new_mob_spawn_list(var/choice)
	if(!choice)
		choice = rand(4)
	mob_spawn = list()
	switch(choice)
		if(1) //Regular necromancy mobs
			mob_spawn = list(/mob/living/simple_animal/hostile/necro/zombie = 100,
						/mob/living/simple_animal/hostile/necro/skeleton = 100,)
		if(2) //Infection zombies
			mob_spawn = list(/mob/living/simple_animal/hostile/necro/zombie/turned = 50,
						/mob/living/simple_animal/hostile/necro/zombie/rotting = 75,
						/mob/living/simple_animal/hostile/necro/zombie/putrid = 100,
						/mob/living/simple_animal/hostile/necro/zombie/crimson = 250,)
		if(3) //Necromorphs
			mob_spawn = list(/mob/living/simple_animal/hostile/necromorph = 150,
							/mob/living/simple_animal/hostile/necromorph/leaper = 90,
							/mob/living/simple_animal/hostile/necromorph/puker = 120,
							/mob/living/simple_animal/hostile/necromorph/exploder = 75,) //More necromorph mobs NOW
		if(4) //Randomized mobs
			var/max_mobs = rand(3,7)
			for(var/i=0 to max_mobs)
				var/mob/living/simple_animal/mob_to_add = pick(existing_typesof(/mob/living/simple_animal))
				var/mob_cost = rand(5,25)*10
				mob_spawn += mob_to_add
				mob_spawn[mob_to_add] = mob_cost

/datum/artifact_effect/deadharvest/DoEffectTouch(var/mob/user)
	if(!holder || !user)
		return
	if(isliving(user))
		if(can_be_controlled)
			if(!controller)
				to_chat(user, "<span class = 'sinister'>You feel a slight biting sensation, which subsides.</span>")
				controller = user
			else
				if(controller == user)
					to_chat(user, "<span class = 'rose'>\The [holder] hums happily.</span>")
					to_chat(user, "<span class = 'sinister'>[points]</span>")

		harvest(user, 1)
		for(var/mob/living/L in range(1,holder))
			if(L.isDead())
				if(ishuman(L))
					var/weakness = 1-GetAnomalySusceptibility(L)
					if(prob(weakness * 100))
						continue
				harvest(L)
	spawn_creature()

/datum/artifact_effect/deadharvest/DoEffectPulse() //Does it in waves, so sensible to heal associates
	if(!holder)
		return
	spawn_creature()
	for(var/mob/living/L in range(src.effectrange,holder))
		if(L.isDead())
			if(ishuman(L))
				var/weakness = 1-GetAnomalySusceptibility(L)
				if(prob(weakness * 100))
					continue
			harvest(L, heal_associates = 1)
		else
			if(ishuman(L))
				var/weakness = GetAnomalySusceptibility(L)
				if(prob(weakness * 100))
					to_chat(L, "<span class = 'sinister'>You [pick("feel tingly","are overcome with a sense of dread","feel incomplete")].</span>")
					continue



/datum/artifact_effect/deadharvest/DoEffectAura() //Does it continuously, so not sensible to heal associates
	if(!holder)
		return

	if(prob(10))
		spawn_creature()

	if(prob(50))
		for (var/mob/living/L in range(src.effectrange*2, holder))
			if(L.isDead())
				if(ishuman(L))
					var/weakness = 1-GetAnomalySusceptibility(L)
					if(prob(weakness * 100))
						continue
				harvest(L)

/datum/artifact_effect/deadharvest/proc/harvest(var/mob/living/sacrifice, var/override, var/heal_associates)
	if(!sacrifice)
		return

	if(!sacrifice.isDead() && !override) //No eating the living unless they come willingly
		return

	if(can_be_controlled && controller == sacrifice)
		return

	for(var/mob/living/summons in mob_spawn)
		if(istype(summons, sacrifice)) //No sacrificing things we've summoned
			if(heal_associates)
				sacrifice.revive(0)
				sacrifice.visible_message("<span class='warning'>\the [src] appears to wake from the dead, having healed all wounds.</span>")
			return

	if(iscarbon(sacrifice))
		to_chat(sacrifice, "<span class = 'sinister'>You don't feel quite like yourself anymore.</span>")
		points += 75

	if(isanimal(sacrifice))
		points += sacrifice.size*10

	if(isrobot(sacrifice))
		to_chat(sacrifice, "<span class = 'sinister'>Go away, we have no need for your twisted metal.</span>")
		return


	sacrifice.gib()

	new /obj/effect/gibspawner/generic(get_turf(holder))


/datum/artifact_effect/deadharvest/proc/spawn_creature()
	if(!mob_spawn.len)
		new_mob_spawn_list()
	var/mob/living/to_spawn = pick(mob_spawn)
	var/points_required = mob_spawn[to_spawn]

	if(points < points_required)
		holder.visible_message("<span class = 'danger'>\The [holder] [pick("buzzes angrily","lets out a slight hiss of steam","pulses ominously")]</span>")
		return 0

	points -= points_required

	var/list/randomturfs = new/list()
	for(var/turf/simulated/floor/T in orange(holder, 2))
		randomturfs.Add(T)

	var/mob/living/spawned_mob = new to_spawn(pick(randomturfs))

	if(ispath(to_spawn, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/animal_spawn = spawned_mob

		if(controller)
			animal_spawn.friends.Add(controller)
	new /obj/effect/gibspawner/generic(get_turf(holder))