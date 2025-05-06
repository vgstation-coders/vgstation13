/// --- Actual random reagent effects

/datum/random_reagent_effect
	var/name = ""
	var/activation_chance = 0
	var/investigative_log

/// When the reagent effect is initialised
/// Default behaviour: prob(activation_chance)
/datum/random_reagent_effect/proc/can_be_picked()
	return prob(activation_chance)

/// When the reagent effect is initialised
/datum/random_reagent_effect/proc/on_pick()

/// Called on human Life()
/datum/random_reagent_effect/proc/on_human_life(var/mob/living/carbon/human/H)

/// Called on the first tick inside a human
/datum/random_reagent_effect/proc/on_human_life_zeroth(var/mob/living/carbon/human/H)

// Log a text message in mob's attack logs
/datum/random_reagent_effect/proc/log_effect(var/mob/M, var/msg)
	M.attack_log += text("\[[time_stamp()]\]: <font color='orange'>[msg] (<a href='?_src_=vars;Vars=\ref[src]'>[src]</a>)</font>")
	log_attack("[M.name] ([M.ckey]) [msg] ([src] \ref[src])")
	msg_admin_attack("[M.name] ([M.ckey]) [msg] (<a href='?_src_=vars;Vars=\ref[src]'>RR</a>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>)")

/// ------------- Explode
/datum/random_reagent_effect/explode
	name = "Explode"
	activation_chance = 8
	var/explode_strength

#define NO_GIBS 0
#define GIBS 1
#define SMALL_EXPLOSION 2
#define BREACH_NORMAL 3
#define BREACH_REINFORCED 4

/datum/random_reagent_effect/explode/on_pick()
	explode_strength = pick(
		1000; GIBS, // Just gibs
		 500; SMALL_EXPLOSION, // Small explosion
		 400; BREACH_NORMAL, // Breaches normal floor
		 100; BREACH_REINFORCED, // Breaches reinforced floor
	)
	investigative_log = "Pikced effect 'explode' with strength [explode_strength] -- "

/datum/random_reagent_effect/explode/on_human_life(var/mob/living/carbon/human/H)
	H.death(explode_strength)
	switch(explode_strength)
		if(NO_GIBS)
			log_effect(H, "was killed instantly")
		if(GIBS)
			log_effect(H, "was gibbed")
		if(SMALL_EXPLOSION)
			log_effect(H, "exploded (small)")
			explosion(get_turf(H), 0, 0, 1, 3, whodunnit=H)
		if(BREACH_NORMAL)
			log_effect(H, "exploded (medium)")
			explosion(get_turf(H), 0, 1, 3, 5, whodunnit=H)
		if(BREACH_REINFORCED to INFINITY)
			log_effect(H, "exploded (large)")
			explosion(get_turf(H), 1, 3, 5, 7, whodunnit=H)
	return

#undef NO_GIBS
#undef GIBS
#undef SMALL_EXPLOSION
#undef BREACH_NORMAL
#undef BREACH_REINFORCED

/// ------------- Healing
/datum/random_reagent_effect/simple_heal_damage
	name = "Simple heal/damage"
	activation_chance = 100 // Always picked
	var/list/healing_values = list(
		"brute" = 0,
		"oxy" = 0,
		"tox" = 0,
		"fire" = 0,
		"clone" = 0,
		"brain" = 0,
	)

/datum/random_reagent_effect/simple_heal_damage/on_pick()
	var/generator/total_value_rng = generator("num", 10, 0.2, LINEAR_RAND) // Uniform distribution for 10 to 0.2
	for (var/dmg_type in healing_values)
		var/activation_prob = (dmg_type != "clone") ? 30 : 8 // 30% to activate regular damage type. 8% chance to activate clone
		if (prob(activation_prob))
			healing_values[dmg_type] = total_value_rng.Rand()
			// 80% of the effect to heal (neg dmg)
			if (prob(80))
				healing_values[dmg_type] =- healing_values[dmg_type]
			investigative_log += "-- damage [dmg_type]: [healing_values[dmg_type]] "

/datum/random_reagent_effect/simple_heal_damage/on_human_life(mob/living/carbon/human/H)
	// We hate hardcoding here
	H.adjustBruteLoss(healing_values["brute"] *REM)
	H.adjustOxyLoss(healing_values["oxy"]*REM)
	H.adjustToxLoss(healing_values["tox"]*REM)
	H.adjustFireLoss(healing_values["fire"]*REM)
	H.adjustCloneLoss(healing_values["clone"]*REM)
	H.adjustBrainLoss(healing_values["brain"]*REM)


/// ------ Transform women into men
/datum/random_reagent_effect/tf_inverse
	name = "Anti-estradiol (female to male tf)"
	activation_chance = 8
	investigative_log = "transform women into men -- "

/datum/random_reagent_effect/tf_inverse/on_human_life(mob/living/carbon/human/H)
	if(isjusthuman(H) && H.gender != MALE)
		H.emote("faint")
		var/obj/effect/smoke/smoke = new /obj/effect/smoke(get_turf(H))
		smoke.time_to_live = 1
		H.gender = MALE

		H.my_appearance.h_style = pick("Bald", "Bedhead", "Bedhead 2", "Bowl", "Skinhead", "Balding Hair", "Nitori", "Manbun")
		H.my_appearance.f_style = pick("Neckbeard", "Full Beard", "Unshaven")
		H.my_appearance.s_tone = rand(-10, 10)

		H.my_appearance.r_eyes = H.my_appearance.g_eyes = H.my_appearance.b_eyes = 0
		H.my_appearance.r_facial = H.my_appearance.r_hair = 20
		H.my_appearance.g_facial = H.my_appearance.g_hair = 20
		H.my_appearance.b_facial = H.my_appearance.b_hair = 20

		H.update_hair()
		H.update_body()
		H.regenerate_icons()
		H.check_dna_integrity()
		H.update_dna_from_appearance()
		log_effect(H, "was transformed into a man")

/// --------- Kill users
/datum/random_reagent_effect/kill
	name = "Kill"
	activation_chance = 2
	investigative_log = "kill user -- "

/datum/random_reagent_effect/kill/on_human_life(mob/living/carbon/human/H)
	H.visible_message("<span class='warning'>\The [H] suddenly collapses!</span>")
	H.death()

/// --------- Catbeast transformation
/datum/random_reagent_effect/tf_catbeast
	name = "TF Catbeast"
	activation_chance = 1
	investigative_log = "transform user into catbeast -- "

/datum/random_reagent_effect/tf_catbeast/on_human_life(mob/living/carbon/human/H)
	if (!iscatbeast(H))
		H.set_species("Tajaran", transfer_damage = TRUE)
		H.regenerate_icons()
		H.emote("me", MESSAGE_HEAR, pick("meows", "mews"))
		playsound(H, 'sound/voice/catmeow.ogg', 100)
		log_effect(H, "was transformed into a catbeast")


/// --------- Simple mob transformation
/datum/random_reagent_effect/tf_simplemob
	name = "TF Simple mob"
	activation_chance = 4
	var/picked_mob_type

/datum/random_reagent_effect/tf_simplemob/on_pick()
	// This is a BIT ugly but eeeh
	var/generator/rand = generator("num", 0, 150)
	var/picked_number = rand.Rand()
	switch(picked_number)
		if (0 to 100)
			picked_mob_type = pick(
				/mob/living/simple_animal/capybara, /mob/living/simple_animal/cat,
				/mob/living/simple_animal/cat/kitten, /mob/living/simple_animal/cat/snek,
				/mob/living/simple_animal/chick, /mob/living/simple_animal/chicken,
				/mob/living/simple_animal/corgi, /mob/living/simple_animal/corgi/puppy,
				/mob/living/simple_animal/corgi/saint, /mob/living/simple_animal/corgi/sasha,
				/mob/living/simple_animal/cow, /mob/living/simple_animal/crab,
				/mob/living/simple_animal/hamster, /mob/living/simple_animal/hostile/retaliate/goat,
				/mob/living/simple_animal/hostile/retaliate/goat/wooly, /mob/living/simple_animal/parrot,
				/mob/living/simple_animal/penguin, /mob/living/simple_animal/penguin/chick,
				/mob/living/simple_animal/rabbit, /mob/living/simple_animal/rabbit/bunny,
			)
		if (101 to 130) // Uncommon
			picked_mob_type = pick(
				/mob/living/simple_animal/borer, /mob/living/simple_animal/puddi/happy,
				/mob/living/simple_animal/puddi/anger, /mob/living/simple_animal/spiderbot,
			)
		if (131 to 145) // Dangerous
			picked_mob_type = pick(
				/mob/living/simple_animal/amogusflash,
				/mob/living/simple_animal/hostile/asteroid/basilisk, /mob/living/simple_animal/hostile/asteroid/goldgrub,
				/mob/living/simple_animal/hostile/asteroid/goliath, /mob/living/simple_animal/hostile/asteroid/rockernaut,
				/mob/living/simple_animal/hostile/bear, /mob/living/simple_animal/hostile/carp,
				/mob/living/simple_animal/hostile/giant_spider/hunter, /mob/living/simple_animal/hostile/pitbull,
				/mob/living/simple_animal/slime, /mob/living/simple_animal/slime/adult,
			)
		if (146 to 150) // Owned
			picked_mob_type = pick(
				/mob/living/simple_animal/hostile/retaliate/clown, /mob/living/simple_animal/hostile/retaliate/cluwne,
				/mob/living/simple_animal/hostile/retaliate/faguette, /mob/living/simple_animal/hostile/retaliate/mime,
			)
	investigative_log = "transform user into [picked_mob_type] -- "

/datum/random_reagent_effect/tf_simplemob/on_human_life(mob/living/carbon/human/H)
	var/mob/living/simple_animal/animal = new picked_mob_type(get_turf(H))
	animal.name = get_first_word(H.name)
	animal.real_name = get_first_word(H.real_name)
	animal.flavor_text = H.flavor_text
	animal.gender = H.gender
	animal.desc = "Something is off about this one."
	animal.faction = H.faction
	animal.meat_type = H.meat_type
	animal.attack_log = H.attack_log.Copy()
	H.reagents.trans_to(animal.reagents, animal.reagents.maximum_volume)

	animal.health = 100
	animal.maxHealth = 100
	animal.stop_automated_movement = TRUE
	animal.wander = FALSE
	animal.speak_chance = 0
	animal.can_breed = FALSE //No ERP allowed

	H.Premorph()
	H.audible_scream()
	H.mind.transfer_to(animal)
	log_effect(animal, "was transformed into a simplemob")
	var/obj/effect/smoke/smoke = new /obj/effect/smoke(get_turf(H))
	smoke.time_to_live = 1
	qdel(H)

/// ------- Scramble damage

/datum/random_reagent_effect/scramble_damage
	name = "Scramble damage"
	activation_chance = 10
	investigative_log = "-- scramble damage "

/datum/random_reagent_effect/scramble_damage/on_human_life_zeroth(mob/living/carbon/human/H)
	if(!(H.status_flags&GODMODE))
		var/damage_msg = "[H.getBruteLoss()]/[H.getOxyLoss()]/[H.getToxLoss()]/[H.getFireLoss()]/[H.getCloneLoss()]"
		var/damage_budget = H.getOxyLoss() + H.getToxLoss() + H.getCloneLoss()
		H.setOxyLoss(0)
		H.setToxLoss(0)
		H.setCloneLoss(0)
		for(var/datum/organ/external/O in H.organs)
			if(O.is_organic() && O.is_existing())
				damage_budget += O.brute_dam + O.burn_dam
				O.brute_dam = O.burn_dam = 0

		while(damage_budget>0)
			var/damage_amount = rand(max(damage_budget, 1))
			var/proc_tocall = pick("adjustBruteLoss", "adjustOxyLoss", "adjustToxLoss", "adjustFireLoss", "adjustCloneLoss")
			// This is le silly.
			call(H, proc_tocall)(damage_amount)
			damage_budget -= damage_amount
		damage_msg += " to [H.getBruteLoss()]/[H.getOxyLoss()]/[H.getToxLoss()]/[H.getFireLoss()]/[H.getCloneLoss()]"
		log_effect(H, "had their damage scrambled ([damage_msg])")


/// ------- Hallucination

/datum/random_reagent_effect/hallucination
	name = "Hallucination"
	activation_chance = 10
	var/total_hallucination_damage

/datum/random_reagent_effect/hallucination/on_pick()
	var/generator/rand = generator("num", 10, 0.2, LINEAR_RAND)
	var/value_rng = rand.Rand()
	total_hallucination_damage = value_rng
	investigative_log = "-- does hallucination damage for [total_hallucination_damage]"

/datum/random_reagent_effect/hallucination/on_human_life(mob/living/carbon/human/H)
	H.hallucination += total_hallucination_damage
