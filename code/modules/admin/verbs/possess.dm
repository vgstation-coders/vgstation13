/client
	var/possessing = 0

/client/proc/possess(obj/thing as obj in world)
	set name = "Possess/Release Object"
	set category = "Object"
	set desc = "Posess or release an object"

	if(possessing)
		//mob.loc = get_turf(mob)
		var/datum/control/actual
		for(var/datum/control/C in mob.control_object)
			if(C.controlled == thing)
				actual = C
				break
		if(actual && mob.name_archive) //if you have a name archived and if you are actually releasing an object
			mob.real_name = mob.name_archive
			mob.name = mob.real_name
			if(ishuman(mob))
				var/mob/living/carbon/human/H = mob
				H.update_name()
	//		mob.regenerate_icons() //So the name is updated properly

		mob.forceMove(thing.loc) // Appear where the object you were controlling is -- TLE
		mob.client.eye = mob
		possessing = 0
		thing.unregister_event(/event/destroyed, src, nameof(src::possess()))

		if(actual)
			actual.break_control()
			qdel(actual)
		feedback_add_details("admin_verb","RO") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		if(config.forbid_singulo_possession && istype(thing,/obj/machinery/singularity))
			to_chat(mob, "It is forbidden to possess singularities.")
			return

		var/turf/T = get_turf(thing)

		log_admin("[key_name(mob)] has possessed [thing] ([thing.type]) at [T ? "([T.x], [T.y], [T.z])" : "an unknown location"]")
		message_admins("[key_name(mob)] has possessed [thing] ([thing.type]) at [T ? "([T.x], [T.y], [T.z])" : "an unknown location"]", 1)

		if(!mob.control_object.len) //If you're not already possessing something...
			mob.name_archive = mob.real_name

		mob.forceMove(thing)
		mob.real_name = thing.name
		mob.name = thing.name
		var/datum/control/new_control = new /datum/control/lock_move(mob, thing)
		mob.control_object.Add(new_control)
		possessing = 1
		new_control.take_control()
		thing.register_event(/event/destroyed, src, nameof(src::possess()))
		feedback_add_details("admin_verb","PO") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/givetestverbs(mob/M as mob in mob_list)
	set desc = "Give this guy possess/release verbs"
	set category = "Debug"
	set name = "Give Possessing Verbs"
	M.verbs += /client/proc/possess
	feedback_add_details("admin_verb","GPV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
