/obj/item/weapon/implant/holy
	name = "holy implant"
	desc = "Subjects its user to the chants of a thousand chaplains."

/obj/item/weapon/implant/holy/get_data()
	return {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Holy Dogmatic Interference Implant<BR>
<b>Life:</b> Anywhere from ten days to ten years depending on the strain placed upon the implant by the subject.<BR>
<b>Important Notes:</b> This device was commissioned by Nanotrasen after it proved able to distract occult practitioners, making them unable to practice their dark arts.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Submits its subject to the chants of a thousand chaplains.<BR>
<b>Special Features:</b> Prevents cultists from using their runes and talismans, or from being the target of some of their peers' rituals.<BR>
<b>Integrity:</b> Implant anchors itself against the subject's bones to prevent blood pressure induced ejections."}

/obj/item/weapon/implant/holy/implanted(mob/implanter)
	imp_in << sound('sound/ambience/ambicha1.ogg')
	imp_in << sound('sound/ambience/ambicha2.ogg')
	imp_in << sound('sound/ambience/ambicha3.ogg')
	imp_in << sound('sound/ambience/ambicha4.ogg')
	if(iscultist(imp_in))
		to_chat(imp_in, "<span class='danger'>You feel uneasy as you suddenly start hearing a cacophony of religious chants. You find yourself unable to perform any ritual.</span>")
	else
		to_chat(imp_in, "<span class='notice'>You hear the soothing millennia-old Gregorian chants of the clergy.</span>")

/obj/item/weapon/implant/holy/handle_removal(mob/remover)
	makeunusable(15)
