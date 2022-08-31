/client/verb/visave()
	set hidden = 1
	if(implant_check(mob))
		var/obj/item/weapon/implanter/vocal/V = mob.get_active_hand()
		if(V.imp)
			var/obj/item/weapon/implant/vocal/VI = V.imp
			var/vicode = winget(src, "vicode", "text")
			VI.setcode( vicode ) // this actually saves the code from input to the implant
			src << output(null, "vierror") // clear the errors
		else
			src << output(null, "vierror")
			src << output("<font color = red>Failed to save: Unable to locate vocal implant. (Back up your code before exiting the window!)</font color>", "vierror")
	else
		src << output(null, "vierror")
		src << output("<font color = red>Failed to save: Unable to locate implant. (Back up your code before exiting the window!)</font color>", "vierror")


/client/verb/vicompile()
	set hidden = 1
	if(implant_check(mob))
		var/obj/item/weapon/implanter/vocal/V = mob.get_active_hand()
		if(V.imp)
			var/obj/item/weapon/implant/vocal/VI = V.imp
			VI.setcode( winget(src, "vicode", "text") ) // save code first

			spawn(0)
				// Output all the compile-time errors
				src << output(null, "vierror")
				src << output("<font color = black>Please wait, compiling...</font>", "vierror")

				var/list/compileerrors = VI.compile(mob) // then compile the code!
				if(!implant_check(mob))
					return

				if(compileerrors.len)
					src << output("<b>Compile Errors</b>", "vierror")
					for(var/datum/scriptError/e in compileerrors)
						src << output("<font color = red>\t>[e.message]</font color>", "vierror")
					src << output("([compileerrors.len] errors)", "vierror")

				else
					src << output("<font color = blue>vi compilation successful!</font color>", "vierror")
					src << output("(0 errors)", "vierror")

		else
			src << output(null, "vierror")
			src << output("<font color = red>Failed to compile: Unable to locate vocal implant. (Back up your code before exiting the window!)</font color>", "vierror")
	else
		src << output(null, "vierror")
		src << output("<font color = red>Failed to compile: Unable to locate implant. (Back up your code before exiting the window!)</font color>", "vierror")

/client/verb/virun()
	set hidden = 1
	if(implant_check(mob))
		var/obj/item/weapon/implanter/vocal/V = mob.get_active_hand()
		if(V.imp)
			var/obj/item/weapon/implant/vocal/VI = V.imp

			var/datum/signal/signal = new /datum/signal
			signal.data["message"] = ""
			signal.data["reject"] = 0
			signal.data["implant"] = VI

			VI.Compiler.Run(signal)
			if(!signal.data["reject"])
				V.say(signal.data["message"])

		else
			src << output(null, "vierror")
			src << output("<font color = red>Failed to run: Unable to locate vocal implant. (Back up your code before exiting the window!)</font color>", "vierror")
	else
		src << output(null, "vierror")
		src << output("<font color = red>Failed to run: Unable to locate implant. (Back up your code before exiting the window!)</font color>", "vierror")

/client/verb/virevert()
	set hidden = 1
	if(implant_check(mob))
		var/obj/item/weapon/implanter/vocal/V = mob.get_active_hand()
		if(V.imp)
			var/obj/item/weapon/implant/vocal/VI = V.imp

			// Replace quotation marks with quotation macros for proper winset() compatibility
			var/showcode = replacetext(VI.rawcode, "\\\"", "\\\\\"")
			showcode = replacetext(showcode, "\"", "\\\"")

			winset(mob, "vicode", "text=\"[showcode]\"")

			src << output(null, "vierror") // clear the errors
		else
			src << output(null, "vierror")
			src << output("<font color = red>Failed to revert: Unable to locate vocal implant.</font color>", "vierror")
	else
		src << output(null, "vierror")
		src << output("<font color = red>Failed to revert: Unable to locate implant.</font color>", "vierror")


/client/verb/viclearmem()
	set hidden = 1
	if(implant_check(mob))
		var/obj/item/weapon/implanter/vocal/V = mob.get_active_hand()
		if(V.imp)
			var/obj/item/weapon/implant/vocal/VI = V.imp
			VI.memory = list() // clear the memory
			// Show results
			src << output(null, "vierror")
			src << output("<font color = blue>Implant memory cleared!</font color>", "vierror")
		else
			src << output(null, "vierror")
			src << output("<font color = red>Failed to clear memory: Unable to locate vocal implant.</font color>", "vierror")
	else
		src << output(null, "vierror")
		src << output("<font color = red>Failed to clear memory: Unable to locate implant.</font color>", "vierror")

/proc/implant_check(var/mob/mob)
	if(mob && istype(mob.get_active_hand(),/obj/item/weapon/implanter/vocal))
		return 1
	return 0
