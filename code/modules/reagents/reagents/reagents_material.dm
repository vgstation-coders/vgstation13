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
	specheatcap = 124

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
		if(prob(15))
			T.mutate(GENE_BIOLUMINESCENCE)
			T.reagents.remove_reagent(id, 1)
	else if(amount > 0)
		T.reagents.remove_reagent(id, amount)
