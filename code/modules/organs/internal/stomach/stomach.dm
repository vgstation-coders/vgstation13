/*
Stomach organ, 'handles the food'

If removed, the owner has no real reservoir to hold chems in, let's say 50.

With a stomach, they have the regular 1000u limit

Better stomach, more room for food, or quicker metabolism of food


handle_regular_hud_updates
		if(nutrition_icon)
			switch(nutrition)
				if(450 to INFINITY)
					nutrition_icon.icon_state = "nutrition0"
				if(350 to 450)
					nutrition_icon.icon_state = "nutrition1"
				if(250 to 350)
					nutrition_icon.icon_state = "nutrition2"
				if(150 to 250)
					nutrition_icon.icon_state = "nutrition3"
				else
					nutrition_icon.icon_state = "nutrition4"

			if(ticker && ticker.hardcore_mode) //Hardcore mode: flashing nutrition indicator when starving!
				if(nutrition < STARVATION_MIN)
					nutrition_icon.icon_state = "nutrition5"


food/snacks.dm

			var/fullness = target.nutrition + (target.reagents.get_reagent_amount(NUTRIMENT) * 25) //This reminds me how unlogical mob nutrition is

			if(fullness <= 50)
				target.visible_message("<span class='notice'>[target] hungrily [eatverb]s some of \the [src] and gobbles it down!</span>", \
				"<span class='notice'>You hungrily [eatverb] some of \the [src] and gobble it down!</span>")
			else if(fullness > 50 && fullness < 150)
				target.visible_message("<span class='notice'>[target] hungrily [eatverb]s \the [src].</span>", \
				"<span class='notice'>You hungrily [eatverb] \the [src].</span>")
			else if(fullness > 150 && fullness < 350)
				target.visible_message("<span class='notice'>[target] [eatverb]s \the [src].</span>", \
				"<span class='notice'>You [eatverb] \the [src].</span>")
			else if(fullness > 350 && fullness < 550)
				target.visible_message("<span class='notice'>[target] unwillingly [eatverb]s some of \the [src].</span>", \
				"<span class='notice'>You unwillingly [eatverb] some of \the [src].</span>")

Chemistry-reagents.dm
#define FOOD_METABOLISM 0.4

*/

/datum/organ/internal/stomach
	name = "stomach"
	parent_organ = LIMB_CHEST
	removed_type = /obj/item/organ/stomach
	var/max_reagents = 1000
	var/food_metabolism = 0.4
	var/fullness
	var/max_fullness = 550

/datum/organ/internal/stomach/process()
	if(is_bruised())
		if(prob(((damage-min_bruised_damage)/min_broken_damage)*100))
			owner.vomit()
	var/mob/living/carbon/human/H = owner
	if(H.reagents.maximum_volume != max_reagents)
		H.reagents.maximum_volume = max_reagents

/datum/organ/internal/stomach/remove()
	var/mob/living/carbon/human/H = owner
	H.reagents.clear_reagents()
	H.reagents.maximum_volume = 50
	..()

/datum/organ/internal/stomach/adv_room
	name = "bluespace stomach"
	max_reagents = 2000
	food_metabolism = 0.8
	max_fullness = 750
	robotic=2

/datum/organ/internal/stomach/adv_chem
	name = "transmutation membrane"
	robotic=2
	var/chem_cost = 25
	var/chem_max_amount = 10
	var/chem = PEPTOBISMOL

/datum/organ/internal/stomach/adv_chem/process()
	var/mob/living/carbon/human/H=owner
	if(!is_bruised() && H.nutrition >= chem_cost+200 && (H.reagents.get_reagent_amount(chem) < chem_max_amount)) //200 is the middleground for nutrition being slightly hungry
		H.reagents.add_reagent(chem, 1)

	..()

	/*
			CURRENT PROBLEM:
				Removing the stomach doesn't properly remove the stomach. It's still in there
	*/