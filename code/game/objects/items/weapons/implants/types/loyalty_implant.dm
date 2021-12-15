/obj/item/weapon/implant/loyalty
	name = "loyalty implant"
	desc = "Induces constant thoughts of loyalty to Nanotrasen."

/obj/item/weapon/implant/loyalty/get_data()
	return {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Nanotrasen Employee Management Implant<BR>
<b>Life:</b> Ten years.<BR>
<b>Important Notes:</b> Personnel injected with this device tend to be much more loyal to the company.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small pod of nanobots that manipulate the host's mental functions.<BR>
<b>Special Features:</b> Will prevent and cure light forms of brainwashing.<BR>
<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}

/obj/item/weapon/implant/loyalty/insert(mob/living/target, target_limb, mob/implanter)
	if(!iscarbon(target))
		return FALSE
	return ..()

/obj/item/weapon/implant/loyalty/implanted(mob/implanter)
	if(imp_in.is_implanted(/obj/item/weapon/implant/traitor))
		imp_in.visible_message("<span class='big danger'>[imp_in] seems to resist the implant!</span>", "<span class='danger'>You feel a strange sensation in your head that quickly dissipates.</span>")
		qdel(src)
		return
	if(isrevhead(imp_in))
		imp_in.visible_message("<span class='big danger'>[imp_in] seems to resist the implant!</span>", "<span class='danger'>You feel the corporate tendrils of Nanotrasen try to invade your mind!</span>")
		qdel(src)
		return
	if(iscultist(imp_in))
		to_chat(imp_in, "<span class='danger'>You feel the corporate tendrils of Nanotrasen trying to invade your mind!</span>")
		var/mob/living/carbon/host = imp_in
		if(istype(host))
			host.implant_pop()
	if(isrevnothead(imp_in))
		var/datum/role/R = imp_in.mind.GetRole(REV)
		R.Drop()

	to_chat(imp_in, "<span class='notice'>You feel a surge of loyalty towards Nanotrasen.</span>")

/obj/item/weapon/implant/loyalty/handle_removal(mob/remover)
	makeunusable(15)
