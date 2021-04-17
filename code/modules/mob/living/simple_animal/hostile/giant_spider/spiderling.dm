///////////////////////////////////////
// SPIDERLING 2.0
//
// NOW NOT A FUCKING DECAL
///////////////////////////////////////

/mob/living/simple_animal/hostile/giant_spider/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "spiderling"
	icon_living = "spiderling"

	layer = HIDING_MOB_PLANE
	density = 0

	var/amount_grown = 0
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0

	butchering_drops = null

	vision_range = 3
	aggro_vision_range = 9
	idle_vision_range = 3
	move_to_delay = 3
	friendly = "harmlessly skitters into"
	maxHealth = 12
	health = 12
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "barrels into"
	a_intent = I_HELP
	size = SIZE_TINY
	//throw_message = "sinks in slowly, before being pushed out of "
	//status_flags = CANPUSH
	search_objects = 0
	wanted_objects = list(/obj/machinery/atmospherics/unary/vent_pump)

	environment_smash_flags = 0//spiderlings cannot smash tables and windows anymore when getting stomped
	var/static/list/spider_types = list(/mob/living/simple_animal/hostile/giant_spider, /mob/living/simple_animal/hostile/giant_spider/nurse, /mob/living/simple_animal/hostile/giant_spider/hunter)

/mob/living/simple_animal/hostile/giant_spider/spiderling/New()
	..()
	pixel_x = rand(6,-6) * PIXEL_MULTIPLIER
	pixel_y = rand(6,-6) * PIXEL_MULTIPLIER
	//75% chance to grow up
	if(prob(75))
		amount_grown = 1

/mob/living/simple_animal/hostile/giant_spider/spiderling/death(var/gibbed = FALSE)
	visible_message("<span class='alert'>[src] dies!</span>")
	new /obj/effect/decal/cleanable/spiderling_remains(src.loc)
	..(TRUE)
	qdel(src)

/mob/living/simple_animal/giant_spider/spiderling/reagent_act(id, method, volume)
	if(isDead())
		return

	.=..()

	switch(id)
		if(INSECTICIDE)
			if(method != INGEST)
				death(FALSE)

/mob/living/simple_animal/hostile/giant_spider/spiderling/Aggro()
	..()

	stance = HOSTILE_STANCE_ATTACK
	retreat_distance = 10
	minimum_distance = 10
	search_objects = 1

/mob/living/simple_animal/hostile/giant_spider/spiderling/LoseAggro()
	..()

	retreat_distance = 0
	minimum_distance = 0
	search_objects = 0
	stance = HOSTILE_STANCE_IDLE

/mob/living/simple_animal/hostile/giant_spider/spiderling/Life()
	if(timestopped)
		return 0 //under effects of time magick
	if(!client || deny_client_move)
		if(travelling_in_vent)
			if(istype(src.loc, /turf))
				travelling_in_vent = 0
				entry_vent = null
		else if(entry_vent)
			if(get_dist(src, entry_vent) <= 1)
				if(entry_vent.network && entry_vent.network.normal_members.len)
					var/list/vents = list()
					for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.network.normal_members)
						vents.Add(temp_vent)
					if(!vents.len)
						entry_vent = null
						return
					var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
					/*if(prob(50))
						src.visible_message("<B>[src] scrambles into the ventillation ducts!</B>")*/
					LoseAggro()
					spawn(rand(20,60))
						loc = exit_vent
						var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
						spawn(travel_time)

							if(!exit_vent || exit_vent.welded)
								loc = entry_vent
								entry_vent = null
								return

							if(prob(50))
								src.visible_message("<span class='notice'>You hear something squeezing through the ventilation ducts.</span>",2)
							sleep(travel_time)

							if(!exit_vent || exit_vent.welded)
								loc = entry_vent
								entry_vent = null
								return
							loc = exit_vent.loc
							entry_vent = null
							var/area/new_area = get_area(loc)
							if(new_area)
								new_area.Entered(src)
				else
					entry_vent = null
	//=================

	if (growth())
		return

	return ..()

/mob/living/simple_animal/hostile/giant_spider/spiderling/regular_hud_updates()
	..()
	if(client && hud_used)
		if(!hud_used.spiderling_growth_display)
			hud_used.spider_hud()
		hud_used.spiderling_growth_display.maptext_width = WORLD_ICON_SIZE
		hud_used.spiderling_growth_display.maptext_height = WORLD_ICON_SIZE
		if (amount_grown >= 100)
			hud_used.spiderling_growth_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'>Growth:<br><font color='#33FF33'>[min(amount_grown,100)]%</font></div>"
		else
			hud_used.spiderling_growth_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'>Growth:<br><font color='#FFFF00'>[min(amount_grown,100)]%</font></div>"

/mob/living/simple_animal/hostile/giant_spider/spiderling/GiveTarget(var/new_target)
	if(isliving(target) && (ishuman(target)||isrobot(target)) && !isMoMMI(target))
		target = new_target
		Aggro()
		visible_message("<span class='danger'>The [src.name] tries to flee from [target.name]!</span>")

/mob/living/simple_animal/hostile/giant_spider/spiderling/AttackingTarget()
	if(istype(target, /obj/machinery/atmospherics/unary/vent_pump))
		ventcrawl(target)

/mob/living/simple_animal/hostile/giant_spider/spiderling/proc/growth()
	if(isturf(loc) && (client || amount_grown > 0))//player-controlled spiderlings will always eventually mature, others have a 75% chance.
		amount_grown += rand(0,2)
		if(amount_grown >= 100)
			if (client)
				if(!(locate(/spell/spiderling_evolution) in spell_list))
					add_spell(new /spell/spiderling_evolution, "spider_spell_ready", /obj/abstract/screen/movable/spell_master/spider)
			else
				species_type = pick(spider_types)
				grow_up()
				return TRUE
	return FALSE

/mob/living/simple_animal/hostile/giant_spider/spiderling/proc/manual_evolution()
	if (!client)
		return
	if (!isturf(loc))
		to_chat(src,"<span class='warning'>You need to stand in the open before you can grow up.</span>")
		return

	var/list/choices = list(
		list("Nurse", "radial_nurse", "Weak, but injects sleep toxin upon successful attacks. Can also spin webs, lay eggs to birth more spiders, and evolve further into a sturdy and powerful queen."),
		list("Hunter", "radial_hunter", "Fast-moving, with decent damage and health."),
		list("Guard", "radial_guard", "Strong and sturdy, but fairly slow."),
	)
	var/spider_class = show_radial_menu(src,src,choices,'icons/obj/spiderling_radial.dmi',"radial-spider")

	if (!isturf(loc))
		to_chat(src,"<span class='warning'>You need to stand in the open before you can grow up.</span>")
		return//sanity check after we've picked a spider class

	switch(spider_class)
		if ("Nurse")
			grow_up(/mob/living/simple_animal/hostile/giant_spider/nurse)
		if ("Hunter")
			grow_up(/mob/living/simple_animal/hostile/giant_spider/hunter)
		if ("Guard")
			grow_up(/mob/living/simple_animal/hostile/giant_spider)

/mob/living/simple_animal/hostile/giant_spider/spiderling/proc/ventcrawl(var/obj/machinery/atmospherics/unary/vent_pump/v)
	//ventcrawl!
	if(!v.welded)
		entry_vent = v
		Goto(get_turf(v),move_to_delay)


//Virologist's little friend!
/mob/living/simple_animal/hostile/giant_spider/spiderling/salk
	name = "Salk"
	desc = "Named after someone who did their job much better than you do."
	icon_state = "jonas"
	icon_living = "jonas"

/mob/living/simple_animal/hostile/giant_spider/spiderling/salk/growth()//little jonas can never grow up
	return
