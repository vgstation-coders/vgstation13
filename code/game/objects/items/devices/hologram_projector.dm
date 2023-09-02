/obj/item/device/hologram_projector
	name = "hologram projector"
	desc = "It makes a hologram appear...with magnets or something..."
	icon_state = "shield0"
	can_take_pai = TRUE

	var/mob/living/simple_animal/hologram/advanced/projector/holoperson = null
	var/holo_range = 10 //if you run, you disappear with lower range
	var/holo_mode = 0
	var/obj/effect/overlay/holoray/ray	//The link between the projection and the projector.
	var/datum/recruiter/recruiter = null
	var/polling_ghosts = FALSE

/obj/item/device/hologram_projector/Destroy()
	if(holoperson)
		holoperson.unequip_everything()
		QDEL_NULL(holoperson)
	if(ray)
		QDEL_NULL(ray)
	..()

/mob/living/simple_animal/hologram/advanced/projector
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
	..()

/mob/living/simple_animal/hologram/advanced/projector/Destroy()
	if(projector)
		projector.icon_state = "shield0"
		if(projector.ray)
			qdel(projector.ray)
		projector = null
	..()

/obj/item/device/hologram_projector/proc/clear_holo()
	set_light(0)
	if(holoperson)
		if(integratedpai)
			remove_pai()
		visible_message("<span class='warning'>The image of [holoperson] fades away.</span>")
		animate(holoperson, alpha = 0, time = 5)
		spawn(5)
			holoperson.set_light(0)
			QDEL_NULL(ray)
			holoperson.unequip_everything()
			QDEL_NULL(holoperson)
			icon_state = "shield0"
	return 1

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
		install_pai()
	else
		recruit_holoperson()
	to_chat(usr, "Generating hologram...")

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
	ray = new(T)
	qdel(recruiter)

/mob/living/simple_animal/hologram/advanced/projector/Life()
	regular_hud_updates()

	if(!projector)
		return
	if((mind && !client))
		projector.clear_holo()

	var/turf/T = get_turf(src)
	var/turf/dest = get_turf(projector)

	if(T && T.obscured)
		projector.clear_holo()
	if((projector.holo_mode == 0 && (get_dist(dest, T) <= projector.holo_range)))
		return 1
	else if (projector.holo_mode == 1)
		var/area/area = get_area(dest)
		var/area/holoperson_area = get_area(T)
		if(holoperson_area == area)
			return 1

	projector.clear_holo() //If not, we want to get rid of the hologram.

/mob/living/simple_animal/hologram/advanced/projector/Move()
	..()
	if(!projector)
		return
	var/turf/T = get_turf(src)
	var/turf/dest = get_turf(projector)
	if(proj_turf && proj_turf != dest)
		qdel(projector.ray)
		projector.ray = new(dest)
		proj_turf = dest
	else
		var/disty = y - projector.ray.y
		var/distx = x - projector.ray.x
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
		if (get_dist(T,dest) <= 1)
			animate(projector.ray, transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle),time = 1)
		else
			projector.ray.transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle)

//pAI it uses the pAI framework in objs.dm. Check that code for further information
/obj/item/device/hologram_projector/install_pai(obj/item/device/paicard/P)
	..()
	if(holoperson)
		clear_holo()
	if(!P?.pai)
		return
	var/turf/T = get_turf(src)
	holoperson = new (T)
	holoperson.set_light(1)
	holoperson.real_name = P.pai.real_name
	holoperson.name = P.pai.name
	holoperson.projector = src
	holoperson.proj_turf = T
	P.pai.mind.transfer_to(holoperson)
	qdel(P.pai)

	icon_state = "shield1"
	ray = new(T)

/obj/item/device/hologram_projector/remove_pai()
	if(holoperson)
		integratedpai.pai = new (integratedpai)
		integratedpai.pai.real_name = holoperson.real_name
		integratedpai.pai.name = holoperson.name
		var/datum/mind/M = holoperson.mind
		M.transfer_to(integratedpai.pai)
		clear_holo()
	..()
