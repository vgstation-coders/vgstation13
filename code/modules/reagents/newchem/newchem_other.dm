#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

/datum/reagent/oil
	name = "Oil"
	id = "oil"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/stable_plasma
	name = "Stable Plasma"
	id = "stable_plasma"
	description = "Non-flammable plasma locked into a liquid form that cannot ignite or become gaseous/solid."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/iodine
	name = "Iodine"
	id = "iodine"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/carpet
	name = "Carpet"
	id = "carpet"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/carpet/reaction_turf(var/turf/simulated/T, var/volume)
	if(istype(T, /turf/simulated/floor/) && !istype(T, /turf/simulated/floor/carpet))
		var/turf/simulated/floor/F = T
		F.visible_message("[T] gets a layer of carpeting applied!")
		F.ChangeTurf(/turf/simulated/floor/carpet)
	..()
	return

/datum/reagent/bromine
	name = "Bromine"
	id = "bromine"
	description = "A slippery solution."
	reagent_state = GAS
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/phenol
	name = "Phenol"
	id = "phenol"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/ash
	name = "Ash"
	id = "ash"
	description = "Ashes to ashes, dust to dust."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/acetone
	name = "Acetone"
	id = "acetone"
	description = "A solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/acetone
	name = "acetone"
	id = "acetone"
	result = "acetone"
	required_reagents = list("oil" = 1, "fuel" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/carpet
	name = "carpet"
	id = "carpet"
	result = "carpet"
	required_reagents = list("space_drugs" = 1, "blood" = 1)
	result_amount = 2


/datum/chemical_reaction/oil
	name = "Oil"
	id = "oil"
	result = "oil"
	required_reagents = list("fuel" = 1, "carbon" = 1, "hydrogen" = 1)
	result_amount = 3

/datum/chemical_reaction/phenol
	name = "phenol"
	id = "phenol"
	result = "phenol"
	required_reagents = list("water" = 1, "chlorine" = 1, "oil" = 1)
	result_amount = 3

/datum/chemical_reaction/ash
	name = "Ash"
	id = "ash"
	result = "ash"
	required_reagents = list("oil" = 1)
	result_amount = 1
	required_temp = 480

/datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	id = "colorful_reagent"
	description = "A solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	var/list/potential_colors = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")

/datum/chemical_reaction/colorful_reagent
	name = "colorful_reagent"
	id = "colorful_reagent"
	result = "colorful_reagent"
	required_reagents = list("stable_plasma" = 1, "radium" = 1, "space_drugs" = 1, "cryoxadone" = 1, "triple_citrus" = 1)
	result_amount = 5

/datum/reagent/colorful_reagent/on_mob_life(var/mob/living/M as mob)
	if(M && isliving(M))
		M.color = pick(potential_colors)
	..()
	return

/datum/reagent/colorful_reagent/reaction_mob(var/mob/living/M, var/volume)
	if(M && isliving(M))
		M.color = pick(potential_colors)
	..()
	return
/datum/reagent/colorful_reagent/reaction_obj(var/obj/O, var/volume)
	if(O)
		O.color = pick(potential_colors)
	..()
	return
/datum/reagent/colorful_reagent/reaction_turf(var/turf/T, var/volume)
	if(T)
		T.color = pick(potential_colors)
	..()
	return


/datum/reagent/triple_citrus
	name = "Triple Citrus"
	id = "triple_citrus"
	description = "A solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/triple_citrus
	name = "triple_citrus"
	id = "triple_citrus"
	result = "triple_citrus"
	required_reagents = list("lemonjuice" = 1, "limejuice" = 1, "orangejuice" = 1)
	result_amount = 5

/datum/reagent/corn_starch
	name = "Corn Starch"
	id = "corn_starch"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/corn_syrup
	name = "corn_syrup"
	id = "corn_syrup"
	result = "corn_syrup"
	required_reagents = list("corn_starch" = 1, "sacid" = 1)
	result_amount = 5
	required_temp = 374

/datum/reagent/corn_syrup
	name = "Corn Syrup"
	id = "corn_syrup"
	description = "Decays into sugar."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/corn_syrup/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.reagents.add_reagent("sugar", 3)
	M.reagents.remove_reagent("corn_syrup", 1)
	..()
	return

/datum/chemical_reaction/corgium
	name = "corgium"
	id = "corgium"
	result = "corgium"
	required_reagents = list("nutriment" = 1, "colorful_reagent" = 1, "strange_reagent" = 1, "blood" = 1)
	result_amount = 3
	required_temp = 374

/datum/reagent/corgium
	name = "Corgium"
	id = "corgium"
	description = "Creates a corgi at the reaction location."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/corgium/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /mob/living/simple_animal/corgi(location)
	..()
	return

/datum/reagent/hair_dye
	name = "Quantum Hair Dye"
	id = "hair_dye"
	description = "A solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/hair_dye
	name = "hair_dye"
	id = "hair_dye"
	result = "hair_dye"
	required_reagents = list("colorful_reagent" = 1, "radium" = 1, "space_drugs" = 1)
	result_amount = 5

/datum/reagent/hair_dye/on_mob_life(var/mob/living/M as mob)
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.r_hair = rand(0,255)
		H.g_hair = rand(0,255)
		H.b_hair = rand(0,255)
		H.r_facial = rand(0,255)
		H.g_facial = rand(0,255)
		H.b_facial = rand(0,255)
		H.update_hair()
	..()
	return

/datum/reagent/hair_dye/reaction_mob(var/mob/living/M, var/volume)
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.r_hair = rand(0,255)
		H.g_hair = rand(0,255)
		H.b_hair = rand(0,255)
		H.r_facial = rand(0,255)
		H.g_facial = rand(0,255)
		H.b_facial = rand(0,255)
		H.update_hair()
	..()
	return

/datum/reagent/barbers_aid
	name = "Barber's Aid"
	id = "barbers_aid"
	description = "A solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/barbers_aid
	name = "barbers_aid"
	id = "barbers_aid"
	result = "barbers_aid"
	required_reagents = list("carpet" = 1, "radium" = 1, "space_drugs" = 1)
	result_amount = 5

/datum/reagent/barbers_aid/reaction_mob(var/mob/living/M, var/volume)
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/sprite_accessory/hair/picked_hair = random_hair_style(M.gender, "Human")
		var/datum/sprite_accessory/facial_hair/picked_beard = random_facial_hair_style(M.gender, "Human")
		H.h_style = picked_hair
		H.f_style = picked_beard
		H.update_hair()
	..()
	return

/datum/reagent/concentrated_barbers_aid
	name = "Concentrated Barber's Aid"
	id = "concentrated_barbers_aid"
	description = "A concentrated solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/concentrated_barbers_aid
	name = "concentrated_barbers_aid"
	id = "concentrated_barbers_aid"
	result = "concentrated_barbers_aid"
	required_reagents = list("barbers_aid" = 1, "mutagen" = 1)
	result_amount = 2

/datum/reagent/concentrated_barbers_aid/reaction_mob(var/mob/living/M, var/volume)
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.h_style = "Very Long Hair"
		H.f_style = "Very Long Beard"
		H.update_hair()
	..()
	return

/datum/reagent/untable_mutagen
	name = "Untable Mutagen"
	id = "untable_mutagen"
	description = "A solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/untable_mutagen
	name = "untable_mutagen"
	id = "untable_mutagen"
	result = "untable_mutagen"
	required_reagents = list("liquid_dark_matter" = 1, "iron" = 1, "mutagen" = 1)
	result_amount = 3

/datum/reagent/untable_mutagen/reaction_obj(var/obj/O, var/volume)
	if(istype(O, /obj/structure/table))
		O.visible_message("<span class = 'notice'>[O] melts into goop!</span>")
		new/obj/item/trash/candle(O.loc)
		qdel(O)
	..()
	return