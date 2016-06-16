//Enhancers are used to bring a cybernetic organ to a higher tier

/obj/item/cybernetics/enhancer
	name = "cybernetic limb enhancer"
	var/tier = 1 //What tier the enhancer will work on

/obj/item/cybernetics/enhancer/New()
	..()
	name = "[name] Tier [tier]"

/obj/item/cybernetics/enhancer/apply(var/obj/item/organ/O, var/datum/organ/organ, mob/user)
	if(istype(O, /obj/item/organ))
		var/obj/item/organ/I = O
		var/current_tier = I.organ_tier
		if(current_tier >= tier)
			to_chat(user, "\the [src]'s tier is lower or equal that of \the [O]'s tier.")
			return
		else if(tier == current_tier + 1)
			//This is so hacky
			switch(current_tier)
				if(0)
					I.organ_tier = 1
					I.reload_slots(0,1)
				if(1)
					I.organ_tier = 2
					I.reload_slots(1,2)
				if(2)
					I.organ_tier = 3
					I.reload_slots(2,2)
				if(3)
					I.organ_tier = 4
					I.reload_slots(4,4)
			to_chat(user, "\the [src]'s tier has been succesfully upgraded to [tier].")

