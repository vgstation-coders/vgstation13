//the clown mobs in this file are NOT redundant, i needed them to be hostile so i couldn't use the existing clown/mime mobs, as they are retaliate, not hostile

/spell/aoe_turf/conjure/clownmime
	name = "Summon Jesters" //TODO: THINK OF BETTER NAME
	desc = "This forbidden Honkonomicon spell makes a temporary connection to the place beyond the realm of Nar'Sie, and incarnates some of the souls trapped there into physical form."
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

	summon_type = list(/mob/living/simple_animal/hostile/retaliate/cluwne/goblin/wizard)
	summon_amt = 6

	price = SP_BASE_PRICE + 10
	level_max = list(SP_TOTAL = 3, SP_SPEED = 2, SP_POWER = 1) //empower fully releases them from the void, 80 full points to get it maxed, leaves you with barely anything to buy escape options
	charge_cooldown_max = 30 SECONDS
	cooldown_reduc = 10 SECONDS
	cooldown_min = 10 SECONDS
	invocation = "H'NK'N G'B'LN"
	invocation_type = SP_INV_SHOUT
	spell_flags = NEEDSCLOTHES
//	hud_state = "clown" //TODO /low priority/
//	cast_sound = 'sound/misc/pitchedownhonking.ogg' //TODO /low priority/
	hud_state = "wiz_clown"
	cast_sound = 'sound/items/bikehorn.ogg'
	var/empowered

/spell/aoe_turf/conjure/clownmime/empower_spell()
	..()
	empowered += 1
	spell_levels[SP_POWER]++
	summon_amt = 4 //you lose 2 but they're way stronger
	. = "You have gotten the eyes of the eternally cursed focused on you, longingly, this time."
  //TO DO: make it so empowering the spell changes your clothing to the clownwizard one /low priority/

/spell/aoe_turf/conjure/clownmime/invocation(mob/user, list/targets)
	if(empowered)
		invocation = pick("Y'R G'D H'S 'B'N'D'N'D' Y'", "H'N'K'N'M'C'N", "CLW'N' N' M'RE", "R'TR'N FR'M N'THN!'")
	..()

/spell/aoe_turf/conjure/clownmime/perform(mob/user = usr, skipcharge = 0, list/target_override, var/ignore_timeless = FALSE, var/ignore_path = null)
	if(empowered)
		if(prob(50))
			summon_type = list(/mob/living/simple_animal/hostile/clown/wizard) //effectively the same mob, but muh flavor
		else
			summon_type = list(/mob/living/simple_animal/hostile/mime/wizard)
	else
		switch(pick(1,2,3))
			if(1)
				summon_type = list(/mob/living/simple_animal/hostile/retaliate/cluwne/goblin/wizard)
			if(2)
				summon_type = list(/mob/living/simple_animal/hostile/retaliate/cluwne/psychedelicgoblin/wizard)
			if(3)
				summon_type = list(/mob/living/simple_animal/hostile/retaliate/faguette/goblin/wizard)
	..()

/spell/aoe_turf/conjure/clownmime/choose_targets(var/mob/user = usr) //copypasted from the pitbull spell
	var/list/turf/locs = new
	for(var/direction in alldirs)
		if(locs.len >= 3) //we found 3 locations and thats all we need
			break
		var/turf/T = get_step(user, direction) //getting a loc in that direction
		if(quick_AStar(get_turf(user), T, /turf/proc/AdjacentTurfs, /turf/proc/Distance, 1, reference="\ref[src]")) // if a path exists, so no dense objects in the way its valid salid
			locs += T

	if(locs.len < 3)
		locs += user.loc
	return locs

/spell/aoe_turf/conjure/clownmime/before_cast(list/targets, user, bypass_range = 0)
	return targets

///////// MOBS /////////////

//goblins (10% chance they drop their clothing when dead)

/mob/living/simple_animal/hostile/retaliate/cluwne/goblin/wizard
	name = "clownly manifestation"
	desc = "The soul of a clown doomed for eternity now inhabits this shell. It's not fully there yet, so it's not outwardly hostile."
	faction = "wizard"

/mob/living/simple_animal/hostile/retaliate/cluwne/goblin/wizard/handle_loot_drop()
	if(prob(90))
		animate(src, alpha = 0, time = 3 SECONDS)
		spawn(3 SECONDS)
			qdel(src)
	else
		new /obj/item/clothing/mask/gas/clown_hat(src.loc)
		new /obj/item/clothing/shoes/clown_shoes(src.loc)
		qdel(src)

/mob/living/simple_animal/hostile/retaliate/cluwne/psychedelicgoblin/wizard
	name = "abyss-touched manifestation"
	desc = "The tortuous depths of the damned realm have tainted this one's soul beyond redemption. It's not fully there yet, so it's not outwardly hostile."
	faction = "wizard"
	speak = list("AHAHAHAHAHAHA!")

/mob/living/simple_animal/hostile/retaliate/cluwne/psychedelicgoblin/wizard/handle_loot_drop()
	if(prob(90))
		animate(src, alpha = 0, time = 3 SECONDS)
		spawn(3 SECONDS)
			qdel(src)
	else
		new /obj/item/clothing/mask/gas/clownmaskpsyche(src.loc)
		new /obj/item/clothing/shoes/clownshoespsyche(src.loc)
		qdel(src)

/mob/living/simple_animal/hostile/retaliate/faguette/goblin/wizard
	name = "silent manifestation"
	desc = "The soul of one of the mimes sent to the darkest depths of the cluwne realm, where those cursed without even mouths to cry in pain go, inhabits this shell. It's soul is not fully there yet, so it's not outwardly hostile."
	faction = "wizard"

/mob/living/simple_animal/hostile/retaliate/faguette/goblin/wizard/handle_loot_drop()
	if(prob(90))
		animate(src, alpha = 0, time = 3 SECONDS)
		spawn(3 SECONDS)
			qdel(src)
	else
		new /obj/item/clothing/head/beret(src.loc)
		new /obj/item/clothing/gloves/white(src.loc)
		qdel(src)

//the clown and mime (20% chance they drop ectoplasm)

/mob/living/simple_animal/hostile/clown/wizard //most of it is copypasted from the clown retaliate mob
	name = "reincarnated clown"
	desc = "Words don't do justice to the agony this one felt in the realms beyond. It is fiercely loyal to his summoner."
	faction = "wizard"
	icon = 'icons/mob/clown_mobs.dmi'
	icon_state = "scary clown"
	icon_living = "scary clown"
	icon_dead = "clown_dead"
	icon_gib = "clown_gib"
	speak_chance = 2
	turns_per_move = 5
	response_help = "touches"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	speak = list("The Honkmother abandoned us...", "Master brought us back...", "It's eternity in there...", "Longer than you think...", "Whatever it takes to not go back...")
	emote_see = list("laughs incoherently", "stares at nothing")
	a_intent = I_HURT
	stop_automated_movement_when_pulled = 0
	maxHealth = 75
	health = 75
	speed = 1
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "attacks"
	attack_sound = 'sound/items/bikehorn.ogg'
	meat_type = /obj/item/weapon/ectoplasm

	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 270
	maxbodytemp = 370
	heat_damage_per_tick = 15	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	cold_damage_per_tick = 10	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	unsuitable_atmos_damage = 10

/mob/living/simple_animal/hostile/clown/wizard/New()
	..()
	if(prob(95))
		var/temporaryiconholder = pick("pie spewer", "lube", "giggles", "scary clown", "fleshclown", "clown")
		icon_state = temporaryiconholder
		icon_living = temporaryiconholder
		icon_dead = "[temporaryiconholder]_dead"

	else
		var/temporarygigaholder = pick("honkhulk", "banana tree", "honkmunculus", "destroyer", "mutant", "blob", "clowns")
		icon_state = temporarygigaholder
		icon_living = temporarygigaholder
		icon_dead = "[temporarygigaholder]_dead"
		name = "reincarnated clownhorror"
		speed = 0.8
		attack_sound = 'sound/weapons/heavysmash.ogg'
		response_harm = "smashes"
		maxHealth = 100
		health = 100

/mob/living/simple_animal/hostile/clown/wizard/death(var/gibbed = FALSE)
	..()
	if(!gibbed)
		if(prob(80))
			animate(src, alpha = 0, time = 4 SECONDS)
			spawn(4 SECONDS)
				qdel(src)
		else
			gib()

/mob/living/simple_animal/hostile/mime/wizard //most of it copypasted from retaliate/mime
	name = "reincarnated mime"
	desc = "Its vacant eyes are faded with the weight of horrors untold, this one can't even scream to let the demons out. It is fiercely loyal to its summoner."

	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "mime"
	icon_living = "mime"
	icon_dead = "mime_dead"

	faction = "wizard"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "gently pushes aside"
	response_harm = "hits"

	emote_see = list("tries to claw its eyes out", "pulls at its hair as it cries desperately", "slaps its arms as if it had bugs on its skin", "stares unblinkingly at the horizon")
	speak_chance = 1
	a_intent = I_HURT
	stop_automated_movement_when_pulled = 0
	maxHealth = 75
	health = 75
	speed = 1
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "attacks"
	meat_type = /obj/item/weapon/ectoplasm

	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 270
	maxbodytemp = 370
	heat_damage_per_tick = 15	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	cold_damage_per_tick = 10	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	unsuitable_atmos_damage = 10

/mob/living/simple_animal/hostile/mime/wizard/death(var/gibbed = FALSE)
	..()
	if(!gibbed)
		if(prob(80))
			animate(src, alpha = 0, time = 4 SECONDS)
			spawn(4 SECONDS)
				qdel(src)
		else
			gib()
