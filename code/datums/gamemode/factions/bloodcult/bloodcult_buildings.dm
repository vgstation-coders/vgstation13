/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'
	var/health = 50
	var/maxHealth = 50

/obj/structure/cult/proc/takeDamage(var/damage)
	health -= damage
	if (health <= 0)
		qdel(src)
	else
		update_icon()

/obj/structure/cult/New()
	..()
	flick("[icon_state]-spawn", src)

/obj/structure/cult/Destroy()
	flick("[icon_state]-break", src)
	..()

/obj/structure/cult/cultify()
	return

/obj/structure/cult/ex_act(var/severity)
	switch(severity)
		if (1)
			takeDamage(100)
		if (2)
			takeDamage(20)
		if (3)
			takeDamage(4)

/obj/structure/cult/blob_act()
	takeDamage(20)

/obj/structure/cult/altar
	name = "Altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "altar"
