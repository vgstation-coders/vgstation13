#define MARTIANS_AMBIDEXTROUS //Comment out to prevent martians from being able to do multiple do_afters at once

//WORK IN PROGRESS - Martians (name may be changed)
//Like octopuses but with 6 hands

/*
 DESIGN:

 + tentacles provide better grasp than hands. Martians are more resistant to winds, disarms and other hazards that would stun a human
 + are ambidextrous

 * breathe oxygen and exhale CO2 like humans do

 - their unique shape means they can't fit into any human clothing, and can only put on hats
 - toxins are very dangerous to them

*/

/mob/living/carbon/martian
	name = "martian"
	desc = "An alien resembling an overgrown octopus."
	voice_name = "martian"

	icon = 'icons/mob/martian.dmi'
	icon_state = "martian"

	species_type = /mob/living/carbon/martian

	held_items = list(null, null, null, null, null, null) //6 hands

	unslippable = TRUE
	size = SIZE_BIG

	fire_dmi = 'icons/mob/OnFire.dmi'
	fire_sprite = "Standing"
	plane = HUMAN_PLANE

	maxHealth = 150
	health = 150

	//Inventory slots
	var/obj/item/head //hat

	var/icon_state_standing = "martian"
	var/icon_state_lying = "lying"
	var/icon_state_dead = "dead"

	var/flag = 0

/mob/living/carbon/martian/New()
	create_reagents(200)
	name = pick("martian","scootaloo","squid","rootmarian","phoronitian","sepiida","octopodiforme",\
	"bolitaenides","belemnites","astrocanthoteuthis","octodad","ocotillo")
	..()

/mob/living/carbon/martian/Destroy()
	head = null

	..()

#ifdef MARTIANS_AMBIDEXTROUS
/mob/living/carbon/martian/do_after_hand_check(held_item)
	//Normally do_after breaks if you switch hands. With martians, it will only break if the used item is dropped
	//This lets them do multiple things at once.
	return (held_items.Find(held_item))
#endif

/mob/living/carbon/martian/eyecheck()
	var/obj/item/clothing/head/headwear = src.head

	var/protection = headwear.eyeprot

	return Clamp(protection, -2, 2)

/mob/living/carbon/martian/earprot()
	return 1

/mob/living/carbon/martian/dexterity_check()
	return TRUE

/mob/living/carbon/martian/IsAdvancedToolUser()
	return TRUE

/mob/living/carbon/martian/Process_Spaceslipping()
	return 0 //No slipping

/mob/living/carbon/martian/has_eyes()
	return FALSE

/mob/living/carbon/martian/attack_hand(mob/living/M)
	switch(M.a_intent)
		if(I_HELP)
			help_shake_act(M)

		if(I_HURT)
			M.unarmed_attack_mob(src)

		if(I_GRAB)
			M.grab_mob(src)

		if(I_DISARM)
			M.disarm_mob(src)

/mob/living/carbon/martian/attack_alien(mob/living/M)
	switch(M.a_intent)
		if (I_HELP)
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")

		if (I_HURT)
			return M.unarmed_attack_mob(src)

		if (I_GRAB)
			return M.grab_mob(src)

		if (I_DISARM)
			return M.disarm_mob(src)

/mob/living/carbon/martian/attack_slime(mob/living/carbon/slime/M)
	M.unarmed_attack_mob(src)

/mob/living/carbon/martian/attack_martian(mob/M)
	return attack_hand(M)

/mob/living/carbon/martian/attack_paw(mob/M)
	return attack_hand(M)

/mob/living/carbon/martian/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else
		health = maxHealth - getOxyLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()

/mob/living/carbon/martian/Stat()
	if(head && istype(head, /obj/item/clothing/head/helmet/space/martian))
		var/obj/item/clothing/head/helmet/space/martian/fishbowl = head
		if(fishbowl.tank && istype(fishbowl.tank, /obj/item/weapon/tank))
			var/obj/item/weapon/tank/internal = fishbowl.tank
			stat("Internal Atmosphere Info", internal.name)
			stat("Tank Pressure", internal.air_contents.return_pressure())
			stat("Distribution Pressure", internal.distribute_pressure)


/mob/living/carbon/martian/Login()
	..()
	update_hud()