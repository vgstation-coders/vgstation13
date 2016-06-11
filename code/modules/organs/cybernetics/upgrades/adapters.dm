//Enhancers are used to bring a cybernetic organ to a higher tier

/obj/item/cybernetics/enhancer
	name = "cybernetic limb enhancer"
	var/tier = 1 //What tier the enhancer will work on

/obj/item/cybernetics/enhancer/New()
	..()
	name = "[name] Tier [tier]"

/obj/item/cybernetics/enhancer/apply(var/obj/item/O)
	if(istype(O, obj/item/organ))
		var/currentTier = O.organTier
		if(currentTier >= tier)
			to_chat(usr, "\the [src]'s tier is lower or equal that of \the [O]'s tier.")
			return
		else if(tier = currentTier + 1)
			//This is so hacky
			switch(currentTier)
				if(0)
					O.organTier = 1

				if(1)
					O.organTier = 2

