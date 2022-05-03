//Luckiness-related defines

#define LUCKINESS_DRAINRATE 0.2 //How much temporary (un)luck or luck dissipates per Life() tick
#define LUCKINESS_WHEN_HELD (1<<0) //The item confers (un)luck when held in the hand. Also includes surgically implanted items.
#define LUCKINESS_WHEN_WORN (1<<1)	//The item confers (un)luck when worn in an inventory slot other than the hands.
#define LUCKINESS_WHEN_HELD_RECURSIVE (1<<2) //The item confers (un)luck when held in the hand directly or inside something else being held in the hand.
#define LUCKINESS_WHEN_WORN_RECURSIVE (1<<3) //The item confers (un)luck when worn or inside something else being worn, but not held in the hand.
#define LUCKINESS_WHEN_GENERAL (LUCKINESS_WHEN_HELD | LUCKINESS_WHEN_WORN) //The item confers (un)luck when directly held in the hand or worn in an inventory slot.
#define LUCKINESS_WHEN_GENERAL_RECURSIVE (LUCKINESS_WHEN_HELD_RECURSIVE | LUCKINESS_WHEN_WORN_RECURSIVE) //The item confers (un)luck when held in the hand or worn directly, or inside something else being held in the hand or worn.

//Luckiness and unluckiness

/mob/proc/luck()
	var/luck = 0
	if(base_luck)
		luck += base_luck.base_luck()
	//Adjust based on borne items
	luck += borne_item_luckiness()
	return luck

/mob
	var/datum/luckiness/base_luck

/mob/proc/luck_adjust(var/luckchange, var/temporary = FALSE)
	if(!base_luck)
		base_luck = new /datum/luckiness
	if(temporary)
		base_luck.temporary_luckiness += luckchange
	else
		base_luck.permanent_luckiness += luckchange

/mob/proc/borne_item_luckiness() //Check all inventory items for (un)luckiness.
	var/total_item_luckiness = 0
	var/list/equipped_items = get_equipped_items()
	while(null in equipped_items)
		equipped_items -= null
	var/list/held_or_implanted_items = contents - equipped_items
	//check hand slot items and implanted items
	if(held_or_implanted_items.len)
		for(var/i in 1 to held_or_implanted_items.len)
			var/obj/item/thisitem = held_or_implanted_items[i]
			if(thisitem.luckiness_validity & (LUCKINESS_WHEN_HELD | LUCKINESS_WHEN_HELD_RECURSIVE) && thisitem.luckiness)
				total_item_luckiness += thisitem.luckiness
			//check hand slot and implanted item contents recursively
			if(thisitem.contents.len)
				var/list/thisitemscontents = thisitem.contents
				var/j = 1
				while(j <= thisitemscontents.len)
					var/obj/item/thiscontent = thisitemscontents[j]
					if(thiscontent.contents.len)
						thisitemscontents += thiscontent.contents
					j += 1
				for(var/k in 1 to thisitemscontents.len)
					var/obj/item/thisitemscontent = thisitemscontents[k]
					if(thisitemscontent.luckiness_validity & LUCKINESS_WHEN_HELD_RECURSIVE && thisitemscontent.luckiness)
						total_item_luckiness += thisitemscontent.luckiness
	//check worn items directly
	if(equipped_items.len)
		for(var/i in 1 to equipped_items.len)
			var/obj/item/thisitem = equipped_items[i]
			if(thisitem.luckiness_validity & (LUCKINESS_WHEN_WORN | LUCKINESS_WHEN_WORN_RECURSIVE) && thisitem.luckiness)
				total_item_luckiness += thisitem.luckiness
				//check worn item contents recursively
			if(thisitem.contents.len)
				var/list/thisitemscontents = thisitem.contents
				var/j = 1
				while(j <= thisitemscontents.len)
					var/obj/item/thiscontent = thisitemscontents[j]
					if(thiscontent.contents.len)
						thisitemscontents += thiscontent.contents
					j += 1
				for(var/k in 1 to thisitemscontents.len)
					var/obj/item/thisitemscontent = thisitemscontents[k]
					if(thisitemscontent.luckiness_validity & LUCKINESS_WHEN_WORN_RECURSIVE && thisitemscontent.luckiness)
						total_item_luckiness += thisitemscontent.luckiness
	return total_item_luckiness

/datum/luckiness
	var/permanent_luckiness = 0
	var/temporary_luckiness = 0
	var/list/blesscurse = list() //List of blessings and curses.

/datum/luckiness/proc/base_luck()
	var/base_luck = permanent_luckiness + temporary_luckiness
	if(blesscurse.len)
		for(var/i in 1 to blesscurse.len)
			var/datum/blesscurse/this_blesscurse = blesscurse[i]
			base_luck += this_blesscurse.blesscurse_strength
	return base_luck

/mob/proc/add_blesscurse(var/datum/blesscurse/ourblesscurse)
	if(!base_luck)
		base_luck = new /datum/luckiness
	if(has_blesscurse(ourblesscurse)) //can only have one instance of each type of blessing or curse.
		return
	base_luck.blesscurse += ourblesscurse

/mob/proc/remove_blesscurse(var/datum/blesscurse/ourblesscurse)
	if(!base_luck)
		return
	base_luck.blesscurse -= ourblesscurse

/mob/proc/has_blesscurse(var/datum/blesscurse/ourblesscurse)
	if(!base_luck)
		return FALSE
	if(base_luck.blesscurse.len)
		for(var/i in 1 to base_luck.blesscurse.len)
			if(istype(base_luck.blesscurse[i], ourblesscurse))
				return TRUE
	else
		return FALSE

/datum/blesscurse
	var/blesscurse_name //string; name of the blessing or curse
	var/blesscurse_strength //number; how much luck (+) or unluck (-) the blessing or curse confers.

//Modify a probability in the range [0,100] based on luck.
/mob/proc/lucky_probability(var/baseprob = 50, var/luckfactor = 1)
	//Get our luck and scale it by the luckfactor:
	var/ourluck = luck() * luckfactor
	if(ourluck == 0 || baseprob == 0 || baseprob == 100)
		return baseprob
	//Asymptotically clamp it to between -50 and 50 using hyperbolic tangent:
	ourluck = 50 * clamp(((E ** ourluck) - (E ** (-1* ourluck))) / ((E ** ourluck) + (E ** (-1* ourluck))), -1, 1)
	//Skew the probabiliity by "pulling" the unbiased (50 input probability, 50 output probability) point towards either (0, 100) - maximally lucky, or (100, 0) - maximally unlucky.
	//This is done by shifting a point P from (50, 50) a distance of (sqrt(2) * ourluck) along the line running through (0, 100) and (100, 0), and then fitting a polynomial to (0, 0), P, and (100,100).
	//The coordinates of P are (50 - ourluck, 50 + ourluck):
	var/P_i = 50 - ourluck
	var/P_o = 50 + ourluck
	if(P_o == 100 || P_o == 0)
		return P_o
	//The polynomial running though (0, 0), P, and (100, 100) is:
	var/newprob = (-1 * P_o * (baseprob ** 2) / (100 * (100 - P_i))) - (P_o * (baseprob ** 2) / (100 * P_i)) + (P_i * P_o * baseprob / (100 * (100 - P_i))) + (P_o * baseprob / P_i) + ((baseprob ** 2) / (100 - P_i)) - (P_i * baseprob / (100 - P_i)) + (P_o * baseprob / 100)
	//Clamp it to the range [0, 100] to avoid precision-based excursions:
	newprob = clamp(newprob, 0, 100)
	return newprob

//todo:

	//[TEST] slowly reduce temporary (un)luck on life tick
	//clovers, hold or eat
	//[DONE] broke a mirror
	//[DONE] lucky items surgically implanted or inside the body?
	//[DONE] test recursion and in general
	//[DONE] pocket mirrors?

	//clover seeds, sprites, test
	//only one of each blesscurse type active at once?
	//edge cases breaking mirrors with explosives or otherwise
	//finish clover mechanics and sprites


	//Curses:
	//[DONE] breaking a mirror
	//spilling salt from a container

	//Lucky items:
	//lucky 4 leaf clovers when held
	//eat clover for a temporary luck boost
	//unlucky 2 leaf clovers

	//Luck affects:
	//surgery sucess/failures
	//[DONE] scratch cards
	//slots
	//tripping rate with long hair
	//shuttle kicking
	//breaking bones when hit
	//randomly getting a disease chance
	//[DONE] russian roulette
	//very bad luck increases midround threat?
	//very good luck decreases midround threat?
	//calling coin flips and die rolls.
	//singularity attraction/repulsion?
	//plant breeding/clover breeding?
	//luck-conferring mojo reagent