var/list/ventcrawl_machinery = list(/obj/machinery/atmospherics/unary/vent_pump, /obj/machinery/atmospherics/unary/vent_scrubber, /obj/machinery/atmospherics/unary/vent)

/mob/living/proc/can_ventcrawl()
	return FALSE

/mob/living/proc/ventcrawl_carry()
	for(var/atom/A in src.contents)
		if(!(is_type_in_list(A, canEnterVentWith())))
			to_chat(src, "<span class='warning'>You can't be carrying items or have items equipped when vent crawling!</span>")
			return FALSE
	return TRUE

// Vent crawling whitelisted items, whoo
/mob/living/proc/canEnterVentWith()
	var/static/list/allowed_items = list(
		/obj/item/weapon/implant,
		/obj/item/clothing/mask/facehugger,
		/obj/item/device/radio/borg,
		/obj/machinery/camera,
		/mob/living/simple_animal/borer,
		/obj/transmog_body_container,
		/obj/item/verbs,
		/obj/item/weapon/gun/hookshot/flesh,
		/obj/item/device/camera_bug,
	)
	return allowed_items

/mob/living/DblClickOn(atom/A, params)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.handle_ventcrawl(A)
		return TRUE
	return ..()

/mob/living/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.handle_ventcrawl(A)
		return TRUE
	return ..()

/mob/living/carbon/human/can_ventcrawl()
	if(handcuffed || legcuffed)
		to_chat(src, "<span class='warning'>You can't vent crawl while you're restrained!</span>")
		return FALSE
	return istype(w_uniform,/obj/item/clothing/under/contortionist)

/mob/living/carbon/human/ventcrawl_carry()
	if(istype(w_uniform,/obj/item/clothing/under/contortionist))
		var/obj/item/clothing/under/contortionist/C = w_uniform
		return C.check_clothing(src)
	return TRUE

/obj/item/clothing/under/contortionist/verb/crawl_through_vent()
	set name = "Crawl Through Vent"
	set category = "Object"
	set src in usr

	var/mob/living/carbon/human/user = usr
	if(istype(user) && user.w_uniform == src && check_clothing(user))
		var/pipe = user.start_ventcrawl()
		if(pipe)
			user.handle_ventcrawl(pipe)

/mob/proc/start_ventcrawl()
	var/atom/pipe
	var/list/pipes = list()
	for(var/obj/machinery/atmospherics/unary/U in range(1))
		if(is_type_in_list(U,ventcrawl_machinery) && Adjacent(U))
			pipes |= U
	if(!pipes || !pipes.len)
		to_chat(src, "<span class='warning'>There are no pipes that you can ventcrawl into within range!</span>")
		return
	if(pipes.len == 1)
		pipe = pipes[1]
	else
		pipe = input("Crawl Through Vent", "Pick a pipe") as null|anything in pipes
	if(canmove && pipe)
		return pipe

/mob/living/carbon/slime/can_ventcrawl()
	return TRUE

/mob/living/carbon/monkey/can_ventcrawl()
	if(handcuffed || legcuffed)
		to_chat(src, "<span class='warning'>You can't vent crawl while you're restrained!</span>")
		return FALSE
	return TRUE

/mob/living/silicon/robot/mommi/can_ventcrawl()
	return TRUE

/mob/living/silicon/robot/mommi/ventcrawl_carry()
	return TRUE

/mob/living/simple_animal/borer/can_ventcrawl()
	return TRUE

/mob/living/simple_animal/borer/ventcrawl_carry()
	return TRUE

/mob/living/simple_animal/mouse/can_ventcrawl()
	if(is_fat)
		to_chat(src, "<span class='notice'>You can't quite fit in the pipe.</span>")
		return FALSE
	return TRUE

/mob/living/simple_animal/hostile/gremlin/grinch/can_ventcrawl()
	return TRUE

/mob/living/simple_animal/spiderbot/can_ventcrawl()
	return TRUE

/mob/living/simple_animal/hostile/lizard/can_ventcrawl()
	return TRUE

/mob/living/simple_animal/hostile/necro/necromorph/leaper/can_ventcrawl()
	return TRUE

/mob/living/simple_animal/shade/can_ventcrawl()
	return TRUE

/mob/living/simple_animal/hostile/giant_spider/spiderling/can_ventcrawl()
	return TRUE

/mob/living/carbon/alien/can_ventcrawl()
	if(handcuffed)
		to_chat(src, "<span class='warning'>You can't vent crawl while you're restrained!</span>")
		return FALSE
	return TRUE

/mob/living/carbon/alien/ventcrawl_carry()
	return TRUE

/mob/living/carbon/alien/humanoid/queen/can_ventcrawl()
	to_chat(src, "<span class='notice'>You can't quite fit in the pipe.</span>")
	return FALSE

/mob/living/simple_animal/hostile/grue/can_ventcrawl()
	if(lifestage==GRUE_LARVA)
		return TRUE
	else
		to_chat(src, "<span class='notice'>You are too big to fit into the pipe.</span>")
	return FALSE

/mob/living/var/ventcrawl_layer = PIPING_LAYER_DEFAULT

/mob/living/proc/handle_ventcrawl(var/atom/clicked_on)
	if(can_ventcrawl())
		if(!stat)
			if(!locked_to)
				if(!lying)
//					if(clicked_on)
//						to_chat(world, "We start with [clicked_on], and [clicked_on.type]")
					var/obj/machinery/atmospherics/unary/vent_found

					if(clicked_on && Adjacent(clicked_on))
						vent_found = clicked_on
						if(!istype(vent_found) || !vent_found.can_crawl_through())
							vent_found = null


					if(!vent_found)
						for(var/obj/machinery/atmospherics/machine in range(1,src))
							if(is_type_in_list(machine, ventcrawl_machinery))
								vent_found = machine

							if(!vent_found.can_crawl_through())
								vent_found = null

							if(vent_found)
								break

					if(vent_found)
						if(vent_found.network && (vent_found.network.normal_members.len || vent_found.network.line_members.len))

							to_chat(src, "You begin climbing into the ventilation system...")
							if(vent_found.air_contents && !issilicon(src))

								switch(vent_found.air_contents.temperature)
									if(0 to BODYTEMP_COLD_DAMAGE_LIMIT)
										to_chat(src, "<span class='danger'>You feel a painful freeze coming from the vent!</span>")
									if(BODYTEMP_COLD_DAMAGE_LIMIT to T0C)
										to_chat(src, "<span class='warning'>You feel an icy chill coming from the vent.</span>")
									if(T0C + 40 to BODYTEMP_HEAT_DAMAGE_LIMIT)
										to_chat(src, "<span class='warning'>You feel a hot wash coming from the vent.</span>")
									if(BODYTEMP_HEAT_DAMAGE_LIMIT to INFINITY)
										to_chat(src, "<span class='danger'>You feel a searing heat coming from the vent!</span>")

								switch(vent_found.air_contents.pressure)
									if(0 to HAZARD_LOW_PRESSURE)
										to_chat(src, "<span class='danger'>You feel a rushing draw pulling you into the vent!</span>")
									if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
										to_chat(src, "<span class='warning'>You feel a strong drag pulling you into the vent.</span>")
									if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
										to_chat(src, "<span class='warning'>You feel a strong current pushing you away from the vent.</span>")
									if(HAZARD_HIGH_PRESSURE to INFINITY)
										to_chat(src, "<span class='danger'>You feel a roaring wind pushing you away from the vent!</span>")

							if(!do_after(src,vent_found, 45,,0))
								return

							if(!client)
								return

							if(!ventcrawl_carry())
								return

							visible_message("<B>[src] scrambles into the ventilation ducts!</B>", "You climb into the ventilation system.")

							forceMove(vent_found)
							add_ventcrawl(vent_found)
							diary << "[src] is ventcrawling."

						else
							to_chat(src, "<span class='danger'>This vent is not connected to anything.</span>")
					else
						to_chat(src, "<span class='warning'>You must be standing on or beside an air vent to enter it.</span>")
				else
					to_chat(src, "<span class='warning'>You can't vent crawl while you're stunned!</span>")
			else
				to_chat(src, "<span class='warning'>You can't vent crawl while you're restrained!</span>")
		else
			to_chat(src, "<span class='danger'>You must be conscious to do this!</span>")


/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/starting_machine)
	is_ventcrawling = 1
	candrop = 0
	var/datum/pipe_network/network = starting_machine.return_network(starting_machine)
	if(!network)
		return
	for(var/datum/pipeline/pipeline in network.line_members)
		for(var/obj/machinery/atmospherics/A in (pipeline.members || pipeline.edges))
			if(!A.pipe_image)
				A.pipe_image = image(A, A.loc, layer = ABOVE_LIGHTING_LAYER, dir = A.dir)
				A.pipe_image.plane = ABOVE_LIGHTING_PLANE
			pipes_shown += A.pipe_image
			client.images += A.pipe_image

/mob/living/proc/remove_ventcrawl()
	is_ventcrawling = 0
	candrop = 1
	if(client)
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
		client.eye = src

	pipes_shown.len = 0
