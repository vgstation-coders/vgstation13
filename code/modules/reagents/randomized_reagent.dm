/// This gives a robust OOP framework for a reagent with a variety of random effects.
/datum/randomized_reagent

	/// Effects you always pick
	var/list/always_pick_effects = list()

	/// A list of all actual effects we have picked this time
	var/list/datum/random_reagent_effect/picked_effects = list()

/datum/randomized_reagent/New()
	. = ..()
	randomize()

/datum/randomized_reagent/proc/randomize()
	var/datum/log_controller/I = investigations[I_CHEMS]
	var/investigate_text = ""

	for (var/effect in always_pick_effects)
		var/datum/random_reagent_effect/the_effect = new effect

		// Check if the effect can be picked
		if (!the_effect.can_be_picked())
			continue

		the_effect.on_pick()
		picked_effects += the_effect
		investigate_text += the_effect.investigative_log

	I.write("<small>[time_stamp()]</small> \ref[src] || Randomized <a href='?_src_=vars;Vars=\ref[src]'>[src]</a>[investigate_text]<br />")


/datum/randomized_reagent/all_effects
	always_pick_effects = list(
		/datum/random_reagent_effect/explode,
		/datum/random_reagent_effect/simple_heal_damage,
		/datum/random_reagent_effect/kill,
		/datum/random_reagent_effect/tf_catbeast,
		/datum/random_reagent_effect/tf_inverse,
		/datum/random_reagent_effect/tf_simplemob,
		/datum/random_reagent_effect/hallucination,
		/datum/random_reagent_effect/scramble_damage,
	)

/datum/randomized_reagent/proc/on_human_life(var/mob/living/carbon/human/H, var/tick)
	if(tick==0)
		for (var/datum/random_reagent_effect/effect in picked_effects)
			effect.on_human_life_zeroth(H)

	for (var/datum/random_reagent_effect/effect in picked_effects)
		effect.on_human_life(H)

	H.updatehealth()

/datum/randomized_reagent/proc/log_effect(var/mob/M, var/msg)
	M.attack_log += text("\[[time_stamp()]\]: <font color='orange'>[msg] (<a href='?_src_=vars;Vars=\ref[src]'>[src]</a>)</font>")
	log_attack("[M.name] ([M.ckey]) [msg] ([src] \ref[src])")
	msg_admin_attack("[M.name] ([M.ckey]) [msg] (<a href='?_src_=vars;Vars=\ref[src]'>RR</a>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>)")

var/list/datum/randomized_reagent/randomized_reagents = list()

/proc/create_randomized_reagents()
	randomized_reagents.Cut()
	randomized_reagents[SIMPOLINOL] = new /datum/randomized_reagent/all_effects
