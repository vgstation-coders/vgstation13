/datum/clockcult_power/fellowship_armory
	name				= "Fellowship Armory"
	desc				= "Spawns enough Ratvarian cult armor for the entire group. The more people in the group, the faster it works. The set includes: Ratvarian Armor, Ratvarian Greaves, Ratvarian Gloves, and Ratvarian Helrmet."
	category			= CLOCK_SCRIPTS

	invocation			= "Tenag zr Ratvar sentzrag"
	participants_max	= INFINITY
	cast_time			= -1 // Dependant on the amount of people in the group.
	req_components		= list(CLOCK_VANGUARD = 1, CLOCK_HIEROPHANT = 1)

/datum/clockcult_power/fellowship_armory/get_cast_time(var/mob/user, var/obj/item/clockslab/C, var/list/participants)
	return (10 - participants.len) SECONDS // 10 seconds - 1 second for every participant.

/datum/clockcult_power/fellowship_armory/activate(var/mob/user, var/obj/item/clockslab/C, var/list/participants)
	for(var/mob/living/cultist in participants + user)
		// Hood.
		var/obj/item/clothing/L = new/obj/item/clothing/head/clockcult{alpha = 0;}(cultist.loc)
		animate(L, alpha = initial(L.alpha), 5)

		// Suit.
		L = new/obj/item/clothing/suit/clockcult{alpha = 0;}(cultist.loc)
		animate(L, alpha = initial(L.alpha), 5)

		// Shoes.
		L = new/obj/item/clothing/shoes/clockcult{alpha = 0;}(cultist.loc)
		animate(L, alpha = initial(L.alpha), 5)
