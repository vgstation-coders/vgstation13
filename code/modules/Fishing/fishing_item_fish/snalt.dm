/obj/item/snalt
	name = "snalt"
	desc = "snalt"
	icon = ''
	icon_state = ""
	w_class = W_CLASS_SMALL
	var/snaltiness = 10
	var/wriggleTime = 60

/obj/item/snalt/angler_effect(obj/item/weapon/bait/baitUsed)
	snaltiness = baitUsed.catchPower/2
	wriggleTime -= baitUsed.catchSizeAdd * baitUsed.catchSizeMult

/obj/item/snalt/throw_impact(atom/hit_atom)
	src.visible_message("<span class='danger'>\The [src] recoils into its shell. Salt rapidly forms around it!</span>")
	spawn(5)
		getSalty()

/obj/item/snalt/proc/getSalty()
	var/obj/structure/inflatable/pillarofsalt/pillarOfSnalt = new /obj/structure/inflatable/pillarofsalt(src.loc)
	forceMove(pillarOfSnalt)
	pillarOfSnalt.health += snaltiness
	pillarOfSnalt.saltiness = snaltiness
	spawn(wriggleTime SECONDS)
		wriggleOut(pillarOfSnalt)

/obj/item/snalt/proc/wriggleOut(obj/structure/inflatable/pillarofsalt/pillarOfSnalt)
	if(!pillarOfSnalt.gcDestroyed && src.loc == pillarOfSnalt)
		src.forceMove(pillarOfSnalt.loc)
		src.visible_message("<span class='notice'>\The [src] wriggles free of \the [pillarOfSnalt]!</span>")
		pillarOfSnalt.ourSnalt = null

/obj/structure/inflatable/pillarofsalt
	name = "pillar of salt"
	desc = ""
	icon = ''
	icon_state = ""
	density = 1
	anchored = 1
	opacity = 1
	health = 50
	ctrl_deflate = FALSE
	var/obj/item/snalt/ourSnalt = null
	var/saltiness = 0

/obj/structure/inflatable/pillarofsalt/attackby(obj/item/I, mob/user)
	take_damage(I.force)
	user.delayNextAttack(10)

/obj/structure/inflatable/pillarofsalt/deflate()
	new /obj/effect/decal/cleanable/salt(src.loc)
	if(ourSnalt)
		ourSnalt.forceMove(src.loc)
	animate(src, alpha = 0, time = 1 SECONDS)
	spawn(1 SECONDS)
		qdel(src)

/obj/structure/inflatable/pillarofsalt/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	mover.reagents.add_reagent(SODIUMCHLORIDE, saltiness/5)

/obj/structure/inflatable/pillarofsalt/bite_act(mob/living/carbon/human/user)
	user.reagents.add_reagent(SODIUMCHLORIDE, health/2)
	take_damage(rand(5,10))
	to_chat(user, "<span class='notice'>You bite \the [src], it tastes about as salty as you'd expect.</span>")
