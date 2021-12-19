#define FILLET_MEAT 1
#define FILLET_SKIN 2
#define FILLET_TEETH 3
#define FILLET_OTHER 4

/obj/item/weapon/fillet_knife
	name = "fillet knife"
	desc = "An extremely sharp and relatively thin knife used by space anglers. Designed to pierce between scales both in and out of combat."
	icon =
	icon_state =
	force = 5.0
	throwforce = 5.0
	sharpness = 1.5
	origin_tech = Tc_COMBAT + "=2"
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = W_CLASS_SMALL
	attack_verb = list("slashes", "stabs", "slices", "cuts", "fillets")
	armor_penetration = 25
	var/baseDamage = 5
	var/simpleBonus = 10
	var/butcherMode = FILLET_MEAT

/obj/item/weapon/fillet_knife/attack(mob/living/M, mob/living/user)
	if(isanimal(M))
		force = baseDamage + simpleBonus
	else if(istype(M, /mob/living/simple_animal/hostile/fishing))
		force = baseDamage*2 + simpleBonus
	..()

/obj/item/weapon/fillet_knife/afterattack(atom/target, mob/user)
	force = baseDamage
	..()

/obj/item/weapon/fillet_knife/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(isliving(target))
		var/mob/living/M = target
		if(M.stat == DEAD)
			quickButcher(M, user)
	..()

/obj/item/weapon/fillet_knife/proc/quickButcher(var/mob/living/bTarget, mob/user)
	if(!bTarget.butcherCheck(user, src))
		return
	bTarget.being_butchered = TRUE
	var/list/bData = bTarget.butcherValueStep(user)
	switch(butcherMode)
		if(FILLET_MEAT)
			if(do_after(bTime SECONDS))
				var/bTime = (bTarget.size * 20) / bData[1]
				bTarget.butcherMeat(user, bData[3])
		if(FILLET_SKIN)
			if(do_after()) //custom proc thing etc
				for(var/datum/butchering_product/skin/S in bTarget.butchering_drops)
					if(S.amount)
						bTarget.butcherProduct(user, S)
		if(FILLET_TEETH)
			if(do_after()) //custom proc thing etc
				for(var/datum/butchering_product/teeth/T in bTarget.butchering_drops)
					if(S.amount)
						bTarget.butcherProduct(user, T)
		if(FILLET_OTHER)
			if(do_after())
				for(var/datum/butchering_product/BP in bTarget.butchering_drops)
					if(istype(BP, /datum/butchering_product/skin) || istype(BP, /datum/butchering_product/teeth))
						continue
					if(BP.amount)
						bTarget.butcherProduct(user, BP)
						break

/obj/item/weapon/fillet_knife/proc/swapMode(mob/user)
	if(butcherMode < 4)
		butcherMode++
	else
		butcherMode = 1
	var/butcherChat = butcherExplain()
	to_chat(user, "<span class='info'>[butcherChat]</span>")

/obj/item/weapon/fillet_knife/proc/butcherExplain()
	var/bE = "No butcher priority."	//This should never be seen
	switch(butcherMode)
		if(FILLET_MEAT)
			bE = "Meat will now be butchered first."
		if(FILLET_SKIN)
			bE = "Skin will now be butchered first."
		if(FILLET_TEETH)
			bE = "Teeth will now be removed first."
		if(FILLET_OTHER)
			bE = "Unique products will now be harvested first."
	return bE
