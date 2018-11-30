/obj/item/device/instrument/guitar/magical
	desc = "An ancient guitar, from the legendary artist born on Mars. It was said that he was a son of a god, gifted with the power of lighting himself. People say that he was the most humble man.. and that his music was simply.. electric!"
	force = 15
	mech_flags = MECH_SCAN_FAIL

/obj/item/device/instrument/guitar/magical/afterattack(atom/target, mob/user, proximity_flag)
	..()
	if(prob(20) && (wielded && song.playing) && proximity_flag) //20% chance to fire 4 bolts of lighting(33% damage each).
		playsound(src, pick(lightning_sound), 75, 1)
		for(var/i=0, i<4, i++)
			eletric_music(target, user)

/obj/item/device/instrument/guitar/magical/proc/eletric_music(var/atom/target, var/mob/user) //Kinda copypasty but eh, i don't want to make a new projectile for this.
	var/turf/T = get_turf(user)
	var/turf/U = get_turf(target)
	var/obj/item/projectile/beam/lightning/L = getFromPool(/obj/item/projectile/beam/lightning, T)
	L.damage = round((force * 33) / 100)
	L.tang = adjustAngle(get_angle(U,T))
	L.icon = midicon
	L.icon_state = "[L.tang]"
	L.firer = user
	L.def_zone = LIMB_CHEST
	L.original = target
	L.current = U
	L.starting = U
	L.yo = U.y - T.y
	L.xo = U.x - T.x
	spawn L.process()