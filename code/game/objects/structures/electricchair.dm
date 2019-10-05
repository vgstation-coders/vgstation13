/obj/structure/bed/chair/e_chair
	name = "electric chair"
	desc = "Looks absolutely SHOCKING!"
	icon_state = "echair0"
	var/on = 1
	var/obj/item/assembly/shock_kit/part = null
	var/last_time = 1.0

/obj/structure/bed/chair/e_chair/New()
	..()
	var/image/over = image('icons/obj/objects.dmi', src, "echair_over",OBJ_LAYER, dir)
	over.plane = ABOVE_HUMAN_PLANE
	overlays += over

/obj/structure/bed/chair/e_chair/Destroy()
	return ..()

/obj/structure/bed/chair/e_chair/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswrench(W))
		var/obj/structure/bed/chair/C = new /obj/structure/bed/chair(loc)
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		C.dir = dir
		part.forceMove(loc)
		part.master = null
		part = null
		qdel(src)

/obj/structure/bed/chair/e_chair/verb/toggle()
	set name = "Toggle Electric Chair"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return

	on = !on
	icon_state = "echair[on]"
	to_chat(usr, "<span class='notice'>You switch [on ? "on" : "off"] [src].</span>")

/obj/structure/bed/chair/e_chair/rotate()
	..()
	overlays.len = 0
	var/image/electric_chair_overlay = image('icons/obj/objects.dmi', src, "echair_over")
	electric_chair_overlay.plane = ABOVE_HUMAN_PLANE
	overlays += electric_chair_overlay

/obj/structure/bed/chair/e_chair/proc/shock()
	if(!on)
		return
	if(last_time + 50 > world.time)
		return
	last_time = world.time

	// special power handling
	var/area/A = get_area(src)
	if(!isarea(A))
		return
	if(!A.powered(EQUIP))
		return
	if(is_locking(/datum/locking_category/buckle, subtypes=TRUE))
		A.use_power(EQUIP, 5000)
		var/light = A.power_light
		A.updateicon()
		flick("echair1", src)
		var/mob/living/carbon/human/target = get_locked(/datum/locking_category/buckle, subtypes=TRUE)[1]
		visible_message("<span class='danger'>The electric chair went off!</span>", "<span class='danger'>You hear a deep sharp shock!</span>")
		for(var/i=1;i<=5;i++)
			if(istype(target) && target.locked_to == src)
				target.electrocute_act(34, src, incapacitation_duration = 24 SECONDS)
				to_chat(target, "<span class='danger'>You feel a deep shock course through your body!</span>")
			spark(src, 12, FALSE)
			sleep(10)

		A.power_light = light
		A.updateicon()
	else
		spark(src, 12, FALSE) //just something to let them know it works
	return
