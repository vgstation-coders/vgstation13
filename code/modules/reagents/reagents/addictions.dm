#define TICK_ADDICTION_REMINDER 50

/datum/addiction
	var/name = "addiction"
	var/tick //Tick goes up if you're not satiating your addiction, Tick goes down if you're satiating it
	var/addiction = "memes" //Holds the ID for whatever reagent you're addicted to
	var/mob/holder
	var/addiction_multiplier = 1
	var/list/addiction_effects = list() //What effects this addiction will have on the holder. Organized as list(tick_to_trigger = effect)

/datum/addiction/New(var/mob/new_holder, var/addicted)
	..()
	if(new_holder)
		holder = new_holder
	if(addicted)
		addiction = addicted

/datum/addiction/Destroy()
	if(holder)
		holder = null
	if(addiction_effects)
		for(var/datum/addiction_effect/E in addiction_effects)
			addiction_effects.Remove(E)
			qdel(E)
	..()

/datum/addiction/proc/handle_addiction()
	if(holder.reagents && holder.reagents.has_reagent(addiction, 1*addiction_multiplier))
		tick = max(0, tick--)
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
			var/datum/addiction_effect/E = addiction_effects[a]
			E.trigger(holder)

/datum/addiction_effect

/datum/addiction_effect/proc/trigger(mob/victim)
	to_chat(victim, "<span class = 'warning'>You suck.</span>")