/obj/item/weapon/implant/traitor
	name = "greytide implant"
	desc = "Greytide station wide."
	icon_state = "implant_evil"

/obj/item/weapon/implant/traitor/get_data()
	return {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Greytide Mind-Slave Implant<BR>
<b>Life:</b> ??? <BR>
<b>Important Notes:</b> Any humanoid injected with this implant will become loyal to the injector and the greytide, unless of course the host is already loyal to someone else.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a small pod of nanobots that manipulate the host's mental functions.<BR>
<b>Special Features:</b> Glory to the Greytide!<BR>
<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}

/obj/item/weapon/implant/traitor/insert(mob/living/target, target_limb, mob/implanter)
	. = ..()
	if (!.)
		return FALSE
	if(!iscarbon(target))
		to_chat(implanter, "<span class='danger'>The implant doesn't seem to be compatible with [target]!</span>")
		return FALSE
	if(!target.mind)
		to_chat(implanter, "<span class='danger'>[target] lacks a mind to affect!</span>")
		return FALSE
	if(target == implanter)
		to_chat(target, "<span class='notice'>You feel quite stupid for doing that.</span>")
		target.adjustBrainLoss(10)
		return FALSE

	/* We check for faction here to fail the insertion if the target is already greytided to us, and in implanted() to handle recruiting them. */
	var/datum/faction/F = find_active_faction_by_typeandmember(/datum/faction/syndicate/greytide, null, implanter.mind)
	if(!F)
		F = ticker.mode.CreateFaction(/datum/faction/syndicate/greytide, 0, 1)
		F.HandleNewMind(implanter.mind)
	for(var/datum/role/grey in F.members)
		if(grey.antag == imp_in.mind)
			to_chat(implanter, "<span class='warning'>[imp_in] is already on our side!</span>")
			return FALSE

/obj/item/weapon/implant/traitor/implanted(mob/implanter)
	for(var/obj/item/weapon/implant/I in imp_in)
		if(I == src)
			continue
		if(istype(I, /obj/item/weapon/implant/traitor) || istype(I, /obj/item/weapon/implant/loyalty))
			if(I.imp_in == imp_in)
				imp_in.visible_message("<span class='big danger'>[imp_in] seems to resist the implant!</span>", "<span class='danger'>You feel a strange sensation in your head that quickly dissipates.</span>")
				remove(imp_in)
				return

	if(istraitor(imp_in) || ischallenger(imp_in))
		imp_in.visible_message("<span class='big danger'>[imp_in] seems to resist the implant!</span>", "<span class='danger'>You feel a familiar sensation in your head that quickly dissipates.</span>")
		remove(imp_in)
		return

	var/datum/faction/F = find_active_faction_by_typeandmember(/datum/faction/syndicate/greytide, null, implanter.mind)
	if(!F)
		message_admins("ERROR: Greytide implant failed to find valid faction at implanted() after passing faction check in insert().")
		stack_trace("ERROR: Greytide implant failed to find valid faction at implanted() after passing faction check in insert().")
		return
	var/success = F.HandleRecruitedMind(imp_in.mind)
	if(success)
		F.forgeObjectives()
		update_faction_icons()
	else /* This will never actually happen at present. I don't know why it's here, but it's worth keeping around in case anyone has a funny idea for it. */
		visible_message("<span class = 'warning'>The head of [imp_in] begins to glow a deep red. It is going to explode!</span>")
		spawn(3 SECONDS)
			var/datum/organ/external/head/head_organ = imp_in.get_organ(LIMB_HEAD)
			head_organ.explode()
			qdel(src)
		return

	to_chat(imp_in, "<span class='notice'>You feel a surge of loyalty towards [implanter.name].</span>")
	to_chat(imp_in, "<B><span class='big warning'>You've been shown the Greytide by [implanter.name]!</B> You now must lay down your life to protect them and assist in their goals at any cost.</span>")
	log_admin("[ckey(implanter.key)] has mind-slaved [ckey(imp_in.key)].")

/obj/item/weapon/implant/traitor/handle_removal(mob/remover)
	if (!imp_in.mind)
		return
	var/datum/role/R = imp_in.mind.GetRole(IMPLANTSLAVE)
	if (!R)
		return
	log_admin("[key_name(remover)] has removed a greytide implant from [key_name(imp_in)].")
	R.Drop(FALSE)

	makeunusable(90)
