/obj/effect/gibspawner
	generic
		gibtypes = new /list(/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/core)
		gibamounts = new /list(2,2,1)

		New()
			gibdirections = new /list(new /list(WEST, NORTHWEST, SOUTHWEST, NORTH), new /list(EAST, NORTHEAST, SOUTHEAST, SOUTH), new /list())
			..()

	human
		gibtypes = new /list(/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/down,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs,/obj/effect/decal/cleanable/blood/gibs/core)
		gibamounts = new /list(1,1,1,1,1,1,1)

		New()
			gibdirections = new /list(new /list(NORTH, NORTHEAST, NORTHWEST), new /list(SOUTH, SOUTHEAST, SOUTHWEST), new /list(WEST, NORTHWEST, SOUTHWEST), new /list(EAST, NORTHEAST, SOUTHEAST), ALL_DIRS.Copy(), ALL_DIRS.Copy(), new /list())
			gibamounts[6] = pick(0,1,2)
			..()

	xeno
		gibtypes = new /list(/obj/effect/decal/cleanable/blood/gibs/xeno/up,/obj/effect/decal/cleanable/blood/gibs/xeno/down,/obj/effect/decal/cleanable/blood/gibs/xeno,/obj/effect/decal/cleanable/blood/gibs/xeno,/obj/effect/decal/cleanable/blood/gibs/xeno/body,/obj/effect/decal/cleanable/blood/gibs/xeno/limb,/obj/effect/decal/cleanable/blood/gibs/xeno/core)
		gibamounts = new /list(1,1,1,1,1,1,1)

		New()
			gibdirections = new /list(new /list(NORTH, NORTHEAST, NORTHWEST), new /list(SOUTH, SOUTHEAST, SOUTHWEST), new /list(WEST, NORTHWEST, SOUTHWEST), new /list(EAST, NORTHEAST, SOUTHEAST), ALL_DIRS.Copy(), ALL_DIRS.Copy(), new /list())
			gibamounts[6] = pick(0,1,2)
			..()

	robot
		sparks = 1
		gibtypes = new /list(/obj/effect/decal/cleanable/blood/gibs/robot/up,/obj/effect/decal/cleanable/blood/gibs/robot/down,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot,/obj/effect/decal/cleanable/blood/gibs/robot/limb)
		gibamounts = new /list(1,1,1,1,1,1)

		New()
			gibdirections = new /list(new /list(NORTH, NORTHEAST, NORTHWEST), new /list(SOUTH, SOUTHEAST, SOUTHWEST), new /list(WEST, NORTHWEST, SOUTHWEST), new /list(EAST, NORTHEAST, SOUTHEAST), ALL_DIRS.Copy(), ALL_DIRS.Copy())
			gibamounts[6] = pick(0,1,2)
			..()