/* Swapped for new charcoal in newchem_medicine.dm - Iamgoofball

var/global/list/charcoal_doesnt_remove=list(
	"charcoal",
	"blood"
)

/datum/reagent/charcoal
	//data must contain virus type
	name = "Activated Charcoal"
	id = "charcoal"
	reagent_state = LIQUID
	color = "#333333" // rgb: 200, 16, 64

/datum/reagent/charcoal/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom

	if(ishuman(M) && prob(5))
		var/mob/living/carbon/human/H=M
		H.vomit()
		holder.remove_reagent("charcoal",volume) // Remove all charcoal.
		return

	for(var/datum/reagent/reagent in holder.reagent_list)
		if(reagent.id in charcoal_doesnt_remove)
			continue
		holder.remove_reagent(reagent.id, 3*REM)

	M.adjustToxLoss(-2*REM)
	..()
	return

*/

/datum/reagent/muhhardcores
	name = "Hardcores"
	id = "bustanut"
	description = "Concentrated hardcore beliefs."
	reagent_state = LIQUID
	color = "#FFF000"
	custom_metabolism = 0.01

/datum/reagent/muhhardcores/on_mob_life(var/mob/living/M)
	if(prob(1))
		if(prob(90))
			M << "<span class='notice'>[pick("You feel quite hardcore","Coderbased is your god", "Fucking kickscammers Bustration will be the best")]."
		else
			M.say(pick("Muh hardcores.", "Falling down is a feature", "Gorrillionaires and Booty Borgs when?"))
	..()
	return