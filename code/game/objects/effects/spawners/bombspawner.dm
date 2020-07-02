
/obj/effect/spawner/newbomb
	name = "bomb"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	var/btype = 0 // 0=radio, 1=prox, 2=time
	var/delayedspawn = 0

/obj/effect/spawner/newbomb/radio
	btype = 0

/obj/effect/spawner/newbomb/proximity
	btype = 1

/obj/effect/spawner/newbomb/timer
	btype = 2

var/list/syndicate_bomb_spawners = list()

/obj/effect/spawner/newbomb/timer/syndicate
	delayedspawn = 1

/obj/effect/spawner/newbomb/timer/syndicate/New()
	..()
	syndicate_bomb_spawners += src

/obj/effect/spawner/newbomb/timer/syndicate/Destroy()
	syndicate_bomb_spawners -= src
	..()

/obj/effect/spawner/newbomb/New()
	..()
	if(delayedspawn)
		return

	spawnbomb()

/obj/effect/spawner/newbomb/proc/spawnbomb()
	var/obj/item/device/transfer_valve/mediumsize/V = new(src.loc)
	var/obj/item/weapon/tank/plasma/PT = new(V)
	var/obj/item/weapon/tank/oxygen/OT = new(V)

	V.tank_one = PT
	V.tank_two = OT

	//This is just an arbitrary mix that works fairly well.
	PT.air_contents.temperature = T0C + 170
	OT.air_contents.temperature = T0C - 100

	for(var/obj/item/weapon/tank/T in list(PT, OT))
		T.master = V
		var/datum/gas_mixture/G = T.air_contents
		G.update_values()
		G.multiply(20 * ONE_ATMOSPHERE / G.pressure) //Sets each tank's pressure to twenty atmospheres, generates a 3, 7, 14 explosion (used to be 10 times for 1, 3, 7)

	var/obj/item/device/assembly/S

	switch(btype)
		//Radio
		if(0)
			S = new/obj/item/device/assembly/signaler(V)

		//Proximity
		if (1)
			S = new/obj/item/device/assembly/prox_sensor(V)

		//Timer
		if (2)
			S = new/obj/item/device/assembly/timer(V)


	V.attached_device = S

	S.holder = V
	S.toggle_secure()

	V.update_icon()

	qdel(src)
