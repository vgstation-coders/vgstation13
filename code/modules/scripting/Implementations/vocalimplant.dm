/datum/n_Interpreter/vocal_implant/AlertAdmins()
	if(Compiler && !alertadmins)
		if(istype(Compiler, /datum/n_Compiler/vocal_implant))
			var/datum/n_Compiler/vocal_implant/V = Compiler
			var/obj/item/weapon/implant/vocal/VI = V.Holder
			if(VI)
				var/turf/T = get_turf(VI)
				var/message = "Potential crash-inducing NTSL script detected in vocal implant held in [VI.loc] ([T.x], [T.y], [T.z])."

				alertadmins = 1
				message_admins(message, 1)

/datum/n_Compiler/vocal_implant
	var/obj/item/weapon/implant/vocal/Holder	// the implant that is running the code
	interptype = /datum/n_Interpreter/vocal_implant

/datum/n_Compiler/vocal_implant/GC()
	Holder = null
	..()
