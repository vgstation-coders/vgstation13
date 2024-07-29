
////////////////////////////////////////////////////////////////////
//																  //
//						HOLOGRAM PROJECTOR						  //
//																  //
////////////////////////////////////////////////////////////////////

/obj/item/device/hologram_projector
	name = "hologram projector"
	desc = "It makes a hologram appear...with magnets or something..."
	icon_state = "shield0"
	can_take_pai = TRUE

	var/mob/living/simple_animal/hologram/advanced/projector/holoperson = null
	var/holo_range = 10 //if you run, you disappear with lower range
	var/obj/effect/overlay/holoray/ray	//The link between the projection and the projector.
	var/datum/recruiter/recruiter = null
	var/polling_ghosts = FALSE

/obj/item/device/hologram_projector/New()
	..()
	register_event(/event/after_move, src, /obj/item/device/hologram_projector/proc/update_ray)

/obj/item/device/hologram_projector/Destroy()
	if(holoperson)
		QDEL_NULL(holoperson)
	if(ray)
		QDEL_NULL(ray)
	..()

/obj/item/device/hologram_projector/install_pai(obj/item/device/paicard/P)
	..()
	if(holoperson)
		clear_holo()
	if(P?.pai)
		P.pai.verbs += /obj/item/device/hologram_projector/proc/spawn_hologram
		spawn_pai_hologram()

/obj/item/device/hologram_projector/eject_integratedpai_if_present()
	clear_holo()
	if(integratedpai)
		var/obj/item/device/paicard/P = integratedpai
		if(P?.pai)
			P.pai.verbs -= /obj/item/device/hologram_projector/proc/spawn_hologram
	..()

/obj/item/device/hologram_projector/proc/spawn_hologram()
	set category = "pAI Commands"
	set name = "Spawn Hologram"
	set desc = "Display a a visual representation of yourself to those nearby!"

	var/obj/item/device/hologram_projector/mine = usr.loc.loc //the pai in the card in the projector (that's how MULEbots do it)
	if(istype(mine))
		mine.spawn_pai_hologram()

/obj/item/device/hologram_projector/emp_act()
	if(holoperson)
		clear_holo()

/obj/item/device/hologram_projector/attack_self()
	if(polling_ghosts)
		return
	if(holoperson)
		to_chat(usr, "Shutting down hologram...")
		clear_holo()
		return
	else if(integratedpai)
		spawn_pai_hologram()
	else
		recruit_holoperson()
	to_chat(usr, "Generating hologram...")

/obj/item/device/hologram_projector/pickup(var/mob/user)
	user.register_event(/event/after_move, src, /obj/item/device/hologram_projector/proc/update_ray)
	update_ray()

/obj/item/device/hologram_projector/dropped(var/mob/user)
	if (!still_in_user(user,src.loc))
		user.unregister_event(/event/after_move, src, /obj/item/device/hologram_projector/proc/update_ray)
	update_ray()

/obj/item/device/hologram_projector/proc/still_in_user(var/mob/user, var/atom/check)
	if (!check)
		return FALSE
	if (check == user)
		return TRUE
	else if (isturf(check))
		return FALSE
	else
		return still_in_user(user,check.loc)

/obj/item/device/hologram_projector/proc/spawn_pai_hologram()
	if (integratedpai?.pai)
		var/turf/T = get_turf(src)
		holoperson = new (T)
		holoperson.set_light(1)
		holoperson.real_name = integratedpai.pai.real_name
		holoperson.name = integratedpai.pai.name
		holoperson.projector = src
		holoperson.proj_turf = T

		//giving control of the hologram to the pAI
		holoperson.key = integratedpai.pai.key
		//we don't transfer the mind but we keep a reference to it.
		holoperson.mind = integratedpai.pai.mind

		icon_state = "shield1"
		update_ray()

/obj/item/device/hologram_projector/proc/clear_holo()
	if(holoperson)
		holoperson.clearing_holo = TRUE
		if(integratedpai)
			if (!integratedpai.pai)//shouldn't occur but hey just in case
				integratedpai.pai = new (integratedpai)
			integratedpai.pai.key = holoperson.key
		visible_message("<span class='warning'>The image of [holoperson] fades away.</span>")
		var/atom/movable/overlay/fade_out = anim(location = get_turf(holoperson))
		fade_out.appearance = holoperson.appearance
		animate(fade_out, alpha = 0, time = 5)
		holoperson.set_light(0)
		holoperson.drop_hands()
		holoperson.unequip_everything()

		QDEL_NULL(holoperson)
		update_ray()
		icon_state = "shield0"

/obj/item/device/hologram_projector/proc/recruit_holoperson()
	if(polling_ghosts)
		return
	polling_ghosts = TRUE
	if(!recruiter)
		recruiter = new(src)
		recruiter.display_name = "Holoperson"
		recruiter.jobban_roles = list(ROLE_POSIBRAIN)
		recruiter.recruitment_timeout = 30 SECONDS
	// Role set to Yes or Always
	recruiter.player_volunteering = new /callback(src, nameof(src::recruiter_recruiting()))
	// Role set to No or Never
	recruiter.player_not_volunteering = new /callback(src, nameof(src::recruiter_not_recruiting()))

	recruiter.recruited = new /callback(src, nameof(src::recruiter_recruited()))
	recruiter.request_player()

/obj/item/device/hologram_projector/proc/recruiter_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\ You have been added to the list of potential ghosts. ([controls])</span>")

/obj/item/device/hologram_projector/proc/recruiter_not_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\ A hologram is being requested. ([controls])</span>")

/obj/item/device/hologram_projector/proc/recruiter_recruited(mob/dead/observer/player)
	if(!player)
		to_chat(usr, "Hologram generation failed!")
		polling_ghosts = FALSE
		QDEL_NULL(recruiter)
		return
	polling_ghosts = FALSE

	var/turf/T = get_turf(src)
	player.forceMove(T)
	holoperson = player.transmogrify(/mob/living/simple_animal/hologram/advanced/projector, TRUE)
	holoperson.set_light(1)
	holoperson.projector = src
	holoperson.proj_turf = T

	icon_state = "shield1"
	update_ray()
	qdel(recruiter)

/obj/item/device/hologram_projector/proc/update_ray()
	if (!ray)
		ray = new(src)
	var/turf/hologram_turf = null
	var/turf/projector_turf = get_turf(src)

	if (holoperson && !holoperson.clearing_holo)
		hologram_turf = get_turf(holoperson)

		if (get_dist(projector_turf, hologram_turf) > holo_range)
			clear_holo()
			return

	//we only render the ray if the holoperson isn't on top of the projector
	if (hologram_turf && projector_turf && (hologram_turf != projector_turf))
		if (hologram_turf.z != projector_turf.z)
			ray.forceMove(src)
			return
		ray.forceMove(projector_turf)
		var/disty = hologram_turf.y - projector_turf.y
		var/distx = hologram_turf.x - projector_turf.x
		var/newangle
		if(!disty)
			if(distx >= 0)
				newangle = 90
			else
				newangle = 270
		else
			newangle = arctan(distx/disty)
			if(disty < 0)
				newangle += 180
			else if(distx < 0)
				newangle += 360
		var/matrix/M = matrix()
		if (get_dist(hologram_turf,projector_turf) <= 1)
			animate(ray, transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle),time = 1)
		else
			ray.transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle)
	else if (ray.loc != src)
		ray.forceMove(src)

////////////////////////////////////////////////////////////////////
//																  //
//							HOLOGRAM MOB						  //
//																  //
////////////////////////////////////////////////////////////////////

/mob/living/simple_animal/hologram/advanced/projector
	holodeck_bound = FALSE
	var/clearing_holo = FALSE
	var/obj/item/device/hologram_projector/projector = null
	var/proj_turf = null
	login_text = "You are a hologram. You can perform a few basic functions, and are unable to leave the vicinity of the projector.\
	\n<span class='danger'>Do not damage the station. Do not harm crew members without their consent. Serve your master.</span>"


/mob/living/simple_animal/hologram/advanced/projector/Login()
	if(projector?.integratedpai)
		var/obj/item/device/paicard/P = projector.integratedpai
		login_text = "Your supplemental directives have been updated. Your new directives are: \
			\nPrime Directive : <br>[P.pai.pai_law0] \
			\nSupplemental Directives: <br>[P.pai.pai_laws]"

	register_event(/event/after_move, src, /mob/living/simple_animal/hologram/advanced/projector/proc/update_ray)
	..()

/mob/living/simple_animal/hologram/advanced/projector/Destroy()
	unregister_event(/event/after_move, src, /mob/living/simple_animal/hologram/advanced/projector/proc/update_ray)
	if(projector && !clearing_holo)
		projector.clear_holo()
	projector = null
	..()

/mob/living/simple_animal/hologram/advanced/projector/Life()
	..()

	if(!projector)
		return

	if(mind && !client)
		projector.clear_holo()

	var/turf/T = get_turf(src)

	if(T && T.obscured)
		projector.clear_holo()
	else
		update_ray()

/mob/living/simple_animal/hologram/advanced/projector/proc/update_ray()
	if (projector)
		projector.update_ray()
