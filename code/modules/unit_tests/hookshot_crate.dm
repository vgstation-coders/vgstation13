/datum/unit_test/hookshot_crate/start()
	var/turf/T = locate(1, 1, 1)
	var/obj/structure/closet/crate/crate = new(T)
	crate.open()

	var/obj/effect/overlay/hookchain/chain = new(T)
	crate.close()
	if(chain.loc == crate)
		fail("A hookshot chain link was stored inside the crate.")
	crate.open()

	var/obj/item/projectile/projectile = new(T)
	crate.close()
	if(projectile.loc == crate)
		fail("A projectile was stored inside the crate.")

	qdel(chain)
	qdel(projectile)
	qdel(crate)
