#define SPIDERWEB_BRUTE_DIVISOR 4

//generic procs copied from obj/effect/alien
/obj/effect/spider
	name = "web"
	desc = "It's stringy and sticky."
	anchored = 1
	density = 0
	health = 15
	gender = NEUTER
	w_type=NOT_RECYCLABLE
	mouse_opacity = 1

//similar to weeds, but only barfed out by nurses manually
/obj/effect/spider/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)
		if(3.0)
			if (prob(5))
				qdel(src)
	return

/obj/effect/spider/attackby(var/obj/item/weapon/W, var/mob/user)
	user.delayNextAttack(8)
	if (~W.flags & NO_ATTACK_MSG)
		if(W.attack_verb && W.attack_verb.len)
			visible_message("<span class='warning'><b>[user] [pick(W.attack_verb)] \the [src] with \the [W].</b></span>")
		else
			visible_message("<span class='warning'><b>[user] attacks \the [src] with \the [W].</b></span>")

	var/damage = (W.is_hot() || W.is_sharp()) ? (W.force) : (W.force / SPIDERWEB_BRUTE_DIVISOR)

	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		else
			damage = W.force / SPIDERWEB_BRUTE_DIVISOR

	health -= damage
	healthcheck()

/obj/effect/spider/attack_hand(var/mob/living/carbon/human/user)
	if(user.a_intent == I_HURT)
		user.delayNextAttack(8)
		user.visible_message("<span class='danger'>[user.name] claws at the [src]!</span>", \
			"<span class='danger'>You claw at the [src]!</span>", \
			"You hear something tear.")
		health -= 2
		healthcheck()
	else
		var/atom/movable/I = pick(contents)
		var/some_suffix = "thing"
		if(I && ishuman(I))
			some_suffix = "one"
		user.visible_message("<span class='notice'>[user] rubs their hands all over \the [src]!</span>", \
			"<span class='notice'>You rub your hands over \the [src] [I && ", you think you can feel some[some_suffix] in there!"]</span>")


/obj/effect/spider/bullet_act(var/obj/item/projectile/Proj)
	. = ..()
	health -= Proj.damage
	healthcheck()

/obj/effect/spider/proc/healthcheck()
	if(health <= 0)
		qdel(src)

/obj/effect/spider/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		health -= 5
		healthcheck()

/obj/effect/spider/stickyweb
	layer = BELOW_TABLE_LAYER
	icon_state = "stickyweb1"

/obj/effect/spider/stickyweb/New()
	. = ..()

	if (prob(50))
		icon_state = "stickyweb2"

/obj/effect/spider/stickyweb/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0))
		return 1
	if(istype(mover, /mob/living/simple_animal/hostile/giant_spider))
		return 1
	else if(istype(mover, /mob/living))
		if(prob(50))
			to_chat(mover, "<span class='warning'>You get stuck in \the [src] for a moment.</span>")
			return 0
	else if(istype(mover, /obj/item/projectile) && !istype(mover, /obj/item/projectile/web))
		return prob(30)
	return 1

/obj/effect/spider/eggcluster
	name = "egg cluster"
	desc = "They seem to pulse slightly with an inner life."
	icon_state = "eggs"
	var/amount_grown = 0

/obj/effect/spider/eggcluster/New()
	..()
	pixel_x = rand(3,-3) * PIXEL_MULTIPLIER
	pixel_y = rand(3,-3) * PIXEL_MULTIPLIER
	processing_objects.Add(src)

/obj/effect/spider/eggcluster/Destroy()
	processing_objects.Remove(src)
	..()

/obj/effect/spider/eggcluster/healthcheck()
	if(health <= 0)
		new /obj/item/weapon/reagent_containers/food/snacks/spidereggs(loc)
		qdel(src)

/obj/effect/spider/eggcluster/process()
	amount_grown += rand(0,2)
	if(amount_grown >= 100)
		var/num = rand(4,6)
		for(var/i=0, i<num, i++)
			//new /obj/effect/spider/spiderling(src.loc)
			new /mob/living/simple_animal/hostile/giant_spider/spiderling(src.loc)
		qdel(src)

/obj/effect/decal/cleanable/spiderling_remains
	name = "spiderling remains"
	desc = "Green squishy mess."
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenshatter"

/obj/effect/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web."
	icon_state = "cocoon1"
	health = 30

/obj/effect/spider/cocoon/New()
	..()
	icon_state = pick("cocoon1","cocoon2","cocoon3")

/obj/effect/spider/cocoon/Destroy()
	src.visible_message("<span class='warning'>\the [src] splits open.</span>")
	for(var/atom/movable/A in contents)
		A.forceMove(src.loc)
	..()

/////////////////////////////////////SPIDER QUEEN STICKY PROJECTILE TRAP////////////////////////////////

//Spawns on top of mobs hit with the queen's web projectile
/obj/effect/rooting_trap/stickyweb
	name = "sticky web"
	desc = "A mess of sticky strings."
	mouse_opacity = 1
	icon_state = "stickyweb"

/obj/effect/rooting_trap/stickyweb/stick_to(var/atom/A, var/side = null)
	var/turf/T = get_turf(A)
	playsound(T, 'sound/weapons/hivehand_empty.ogg', 75, 1)
	. = ..()
	if (.)
		visible_message("<span class='warning'>\the sticky ball splatters over \the [A]'s legs, sticking them to \the [T].</span>")

#undef SPIDERWEB_BRUTE_DIVISOR
