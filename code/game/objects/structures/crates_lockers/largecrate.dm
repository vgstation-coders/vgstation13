/obj/structure/largecrate
	name = "large crate"
	desc = "A hefty wooden crate."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "densecrate"
	density = 1
	flags = FPRINT

/obj/structure/largecrate/attack_hand(mob/user as mob)
	to_chat(user, "<span class='notice'>You need a crowbar to pry this open!</span>")
	return

/obj/structure/largecrate/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iscrowbar(W))
		new /obj/item/stack/sheet/wood(src)
		var/turf/T = get_turf(src)
		for(var/obj/O in contents)
			O.forceMove(T)
		user.visible_message("<span class='notice'>[user] pries \the [src] open.</span>", \
							 "<span class='notice'>You pry open \the [src].</span>", \
							 "<span class='notice'>You hear splitting wood.</span>")
		qdel(src)
	else
		return attack_hand(user)

/obj/structure/largecrate/mule
	icon_state = "mulecrate"

/obj/structure/largecrate/lisa
	icon_state = "lisacrate"

/obj/structure/largecrate/porcelain

/obj/structure/largecrate/showers

/obj/structure/largecrate/lisa/attackby(obj/item/weapon/W as obj, mob/user as mob)	//ugly but oh well
	if(iscrowbar(W))
		new /mob/living/simple_animal/corgi/Lisa(loc)
	..()

/obj/structure/largecrate/cow
	name = "cow crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/cow/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iscrowbar(W))
		new /mob/living/simple_animal/cow(loc)
	..()

/obj/structure/largecrate/goat
	name = "goat crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/goat/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iscrowbar(W))
		new /mob/living/simple_animal/hostile/retaliate/goat(loc)
	..()

/obj/structure/largecrate/chick
	name = "chicken crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/chick/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iscrowbar(W))
		var/num = rand(4, 6)
		for(var/i = 0, i < num, i++)
			new /mob/living/simple_animal/chick(loc)
	..()

/obj/structure/largecrate/hissing/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iscrowbar(W))
		var/num = rand(2, 4)
		for(var/i = 1 to num)
			new /mob/living/simple_animal/hostile/lizard(loc)
	..()

/obj/structure/largecrate/porcelain/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iscrowbar(W))
		var/obj/structure/toilet/T = new (loc)
		T.anchored = 0
		var/obj/structure/sink/S = new (loc)
		S.anchored = 0
	..()

/obj/structure/largecrate/showers/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iscrowbar(W))
		for(var/i = 0, i < 2, i++)
			var/obj/machinery/shower/S = new (loc)
			S.anchored = 0
			S.panel_open = 1
	..()

/obj/structure/largecrate/skele_stand
	name = "hanging skeleton model crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/skele_stand/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iscrowbar(W))
		new /obj/structure/skele_stand(loc)
	..()

/obj/structure/largecrate/anomaly_container
	name = "anomaly container crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/anomaly_container/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iscrowbar(W))
		new /obj/structure/anomaly_container(loc)
	..()

/obj/structure/largecrate/cat
	icon_state = "lisacrate"

/obj/structure/largecrate/cat/attackby(obj/item/weapon/W, mob/user)
	if(iscrowbar(W))
		new /mob/living/simple_animal/cat/Proc(loc)
	..()