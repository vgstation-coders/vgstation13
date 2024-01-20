/obj/effect/decal/cleanable/blood/gibs/robot
	name = "robot debris"
	desc = "It's a useless heap of junk... <i>or is it?</i>"
	icon = 'icons/mob/robots.dmi'
	icon_state = "gib1"
	basecolor=ROBOT_OIL
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7")

	fake_DNA = "robot oil splatters"
	stain_name = "oil"

/obj/effect/decal/cleanable/blood/gibs/robot/update_icon()
	color = "#FFFFFF"

/obj/effect/decal/cleanable/blood/gibs/robot/dry()	//pieces of robots do not dry up like
	return

/obj/effect/decal/cleanable/blood/gibs/robot/streak(var/list/directions)
	spawn ()
		var/direction = pick(directions)
		for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
			sleep(3)
			if (i > 0)
				if (prob(40))
					new /obj/effect/decal/cleanable/blood/oil/streak(get_turf(src))
				else if (prob(10))
					spark(src)

			anchored = FALSE
			throw_at(get_step(src, direction),1,1)//will cover hit humans in oil

/obj/effect/decal/cleanable/blood/gibs/robot/limb
	random_icon_states = list("gibarm", "gibleg")

/obj/effect/decal/cleanable/blood/gibs/robot/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7","gibup1","gibup1") //2:7 is close enough to 1:4

/obj/effect/decal/cleanable/blood/gibs/robot/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7","gibdown1","gibdown1") //2:7 is close enough to 1:4

/obj/effect/decal/cleanable/blood/oil
	name = "motor oil"
	desc = "It's black and greasy. Looks like Beepsky made another mess."
	basecolor=ROBOT_OIL

	fake_DNA = "oil splatters"
	stain_name = "oil"

/obj/effect/decal/cleanable/blood/oil/dry()
	return

/obj/effect/decal/cleanable/blood/oil/streak
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2
