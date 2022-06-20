/obj/effect/gibspawner

/obj/effect/gibspawner/generic
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/core)
	gibamounts = list(2,2,1)

/obj/effect/gibspawner/generic/New()
	gibdirections = list(list(WEST, NORTHWEST, SOUTHWEST, NORTH),list(EAST, NORTHEAST, SOUTHEAST, SOUTH), list())
	..()

/obj/effect/gibspawner/genericmothership
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/core)
	gibamounts = list(2,2,1)
	fleshcolor = "#B5B5B5"
	bloodcolor = "#CFAAAA"

/obj/effect/gibspawner/genericmothership/New()
	gibdirections = list(list(WEST, NORTHWEST, SOUTHWEST, NORTH),list(EAST, NORTHEAST, SOUTHEAST, SOUTH), list())
	..()

/obj/effect/gibspawner/human
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/down,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/core)
	gibamounts = list(1,1,1,1,1,1,1)

/obj/effect/gibspawner/human/New(location, var/list/virus2, var/datum/dna/MobDNA, var/fleshcolor, var/bloodcolor, spread_radius)
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), alldirs, alldirs, list())
	gibamounts[6] = pick(0,1,2)
	..()

/obj/effect/gibspawner/xeno
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/xeno/up,/obj/effect/decal/cleanable/blood/gibs/xeno/down,/obj/effect/decal/cleanable/blood/gibs/xeno,/obj/effect/decal/cleanable/blood/gibs/xeno,/obj/effect/decal/cleanable/blood/gibs/xeno/body,/obj/effect/decal/cleanable/blood/gibs/xeno/limb,/obj/effect/decal/cleanable/blood/gibs/xeno/core)
	gibamounts = list(1,1,1,1,1,1,1)
	fleshcolor = ALIEN_FLESH
	bloodcolor = ALIEN_BLOOD

/obj/effect/gibspawner/xeno/New()
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), alldirs, alldirs, list())
	gibamounts[6] = pick(0,1,2)
	..()

/obj/effect/gibspawner/robot
	sparks = 1
	gibtypes = list(/obj/effect/decal/cleanable/blood/gibs/robot/up,/obj/effect/decal/cleanable/blood/gibs/robot/down,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot/limb)
	gibamounts = list(1,1,1,1,1,1)
	fleshcolor = ROBOT_OIL
	bloodcolor = ROBOT_OIL

/obj/effect/gibspawner/robot/New()
	gibdirections = list(list(NORTH, NORTHEAST, NORTHWEST),list(SOUTH, SOUTHEAST, SOUTHWEST),list(WEST, NORTHWEST, SOUTHWEST),list(EAST, NORTHEAST, SOUTHEAST), alldirs, alldirs)
	gibamounts[6] = pick(0,1,2)
	..()

/obj/effect/gibspawner/blood
	gibtypes = list(/obj/effect/decal/cleanable/blood,/obj/effect/decal/cleanable/blood,/obj/effect/decal/cleanable/blood/drip,/obj/effect/decal/cleanable/blood/drip)
	gibamounts = list(1,1,1,1)

/obj/effect/gibspawner/blood/New()
	gibdirections = list(alldirs, list(), list(WEST, NORTHWEST, SOUTHWEST, NORTH),list(EAST, NORTHEAST, SOUTHEAST, SOUTH))
	..()

/obj/effect/gibspawner/blood_drip
	gibtypes = list(/obj/effect/decal/cleanable/blood/drip,/obj/effect/decal/cleanable/blood/drip,/obj/effect/decal/cleanable/blood/drip)
	gibamounts = list(1,1,1)

/obj/effect/gibspawner/blood_drip/New()
	gibdirections = list(list(WEST, NORTHWEST, SOUTHWEST, NORTH),list(EAST, NORTHEAST, SOUTHEAST, SOUTH),list())
	..()
