/obj/item/weapon/pinnelid	//Not a child of pinpointers because enough was hardcoded that I might as well trim the fat
	name = "pinnelid"
	desc = ""
	icon = ''
	icon_state = "pinnelid_off"
	item_state = ""
	var/pointTarg = null

/obj/item/weapon/pinnelid/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/pinnelid/attack_self(mob/user)
	if(target)
		to_chat(user, "<span class='notice'>You begin spinning, squishing, and smothering \the [src] in an attempt to disorient its senses.</span>")
		if(do_after(user, src, 3 SECONDS))
			to_chat(user, "<span class='notice'>\The [src] looks confused and aimless.</span>")
			pointTarg = null


/obj/item/weapon/pinnelid/preattack(atom/target, mob/user , proximity)
	if(isrealobject(target))
		pointTarg = target

/obj/item/weapon/pinnelid/process()
	pointAt()

/obj/item/weapon/pinnelid/proc/pointAt()
	if(pointTarg)
		dir = get_dir(location, pointTarg)
	else if(prob(50))
		dir = pick(alldirs)	//He's just looking around

