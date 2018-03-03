
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// fossils

/obj/item/weapon/fossil
	name = "Fossil"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "bone"
	desc = "It's a fossil."

/obj/item/weapon/fossil/base/New()
	var/list/l = list("/obj/item/weapon/fossil/bone"=9,"/obj/item/weapon/fossil/skull"=3,
	"/obj/item/weapon/fossil/skull/horned"=2)
	var/t = pickweight(l)
	var/obj/item/weapon/W = new t(src.loc)
	var/turf/T = get_turf(src)
	if(istype(T, /turf/unsimulated/mineral))
		T:last_find = W
	qdel (src)

/obj/item/weapon/fossil/bone
	name = "Fossilised bone"
	icon_state = "bone"
	desc = "It's a fossilised bone."

/obj/item/weapon/fossil/skull
	name = "Fossilised skull"
	icon_state = "skull"
	desc = "It's a fossilised skull."

/obj/item/weapon/fossil/skull/horned
	icon_state = "hskull"
	desc = "It's a fossilised, horned skull."

/obj/item/weapon/fossil/skull/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/fossil/bone))
		var/obj/o = new /obj/structure/skeleton(get_turf(src))
		var/a = new /obj/item/weapon/fossil/bone
		var/b = new src.type
		o.contents.Add(a)
		o.contents.Add(b)
		qdel (W)
		W = null
		qdel (src)

/obj/structure/skeleton
	name = "Incomplete skeleton"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "uskel"
	desc = "Incomplete skeleton."
	var/bnum = 1
	var/breq
	var/bstate = 0
	var/plaque_contents = "Unnamed alien creature"

/obj/structure/skeleton/New()
	src.breq = rand(6)+3
	src.desc = "An incomplete skeleton, looks like it could use [src.breq-src.bnum] more bones."

/obj/structure/skeleton/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/fossil/bone))
		if(!bstate)
			bnum++
			src.contents.Add(new/obj/item/weapon/fossil/bone)
			qdel (W)
			W = null
			if(bnum==breq)
				usr = user
				icon_state = "skel"
				src.bstate = 1
				src.setDensity(TRUE)
				src.name = "alien skeleton display"
				if(src.contents.Find(/obj/item/weapon/fossil/skull/horned))
					src.desc = "A creature made of [src.contents.len-1] assorted bones and a horned skull. The plaque reads \'[plaque_contents]\'."
				else
					src.desc = "A creature made of [src.contents.len-1] assorted bones and a skull. The plaque reads \'[plaque_contents]\'."
			else
				src.desc = "Incomplete skeleton, looks like it could use [src.breq-src.bnum] more bones."
				to_chat(user, "Looks like it could use [src.breq-src.bnum] more bones.")
		else
			..()
	else if(istype(W,/obj/item/weapon/pen))
		plaque_contents = copytext(sanitize(input(user, "What would you like to write on the plaque?", "Skeleton plaque", null) as text|null), 1, 1648) //length of WGW in characters - niggly said i should
		if (!plaque_contents || !Adjacent(user) || user.stat)
			return
		user.visible_message("[user] writes something on the base of [src].","You relabel the plaque on the base of [bicon(src)] [src].")
		if(src.contents.Find(/obj/item/weapon/fossil/skull/horned))
			src.desc = "A creature made of [src.contents.len-1] assorted bones and a horned skull. The plaque reads \'[plaque_contents]\'."
		else
			src.desc = "A creature made of [src.contents.len-1] assorted bones and a skull. The plaque reads \'[plaque_contents]\'."
	else
		..()

//shells and plants do not make skeletons
/obj/item/weapon/fossil/shell
	name = "Fossilised shell"
	icon_state = "shell"
	desc = "It's a fossilised shell."

/obj/item/weapon/fossil/plant
	name = "Fossilised plant"
	icon_state = "plant1"
	desc = "It's fossilised plant remains."

/obj/item/weapon/fossil/plant/New()
	..()
	icon_state = "plant[rand(1,4)]"
	var/prehistoric_plants = list(
		/obj/item/seeds/telriis,
		/obj/item/seeds/thaadra,
		/obj/item/seeds/jurlmah,
		/obj/item/seeds/amauri,
		/obj/item/seeds/gelthi,
		/obj/item/seeds/vale,
		/obj/item/seeds/surik,
		)
	nonplant_seed_type = pick(prehistoric_plants)
