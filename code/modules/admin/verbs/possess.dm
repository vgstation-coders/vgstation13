/client/proc/possess(obj/O as obj in world)
	set name = "Possess Obj"
	set category = "Object"

	if(istype(O,/obj/machinery/singularity))
		if(config.forbid_singulo_possession)
			to_chat(mob, "It is forbidden to possess singularities.")
			return

	var/turf/T = get_turf(O)

	if(T)
		log_admin("[key_name(mob)] has possessed [O] ([O.type]) at ([T.x], [T.y], [T.z])")
		message_admins("[key_name(mob)] has possessed [O] ([O.type]) at ([T.x], [T.y], [T.z])", 1)
	else
		log_admin("[key_name(mob)] has possessed [O] ([O.type]) at an unknown location")
		message_admins("[key_name(mob)] has possessed [O] ([O.type]) at an unknown location", 1)

	if(!mob.control_object.len) //If you're not already possessing something...
		mob.name_archive = mob.real_name

	mob.forceMove(O)
	mob.real_name = O.name
	mob.name = O.name
	var/datum/control/new_control = new /datum/control/lock_move(mob, O)
	mob.control_object.Add(new_control)
	mob.verbs += /client/proc/release
	mob.verbs -= /client/proc/possess
	new_control.take_control()
	O.register_event(/event/destroyed, src, nameof(src::release()))
	feedback_add_details("admin_verb","PO") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/release(obj/O as obj in world)
	set name = "Release Obj"
	set category = "Object"
	//mob.loc = get_turf(mob)
	var/datum/control/actual
	for(var/datum/control/C in mob.control_object)
		if(C.controlled == O)
			actual = C
			break
	if(actual && mob.name_archive) //if you have a name archived and if you are actually relassing an object
		mob.real_name = mob.name_archive
		mob.name = mob.real_name
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			H.update_name()
//		mob.regenerate_icons() //So the name is updated properly

	mob.forceMove(O.loc) // Appear where the object you were controlling is -- TLE
	mob.client.eye = mob
	mob.verbs -= /client/proc/release
	mob.verbs += /client/proc/possess

	if(actual)
		actual.break_control()
		qdel(actual)
	feedback_add_details("admin_verb","RO") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/givetestverbs(mob/M as mob in mob_list)
	set desc = "Give this guy possess/release verbs"
	set category = "Debug"
	set name = "Give Possessing Verbs"
	M.verbs += /client/proc/possess
	feedback_add_details("admin_verb","GPV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
