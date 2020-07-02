/obj/effect/spawner/mecha
	name = "mecha teleport beacon"
	var/mecha_type = null

/obj/effect/spawner/mecha/New()
	..()
	spawn_mecha()

/obj/effect/spawner/mecha/proc/spawn_mecha()
	var/turf/T = get_turf(src)
	var/obj/mecha = null
	if(mecha_type && T)
		mecha = new mecha_type(T)
		spark(mecha, 4)
	qdel(src)

/obj/effect/spawner/mecha/mauler
	mecha_type = /obj/mecha/combat/marauder/mauler