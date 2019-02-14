
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
	if (delayedspawn)
		return

	spawnbomb()

/obj/effect/spawner/newbomb/proc/spawnbomb()
	var/obj/item/device/transfer_valve/mediumsize/V = new(src.loc)
	var/obj/item/weapon/tank/plasma/PT = new(V)
	var/obj/item/weapon/tank/oxygen/OT = new(V)

	V.tank_one = PT
	V.tank_two = OT

	PT.master = V
	OT.master = V

	PT.air_contents.temperature = PLASMA_FLASHPOINT
	PT.air_contents.adjust_multi(
		GAS_PLASMA, 15,
		GAS_CARBON, 33)

	OT.air_contents.temperature = PLASMA_FLASHPOINT
	OT.air_contents.adjust_gas(GAS_OXYGEN, 48)

	var/obj/item/device/assembly/S

	switch (src.btype)
		// radio
		if (0)

			S = new/obj/item/device/assembly/signaler(V)

		// proximity
		if (1)

			S = new/obj/item/device/assembly/prox_sensor(V)

		// timer
		if (2)

			S = new/obj/item/device/assembly/timer(V)


	V.attached_device = S

	S.holder = V
	S.toggle_secure()

	V.update_icon()

	qdel(src)
