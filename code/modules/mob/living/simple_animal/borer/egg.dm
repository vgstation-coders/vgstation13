// Amount of time between retries for recruits. As to not spam ghosts every minute.
#define BORER_EGG_RERECRUITE_DELAY 5.0 MINUTES

/obj/item/weapon/reagent_containers/food/snacks/borer_egg
	name = "borer egg"
	desc = "A small, gelatinous egg."
	icon = 'icons/mob/mob.dmi'
	icon_state = "borer egg-growing"
	bitesize = 12
	origin_tech = Tc_BIOTECH + "=4"
	mech_flags = MECH_SCAN_FAIL
	var/grown = 0
	var/hatching = 0 // So we don't spam ghosts.
	var/datum/recruiter/recruiter = null
	var/child_prefix_index = 1
	var/last_ping_time = 0
	var/ping_cooldown = 50

	var/list/required_mols=list(
		"toxins" = MOLES_PLASMA_VISIBLE / CELL_VOLUME,
		"oxygen" = 5 / CELL_VOLUME
	)

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/New()
	..()
	last_ping_time = world.time
	reagents.add_reagent(NUTRIMENT, 4)
	spawn(rand(1200,1500))//the egg takes a while to "ripen"
		Grow()

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/proc/Grow()
	grown = 1
	icon_state = "borer egg-grown"
	processing_objects.Add(src)

	if(!recruiter)
		recruiter = new(src)
		recruiter.display_name = "borer"
		recruiter.role = ROLE_BORER
		recruiter.jobban_roles = list("pAI")

		// A player has their role set to Yes or Always
		recruiter.player_volunteering.Add(src, "recruiter_recruiting")
		// ", but No or Never
		recruiter.player_not_volunteering.Add(src, "recruiter_not_recruiting")

		recruiter.recruited.Add(src, "recruiter_recruited")

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/proc/Hatch()
	if(hatching)
		return
	processing_objects.Remove(src)
	icon_state="borer egg-triggered"
	hatching=1
	src.visible_message("<span class='notice'>The [name] pulsates and quivers!</span>")
	recruiter.request_player()

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/proc/recruiter_recruiting(var/list/args)
	var/mob/dead/observer/O = args["player"]
	var/controls = args["controls"]
	to_chat(O, "<span class='recruit'>\The [src] is starting to hatch. You have been added to the list of potential ghosts. ([controls])</span>")

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/proc/recruiter_not_recruiting(var/list/args)
	var/mob/dead/observer/O = args["player"]
	var/controls = args["controls"]
	to_chat(O, "<span class='recruit'>\The [src] is starting to hatch. ([controls])</span>")

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/proc/recruiter_recruited(var/list/args)
	var/mob/dead/observer/O = args["player"]
	if(O)
		var/defect = rand(1,10000)
		var/turf/T = get_turf(src)
		src.visible_message("<span class='notice'>\The [name] bursts open!</span>")
		//Adds the chance for a "special" borer to be born
		var/borer_type = (defect == 666 ? /mob/living/simple_animal/borer/defected_borer : /mob/living/simple_animal/borer)
		var/mob/living/simple_animal/borer/B = new borer_type(T, child_prefix_index)
		B.transfer_personality(O.client)
		// Play hatching noise here.
		playsound(src.loc, 'sound/items/borer_hatch.ogg', 50, 1)
		qdel(src)
	else
		src.visible_message("<span class='notice'>\The [name] calms down.</span>")
		hatching = FALSE
		spawn (BORER_EGG_RERECRUITE_DELAY)
			Grow() // Reset egg, check for hatchability.


/obj/item/weapon/reagent_containers/food/snacks/borer_egg/process()
	var/turf/location = get_turf(src)
	if(!location)
		return
	var/datum/gas_mixture/environment = location.return_air()
	//testing("[type]/PROCESS() - plasma: [environment.toxins]")
	var/meets_conditions=1
	for(var/gas_id in required_mols)
		if(environment.molar_density(gas_id) < required_mols[gas_id])
			meets_conditions=0
	if(meets_conditions)
		src.Hatch()

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype( W, /obj/item/toy/crayon ))
		return
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/attack_ghost(var/mob/dead/observer/O)
	if(last_ping_time + ping_cooldown <= world.time)
		visible_message(message = "<span class='notice'>\The [src] wriggles vigorously.</span>", blind_message = "<span class='danger'>You hear what you think is someone jiggling a jelly.</span>")
		last_ping_time = world.time
	else
		to_chat(O, "The egg is recovering. Try again in a few moments.")

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/Destroy()
	qdel(recruiter)
	recruiter = null
	..()

#undef BORER_EGG_RERECRUITE_DELAY
