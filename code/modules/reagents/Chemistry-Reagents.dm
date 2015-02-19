#define SOLID 1
#define LIQUID 2
#define GAS 3
#define FOOD_METABOLISM 0.4
#define REAGENTS_OVERDOSE 30
#define REM REAGENTS_EFFECT_MULTIPLIER

//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.


/datum/reagent
	var/name = "Reagent"
	var/id = "reagent"
	var/description = ""
	var/datum/reagents/holder = null
	var/reagent_state = SOLID
	var/list/data = null
	var/volume = 0
	var/nutriment_factor = 0
	var/custom_metabolism = REAGENTS_METABOLISM
	//var/list/viruses = list()
	var/color = "#000000" // rgb: 0, 0, 0 (does not support alpha channels - yet!)
	var/overdose_threshold = 0
	var/addiction_threshold = 0
	var/addiction_stage = 0
	var/shock_reduction = 0
	var/overdosed = 0 // You fucked up and this is now triggering it's overdose_threshold effects, purge that shit quick.

/datum/reagent/proc/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
 //By default we have a chance to transfer some
	if(!istype(M, /mob/living))	return 0
	var/datum/reagent/self = src
	src = null										  //of the reagent to the mob on TOUCHING it.

	if(self.holder && !istype(self.holder.my_atom, /obj/effect/effect/smoke/chem))
		// If the chemicals are in a smoke cloud, do not try to let the chemicals "penetrate" into the mob's system (balance station 13) -- Doohl

		if(method == TOUCH)

			var/chance = 1
			var/block  = 0

			for(var/obj/item/clothing/C in M.get_equipped_items())
				if(C.permeability_coefficient < chance) chance = C.permeability_coefficient
				if(istype(C, /obj/item/clothing/suit/bio_suit))
					// bio suits are just about completely fool-proof - Doohl
					// kind of a hacky way of making bio suits more resistant to chemicals but w/e
					if(prob(75))
						block = 1

				if(istype(C, /obj/item/clothing/head/bio_hood))
					if(prob(75))
						block = 1

			chance = chance * 100

			if(prob(chance) && !block)
				if(M.reagents)
					M.reagents.add_reagent(self.id,self.volume/2)
	return 1

/datum/reagent/proc/reaction_obj(var/obj/O, var/volume) //By default we transfer a small part of the reagent to the object
	src = null						//if it can hold reagents. nope!
	//if(O.reagents)
	//	O.reagents.add_reagent(id,volume/3)
	return

/datum/reagent/proc/reaction_turf(var/turf/T, var/volume)
	src = null
	return

/datum/reagent/proc/on_mob_life(var/mob/living/M as mob, var/alien)
	if(!istype(M, /mob/living))
		return //Noticed runtime errors from pacid trying to damage ghosts, this should fix. --NEO

	if(!holder) return
	holder.remove_reagent(src.id, custom_metabolism) //By default it slowly disappears.
	return

/datum/reagent/proc/on_move(var/mob/M)
	return

// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new(var/data)
	return

// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(var/data)
	return

/datum/reagent/proc/on_update(var/atom/A)
	return

datum/reagent/proc/overdose_process(var/mob/living/M as mob)
	return

datum/reagent/proc/overdose_start(var/mob/living/M as mob)
	return

datum/reagent/proc/addiction_act_stage1(var/mob/living/M as mob)
	if(prob(30))
		M << "<span class = 'notice'>You feel like some [name] right about now.</span>"
	return

datum/reagent/proc/addiction_act_stage2(var/mob/living/M as mob)
	if(prob(30))
		M << "<span class = 'notice'>You feel like you need [name]. You just can't get enough.</span>"
	return

datum/reagent/proc/addiction_act_stage3(var/mob/living/M as mob)
	if(prob(30))
		M << "<span class = 'danger'>You have an intense craving for [name].</span>"
	return

datum/reagent/proc/addiction_act_stage4(var/mob/living/M as mob)
	if(prob(30))
		M << "<span class = 'userdanger'>You're not feeling good at all! You really need some [name].</span>"
	return

/datum/reagent/Destroy()
	if(istype(holder))
		holder.reagent_list -= src
		holder = null
	..()
