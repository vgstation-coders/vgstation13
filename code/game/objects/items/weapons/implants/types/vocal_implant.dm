/obj/item/weapon/implant/vocal
	name = "vocal implant"
	icon_state = "implant_evil"
	var/datum/speech_filter/filter
	var/list/memory = list()	// stored memory
	var/rawcode = ""	// the code to compile (raw text)
	var/datum/n_Compiler/vocal_implant/Compiler	// the compiler that compiles and runs the code

/obj/item/weapon/implant/vocal/New()
	..()
	filter = new
	Compiler = new
	Compiler.Holder = src

/obj/item/weapon/implant/vocal/Destroy()
	// Garbage collects all the NTSL datums.
	if(Compiler)
		Compiler.GC()
		Compiler = null
	..()

/obj/item/weapon/implant/vocal/proc/setcode(var/t)
	if(t)
		if(istext(t))
			rawcode = t

/obj/item/weapon/implant/vocal/proc/compile(var/mob/user)
	if(Compiler)
		admin_log(user)
		return Compiler.Compile(rawcode)

/obj/item/weapon/implant/vocal/proc/admin_log(var/mob/mob)
	var/msg = "[key_name(mob)] has compiled a script to a vocal implant"

	diary << msg
	diary << rawcode

	investigation_log(I_NTSL, "[msg]<br /><pre>[rawcode]</pre>")

	if (length(rawcode)) // Let's not bother the admins for empty code.
		message_admins("[msg] ([formatJumpTo(mob)])", 0, 1)

/obj/item/weapon/implant/vocal/get_data()
	return {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Chameleon Voice-Changing Implant<BR>
<b>Life:</b> ??? <BR>
<b>Important Notes:</b> Any humanoid injected with this implant will have their vocal chords muted and replaced with a replica of their own voice on the reception of key phrases.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small pod of nanobots that manipulate the host's mental speech functions and processing.<BR>
<b>Special Features:</b> Vocal manipulation.<BR>
<b>Integrity:</b> Implant will last so long as the subject is speaking."}
