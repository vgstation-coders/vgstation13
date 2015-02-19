/*
/datum/reagent/ethanol
	name = "Ethanol"
	id = "ethanol"
	description = "A well-known alcohol with a variety of applications."
	reagent_state = LIQUID
	color = "#404030" // rgb: 64, 64, 48

/datum/reagent/ethanol/on_mob_life(var/mob/living/M as mob)
	if(!data) data = 1
	data++
	M.Dizzy(5)
	M.jitteriness = max(M.jitteriness-5,0)
	if(data >= 25)
		if (!M.stuttering) M.stuttering = 1
		M.stuttering += 4
	if(data >= 40 && prob(33))
		if (!M.confused) M.confused = 1
		M.confused += 3
	..()
	return
/datum/reagent/ethanol/reaction_obj(var/obj/O, var/volume)
	if(istype(O,/obj/item/weapon/paper))
		var/obj/item/weapon/paper/paperaffected = O
		paperaffected.clearpaper()
		usr << "The solution melts away the ink on the paper."
	if(istype(O,/obj/item/weapon/book))
		if(volume >= 5)
			var/obj/item/weapon/book/affectedbook = O
			affectedbook.dat = null
			usr << "The solution melts away the ink on the book."
		else
			usr << "It wasn't enough..."
	return
*/
