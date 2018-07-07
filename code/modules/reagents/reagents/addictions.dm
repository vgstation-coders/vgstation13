#define TICK_ADDICTION_REMINDER 50

/datum/addiction
	var/name = "addiction"
	var/tick //Tick goes up if you're not satiating your addiction, Tick goes down if you're satiating it
	var/addiction = "memes" //Holds the reagent ID for whatever reagent you're addicted to, or reagent type if you want it to be covered by a subtype
	var/mob/living/holder //The person with this addiction
	var/addiction_multiplier = 1 //A way to simulate addictions getting 'worse' over time. As time goes by, this will increase, so you will need more of a chem. Can be used by addiction effects for greater effect
	var/list/addiction_effects = list() //What effects this addiction will have on the holder. Organized as list(tick_to_trigger = effect)

/datum/addiction/New(var/mob/living/new_holder, var/addicted)
	..()
	if(new_holder)
		holder = new_holder
		holder.addictions[addicted] = src
	if(addicted)
		addiction = addicted

/datum/addiction/Destroy()
	if(holder)
		holder.addictions.Remove(src)
		holder = null
	if(addiction_effects)
		for(var/datum/addiction_effect/E in addiction_effects)
			qdel(E)
		addiction_effects = null
	..()

/datum/addiction/proc/add_effect(var/datum/addiction_effect/E, var/tick_trigger)
	addiction_effects[tick_trigger] = E

/datum/addiction/proc/add_random_effects()
	var/list/effects_to_choose = subtypesof(/datum/addiction_effect)
	for(var/i = 0 to rand(2,5))
		var/chosen_effect = pick(effects_to_choose)
		var/datum/addiction_effect/AE = new chosen_effect
		effects_to_choose.Remove(AE.type)
		add_effect(AE, AE.recommended_tick_trigger + (AE.recommended_tick_trigger/100)*rand(10,-10))



/datum/addiction/proc/handle_addiction()
	if(holder.reagents && istype(addiction, /datum/reagent)?holder.reagents.has_reagent_type(addiction, 1*addiction_multiplier):holder.reagents.has_reagent(addiction, 1*addiction_multiplier))
		tick = max(0, tick-1)
		if(prob(30))
			addiction_multiplier+=rand(1,3)/rand(10,30)
		return
	tick++
	handle_withdrawal()

/datum/addiction/proc/handle_withdrawal()
	if(tick > TICK_ADDICTION_REMINDER)
		to_chat(holder, "<span class = 'warning'>You need more [addiction]!</span>")
	for(var/a in addiction_effects)
		if(tick < a)
			var/datum/addiction_effect/A = addiction_effects[a]
			if(prob(A.activation_prob*(tick/a)))
				A.trigger(holder)

/datum/addiction_effect
	var/recommended_tick_trigger = 100 //What the tick trigger should be in add_random_effects(), +/- 10%
	var/activation_prob = 30 //What probability the effect will trigger. This increases as the tick count goes above the tick trigger

/datum/addiction_effect/proc/trigger(mob/living/victim)
	to_chat(victim, "<span class = 'warning'>You suck.</span>")

/datum/addiction_effect/brain_damage/minor
	recommended_tick_trigger = 150

/datum/addiction_effect/brain_damage/minor/trigger(mob/living/victim)
	victim.adjustBrainLoss(rand(1,3))

/datum/addiction_effect/brain_damage
	recommended_tick_trigger = 280

/datum/addiction_effect/brain_damage/trigger(mob/living/victim)
	victim.adjustBrainLoss(rand(3,10))

/datum/addiction_effect/twitch/trigger(mob/living/victim)
	victim.say("*twitch_s")

/datum/addiction_effect/vomit
	recommended_tick_trigger = 100
	activation_prob = 10

/datum/addiction_effect/vomit/trigger(mob/living/victim)
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		H.vomit()

/datum/addiction_effect/increased_metabolism
	recommended_tick_trigger = 120

/datum/addiction_effect/increased_metabolism/trigger(mob/living/victim)
	victim.nutrition-=rand(1,3)/rand(2,10)

/datum/addiction_effect/hallucination/minor
	recommended_tick_trigger = 70
	activation_prob = 25

/datum/addiction_effect/hallucination/minor/trigger(mob/living/victim)
	victim.hallucination += rand(1,10)

/datum/addiction_effect/hallucination
	recommended_tick_trigger = 200

/datum/addiction_effect/hallucination/trigger(mob/living/victim)
	victim.hallucination += rand(3,30)

/datum/addiction_effect/headache/trigger(mob/living/victim)
	to_chat(victim, "<span class = '[pick("notice","warning")]'>[pick("Your head hurts [pick("a bit","a lot","")]","Your head is agonizing!","<b>MAKE IT STOP!</b>")].</span>")