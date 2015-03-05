#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

/datum/reagent/clf3
	name = "Chlorine Trifluoride"
	id = "clf3"
	description = "Makes a temporary 3x3 fireball when it comes into existence, so be careful when mixing. ClF3 applied to a surface burns things that wouldn't otherwise burn, sometimes through the very floors of the station and exposing it to the vacuum of space."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132

/datum/chemical_reaction/clf3
	name = "Chlorine Trifluoride"
	id = "clf3"
	required_reagents = list("chlorine" = 1, "fluorine" = 3)
	min_temperature = 424
	results = list("clf3" = 4)

/datum/reagent/clf3/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjust_fire_stacks(20)
	M.IgniteMob()
	M.adjustFireLoss(5*REM)
	..()
	return

/datum/chemical_reaction/clf3/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	for(var/turf/simulated/turf in range(1,T))
		new /obj/fire(turf)
	holder.chem_temp = 1000 // hot as shit
	return

/datum/reagent/clf3/reaction_turf(var/turf/simulated/T, var/volume)
	if(istype(T, /turf/simulated/floor/))
		var/turf/simulated/floor/F = T
		if(prob(volume/10))
			F.make_plating()
		if(prob(volume/20))
			F.ChangeTurf(/turf/space)
		if(istype(F, /turf/simulated/floor/))
			new /obj/fire(F)
	if(istype(T, /turf/simulated/wall/))
		var/turf/simulated/wall/W = T
		if(prob(volume/10))
			W.ChangeTurf(/turf/simulated/floor)
	if(istype(T, /turf/simulated/floor/plating))
		var/turf/simulated/floor/plating/F = T
		if(prob(volume/20))
			F.ChangeTurf(/turf/space)
	return

/datum/reagent/clf3/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(method == TOUCH && ishuman(M))
		M.adjust_fire_stacks(20)
		M.IgniteMob()
		new /obj/fire(M.loc)
		return


/datum/reagent/sorium
	name = "Sorium"
	id = "sorium"
	description = "Sends everything flying from the detonation point."
	reagent_state = LIQUID
	color = "#60A584"  //rgb: 96, 165, 132

/datum/chemical_reaction/sorium
	name = "Sorium"
	id = "sorium"
	required_reagents = list("mercury" = 1, "oxygen" = 1, "nitrogen" = 1, "carbon" = 1)
	min_temperature = 474
	results = list("sorium" = 4)

/datum/reagent/sorium/reaction_turf(var/turf/simulated/T, var/volume)
	if(istype(T, /turf/simulated/floor/))
		goonchem_vortex(T, 1, 5, 3)
/datum/reagent/sorium/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		var/turf/simulated/T = get_turf(M)
		goonchem_vortex(T, 1, 5, 3)


/datum/chemical_reaction/sorium/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	goonchem_vortex(T, 1, 5, 6)

/datum/reagent/liquid_dark_matter
	name = "Liquid Dark Matter"
	id = "liquid_dark_matter"
	description = "Sucks everything into the detonation point."
	reagent_state = LIQUID
	color = "#60A584"  //rgb: 96, 165, 132

/datum/chemical_reaction/liquid_dark_matter
	name = "Liquid Dark Matter"
	id = "liquid_dark_matter"
	required_reagents = list("stable_plasma" = 1, "radium" = 1, "carbon" = 1)
	min_temperature = 474
	results = list("liquid_dark_matter" = 3)

/datum/reagent/liquid_dark_matter/reaction_turf(var/turf/simulated/T, var/volume)
	if(istype(T, /turf/simulated/floor/))
		goonchem_vortex(T, 0, 5, 3)
		return
/datum/reagent/liquid_dark_matter/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		var/turf/simulated/T = get_turf(M)
		goonchem_vortex(T, 0, 5, 3)
		return
/datum/chemical_reaction/liquid_dark_matter/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	goonchem_vortex(T, 0, 5, 6)
	return


/proc/goonchem_vortex(var/turf/simulated/T, var/setting_type, var/range, var/pull_times)
	for(var/atom/movable/X in orange(range, T))
		if(istype(X, /obj/effect))
			continue  //stop pulling smoke and hotspots please
		if(istype(X, /atom/movable))
			if((X) && !X.anchored)
				if(setting_type)
					for(var/i = 0, i < pull_times, i++)
						step_away(X,T)
				else
					for(var/i = 0, i < pull_times, i++)
						step_towards(X,T)


/datum/reagent/blackpowder
	name = "Black Powder"
	id = "blackpowder"
	description = "Explodes. Violently."
	reagent_state = LIQUID
	color = "#000000"  //rgb: 96, 165, 132
	custom_metabolism = 0.05

/datum/chemical_reaction/blackpowder
	name = "Black Powder"
	id = "blackpowder"
	required_reagents = list("saltpetre" = 1, "charcoal" = 1, "sulfur" = 1)
	results = list("blackpowder" = 3)

/datum/chemical_reaction/blackpowder_explosion
	name = "Black Powder Kaboom"
	id = "blackpowder_explosion"
	required_reagents = list("blackpowder" = 1)
	min_temperature = 474
	results = list(null = 1)

/datum/chemical_reaction/blackpowder_explosion/on_reaction(var/datum/reagents/holder, var/created_volume)
	holder.my_atom.visible_message("<span class = 'userdanger'>Sparks come out of [holder.my_atom]!</span>")
	sleep(rand(10,30))
	var/turf/simulated/T = get_turf(holder.my_atom)
	var/ex_severe = round(created_volume / 10)
	var/ex_heavy = round(created_volume / 8)
	var/ex_light = round(created_volume / 6)
	var/ex_flash = round(created_volume / 4)
	if(ex_severe > 3)
		ex_severe = 3
	if(ex_heavy > 7)
		ex_severe = 7
	if(ex_light > 14)
		ex_severe = 14
	explosion(T,ex_severe,ex_heavy,ex_light,ex_flash, 1, 1)
	return

