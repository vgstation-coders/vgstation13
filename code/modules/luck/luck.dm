///////Luck///////

//Every mob has a certain amount of luck, defaulting to a neutral value of 0.
//Luck can be affected by blessings or curses, or by bearing lucky or unlucky items.
//Luck can also be permanently or temporarily given to a mob itself through various means.
//A mob's luck can affect the outcomes of various probabilistic events involving that mob.

//Returns a mob's luckiness.
/mob/proc/luck()
	var/luck = 0
	if(base_luck)
		luck += base_luck.base_luck()
	//adjust based on borne items
	luck += borne_item_luckiness()
	if(Holiday == FRIDAY_THE_13TH)
		luck -= 250
	return luck

/mob
	var/datum/luckiness/base_luck

//Stores the factors that contribute to a mob's base luckiness.
	//permanent_luckiness: Remains constant unless modified via luck_adjust().
	//temporary_luckiness: Gradually decreases in magnitude according to LUCKINESS_DRAINFACTOR.
	//blesscurse: List of blessings and curses: see luck_blesscurse.dm.
/datum/luckiness
	var/permanent_luckiness = 0
	var/temporary_luckiness = 0
	var/list/blesscurse = list()

//Returns a mob's base luckiness.
/datum/luckiness/proc/base_luck()
	var/base_luck = permanent_luckiness + temporary_luckiness
	if(blesscurse.len)
		for(var/datum/blesscurse/this_blesscurse in blesscurse)
			base_luck += this_blesscurse.blesscurse_strength
	return base_luck

//Add a blessing or curse to a mob.
/mob/proc/add_blesscurse(var/datum/blesscurse/ourblesscurse)
	if(!base_luck)
		base_luck = new /datum/luckiness
	if(has_blesscurse(ourblesscurse)) //can only have one instance of each type of blessing or curse
		return
	base_luck.blesscurse += ourblesscurse

//Remove a blessing or curse from a mob.
/mob/proc/remove_blesscurse(var/datum/blesscurse/ourblesscurse)
	if(!base_luck)
		return
	base_luck.blesscurse -= ourblesscurse

//Check if a mob has a given type of blessing or curse.
/mob/proc/has_blesscurse(var/datum/blesscurse/ourblesscurse)
	if(!base_luck)
		return FALSE
	if(base_luck.blesscurse.len)
		for(var/i in 1 to base_luck.blesscurse.len)
			if(ispath(base_luck.blesscurse[i], ourblesscurse))
				return TRUE
	else
		return FALSE

//Alters a mob's base luckiness.
/mob/proc/luck_adjust(var/luckchange, var/temporary = FALSE)
	if(!base_luck)
		base_luck = new /datum/luckiness
	if(temporary)
		base_luck.temporary_luckiness += luckchange
	else
		base_luck.permanent_luckiness += luckchange

//Returns the total luckiness of all items held or worn by the mob. Items confer luckiness in different inventory locations according to their luckiness_validity flags: see setup.dm.
/mob/proc/borne_item_luckiness() //Check all inventory items for (un)luckiness.
	var/total_item_luckiness = 0
	var/list/equipped_items = get_equipped_items()
	while(null in equipped_items)
		equipped_items -= null
	var/list/held_or_implanted_items = contents - equipped_items
	//check hand slot items and implanted items
	if(held_or_implanted_items.len)
		for(var/obj/item/thisitem in held_or_implanted_items)
			if(thisitem.luckiness_validity & (LUCKINESS_WHEN_HELD | LUCKINESS_WHEN_HELD_RECURSIVE) && thisitem.luckiness)
				total_item_luckiness += thisitem.luckiness
			//check hand slot and implanted item contents recursively
			if(thisitem.contents.len)
				var/list/thisitemscontents = thisitem.contents.Copy()
				var/j = 1
				while(j <= thisitemscontents.len)
					var/obj/item/thiscontent = thisitemscontents[j]
					if(thiscontent.contents.len)
						thisitemscontents += thiscontent.contents
					j += 1
				for(var/obj/item/thisitemscontent in thisitemscontents)
					if(thisitemscontent.luckiness_validity & LUCKINESS_WHEN_HELD_RECURSIVE && thisitemscontent.luckiness)
						total_item_luckiness += thisitemscontent.luckiness
	//check worn items directly
	if(equipped_items.len)
		for(var/obj/item/thisitem in  equipped_items)
			if(thisitem.luckiness_validity & (LUCKINESS_WHEN_WORN | LUCKINESS_WHEN_WORN_RECURSIVE) && thisitem.luckiness)
				total_item_luckiness += thisitem.luckiness
			//check worn item contents recursively
			if(thisitem.contents.len)
				var/list/thisitemscontents = thisitem.contents.Copy()
				var/j = 1
				while(j <= thisitemscontents.len)
					var/obj/item/thiscontent = thisitemscontents[j]
					if(thiscontent.contents.len)
						thisitemscontents += thiscontent.contents
					j += 1
				for(var/obj/item/thisitemscontent in thisitemscontents)
					if(thisitemscontent.luckiness_validity & LUCKINESS_WHEN_WORN_RECURSIVE && thisitemscontent.luckiness)
						total_item_luckiness += thisitemscontent.luckiness
	return total_item_luckiness

//Modify a probability in the range [0,100] based on luck.
	//baseprob: The base probability to be modified.
	//luckfactor: Related to how much the probability shifts towards 100% for every +1 luck. A negative luckfactor causes the shift to be towards 0% instead.
	//maxskew: The maximum influence luck can have on the outcome probability. At maxskew 0, there is no effect. At maxskew 50, the effect is maximal.
	//ourluck: Can set this to the mob's luck to avoid having to call luck() multiple times.
/mob/proc/lucky_probability(var/baseprob = 50, var/luckfactor = 1, var/maxskew = 50, var/ourluck)
	//Get our luck and scale it by the luckfactor:
	if(isnull(ourluck))
		ourluck = luck() * luckfactor
	else
		ourluck = ourluck * luckfactor
	if(ourluck == 0 || baseprob == 0 || baseprob == 100)
		return baseprob
	//Asymptotically clamp it to between -maxskew and maxskew using hyperbolic tangent:
	if(abs(ourluck) < 16)
		ourluck = clamp(((E ** ourluck) - (E ** (-1 * ourluck))) / ((E ** ourluck) + (E ** (-1 * ourluck))), -1, 1)
	//Avoid overflow:
	else if(ourluck > 0)
		ourluck = 1
	else
		ourluck = -1
	ourluck = clamp(maxskew, 0, 50) * ourluck
	//Skew the probability by pulling the unbiased (50 input probability, 50 output probability) point towards either (0, 100) - maximally lucky, or (100, 0) - maximally unlucky.
	//This is done by shifting a point P from (50, 50) a distance of (sqrt(2) * ourluck) along the line running through (0, 100) and (100, 0), and then linearly interpolating between (0, 0), P, and (100, 100).
	//The coordinates of P are (50 - ourluck, 50 + ourluck):
	var/P_i = 50 - ourluck
	var/P_o = 50 + ourluck
	if(P_o == 100 || P_o == 0)
		return P_o
	else if(P_i == 100 || P_i == 0)
		return P_i
	//The piecewise function passing through (0, 0), P, and (100, 100) is:
	var/newprob
	if(baseprob <= P_i)
		newprob = (P_o / P_i) * baseprob
	else
		newprob = 100 - (P_i / P_o) * (100 - baseprob)
	newprob = clamp(newprob, 0, 100)
	return newprob

//Calls prob() on lucky_probability(), for convenience.
/mob/proc/lucky_prob(var/baseprob = 50, var/luckfactor = 1, var/maxskew = 50, var/ourluck)
	return prob(lucky_probability(baseprob, luckfactor, maxskew, ourluck))
