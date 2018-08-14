
/obj/item/verbs/borer/severed/verb/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B))
		return
	B.abandon_host()
