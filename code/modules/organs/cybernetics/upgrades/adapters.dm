//Enhancers are used to bring a cybernetic organ to a higher tier

/obj/item/cybernetics/enhancer
	name = "cybernetic limb enhancer"
	var/tier = 1 //What tier the enhancer will work on

/obj/item/cybernetics/enhancer/New()
	..()
	name = "[name] Tier [tier]"

/obj/item/cybernetics/enhancer/apply(var/obj/item/O, mob/user)
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


				if(1)
					I.organ_tier = 2

