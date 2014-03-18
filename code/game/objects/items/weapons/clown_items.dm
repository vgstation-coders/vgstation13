/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Soap
 *		Bike Horns
 */

/*
 * Banana Peals
 */
/obj/item/weapon/bananapeel/HasEntered(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if (istype(M, /mob/living/carbon/human) && (isobj(M:shoes) && M:shoes.flags&NOSLIP))
			return

		M.stop_pulling()
		M << "\blue You slipped on the [name]!"
		playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
		M.Stun(2)
		M.Weaken(2)
/*
 * Bike Horns
 */
/obj/item/weapon/bikehorn/attack_self(mob/user as mob)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(get_turf(src), 'sound/items/bikehorn.ogg', 50, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return