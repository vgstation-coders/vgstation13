
/datum/reagent/oxygen
	name = "Oxygen"
	id = "oxygen"
	description = "A colorless, odorless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

	custom_metabolism = 0.01

/datum/reagent/oxygen/on_mob_life(var/mob/living/M as mob, var/alien)

	if(!holder) return
	if(M.stat == 2) return
	if(alien && alien == IS_VOX)
		M.adjustToxLoss(REAGENTS_METABOLISM)
		holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
		return
	..()

/datum/reagent/copper
	name = "Copper"
	id = "copper"
	description = "A highly ductile metal."
	color = "#6E3B08" // rgb: 110, 59, 8

	custom_metabolism = 0.01

/datum/reagent/nitrogen
	name = "Nitrogen"
	id = "nitrogen"
	description = "A colorless, odorless, tasteless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

	custom_metabolism = 0.01

/datum/reagent/nitrogen/on_mob_life(var/mob/living/M as mob, var/alien)

	if(!holder) return
	if(M.stat == 2) return
	if(alien && alien == IS_VOX)
		M.adjustOxyLoss(-2*REM)
		M.adjustToxLoss(-2*REM)
		holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
		return
	..()

/datum/reagent/hydrogen
	name = "Hydrogen"
	id = "hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

	custom_metabolism = 0.01

/datum/reagent/potassium
	name = "Potassium"
	id = "potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = SOLID
	color = "#A0A0A0" // rgb: 160, 160, 160

	custom_metabolism = 0.01

/datum/reagent/mercury
	name = "Mercury"
	id = "mercury"
	description = "A chemical element."
	reagent_state = LIQUID
	color = "#484848" // rgb: 72, 72, 72
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/mercury/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5)) M.emote(pick("twitch","drool","moan"))
	M.adjustBrainLoss(2)
	..()
	return

/datum/reagent/sulfur
	name = "Sulfur"
	id = "sulfur"
	description = "A chemical element with a pungent smell."
	reagent_state = SOLID
	color = "#BF8C00" // rgb: 191, 140, 0

	custom_metabolism = 0.01

/datum/reagent/carbon
	name = "Carbon"
	id = "carbon"
	description = "A chemical element, the builing block of life."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0

	custom_metabolism = 0.01

/datum/reagent/carbon/reaction_turf(var/turf/T, var/volume)
	src = null
	// Only add one dirt per turf.  Was causing people to crash.
	if(!istype(T, /turf/space) && !(locate(/obj/effect/decal/cleanable/dirt) in T))
		new /obj/effect/decal/cleanable/dirt(T)

/datum/reagent/chlorine
	name = "Chlorine"
	id = "chlorine"
	description = "A chemical element with a characteristic odour."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/chlorine/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.take_organ_damage(1*REM, 0)
	..()
	return


/datum/reagent/sodium
	name = "Sodium"
	id = "sodium"
	description = "A chemical element, readily reacts with water."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128

	custom_metabolism = 0.01

/datum/reagent/phosphorus
	name = "Phosphorus"
	id = "phosphorus"
	description = "A chemical element, the backbone of biological energy carriers."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40

	custom_metabolism = 0.01

/datum/reagent/lithium
	name = "Lithium"
	id = "lithium"
	description = "A chemical element, used as antidepressant."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/lithium/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5)) M.emote(pick("twitch","drool","moan"))
	..()
	return



/datum/reagent/iron
	name = "Iron"
	id = "iron"
	description = "Pure iron is a metal."
	reagent_state = SOLID
	color = "#C8A5DC" // rgb: 200, 165, 220
/*
/datum/reagent/iron/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if((M.virus) && (prob(8) && (M.virus.name=="Magnitis")))
		if(M.virus.spread == "Airborne")
			M.virus.spread = "Remissive"
		M.virus.stage--
		if(M.virus.stage <= 0)
			M.resistances += M.virus.type
			M.virus = null
	holder.remove_reagent(src.id, 0.2)
	return
*/


/datum/reagent/gold
	name = "Gold"
	id = "gold"
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48

/datum/reagent/silver
	name = "Silver"
	id = "silver"
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208

/datum/reagent/uranium
	name ="Uranium"
	id = "uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192

/datum/reagent/uranium/on_mob_life(var/mob/living/M as mob)

	if(!holder) return
	if(!M) M = holder.my_atom
	M.apply_effect(1,IRRADIATE,0)
	..()
	return


/datum/reagent/uranium/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 3)
		if(!istype(T, /turf/space))
			new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/aluminum
	name = "Aluminum"
	id = "aluminum"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168

/datum/reagent/silicon
	name = "Silicon"
	id = "silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168