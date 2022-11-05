/datum/randomized_reagent
	var/brute = 0
	var/oxy   = 0
	var/tox   = 0
	var/fire  = 0
	var/clone = 0
	var/brain = 0
	var/hallucination = 0

	var/explode = 0

	var/kill        = FALSE
	var/tf_simpmob  = null
	var/tf_immerse  = FALSE
	var/tf_catbeast = FALSE

	var/scramble_damage = FALSE

/datum/randomized_reagent/New()
	. = ..()
	randomize()

/datum/randomized_reagent/proc/randomize()
	var/datum/log_controller/I = investigations[I_CHEMS]
	var/investigate_text = ""

	for(var/K in vars)
		if(issaved(vars[K]) && (vars[K] != initial(vars[K])))
			var/V = vars[K]
			if(isnull(V)) V = "null"
			if(isnum(V))  V = round(V, 0.1)
			investigate_text += " - [K] [V]"

	I.write("<small>[time_stamp()]</small> \ref[src] || Randomized <a href='?_src_=vars;Vars=\ref[src]'>[src]</a>[investigate_text]<br />")

/datum/randomized_reagent/all_effects/randomize()
	for(var/K in vars)
		if(issaved(vars[K]) && (vars[K] != initial(vars[K])))
			vars[K] = initial(vars[K])

	// Modifiers, do nothing on their own
	if(prob(8))
		explode = pick(
			1000; 1, // Just gibs
			 500; 2, // Small explosion
			 400; 3, // Breaches normal floor
			 100; 4, // Breaches reinforced floor
		)

	// Standard damage types
	var/generator/rng = generator("num", 10, 0.2, LINEAR_RAND) // Second numeric argument is more likely
	for(var/K in list("brute", "oxy", "tox", "fire", "clone", "brain"))
		var/P = (K!="clone")?15:1; // Room-temperature clone damage healing should be rare
		if(prob(P))
			vars[K] = rng.Rand()
			if(prob(80)) // Heal most of the time
				vars[K] = -vars[K]

	// Effects to discourage unethical testing by non-antags
	tf_immerse  = prob(4)   // Turn female humans into boring males
	kill        = prob(2)   // Instant death
	tf_catbeast = prob(0.5) // Transform into a catbeast

	if(prob(2)) // Transform into a simple animal
		tf_simpmob = pick(
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

			25; list( // Uncommon
				/mob/living/simple_animal/borer, /mob/living/simple_animal/puddi/happy,
				/mob/living/simple_animal/puddi/anger, /mob/living/simple_animal/spiderbot
			),
			1; list( // Dangerous
				/mob/living/simple_animal/amogusflash,
				/mob/living/simple_animal/hostile/asteroid/basilisk, /mob/living/simple_animal/hostile/asteroid/goldgrub,
				/mob/living/simple_animal/hostile/asteroid/goliath, /mob/living/simple_animal/hostile/asteroid/rockernaut,
				/mob/living/simple_animal/hostile/bear, /mob/living/simple_animal/hostile/carp,
				/mob/living/simple_animal/hostile/giant_spider/hunter, /mob/living/simple_animal/hostile/pitbull,
				/mob/living/simple_animal/slime, /mob/living/simple_animal/slime/adult
			),
			1; list( // You poor bastard
				/mob/living/simple_animal/hostile/retaliate/clown, /mob/living/simple_animal/hostile/retaliate/cluwne,
				/mob/living/simple_animal/hostile/retaliate/faguette, /mob/living/simple_animal/hostile/retaliate/mime
			),
		)

		if(islist(tf_simpmob))
			tf_simpmob = pick(tf_simpmob)

	// Misc
	scramble_damage = prob(5)
	if(prob(5))
		hallucination = rng.Rand()

	..()

/datum/randomized_reagent/proc/on_human_life(var/mob/living/carbon/human/H, var/tick)
	if(tick==0)
		on_human_life_zeroth(H)

	if(kill)
		H.death(explode)
		switch(explode)
			if(0)
				log_effect(H, "was killed instantly")
			if(1)
				log_effect(H, "was gibbed")
			if(2)
				log_effect(H, "exploded (small)")
				explosion(get_turf(H), 0, 0, 1, 3, whodunnit=H)
			if(3)
				log_effect(H, "exploded (medium)")
				explosion(get_turf(H), 0, 1, 3, 5, whodunnit=H)
			if(4 to INFINITY)
				log_effect(H, "exploded (large)")
				explosion(get_turf(H), 1, 3, 5, 7, whodunnit=H)
		return

	if(tf_simpmob)
		var/mob/living/simple_animal/S = new tf_simpmob(get_turf(H))
		S.name = get_first_word(H.name)
		S.real_name = get_first_word(H.real_name)
		S.flavor_text = H.flavor_text
		S.gender = H.gender
		S.desc = "Something is off about this one."
		S.faction = H.faction
		S.meat_type = H.meat_type
		S.attack_log = H.attack_log.Copy()
		H.reagents.trans_to(S.reagents, S.reagents.maximum_volume)

		S.health = 100
		S.maxHealth = 100
		S.stop_automated_movement = TRUE
		S.wander = FALSE
		S.speak_chance = 0
		S.can_breed = FALSE //No ERP allowed
		S.is_pet = FALSE //No ERP allowed

		H.Premorph()
		H.audible_scream()
		H.mind.transfer_to(S)
		log_effect(S, "was transformed into a simplemob")
		var/obj/effect/smoke/smoke = new /obj/effect/smoke(get_turf(H))
		smoke.time_to_live = 1
		if(explode)
			hgibs(get_turf(H), H.virus2, H.dna, H.species.flesh_color, H.species.blood_color, explode*explode)
		qdel(H)
		return

	if(tf_catbeast && !iscatbeast(H))
		H.set_species("Tajaran")
		H.regenerate_icons()
		H.emote("me", MESSAGE_HEAR, pick("meows", "mews"))
		playsound(H, 'sound/voice/catmeow.ogg', 100)
		log_effect(H, "was transformed into a catbeast")

	if(tf_immerse && isjusthuman(H) && H.gender != MALE)
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

	H.hallucination += hallucination
	H.adjustBruteLoss(brute*REM)
	H.adjustOxyLoss(oxy*REM)
	H.adjustToxLoss(tox*REM)
	H.adjustFireLoss(fire*REM)
	H.adjustCloneLoss(clone*REM)
	H.adjustBrainLoss(brain*REM)
	H.updatehealth()

/datum/randomized_reagent/proc/on_human_life_zeroth(var/mob/living/carbon/human/H)
	if(scramble_damage && !(H.status_flags&GODMODE))
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
			var/D = rand(max(damage_budget, 1))
			var/P = pick("adjustBruteLoss", "adjustOxyLoss", "adjustToxLoss", "adjustFireLoss", "adjustCloneLoss")
			call(H,P)(D)
			damage_budget -= D
		damage_msg += " to [H.getBruteLoss()]/[H.getOxyLoss()]/[H.getToxLoss()]/[H.getFireLoss()]/[H.getCloneLoss()]"
		log_effect(H, "had their damage scrambled ([damage_msg])")

/datum/randomized_reagent/proc/log_effect(var/mob/M, var/msg)
	M.attack_log += text("\[[time_stamp()]\]: <font color='orange'>[msg] (<a href='?_src_=vars;Vars=\ref[src]'>[src]</a>)</font>")
	log_attack("[M.name] ([M.ckey]) [msg] ([src] \ref[src])")
	msg_admin_attack("[M.name] ([M.ckey]) [msg] (<a href='?_src_=vars;Vars=\ref[src]'>RR</a>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>)")

var/list/datum/randomized_reagent/randomized_reagents = list()
/proc/create_randomized_reagents()
	randomized_reagents.Cut()
	randomized_reagents[SIMPOLINOL] = new /datum/randomized_reagent/all_effects
