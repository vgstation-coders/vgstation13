/mob/living/simple_animal/hologram
	name = "hologram"
	desc = "A holographic image of something"
	icon = 'icons/mob/AI.dmi'
	icon_state = "holo2"
	icon_living = "holo2"
	icon_dead = null
	var/atom/atom_to_mimic


/mob/living/simple_animal/hologram/Die()
	..()
	visible_message("<span class = 'notice>\The [src] dissipates from view.</span>")
	qdel(src)


/mob/living/simple_animal/hologram/New()
	..()
	mimic()

/mob/living/simple_animal/hologram/proc/mimic(var/atom/mimic = atom_to_mimic)
	if(!mimic)
		return

	var/atom/thing_to_mimic = new mimic

	var/icon_of_mimic = getHologramIcon(icon(thing_to_mimic.icon, thing_to_mimic.icon_state))

	icon = icon_of_mimic
	name = thing_to_mimic.name
	var/datum/log/L = new
	thing_to_mimic.examine(L)
	desc = L.log
	qdel(L)
	qdel(thing_to_mimic)

/mob/living/simple_animal/hologram/examine(mob/user, var/size = "")
	if(desc)
		to_chat(user, desc)

/mob/living/simple_animal/hologram/RangedAttack(var/atom/A)
	if((istype(A, /obj) || isliving(A)) && A != src)
		mimic(A.type)


/mob/living/simple_animal/hologram/corgi
	atom_to_mimic = /mob/living/simple_animal/corgi

/mob/living/simple_animal/hologram/corgi_puppy
	atom_to_mimic = /mob/living/simple_animal/corgi/puppy

/mob/living/simple_animal/hologram/chicken
	atom_to_mimic = /mob/living/simple_animal/chicken

/mob/living/simple_animal/hologram/tajaran
	atom_to_mimic = /mob/living/simple_animal/hostile/humanoid/tajaran

/mob/living/simple_animal/hologram/cow
	atom_to_mimic = /mob/living/simple_animal/cow