
#define EFFECT_TOUCH 0
#define EFFECT_AURA 1
#define EFFECT_PULSE 2
#define MAX_EFFECT 2

#define TRIGGER_TOUCH 0
#define TRIGGER_WATER 1
#define TRIGGER_ACID 2
#define TRIGGER_VOLATILE 3
#define TRIGGER_TOXIN 4
#define TRIGGER_FORCE 5
#define TRIGGER_ENERGY 6
#define TRIGGER_HEAT 7
#define TRIGGER_COLD 8
#define TRIGGER_PLASMA 9
#define TRIGGER_OXY 10
#define TRIGGER_CO2 11
#define TRIGGER_NITRO 12
#define MAX_TRIGGER 12
/*
//sleeping gas appears to be bugged, currently
var/list/valid_primary_effect_types = list(\
	/datum/artifact_effect/cellcharge,\
	/datum/artifact_effect/celldrain,\
	/datum/artifact_effect/forcefield,\
	/datum/artifact_effect/gasoxy,\
	/datum/artifact_effect/gasplasma,\
/*	/datum/artifact_effect/gassleeping,\*/
	/datum/artifact_effect/heal,\
	/datum/artifact_effect/hurt,\
	/datum/artifact_effect/emp,\
	/datum/artifact_effect/teleport,\
	/datum/artifact_effect/robohurt,\
	/datum/artifact_effect/roboheal)

var/list/valid_secondary_effect_types = list(\
	/datum/artifact_effect/cold,\
	/datum/artifact_effect/badfeeling,\
	/datum/artifact_effect/cellcharge,\
	/datum/artifact_effect/celldrain,\
	/datum/artifact_effect/dnaswitch,\
	/datum/artifact_effect/emp,\
	/datum/artifact_effect/gasco2,\
	/datum/artifact_effect/gasnitro,\
	/datum/artifact_effect/gasoxy,\
	/datum/artifact_effect/gasplasma,\
/*	/datum/artifact_effect/gassleeping,\*/
	/datum/artifact_effect/goodfeeling,\
	/datum/artifact_effect/heal,\
	/datum/artifact_effect/hurt,\
	/datum/artifact_effect/radiate,\
	/datum/artifact_effect/roboheal,\
	/datum/artifact_effect/robohurt,\
	/datum/artifact_effect/sleepy,\
	/datum/artifact_effect/stun,\
	/datum/artifact_effect/teleport)
	*/

/obj/machinery/artifact
	name = "alien artifact"
	desc = "A large alien device."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "ano00"
	var/icon_num = 0
	density = 1
	var/datum/artifact_effect/my_effect
	var/datum/artifact_effect/secondary_effect
	var/being_used = 0
	var/contained = 0
	var/artifact_id = ""
	anchored = 0

/obj/machinery/artifact/New(location, find_id)
	..()
	if(find_id)
		artifact_id = find_id
	else
		artifact_id = "[pick("kappa","sigma","antaeres","beta","omicron","iota","epsilon","omega","gamma","delta","tau","alpha")]-[rand(100,999)]"

	//setup primary effect - these are the main ones (mixed)
	var/effecttype = pick(typesof(/datum/artifact_effect) - /datum/artifact_effect)
	my_effect = new effecttype(src)
	my_effect.artifact_id = "[artifact_id]a"
	src.investigation_log(I_ARTIFACT, "|| spawned with a primary effect [my_effect.artifact_id]: [my_effect] || range: [my_effect.effectrange] || charge time: [my_effect.chargelevelmax] || trigger: [my_effect.trigger].")

	//75% chance to have a secondary stealthy (and mostly bad) effect
	if(prob(75))
		effecttype = pick(typesof(/datum/artifact_effect) - /datum/artifact_effect)
		secondary_effect = new effecttype(src)
		secondary_effect.artifact_id = "[artifact_id]b"
		src.investigation_log(I_ARTIFACT, "|| spawned with a secondary effect [secondary_effect.artifact_id]: [secondary_effect] || range: [secondary_effect.effectrange] || charge time: [secondary_effect.chargelevelmax] || trigger: [secondary_effect.trigger].")
		if(prob(75))
			src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id] starts triggered by default.")
			secondary_effect.ToggleActivate(2)

	icon_num = rand(0,11)
	icon_state = "ano[icon_num]0"
	if(icon_num == 7 || icon_num == 8)
		name = "large crystal"
		desc = pick("It shines faintly as it catches the light.",\
		"It appears to have a faint inner glow.",\
		"It seems to draw you inward as you look it at.",\
		"Something twinkles faintly as you look at it.",\
		"It's mesmerizing to behold.")
		if(prob(50))
			my_effect.trigger = TRIGGER_ENERGY
	else if(icon_num == 9)
		name = "alien computer"
		desc = "It is covered in strange markings."
		if(prob(75))
			my_effect.trigger = TRIGGER_TOUCH
	else if(icon_num == 10)
		desc = "A large alien device, there appear to be some kind of vents in the side."
		if(prob(50))
			my_effect.trigger = rand(6,12)
	else if(icon_num == 11)
		name = "sealed alien pod"
		desc = "A strange alien device."
		if(prob(25))
			my_effect.trigger = rand(1,4)

#define TRIGGER_PLASMA 9
#define TRIGGER_OXY 10
#define TRIGGER_CO2 11
#define TRIGGER_NITRO 12

/obj/machinery/artifact/process()

	var/turf/L = loc
	if(isnull(L) || !istype(L)) 	// We're inside a container or on null turf, either way stop processing effects
		return

	if(my_effect && !contained)
		my_effect.process()
	if(secondary_effect && !contained)
		secondary_effect.process()

	if(pulledby)
		if(!Adjacent(pulledby)) //Not actually next to them
			if(pulledby.pulling == src)
				pulledby.stop_pulling()
			pulledby = null
		else if(pulledby.incapacitated()) //To prevent getting stuck stunned forever due to not being able to break the pull.
			if(pulledby.pulling == src)
				pulledby.stop_pulling()
			pulledby = null
		else
			Bumped(pulledby)

	//if either of our effects rely on environmental factors, work that out
	var/trigger_cold = 0
	var/trigger_hot = 0
	var/trigger_plasma = 0
	var/trigger_oxy = 0
	var/trigger_co2 = 0
	var/trigger_nitro = 0
	if( (my_effect.trigger >= TRIGGER_HEAT && my_effect.trigger <= TRIGGER_NITRO) || (my_effect.trigger >= TRIGGER_HEAT && my_effect.trigger <= TRIGGER_NITRO) )
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/env = T.return_air()
		if(env)
			if(env.temperature < 225)
				trigger_cold = 1
			else if(env.temperature > 375)
				trigger_hot = 1

			if(env.toxins >= 10)
				trigger_plasma = 1
			if(env.oxygen >= 10)
				trigger_oxy = 1
			if(env.carbon_dioxide >= 10)
				trigger_co2 = 1
			if(env.nitrogen >= 10)
				trigger_nitro = 1

	//COLD ACTIVATION
	if(trigger_cold)
		if(my_effect.trigger == TRIGGER_COLD && !my_effect.activated)
			src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by COLD([my_effect.trigger]).")
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_COLD && !secondary_effect.activated)
			src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by COLD([secondary_effect.trigger]).")
			secondary_effect.ToggleActivate(2)
	else
		if(my_effect.trigger == TRIGGER_COLD && my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_COLD && secondary_effect.activated)
			secondary_effect.ToggleActivate(2)

	//HEAT ACTIVATION
	if(trigger_hot)
		if(my_effect.trigger == TRIGGER_HEAT && !my_effect.activated)
			src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by HEAT([my_effect.trigger]).")
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_HEAT && !secondary_effect.activated)
			src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by HEAT([secondary_effect.trigger]).")
			secondary_effect.ToggleActivate(2)
	else
		if(my_effect.trigger == TRIGGER_HEAT && my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_HEAT && secondary_effect.activated)
			secondary_effect.ToggleActivate(2)

	//PLASMA GAS ACTIVATION
	if(trigger_plasma)
		if(my_effect.trigger == TRIGGER_PLASMA && !my_effect.activated)
			src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by PLASMA([my_effect.trigger]).")
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_PLASMA && !secondary_effect.activated)
			src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by PLASMA([secondary_effect.trigger]).")
			secondary_effect.ToggleActivate(2)
	else
		if(my_effect.trigger == TRIGGER_PLASMA && my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_PLASMA && secondary_effect.activated)
			secondary_effect.ToggleActivate(2)

	//OXYGEN GAS ACTIVATION
	if(trigger_oxy)
		if(my_effect.trigger == TRIGGER_OXY && !my_effect.activated)
			src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by O2([my_effect.trigger]).")
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_OXY && !secondary_effect.activated)
			src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by O2([secondary_effect.trigger]).")
			secondary_effect.ToggleActivate(2)
	else
		if(my_effect.trigger == TRIGGER_OXY && my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_OXY && secondary_effect.activated)
			secondary_effect.ToggleActivate(2)

	//CO2 GAS ACTIVATION
	if(trigger_co2)
		if(my_effect.trigger == TRIGGER_CO2 && !my_effect.activated)
			src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by CO2([my_effect.trigger]).")
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_CO2 && !secondary_effect.activated)
			src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by CO2([secondary_effect.trigger]).")
			secondary_effect.ToggleActivate(2)
	else
		if(my_effect.trigger == TRIGGER_CO2 && my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_CO2 && secondary_effect.activated)
			secondary_effect.ToggleActivate(2)

	//NITROGEN GAS ACTIVATION
	if(trigger_nitro)
		if(my_effect.trigger == TRIGGER_NITRO && !my_effect.activated)
			src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by N2([my_effect.trigger]).")
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_NITRO && !secondary_effect.activated)
			src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by N2([secondary_effect.trigger]).")
			secondary_effect.ToggleActivate(2)
	else
		if(my_effect.trigger == TRIGGER_NITRO && my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_NITRO && secondary_effect.activated)
			secondary_effect.ToggleActivate(2)

/obj/machinery/artifact/attack_hand(var/mob/user as mob)
	if(isobserver(user))
		to_chat(user, "<span class='rose'>Your ghostly hand goes right through!</span>")
		return
	if (get_dist(user, src) > 1)
		to_chat(user, "<span class='warning'>You can't reach [src] from here.</span>")
		return
	if(ishuman(user) && user:gloves)
		to_chat(user, "<b>You touch [src]</b> with your gloved hands, [pick("but nothing of note happens","but nothing happens","but nothing interesting happens","but you notice nothing different","but nothing seems to have happened")].")
		return

	src.add_fingerprint(user)

	if(my_effect.trigger == TRIGGER_TOUCH)
		to_chat(user, "<b>You touch [src].<b>")
		src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by TOUCH([my_effect.trigger]) || touched by [key_name(user)].")
		my_effect.ToggleActivate()
	else
		to_chat(user, "<b>You touch [src],</b> [pick("but nothing of note happens","but nothing happens","but nothing interesting happens","but you notice nothing different","but nothing seems to have happened")].")

	if(prob(25) && secondary_effect && secondary_effect.trigger == TRIGGER_TOUCH)
		src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by TOUCH([secondary_effect]) || touched by [key_name(user)].")
		secondary_effect.ToggleActivate(2)

	if (my_effect.effect == EFFECT_TOUCH)
		if (contained)
			my_effect.isolated = 1
			my_effect.Blocked()
			spawn(10 SECONDS)
				my_effect.isolated = 0
		else
			my_effect.DoEffectTouch(user)

	if(secondary_effect && secondary_effect.effect == EFFECT_TOUCH && secondary_effect.activated)
		if (contained)
			secondary_effect.isolated = 1
			secondary_effect.Blocked()
			spawn(10 SECONDS)
				secondary_effect.isolated = 0
		else
			secondary_effect.DoEffectTouch(user)

/obj/machinery/artifact/attackby(obj/item/weapon/W as obj, mob/living/user as mob)

	if (istype(W, /obj/item/weapon/reagent_containers/glass) && W.is_open_container() ||\
		istype(W, /obj/item/weapon/reagent_containers/dropper))
		if(W.reagents.has_reagent(HYDROGEN, 1) || W.reagents.has_reagent(WATER, 1))
			if(my_effect.trigger == TRIGGER_WATER)
				src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by WATER([my_effect.trigger]) || [W] || splashed by [key_name(user)].")
				my_effect.ToggleActivate()
			if(secondary_effect && secondary_effect.trigger == TRIGGER_WATER && prob(25))
				src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by WATER([secondary_effect.trigger]) || [W] || splashed by [key_name(user)].")
				secondary_effect.ToggleActivate(2)
		else if(W.reagents.has_reagent(SACID, 1) || W.reagents.has_reagent(PACID, 1) || W.reagents.has_reagent(DIETHYLAMINE, 1))
			if(my_effect.trigger == TRIGGER_ACID)
				src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by ACID([my_effect.trigger]) || [W] || splashed by [key_name(user)].")
				my_effect.ToggleActivate()
			if(secondary_effect && secondary_effect.trigger == TRIGGER_ACID && prob(25))
				src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by ACID([secondary_effect.trigger]) || [W] || splashed by [key_name(user)].")
				secondary_effect.ToggleActivate(2)
		else if(W.reagents.has_reagent(PLASMA, 1) || W.reagents.has_reagent(THERMITE, 1))
			if(my_effect.trigger == TRIGGER_VOLATILE)
				src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by VOLATILE([my_effect.trigger]) || [W] || splashed by [key_name(user)].")
				my_effect.ToggleActivate()
			if(secondary_effect && secondary_effect.trigger == TRIGGER_VOLATILE && prob(25))
				src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by VOLATILE([secondary_effect.trigger]) || [W] || splashed by [key_name(user)].")
				secondary_effect.ToggleActivate(2)
		else if(W.reagents.has_reagent(TOXIN, 1) || W.reagents.has_reagent(CYANIDE, 1) || W.reagents.has_reagent(AMATOXIN, 1) || W.reagents.has_reagent(NEUROTOXIN, 1))
			if(my_effect.trigger == TRIGGER_TOXIN)
				src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by TOXIN([my_effect.trigger]) || [W] || splashed by [key_name(user)].")
				my_effect.ToggleActivate()
			if(secondary_effect && secondary_effect.trigger == TRIGGER_TOXIN && prob(25))
				src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by TOXIN([secondary_effect.trigger]) || [W] || splashed by [key_name(user)].")
				secondary_effect.ToggleActivate(2)
	else if(istype(W,/obj/item/weapon/melee/baton) && W:status ||\
			istype(W,/obj/item/weapon/melee/energy) ||\
			istype(W,/obj/item/weapon/melee/cultblade) ||\
			istype(W,/obj/item/weapon/card/emag) ||\
			istype(W,/obj/item/device/multitool))
		if (my_effect.trigger == TRIGGER_ENERGY)
			src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by ENERGY([my_effect.trigger]) || [W] || energized by [key_name(user)].")
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_ENERGY && prob(25))
			src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by ENERGY([secondary_effect.trigger]) || [W] || energized by [key_name(user)].")
			secondary_effect.ToggleActivate(2)

	else if (istype(W,/obj/item/weapon/match) && W:lit ||\
			istype(W,/obj/item/weapon/weldingtool) && W:welding ||\
			istype(W,/obj/item/weapon/lighter) && W:lit)
		if(my_effect.trigger == TRIGGER_HEAT)
			src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by HEAT([my_effect.trigger]) || [W] || heated by [key_name(user)].")
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_HEAT && prob(25))
			src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by HEAT([secondary_effect.trigger]) || [W] || heated by [key_name(user)].")
			secondary_effect.ToggleActivate(2)
	else
		..()
		if (my_effect.trigger == TRIGGER_FORCE && W.force >= 10)
			src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by FORCE([my_effect.trigger]) || [W] || attacked by [key_name(user)].")
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_FORCE && prob(25))
			src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by FORCE([secondary_effect.trigger]) || [W] || attacked by [key_name(user)].")
			secondary_effect.ToggleActivate(2)

/obj/machinery/artifact/Bumped(M as mob|obj)
	..()
	if(istype(M,/obj))
		if(M:throwforce >= 10)
			if(my_effect.trigger == TRIGGER_FORCE)
				src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by THROW FORCE([my_effect.trigger]) || [M] || thrown by [key_name(usr)].")
				my_effect.ToggleActivate()
			if(secondary_effect && secondary_effect.trigger == TRIGGER_FORCE && prob(25))
				src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by THROW FORCE([secondary_effect.trigger]) || [M] || thrown by [key_name(usr)].")
				secondary_effect.ToggleActivate(2)
	else if(ishuman(M) && !istype(M:gloves,/obj/item/clothing/gloves))
		var/warn = 0

		if (my_effect.trigger == TRIGGER_TOUCH && prob(50))
			src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) accidentally triggered by TOUCH([my_effect.trigger]) || bumped by [key_name(M)].")
			my_effect.ToggleActivate()
			warn = 1
		if(secondary_effect && secondary_effect.trigger == TRIGGER_TOUCH && prob(25))
			src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) accidentally triggered by TOUCH([secondary_effect.trigger]) || bumped by [key_name(M)].")
			secondary_effect.ToggleActivate(2)
			warn = 1

		if (my_effect.effect == EFFECT_TOUCH && prob(50))
			if (contained)
				my_effect.isolated = 1
				my_effect.Blocked()
				spawn(10 SECONDS)
					my_effect.isolated = 0
			else
				my_effect.DoEffectTouch(M)
			warn = 1
		if(secondary_effect && secondary_effect.effect == EFFECT_TOUCH && secondary_effect.activated && prob(50))
			if (contained)
				secondary_effect.isolated = 1
				secondary_effect.Blocked()
				spawn(10 SECONDS)
					secondary_effect.isolated = 0
			else
				secondary_effect.DoEffectTouch(M)
			warn = 1

		if(warn)
			to_chat(M, "<b>You accidentally touch [src].<b>")
	..()

/obj/machinery/artifact/bullet_act(var/obj/item/projectile/P)
	if(istype(P,/obj/item/projectile/bullet) ||\
		istype(P,/obj/item/projectile/hivebotbullet))
		if(my_effect.trigger == TRIGGER_FORCE)
			src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by PROJECTILE([my_effect.trigger]) || [P] || fired by [key_name(P.firer)].")
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_FORCE && prob(25))
			src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by PROJECTILE([secondary_effect.trigger]) || [P] || fired by [key_name(P.firer)].")
			secondary_effect.ToggleActivate(2)
	else if(istype(P,/obj/item/projectile/beam) ||\
		istype(P,/obj/item/projectile/ion) ||\
		istype(P,/obj/item/projectile/energy))
		if(my_effect.trigger == TRIGGER_ENERGY)
			src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by BEAM([my_effect.trigger]) || [P] || fired by [key_name(P.firer)].")
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_ENERGY && prob(25))
			src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by BEAM([secondary_effect.trigger]) || [P] || fired by [key_name(P.firer)].")
			secondary_effect.ToggleActivate(2)

/obj/machinery/artifact/ex_act(severity)
	switch(severity)
		if(1.0)
			src.investigation_log(I_ARTIFACT, "|| blew up by EXPLOSION DAMAGE([severity]).")
			qdel(src)
		if(2.0)
			if (prob(50))
				src.investigation_log(I_ARTIFACT, "|| blew up by EXPLOSION DAMAGE([severity]).")
				qdel(src)
			else
				if(my_effect.trigger == TRIGGER_FORCE || my_effect.trigger == TRIGGER_HEAT)
					src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by EXPLOSION DAMAGE([severity]).")
					my_effect.ToggleActivate()
				if(secondary_effect && (secondary_effect.trigger == TRIGGER_FORCE || secondary_effect.trigger == TRIGGER_HEAT) && prob(25))
					src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by EXPLOSION DAMAGE([severity]).")
					secondary_effect.ToggleActivate(2)
		if(3.0)
			if (my_effect.trigger == TRIGGER_FORCE || my_effect.trigger == TRIGGER_HEAT)
				src.investigation_log(I_ARTIFACT, "|| primary effect [my_effect.artifact_id]([my_effect]) triggered by EXPLOSION DAMAGE([severity]).")
				my_effect.ToggleActivate()
			if(secondary_effect && (secondary_effect.trigger == TRIGGER_FORCE || secondary_effect.trigger == TRIGGER_HEAT) && prob(25))
				src.investigation_log(I_ARTIFACT, "|| secondary effect [secondary_effect.artifact_id]([secondary_effect]) triggered by EXPLOSION DAMAGE([severity]).")
				secondary_effect.ToggleActivate(2)
	return

/obj/machinery/artifact/Move()
	..()
	if(my_effect)
		my_effect.UpdateMove()
	if(secondary_effect)
		secondary_effect.UpdateMove()
