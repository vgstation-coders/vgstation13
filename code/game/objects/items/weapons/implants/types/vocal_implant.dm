/obj/item/weapon/implant/vocal
	name = "vocal implant"
	icon_state = "implant_evil"
	var/datum/speech_filter/filter

/obj/item/weapon/implant/vocal/New()
	..()
	filter = new

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
