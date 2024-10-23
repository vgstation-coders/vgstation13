//Reagents that handle physical construction materials like glass, iron, diamond, etc

/datum/reagent/diamond
	name = "Diamond Dust"
	id = DIAMONDDUST
	description = "An allotrope of carbon, one of the hardest minerals known."
	reagent_state = REAGENT_STATE_SOLID
	color = "#C4D4E0" //196 212 224
	density = 3.51
	specheatcap = 6.57

/datum/reagent/diamond/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(isgolem(M)) //golems metabolize the diamond into very expensive doctor's delight
		if(M.getOxyLoss())
			M.adjustOxyLoss(-2)
		if(M.getBruteLoss())
			M.heal_organ_damage(2, 0)
		if(M.getFireLoss())
			M.heal_organ_damage(0, 2)
		if(M.getToxLoss())
			M.adjustToxLoss(-2)
		if(M.dizziness != 0)
			M.dizziness = max(0, M.dizziness - 15)
		if(M.confused != 0)
			M.remove_confused(5)
	else
		M.adjustBruteLoss(5 * REM) //Not a good idea to eat crystal powder
		if(prob(30))
			M.audible_scream()

/datum/reagent/gold
	name = "Gold Powder"
	id = GOLD
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = REAGENT_STATE_SOLID
	color = "#F7C430" //rgb: 247, 196, 48
	specheatcap = 0.129
	density = 19.3

/datum/reagent/iron
	name = "Iron"
	id = IRON
	description = "Pure iron in powdered form, a metal."
	reagent_state = REAGENT_STATE_SOLID
	color = "#666666" //rgb: 102, 102, 102
	specheatcap = 0.45
	density = 7.874

/datum/reagent/phazon
	name = "Phazon Salt"
	id = PHAZON
	description = "The properties of this rare metal are not well-known."
	reagent_state = REAGENT_STATE_SOLID
	color = "#5E02F8" //rgb: 94, 2, 248
	dupeable = FALSE

/datum/reagent/phazon/New()
	..()
	density = rand(1,250)/rand(1,35)
	specheatcap = rand(1,250)/rand(1,35)

/datum/reagent/phazon/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.apply_radiation(5, RAD_INTERNAL)
	if(prob(20))
		M.advanced_mutate()

/datum/reagent/phazon/reaction_animal(var/mob/living/M)
	on_mob_life(M)

/datum/reagent/plasma
	name = "Plasma"
	id = PLASMA
	description = "Plasma in its liquid form."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#500064" //rgb: 80, 0, 100
	fission_time=18000 //5 hours.
	fission_absorbtion=8333.333

/datum/reagent/plasma/New()
	..()
	specheatcap = rand(1,150)/rand(1,25)
	density = rand(1,150)/rand(1,25)

/datum/reagent/plasma/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	var/mob/living/carbon/human/H = M
	if(istype(H) && H.species.flags & PLASMA_IMMUNE)
		return 1
	else
		M.adjustToxLoss(3 * REM)
	if(holder.has_reagent("inaprovaline"))
		holder.remove_reagent("inaprovaline", 2 * REM)

/datum/reagent/plasticide
	name = "Plasticide"
	id = PLASTICIDE
	description = "Liquid plastic, do not eat."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#CF3600" //rgb: 207, 54, 0
	custom_metabolism = 0.01
	density = 0.4
	specheatcap = 1.67

/datum/reagent/plasticide/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	//Toxins are really weak, but without being treated, last very long
	M.adjustToxLoss(0.2)

/datum/reagent/silicate
	name = "Silicate"
	id = SILICATE
	description = "A compound that can be used to repair and reinforce glass."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C7FFFF" //rgb: 199, 255, 255
	overdose_am = 0
	density = 0.69
	specheatcap =  0.59

/datum/reagent/silver
	name = "Silver Powder"
	id = SILVER
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = REAGENT_STATE_SOLID
	color = "#D0D0D0" //rgb: 208, 208, 208
	specheatcap = 0.24
	density = 10.49

/datum/reagent/uranium
	name ="Uranium salt"
	id = URANIUM
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = REAGENT_STATE_SOLID
	color = "#B8B8C0" //rgb: 184, 184, 192
	density = 19.05
	specheatcap = 0.124
	fission_time=9000 //2.5 hours.
	fission_power=16666.667

/datum/reagent/uranium/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	M.apply_radiation(1, RAD_INTERNAL)

/datum/reagent/uranium/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	if(volume >= 3)
		if(!(locate(/obj/effect/decal/cleanable/greenglow) in T))
			new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/uranium/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	if(!holder)
		return
	if(!T)
		T = holder.my_atom //Try to find the mob through the holder
	if(!istype(T)) //Still can't find it, abort
		return
	var/amount = T.reagents.get_reagent_amount(id)
	if(amount >= 1)
		if(prob(30))
			T.mutate(GENE_BIOLUMINESCENCE)
			if(prob(50))
				T.reagents.remove_reagent(id, 1)
	else if(amount > 0)
		T.reagents.remove_reagent(id, amount)

//----------------------------------------------------------------------------------------------------

/datum/reagent/wax
	name = "Wax Powder"
	id = WAX
	description = "Wax that has been grinded into a powder form. Its colour may change from the surrounding pigments."
	color = "#FFB700"
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	density = 0.84
	specheatcap = 2.1
	data = list(
		"color" = "#FFB700",
		)

/datum/reagent/wax/handle_data_mix(var/list/added_data=null, var/added_volume, var/mob/admin)
	var/base_color = data["color"]
	var/added_color = base_color
	if (added_data)
		added_color = added_data["color"]
	data["color"] = BlendRYB(added_color, base_color, added_volume / (added_volume+volume))
	color = data["color"]

/datum/reagent/wax/handle_data_copy(var/list/added_data=null, var/added_volume, var/mob/admin)
	if (added_data)
		data["color"] = added_data["color"]
		color = data["color"]

/datum/reagent/wax/special_behaviour()
	var/list/pigments = list()
	for (var/datum/reagent/R in holder.reagent_list)
		if (R.id == BLEACH)
			data["color"] = "#FFFFFF"
			color = data["color"]
			return
		else if (R.flags & CHEMFLAG_PIGMENT)
			pigments += R
	if (pigments.len <= 0)
		return
	var/target_color = mix_color_from_reagents(pigments)
	if (data["color"] == "#FFFFFF")//if you bleach the wax first, it's easier to dye
		data["color"] = target_color
	else
		data["color"] = BlendRYB(data["color"], target_color, 0.5)
	color = data["color"]

/datum/reagent/wax/handle_additional_data(var/list/additional_data=null)
	if ("color" in additional_data)
		data["color"] = additional_data["color"]
		color = data["color"]



//TODO: give these an effect.
/datum/reagent/plutonium
	name ="Plutonium"
	id = PLUTONIUM
	description = "A silvery-white metallic chemical element in the actinide series, very radioactive."
	reagent_state = REAGENT_STATE_SOLID
	color = "#CACAD2" //rgb: 202, 202, 210
	density = 19.85
	specheatcap = 0.124
	fission_time=4500 //1.25 hours.
	fission_power=66666.67 //spooky
	
/datum/reagent/plutonium/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.apply_radiation(4, RAD_INTERNAL)

/datum/reagent/radon
	name ="Radon"
	id = RADON
	description = "A colorless, odorless, highly radioactive noble gas."
	reagent_state = REAGENT_STATE_GAS
	color = "#808080" //rgb: 128, 128, 128
	density = 9.73
	specheatcap = 0.936
	custom_metabolism = 1 //decays really fast, so it shouldn't linger long.
	fission_time=1500 //25 minutes.
	fission_power=1666.6666
	
/datum/reagent/radon/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.apply_radiation(7.5, RAD_INTERNAL)


/datum/reagent/lead
	name ="Lead"
	id = LEAD
	description = "A dull grey metallic element and heavy metal. Ingestion leads to brain damage"
	reagent_state = REAGENT_STATE_SOLID
	color = "#676767" //rgb: 103, 103, 103
	density = 11.34
	specheatcap = 0.129
	
/datum/reagent/lead/on_mob_life(var/mob/living/M) //less potent mercury
	if(..())
		return 1
	M.adjustBrainLoss(1)


/datum/reagent/thallium
	name ="Thallium"
	id = THALLIUM
	description = "A silvery-grey metallic chemical element in the post-transition metal series. Toxic when touched, ingested, or inhaled. Very difficult to remove from the body once exposed."
	reagent_state = REAGENT_STATE_SOLID
	color = "#CACAD2" //rgb: 202, 202, 210
	density = 11.87
	custom_metabolism = 0.1
	flags = CHEMFLAG_NOTREMOVABLE
	specheatcap = 0.128

/datum/reagent/thallium/on_mob_life(var/mob/living/M) //the point of this is to be a nuisance. stays in you no matter what, but not really *that* deadly, just kind of annoying. You'd have to really piss someone off to get a mouthfull of this.
	if(..())
		return 1
	M.adjustToxLoss(0.5)
