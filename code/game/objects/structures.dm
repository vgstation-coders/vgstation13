/obj/structure
	icon = 'icons/obj/structures.dmi'
	penetration_dampening = 5
	var/hasbolts = FALSE
	fire_fuel = 0 //exceptions defined as needed

/obj/structure/examine(mob/user)
	..()
	if(hasbolts)
		to_chat(user,"<span class='info'>This one is bolted into place.</span>")

/obj/structure/blob_act(var/destroy = 0)
	..()
	if(destroy || (prob(50)))
		qdel(src)

/obj/structure/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
		if(3.0)
			return

/obj/structure/projectile_check()
	return PROJREACT_OBJS

/obj/structure/kick_act(mob/living/carbon/human/H)
	if(H.locked_to && isobj(H.locked_to) && H.locked_to != src)
		var/obj/O = H.locked_to
		if(O.onBuckledUserKick(H, src))
			return //don't return 1! we will do the normal "touch" action if so!

	playsound(src, 'sound/effects/grillehit.ogg', 50, 1) //Zth: I couldn't find a proper sound, please replace it

	H.visible_message("<span class='danger'>[H] kicks \the [src].</span>", "<span class='danger'>You kick \the [src].</span>")
	if(prob(70))
		H.foot_impact(src, rand(2,4))

	if(!anchored && !locked_to)
		var/strength = H.get_strength()
		var/kick_dir = get_dir(H, src)

		if(!Move(get_step(loc, kick_dir))) //The structure that we kicked is up against a wall - this hurts our foot
			H.foot_impact(src, rand(2,4))

		if(strength > 1) //Strong - kick further
			spawn()
				sleep(3)
				for(var/i = 2 to strength)
					if(!Move(get_step(loc, kick_dir)))
						break
					sleep(3)
	if(material_type)
		material_type.on_use(H,src,null)

	if(arcanetampered && density && anchored)
		to_chat(H,"<span class='sinister'>[src] kicks YOU!</span>")
		playsound(src, 'sound/effects/grillehit.ogg', 50, 1) //Zth: I couldn't find a proper sound, please replace it
		H.Knockdown(10)
		H.Stun(10)

/obj/structure/animationBolt(var/mob/firer)
	new /mob/living/simple_animal/hostile/mimic/copy(loc, src, firer, duration=SPELL_ANIMATION_TTL)
