/obj/item/weapon/implant/adrenalin
	name = "adrenalin implant"
	desc = "Removes all stuns and knockdowns."
	var/uses

/obj/item/weapon/implant/adrenalin/get_data()
	return {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Cybersun Industries Adrenalin Implant<BR>
<b>Life:</b> Five days.<BR>
<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
<HR>
<b>Implant Details:</b> Subjects injected with implant can activate a massive injection of adrenalin.<BR>
<b>Function:</b> Contains nanobots to stimulate body to mass-produce Adrenalin.<BR>
<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
<b>Integrity:</b> Implant can only be used three times before the nanobots are depleted."}

/obj/item/weapon/implant/adrenalin/trigger(emote, mob/source)
	if(malfunction == IMPLANT_MALFUNCTION_PERMANENT)
		return 0
	if (src.uses < 1)
		return 0
	if (emote == "pale")
		src.uses--
		to_chat(source, "<span class = 'notice'>You feel a sudden surge of energy!</span>")
		source.SetStunned(0)
		source.SetKnockdown(0)
		source.SetParalysis(0)

/obj/item/weapon/implant/adrenalin/implanted(mob/implanter)
	imp_in.register_event(/event/emote, src, nameof(src::trigger()))
	imp_in.mind.store_memory("The freedom implant can be activated by using the pale emote, <B>say *pale</B> to attempt to activate.", 0, 0)
	to_chat(imp_in, "The implanted freedom implant can be activated by using the pale emote, <B>say *pale</B> to attempt to activate.")

/obj/item/weapon/implant/adrenalin/handle_removal(mob/remover)
	imp_in?.unregister_event(/event/emote, src, nameof(src::trigger()))
	makeunusable(75)
