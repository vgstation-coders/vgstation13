/obj/structure/skele_stand
	name = "hanging skeleton model"
	anchored = 0
	density = 1
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hangskele"
	desc = "It's an anatomical model of a human skeletal system made of plaster."
	var/last_rattle_time = 0
	var/rattle_cooldown = 2 SECONDS// let's not get our rattling out of hand

/obj/structure/skele_stand/New()
	..()
	gender = pick(MALE, FEMALE)

/obj/structure/skele_stand/proc/rattle_bones(mob/user, atom/thingy)
	if(last_rattle_time + rattle_cooldown <= world.time)
		if(user && !isobserver(user))
			visible_message("\The [user] pushes on [src][thingy?" with \the [thingy]":""], giving the bones a good rattle.")
		else if(user && isobserver(user))
			visible_message("\The [src] rattles [pick("ominously","violently")] on \his stand! [pick("Spooky","Weird")].")
		else
			visible_message("\The [src] rattles[thingy ? " upon being hit by \the [thingy]" : ""].")
		playsound(src, 'sound/effects/rattling_bones.ogg', 50, 0)
		last_rattle_time = world.time
	else
		return

/obj/structure/skele_stand/attack_hand(mob/user)
	rattle_bones(user, null)

/obj/structure/skele_stand/Bumped(atom/thing)
	rattle_bones(null, thing)

/obj/structure/skele_stand/attackby(obj/item/weapon/W, mob/user)
	rattle_bones(user, W)

obj/structure/skele_stand/spook(mob/user)
	rattle_bones(user, null)

/obj/structure/skele_stand/mrbones
  name = "Mr. Bones"
  desc = "The ride never ends!"

/obj/structure/skele_stand/mrbones/New()
	..()
	gender = MALE
